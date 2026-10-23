import NeuralGeneralization.RobustModelContinuity
import NeuralGeneralization.FunctionPriorFacts
import NeuralGeneralization.BatchTwoShallowRobust
import Mathlib.Topology.Order.Compact
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-! The actual gain-restricted tanh prior in the depth-polynomial converse. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
open ConcreteModel

abbrev Slopes (N r : ℕ) := Fin r → Fin N → ℝ
def slopeCube (N r : ℕ) : Set (Slopes N r) := Icc 0 1

theorem slopeCube_nonempty (N r : ℕ) : (slopeCube N r).Nonempty :=
  ⟨0, by simp [slopeCube]⟩

theorem slopeCube_compact (N r : ℕ) : IsCompact (slopeCube N r) := isCompact_Icc

def pathRow {d N r : ℕ} (w : Weights d N r) (D : Slopes N r) : List (Fin r) → Fin N → ℝ
  | [], j => w (Sum.inr (Sum.inr j))
  | s::ss, j => ∑ i, pathRow w D ss i * D s i * w (Sum.inr (Sum.inl (s,i,j)))

def gainEnergy {d N r : ℕ} (w : Weights d N r) (D : Slopes N r) : ℝ :=
  (N : ℝ)*∑ j : Fin (r+1), ∑ i, pathRow w D ((List.finRange r).drop j.val) i ^ 2

def gainSq {d N r : ℕ} (w : Weights d N r) : ℝ :=
  sSup (gainEnergy w '' slopeCube N r)

theorem continuous_pathRow {d N r : ℕ} (ss : List (Fin r)) (i : Fin N) :
    Continuous (fun p : Weights d N r × Slopes N r => pathRow p.1 p.2 ss i) := by
  induction ss generalizing i with
  | nil => exact (continuous_apply (Sum.inr (Sum.inr i))).comp continuous_fst
  | cons s ss ih =>
      simp only [pathRow]
      apply continuous_finsetSum
      intro j _
      exact ((ih j).mul ((continuous_apply j).comp ((continuous_apply s).comp continuous_snd))).mul
        ((continuous_apply (Sum.inr (Sum.inl (s,j,i)))).comp continuous_fst)

theorem continuous_gainEnergy {d N r : ℕ} :
    Continuous (fun p : Weights d N r × Slopes N r => gainEnergy p.1 p.2) := by
  unfold gainEnergy
  apply continuous_const.mul
  apply continuous_finsetSum
  intro j _
  apply continuous_finsetSum
  intro i _
  exact (continuous_pathRow _ i).pow 2

theorem continuous_gainSq {d N r : ℕ} : Continuous (gainSq : Weights d N r → ℝ) :=
  (slopeCube_compact N r).continuous_sSup continuous_gainEnergy

theorem gainEnergy_nonneg {d N r : ℕ} (w : Weights d N r) (D : Slopes N r) :
    0 ≤ gainEnergy w D := by unfold gainEnergy; positivity

theorem gainEnergy_le_gainSq {d N r : ℕ} (w : Weights d N r) (D : Slopes N r)
    (hD : D ∈ slopeCube N r) : gainEnergy w D ≤ gainSq w := by
  have hc : Continuous (gainEnergy w) := continuous_gainEnergy.comp (continuous_const.prodMk continuous_id)
  exact le_csSup ((slopeCube_compact N r).image hc).bddAbove ⟨D,hD,rfl⟩

theorem gainSq_nonneg {d N r : ℕ} (w : Weights d N r) : 0 ≤ gainSq w := by
  obtain ⟨D,hD⟩ := slopeCube_nonempty N r
  exact (gainEnergy_nonneg w D).trans (gainEnergy_le_gainSq w D hD)

def gainSupport {d N r : ℕ} (Λ U : ℝ) : Set (Weights d N r) :=
  {w | (∀ x : Cube d, (1 : ℝ)/2 < |networkOutput Real.tanh w x| ∧
      |networkOutput Real.tanh w x| < U) ∧
    gainSq w < Λ^2*((r : ℝ)+1)*readoutEnergy w}

theorem isOpen_gainSupport {d N r : ℕ} (Λ U : ℝ) : IsOpen (gainSupport (d := d) (N := N) (r := r) Λ U) := by
  unfold gainSupport
  simp only [setOf_and, setOf_forall]
  apply IsOpen.inter
  · apply isOpen_iInter_of_finite
    intro x
    exact (isOpen_lt continuous_const (continuous_networkOutput tanh_continuous x).abs).inter
      (isOpen_lt (continuous_networkOutput tanh_continuous x).abs continuous_const)
  · exact isOpen_lt continuous_gainSq (continuous_readoutEnergy.const_mul _)

def functionSupport {d N r : ℕ} (Λ U : ℝ) (f : BooleanFunction d) : Set (Weights d N r) :=
  gainSupport Λ U ∩ marginEvent Real.tanh (1/2) f

theorem isOpen_functionSupport {d N r : ℕ} (Λ U : ℝ) (f : BooleanFunction d) :
    IsOpen (functionSupport (N := N) (r := r) Λ U f) := by
  apply (isOpen_gainSupport Λ U).inter
  unfold marginEvent
  simp only [setOf_forall]
  apply isOpen_iInter_of_finite
  intro x
  exact isOpen_lt continuous_const ((continuous_networkOutput tanh_continuous x).const_mul _)

def restrictedPrior {d N r : ℕ} (σ Λ U : ℝ) : Measure (Weights d N r) :=
  cond (smallPrior d N r σ) (gainSupport Λ U)

def signTraining {d N r : ℕ} (f : BooleanFunction d) (A : Finset (Cube d)) : Set (Weights d N r) :=
  {w | ∀ x ∈ A, 0 < labelReal (f x)*networkOutput Real.tanh w x}

def posterior {d N r : ℕ} (σ Λ U : ℝ) (f : BooleanFunction d) (A : Finset (Cube d)) :
    Measure (Weights d N r) := cond (restrictedPrior σ Λ U) (signTraining f A)

theorem tanh_monotone : Monotone Real.tanh := by
  apply monotone_of_deriv_nonneg (fun x => (hasDerivAt_tanh x).differentiableAt)
  intro x
  rw [(hasDerivAt_tanh x).deriv]
  positivity

def tanhSlope (a b : ℝ) : ℝ := if a=b then 0 else (Real.tanh a-Real.tanh b)/(a-b)

theorem tanhSlope_mul (a b : ℝ) : tanhSlope a b*(a-b)=Real.tanh a-Real.tanh b := by
  unfold tanhSlope
  split_ifs with he
  · simp [he]
  · exact div_mul_cancel₀ _ (sub_ne_zero.mpr he)

theorem tanhSlope_bounds (a b : ℝ) : 0 ≤ tanhSlope a b ∧ tanhSlope a b ≤ 1 := by
  unfold tanhSlope
  split_ifs with he
  · norm_num
  · have hab := tanh_admissible.2 a b
    rcases lt_or_gt_of_ne he with hlt | hgt
    · have hm := tanh_monotone hlt.le
      have hd : a-b < 0 := sub_neg.mpr hlt
      constructor
      · exact div_nonneg_of_nonpos (sub_nonpos.mpr hm) hd.le
      · apply (div_le_one_of_neg hd).mpr
        rw [abs_of_nonpos (sub_nonpos.mpr hm), abs_of_neg hd] at hab
        linarith
    · have hm := tanh_monotone hgt.le
      have hd : 0 < a-b := sub_pos.mpr hgt
      constructor
      · exact div_nonneg (sub_nonneg.mpr hm) hd.le
      · apply (div_le_one hd).mpr
        rwa [abs_of_nonneg (sub_nonneg.mpr hm), abs_of_pos hd] at hab

end
end NeuralGeneralization.BatchTwoNeuralConverse
