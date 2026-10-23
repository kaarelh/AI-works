import NeuralGeneralization.BatchTwoShallowHalfspaceLaw
import NeuralGeneralization.SparseAtomLaw

/-! Every shallow tanh network with bounded readout variation is the exact
mean of a probability law on one fixed finite set of affine halfspaces. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel SparseAtoms BoundedDual

def signedRow {d N : ℕ} (b : Fin N → Fin (d+1) → ℝ) : Atom (Fin N) → Fin (d+1) → ℝ
  | none => 0
  | some (i, s) => if s then b i else -b i

theorem signedRow_mean {d N : ℕ} (b : Fin N → Fin (d+1) → ℝ)
    (v : Fin N → ℝ) {B : ℝ} (hB : 0 < B) (x : Cube d) :
    (∑ a : Atom (Fin N), weight B v a * Real.tanh (dot (signedRow b a) (inputVector x))) =
      (∑ i, v i * Real.tanh (dot (b i) (inputVector x))) / B := by
  classical
  have hneg (i : Fin N) : dot (-b i) (inputVector x) = -dot (b i) (inputVector x) := by
    simp [dot, Finset.sum_neg_distrib]
  simp only [Fintype.sum_option, Fintype.sum_prod_type, Fintype.sum_bool,
    signedRow, Bool.false_eq_true, ite_false, ite_true, weight]
  have hzero : dot (0 : Fin (d+1) → ℝ) (inputVector x) = 0 := by simp [dot]
  rw [hzero, Real.tanh_zero, mul_zero, zero_add, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  rw [hneg, Real.tanh_neg]
  have hh := positive_negative_sub (v i)
  field_simp
  linear_combination Real.tanh (dot (b i) (inputVector x)) * hh

def mixtureWeight {d N : ℕ} (B : ℝ) (b : Fin N → Fin (d+1) → ℝ)
    (v : Fin N → ℝ) (h : Halfspace d) : ℝ :=
  ∑ a : Atom (Fin N), weight B v a * (ridgeLaw (signedRow b a)).real {h}

theorem mixtureWeight_nonneg {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B)
    (h : Halfspace d) : 0 ≤ mixtureWeight B b v h :=
  Finset.sum_nonneg (fun a _ => mul_nonneg (weight_nonneg hB v hv a) measureReal_nonneg)

theorem mixtureWeight_sum {d N : ℕ} (B : ℝ)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) :
    (∑ h : Halfspace d, mixtureWeight B b v h) = 1 := by
  unfold mixtureWeight
  rw [Finset.sum_comm]
  simp_rw [← Finset.mul_sum, ridgeLaw_sum, mul_one]
  exact sum_weight B v

theorem mixtureWeight_mean {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (x : Cube d) :
    (∑ h : Halfspace d, mixtureWeight B b v h * halfspaceValue h x) =
      (∑ i, v i * Real.tanh (dot (b i) (inputVector x))) / B := by
  unfold mixtureWeight
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  simp_rw [mul_assoc, ← Finset.mul_sum, ridgeLaw_mean_finite]
  exact signedRow_mean b v hB x

def mixturePMF {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B) :
    PMF (Halfspace d) :=
  PMF.ofFintype (fun h => ENNReal.ofReal (mixtureWeight B b v h)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun h _ => mixtureWeight_nonneg hB b v hv h),
      mixtureWeight_sum, ENNReal.ofReal_one])

def mixtureLaw {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B) :
    Measure (Halfspace d) := (mixturePMF hB b v hv).toMeasure

instance {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B) :
    IsProbabilityMeasure (mixtureLaw hB b v hv) := by
  unfold mixtureLaw
  infer_instance

theorem mixtureLaw_mean {d N : ℕ} {B : ℝ} (hB : 0 < B)
    (b : Fin N → Fin (d+1) → ℝ) (v : Fin N → ℝ) (hv : entryL1 v ≤ B) (x : Cube d) :
    (∫ h, halfspaceValue h x ∂mixtureLaw hB b v hv) =
      (∑ i, v i * Real.tanh (dot (b i) (inputVector x))) / B := by
  unfold mixtureLaw
  rw [PMF.integral_eq_sum]
  simp only [mixturePMF, PMF.ofFintype_apply,
    ENNReal.toReal_ofReal (mixtureWeight_nonneg hB b v hv _), smul_eq_mul]
  exact mixtureWeight_mean hB b v x

end NeuralGeneralization.BatchTwoShallow
