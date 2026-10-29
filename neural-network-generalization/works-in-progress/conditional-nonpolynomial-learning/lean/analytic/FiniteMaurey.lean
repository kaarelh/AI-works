import FiniteConcentration

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch
namespace FiniteProbability

variable {I E : Type*} [Fintype I] [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Finite vector-valued mean. -/
def vectorAvg (p : I → ℝ) (v : I → E) : E := ∑ i, p i • v i

lemma avg_inner (p : I → ℝ) (v : I → E) (z : E) :
    avg p (fun i ↦ ⟪v i, z⟫) = ⟪vectorAvg p v, z⟫ := by
  simp only [avg, vectorAvg, sum_inner, real_inner_smul_left]

lemma vectorAvg_centered (p : I → ℝ) (hp : ∑ i, p i = 1) (v : I → E) :
    vectorAvg p (fun i ↦ v i - vectorAvg p v) = 0 := by
  simp only [vectorAvg, smul_sub, Finset.sum_sub_distrib, ← Finset.sum_smul, hp, one_smul,
    sub_self]

lemma avg_norm_sq_centered (p : I → ℝ) (hp : ∑ i, p i = 1) (v : I → E) :
    avg p (fun i ↦ ‖v i - vectorAvg p v‖ ^ 2) =
      avg p (fun i ↦ ‖v i‖ ^ 2) - ‖vectorAvg p v‖ ^ 2 := by
  simp_rw [norm_sub_sq_real]
  rw [avg_add, avg_sub, avg_const_mul, avg_inner, avg_const p hp,
    real_inner_self_eq_norm_sq]
  ring

lemma avg_norm_add_sq_of_centered (p : I → ℝ) (hp : ∑ i, p i = 1)
    (v : I → E) (hv : vectorAvg p v = 0) (z : E) :
    avg p (fun i ↦ ‖v i + z‖ ^ 2) = avg p (fun i ↦ ‖v i‖ ^ 2) + ‖z‖ ^ 2 := by
  simp_rw [norm_add_sq_real]
  rw [avg_add, avg_add, avg_const_mul, avg_inner, avg_const p hp, hv]
  simp

/-- Exact Hilbert-space variance identity for a sum of independent finite draws. -/
theorem sampleAvg_norm_sum_sq (p : I → ℝ) (hp : ∑ i, p i = 1)
    (v : I → E) (hv : vectorAvg p v = 0) (m : ℕ) :
    sampleAvg p m (fun s ↦ ‖∑ j, v (s j)‖ ^ 2) =
      (m : ℝ) * avg p (fun i ↦ ‖v i‖ ^ 2) := by
  induction m with
  | zero => simp [sampleAvg]
  | succ m ih =>
    simp_rw [sampleAvg, Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ,
      avg_norm_add_sq_of_centered p hp v hv]
    rw [sampleAvg_add, sampleAvg_const p hp, ih]
    push_cast
    ring

/-- Expected error of the unnormalized empirical sum is at most J sqrt(m). -/
theorem sampleAvg_norm_sum_centered_le (p : I → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (v : I → E) (J : ℝ) (hJ : 0 ≤ J) (hv : ∀ i, ‖v i‖ ≤ J) (m : ℕ) :
    sampleAvg p m (fun s ↦ ‖∑ j, (v (s j) - vectorAvg p v)‖) ≤ J * Real.sqrt m := by
  have hm : 0 ≤ (m : ℝ) := Nat.cast_nonneg m
  have hv2 : avg p (fun i ↦ ‖v i‖ ^ 2) ≤ J ^ 2 := by
    apply (avg_mono p hp0 (fun i ↦ (sq_le_sq₀ (norm_nonneg _) hJ).mpr (hv i))).trans_eq
    exact avg_const p hp _
  have hsq := sq_sampleAvg_le p hp0 hp m
    (fun s ↦ ‖∑ j, (v (s j) - vectorAvg p v)‖)
  rw [sampleAvg_norm_sum_sq p hp _ (vectorAvg_centered p hp v), avg_norm_sq_centered p hp] at hsq
  have hmean0 := sampleAvg_nonneg p hp0 hp m
    (fun s ↦ ‖∑ j, (v (s j) - vectorAvg p v)‖) (fun _ ↦ norm_nonneg _)
  apply (sq_le_sq₀ hmean0 (mul_nonneg hJ (Real.sqrt_nonneg _))).mp
  rw [mul_pow, Real.sq_sqrt hm]
  nlinarith [mul_nonneg hm (sq_nonneg (vectorAvg p v |> norm))]

omit [Fintype I] [InnerProductSpace ℝ E] in
/-- Single-sample sensitivity of an empirical Hilbert norm. -/
theorem boundedDifferences_norm_sum (v : I → E) (J : ℝ) (hv : ∀ i, ‖v i‖ ≤ J)
    (m : ℕ) (z : E) :
    BoundedDifferences m (fun s ↦ ‖z + ∑ j, v (s j)‖) (2 * J) := by
  induction m generalizing z with
  | zero => trivial
  | succ m ih =>
    constructor
    · intro s a b
      simp only [Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ]
      apply (abs_norm_sub_norm_le _ _).trans
      have heq : (z + (v a + ∑ j, v (s j))) - (z + (v b + ∑ j, v (s j))) = v a - v b := by abel
      rw [heq]
      exact (norm_sub_le _ _).trans (by linarith [hv a, hv b])
    · intro a
      simpa only [Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ, add_assoc]
        using ih (z + v a)

/-- Finite-input Hilbert-valued Maurey approximation with logarithmic dependence
on the number of inputs. The conclusion uses an actual common sequence of m
sampled indices. No concentration, independence, or empirical approximation is
assumed: those estimates are proved in this file and FiniteConcentration. -/
theorem finite_input_maurey {K : Type*} [Fintype K] [Nonempty K]
    (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (v : K → I → E) (J ε : ℝ) (hJ : 0 < J) (hε : 0 < ε)
    (hv : ∀ k i, ‖v k i‖ ≤ J) (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * J ^ 2 * (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2) :
    ∃ s : Fin m → I, ∀ k,
      ‖(m : ℝ)⁻¹ • (∑ j, v k (s j)) - vectorAvg p (v k)‖ < ε := by
  classical
  have hmR : 0 < (m : ℝ) := Nat.cast_pos.mpr hm
  have hN : 0 < (Fintype.card K : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hN1 : (1 : ℝ) ≤ Fintype.card K := by exact_mod_cast Fintype.card_pos
  have hlog0 : 0 ≤ Real.log (Fintype.card K) := Real.log_nonneg hN1
  let f : K → (Fin m → I) → ℝ := fun k s ↦
    ‖∑ j, (v k (s j) - vectorAvg p (v k))‖
  have hf : ∀ k, BoundedDifferences m (f k) (2 * J) := by
    intro k
    have heq : f k = fun s ↦ ‖-((m : ℝ) • vectorAvg p (v k)) + ∑ j, v k (s j)‖ := by
      funext s
      dsimp [f]
      congr 1
      rw [Finset.sum_sub_distrib]
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
        ← Nat.cast_smul_eq_nsmul ℝ]
      abel
    rw [heq]
    exact boundedDifferences_norm_sum (v k) J (hv k) m _
  have hmean : ∀ k, sampleAvg p m (f k) ≤ (m : ℝ) * ε / 2 := by
    intro k
    apply (sampleAvg_norm_sum_centered_le p hp0 hp (v k) J hJ.le (hv k) m).trans
    have hbase : 4 * J ^ 2 ≤ (m : ℝ) * ε ^ 2 := by
      nlinarith [mul_nonneg (sq_nonneg J) hlog0]
    apply (sq_le_sq₀ (mul_nonneg hJ.le (Real.sqrt_nonneg _)) (by positivity)).mp
    rw [mul_pow, Real.sq_sqrt hmR.le]
    nlinarith [mul_le_mul_of_nonneg_left hbase hmR.le]
  let t := ε / (8 * J ^ 2)
  let u := (m : ℝ) * ε / 2
  have ht : 0 ≤ t := by dsimp [t]; positivity
  have hden : 0 < 32 * J ^ 2 := by positivity
  have hlog : Real.log (Fintype.card K) < (m : ℝ) * ε ^ 2 / (32 * J ^ 2) := by
    apply (lt_div_iff₀ hden).mpr
    nlinarith [sq_pos_of_pos hJ, mul_nonneg (sq_nonneg J) hlog0]
  have ha : t ^ 2 * (m : ℝ) * (2 * J) ^ 2 / 2 = (m : ℝ) * ε ^ 2 / (32 * J ^ 2) := by
    dsimp [t]
    field_simp
    ring
  have hb : t * u = 2 * ((m : ℝ) * ε ^ 2 / (32 * J ^ 2)) := by
    dsimp [t, u]
    field_simp
    ring
  have hgap : (Fintype.card K : ℝ) * Real.exp (t ^ 2 * (m : ℝ) * (2 * J) ^ 2 / 2) <
      Real.exp (t * u) := by
    rw [ha, hb]
    calc
      _ = Real.exp (Real.log (Fintype.card K) + (m : ℝ) * ε ^ 2 / (32 * J ^ 2)) := by
        rw [Real.exp_add, Real.exp_log hN]
      _ < _ := Real.exp_lt_exp.mpr (by linarith)
  obtain ⟨s, hs⟩ := exists_sample_all_lt p hp0 hp m f (2 * J) (by positivity) hf t u ht hgap
  refine ⟨s, fun k ↦ ?_⟩
  have hsum : ‖∑ j, (v k (s j) - vectorAvg p (v k))‖ < (m : ℝ) * ε := by
    have := hs k
    have := hmean k
    dsimp [f, u] at *
    linarith
  have heq : (m : ℝ)⁻¹ • (∑ j, v k (s j)) - vectorAvg p (v k) =
      (m : ℝ)⁻¹ • (∑ j, (v k (s j) - vectorAvg p (v k))) := by
    rw [Finset.sum_sub_distrib]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      ← Nat.cast_smul_eq_nsmul ℝ, smul_sub, smul_smul, inv_mul_cancel₀ (ne_of_gt hmR), one_smul]
  rw [heq, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hmR]
  exact (inv_mul_lt_iff₀ hmR).mpr (by simpa [mul_comm] using hsum)

#print axioms finite_input_maurey

end FiniteProbability
end BooleanDepthResearch
