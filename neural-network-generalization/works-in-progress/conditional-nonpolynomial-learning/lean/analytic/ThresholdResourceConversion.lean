import CeilingResourceArithmetic

noncomputable section
namespace ConditionalNonpolynomial.Analytic

theorem one_add_real_log_le_three_log2 {R : ℕ} (hR : 2≤R) :
    1+Real.log (R:ℝ)≤3*(Nat.log2 R:ℝ) := by
  have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
  have hkR : (1:ℝ)≤Nat.log2 R := by exact_mod_cast hk
  linarith [real_log_le_twice_log2 hR]

/-- Converts actual real-valued resource estimates to the standard natural
circuit-size and binary-logarithmic-depth bounds. -/
theorem natural_circuit_resource_bounds {size depth R p K : ℕ} {C : ℝ}
    (hR : 2≤R) (hC : 0≤C) (hpK : p≤K) (hCK : 3*C≤(K:ℝ))
    (hsize : (size:ℝ)≤(R:ℝ)^p) (hdepth : (depth:ℝ)≤C*(1+Real.log (R:ℝ))) :
    size≤R^K ∧ depth≤K*Nat.log2 R := by
  constructor
  · have hs : size≤R^p := by exact_mod_cast hsize
    exact hs.trans (Nat.pow_le_pow_right (by omega) hpK)
  · have hl := mul_le_mul_of_nonneg_left (one_add_real_log_le_three_log2 hR) hC
    have hc := mul_le_mul_of_nonneg_right hCK (Nat.cast_nonneg (α:=ℝ) (Nat.log2 R))
    have hh : (depth:ℝ)≤(K:ℝ)*(Nat.log2 R:ℝ) := by nlinarith only [hdepth,hl,hc]
    exact_mod_cast hh

def naturalCircuitResourceExponent (p : ℕ) (C : ℝ) : ℕ := p+⌈3*C⌉₊+1

theorem naturalCircuitResourceExponent_one (p : ℕ) (C : ℝ) :
    1≤naturalCircuitResourceExponent p C := by unfold naturalCircuitResourceExponent; omega

theorem natural_circuit_resource_bounds_uniform (p : ℕ) {C : ℝ} (hC : 0≤C)
    {size depth R : ℕ} (hR : 2≤R)
    (hsize : (size:ℝ)≤(R:ℝ)^p) (hdepth : (depth:ℝ)≤C*(1+Real.log (R:ℝ))) :
    size≤R^(naturalCircuitResourceExponent p C) ∧
      depth≤naturalCircuitResourceExponent p C*Nat.log2 R := by
  apply natural_circuit_resource_bounds hR hC (by unfold naturalCircuitResourceExponent; omega) _ hsize hdepth
  have hh := Nat.le_ceil (3*C)
  have hp := Nat.cast_nonneg (α:=ℝ) p
  unfold naturalCircuitResourceExponent
  push_cast
  linarith

#print axioms natural_circuit_resource_bounds_uniform
end ConditionalNonpolynomial.Analytic
