import NeuralGeneralization.OnlineLowerTanhEmpirical
import Mathlib.Analysis.SpecificLimits.Basic

/-! # Probability and second-moment limits of actual empirical odd alphabets

Pointwise convergence plus the actual quadratic tail bound conserves total
probability. Second moment need not be conserved: the nonnegative escaped
moment is explicitly the limiting empirical moment minus the limit-law
moment.
-/

noncomputable section
open scoped BigOperators Topology Classical
open Filter Set

namespace NeuralGeneralization.OnlineLowerTanh

lemma empiricalSecondMoment_nonneg {n : ℕ} (q : Fin n → ℕ) :
    0 ≤ empiricalSecondMoment q := by unfold empiricalSecondMoment; positivity

lemma empiricalMass_moment_range {n : ℕ} (q : Fin n → ℕ) (J : ℕ) :
    (∑ j ∈ Finset.range J, empiricalMass q j * (j : ℝ)^2) =
      (n : ℝ)⁻¹ * ∑ i, if q i < J then (q i : ℝ)^2 else 0 := by
  have hterm (j : ℕ) : empiricalMass q j * (j : ℝ)^2 =
      (n : ℝ)⁻¹ * ∑ i, if q i = j then (q i : ℝ)^2 else 0 := by
    unfold empiricalMass
    rw [mul_assoc, Finset.sum_mul]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    by_cases hi : q i = j <;> simp [hi]
  simp_rw [hterm]
  rw [← Finset.mul_sum, Finset.sum_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  simp [eq_comm]

lemma empiricalMass_moment_range_le {n : ℕ} (q : Fin n → ℕ) (J : ℕ) :
    (∑ j ∈ Finset.range J, empiricalMass q j * (j : ℝ)^2) ≤ empiricalSecondMoment q := by
  rw [empiricalMass_moment_range]
  unfold empiricalSecondMoment
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  exact Finset.sum_le_sum fun i _ => by split_ifs <;> first | exact le_rfl | positivity

section Limits
variable (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (p : ℕ → ℝ) (Q : ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j)))
    (hQ : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 Q))
include hN hp hQ

lemma empiricalLimit_nonneg (j : ℕ) : 0 ≤ p j :=
  ge_of_tendsto (hp j) (Filter.Eventually.of_forall fun k => empiricalMass_nonneg (q k) j)

lemma empiricalLimit_moment_nonneg : 0 ≤ Q :=
  ge_of_tendsto hQ (Filter.Eventually.of_forall fun k => empiricalSecondMoment_nonneg (q k))

lemma empiricalLimit_prefix_le_one (J : ℕ) : (∑ j ∈ Finset.range J, p j) ≤ 1 := by
  have hc : Tendsto (fun k => ∑ j ∈ Finset.range J, empiricalMass (q k) j) atTop
      (𝓝 (∑ j ∈ Finset.range J, p j)) := tendsto_finsetSum _ fun j _ => hp j
  exact le_of_tendsto hc (Filter.Eventually.of_forall fun k => empiricalMass_range_le_one (hN k) (q k) J)

lemma empiricalLimit_tail_bound (J : ℕ) (hJ : 0 < J) :
    1 - (∑ j ∈ Finset.range J, p j) ≤ Q / (J : ℝ)^2 := by
  have hc : Tendsto (fun k => ∑ j ∈ Finset.range J, empiricalMass (q k) j) atTop
      (𝓝 (∑ j ∈ Finset.range J, p j)) := tendsto_finsetSum _ fun j _ => hp j
  exact le_of_tendsto_of_tendsto' (tendsto_const_nhds.sub hc) (hQ.div_const _)
    (fun k => empiricalMass_tail_bound (hN k) (q k) J hJ)

lemma empiricalLimit_summable : Summable p :=
  summable_of_sum_range_le (empiricalLimit_nonneg N hN q p Q hp hQ)
    (empiricalLimit_prefix_le_one N hN q p Q hp hQ)

/-- No probability mass escapes under the uniform second-moment control. -/
theorem empiricalLimit_hasSum_one : HasSum p 1 := by
  have hs := empiricalLimit_summable N hN q p Q hp hQ
  have hu : (∑' j, p j) ≤ 1 := hs.tsum_le_of_sum_range_le
    (empiricalLimit_prefix_le_one N hN q p Q hp hQ)
  have htail : Tendsto (fun J : ℕ => Q / (J : ℝ)^2) atTop (𝓝 0) := by
    have hh := (tendsto_inv_atTop_nhds_zero_nat (𝕜 := ℝ)).pow 2
    simpa only [div_eq_mul_inv, inv_pow, zero_pow (by norm_num : 2 ≠ 0), mul_zero] using
      (tendsto_const_nhds (x := Q)).mul hh
  have hlo : 1 - (∑' j, p j) ≤ 0 := by
    apply le_of_tendsto_of_tendsto (tendsto_const_nhds.sub hs.hasSum.tendsto_sum_nat) htail
    exact Filter.eventually_atTop.mpr ⟨1, fun J hJ => empiricalLimit_tail_bound N hN q p Q hp hQ J (by omega)⟩
  have heq : (∑' j, p j) = 1 := by linarith
  exact heq ▸ hs.hasSum

lemma empiricalLimit_truncated_moment_le (J : ℕ) :
    (∑ j ∈ Finset.range J, p j * (j : ℝ)^2) ≤ Q := by
  have hc : Tendsto (fun k => ∑ j ∈ Finset.range J, empiricalMass (q k) j * (j : ℝ)^2) atTop
      (𝓝 (∑ j ∈ Finset.range J, p j * (j : ℝ)^2)) :=
    tendsto_finsetSum _ fun j _ => (hp j).mul_const _
  exact le_of_tendsto_of_tendsto' hc hQ (fun k => empiricalMass_moment_range_le (q k) J)

lemma empiricalLimit_moment_summable : Summable (fun j => p j * (j : ℝ)^2) :=
  summable_of_sum_range_le (fun j => mul_nonneg (empiricalLimit_nonneg N hN q p Q hp hQ j) (sq_nonneg _))
    (empiricalLimit_truncated_moment_le N hN q p Q hp hQ)

/-- The limit law can lose second moment, and the escaped part is nonnegative. -/
theorem empiricalLimit_escaped_moment_nonneg :
    0 ≤ Q - ∑' j, p j * (j : ℝ)^2 := by
  have hs := empiricalLimit_moment_summable N hN q p Q hp hQ
  exact sub_nonneg.mpr (hs.tsum_le_of_sum_range_le (empiricalLimit_truncated_moment_le N hN q p Q hp hQ))

lemma empiricalLimit_zero_of_forbidden (j : ℕ) (hforbidden : ∀ k i, q k i ≠ j) : p j = 0 := by
  have hz (k : ℕ) : empiricalMass (q k) j = 0 := by
    simp [empiricalMass, hforbidden k]
  have hzero : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 (p j)) := by simpa only [hz] using hp j
  exact tendsto_nhds_unique hzero tendsto_const_nhds

theorem empiricalLimit_positive_odd_support
    (hq : ∀ k i, 0 < q k i ∧ Odd (q k i)) (j : ℕ) (hj : 0 < p j) : 0 < j ∧ Odd j := by
  by_contra hbad
  have hzero := empiricalLimit_zero_of_forbidden N hN q p Q hp hQ j (fun k i he => hbad (he ▸ hq k i))
  linarith

end Limits
end NeuralGeneralization.OnlineLowerTanh
