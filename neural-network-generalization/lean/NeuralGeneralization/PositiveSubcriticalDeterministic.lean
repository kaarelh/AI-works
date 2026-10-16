import NeuralGeneralization.GaussianWalshHeadBound
import NeuralGeneralization.ParityModelBridge
import NeuralGeneralization.NetworkSubcriticalConfidence

/-! Deterministic statistical endpoint for the actual positive-subcritical posterior.
Every global-margin minimum is handled, including ties. The remaining premises
are explicit sample events and scalar cutoff bounds. -/
noncomputable section
namespace NeuralGeneralization.PositiveSubcriticalDeterministic
open scoped BigOperators Topology
open GaussianWalshHeadBound ConcreteModel WalshMarginMinimizers
open NetworkSubcriticalConfidence
open Filter
variable {d u : ℕ} {J : Type*} [Fintype J] [Nonempty J]

lemma low_square_le_energy (w c : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (s : J → ClippingCube d) (H : Finset (Finset (Fin d)))
    (htrain : ∀ j, 0 ≤ fullParity (s j)*walshExpansion c (s j))
    (hcoercivity : ∀ a : Finset (Fin d) → ℝ, (∀ S, a S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion a x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion a (s j))))^2)/Fintype.card J)
    (G B : ℝ) (hG : 0 ≤ G) (hE : featureEnergy w c ≤ B)
    (hGram : ∀ a : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) a ≤ G*∑ i, a i^2) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients H c) x^2) ≤
      4*G*B/Fintype.card J := by
  classical
  let p := walshExpansion (maskCoefficients H c)
  let t := walshExpansion (maskCoefficients (Finset.univ \ H) c)
  have hcoer := hcoercivity (maskCoefficients H c) (fun S hS => by
    by_contra hn
    exact hS (by simp [maskCoefficients, hn]))
  have ht (x : ClippingCube d) : walshExpansion c x-p x=t x := by
    have h := featureField_decomposition (fun S x => walshCharacter S x) c H x
    change walshExpansion c x=p x+t x at h
    linarith
  have hwrong : (∑ j, (max 0 (-(fullParity (s j)*p (s j))))^2) ≤ ∑ j, t (s j)^2 := by
    apply Finset.sum_le_sum
    intro j _
    rw [← ht]
    exact signed_negativePart_sq_le_residual _ _ _ (fullParity_sign _) (htrain j)
  have hsample := (walsh_tail_sample_square_le w c hw (Finset.univ \ H) s G hG hGram).trans
    (mul_le_mul_of_nonneg_left hE hG)
  have hn : (0:ℝ) < Fintype.card J := Nat.cast_pos.mpr Fintype.card_pos
  have havg := div_le_div_of_nonneg_right (hwrong.trans hsample) hn.le
  change (1/4:ℝ)*uniformCubeMean (fun x => p x^2) ≤ _ at hcoer
  change uniformCubeMean (fun x => p x^2) ≤ _
  calc
    _ ≤ 4*(G*B/Fintype.card J) := by linarith
    _ = _ := by ring

lemma projected_square_le_energy (w c : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (htrain : ∀ j, 0 ≤ fullParity (s j)*walshExpansion c (s j))
    (hcoercivity : ∀ a : Finset (Fin d) → ℝ, (∀ S, a S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion a x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion a (s j))))^2)/Fintype.card J)
    (G B ell : ℝ) (hG : 0 ≤ G) (hell : 0 ≤ ell) (hE : featureEnergy w c ≤ B)
    (hmax : ∀ S ∈ Finset.univ \ H, w S ≤ ell)
    (hGram : ∀ a : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) a ≤ G*∑ i, a i^2) :
    uniformCubeMean (fun x => walshExpansion (maskCoefficients U c) x^2) ≤
      4*G*B/Fintype.card J+ell*B := by
  apply (mean_square_mask_le c U).trans
  rw [mean_square_decomposition c H]
  exact add_le_add (low_square_le_energy w c hw s H htrain hcoercivity G B hG hE hGram)
    ((walsh_tail_population_square_le w c hw (Finset.univ \ H) ell hell hmax).trans
      (mul_le_mul_of_nonneg_left hE hell))

/-- Actual global-margin fields of bounded RKHS energy have parity error at
least three eighths on the two sample events, under displayed scalar budgets. -/
theorem parity_error_lower_of_energy (hd : 0 < d)
    (w c : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (s : J → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hdegree : ∀ S ∈ U, S.card ≤ u)
    (a : ℝ) (ha : 0 < a) (hmargin : ∀ x, a ≤ |walshExpansion c x|)
    (htrain : ∀ j, 0 ≤ fullParity (s j)*walshExpansion c (s j))
    (hcoercivity : ∀ z : Finset (Fin d) → ℝ, (∀ S, z S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion z x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion z (s j))))^2)/Fintype.card J)
    (G B ellH ellU : ℝ) (hG : 0 ≤ G) (hellH : 0 ≤ ellH) (hellU : 0 ≤ ellU)
    (hE : featureEnergy w c ≤ B)
    (hmaxH : ∀ S ∈ Finset.univ \ H, w S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ \ U, w S ≤ ellU)
    (hGram : ∀ z : J → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H) w (s i) (s j)) z ≤ G*∑ i, z i^2)
    (hhead : (u:ℝ)^2*(4*G*B/Fintype.card J+ellH*B) ≤ (a*(d:ℝ))^2/64)
    (htail : ellU*B ≤ a^2/64) :
    (3/8:ℝ) ≤ uniformParityError (walshExpansion c) := by
  classical
  apply parity_error_lower_of_low_degree_approximation hd (maskCoefficients U c)
    (fun S hS => hdegree S (by
      by_contra hn
      exact hS (by simp [maskCoefficients, hn]))) (walshExpansion c) a ha hmargin
  · exact (mul_le_mul_of_nonneg_left
      (projected_square_le_energy w c hw s H U htrain hcoercivity G B ellH hG hellH hE hmaxH hGram)
      (sq_nonneg (u:ℝ))).trans hhead
  · have he (x : ClippingCube d) : walshExpansion c x-walshExpansion (maskCoefficients U c) x =
        walshExpansion (maskCoefficients (Finset.univ \ U) c) x := by
      have hh := featureField_decomposition (fun S x => walshCharacter S x) c U x
      change walshExpansion c x = walshExpansion (maskCoefficients U c) x+
        walshExpansion (maskCoefficients (Finset.univ \ U) c) x at hh
      linarith
    simp_rw [he]
    exact ((walsh_tail_population_square_le w c hw (Finset.univ \ U) ellU hellU hmaxU).trans
      (mul_le_mul_of_nonneg_left hE hellU)).trans htail

/-- All analytic limit and minimizer obligations are discharged here. The
remaining hypotheses are a concrete feasible comparator, the two explicit
sample inequalities, and numerical spectral budgets. -/
theorem confidence_liminf_of_comparator_budgets {n r : ℕ} (hd : 0 < d) (hn : 0 < n)
    {γ a : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) (ha : 0 < a)
    (s : Fin n → ClippingCube d) (H U : Finset (Finset (Fin d)))
    (hdegree : ∀ S ∈ U, S.card ≤ u)
    (hcoercivity : ∀ z : Finset (Fin d) → ℝ, (∀ S, z S ≠ 0 → S ∈ H) →
      (1/4:ℝ)*uniformCubeMean (fun x => walshExpansion z x^2) ≤
        (∑ j, (max 0 (-(fullParity (s j)*walshExpansion z (s j))))^2)/n)
    (G B ellH ellU : ℝ) (hG : 0 ≤ G) (hellH : 0 ≤ ellH) (hellU : 0 ≤ ellU)
    (hcomparator : ∃ c₀ ∈ globalTrainingMarginSet a (parity d) s,
      featureEnergy (walshCoefficients (arcsineProfile d (r+1))) c₀ ≤ B)
    (hmaxH : ∀ S ∈ Finset.univ \ H, walshCoefficients (arcsineProfile d (r+1)) S ≤ ellH)
    (hmaxU : ∀ S ∈ Finset.univ \ U, walshCoefficients (arcsineProfile d (r+1)) S ≤ ellU)
    (hGram : ∀ z : Fin n → ℝ,
      finiteQuadratic (fun i j => walshTailKernel (Finset.univ \ H)
        (walshCoefficients (arcsineProfile d (r+1))) (s i) (s j)) z ≤ G*∑ i, z i^2)
    (hhead : (u:ℝ)^2*(4*G*B/n+ellH*B) ≤ (a*(d:ℝ))^2/64)
    (htail : ellU*B ≤ a^2/64) :
    (1/16:ℝ) ≤ Filter.liminf (fun N => ConcreteModel.confidenceFailure (uniformLaw d) (parity d)
      (networkPosterior Real.tanh a (powerPrior d N r γ) (parity d) s)) atTop := by
  letI : NeZero n := ⟨Nat.ne_of_gt hn⟩
  apply confidence_liminf_of_hard_global_minimizers hd r hγ0 hγ1 ha (uniformLaw d) (parity d) s
  intro c hc hmin
  obtain ⟨c₀, hc₀, hB⟩ := hcomparator
  rw [functionError_parity_eq]
  apply parity_error_lower_of_energy hd (walshCoefficients (arcsineProfile d (r+1))) c
    (iterated_arcsine_coefficient_pos d r) s H U hdegree a ha hc.1
    (fun j => ha.le.trans (by simpa only [labelReal_parity] using hc.2 j))
    (by simpa only [Fintype.card_fin] using hcoercivity) G B ellH ellU hG hellH hellU
    ((hmin c₀ hc₀).trans hB) hmaxH hmaxU hGram
    (by simpa only [Fintype.card_fin] using hhead) htail

end NeuralGeneralization.PositiveSubcriticalDeterministic
