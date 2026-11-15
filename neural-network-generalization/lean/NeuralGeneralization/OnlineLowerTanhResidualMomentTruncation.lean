import NeuralGeneralization.OnlineLowerTanhResidualCLT
import NeuralGeneralization.OnlineLowerTanhResidualMomentSeries
import NeuralGeneralization.OnlineLowerTanhBiasIntegral
import NeuralGeneralization.OnlineLowerIntegralTails

/-! # Uniform finite approximations of the signed residual integral -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualActualMomentTailBound (j : ℕ) (Q hi : ℝ) (L : ℕ) : ℝ :=
  Q * (((2/(Real.pi/2))*((j.factorial:ℝ)/((Real.pi/2)/4)^j))*(Real.pi/((Real.pi/2)/8)))*
    Real.exp (-((Real.pi/2)/8)*((L:ℝ)*Real.pi/hi))

def residualMomentModelTailBound (j : ℕ) (lo hi : ℝ) (L : ℕ) : ℝ :=
  (Real.sqrt (2*Real.pi)/Real.pi)*(∑' l : ℕ, momentMajorant j lo hi (l+L))

def residualMomentIntegral {n : ℕ} (j : ℕ) (u : Fin n → ℝ) (B δ : ℝ) : ℝ :=
  ∫ t : ℝ in Ioi 0, residualRawKernel u B ((n:ℝ)*Real.pi/2+δ) (residualDerivativeKernel j) t

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

lemma residual_actual_moment_tail (j k L : ℕ) (hL : 1 ≤ (L:ℝ)*Real.pi/S.hi) :
    Real.sqrt (residualVariance (S.alphabet k)) *
      (∫ t : ℝ in Ioi ((L:ℝ)*(Real.pi/S.A k)),
        t^j*paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)) ≤
      residualActualMomentTailBound j S.Q S.hi L := by
  let T : ℝ := (L:ℝ)*(Real.pi/S.A k)
  have hT : (L:ℝ)*Real.pi/S.hi ≤ T := by
    dsimp [T]
    simpa only [mul_div_assoc] using div_le_div_of_nonneg_left
      (mul_nonneg (Nat.cast_nonneg L) Real.pi_pos.le) (S.gain_pos k) (S.A_hi k)
  have hb := (parity_kernel_moment_tail (S.N_pos k) (S.incoming k) j
    (by positivity : 0 < Real.pi/2) (hL.trans hT)).2
  have hi : 0 ≤ ∫ t : ℝ in Ioi T,
      t^j*paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t) := by
    apply setIntegral_nonneg measurableSet_Ioi
    intro t ht
    exact div_nonneg (mul_nonneg (pow_nonneg (by have hh := hL.trans hT; have h := ht; change T<t at h; linarith : 0≤t) j) (paritySineProduct_nonneg _ _)) (Real.sinh_pos_iff.mpr (by
      have ht0 : 0 < t := lt_of_lt_of_le (by norm_num : (0:ℝ)<1) ((hL.trans hT).trans ht.le)
      positivity)).le
  have hs := mul_le_mul_of_nonneg_right (S.variance_sqrt_bound k) hi
  have hm := mul_le_mul_of_nonneg_left hb S.Q_pos.le
  have hexp : Real.exp (-((Real.pi/2)/8)*T) ≤
      Real.exp (-((Real.pi/2)/8)*((L:ℝ)*Real.pi/S.hi)) := by
    apply Real.exp_le_exp.mpr
    nlinarith [Real.pi_pos]
  have he := mul_le_mul_of_nonneg_left hexp
    (show 0 ≤ S.Q*(((2/(Real.pi/2))*((j.factorial:ℝ)/((Real.pi/2)/4)^j))*(Real.pi/((Real.pi/2)/8))) by positivity [S.Q_pos])
  dsimp [residualActualMomentTailBound,T] at *
  nlinarith

lemma residual_actual_moment_zero (j k : ℕ) {M ρ : ℝ} (hM : 0 ≤ M) (hρ : 0 ≤ ρ)
    (hu : ∀ i, |S.incoming k i| ≤ M) :
    Real.sqrt (residualVariance (S.alphabet k)) *
      (∫ t : ℝ in Ioc 0 ρ, t^j*paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)) ≤
      ρ^j*residualZeroBound S.Q M ρ (S.N k) := by
  have hgi := integrable_parity_kernel_moment (S.N_pos k) (S.incoming k) j
    (by positivity : 0 < Real.pi/2)
  have hg0 := integrable_parity_kernel_moment (S.N_pos k) (S.incoming k) 0
    (by positivity : 0 < Real.pi/2)
  simp only [pow_zero,one_mul] at hg0
  have hcmp := integral_mono_ae (hgi.mono_set (s:=Ioc 0 ρ) Ioc_subset_Ioi_self)
    ((hg0.mono_set (s:=Ioc 0 ρ) Ioc_subset_Ioi_self).const_mul (ρ^j)) (by
      filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      have hs : 0 < Real.sinh ((Real.pi/2)*t) := Real.sinh_pos_iff.mpr (by positivity [ht.1])
      have hp := pow_le_pow_left₀ ht.1.le ht.2 j
      have hm := mul_le_mul_of_nonneg_right hp
        (div_nonneg (paritySineProduct_nonneg (S.incoming k) t) hs.le)
      convert hm using 1 <;> first | rfl | ring)
  rw [integral_const_mul] at hcmp
  have hm := mul_le_mul_of_nonneg_left hcmp (Real.sqrt_nonneg (residualVariance (S.alphabet k)))
  have hz := mul_le_mul_of_nonneg_left (S.residual_actual_zero k hM hρ hu) (pow_nonneg hρ j)
  nlinarith

/-- A finite, uniform-in-bias approximation with all three discarded tails
controlled explicitly. -/
theorem moment_approximation_bound (j k L : ℕ) {ρ M : ℝ} (hρ : 0 < ρ) (hM : 0 ≤ M)
    (hu : ∀ i, |S.incoming k i| ≤ M)
    (hH : ρ ≤ (L:ℝ)*(Real.pi/S.A k))
    (hL : 1 ≤ (L:ℝ)*Real.pi/S.hi) (B δ : ℝ) :
    Real.sqrt (residualVariance (S.alphabet k))*
      |residualMomentIntegral j (S.incoming k) B δ-residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B δ| ≤
      ρ^j*residualZeroBound S.Q M ρ (S.N k) +
      (1/S.lo)*(∑ l ∈ Finset.range L, residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l j) +
      residualActualMomentTailBound j S.Q S.hi L + residualMomentModelTailBound j S.lo S.hi L := by
  let f := residualRawKernel (S.incoming k) B ((S.N k:ℝ)*Real.pi/2+δ) (residualDerivativeKernel j)
  let g := fun t : ℝ => t^j*paritySineProduct (S.incoming k) t/Real.sinh ((Real.pi/2)*t)
  have hf := residualRawKernel_integrable (S.N_pos k) (S.incoming k) B ((S.N k:ℝ)*Real.pi/2+δ) j
  have hg : IntegrableOn g (Ioi 0) := by
    exact integrable_parity_kernel_moment
      (S.N_pos k) (S.incoming k) j (by positivity : 0 < Real.pi/2)
  have ht := integral_sub_truncated_cells_abs_le f g hf hg
    (fun t ht => residualRawKernel_abs_le_moment _ _ _ j ht) (Real.pi/S.A k) ρ
    (div_pos Real.pi_pos (S.gain_pos k)) hρ L hH
  have ht' := mul_le_mul_of_nonneg_left ht (Real.sqrt_nonneg (residualVariance (S.alphabet k)))
  have hz := S.residual_actual_moment_zero j k hM hρ.le hu
  have hh := S.residual_actual_moment_tail j k L hL
  have hc := residual_finite_cell_error (S.N_pos k) (S.alphabet k) (S.alphabet_odd k)
    (S.d k) S.lo_pos (S.A_lo k) ρ B ((S.N k:ℝ)*Real.pi/2+δ) L j
    (fun l _ => S.cell_integrable hρ k l j)
  have hm := residual_moment_model_tail (S.N_pos k) (S.alphabet k) (S.alphabet_pos k)
    (S.d k) S.lo_pos (S.A_lo k) (S.A_hi k) B δ L j
  let actual := ∑ l ∈ Finset.range L, ∫ t : ℝ in
    Ioc ((l:ℝ)*(Real.pi/S.A k)) (((l:ℝ)+1)*(Real.pi/S.A k)) ∩ Ici ρ, f t
  let model := ∑ l ∈ Finset.range L,
    residualPeakModel (S.alphabet k) (S.d k) (S.A k) B ((S.N k:ℝ)*Real.pi/2+δ) l j
  change Real.sqrt (residualVariance (S.alphabet k))*|actual-model| ≤
    (1/S.lo)*(∑ l ∈ Finset.range L, residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l j) at hc
  have htri := abs_sub_le (residualMomentIntegral j (S.incoming k) B δ) actual
    (residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B δ)
  have htri' := abs_sub_le actual model (residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) B δ)
  have hscale := Real.sqrt_nonneg (residualVariance (S.alphabet k))
  have h1 := mul_le_mul_of_nonneg_left htri hscale
  have h2 := mul_le_mul_of_nonneg_left htri' hscale
  unfold residualMomentIntegral at h1
  unfold residualMomentIntegral
  dsimp [actual,model,f,g,residualMomentModelTailBound] at *
  nlinarith

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
