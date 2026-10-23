import NeuralGeneralization.BatchTwoActivationDepthIteration

/-!
# Explicit polynomial extraction from the activation-cover moment bound

The grid used by the formal proof has a slightly looser entropy than the
manuscript's optimized grid. The resulting capacity is still a polynomial
in energy and input dimension at every fixed depth.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

/-- A coarse polynomial bound on the logarithm of the actual scalar-code
cardinality. The cardinality itself is not polynomial. -/
theorem activationCode_card_le_exp (q : ℕ) :
    (Fintype.card (ActivationCode q) : ℝ) ≤ Real.exp ((2*(q:ℝ)+1)^2) := by
  rw [activationCode_card]
  push_cast
  have hb : 0<(2*(q:ℝ)+1) := by positivity
  have hl : Real.log ((2*(q:ℝ)+1)^((2*q+1):ℕ)) ≤ (2*(q:ℝ)+1)^2 := by
    rw [Real.log_pow]
    push_cast
    have h := mul_le_mul_of_nonneg_left (Real.log_le_self hb.le) hb.le
    nlinarith
  rw [← Real.exp_log (pow_pos hb _)]
  exact Real.exp_le_exp.mpr hl

theorem activationPeelingFactor_le_exp (n q : ℕ) (R a : ℝ) :
    activationPeelingFactor n q R a ≤
      Real.exp (2+(2*(q:ℝ)+1)^2+a*((n:ℝ)*(4*R/(q:ℝ)))) := by
  have h2 : (2:ℝ)≤Real.exp 2 := by linarith [Real.add_one_le_exp 2]
  unfold activationPeelingFactor
  calc
    _ ≤ (Real.exp 2*Real.exp ((2*(q:ℝ)+1)^2))*
        Real.exp (a*((n:ℝ)*(4*R/(q:ℝ)))) :=
      mul_le_mul_of_nonneg_right
        (mul_le_mul h2 (activationCode_card_le_exp q) (Nat.cast_nonneg _) (Real.exp_pos _).le)
        (Real.exp_pos _).le
    _ = _ := by rw [← Real.exp_add, ← Real.exp_add]

def capacityEntropy (H q : ℕ) (p : ℝ) : ℝ :=
  (H:ℝ)*(2+(2*(q:ℝ)+1)^2)+2*p

theorem peeling_moment_le_exp (n q H : ℕ) {p : ℝ} (hp : 0≤p) (R a : ℝ) :
    (activationPeelingFactor n q R a)^H *
      (2*p*Real.exp (a^2*p*n/2)) ≤
        Real.exp (capacityEntropy H q p + (H:ℝ)*a*((n:ℝ)*(4*R/q)) + a^2*p*n/2) := by
  have hfac := pow_le_pow_left₀ (activationPeelingFactor_nonneg n q R a)
    (activationPeelingFactor_le_exp n q R a) H
  have hp' : 2*p≤Real.exp (2*p) := by linarith [Real.add_one_le_exp (2*p)]
  have hupper := mul_le_mul hfac
    (mul_le_mul_of_nonneg_right hp' (Real.exp_pos (a^2*p*n/2)).le)
    (mul_nonneg (mul_nonneg (by norm_num) hp) (Real.exp_pos _).le)
    (pow_nonneg (Real.exp_pos _).le _)
  apply hupper.trans_eq
  rw [← Real.exp_nat_mul, ← Real.exp_add, ← Real.exp_add]
  congr 1
  unfold capacityEntropy
  ring

/-- The covering resolution is proportional to the output scale and depth. -/
def capacityResolution (H : ℕ) (p P : ℝ) : ℕ := ⌈32*(H:ℝ)*p*P⌉₊

theorem capacityResolution_pos {H : ℕ} (hH : 0<H) {p P : ℝ}
    (hp : 0<p) (hP : 0<P) : 0<capacityResolution H p P := by
  apply Nat.ceil_pos.mpr
  have hHr : (0:ℝ)<H := by exact_mod_cast hH
  positivity

theorem resolution_error_le {H : ℕ} (hH : 0<H) {p P : ℝ}
    (hp : 0<p) (hP : 0<P) :
    (H:ℝ)*(4*p/(capacityResolution H p P : ℝ)) ≤ 1/(8*P) := by
  have hHr : (0:ℝ)<H := by exact_mod_cast hH
  have hq : (0:ℝ)<capacityResolution H p P := by
    exact_mod_cast capacityResolution_pos hH hp hP
  have hc : 32*(H:ℝ)*p*P ≤ (capacityResolution H p P : ℝ) := Nat.le_ceil _
  rw [← mul_div_assoc]
  apply (div_le_div_iff₀ hq (mul_pos (by norm_num) hP)).mpr
  nlinarith

/-- The actual two-sided moment inequality forces an explicit finite
shattering dimension. No Rademacher-capacity implication is assumed. -/
theorem capacity_from_moment {n H : ℕ} (hH : 0<H) {p P : ℝ}
    (hp : 0<p) (hP : 0<P)
    (hmgf : Real.exp ((1/(4*P*p))*((n:ℝ)/(2*P))) ≤
      (activationPeelingFactor n (capacityResolution H p P) p (1/(4*P*p)))^H *
        (2*p*Real.exp ((1/(4*P*p))^2*p*n/2))) :
    (n:ℝ) ≤ 16*P^2*p*capacityEntropy H (capacityResolution H p P) p := by
  have he := Real.exp_le_exp.mp (hmgf.trans
    (peeling_moment_le_exp n (capacityResolution H p P) H hp.le p (1/(4*P*p))))
  have herr := resolution_error_le hH hp hP
  have hcoef : 0≤(1/(4*P*p))*(n:ℝ) := by positivity
  have he' := mul_le_mul_of_nonneg_left herr hcoef
  have hl : (1/(4*P*p))*((n:ℝ)/(2*P)) = (n:ℝ)/(8*P^2*p) := by field_simp; ring
  have hquad : (1/(4*P*p))^2*p*(n:ℝ)/2 = (n:ℝ)/(32*P^2*p) := by field_simp; ring
  have herror : ((1/(4*P*p))*(n:ℝ))*(1/(8*P)) = (n:ℝ)/(32*P^2*p) := by field_simp; ring
  rw [hl, hquad] at he
  rw [herror] at he'
  have hmiddle : (H:ℝ)*(1/(4*P*p))*((n:ℝ)*(4*p/(capacityResolution H p P : ℝ))) =
      ((1/(4*P*p))*(n:ℝ))*((H:ℝ)*(4*p/(capacityResolution H p P : ℝ))) := by ring
  rw [hmiddle] at he
  have hbound : (n:ℝ)/(16*P^2*p) ≤ capacityEntropy H (capacityResolution H p P) p := by
    have heq : (n:ℝ)/(8*P^2*p) = 2*((n:ℝ)/(16*P^2*p)) := by ring
    have heq' : (n:ℝ)/(32*P^2*p) = ((n:ℝ)/(16*P^2*p))/2 := by ring
    rw [heq, heq'] at he
    rw [heq'] at he'
    linarith
  have hden : 0<16*P^2*p := by positivity
  have h := (div_le_iff₀ hden).mp hbound
  nlinarith

end NeuralGeneralization.BatchTwoActivation
