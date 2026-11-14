import NeuralGeneralization.OnlineLowerTanhCodeProjectionSharp

/-! # An exact-constant Jensen lift for support stability

The proof uses a scalar tangent inequality and finite sums, not an extra
analytic concavity hypothesis. Positive conditional radii may be arbitrarily
small. The constant K only needs to be at least four.
-/
set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

/-- Algebraic tangent bound for the concave radius profile appearing in
support stability. The selected energy is bounded by both squared radii. -/
theorem stability_profile_tangent (K A r ρ : ℝ)
    (hK : 4 ≤ K) (hA : 0 ≤ A) (hr : 0 < r) (hρ : 0 < ρ)
    (hAr : A ≤ r^2) (hAρ : A ≤ ρ^2) :
    ((K-1)*r^2+A)/(K*r) ≤
      ((K-1)*ρ^2+A)/(K*ρ) +
        (((K-1)*ρ^2-A)/(2*K*ρ^3))*(r^2-ρ^2) := by
  have hK0 : 0 < K := by linarith
  have hcross : A ≤ ρ*r := by
    rcases le_total r ρ with h | h
    · nlinarith [mul_le_mul_of_nonneg_right h hr.le]
    · nlinarith [mul_le_mul_of_nonneg_right h hρ.le]
  have hcoeff : 0 ≤ (K-1)*ρ^2*r-A*r-2*A*ρ := by
    have h1 := mul_le_mul_of_nonneg_right hAρ hr.le
    have h2 := mul_le_mul_of_nonneg_right hcross hρ.le
    have h3 := mul_le_mul_of_nonneg_right hK (mul_nonneg (sq_nonneg ρ) hr.le)
    nlinarith
  have hnonneg := mul_nonneg (sq_nonneg (ρ-r)) hcoeff
  have hden : 0 < 2*K*ρ^3*r := by positivity
  apply (le_of_sub_nonneg ?_)
  apply (nonneg_of_mul_nonneg_right ?_ hden)
  convert hnonneg using 1 <;> field_simp [hK0.ne',hr.ne',hρ.ne'] <;> ring

/-- A per-fiber support estimate lies below its common tangent. -/
theorem support_stability_tangent (K A r ρ q : ℝ)
    (hK : 4 ≤ K) (hA : 0 ≤ A) (hr : 0 < r) (hρ : 0 < ρ)
    (hAr : A ≤ r^2) (hAρ : A ≤ ρ^2)
    (hlocal : r^2-A ≤ K*r*(r-q)) :
    q ≤ ((K-1)*ρ^2+A)/(K*ρ) +
      (((K-1)*ρ^2-A)/(2*K*ρ^3))*(r^2-ρ^2) := by
  have hK0 : 0 < K := by linarith
  have hbound : q ≤ ((K-1)*r^2+A)/(K*r) := by
    apply (le_div_iff₀ (mul_pos hK0 hr)).mpr
    nlinarith
  exact hbound.trans (stability_profile_tangent K A r ρ hK hA hr hρ hAr hAρ)

/-- The tangent estimate also includes zero-radius fibers when their mass
is bounded by their radius, as it is for actual neural atoms. -/
theorem support_stability_nonnegative_tangent (K A r ρ q : ℝ)
    (hK : 4 ≤ K) (hA : 0 ≤ A) (hr : 0 ≤ r) (hρ : 0 < ρ)
    (hAr : A ≤ r^2) (hAρ : A ≤ ρ^2) (hqr : q ≤ r)
    (hlocal : r^2-A ≤ K*r*(r-q)) :
    q ≤ ((K-1)*ρ^2+A)/(K*ρ) +
      (((K-1)*ρ^2-A)/(2*K*ρ^3))*(r^2-ρ^2) := by
  by_cases hpos : 0 < r
  · exact support_stability_tangent K A r ρ q hK hA hpos hρ hAr hAρ hlocal
  have hrzero : r=0 := by linarith
  subst r
  have hAzero : A=0 := by nlinarith
  subst A
  have hK0 : 0 < K := by linarith
  have hbound : 0 ≤ (K-1)*ρ/(2*K) := by
    apply div_nonneg (mul_nonneg (by linarith) hρ.le) (by linarith)
  have heq : ((K-1)*ρ^2+0)/(K*ρ) +
      (((K-1)*ρ^2-0)/(2*K*ρ^3))*((0:ℝ)^2-ρ^2) = (K-1)*ρ/(2*K) := by
    field_simp [hK0.ne',hρ.ne']
    ring
  rw [heq]
  exact hqr.trans hbound

/-- Uniform finite averaging preserves the literal support-stability constant.
The common selected energy need not be positive. -/
theorem support_stability_finite_average {ι : Type*} [Fintype ι] [Nonempty ι]
    (K A ρ Q : ℝ) (r q : ι → ℝ)
    (hK : 4 ≤ K) (hA : 0 ≤ A) (hρ : 0 < ρ)
    (hr : ∀ i,0 < r i) (hAr : ∀ i,A ≤ (r i)^2)
    (hlocal : ∀ i,(r i)^2-A ≤ K*r i*(r i-q i))
    (henergy : (∑ i,(r i)^2)/(Fintype.card ι : ℝ)=ρ^2)
    (hQ : Q ≤ (∑ i,q i)/(Fintype.card ι : ℝ)) :
    Q ≤ ρ ∧ ρ^2-A ≤ K*ρ*(ρ-Q) := by
  have hc : (0 : ℝ) < Fintype.card ι := Nat.cast_pos.mpr Fintype.card_pos
  have hsumenergy : ∑ i,(r i)^2=(Fintype.card ι : ℝ)*ρ^2 := by
    have h := (div_eq_iff hc.ne').mp henergy
    nlinarith
  have hAρ : A ≤ ρ^2 := by
    have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hAr i)
    simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at h
    rw [hsumenergy] at h
    nlinarith
  let B := ((K-1)*ρ^2+A)/(K*ρ)
  let T := ((K-1)*ρ^2-A)/(2*K*ρ^3)
  have hsum : (∑ i,q i) ≤ (Fintype.card ι : ℝ)*B := by
    have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>
      support_stability_tangent K A (r i) ρ (q i) hK hA (hr i) hρ (hAr i) hAρ (hlocal i))
    change (∑ i,q i) ≤ ∑ i,(B+T*((r i)^2-ρ^2)) at h
    rw [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_sub_distrib] at h
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,hsumenergy,
      sub_self,mul_zero,add_zero] using h
  have hQB : Q ≤ B := hQ.trans ((div_le_iff₀ hc).mpr (by simpa only [mul_comm] using hsum))
  have hK0 : 0 < K := by linarith
  have hQB' : Q*(K*ρ) ≤ (K-1)*ρ^2+A := (le_div_iff₀ (mul_pos hK0 hρ)).mp hQB
  have hQρ : Q ≤ ρ := by
    apply (mul_le_mul_iff_left₀ (mul_pos hK0 hρ)).mp
    nlinarith
  exact ⟨hQρ,by nlinarith⟩

/-- The same exact-constant averaging result allowing zero-radius fibers. -/
theorem support_stability_finite_average_nonnegative {ι : Type*} [Fintype ι] [Nonempty ι]
    (K A ρ Q : ℝ) (r q : ι → ℝ)
    (hK : 4 ≤ K) (hA : 0 ≤ A) (hρ : 0 ≤ ρ)
    (hr : ∀ i,0 ≤ r i) (hAr : ∀ i,A ≤ (r i)^2) (hqr : ∀ i,q i ≤ r i)
    (hlocal : ∀ i,(r i)^2-A ≤ K*r i*(r i-q i))
    (henergy : (∑ i,(r i)^2)/(Fintype.card ι : ℝ)=ρ^2)
    (hQ : Q ≤ (∑ i,q i)/(Fintype.card ι : ℝ)) :
    Q ≤ ρ ∧ ρ^2-A ≤ K*ρ*(ρ-Q) := by
  have hc : (0 : ℝ) < Fintype.card ι := Nat.cast_pos.mpr Fintype.card_pos
  have hsumenergy : ∑ i,(r i)^2=(Fintype.card ι : ℝ)*ρ^2 := by
    have h := (div_eq_iff hc.ne').mp henergy
    nlinarith
  by_cases hρpos : 0 < ρ
  swap
  · have hρzero : ρ=0 := le_antisymm (le_of_not_gt hρpos) hρ
    have hrzero : ∀ i,r i=0 := by
      intro i
      have hi := Finset.single_le_sum (s:=Finset.univ) (f:=fun j=>(r j)^2)
        (fun j _=>sq_nonneg _) (Finset.mem_univ i)
      rw [hsumenergy,hρzero] at hi
      nlinarith [sq_nonneg (r i)]
    have hqsum : (∑ i,q i) ≤ 0 := by
      have hs := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hqr i)
      simpa only [hrzero,Finset.sum_const_zero] using hs
    constructor
    · rw [hρzero]
      exact hQ.trans (div_nonpos_of_nonpos_of_nonneg hqsum hc.le)
    · rw [hρzero]
      nlinarith
  clear hρ
  have hρ := hρpos
  have hAρ : A ≤ ρ^2 := by
    have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hAr i)
    simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at h
    rw [hsumenergy] at h
    nlinarith
  let B := ((K-1)*ρ^2+A)/(K*ρ)
  let T := ((K-1)*ρ^2-A)/(2*K*ρ^3)
  have hsum : (∑ i,q i) ≤ (Fintype.card ι : ℝ)*B := by
    have h := Finset.sum_le_sum (s:=Finset.univ) (fun i _=>
      support_stability_nonnegative_tangent K A (r i) ρ (q i) hK hA (hr i) hρ (hAr i) hAρ (hqr i) (hlocal i))
    change (∑ i,q i) ≤ ∑ i,(B+T*((r i)^2-ρ^2)) at h
    rw [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_sub_distrib] at h
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,hsumenergy,
      sub_self,mul_zero,add_zero] using h
  have hQB : Q ≤ B := hQ.trans ((div_le_iff₀ hc).mpr (by simpa only [mul_comm] using hsum))
  have hK0 : 0 < K := by linarith
  have hQB' : Q*(K*ρ) ≤ (K-1)*ρ^2+A := (le_div_iff₀ (mul_pos hK0 hρ)).mp hQB
  have hQρ : Q ≤ ρ := by
    apply (mul_le_mul_iff_left₀ (mul_pos hK0 hρ)).mp
    nlinarith
  exact ⟨hQρ,by nlinarith⟩

end NeuralGeneralization.OnlineLowerTanh
