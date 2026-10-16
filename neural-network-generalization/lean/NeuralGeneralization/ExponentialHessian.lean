import NeuralGeneralization.TanhHessian
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

/-! True first/second derivatives for exponential tilts and weighted observables. -/

noncomputable section
namespace NeuralGeneralization.TanhDifferential
open NeuralGeneralization.FiniteDifferential
open scoped BigOperators
variable {I : Type*} [Fintype I]

/-- The gradient and Hessian of the actual exponential of a potential. -/
def expGradient (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (z : I → ℝ) (i : I) : ℝ :=
  Real.exp (V z) * V₁ z i

def expHessian (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (V₂ : (I → ℝ) → I → I → ℝ) (z : I → ℝ) (i j : I) : ℝ :=
  Real.exp (V z) * (V₂ z i j + V₁ z i * V₁ z j)

/-- The true derivatives of a scalar observable multiplied by the tilt. -/
def weightedGradient (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (z : I → ℝ) (i : I) : ℝ :=
  Real.exp (V z) * (F₁ z i + F z * V₁ z i)

def weightedHessian (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ)
    (F₂ : (I → ℝ) → I → I → ℝ) (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (V₂ : (I → ℝ) → I → I → ℝ) (z : I → ℝ) (i j : I) : ℝ :=
  Real.exp (V z) * (F₂ z i j + F₁ z i * V₁ z j + F₁ z j * V₁ z i +
    F z * V₂ z i j + F z * V₁ z i * V₁ z j)

theorem hasFDerivAt_expValue (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (hV : ∀ z, HasFDerivAt V (gradientLinear (V₁ z)) z) (z : I → ℝ) :
    HasFDerivAt (fun y => Real.exp (V y)) (gradientLinear (expGradient V V₁ z)) z := by
  have h := (hV z).exp
  unfold expGradient
  rw [gradientLinear_const_mul_fun]
  exact h

theorem hasFDerivAt_expGradient (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (V₂ : (I → ℝ) → I → I → ℝ)
    (hV : ∀ z, HasFDerivAt V (gradientLinear (V₁ z)) z)
    (hV₁ : ∀ z i, HasFDerivAt (fun y => V₁ y i) (gradientLinear (V₂ z i)) z)
    (z : I → ℝ) (i : I) :
    HasFDerivAt (fun y => expGradient V V₁ y i) (gradientLinear (expHessian V V₁ V₂ z i)) z := by
  apply ((hasFDerivAt_expValue V V₁ hV z).mul (hV₁ z i)).congr_fderiv
  ext v
  simp only [add_apply, smul_apply, smul_eq_mul, gradientLinear_apply, expHessian, expGradient]
  simp_rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem hasFDerivAt_weightedValue (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (hF : ∀ z, HasFDerivAt F (gradientLinear (F₁ z)) z)
    (hV : ∀ z, HasFDerivAt V (gradientLinear (V₁ z)) z) (z : I → ℝ) :
    HasFDerivAt (fun y => F y * Real.exp (V y))
      (gradientLinear (weightedGradient F F₁ V V₁ z)) z := by
  apply ((hF z).mul (hasFDerivAt_expValue V V₁ hV z)).congr_fderiv
  ext v
  simp only [add_apply, smul_apply, smul_eq_mul, gradientLinear_apply, weightedGradient, expGradient]
  simp_rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem hasFDerivAt_weightedGradient
    (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ) (F₂ : (I → ℝ) → I → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (V₂ : (I → ℝ) → I → I → ℝ)
    (hF : ∀ z, HasFDerivAt F (gradientLinear (F₁ z)) z)
    (hF₁ : ∀ z i, HasFDerivAt (fun y => F₁ y i) (gradientLinear (F₂ z i)) z)
    (hV : ∀ z, HasFDerivAt V (gradientLinear (V₁ z)) z)
    (hV₁ : ∀ z i, HasFDerivAt (fun y => V₁ y i) (gradientLinear (V₂ z i)) z)
    (z : I → ℝ) (i : I) :
    HasFDerivAt (fun y => weightedGradient F F₁ V V₁ y i)
      (gradientLinear (weightedHessian F F₁ F₂ V V₁ V₂ z i)) z := by
  have hinner := (hF₁ z i).add ((hF z).mul (hV₁ z i))
  apply ((hasFDerivAt_expValue V V₁ hV z).mul hinner).congr_fderiv
  ext v
  simp only [add_apply, smul_apply, smul_eq_mul, gradientLinear_apply,
    weightedHessian, expGradient, Pi.add_apply, Pi.mul_apply]
  simp_rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- A global entrywise bound retaining the exact positive exponential weight. -/
theorem expHessian_l1_le (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (V₂ : (I → ℝ) → I → I → ℝ) (z : I → ℝ) :
    (∑ i, ∑ j, |expHessian V V₁ V₂ z i j|) ≤
      Real.exp (V z) * ((∑ i, ∑ j, |V₂ z i j|) + (∑ i, |V₁ z i|) ^ 2) := by
  calc
    _ ≤ ∑ i, ∑ j, Real.exp (V z) * (|V₂ z i j| + |V₁ z i| * |V₁ z j|) := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      unfold expHessian
      rw [abs_mul, Real.abs_exp]
      apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
      simpa only [abs_mul] using abs_add_le (V₂ z i j) (V₁ z i * V₁ z j)
    _ = _ := by
      simp_rw [← Finset.mul_sum, Finset.sum_add_distrib]
      simp only [← Finset.mul_sum, ← Finset.sum_mul]
      ring

theorem weightedHessian_l1_le
    (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ) (F₂ : (I → ℝ) → I → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (V₂ : (I → ℝ) → I → I → ℝ)
    (z : I → ℝ) :
    (∑ i, ∑ j, |weightedHessian F F₁ F₂ V V₁ V₂ z i j|) ≤ Real.exp (V z) *
      ((∑ i, ∑ j, |F₂ z i j|) + 2 * (∑ i, |F₁ z i|) * (∑ i, |V₁ z i|) +
        |F z| * ((∑ i, ∑ j, |V₂ z i j|) + (∑ i, |V₁ z i|) ^ 2)) := by
  have hpoint (i j : I) : |weightedHessian F F₁ F₂ V V₁ V₂ z i j| ≤
      Real.exp (V z) * (|F₂ z i j| + |F₁ z i| * |V₁ z j| + |F₁ z j| * |V₁ z i| +
        |F z| * |V₂ z i j| + |F z| * |V₁ z i| * |V₁ z j|) := by
    unfold weightedHessian
    rw [abs_mul, Real.abs_exp]
    apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
    have h1 := abs_add_le (F₂ z i j) (F₁ z i * V₁ z j)
    have h2 := abs_add_le (F₂ z i j + F₁ z i * V₁ z j) (F₁ z j * V₁ z i)
    have h3 := abs_add_le (F₂ z i j + F₁ z i * V₁ z j + F₁ z j * V₁ z i) (F z * V₂ z i j)
    have h4 := abs_add_le (F₂ z i j + F₁ z i * V₁ z j + F₁ z j * V₁ z i + F z * V₂ z i j)
      (F z * V₁ z i * V₁ z j)
    simp only [abs_mul] at h1 h2 h3 h4
    linarith
  calc
    _ ≤ ∑ i, ∑ j, Real.exp (V z) *
        (|F₂ z i j| + |F₁ z i| * |V₁ z j| + |F₁ z j| * |V₁ z i| +
          |F z| * |V₂ z i j| + |F z| * |V₁ z i| * |V₁ z j|) :=
      Finset.sum_le_sum (fun i hi => Finset.sum_le_sum (fun j hj => hpoint i j))
    _ = _ := by
      simp_rw [← Finset.mul_sum, Finset.sum_add_distrib, ← Finset.sum_mul]
      simp only [← Finset.mul_sum, ← Finset.sum_mul]
      ring

@[fun_prop] theorem continuous_expGradient
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (hV : Continuous V) (hV₁ : ∀ i, Continuous (fun z => V₁ z i)) (i : I) :
    Continuous (fun z => expGradient V V₁ z i) := (Real.continuous_exp.comp hV).mul (hV₁ i)

@[fun_prop] theorem continuous_expHessian
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (V₂ : (I → ℝ) → I → I → ℝ)
    (hV : Continuous V) (hV₁ : ∀ i, Continuous (fun z => V₁ z i))
    (hV₂ : ∀ i j, Continuous (fun z => V₂ z i j)) (i j : I) :
    Continuous (fun z => expHessian V V₁ V₂ z i j) :=
  (Real.continuous_exp.comp hV).mul ((hV₂ i j).add ((hV₁ i).mul (hV₁ j)))

@[fun_prop] theorem continuous_weightedGradient
    (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ)
    (hF : Continuous F) (hF₁ : ∀ i, Continuous (fun z => F₁ z i))
    (hV : Continuous V) (hV₁ : ∀ i, Continuous (fun z => V₁ z i)) (i : I) :
    Continuous (fun z => weightedGradient F F₁ V V₁ z i) :=
  (Real.continuous_exp.comp hV).mul ((hF₁ i).add (hF.mul (hV₁ i)))

@[fun_prop] theorem continuous_weightedHessian
    (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ) (F₂ : (I → ℝ) → I → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (V₂ : (I → ℝ) → I → I → ℝ)
    (hF : Continuous F) (hF₁ : ∀ i, Continuous (fun z => F₁ z i))
    (hF₂ : ∀ i j, Continuous (fun z => F₂ z i j))
    (hV : Continuous V) (hV₁ : ∀ i, Continuous (fun z => V₁ z i))
    (hV₂ : ∀ i j, Continuous (fun z => V₂ z i j)) (i j : I) :
    Continuous (fun z => weightedHessian F F₁ F₂ V V₁ V₂ z i j) :=
  (Real.continuous_exp.comp hV).mul (((((hF₂ i j).add ((hF₁ i).mul (hV₁ j))).add
    ((hF₁ j).mul (hV₁ i))).add (hF.mul (hV₂ i j))).add
      ((hF.mul (hV₁ i)).mul (hV₁ j)))

theorem expGradient_l1_eq (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (z : I → ℝ) :
    (∑ i, |expGradient V V₁ z i|) = Real.exp (V z) * ∑ i, |V₁ z i| := by
  simp [expGradient, abs_mul, Real.abs_exp, Finset.mul_sum]

theorem weightedGradient_l1_le
    (F : (I → ℝ) → ℝ) (F₁ : (I → ℝ) → I → ℝ)
    (V : (I → ℝ) → ℝ) (V₁ : (I → ℝ) → I → ℝ) (z : I → ℝ) :
    (∑ i, |weightedGradient F F₁ V V₁ z i|) ≤ Real.exp (V z) *
      ((∑ i, |F₁ z i|) + |F z| * ∑ i, |V₁ z i|) := by
  calc
    _ ≤ ∑ i, Real.exp (V z) * (|F₁ z i| + |F z| * |V₁ z i|) := by
      apply Finset.sum_le_sum
      intro i hi
      unfold weightedGradient
      rw [abs_mul, Real.abs_exp]
      apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
      simpa only [abs_mul] using abs_add_le (F₁ z i) (F z * V₁ z i)
    _ = _ := by simp [Finset.mul_sum, Finset.sum_add_distrib, mul_add]

end NeuralGeneralization.TanhDifferential
