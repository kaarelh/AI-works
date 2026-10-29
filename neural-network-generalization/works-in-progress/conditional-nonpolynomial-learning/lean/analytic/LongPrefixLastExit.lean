import ScalarShortPath
import SubcriticalMarginGain

/-! A linear prefix remains before the last low-variance visit whenever the
network is long. The tail-length estimate uses actual adjusted charges and
does not require excess smaller than the cutoff. -/
noncomputable section
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def lastExitTailLengthConstant (C : ℝ) : ℝ :=
  1+3*scalarBandLengthConstant C+6/(driftRate*driftDissipation)

lemma lastExitTailLengthConstant_pos {C : ℝ} (hC : 0≤C) :
    0<lastExitTailLengthConstant C := by
  have h := scalarBandLengthConstant_pos hC
  have hr := driftRate_pos
  have hd := driftDissipation_pos
  unfold lastExitTailLengthConstant
  positivity

/-- The suffix above a has O(1/a+ε/a²) length. The first transition is
excluded automatically, so the original input variance may exceed one. -/
theorem truncated_lastExit_length_after_first
    (H : ℕ) (q e : ℕ→ℝ) {ε C a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (ha : 0<a) (ha1 : a≤1)
    (hq1 : ∀j≤H,1≤j→q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,1≤j→q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j∈Finset.range i,e j)≤ε+C*q i) :
    ((H-lastExit q H a:ℕ):ℝ)≤lastExitTailLengthConstant C*(1/a+ε/a^2) := by
  let τ := lastExit q H a
  have hτ : τ≤H := lastExit_le q H a
  have hK : 0<lastExitTailLengthConstant C := lastExitTailLengthConstant_pos hC
  by_cases hτH : τ=H
  · change ((H-τ:ℕ):ℝ)≤_
    rw [hτH,Nat.sub_self,Nat.cast_zero]
    positivity
  have hτlt : τ<H := lt_of_le_of_ne hτ hτH
  let s := τ+1
  let n := H-s
  have hs : s≤H := by dsimp [s]; omega
  have hsend : s+n=H := by dsimp [n]; omega
  have hlo (j : ℕ) (hj : j≤n) : a≤q (s+j) :=
    (after_lastExit (show s+j≤H by omega) (show lastExit q H a<s+j by dsimp [s]; omega)).le
  have hhi (j : ℕ) (hj : j≤n) : q (s+j)≤1 := hq1 _ (by omega) (by dsimp [s]; omega)
  have he' (j : ℕ) (hj : j<n) : 0≤e (s+j) := he _ (by omega)
  have hd' (j : ℕ) (hj : j<n) :
      q (s+(j+1))-q (s+j)≤-driftDissipation*(q (s+j))^2+e (s+j)/driftRate := by
    simpa only [Nat.add_assoc] using hd (s+j) (by omega) (by dsimp [s]; omega)
  have hC' : 0≤C+ε/a := by positivity
  have hpref (i : ℕ) (hi : i≤n) : (∑j∈Finset.range i,e (s+j))≤0+(C+ε/a)*q (s+i) := by
    have hh := (sum_segment_le_prefix e (show s≤s+i by omega)
      (fun j hj=>he j (by omega))).trans (hprefix (s+i) (by omega))
    have hseg : (s+i)-s=i := by omega
    rw [hseg] at hh
    have hm := mul_le_mul_of_nonneg_left (hlo i hi) (show 0≤ε/a by positivity)
    have hid : ε/a*a=ε := by field_simp
    rw [hid] at hm
    nlinarith
  obtain ⟨J,hreach⟩ := exists_dyadic_reaches ha
  have hlen := floor_path_length_bound n J (fun j=>q (s+j)) (fun j=>e (s+j))
    ha (show (0:ℝ)≤0 by norm_num) ha.le hC' hreach hlo hhi he' hd' hpref
  have hdelta : ((H-τ:ℕ):ℝ)=(n:ℝ)+1 := by
    have hh : H-τ=n+1 := by dsimp [n,s]; omega
    exact_mod_cast hh
  have hscalar : scalarBandLengthConstant (C+ε/a)=
      scalarBandLengthConstant C+2*ε/(a*driftRate*driftDissipation) := by
    unfold scalarBandLengthConstant
    ring
  rw [hscalar] at hlen
  have hdiv := (le_div_iff₀ ha).mpr hlen
  have hexpand : (3*(scalarBandLengthConstant C+2*ε/(a*driftRate*driftDissipation)))/a+1=
      3*scalarBandLengthConstant C/a+6/(driftRate*driftDissipation)*(ε/a^2)+1 := by ring
  change ((H-τ:ℕ):ℝ)≤_
  rw [hdelta]
  apply le_trans (b:=3*(scalarBandLengthConstant C+2*ε/(a*driftRate*driftDissipation))/a+1)
  · linarith only [hdiv]
  rw [hexpand]
  have hi : 1≤1/a := (le_div_iff₀ ha).mpr (by simpa using ha1)
  have h0 : 0≤scalarBandLengthConstant C := (scalarBandLengthConstant_pos hC).le
  have hr := driftRate_pos
  have hdiss := driftDissipation_pos
  have hcross1 : 0≤(1+3*scalarBandLengthConstant C)*(ε/a^2) := by positivity
  have hcross2 : 0≤(6/(driftRate*driftDissipation))/a := by positivity
  apply sub_nonneg.mp
  have hid : lastExitTailLengthConstant C*(1/a+ε/a^2)-
      (3*scalarBandLengthConstant C/a+6/(driftRate*driftDissipation)*(ε/a^2)+1)=
      (1/a-1)+(1+3*scalarBandLengthConstant C)*(ε/a^2)+(6/(driftRate*driftDissipation))/a := by
    unfold lastExitTailLengthConstant
    ring
  rw [hid]
  linarith only [hi,hcross1,hcross2]


def longPrefixLength (K T a : ℝ) : ℕ := ⌈K*T/a⌉₊

def longPrefixDepthConstant (C K : ℝ) : ℝ :=
  K+2+lastExitTailLengthConstant 526336*(1+C)

lemma longPrefixLength_bounds {K T a : ℝ} (hK : 0<K) (hT : 1≤T) (ha : 0<a) (ha1 : a≤1) :
    1≤longPrefixLength K T a ∧ K*T/a≤(longPrefixLength K T a:ℝ) ∧
      (longPrefixLength K T a:ℝ)≤(K+1)*T/a := by
  have hT0 : 0<T := by linarith
  have hlo := Nat.le_ceil (K*T/a)
  have hhi := (Nat.ceil_lt_add_one (show 0≤K*T/a by positivity)).le
  have hJpos : 0<(longPrefixLength K T a:ℝ) :=
    (div_pos (mul_pos hK hT0) ha).trans_le hlo
  have hJ : 1≤longPrefixLength K T a := by exact_mod_cast (show (0:ℝ)<longPrefixLength K T a from hJpos)
  have hTa : 1≤T/a := (le_div_iff₀ ha).mpr (by linarith)
  refine ⟨hJ,hlo,?_⟩
  change (⌈K*T/a⌉₊:ℝ)≤_
  have he : (K+1)*T/a=K*T/a+T/a := by ring
  rw [he]
  linarith

/-- An O(T/a) initial segment occurs before the last visit below a whenever
the full path is long compared with T/a. -/
theorem long_prefix_before_lastExit (H : ℕ) (q e : ℕ→ℝ) {ε C K T a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (hK : 0<K) (hT : 1≤T) (ha : 0<a) (ha1 : a≤1)
    (hexcess : ε≤C*a*T)
    (hq1 : ∀j≤H,1≤j→q j≤1) (he : ∀j<H,0≤e j)
    (hd : ∀j<H,1≤j→q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate)
    (hprefix : ∀i≤H,(∑j∈Finset.range i,e j)≤ε+526336*q i)
    (hdepth : longPrefixDepthConstant C K*T/a≤(H:ℝ)) :
    longPrefixLength K T a≤lastExit q H a ∧
      (∑j∈Finset.range (longPrefixLength K T a),e j)≤ε+526336*a := by
  let J := longPrefixLength K T a
  let τ := lastExit q H a
  let L := lastExitTailLengthConstant 526336
  have hL : 0<L := lastExitTailLengthConstant_pos (by norm_num)
  have htail := truncated_lastExit_length_after_first H q e hε (by norm_num) ha ha1 hq1 he hd hprefix
  have hτ : τ≤H := lastExit_le q H a
  have hexp : ε/a^2≤C*T/a := by
    apply (div_le_iff₀ (sq_pos_of_pos ha)).mpr
    have hid : C*T/a*a^2=C*a*T := by field_simp
    rwa [hid]
  have hone : 1/a≤T/a := div_le_div_of_nonneg_right hT ha.le
  have hsmall : ((H-τ:ℕ):ℝ)≤L*(1+C)*T/a := by
    have hh : 1/a+ε/a^2≤(1+C)*T/a := by
      calc
        _ ≤ T/a+C*T/a := add_le_add hone hexp
        _ = _ := by ring
    calc
      _ ≤ L*(1/a+ε/a^2) := htail
      _ ≤ L*((1+C)*T/a) := mul_le_mul_of_nonneg_left hh hL.le
      _ = _ := by ring
  obtain ⟨hJ1,hJlo,hJhi⟩ := longPrefixLength_bounds hK hT ha ha1
  have hdepth' : (K+2+L*(1+C))*T/a≤(H:ℝ) := hdepth
  have hcast : ((H-τ:ℕ):ℝ)=(H:ℝ)-τ := Nat.cast_sub hτ
  rw [hcast] at hsmall
  have hJτreal : (J:ℝ)≤τ := by
    have hTa : 0<T/a := div_pos (by linarith) ha
    have hid : (K+2+L*(1+C))*T/a=(K+1)*T/a+L*(1+C)*T/a+T/a := by ring
    rw [hid] at hdepth'
    dsimp only [J]
    linarith only [hdepth',hsmall,hJhi,hTa]
  have hJτ : J≤τ := by exact_mod_cast hJτreal
  refine ⟨hJτ,?_⟩
  have hτpos : 0<τ := lt_of_lt_of_le (by dsimp [J]; omega) hJτ
  have hqτ : q τ≤a := lastExit_state hτpos
  have hp := hprefix τ hτ
  have hsum : (∑j∈Finset.range J,e j)≤∑j∈Finset.range τ,e j := by
    apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hJτ)
    intro j hj _
    exact he j ((Finset.mem_range.mp hj).trans_le hτ)
  nlinarith

#print axioms truncated_lastExit_length_after_first
#print axioms long_prefix_before_lastExit
end ConditionalNonpolynomial.Analytic
