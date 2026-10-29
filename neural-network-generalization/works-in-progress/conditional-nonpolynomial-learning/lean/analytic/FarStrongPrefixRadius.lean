import FarStrongCanonicalPrefix

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem full_gain_times_normalized_prefix (α b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    (hα:∀j<J,α j≠0) :
    (∏j∈Finset.range H,α j)*(∏j∈Finset.range J,b j/α j)=
      (∏j∈Finset.range J,b j)*(∏j∈Finset.range (H-J),α (J+j)) := by
  have he := Finset.prod_range_add α J (H-J)
  rw [Nat.add_sub_of_le hJ] at he
  rw [he,Finset.prod_div_distrib]
  have hp : (∏j∈Finset.range J,α j)≠0 :=
    Finset.prod_ne_zero_iff.mpr fun j hj=>hα j (Finset.mem_range.mp hj)
  field_simp

theorem farStrong_normalized_radius_bound (D b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    {t a R E:ℝ} (ht:0<t) (ha:1/4≤a) (hta:t^2*(a+1)=1) (hR:0≤R)
    (hD:∀j<H,0≤D j) (hb:∀j<J,0<b j)
    (hball:∀j<J,Real.log (b j)≤(D j-twoBallEntropyBaseline a-twoBallEntropyGap a)/a)
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*twoBallEntropyBaseline a≤E) :
    sharpFiniteProduct t D H*(2*R*∏j∈Finset.range J,b j/sharpFiniteGain t D j)≤
      2*R*Real.exp (E/a-(J:ℝ)/40) := by
  have he : sharpFiniteProduct t D H*(2*R*∏j∈Finset.range J,b j/sharpFiniteGain t D j)=
      2*R*((∏j∈Finset.range J,b j)*(∏j∈Finset.range (H-J),sharpFiniteGain t D (J+j))) := by
    rw [←full_gain_times_normalized_prefix (sharpFiniteGain t D) b H J hJ
      (fun j _=>(sharpFiniteGain_pos ht D j).ne')]
    dsimp [sharpFiniteProduct]
    ring
  rw [he]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  exact mixed_two_ball_uniform_product D (sharpFiniteGain t D) b H J hJ a E ha
    (fun j _=>sharpFiniteGain_pos ht D j) hb
    (fun j hj=>sharp_physical_gain_tangent (by linarith) ht (hD j hj) hta)
    hball hbudget

/-- A logarithmic number of covered rows makes the final readout radius
small, with constants uniform throughout a≥1/4. -/
theorem farStrong_readout_radius_small (D b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    {t a R E W ε:ℝ} (ht:0<t) (ha:1/4≤a) (hta:t^2*(a+1)=1)
    (hR:0<R) (hW:0<W) (hε:0<ε)
    (hD:∀j<H,0≤D j) (hb:∀j<J,0<b j)
    (hball:∀j<J,Real.log (b j)≤(D j-twoBallEntropyBaseline a-twoBallEntropyGap a)/a)
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*twoBallEntropyBaseline a≤E)
    (hJlarge:40*(E/a+Real.log (2*R*W/ε))≤(J:ℝ)) :
    (W*sharpFiniteProduct t D H)*(2*R*∏j∈Finset.range J,b j/sharpFiniteGain t D j)≤ε := by
  have hbnd := farStrong_normalized_radius_bound D b H J hJ ht ha hta hR.le hD hb hball hbudget
  have hh := mul_le_mul_of_nonneg_left hbnd hW.le
  have hex : E/a-(J:ℝ)/40≤ -Real.log (2*R*W/ε) := by linarith
  have hnum : 0<2*R*W/ε := by positivity
  have he := Real.exp_le_exp.mpr hex
  rw [Real.exp_neg,Real.exp_log hnum] at he
  have hm := mul_le_mul_of_nonneg_left he (by positivity : 0≤W*(2*R))
  have hid : W*(2*R)*(2*R*W/ε)⁻¹=ε := by field_simp
  rw [hid] at hm
  nlinarith only [hh,hm]

#print axioms farStrong_readout_radius_small
end ConditionalNonpolynomial.Analytic
