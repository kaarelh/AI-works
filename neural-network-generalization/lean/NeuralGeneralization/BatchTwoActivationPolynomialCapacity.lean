import NeuralGeneralization.BatchTwoActivationCapacity

/-!
# An explicit polynomial dominating the common energy-class logarithm

The expression below is a literal polynomial in the input dimension and
energy at fixed depth and Lipschitz constant. Ceilings occur only in the
intermediate grid and VC constructions, not in this upper bound.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

def capacityPolynomial (H : ℕ) (p P : ℝ) : ℝ :=
  16*P^2*p*((H:ℝ)*(2+(64*(H:ℝ)*p*P+3)^2)+2*p)+1

theorem capacityEntropy_nonneg (H q : ℕ) {p : ℝ} (hp : 0≤p) :
    0≤capacityEntropy H q p := by unfold capacityEntropy; positivity

theorem capacityResolution_le {H : ℕ} {p P : ℝ} (hp : 0≤p) (hP : 0≤P) :
    (capacityResolution H p P : ℝ) ≤ 32*(H:ℝ)*p*P+1 := by
  exact (Nat.ceil_lt_add_one (by positivity)).le

theorem capacityEntropy_le {H : ℕ} {p P : ℝ} (hp : 0≤p) (hP : 0≤P) :
    capacityEntropy H (capacityResolution H p P) p ≤
      (H:ℝ)*(2+(64*(H:ℝ)*p*P+3)^2)+2*p := by
  have hq := capacityResolution_le (H := H) hp hP
  have hq' : 2*(capacityResolution H p P : ℝ)+1 ≤ 64*(H:ℝ)*p*P+3 := by linarith
  have hs := pow_le_pow_left₀ (by positivity : 0≤2*(capacityResolution H p P : ℝ)+1) hq' 2
  unfold capacityEntropy
  exact add_le_add_left (mul_le_mul_of_nonneg_left (add_le_add_right hs 2) (Nat.cast_nonneg H)) _

theorem activationCapacity_le_polynomial (d r : ℕ) {ℓ K : ℝ} (hℓ : 0≤ℓ) (hK : 0≤K) :
    (activationCapacity d r ℓ K : ℝ) ≤
      capacityPolynomial (r+1) ((d:ℝ)+1) (outputNormalization r ℓ K) := by
  have hp : (0:ℝ)≤(d:ℝ)+1 := by positivity
  have hP : 0≤outputNormalization r ℓ K := by unfold outputNormalization; positivity
  have hceil : (activationCapacity d r ℓ K : ℝ) ≤
      16*(outputNormalization r ℓ K)^2*((d:ℝ)+1)*
        capacityEntropy (r+1) (capacityResolution (r+1) ((d:ℝ)+1)
          (outputNormalization r ℓ K)) ((d:ℝ)+1)+1 := by
    apply (Nat.ceil_lt_add_one _).le
    exact mul_nonneg (by positivity) (capacityEntropy_nonneg _ _ hp)
  apply hceil.trans
  unfold capacityPolynomial
  apply add_le_add_left
  exact mul_le_mul_of_nonneg_left (capacityEntropy_le hp hP) (by positivity)

/-- This bound is on the logarithm of the number of Boolean sign functions,
not on the number itself. -/
def activationLogCapacity (d r : ℕ) (ℓ K : ℝ) : ℝ :=
  capacityPolynomial (r+1) ((d:ℝ)+1) (outputNormalization r ℓ K)*((d:ℝ)+1)

theorem cube_log_card_le (d : ℕ) : Real.log ((2:ℝ)^d+1) ≤ (d:ℝ)+1 := by
  have hp : (0:ℝ)<2^d := by positivity
  have h1 : (1:ℝ)≤2^d := one_le_pow₀ (by norm_num)
  have hbase : (2:ℝ)^d+1 ≤ 2^(d+1) := by rw [pow_succ]; linarith
  have hlog := Real.log_le_log (by positivity : (0:ℝ)<2^d+1) hbase
  rw [Real.log_pow] at hlog
  have htwo : Real.log 2≤1 := by
    have := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    linarith
  have h := mul_le_mul_of_nonneg_left htwo (show (0:ℝ)≤(d+1:ℕ) by positivity)
  push_cast at hlog h
  linarith

theorem energyFunctions_card_le_exp {d r : ℕ} {φ : ℝ→ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) :
    ((energyFunctions d r φ K).card : ℝ) ≤ Real.exp (activationLogCapacity d r ℓ K) := by
  have hc := energyFunctions_card_le (r := r) hφ hℓ hK hd
  have hc' : ((energyFunctions d r φ K).card : ℝ) ≤
      ((2:ℝ)^d+1)^(activationCapacity d r ℓ K) := by exact_mod_cast hc
  have hp : (0:ℝ)<((2:ℝ)^d+1) := by positivity
  have heq : ((2:ℝ)^d+1)^(activationCapacity d r ℓ K) =
      Real.exp ((activationCapacity d r ℓ K : ℝ)*Real.log ((2:ℝ)^d+1)) := by
    rw [Real.exp_nat_mul, Real.exp_log hp]
  rw [heq] at hc'
  apply hc'.trans
  apply Real.exp_le_exp.mpr
  unfold activationLogCapacity
  have hcap := activationCapacity_le_polynomial d r hℓ.le (by linarith : 0≤K)
  calc
    _ ≤ (activationCapacity d r ℓ K : ℝ)*((d:ℝ)+1) :=
      mul_le_mul_of_nonneg_left (cube_log_card_le d) (Nat.cast_nonneg _)
    _ ≤ _ := mul_le_mul_of_nonneg_right hcap (by positivity)

end NeuralGeneralization.BatchTwoActivation
