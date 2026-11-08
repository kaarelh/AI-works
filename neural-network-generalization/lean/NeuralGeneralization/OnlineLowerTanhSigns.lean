import NeuralGeneralization.OnlineLowerTanhElementary

/-! Coordinate reflections remove incoming signs without changing the
absolute value of an actual finite-cube tanh parity coefficient. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def incomingSign (a : ℝ) : ℝ := if 0 ≤ a then 1 else -1

def reflectIncoming {n : ℕ} (u : Fin n → ℝ) : Cube n ≃ Cube n where
  toFun x i := if 0 ≤ u i then x i else !(x i)
  invFun x i := if 0 ≤ u i then x i else !(x i)
  left_inv x := by funext i; by_cases h : 0 ≤ u i <;> simp [h]
  right_inv x := by funext i; by_cases h : 0 ≤ u i <;> simp [h]

@[simp] theorem abs_incomingSign (a : ℝ) : |incomingSign a| = 1 := by
  unfold incomingSign
  split_ifs <;> norm_num

theorem reflectIncoming_sign {n : ℕ} (u : Fin n → ℝ) (x : Cube n) (i : Fin n) :
    labelReal (reflectIncoming u x i) = incomingSign (u i)*labelReal (x i) := by
  by_cases h : 0 ≤ u i <;> simp [reflectIncoming, incomingSign, h]

theorem incomingLinear_reflect {n : ℕ} (u : Fin n → ℝ) (x : Cube n) :
    incomingLinear u (reflectIncoming u x) = incomingLinear (fun i => |u i|) x := by
  unfold incomingLinear
  apply Finset.sum_congr rfl
  intro i _
  rw [reflectIncoming_sign]
  by_cases h : 0 ≤ u i
  · simp [incomingSign, h, abs_of_nonneg h]
  · simp [incomingSign, h, abs_of_neg (lt_of_not_ge h)]

theorem paritySign_reflect {n : ℕ} (u : Fin n → ℝ) (x : Cube n) :
    paritySign (reflectIncoming u x) = (∏ i, incomingSign (u i))*paritySign x := by
  simp only [paritySign, reflectIncoming_sign, Finset.prod_mul_distrib]

theorem parityCorrelation_reflect {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    parityCorrelation u b = (∏ i, incomingSign (u i))*
      parityCorrelation (fun i => |u i|) b := by
  rw [parityCorrelation_eq_cubeMean, parityCorrelation_eq_cubeMean]
  rw [← cubeMean_equiv (reflectIncoming u)]
  simp_rw [paritySign_reflect, incomingLinear_reflect, mul_assoc]
  rw [cubeMean_const_mul]

@[simp] theorem parityCorrelation_abs_weights {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    |parityCorrelation u b| = |parityCorrelation (fun i => |u i|) b| := by
  rw [parityCorrelation_reflect u b, abs_mul, Finset.abs_prod]
  simp

@[simp] theorem incomingEnergy_abs {n : ℕ} (u : Fin n → ℝ) :
    incomingEnergy (fun i => |u i|) = incomingEnergy u := by
  simp [incomingEnergy, sq_abs]

end NeuralGeneralization.OnlineLowerTanh
