import NetworkControlledPath
import Mathlib.Algebra.Order.Floor.Semiring

/-! Explicit grid choice and width bound. The width depends on log(1+G),
not G, so exponentially small covariance tolerance is affordable. -/
noncomputable section
set_option linter.unusedSectionVars false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def denseGrid (N : ℕ) (G : ℝ) : ℕ := Nat.ceil ((N:ℝ)^2*(1+G))

lemma denseGrid_pos {N : ℕ} (hN : 0<N) {G : ℝ} (hG : 0≤G) : 0<denseGrid N G := by
  apply Nat.one_le_ceil_iff.mpr
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  positivity

lemma denseGrid_lower (N : ℕ) (G : ℝ) :
    (N:ℝ)^2*(1+G)≤denseGrid N G := Nat.le_ceil _

lemma denseGrid_upper {N : ℕ} (hN : 0<N) {G : ℝ} (hG : 0≤G) :
    (denseGrid N G:ℝ)≤2*(N:ℝ)^2*(1+G) := by
  have hn : (1:ℝ)≤N := by exact_mod_cast hN
  have hx : 1≤(N:ℝ)^2*(1+G) := by nlinarith [sq_nonneg ((N:ℝ)-1)]
  have hh := Nat.ceil_lt_add_one (show 0≤(N:ℝ)^2*(1+G) by positivity)
  unfold denseGrid
  nlinarith

lemma log_nat_le_two_sqrt {N : ℕ} (hN : 0<N) : Real.log N≤2*Real.sqrt N := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hh := Real.log_le_sub_one_of_pos (Real.sqrt_pos.mpr hn)
  rw [Real.log_sqrt hn.le] at hh
  linarith

lemma log_denseGrid_bound {N : ℕ} (hN : 0<N) {G : ℝ} (hG : 0≤G) :
    Real.log (2*(denseGrid N G:ℝ)+1) ≤
      Real.log 5+2*Real.log N+Real.log (1+G) := by
  have hn : (1:ℝ)≤N := by exact_mod_cast hN
  have hn0 : (0:ℝ)<N := by exact_mod_cast hN
  have hu := denseGrid_upper hN hG
  have hx : 1≤(N:ℝ)^2*(1+G) := by nlinarith [sq_nonneg ((N:ℝ)-1)]
  have hle : 2*(denseGrid N G:ℝ)+1≤5*(N:ℝ)^2*(1+G) := by nlinarith
  have hh := Real.log_le_log (show 0<2*(denseGrid N G:ℝ)+1 by positivity) hle
  rw [Real.log_mul (by positivity) (by positivity),Real.log_mul (by norm_num) (by positivity),
    Real.log_pow] at hh
  simpa using hh

lemma denseGrid_rounding_bound {N : ℕ} (hN : 0<N) {G : ℝ} (hG : 0≤G)
    (k : ℝ) (hk : 0≤k) :
    (N:ℝ)*(2*k*G/(denseGrid N G:ℝ))≤2*k := by
  have hn : (1:ℝ)≤N := by exact_mod_cast hN
  have hM : (0:ℝ)<denseGrid N G := by exact_mod_cast denseGrid_pos hN hG
  have hlow := denseGrid_lower N G
  have hNG : (N:ℝ)*G≤denseGrid N G := by
    have hsq : (N:ℝ)≤(N:ℝ)^2 := by nlinarith
    have hmul := mul_le_mul_of_nonneg_right hsq hG
    nlinarith [sq_nonneg (N:ℝ)]
  rw [←mul_div_assoc]
  apply (div_le_iff₀ hM).mpr
  nlinarith

lemma denseOverhead_pos (d N M : ℕ) (G : ℝ) : 0<denseOverhead d N M G := by
  unfold denseOverhead
  positivity

lemma log_denseOverhead (d N M : ℕ) (G : ℝ) :
    Real.log (denseOverhead d N M G) =
      (N:ℝ)*(2*(Fintype.card (Cube d × Cube d):ℝ)*G/M)+
        (Fintype.card (Cube d × Cube d):ℝ)*Real.log (2*(M:ℝ)+1) := by
  unfold denseOverhead
  rw [Real.log_mul (Real.exp_pos _).ne' (by positivity),Real.log_exp]
  congr 1
  rw [Nat.cast_pow,Real.log_pow]
  push_cast
  rfl

/-- The constant part of the logarithmic overhead. -/
def denseLogConstant (d r : ℕ) (G s : ℝ) : ℝ :=
  (r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)*(2+Real.log 5+Real.log (1+G))+
    (Fintype.card (Cube d):ℝ)*Real.log ((Real.sqrt s)⁻¹)

def denseWidthBudget (d r : ℕ) (G s τ : ℝ) : ℝ :=
  1+(16*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)/τ)^2+
    4*denseLogConstant d r G s/τ

lemma denseLogConstant_nonneg (d r : ℕ) {G s : ℝ} (hG : 0≤G)
    (hs : 0<s) (hs1 : s≤1) : 0≤denseLogConstant d r G s := by
  have hlogG : 0≤Real.log (1+G) := Real.log_nonneg (by linarith)
  have hlogs : 0≤Real.log ((Real.sqrt s)⁻¹) := by
    apply Real.log_nonneg
    exact (one_le_inv₀ (Real.sqrt_pos.mpr hs)).mpr (Real.sqrt_le_one.mpr hs1)
  have hlog5 : 0≤Real.log 5 := Real.log_nonneg (by norm_num)
  unfold denseLogConstant
  positivity

/-- A polynomial width bound in H,k,1/τ and log(1+G) controls the complete
finite-test prefactor, including the projected readout. -/
theorem log_prefactor_le_half (d r N : ℕ) (hN : 0<N)
    {G s τ : ℝ} (hG : 0≤G) (hs : 0<s) (hs1 : s≤1) (hτ : 0<τ)
    (hwidth : denseWidthBudget d r G s τ≤N) :
    Real.log (denseOverhead d N (denseGrid N G) G^(r+1)*
      (Real.sqrt s)⁻¹^(Fintype.card (Cube d))) ≤ (N:ℝ)*τ/2 := by
  let k : ℝ := Fintype.card (Cube d × Cube d)
  let H : ℝ := r+1
  have hk : 0≤k := by dsimp [k]; positivity
  have hH : 0≤H := by dsimp [H]; positivity
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hC : 0≤denseLogConstant d r G s := denseLogConstant_nonneg d r hG hs hs1
  have hroot : 16*H*k/τ≤Real.sqrt N := by
    have hsq : (16*H*k/τ)^2≤N := by
      unfold denseWidthBudget at hwidth
      have hnonneg : 0≤4*denseLogConstant d r G s/τ := by positivity
      dsimp [H] at *
      push_cast at hwidth ⊢
      nlinarith
    exact (Real.le_sqrt (by positivity) hn.le).mpr hsq
  have hsmall : 4*H*k*Real.sqrt N≤(N:ℝ)*τ/4 := by
    have hh := (div_le_iff₀ hτ).mp hroot
    have hh2 := mul_le_mul_of_nonneg_right hh (Real.sqrt_nonneg (N:ℝ))
    nlinarith [Real.sq_sqrt hn.le]
  have hconst : denseLogConstant d r G s≤(N:ℝ)*τ/4 := by
    have hh : 4*denseLogConstant d r G s/τ≤N := by
      unfold denseWidthBudget at hwidth
      nlinarith [sq_nonneg (16*(r+1:ℕ)*(Fintype.card (Cube d × Cube d):ℝ)/τ)]
    have hh2 := (div_le_iff₀ hτ).mp hh
    linarith
  have hround := denseGrid_rounding_bound hN hG k hk
  have hlog := log_denseGrid_bound hN hG
  have hlogN := log_nat_le_two_sqrt hN
  have hp := denseOverhead_pos d N (denseGrid N G) G
  rw [Real.log_mul (pow_pos hp _).ne' (by positivity),Real.log_pow,Real.log_pow,
    log_denseOverhead]
  have hhlog := mul_le_mul_of_nonneg_left hlog hk
  have hh := mul_le_mul_of_nonneg_left (add_le_add hround hhlog) hH
  have hhN := mul_le_mul_of_nonneg_left hlogN (mul_nonneg (by positivity : 0≤2*H) hk)
  dsimp [k,H] at hh hhN hsmall
  unfold denseLogConstant at hconst
  push_cast at hh hhN hsmall hconst ⊢
  nlinarith

/-- Explicit width and grid parameters make the exceptional-event threshold
strictly smaller than exp(-NA) at action budget A+τ. -/
theorem prefactor_tail_lt (d r N : ℕ) (hN : 0<N)
    {G s τ : ℝ} (hG : 0≤G) (hs : 0<s) (hs1 : s≤1) (hτ : 0<τ)
    (hwidth : denseWidthBudget d r G s τ≤N) (A : ℝ) :
    (denseOverhead d N (denseGrid N G) G^(r+1)*
      (Real.sqrt s)⁻¹^(Fintype.card (Cube d))) / Real.exp ((N:ℝ)*(A+τ)) <
        Real.exp (-(N:ℝ)*A) := by
  have hp : 0<denseOverhead d N (denseGrid N G) G^(r+1)*
      (Real.sqrt s)⁻¹^(Fintype.card (Cube d)) := by
    exact mul_pos (pow_pos (denseOverhead_pos _ _ _ _) _) (pow_pos (by positivity) _)
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hh := log_prefactor_le_half d r N hN hG hs hs1 hτ hwidth
  have hlog : Real.log (denseOverhead d N (denseGrid N G) G^(r+1)*
      (Real.sqrt s)⁻¹^(Fintype.card (Cube d))) < (N:ℝ)*τ := by
    nlinarith
  have hex := Real.exp_lt_exp.mpr hlog
  rw [Real.exp_log hp] at hex
  calc
    _ < Real.exp ((N:ℝ)*τ)/Real.exp ((N:ℝ)*(A+τ)) :=
      div_lt_div_of_pos_right hex (Real.exp_pos _)
    _ = _ := by rw [←Real.exp_sub]; congr 1; ring

#print axioms log_prefactor_le_half
#print axioms prefactor_tail_lt
#print axioms denseGrid_rounding_bound
#print axioms log_denseGrid_bound
end ConditionalNonpolynomial.Analytic
