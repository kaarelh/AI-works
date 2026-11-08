import NeuralGeneralization.OnlineLowerTanhParity
import NeuralGeneralization.TanhScalarJet
import Mathlib.Topology.Order.Compact
import Mathlib.Data.Nat.Choose.Central
import Mathlib.Analysis.Calculus.Deriv.Mul

/-! # The actual balanced odd-parity tanh scalar

The gain is chosen from a genuine finite-dimensional optimization on the
fixed interval `[1,2]`. Later scalar theorems identify this optimizer with
the unique global positive-gain optimum. No optimality or asymptotic
property is assumed in these definitions.
-/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Set

namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def spinSum {n : ℕ} (x : Cube n) : ℝ := ∑ i, labelReal (x i)

theorem incomingLinear_constant {n : ℕ} (a : ℝ) (x : Cube n) :
    incomingLinear (fun _ : Fin n => a) x = a * spinSum x := by
  simp only [incomingLinear, spinSum, Finset.mul_sum]

/-- Signed actual parity coefficient at odd degree `2r+1`. -/
def balancedParity (r : ℕ) (a : ℝ) : ℝ :=
  (-1 : ℝ)^r * parityCorrelation (fun _ : Fin (2*r+1) => a) 0

def oddParityKappa (r : ℕ) : ℝ := (Nat.centralBinom r : ℝ) / 4^r

theorem oddParityKappa_pos (r : ℕ) : 0 < oddParityKappa r := by
  unfold oddParityKappa
  exact div_pos (Nat.cast_pos.mpr (Nat.centralBinom_pos r)) (by positivity)

theorem balancedParity_sum (r : ℕ) (a : ℝ) :
    balancedParity r a = (-1 : ℝ)^r *
      ((Fintype.card (Cube (2*r+1)) : ℝ)⁻¹ *
        ∑ x : Cube (2*r+1), paritySign x * Real.tanh (a * spinSum x)) := by
  simp only [balancedParity, parityCorrelation, zero_add, incomingLinear_constant]

def balancedParityFirst (r : ℕ) (a : ℝ) : ℝ :=
  (-1 : ℝ)^r * ((Fintype.card (Cube (2*r+1)) : ℝ)⁻¹ *
    ∑ x : Cube (2*r+1), paritySign x * (tanhFirst (a * spinSum x) * spinSum x))

def balancedParitySecond (r : ℕ) (a : ℝ) : ℝ :=
  (-1 : ℝ)^r * ((Fintype.card (Cube (2*r+1)) : ℝ)⁻¹ *
    ∑ x : Cube (2*r+1), paritySign x *
      ((tanhSecond (a * spinSum x) * spinSum x) * spinSum x))

theorem hasDerivAt_balancedParity (r : ℕ) (a : ℝ) :
    HasDerivAt (balancedParity r) (balancedParityFirst r a) a := by
  have hs := HasDerivAt.sum (u := Finset.univ) (fun (x : Cube (2*r+1)) (_ : x ∈ Finset.univ) =>
    (((hasDerivAt_tanh_first (a * spinSum x)).comp a
      ((hasDerivAt_id a).mul_const (spinSum x))).const_mul (paritySign x)))
  have h := (hs.const_mul (Fintype.card (Cube (2*r+1)) : ℝ)⁻¹).const_mul ((-1 : ℝ)^r)
  convert h using 1 <;> try rfl
  · funext y
    simp only [balancedParity_sum, Finset.sum_apply, Function.comp_def, id_eq]
  · simp only [balancedParityFirst, one_mul]

theorem hasDerivAt_balancedParityFirst (r : ℕ) (a : ℝ) :
    HasDerivAt (balancedParityFirst r) (balancedParitySecond r a) a := by
  have hs := HasDerivAt.sum (u := Finset.univ) (fun (x : Cube (2*r+1)) (_ : x ∈ Finset.univ) =>
    ((((hasDerivAt_tanhFirst (a * spinSum x)).comp a
      ((hasDerivAt_id a).mul_const (spinSum x))).mul_const (spinSum x)).const_mul (paritySign x)))
  have h := (hs.const_mul (Fintype.card (Cube (2*r+1)) : ℝ)⁻¹).const_mul ((-1 : ℝ)^r)
  convert h using 1 <;> try rfl
  · funext y
    simp only [balancedParityFirst, Finset.sum_apply, Function.comp_def, id_eq]
  · simp only [balancedParitySecond, one_mul]

@[fun_prop] theorem continuous_balancedParity (r : ℕ) : Continuous (balancedParity r) :=
  continuous_iff_continuousAt.mpr fun a => (hasDerivAt_balancedParity r a).continuousAt

@[fun_prop] theorem continuous_balancedParityFirst (r : ℕ) : Continuous (balancedParityFirst r) :=
  continuous_iff_continuousAt.mpr fun a => (hasDerivAt_balancedParityFirst r a).continuousAt

def balancedRatio (r : ℕ) (a : ℝ) : ℝ := balancedParity r a / a

theorem continuousOn_balancedRatio (r : ℕ) :
    ContinuousOn (balancedRatio r) (Icc (1 : ℝ) 2) := by
  exact (continuous_balancedParity r).continuousOn.div continuousOn_id
    (fun a ha => ne_of_gt (lt_of_lt_of_le (by norm_num) ha.1))

theorem balancedGain_exists (r : ℕ) :
    ∃ a ∈ Icc (1 : ℝ) 2, IsMaxOn (balancedRatio r) (Icc (1 : ℝ) 2) a :=
  isCompact_Icc.exists_isMaxOn (by norm_num : (Icc (1 : ℝ) 2).Nonempty)
    (continuousOn_balancedRatio r)

def balancedGain (r : ℕ) : ℝ := Classical.choose (balancedGain_exists r)

theorem balancedGain_mem (r : ℕ) : balancedGain r ∈ Icc (1 : ℝ) 2 :=
  (Classical.choose_spec (balancedGain_exists r)).1

theorem balancedGain_max (r : ℕ) :
    IsMaxOn (balancedRatio r) (Icc (1 : ℝ) 2) (balancedGain r) :=
  (Classical.choose_spec (balancedGain_exists r)).2

theorem balancedGain_pos (r : ℕ) : 0 < balancedGain r :=
  lt_of_lt_of_le (by norm_num) (balancedGain_mem r).1

def balancedCost (r : ℕ) : ℝ :=
  balancedGain r * Real.sqrt (2*r+1 : ℕ) / balancedParity r (balancedGain r)

theorem balancedCost_normalization (r : ℕ)
    (hq : balancedParity r (balancedGain r) ≠ 0) :
    balancedCost r * balancedParity r (balancedGain r) =
      balancedGain r * Real.sqrt (2*r+1 : ℕ) := by
  exact div_mul_cancel₀ _ hq

end NeuralGeneralization.OnlineLowerTanh
