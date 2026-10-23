import NeuralGeneralization.BatchTwoShallowCompression
import NeuralGeneralization.BatchTwoShallowStability
import NeuralGeneralization.BatchTwoFiniteMixtures

/-! The vote loss is an indicator at the midpoint of the two margins. This
replaces the manuscript's ramp without changing its main constants. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel CompressionSampling BoundedDual

def voteLoss {d : ℕ} (f : BooleanFunction d) (B : ℝ) (m : ℕ)
    (a : Fin m → Halfspace d) (x : Cube d) : ℝ :=
  if labelReal (f x)*vote B m a x ≤ 3/8 then 1 else 0

theorem voteLoss_bounds {d : ℕ} (f : BooleanFunction d) (B : ℝ) (m : ℕ)
    (a : Fin m → Halfspace d) (x : Cube d) :
    0 ≤ voteLoss f B m a x ∧ voteLoss f B m a x ≤ 1 := by
  unfold voteLoss
  split_ifs <;> norm_num

theorem integral_voteLoss {d : ℕ} (f : BooleanFunction d) (B : ℝ) (m : ℕ)
    (P : Measure (Fin m → Halfspace d)) (x : Cube d) :
    (∫ a, voteLoss f B m a x ∂P) = P.real {a | labelReal (f x)*vote B m a x ≤ 3/8} := by
  convert integral_indicator_one (μ := P)
    (Set.toFinite {a : Fin m → Halfspace d | labelReal (f x)*vote B m a x ≤ 3/8}).measurableSet using 1
  congr 1

theorem train_voteLoss {d N : ℕ} (f : BooleanFunction d) {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B)
    (m : ℕ) (hm : 0 < m) (x : Cube d)
    (hmargin : (1 : ℝ)/2 < labelReal (f x)*(∑ i, v i*Real.tanh (dot (b i) (inputVector x)))) :
    (∫ a, voteLoss f B m a x ∂iidSamples (mixtureLaw hB b v hv) m) ≤
      2*Real.exp (-(m : ℝ)/(512*B^2)) := by
  rw [integral_voteLoss]
  apply (measureReal_mono ?_).trans (vote_approximation_tail hB b v hv m hm x)
  intro a ha
  change (1 : ℝ)/16 < |vote B m a x-∑ i, v i*Real.tanh (dot (b i) (inputVector x))|
  by_contra he
  have herr : |labelReal (f x)*(vote B m a x-∑ i, v i*Real.tanh (dot (b i) (inputVector x)))| ≤ 1/16 := by
    simpa only [abs_mul, abs_labelReal, one_mul] using le_of_not_gt he
  have hlow := (abs_le.mp herr).1
  change labelReal (f x)*vote B m a x ≤ 3/8 at ha
  nlinarith

theorem test_voteLoss {d N : ℕ} (f : BooleanFunction d) {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B)
    (m : ℕ) (hm : 0 < m) (x : Cube d) :
    (if labelReal (f x)*(∑ i, v i*Real.tanh (dot (b i) (inputVector x))) ≤ 1/4 then (1 : ℝ) else 0) ≤
      2*Real.exp (-(m : ℝ)/(512*B^2)) +
        ∫ a, voteLoss f B m a x ∂iidSamples (mixtureLaw hB b v hv) m := by
  classical
  by_cases hbad : labelReal (f x)*(∑ i, v i*Real.tanh (dot (b i) (inputVector x))) ≤ 1/4
  · rw [if_pos hbad, integral_voteLoss]
    let E : Set (Fin m → Halfspace d) := {a | labelReal (f x)*vote B m a x ≤ 3/8}
    have hsub : Eᶜ ⊆ {a | (1 : ℝ)/16 < |vote B m a x-∑ i, v i*Real.tanh (dot (b i) (inputVector x))|} := by
      intro a ha
      have ha' : 3/8 < labelReal (f x)*vote B m a x := lt_of_not_ge ha
      by_contra he
      have herr : |labelReal (f x)*(vote B m a x-∑ i, v i*Real.tanh (dot (b i) (inputVector x)))| ≤ 1/16 := by
        simpa only [abs_mul, abs_labelReal, one_mul] using le_of_not_gt he
      have hhigh := (abs_le.mp herr).2
      nlinarith
    have ht := (measureReal_mono hsub).trans (vote_approximation_tail hB b v hv m hm x)
    rw [probReal_compl_eq_one_sub (Set.toFinite E).measurableSet] at ht
    dsimp [E] at ht
    linarith
  · rw [if_neg hbad]
    exact add_nonneg (by positivity) (integral_nonneg (fun a => (voteLoss_bounds f B m a x).1))

end NeuralGeneralization.BatchTwoShallow
