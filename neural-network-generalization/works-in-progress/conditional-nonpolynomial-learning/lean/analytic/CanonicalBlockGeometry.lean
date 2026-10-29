import SpectralGridCover
import BlockRepresentativeCover

/-! The geometric step of the nearcritical good-block proof.
A small free operator plus a Hilbert--Schmidt bounded perturbation is covered by
an explicit finite grid. Restricted residual Lipschitz control then selects
actual query representatives. No full canonical normal form is assumed. -/

namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

/-- Cover parameters depend only on the Hilbert--Schmidt budget and the target
radius, not on either ambient dimension. -/
theorem exists_block_cover_parameters (M B : ℝ) (hM : 0 ≤ M) (hB : 0 < B) :
    ∃ T K : ℕ, 0 < T ∧ M^2 ≤ (B / 64)^2 * K ∧
      ∀ Q : ℝ, 0 ≤ Q → Q ≤ M^2 →
        Real.sqrt (Q / (T : ℝ)^2 + (B / 64)^2) ≤ B / 32 := by
  let ε := B / 64
  have hε : 0 < ε := by dsimp [ε]; positivity
  obtain ⟨T, hT⟩ := exists_nat_gt (M / ε + 1)
  have hTr : (0 : ℝ) < T := lt_trans (by positivity) hT
  have hTn : 0 < T := by exact_mod_cast hTr
  have hMT : M / (T : ℝ) ≤ ε := by
    apply (div_le_iff₀ hTr).mpr
    have hh : M / ε < (T : ℝ) := by linarith
    have hm := (div_lt_iff₀ hε).mp hh
    nlinarith
  obtain ⟨K, hK⟩ := exists_nat_ge (M^2 / ε^2)
  have hMK : M^2 ≤ ε^2 * K := by
    have hh := (div_le_iff₀ (sq_pos_of_pos hε)).mp hK
    nlinarith
  refine ⟨T, K, hTn, hMK, ?_⟩
  intro Q hQ hQM
  have hQdiv : Q / (T : ℝ)^2 ≤ ε^2 := by
    calc
      Q / (T : ℝ)^2 ≤ M^2 / (T : ℝ)^2 :=
        div_le_div_of_nonneg_right hQM (sq_nonneg _)
      _ = (M / (T : ℝ))^2 := by rw [div_pow]
      _ ≤ ε^2 := by nlinarith [div_nonneg hM hTr.le]
  rw [Real.sqrt_le_left (by positivity : 0 ≤ B / 32)]
  change Q / (T : ℝ)^2 + ε^2 ≤ (B / 32)^2
  have he : B / 32 = 2 * ε := by dsimp [ε]; ring
  rw [he]
  nlinarith [sq_nonneg ε]

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [FiniteDimensional ℝ F]

/-- An actual good-block cover, with explicit dimension-independent cardinality.
The residual hypothesis concerns pairs in `S` only. -/
theorem canonical_good_block_actual_cover
    (S : Set E) (z : E) (r B σ ε : ℝ) (T K : ℕ)
    (U A : E →ₗ[ℝ] F) (N : E → F)
    (hr : 0 < r) (hB : 0 ≤ B) (hσ : 0 ≤ σ) (hε : 0 < ε) (hT : 0 < T)
    (hS : S ⊆ Metric.closedBall z r)
    (hU : ∀ x, ‖U x‖ ≤ σ * ‖x‖)
    (hHS : frobeniusSq A ≤ ε^2 * K)
    (hsmall : σ + Real.sqrt (frobeniusSq A / (T : ℝ)^2 + ε^2) ≤ B / 8)
    (hN : ∀ x ∈ S, ∀ y ∈ S, dist (N x) (N y) ≤ (B / 16) * dist x y) :
    ∃ Y : Finset E, (↑Y : Set E) ⊆ S ∧ Y.card ≤ (2 * T + 1)^K ∧
      ∀ x ∈ S, ∃ y ∈ Y,
        dist ((U + A) x + N x) ((U + A) y + N y) ≤ B * r / 2 := by
  obtain ⟨C, hCM, hC⟩ := bounded_perturbation_ball_cover U A z r σ ε T K
    hr hσ hε hT hU hHS
  have hcover : FiniteBallCover ((U + A) '' S) ((2*T+1)^K) (B * r / 8) := by
    refine ⟨C, hCM, ?_⟩
    rintro v ⟨x, hx, rfl⟩
    obtain ⟨c, hc, hxc⟩ := hC ((U + A) x) ⟨x, hS hx, rfl⟩
    refine ⟨c, hc, hxc.trans ?_⟩
    nlinarith [mul_le_mul_of_nonneg_left hsmall hr.le]
  exact actual_representatives_good_block S z r B _ (fun x => (U + A) x) N
    hr.le hB hS hcover hN

#print axioms exists_block_cover_parameters
#print axioms canonical_good_block_actual_cover
end ConditionalNonpolynomial.Analytic
