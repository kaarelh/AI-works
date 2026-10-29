import TwoBallEntropyGap
import ExternalCoverIteration

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem mixed_two_ball_log_bound (D α b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    (a c δ:ℝ) (ha:0<a)
    (hα:∀j<H,0<α j) (hb:∀j<J,0<b j)
    (hgain:∀j<H,Real.log (α j)≤(D j-c)/a)
    (hball:∀j<J,Real.log (b j)≤(D j-c-δ)/a) :
    Real.log ((∏j∈Finset.range J,b j)*
      (∏j∈Finset.range (H-J),α (J+j)))≤
        ((∑j∈Finset.range H,D j)-(H:ℝ)*c-(J:ℝ)*δ)/a := by
  have hp : 0<∏j∈Finset.range J,b j :=
    Finset.prod_pos fun j hj=>hb j (Finset.mem_range.mp hj)
  have hq : 0<∏j∈Finset.range (H-J),α (J+j) :=
    Finset.prod_pos fun j hj=>hα (J+j) (by have hh:=Finset.mem_range.mp hj; omega)
  rw [Real.log_mul hp.ne' hq.ne',Real.log_prod (fun j hj=>(hb j (Finset.mem_range.mp hj)).ne'),
    Real.log_prod (fun j hj=>(hα (J+j) (by have hh:=Finset.mem_range.mp hj; omega)).ne')]
  have h1 := Finset.sum_le_sum (s:=Finset.range J) (fun j hj=>hball j (Finset.mem_range.mp hj))
  have h2 := Finset.sum_le_sum (s:=Finset.range (H-J)) (fun j hj=>hgain (J+j)
    (by have hh:=Finset.mem_range.mp hj; omega))
  have he := Finset.sum_range_add D J (H-J)
  rw [Nat.add_sub_of_le hJ] at he
  have hcast : ((H-J:ℕ):ℝ)=(H:ℝ)-(J:ℝ) := Nat.cast_sub hJ
  simp only [←Finset.sum_div,Finset.sum_sub_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul] at h1 h2
  apply (add_le_add h1 h2).trans_eq
  rw [he,hcast]
  ring

theorem mixed_two_ball_product_bound (D α b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    (a c δ E:ℝ) (ha:0<a)
    (hα:∀j<H,0<α j) (hb:∀j<J,0<b j)
    (hgain:∀j<H,Real.log (α j)≤(D j-c)/a)
    (hball:∀j<J,Real.log (b j)≤(D j-c-δ)/a)
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*c≤E) :
    (∏j∈Finset.range J,b j)*(∏j∈Finset.range (H-J),α (J+j))≤
      Real.exp (E/a-(J:ℝ)*δ/a) := by
  have hp : 0<(∏j∈Finset.range J,b j)*(∏j∈Finset.range (H-J),α (J+j)) :=
    mul_pos (Finset.prod_pos fun j hj=>hb j (Finset.mem_range.mp hj))
      (Finset.prod_pos fun j hj=>hα (J+j) (by have hh:=Finset.mem_range.mp hj; omega))
  rw [←Real.exp_log hp]
  apply Real.exp_le_exp.mpr
  apply (mixed_two_ball_log_bound D α b H J hJ a c δ ha hα hb hgain hball).trans
  rw [←sub_div]
  exact div_le_div_of_nonneg_right (by linarith) ha.le

theorem mixed_two_ball_uniform_product (D α b:ℕ→ℝ) (H J:ℕ) (hJ:J≤H)
    (a E:ℝ) (ha:1/4≤a)
    (hα:∀j<H,0<α j) (hb:∀j<J,0<b j)
    (hgain:∀j<H,Real.log (α j)≤(D j-twoBallEntropyBaseline a)/a)
    (hball:∀j<J,Real.log (b j)≤(D j-twoBallEntropyBaseline a-twoBallEntropyGap a)/a)
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*twoBallEntropyBaseline a≤E) :
    (∏j∈Finset.range J,b j)*(∏j∈Finset.range (H-J),α (J+j))≤
      Real.exp (E/a-(J:ℝ)/40) := by
  have hap : 0<a := by linarith
  apply (mixed_two_ball_product_bound D α b H J hJ a (twoBallEntropyBaseline a)
    (twoBallEntropyGap a) E hap hα hb hgain hball hbudget).trans
  apply Real.exp_le_exp.mpr
  have hh := mul_le_mul_of_nonneg_left (twoBallEntropyGap_uniform ha) (Nat.cast_nonneg J)
  have hh' : (J:ℝ)/40≤(J:ℝ)*twoBallEntropyGap a/a := by
    convert hh using 1 <;> first | rfl | ring
  linarith

#print axioms mixed_two_ball_uniform_product
end ConditionalNonpolynomial.Analytic
