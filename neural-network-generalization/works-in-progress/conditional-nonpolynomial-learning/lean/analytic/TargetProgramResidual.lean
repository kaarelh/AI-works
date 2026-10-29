import TargetProgramLogarithms

noncomputable section
namespace ConditionalNonpolynomial.Analytic

def targetResidual (p : ℝ) (H : ℕ) : ℝ := p/((H:ℝ)+1)^3

theorem four_mul_le_cube_successor (H : ℕ) : 4*(H:ℝ)≤((H:ℝ)+1)^3 := by
  have hH : 0≤(H:ℝ) := Nat.cast_nonneg _
  have hsq : 4*(H:ℝ)≤((H:ℝ)+1)^2 := by nlinarith [sq_nonneg ((H:ℝ)-1)]
  have hprod := mul_nonneg hH (sq_nonneg ((H:ℝ)+1))
  nlinarith

theorem targetResidual_bounds {p : ℝ} (hp : 0<p) (hp1 : p≤1/256) {H m : ℕ} (hm : m≤H) :
    0<targetResidual p H ∧ targetResidual p H<1 ∧ 4*(m:ℝ)*targetResidual p H≤p := by
  have hH : 1≤(H:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) H]
  have hc : 1≤((H:ℝ)+1)^3 := one_le_pow₀ hH
  have hδp : targetResidual p H≤p := (div_le_self hp.le hc)
  refine ⟨by unfold targetResidual; positivity,lt_of_le_of_lt hδp (lt_of_le_of_lt hp1 (by norm_num)),?_⟩
  have hmR : (m:ℝ)≤(H:ℝ) := by exact_mod_cast hm
  have hnum : 4*(m:ℝ)≤((H:ℝ)+1)^3 := by linarith [four_mul_le_cube_successor H]
  unfold targetResidual
  rw [← mul_div_assoc]
  apply (div_le_iff₀ (by positivity)).mpr
  nlinarith [mul_le_mul_of_nonneg_right hnum hp.le]

theorem targetProgram_cost_bound {p baseline nominal R : ℝ} {H m : ℕ}
    (hp : 0<p) (hp1 : p≤1/256) (hHp : 1≤(H:ℝ)*p) (hm : m≤H)
    (hb0 : 0≤baseline) (hb : baseline≤257) (hn : nominal≤baseline+p) (hR : R≤(H:ℝ)) :
    256*R*p^2+(1+4*(m:ℝ)*targetResidual p H)*nominal ≤ baseline+1024*(H:ℝ)*p^2 := by
  have hd := targetResidual_bounds hp hp1 hm
  have hfac : 0≤1+4*(m:ℝ)*targetResidual p H := by
    nlinarith [mul_nonneg (Nat.cast_nonneg (α := ℝ) m) hd.1.le]
  have hstep := mul_le_mul_of_nonneg_left hn hfac
  have hbig := mul_le_mul_of_nonneg_right (show 1+4*(m:ℝ)*targetResidual p H≤1+p by linarith)
    (add_nonneg hb0 hp.le)
  have hpH := mul_le_mul_of_nonneg_right hHp hp.le
  have hRp := mul_le_mul_of_nonneg_right hR (sq_nonneg p)
  have hbp := mul_le_mul_of_nonneg_right hb hp.le
  have hp2 : p^2≤p := by nlinarith
  nlinarith

#print axioms targetProgram_cost_bound
end ConditionalNonpolynomial.Analytic
