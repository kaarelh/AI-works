import NeuralGeneralization.ValidStateSupport
import Mathlib.Topology.Maps.Proper.Basic

/-! Borel measurability of valid-state support. Failures are a countable
union of closed projections with compact path and scalar-noise parameters.
This avoids an invalid interchange of uncountable measurable intersections. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ValidState
open ConcreteModel RobustCompressionInduction
variable {d N r : ℕ}

abbrev PathBox (N r : ℕ) := {h : HiddenPath N r // validHiddenPath h}

instance pathBox_compact (N r : ℕ) : CompactSpace (PathBox N r) :=
  isCompact_iff_compactSpace.mp (isCompact_validHiddenPath N r)

abbrev BoundedParameter (N r : ℕ) (c : ℝ) := PathBox N r × Set.Icc (-c) c

instance boundedParameter_compact (N r : ℕ) (c : ℝ) : CompactSpace (BoundedParameter N r c) := by
  letI : CompactSpace (Set.Icc (-c) c) := isCompact_iff_compactSpace.mp isCompact_Icc
  infer_instance

def badStage (n : ℕ) (φ : ℝ → ℝ) (c : ℝ) (x : Cube d) : Set (Weights d N r) :=
  Prod.fst '' {p : Weights d N r × BoundedParameter N r c |
    hiddenPathCost φ p.1 x p.2.1.val+p.2.2.val^2 ≤ (robustRadius c p.1)^2 ∧
    (1/16:ℝ)+1/((n:ℝ)+1) ≤
      |clippedScore (pathOutput p.1 p.2.1.val p.2.2.val)-clippedScore (networkOutput φ p.1 x)|}

lemma isClosed_badStage (n : ℕ) {φ : ℝ → ℝ} (hφ : Continuous φ) (c : ℝ) (x : Cube d) :
    IsClosed (badStage (N := N) (r := r) n φ c x) := by
  apply isClosedMap_fst_of_compactSpace
  have hw (i : WeightIndex d N r) : Continuous (fun p : Weights d N r × BoundedParameter N r c => p.1 i) :=
    (continuous_apply i).comp continuous_fst
  have hh (s : Fin (r+1)) (i : Fin N) : Continuous (fun p : Weights d N r × BoundedParameter N r c => p.2.1.val s i) :=
    (continuous_apply i).comp ((continuous_apply s).comp
      (continuous_subtype_val.comp (continuous_fst.comp continuous_snd)))
  have ht : Continuous (fun p : Weights d N r × BoundedParameter N r c => p.2.2.val) :=
    continuous_subtype_val.comp (continuous_snd.comp continuous_snd)
  have hcost : Continuous (fun p : Weights d N r × BoundedParameter N r c =>
      hiddenPathCost φ p.1 x p.2.1.val+p.2.2.val^2) := by
    apply Continuous.add _ (ht.pow 2)
    apply Continuous.div_const
    apply Continuous.add
    · exact continuous_finsetSum _ fun i _ =>
        ((hh 0 i).sub ((continuous_firstHidden hφ x i).comp continuous_fst)).pow 2
    · exact continuous_finsetSum _ fun s _ => continuous_finsetSum _ fun i _ =>
        ((hh s.succ i).sub (hφ.comp (continuous_finsetSum _ fun j _ =>
          (hw (.inr (.inl (s,i,j)))).mul (hh s.castSucc j)))).pow 2
  have houtput : Continuous (fun p : Weights d N r × BoundedParameter N r c =>
      pathOutput p.1 p.2.1.val p.2.2.val) :=
    (continuous_finsetSum _ fun i _ => (hw (.inr (.inr i))).mul (hh (Fin.last r) i)).add ht
  have hclean : Continuous (fun p : Weights d N r × BoundedParameter N r c =>
      networkOutput φ p.1 x) := (continuous_networkOutput hφ x).comp continuous_fst
  exact (isClosed_le hcost (((continuous_robustRadius c).comp continuous_fst).pow 2)).inter
    (isClosed_le continuous_const (((continuous_clippedScore.comp houtput).sub
      (continuous_clippedScore.comp hclean)).abs))

lemma not_atInput_iff_badStage (φ : ℝ → ℝ) {c : ℝ} (hc : 0 < c)
    (w : Weights d N r) (x : Cube d) :
    ¬ atInput φ c w x ↔ ∃ n : ℕ,w ∈ badStage n φ c x := by
  classical
  constructor
  · intro hn
    rw [atInput_iff_pathOutput] at hn
    push_neg at hn
    obtain ⟨h,hvalid,t,hbudget,hbad⟩ := hn
    have ht : |t| ≤ robustRadius c w := by
      apply (sq_le_sq₀ (abs_nonneg _) (robustRadius_pos hc w).le).mp
      rw [sq_abs]
      linarith [hiddenPathCost_nonneg φ w x h]
    have htc : |t| ≤ c := ht.trans (robustRadius_le_calibration hc.le w)
    obtain ⟨n,hn⟩ := exists_nat_one_div_lt (sub_pos.mpr hbad)
    refine ⟨n,?_⟩
    refine ⟨(w,⟨h,hvalid⟩,⟨t,abs_le.mp htc⟩),⟨hbudget,?_⟩,rfl⟩
    linarith
  · rintro ⟨n,⟨p,⟨hbudget,hbad⟩,heq⟩⟩ hw
    have hh := (atInput_iff_pathOutput φ c w x).mp hw p.2.1.val p.2.1.property p.2.2.val
    have he : p.1=w := heq
    rw [he] at hbudget hbad
    have hh' := hh hbudget
    have hp : (0:ℝ) < 1/((n:ℝ)+1) := by positivity
    linarith

lemma measurable_atInput {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) (x : Cube d) :
    MeasurableSet {w : Weights d N r | atInput φ c w x} := by
  have heq : {w : Weights d N r | ¬ atInput φ c w x} = ⋃ n : ℕ,badStage n φ c x := by
    ext w
    simp only [Set.mem_setOf_eq,Set.mem_iUnion]
    exact not_atInput_iff_badStage φ hc w x
  have hh : MeasurableSet {w : Weights d N r | ¬ atInput φ c w x} := by
    rw [heq]
    exact MeasurableSet.iUnion fun n => (isClosed_badStage n hφ c x).measurableSet
  simpa only [Set.compl_setOf,not_not] using hh.compl

lemma measurable_support {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter (measurable_atInput hφ hc)

end NeuralGeneralization.ValidState
