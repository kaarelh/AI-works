import ScalarIncreasingPath

/-! Near-optimal actual scalar paths have O(1/p) length after monotonization.
The bound follows from the actual KL drift and Bellman prefix bound. It is not
an assumed short-path or resource certificate. -/

noncomputable section
set_option maxHeartbeats 3000000
open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory InformationTheory

namespace ConditionalNonpolynomial.Analytic

def scalarBandLengthConstant (C : ℝ) : ℝ :=
  ((1+2*C)/driftRate+1)/driftDissipation+1

theorem scalarBandLengthConstant_pos {C : ℝ} (hC : 0 ≤ C) :
    0 < scalarBandLengthConstant C := by
  unfold scalarBandLengthConstant
  have hr := driftRate_pos
  have hd := driftDissipation_pos
  positivity

theorem lastExit_block_length (H s t : ℕ) (q e : ℕ → ℝ) {u K : ℝ}
    (hst : s < t) (htH : t ≤ H) (hu : 0 < u) (hu1 : u ≤ 1) (hK : 0 ≤ K)
    (he : ∀ j < H, 0 ≤ e j)
    (hstates : ∀ j, s < j → j ≤ t → u ≤ q j)
    (hd : ∀ j < H, q (j+1)-q j ≤ -driftDissipation*(q j)^2+e j/driftRate)
    (hcost : (∑ j ∈ Finset.range t, e j) ≤ K*u) :
    ((t-s : ℕ) : ℝ)*u ≤ (K/driftRate+1)/driftDissipation+1 := by
  let n := t-(s+1)
  have hlen := interval_length_bound n (fun j => q (s+1+j)) (fun j => e (s+1+j)) hu
    (fun j hj => hstates (s+1+j) (by omega) (by omega))
    (fun j hj => he (s+1+j) (by omega))
    (fun j hj => by simpa only [Nat.add_assoc] using hd (s+1+j) (by omega))
  have hcostn : (∑ j ∈ Finset.range n, e (s+1+j)) ≤ K*u := by
    exact (sum_segment_le_prefix e (show s+1 ≤ t by omega)
      (fun j hj => he j (by omega))).trans hcost
  have hdiv := div_le_div_of_nonneg_right hcostn
    (mul_nonneg driftRate_pos.le (sq_nonneg u))
  have hmul := mul_le_mul_of_nonneg_right (hlen.trans (add_le_add hdiv le_rfl)) hu.le
  have heq : (K*u/(driftRate*u^2)+1/u)*u = K/driftRate+1 := by field_simp
  rw [heq] at hmul
  have hn : (n : ℝ)*u ≤ (K/driftRate+1)/driftDissipation := by
    apply (le_div_iff₀ driftDissipation_pos).mpr
    nlinarith only [hmul]
  have hncast : ((t-s : ℕ) : ℝ) = (n : ℝ)+1 := by
    have hnat : t-s=n+1 := by dsimp [n]; omega
    exact_mod_cast hnat
  rw [hncast]
  nlinarith

/-- A positive variance floor and the baseline-derived prefix budget force
O(1/p) total steps. No monotonicity is needed once the floor is supplied. -/
theorem floor_path_length_bound (H J : ℕ) (q e : ℕ → ℝ) {p ε C : ℝ}
    (hp : 0 < p) (hε : 0 ≤ ε) (hεp : ε ≤ p) (hC : 0 ≤ C)
    (hreach : 1 ≤ (2 : ℝ)^J*p)
    (hqlo : ∀ j ≤ H, p ≤ q j) (hqhi : ∀ j ≤ H, q j ≤ 1)
    (he : ∀ j < H, 0 ≤ e j)
    (hd : ∀ j < H, q (j+1)-q j ≤ -driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀ i ≤ H, (∑ j ∈ Finset.range i, e j) ≤ ε+C*q i) :
    (H : ℝ)*p ≤ 3*scalarBandLengthConstant C := by
  let u : ℕ → ℝ := fun j => (2 : ℝ)^j*p
  let τ : ℕ → ℕ := fun j => lastExit q H (u j)
  let D := scalarBandLengthConstant C
  have hD : 0 ≤ D := (scalarBandLengthConstant_pos hC).le
  have hu (j : ℕ) : 0 < u j := by dsimp [u]; positivity
  have hu0 : u 0 = p := by simp [u]
  have husucc (j : ℕ) : u (j+1) = 2*u j := by dsimp [u]; rw [pow_succ]; ring
  have hueps (j : ℕ) : ε ≤ u j := by
    have hpow : (1 : ℝ) ≤ 2^j := one_le_pow₀ (by norm_num)
    have hm := mul_le_mul_of_nonneg_right hpow hp.le
    dsimp [u]
    linarith
  have htH (j : ℕ) : τ j ≤ H := lastExit_le q H (u j)
  have htmono (j : ℕ) : τ j ≤ τ (j+1) := lastExit_mono (by rw [husucc]; linarith [hu j])
  have hcost0 : (∑ j ∈ Finset.range (τ 0), e j) ≤ (1+2*C)*p := by
    by_cases hpos : 0 < τ 0
    · have hq := lastExit_state hpos
      change q (τ 0) ≤ u 0 at hq
      rw [hu0] at hq
      have hpre := hprefix (τ 0) (htH 0)
      nlinarith
    · have hz : τ 0 = 0 := by omega
      rw [hz]
      simp only [Finset.range_zero, Finset.sum_empty]
      positivity
  have hstart : (τ 0 : ℝ)*p ≤ D := by
    have hlen := interval_length_bound (τ 0) q e hp
      (fun j hj => hqlo j (hj.trans (htH 0)))
      (fun j hj => he j (hj.trans_le (htH 0)))
      (fun j hj => hd j (hj.trans_le (htH 0)))
    have hdiv := div_le_div_of_nonneg_right hcost0
      (mul_nonneg driftRate_pos.le (sq_nonneg p))
    have hm := mul_le_mul_of_nonneg_right (hlen.trans (add_le_add hdiv le_rfl)) hp.le
    have heq : ((1+2*C)*p/(driftRate*p^2)+1/p)*p = (1+2*C)/driftRate+1 := by field_simp
    rw [heq] at hm
    have hh : (τ 0 : ℝ)*p ≤ ((1+2*C)/driftRate+1)/driftDissipation := by
      apply (le_div_iff₀ driftDissipation_pos).mpr
      nlinarith only [hm]
    dsimp [D, scalarBandLengthConstant]
    linarith
  have hstep (j : ℕ) : ((τ (j+1)-τ j : ℕ) : ℝ)*u j ≤ D := by
    by_cases hz : τ j = τ (j+1)
    · simp only [← hz, Nat.sub_self, Nat.cast_zero, zero_mul]
      exact hD
    · have hlt : τ j < τ (j+1) := lt_of_le_of_ne (htmono j) hz
      have hu1 : u j ≤ 1 :=
        (after_lastExit (htH (j+1)) hlt).le.trans (hqhi (τ (j+1)) (htH (j+1)))
      have hcost : (∑ k ∈ Finset.range (τ (j+1)), e k) ≤ (1+2*C)*u j := by
        have hstate := lastExit_state (show 0 < τ (j+1) by omega)
        change q (τ (j+1)) ≤ u (j+1) at hstate
        rw [husucc] at hstate
        have hpre := hprefix (τ (j+1)) (htH (j+1))
        have hep := hueps j
        nlinarith
      exact lastExit_block_length H (τ j) (τ (j+1)) q e hlt (htH (j+1)) (hu j)
        hu1 (by positivity) he
        (fun k hk hkt => (after_lastExit (hkt.trans (htH (j+1))) hk).le) hd hcost
  have hgeom (j : ℕ) : (τ j : ℝ)*p ≤ (τ 0 : ℝ)*p+2*D*(1-(1/2 : ℝ)^j) := by
    induction j with
    | zero => simp
    | succ j ih =>
      have hh := mul_le_mul_of_nonneg_right (hstep j) (by positivity : 0 ≤ (1/2 : ℝ)^j)
      have hcancel : u j*(1/2 : ℝ)^j = p := by
        dsimp [u]
        rw [mul_right_comm, ← mul_pow]
        norm_num
      rw [mul_assoc, hcancel, Nat.cast_sub (htmono j)] at hh
      rw [pow_succ]
      nlinarith only [ih, hh]
  have hfinal : τ J = H := lastExit_eq_end ((hqhi H le_rfl).trans hreach)
  have hlast := hgeom J
  rw [hfinal] at hlast
  have hnon : 0 ≤ 2*D*(1/2 : ℝ)^J := by positivity
  change (H : ℝ)*p ≤ 3*D
  nlinarith

theorem exists_dyadic_reaches {p : ℝ} (hp : 0 < p) : ∃ J : ℕ, 1 ≤ (2 : ℝ)^J*p := by
  obtain ⟨J, hJ⟩ := exists_nat_gt (1/p)
  have hpow : (J : ℝ) ≤ (2 : ℝ)^J := by exact_mod_cast (show J < 2^J from Nat.lt_two_pow_self).le
  have hmul := mul_le_mul_of_nonneg_right (hJ.le.trans hpow) hp.le
  refine ⟨J,?_⟩
  simpa only [one_div_mul_cancel hp.ne'] using hmul

/-- There is a genuine increasing path of cost <V(p)+p and length <=K/p,
where K is universal and independent of the target and all neural widths. -/
theorem exists_short_nearOptimal_scalarPath {p : ℝ} (hp : 0 < p) (hp1 : p ≤ 1) :
    ∃ P : ScalarPath p, P.Increasing ∧ P.cost < scalarValue p+p ∧
      (P.length : ℝ)*p ≤ 3*scalarBandLengthConstant 526336 := by
  obtain ⟨P,hinc,hcost⟩ := exists_increasing_nearOptimal_scalarPath hp hp
  refine ⟨P,hinc,hcost,?_⟩
  obtain ⟨J,hJ⟩ := exists_dyadic_reaches hp
  have hnear : P.cost ≤ scalarBaseline.toReal+p := by
    have hv := scalarValue_le_baseline hp
    linarith
  apply floor_path_length_bound P.length J P.state P.charge hp hp.le le_rfl (by norm_num)
    hJ (fun j _ => P.state_floor hinc j) (fun j _ => P.state_le_one hp1 j)
    (fun _ _ => ENNReal.toReal_nonneg) _ (P.nearOptimal_prefix hnear)
  intro j hj
  letI := P.control_probability j
  have hh := scalar_entropy_drift (P.control j) (P.control_finiteKL j)
    (P.state_pos j).le (P.state_le_one hp1 j)
  change scalarTransition (P.state j) (P.control j)-P.state j ≤ _ at hh
  rw [P.state_transition j hj] at hh
  exact hh

end ConditionalNonpolynomial.Analytic

#print axioms ConditionalNonpolynomial.Analytic.floor_path_length_bound
#print axioms ConditionalNonpolynomial.Analytic.exists_short_nearOptimal_scalarPath
