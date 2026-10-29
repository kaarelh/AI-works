import ScalarOccupation

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

/-- Last visit to a variance sublevel, with zero as a harmless default if
there was no such visit. -/
def lastExit (q : ℕ → ℝ) (H : ℕ) (u : ℝ) : ℕ := by
  classical
  exact (insert 0 ((Finset.range (H+1)).filter fun j => q j≤u)).max' (by simp)

lemma lastExit_le (q : ℕ → ℝ) (H : ℕ) (u : ℝ) : lastExit q H u≤H := by
  classical
  unfold lastExit
  apply Finset.max'_le
  intro j hj
  rcases Finset.mem_insert.mp hj with rfl | hj
  · omega
  · exact Nat.le_of_lt_succ (Finset.mem_range.mp (Finset.mem_filter.mp hj).1)

lemma le_lastExit {q : ℕ → ℝ} {H j : ℕ} {u : ℝ} (hj : j≤H) (hqu : q j≤u) :
    j≤lastExit q H u := by
  classical
  unfold lastExit
  apply Finset.le_max'
  exact Finset.mem_insert_of_mem (Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega),hqu⟩)

lemma lastExit_state {q : ℕ → ℝ} {H : ℕ} {u : ℝ} (hp : 0<lastExit q H u) :
    q (lastExit q H u)≤u := by
  classical
  have hm := Finset.max'_mem (insert 0 ((Finset.range (H+1)).filter fun j => q j≤u)) (by simp)
  change lastExit q H u∈_ at hm
  rcases Finset.mem_insert.mp hm with hz | hm
  · omega
  · exact (Finset.mem_filter.mp hm).2

lemma after_lastExit {q : ℕ → ℝ} {H j : ℕ} {u : ℝ}
    (hj : j≤H) (hl : lastExit q H u<j) : u<q j := by
  by_contra hh
  exact Nat.not_lt_of_ge (le_lastExit hj (le_of_not_gt hh)) hl

lemma lastExit_mono {q : ℕ → ℝ} {H : ℕ} {u v : ℝ} (huv : u≤v) :
    lastExit q H u≤lastExit q H v := by
  by_cases hp : 0<lastExit q H u
  · exact le_lastExit (lastExit_le q H u) ((lastExit_state hp).trans huv)
  · omega

lemma lastExit_eq_end {q : ℕ → ℝ} {H : ℕ} {u : ℝ} (h : q H≤u) :
    lastExit q H u=H := le_antisymm (lastExit_le q H u) (le_lastExit le_rfl h)

lemma sum_segment_eq (f : ℕ → ℝ) {s t : ℕ} (hst : s≤t) :
    (∑j ∈ Finset.range (t-s),f (s+j))=
      (∑j ∈ Finset.range t,f j)-(∑j ∈ Finset.range s,f j) := by
  have hh := Finset.sum_range_add f s (t-s)
  rw [Nat.add_sub_of_le hst] at hh
  linarith

lemma sum_segment_le_prefix (e : ℕ → ℝ) {s t : ℕ} (hst : s≤t)
    (he : ∀j<t,0≤e j) :
    (∑j ∈ Finset.range (t-s),e (s+j))≤∑j ∈ Finset.range t,e j := by
  rw [sum_segment_eq e hst]
  have hh : 0≤∑j ∈ Finset.range s,e j := Finset.sum_nonneg fun j hj =>
    he j (lt_of_lt_of_le (Finset.mem_range.mp hj) hst)
  linarith

/-- A transition interval may begin below u; discarding its first transition
leaves all states above u. Bounded total interval entropy then gives a uniform
square-root-cost bound, including the discarded transition. -/
theorem lastExit_block_sqrt_bound (H s t : ℕ) (q e : ℕ → ℝ) {u K : ℝ}
    (hst : s<t) (htH : t≤H) (hu : 0<u) (hu1 : u≤1) (hK : 0≤K)
    (he : ∀j<H,0≤e j)
    (hstates : ∀j, s<j → j≤t → u≤q j)
    (hd : ∀j<H,q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hcost : (∑j ∈ Finset.range t,e j)≤K*u) :
    (∑j ∈ Finset.range (t-s),Real.sqrt (e (s+j)))≤
      Real.sqrt (((K/driftRate+1)/driftDissipation+1)*K) := by
  let n := t-(s+1)
  have hn : s+1+n=t := by dsimp [n]; omega
  have hlen := interval_length_bound n (fun j => q (s+1+j)) (fun j => e (s+1+j)) hu
    (fun j hj => hstates (s+1+j) (by omega) (by omega))
    (fun j hj => he (s+1+j) (by omega))
    (fun j hj => by simpa only [Nat.add_assoc] using hd (s+1+j) (by omega))
  have hcostn : (∑j ∈ Finset.range n,e (s+1+j))≤K*u := by
    have hh := sum_segment_le_prefix e (show s+1≤t by omega) (fun j hj => he j (by omega))
    exact hh.trans hcost
  have hlen' : driftDissipation*(n:ℝ)*u≤K/driftRate+1 := by
    have hc := div_le_div_of_nonneg_right hcostn (mul_nonneg driftRate_pos.le (sq_nonneg u))
    have hh := mul_le_mul_of_nonneg_right (hlen.trans (add_le_add hc le_rfl)) hu.le
    have hid : (K*u/(driftRate*u^2)+1/u)*u=K/driftRate+1 := by field_simp
    rw [hid] at hh
    exact hh
  have hnn : t-s=n+1 := by dsimp [n]; omega
  have hncast : (t-s:ℕ)=(n+1:ℕ) := hnn
  have hm : ((t-s:ℕ):ℝ)*u≤(K/driftRate+1)/driftDissipation+1 := by
    have hh : (n:ℝ)*u≤(K/driftRate+1)/driftDissipation :=
      (le_div_iff₀ driftDissipation_pos).mpr (by nlinarith [hlen'])
    rw [hncast,Nat.cast_add,Nat.cast_one]
    nlinarith
  have hseg := (sum_segment_le_prefix e (Nat.le_of_lt hst) (fun j hj => he j (by omega))).trans hcost
  have hs := sum_sqrt_sq_le (t-s) (fun j => e (s+j)) (fun j hj => he (s+j) (by omega))
  have hp := mul_le_mul_of_nonneg_left hseg (Nat.cast_nonneg (t-s) : (0:ℝ)≤(t-s:ℕ))
  have hkm := mul_le_mul_of_nonneg_right hm hK
  apply Real.le_sqrt_of_sq_le
  nlinarith

#print axioms lastExit_block_sqrt_bound
end ConditionalNonpolynomial.Analytic
