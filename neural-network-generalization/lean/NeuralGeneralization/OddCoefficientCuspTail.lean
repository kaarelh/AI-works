import NeuralGeneralization.OddCoefficientTail

/-! Elementary two-scale Tauberian bounds: an endpoint power cusp gives
matching coefficient-tail powers. No differentiability is required. -/
noncomputable section
namespace NeuralGeneralization

lemma exists_small_power_scale {β A B : ℝ} (hβ1 : β < 1)
    (hA : 0 < A) (hB : 0 < B) :
    ∃ δ : ℝ,0 < δ ∧ δ ≤ 1 ∧ A*δ ≤ B*δ^β := by
  let q := min (1 : ℝ) (B/A)
  have hq : 0 < q := lt_min (by norm_num) (div_pos hB hA)
  have hq1 : q ≤ 1 := min_le_left _ _
  let δ := q^(1/(1-β))
  have hδ : 0 < δ := Real.rpow_pos_of_pos hq _
  have hβ : 0 < 1-β := by linarith
  have hδ1 : δ ≤ 1 := Real.rpow_le_one hq.le hq1 (by positivity)
  have he : δ^(1-β)=q := by
    dsimp [δ]
    rw [← Real.rpow_mul hq.le,one_div_mul_cancel (ne_of_gt hβ),Real.rpow_one]
  have hδsplit : δ=δ^β*δ^(1-β) := by
    rw [← Real.rpow_add hδ,show β+(1-β)=1 by ring,Real.rpow_one]
  refine ⟨δ,hδ,hδ1,?_⟩
  calc
    A*δ = A*(δ^β*q) := by rw [← he,← hδsplit]
    _ ≤ A*(δ^β*(B/A)) := by
      gcongr
      exact min_le_right _ _
    _ = B*δ^β := by field_simp

lemma reciprocal_double_rpow {n : ℕ} (hn : 0 < n) (β : ℝ) :
    (1/(2*n : ℝ))^β=(2 : ℝ)^(-β)*(n : ℝ)^(-β) := by
  have hn0 : 0 ≤ (n : ℝ) := by positivity
  rw [one_div,Real.inv_rpow (by positivity : (0 : ℝ) ≤ 2*n),
    Real.mul_rpow (by norm_num : (0 : ℝ) ≤ 2) hn0,mul_inv_rev,
    Real.rpow_neg hn0,Real.rpow_neg (by norm_num : (0 : ℝ) ≤ 2)]
  ring

/-- A true endpoint power cusp implies matching power bounds for all
positive coefficient cutoffs. -/
theorem oddSeries_cusp_tail_bounds {b : ℕ → ℝ} (hb : ∀ m,0 ≤ b m)
    (hs : Summable b) {β c C : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1)
    (hc : 0 < c) (hC : 0 < C)
    (hcusp : ∀ t : ℝ,0 < t → t ≤ 1 →
      c*t^β ≤ oddSeriesDeficit b t ∧ oddSeriesDeficit b t ≤ C*t^β) :
    ∃ c' C' : ℝ,0 < c' ∧ 0 < C' ∧ ∀ n : ℕ,0 < n →
      c'*(n : ℝ)^(-β) ≤ coefficientTail b n ∧
      coefficientTail b n ≤ C'*(n : ℝ)^(-β) := by
  obtain ⟨δ,hδ,hδ1,hsmall⟩ := exists_small_power_scale hβ1
    (mul_pos (Real.exp_pos 1) hC) (half_pos hc)
  let q := 1-Real.exp (-1)
  have hq : 0 < q := by
    have hh : Real.exp (-1) < 1 := by rw [Real.exp_lt_one_iff]; norm_num
    dsimp [q]
    linarith
  let low := (c/2)*δ^β*(2 : ℝ)^(-β)
  let up := C*(2 : ℝ)^(-β)/q
  have hlo : 0 < low := by dsimp [low]; positivity
  have hup : 0 < up := by dsimp [up]; positivity
  refine ⟨low,up,hlo,hup,?_⟩
  intro n hn
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hn0 : 0 < (n : ℝ) := by linarith
  have hd : 0 < (2*n : ℝ) := by positivity
  have ht : 0 < 1/(2*n : ℝ) := by positivity
  have ht1 : 1/(2*n : ℝ) ≤ 1 := (div_le_one hd).mpr (by linarith)
  have htδ : 0 < δ/(2*n : ℝ) := div_pos hδ hd
  have htδ1 : δ/(2*n : ℝ) ≤ 1 := (div_le_one hd).mpr (by linarith)
  have hbase := hcusp (1/(2*n : ℝ)) ht ht1
  have hscaled := hcusp (δ/(2*n : ℝ)) htδ htδ1
  rw [reciprocal_double_rpow hn β] at hbase
  have hscale : (δ/(2*n : ℝ))^β=δ^β*(2 : ℝ)^(-β)*(n : ℝ)^(-β) := by
    rw [div_eq_mul_one_div,Real.mul_rpow hδ.le (by positivity),reciprocal_double_rpow hn β]
    ring
  rw [hscale] at hscaled
  constructor
  · have htwo := oddSeriesDeficit_two_scale hb hs hn hδ.le
    have hmult := mul_le_mul_of_nonneg_left hbase.2
      (mul_nonneg (Real.exp_pos 1).le hδ.le)
    have hsmall' := mul_le_mul_of_nonneg_right hsmall
      (mul_nonneg (Real.rpow_nonneg (by norm_num : (0 : ℝ) ≤ 2) (-β))
        (Real.rpow_nonneg hn0.le (-β)))
    dsimp [low]
    nlinarith only [htwo,hmult,hscaled.1,hsmall']
  · have hupper := coefficientTail_le_deficit hb hs hn
    change q*coefficientTail b n ≤ _ at hupper
    change coefficientTail b n ≤ (C*(2 : ℝ)^(-β)/q)*(n : ℝ)^(-β)
    rw [div_mul_eq_mul_div]
    apply (le_div_iff₀ hq).mpr
    change coefficientTail b n*q ≤ C*(2 : ℝ)^(-β)*(n : ℝ)^(-β)
    have hh := hupper.trans hbase.2
    simpa only [mul_comm,mul_left_comm,mul_assoc] using hh

end NeuralGeneralization
