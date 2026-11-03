import NeuralGeneralization.PointwiseRobustSupport
import NeuralGeneralization.BatchTwoContinuousModel
import Mathlib.Analysis.InnerProductSpace.PiL2

/-! Input-neighborhood transfer for the actual real-input tanh network.
The input distance uses only the non-bias columns of the first layer. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel
open BatchTwoContinuous (RealInput augmentedInput)
variable {d N r : ℕ}

/-- Euclidean coordinates for exactly the manuscript's joint RMS noise norm. -/
def noiseVector (η : NetworkDisturbance N r) :
    EuclideanSpace ℝ ((Fin (r+1) × Fin N) ⊕ Unit) :=
  WithLp.toLp 2 (Sum.elim (fun si => η.1 si.1 si.2 / Real.sqrt N) (fun _ => η.2))

lemma noiseVector_norm_sq (η : NetworkDisturbance N r) :
    ‖noiseVector η‖^2 = noiseBudgetSq η := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [noiseVector,PiLp.toLp_apply,Fintype.sum_sum_type,Fintype.sum_prod_type,
    Fintype.sum_unique,Sum.elim_inl,Sum.elim_inr,div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
  simp only [← Finset.sum_div,noiseBudgetSq]

lemma noiseVector_add (η ζ : NetworkDisturbance N r) :
    noiseVector (η+ζ) = noiseVector η+noiseVector ζ := by
  ext i
  cases i <;> simp [noiseVector,add_div]

/-- Triangle inequality for the exact normalized disturbance budget. -/
lemma noiseBudgetSq_add_le (η ζ : NetworkDisturbance N r) {a b : ℝ}
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hη : noiseBudgetSq η ≤ a^2)
    (hζ : noiseBudgetSq ζ ≤ b^2) : noiseBudgetSq (η+ζ) ≤ (a+b)^2 := by
  rw [← noiseVector_norm_sq] at hη hζ ⊢
  have he := (sq_le_sq₀ (norm_nonneg _) ha).mp hη
  have hz := (sq_le_sq₀ (norm_nonneg _) hb).mp hζ
  rw [noiseVector_add]
  exact (sq_le_sq₀ (norm_nonneg _) (add_nonneg ha hb)).mpr
    ((norm_add_le _ _).trans (add_le_add he hz))

/-- The same postactivation/noisy readout model, for arbitrary real inputs. -/
def realNoisyOutput (φ : ℝ → ℝ) (w : Weights d N r) (x : RealInput d)
    (η : NetworkDisturbance N r) : ℝ :=
  (∑ i,w (.inr (.inr i))*((List.finRange r).foldl (noisyHiddenStep φ w η)
    (fun i => BatchTwoContinuous.firstHidden φ w x i+η.1 0 i)) i)+η.2

@[simp] lemma realNoisyOutput_zero (φ : ℝ → ℝ) (w : Weights d N r) (x : RealInput d) :
    realNoisyOutput φ w x 0 = BatchTwoContinuous.output φ w x := by
  simp [realNoisyOutput,BatchTwoContinuous.output,BatchTwoContinuous.finalHidden]

lemma realNoisyOutput_on_cube (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    realNoisyOutput φ w (fun i => labelReal (x i)) η = noisyNetworkOutput φ w x η := rfl

/-- The literal input semimetric, with the bias column excluded. -/
def inputDistance (w : Weights d N r) (x x₀ : RealInput d) : ℝ :=
  Real.sqrt ((∑ i,(∑ j,w (.inl (i,j.succ))*(x j-x₀ j))^2)/(N:ℝ))

lemma inputDistance_nonneg (w : Weights d N r) (x x₀ : RealInput d) :
    0 ≤ inputDistance w x x₀ := Real.sqrt_nonneg _

def firstShift (φ : ℝ → ℝ) (w : Weights d N r) (x x₀ : RealInput d) :
    NetworkDisturbance N r :=
  (Fin.cases (fun i => BatchTwoContinuous.firstHidden φ w x i-
    BatchTwoContinuous.firstHidden φ w x₀ i) (fun _ _ => 0),0)

lemma firstShift_budget (w : Weights d N r) (x x₀ : RealInput d) :
    noiseBudgetSq (firstShift Real.tanh w x x₀) ≤ (inputDistance w x x₀)^2 := by
  have hn : 0 ≤ (∑ i,(∑ j,w (.inl (i,j.succ))*(x j-x₀ j))^2)/(N:ℝ) := by positivity
  rw [inputDistance,Real.sq_sqrt hn]
  simp only [noiseBudgetSq,firstShift,Fin.sum_univ_succ,Fin.cases_zero,Fin.cases_succ,
    zero_pow (by omega : 2 ≠ 0),Finset.sum_const_zero,add_zero]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
  apply Finset.sum_le_sum
  intro i _
  have hl := tanh_admissible.2
    (∑ j,w (.inl (i,j))*augmentedInput x j)
    (∑ j,w (.inl (i,j))*augmentedInput x₀ j)
  have he : (∑ j,w (.inl (i,j))*augmentedInput x j)-
      (∑ j,w (.inl (i,j))*augmentedInput x₀ j) =
      ∑ j,w (.inl (i,j.succ))*(x j-x₀ j) := by
    rw [← Finset.sum_sub_distrib,Fin.sum_univ_succ]
    simp [augmentedInput,mul_sub]
  rw [he] at hl
  exact (sq_le_sq).mpr hl

/-- Moving the input is exactly equivalent to adding its first-state
change to the first hidden injection. All later injections are identical. -/
lemma realNoisyOutput_shift (φ : ℝ → ℝ) (w : Weights d N r)
    (x x₀ : RealInput d) (η : NetworkDisturbance N r) :
    realNoisyOutput φ w x₀ (η+firstShift φ w x x₀) = realNoisyOutput φ w x η := by
  have hs : noisyHiddenStep φ w (η+firstShift φ w x x₀) = noisyHiddenStep φ w η := by
    funext h s i
    simp [noisyHiddenStep,firstShift]
  have hf : (fun i => BatchTwoContinuous.firstHidden φ w x₀ i+
      (η+firstShift φ w x x₀).1 0 i) =
      (fun i => BatchTwoContinuous.firstHidden φ w x i+η.1 0 i) := by
    funext i
    simp only [Prod.fst_add,Pi.add_apply,firstShift,Fin.cases_zero]
    ring
  unfold realNoisyOutput
  rw [hs,hf]
  simp [firstShift]

/-- The exact confident-neighborhood transfer. It holds for arbitrary real
inputs, not just cube vertices, and permits unrestricted hidden injections. -/
theorem input_neighborhood_transfer (w : Weights d N r) (x₀ : RealInput d)
    (p : Bool) {c R : ℝ} (hc : 0 < c) (hR : robustRadius c w < R)
    (hcenter : ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ R^2 →
      (1/2:ℝ) < labelReal p*realNoisyOutput Real.tanh w x₀ η)
    (x : RealInput d) (hx : inputDistance w x x₀ ≤ R-robustRadius c w) :
    ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
      clippedScore (realNoisyOutput Real.tanh w x η) = labelReal p/2 ∧
      clippedScore (BatchTwoContinuous.output Real.tanh w x) = labelReal p/2 := by
  have hr := (robustRadius_pos hc w).le
  have hlocal (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ (robustRadius c w)^2) :
      clippedScore (realNoisyOutput Real.tanh w x η) = labelReal p/2 := by
    have hb := noiseBudgetSq_add_le η (firstShift Real.tanh w x x₀) hr
      (inputDistance_nonneg w x x₀) hη (firstShift_budget w x x₀)
    have htotal : noiseBudgetSq (η+firstShift Real.tanh w x x₀) ≤ R^2 := by
      apply hb.trans
      apply (sq_le_sq₀ (add_nonneg hr (inputDistance_nonneg w x x₀)) (hr.trans hR.le)).mpr
      linarith
    have hm := hcenter _ htotal
    rw [realNoisyOutput_shift] at hm
    exact clippedScore_eq_label_of_margin p _ hm.le
  intro η hη
  refine ⟨hlocal η hη,?_⟩
  simpa only [realNoisyOutput_zero] using hlocal 0 (by simp; positivity)

/-- The neighborhood theorem certifies the original Boolean stability
predicate with zero clipped-score change. -/
theorem input_neighborhood_stableAt (w : Weights d N r) (x₀ : RealInput d)
    (p : Bool) {c R : ℝ} (hc : 0 < c) (hR : robustRadius c w < R)
    (hcenter : ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ R^2 →
      (1/2:ℝ) < labelReal p*realNoisyOutput Real.tanh w x₀ η)
    (x : Cube d) (hx : inputDistance w (fun i => labelReal (x i)) x₀ ≤ R-robustRadius c w) :
    stableAt Real.tanh c w x := by
  intro η hη
  have hh := input_neighborhood_transfer w x₀ p hc hR hcenter _ hx η hη
  rw [realNoisyOutput_on_cube,BatchTwoContinuous.output_on_cube] at hh
  rw [hh.1,hh.2,sub_self,abs_zero]
  norm_num

end NeuralGeneralization.RobustCertificates
