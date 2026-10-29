import ScalarBellmanConsequences

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

lemma reciprocal_drift {q r e : ℝ} (hq : 0<q) (hr : 0<r)
    (hd : r-q≤-driftDissipation*q^2+e/driftRate) :
    driftDissipation≤e/(driftRate*q^2)+1/r-1/q := by
  have hrq : 1/q-1/r≤(r-q)/q^2 := by
    have hh : 0≤(r-q)^2/(q^2*r) := by positivity
    have hid : (r-q)/q^2-(1/q-1/r)=(r-q)^2/(q^2*r) := by
      field_simp
    linarith
  have hdiv : driftDissipation≤e/(driftRate*q^2)-(r-q)/q^2 := by
    have hm : driftDissipation*q^2≤e/driftRate-(r-q) := by linarith
    have hh := (le_div_iff₀ (sq_pos_of_pos hq)).mpr hm
    have hid : (e/driftRate-(r-q))/q^2=e/(driftRate*q^2)-(r-q)/q^2 := by
      rw [sub_div,div_div]
    rwa [hid] at hh
  linarith

/-- Reciprocal occupation for a finite interval with positive states.
The entropy is charged with its actual drift coefficient. -/
theorem reciprocal_occupation (m : ℕ) (q e : ℕ → ℝ) {u : ℝ}
    (hu : 0<u) (hq : ∀j≤m,0<q j) (he : ∀j<m,0≤e j)
    (hlo : ∀j<m,u≤q j)
    (hd : ∀j<m,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate) :
    driftDissipation*(m:ℝ)≤
      (∑j ∈ Finset.range m,e j)/(driftRate*u^2)+1/q m-1/q 0 := by
  induction m with
  | zero => simp
  | succ m ih =>
    have hi := ih (fun j hj => hq j (by omega)) (fun j hj => he j (by omega))
      (fun j hj => hlo j (by omega)) (fun j hj => hd j (by omega))
    have hs := reciprocal_drift (hq m (by omega)) (hq (m+1) le_rfl)
      (hd m (Nat.lt_succ_self m))
    have hm : e m/(driftRate*(q m)^2)≤e m/(driftRate*u^2) := by
      apply div_le_div_of_nonneg_left (he m (by omega)) (mul_pos driftRate_pos (sq_pos_of_pos hu))
      exact mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hu.le (hlo m (by omega)) 2) driftRate_pos.le
    rw [Finset.sum_range_succ,add_div,Nat.cast_add,Nat.cast_one]
    linarith

/-- If also the endpoint is above u, reciprocal occupation has a bound using
only the interval entropy and the lower variance scale. -/
theorem interval_length_bound (m : ℕ) (q e : ℕ → ℝ) {u : ℝ}
    (hu : 0<u) (hq : ∀j≤m,u≤q j) (he : ∀j<m,0≤e j)
    (hd : ∀j<m,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate) :
    driftDissipation*(m:ℝ)≤
      (∑j ∈ Finset.range m,e j)/(driftRate*u^2)+1/u := by
  have hh := reciprocal_occupation m q e hu (fun j hj => hu.trans_le (hq j hj)) he
    (fun j hj => hq j (by omega)) hd
  have hend : 1/q m≤1/u := one_div_le_one_div_of_le hu (hq m le_rfl)
  have hstart : 0<1/q 0 := by exact one_div_pos.mpr (hu.trans_le (hq 0 (by omega)))
  linarith

lemma sum_sqrt_sq_le (m : ℕ) (e : ℕ → ℝ) (he : ∀j<m,0≤e j) :
    (∑j ∈ Finset.range m,Real.sqrt (e j))^2≤
      (m:ℝ)*(∑j ∈ Finset.range m,e j) := by
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (Finset.range m)
    (fun _ => (1:ℝ)) (fun j => Real.sqrt (e j))
  simp only [one_mul,one_pow,Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_one] at hh
  have hid : (∑j ∈ Finset.range m,(Real.sqrt (e j))^2)=∑j ∈ Finset.range m,e j := by
    apply Finset.sum_congr rfl
    intro j hj
    exact Real.sq_sqrt (he j (Finset.mem_range.mp hj))
  rwa [hid] at hh

/-- A band with O(u) entropy and all states at least u costs only O(1)
in accumulated square-root entropy, independently of its duration. -/
theorem interval_sqrt_cost_bound (m : ℕ) (q e : ℕ → ℝ) {u K : ℝ}
    (hu : 0<u) (hK : 0≤K) (hq : ∀j≤m,u≤q j) (he : ∀j<m,0≤e j)
    (hd : ∀j<m,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hcost : (∑j ∈ Finset.range m,e j)≤K*u) :
    (∑j ∈ Finset.range m,Real.sqrt (e j))≤
      Real.sqrt ((K/driftRate+1)*K/driftDissipation) := by
  have hlen := interval_length_bound m q e hu hq he hd
  have hlen' : driftDissipation*(m:ℝ)*u≤K/driftRate+1 := by
    have hh := mul_le_mul_of_nonneg_right hlen hu.le
    have hc := div_le_div_of_nonneg_right hcost (mul_nonneg driftRate_pos.le (sq_nonneg u))
    have hh' := mul_le_mul_of_nonneg_right hc hu.le
    have hid : (K*u/(driftRate*u^2)+1/u)*u=K/driftRate+1 := by
      field_simp
    nlinarith
  have hs := sum_sqrt_sq_le m e he
  have heprod := mul_le_mul_of_nonneg_left hcost (Nat.cast_nonneg m : (0:ℝ)≤m)
  have hnum := mul_le_mul_of_nonneg_right hlen' hK
  apply Real.le_sqrt_of_sq_le
  apply (le_div_iff₀ driftDissipation_pos).mpr
  have hp := mul_le_mul_of_nonneg_right (hs.trans heprod) driftDissipation_pos.le
  nlinarith

#print axioms reciprocal_occupation
#print axioms interval_sqrt_cost_bound
end ConditionalNonpolynomial.Analytic
