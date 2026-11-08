import NeuralGeneralization.OnlineLowerTanhResidualSequence
import NeuralGeneralization.OnlineLowerIntegralTails

/-! # Uniform finite approximations of the signed residual integral -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma residualRawKernel_dom {n : ℕ} (u : Fin n → ℝ) (B θ : ℝ) {t : ℝ} (ht : 0 < t) :
    |residualRawKernel u B θ (residualDerivativeKernel 0) t| ≤
      paritySineProduct u t/Real.sinh ((Real.pi/2)*t) := by
  have hs : 0 < Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  simp only [residualRawKernel,residualDerivativeKernel,pow_zero,abs_mul,abs_div,
    abs_one,abs_of_pos hs,Finset.abs_prod]
  have hp : (∏ i, |Real.sin (u i*t)|) = paritySineProduct u t := by
    unfold paritySineProduct
    apply Finset.prod_congr rfl
    intro i _
    rw [mul_comm]
  rw [hp]
  have hh := mul_le_of_le_one_left (paritySineProduct_nonneg u t) (Real.abs_sin_le_one (B*t+θ))
  have hm := mul_le_mul_of_nonneg_right hh (show 0 ≤ 1/Real.sinh (Real.pi*t/2) by positivity)
  convert hm using 1 <;> first | ring | rfl

def residualActualTailBound (Q hi : ℝ) (L : ℕ) : ℝ :=
  Q * ((2/(Real.pi/2))*(Real.pi/((Real.pi/2)/8)))*
    Real.exp (-((Real.pi/2)/8)*((L:ℝ)*Real.pi/hi))

def residualModelTailBound (lo hi : ℝ) (L : ℕ) : ℝ :=
  (Real.sqrt (2*Real.pi)/Real.pi)*
    (((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^L/(1-periodicRatio hi))

def residualZeroBound (Q M ρ : ℝ) (n : ℕ) : ℝ :=
  (Q*ρ*(M/(Real.pi/2)))*(Real.sqrt (n:ℝ)*(M*ρ)^(n-1))

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

lemma residual_actual_tail (k L : ℕ) (hL : 1 ≤ (L:ℝ)*Real.pi/S.hi) :
    Real.sqrt (residualVariance (S.alphabet k)) *
      (∫ t : ℝ in Ioi ((L:ℝ)*(Real.pi/S.A k)),
        paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)) ≤
      residualActualTailBound S.Q S.hi L := by
  let T : ℝ := (L:ℝ)*(Real.pi/S.A k)
  have hT : (L:ℝ)*Real.pi/S.hi ≤ T := by
    dsimp [T]
    simpa only [mul_div_assoc] using div_le_div_of_nonneg_left
      (mul_nonneg (Nat.cast_nonneg L) Real.pi_pos.le) (S.gain_pos k) (S.A_hi k)
  have hb := (parity_kernel_moment_tail (S.N_pos k) (S.incoming k) 0
    (by positivity : 0 < Real.pi/2) (hL.trans hT)).2
  simp only [pow_zero,Nat.factorial_zero,Nat.cast_one,div_one,one_mul] at hb
  have hi : 0 ≤ ∫ t : ℝ in Ioi T,
      paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t) := by
    apply setIntegral_nonneg measurableSet_Ioi
    intro t ht
    exact div_nonneg (paritySineProduct_nonneg _ _) (Real.sinh_pos_iff.mpr (by
      have ht0 : 0 < t := lt_of_lt_of_le (by norm_num : (0:ℝ)<1) ((hL.trans hT).trans ht.le)
      positivity)).le
  have hs := mul_le_mul_of_nonneg_right (S.variance_sqrt_bound k) hi
  have hm := mul_le_mul_of_nonneg_left hb S.Q_pos.le
  have hexp : Real.exp (-((Real.pi/2)/8)*T) ≤
      Real.exp (-((Real.pi/2)/8)*((L:ℝ)*Real.pi/S.hi)) := by
    apply Real.exp_le_exp.mpr
    nlinarith [Real.pi_pos]
  have he := mul_le_mul_of_nonneg_left hexp
    (show 0 ≤ S.Q*((2/(Real.pi/2))*(Real.pi/((Real.pi/2)/8))) by positivity [S.Q_pos])
  dsimp [residualActualTailBound,T] at *
  nlinarith

lemma residual_actual_zero (k : ℕ) {M ρ : ℝ} (hM : 0 ≤ M) (hρ : 0 ≤ ρ)
    (hu : ∀ i, |S.incoming k i| ≤ M) :
    Real.sqrt (residualVariance (S.alphabet k)) *
      (∫ t : ℝ in Ioc 0 ρ, paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)) ≤
      residualZeroBound S.Q M ρ (S.N k) := by
  have hb := (parity_kernel_near_zero_integral (S.N_pos k) (S.incoming k)
    hM (by positivity : 0 < Real.pi/2) hρ hu).2
  have hi : 0 ≤ ∫ t : ℝ in Ioc 0 ρ,
      paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t) := by
    apply setIntegral_nonneg measurableSet_Ioc
    intro t ht
    exact div_nonneg (paritySineProduct_nonneg _ _)
      (Real.sinh_pos_iff.mpr (mul_pos (by positivity) ht.1)).le
  have hs := mul_le_mul_of_nonneg_right (S.variance_sqrt_bound k) hi
  have hm := mul_le_mul_of_nonneg_left hb (mul_nonneg S.Q_pos.le (Real.sqrt_nonneg (S.N k:ℝ)))
  dsimp [residualZeroBound]
  nlinarith

/-- A finite, uniform-in-bias approximation with all three discarded tails
controlled explicitly. -/
theorem approximation_bound (k L : ℕ) {ρ M : ℝ} (hρ : 0 < ρ) (hM : 0 ≤ M)
    (hu : ∀ i, |S.incoming k i| ≤ M)
    (hH : ρ ≤ (L:ℝ)*(Real.pi/S.A k))
    (hL : 1 ≤ (L:ℝ)*Real.pi/S.hi) (B : ℝ) :
    Real.sqrt (residualVariance (S.alphabet k))*
      |parityCorrelation (S.incoming k) B-residualLeading (S.alphabet k) (S.d k) (S.A k) B| ≤
      residualZeroBound S.Q M ρ (S.N k) +
      (1/S.lo)*(∑ l ∈ Finset.range L, residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l 0) +
      residualActualTailBound S.Q S.hi L + residualModelTailBound S.lo S.hi L := by
  let f := residualRawKernel (S.incoming k) B ((S.N k:ℝ)*Real.pi/2) (residualDerivativeKernel 0)
  let g := fun t : ℝ => paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)
  have hf := residualRawKernel_integrable (S.N_pos k) (S.incoming k) B ((S.N k:ℝ)*Real.pi/2) 0
  have hg : IntegrableOn g (Ioi 0) := by
    simpa only [pow_zero,one_mul] using integrable_parity_kernel_moment
      (S.N_pos k) (S.incoming k) 0 (by positivity : 0 < Real.pi/2)
  have ht := integral_sub_truncated_cells_abs_le f g hf hg
    (fun t ht => residualRawKernel_dom _ _ _ ht) (Real.pi/S.A k) ρ
    (div_pos Real.pi_pos (S.gain_pos k)) hρ L hH
  have ht' := mul_le_mul_of_nonneg_left ht (Real.sqrt_nonneg (residualVariance (S.alphabet k)))
  have hz := S.residual_actual_zero k hM hρ.le hu
  have hh := S.residual_actual_tail k L hL
  have hc := residual_finite_cell_error (S.N_pos k) (S.alphabet k) (S.alphabet_odd k)
    (S.d k) S.lo_pos (S.A_lo k) ρ B ((S.N k:ℝ)*Real.pi/2) L 0
    (fun l _ => S.cell_integrable hρ k l 0)
  have hm := residual_model_tail (S.N_pos k) (S.alphabet k) (S.alphabet_pos k)
    (S.d k) S.lo_pos (S.A_lo k) (S.A_hi k) B L
  let actual := ∑ l ∈ Finset.range L, ∫ t : ℝ in
    Ioc ((l:ℝ)*(Real.pi/S.A k)) (((l:ℝ)+1)*(Real.pi/S.A k)) ∩ Ici ρ, f t
  let model := ∑ l ∈ Finset.range L,
    residualPeakModel (S.alphabet k) (S.d k) (S.A k) B ((S.N k:ℝ)*Real.pi/2) l 0
  change Real.sqrt (residualVariance (S.alphabet k))*|actual-model| ≤
    (1/S.lo)*(∑ l ∈ Finset.range L, residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l 0) at hc
  have htri := abs_sub_le (parityCorrelation (S.incoming k) B) actual
    (residualLeading (S.alphabet k) (S.d k) (S.A k) B)
  have htri' := abs_sub_le actual model (residualLeading (S.alphabet k) (S.d k) (S.A k) B)
  have hscale := Real.sqrt_nonneg (residualVariance (S.alphabet k))
  have h1 := mul_le_mul_of_nonneg_left htri hscale
  have h2 := mul_le_mul_of_nonneg_left htri' hscale
  rw [residualRawKernel_parity] at h1
  rw [residualRawKernel_parity]
  dsimp [actual,model,f,g,residualModelTailBound] at *
  nlinarith

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
