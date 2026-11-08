import NeuralGeneralization.OnlineLowerTanhDegreeRatio
import NeuralGeneralization.OnlineLowerTanhBiasPeakLoss
import NeuralGeneralization.OnlineLowerTanhOptimizerEfficiency

/-! A uniform finite comparison excludes every nonempty collection of
outlier coordinates once the surviving bulk is exactly equal. Both parities
of bulk size use one odd reference degree. -/
noncomputable section
open scoped Topology BigOperators
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma outlier_normalized_square_gap (x y:ℝ) (hx:0<x) (hxsmall:x≤1/32)
    (hy:0≤y) (hymax:y≤1+2*x) :
    (1+x/4)^2*y < (1-5*x/4)^2*(y+5*x) := by
  have hdiff : (1+x/4)^2-(1-5*x/4)^2≤3*x := by nlinarith [sq_nonneg x]
  have hprod:=mul_le_mul_of_nonneg_right hdiff hy
  have hyprod:=mul_le_mul_of_nonneg_left hymax (by positivity : 0≤3*x)
  have hsquare : 1-5*x/2≤(1-5*x/4)^2 := by nlinarith [sq_nonneg x]
  have hlower:=mul_le_mul_of_nonneg_right hsquare (by positivity : 0≤5*x)
  have hx2 : x^2≤x/32 := by nlinarith [mul_nonneg hx.le (sub_nonneg.mpr hxsmall)]
  nlinarith

lemma outlier_denominator_gap (M N q:ℝ) (hM:0<M) (hN:0<N) (hq:0<q)
    (hqsmall:q/M≤1/32) (hNmax:N≤M+2*q) :
    (1+q/M/4)/Real.sqrt (N+5*q) < (1-5*(q/M)/4)/Real.sqrt N := by
  have hx:0<q/M:=div_pos hq hM
  have hy:0≤N/M:=(div_pos hN hM).le
  have hymax:N/M≤1+2*(q/M):=by
    apply (div_le_iff₀ hM).mpr
    field_simp
    linarith
  have hs:=outlier_normalized_square_gap (q/M) (N/M) hx hqsmall hy hymax
  have he:(N/M+5*(q/M))*M=N+5*q:=by field_simp
  have hm:=mul_lt_mul_of_pos_right hs hM
  have hs':(1+q/M/4)^2*N < (1-5*(q/M)/4)^2*(N+5*q):=by
    calc
      _ = ((1+q/M/4)^2*(N/M))*M := by field_simp
      _ < ((1-5*(q/M)/4)^2*(N/M+5*(q/M)))*M := hm
      _ = _ := by rw [mul_assoc,he]
  have hpos:0<1-5*(q/M)/4:=by linarith
  have hrootN:=Real.sqrt_pos.mpr hN
  have hrootE:=Real.sqrt_pos.mpr (show 0<N+5*q by linarith)
  apply (div_lt_div_iff₀ hrootE hrootN).mpr
  have hleft:0≤(1+q/M/4)*Real.sqrt N:=by positivity
  have hright:0≤(1-5*(q/M)/4)*Real.sqrt (N+5*q):=by positivity
  have hsqLeft:=Real.sq_sqrt hN.le
  have hsqRight:=Real.sq_sqrt (show 0≤N+5*q by linarith)
  have hh:((1+q/M/4)*Real.sqrt N)^2 < ((1-5*(q/M)/4)*Real.sqrt (N+5*q))^2:=by
    rw [mul_pow,mul_pow,hsqLeft,hsqRight]
    exact hs'
  nlinarith

lemma balancedDegreeRatioError_small (r j:ℕ) (K:ℝ) (hK:0≤K)
    (hlarge:32*(scalarFirstError+scalarFirstBound+K+1)≤2*(r:ℝ)+1)
    (hsmall:((j:ℝ)+1)/(2*(r:ℝ)+1)≤1/32) :
    balancedDegreeRatioError j/(2*(r:ℝ)+1)^2 ≤ ((j:ℝ)+1)/(4*(2*(r:ℝ)+1)) := by
  let M:=2*(r:ℝ)+1
  let q:ℝ:=(j:ℝ)+1
  have hM:0<M:=by dsimp [M];positivity
  have hj:0≤(j:ℝ):=Nat.cast_nonneg _
  have hq:1≤q:=by dsimp [q];linarith
  have hqM:q≤M/32:=by
    change q/M≤1/32 at hsmall
    have hh:=(div_le_iff₀ hM).mp hsmall
    linarith
  have hsum:4*(scalarFirstError+scalarFirstBound)≤M/8:=by
    change 32*(scalarFirstError+scalarFirstBound+K+1)≤M at hlarge
    linarith
  have hErr:balancedDegreeRatioError j≤q*(2*q+4*scalarFirstError+4*scalarFirstBound):=by
    unfold balancedDegreeRatioError
    dsimp [q]
    have he:=scalarFirstError_nonneg
    have hb:=scalarFirstBound_nonneg
    nlinarith
  have hcoef:2*q+4*scalarFirstError+4*scalarFirstBound≤M/4:=by linarith
  have hErr':balancedDegreeRatioError j≤q*M/4:=hErr.trans (by
    have hh:=mul_le_mul_of_nonneg_left hcoef (by linarith : 0≤q)
    nlinarith only [hh])
  change balancedDegreeRatioError j/M^2≤q/(4*M)
  apply (div_le_div_iff₀ (sq_pos_of_pos hM) (by positivity)).mpr
  have hh:=mul_le_mul_of_nonneg_right hErr' (by positivity : 0≤4*M)
  nlinarith only [hh]

/-- A fixed quadratic-error bias cap cannot compensate for the norm cost
of even a single outlier. The bound is uniform when j=o(r). -/
theorem outlier_coefficient_strict_comparison (r j:ℕ) (a K c E:ℝ)
    (ha:1≤a) (hK:0≤K)
    (hlarge:32*(scalarFirstError+scalarFirstBound+K+1)≤2*(r:ℝ)+1)
    (hsmall:((j:ℝ)+1)/(2*(r:ℝ)+1)≤1/32)
    (hcap:|c|≤balancedParity r a*(1+K/(2*(r:ℝ)+1)^2))
    (henergy:a^2*((2*(r+j:ℕ)+1:ℕ)+5*((j:ℝ)+1))≤E) :
    |c|/Real.sqrt E < balancedParity (r+j) a/(a*Real.sqrt (2*(r+j:ℕ)+1:ℕ)) := by
  let M:=2*(r:ℝ)+1
  let N:ℝ:=(2*(r+j:ℕ)+1:ℕ)
  let q:ℝ:=(j:ℝ)+1
  have hM:0<M:=by dsimp [M];positivity
  have hN:0<N:=by dsimp [N];positivity
  have hq:0<q:=by dsimp [q];positivity
  have hq1:1≤q:=by dsimp [q];nlinarith [Nat.cast_nonneg (α:=ℝ) j]
  have ha0:0<a:=by linarith
  have hP:=balancedParity_pos_of_one_le r a ha
  have hNmax:N≤M+2*q:=by dsimp [N,M,q];push_cast;nlinarith
  have hratio:=balancedParity_shift_ratio_error r j a ha
  have herr:=balancedDegreeRatioError_small r j K hK hlarge hsmall
  have hrat : 1-5*(q/M)/4 ≤ balancedParity (r+j) a/balancedParity r a := by
    have hl:=(abs_le.mp hratio).1
    change balancedDegreeRatioError j/M^2≤q/(4*M) at herr
    have hjdiv:(j:ℝ)/M≤q/M:=div_le_div_of_nonneg_right (by dsimp [q];linarith) hM.le
    change -(balancedDegreeRatioError j/M^2)≤balancedParity (r+j) a/balancedParity r a-(1-(j:ℝ)/M) at hl
    have he:q/(4*M)=(q/M)/4:=by ring
    rw [he] at herr
    linarith
  have hKcap:K/M^2≤(q/M)/4:=by
    change 32*(scalarFirstError+scalarFirstBound+K+1)≤M at hlarge
    have hKM:4*K≤M:=by linarith [scalarFirstError_nonneg,scalarFirstBound_nonneg]
    have hqM:M≤q*M:=by nlinarith
    apply (div_le_iff₀ (sq_pos_of_pos hM)).mpr
    field_simp
    nlinarith
  have hcap':|c|≤balancedParity r a*(1+q/M/4):=hcap.trans
    (mul_le_mul_of_nonneg_left (by change 1+K/M^2≤1+q/M/4;linarith) hP.le)
  have hEpos:0<E:=lt_of_lt_of_le (mul_pos (sq_pos_of_pos ha0) (by positivity : 0<N+5*q)) henergy
  have hden:a*Real.sqrt (N+5*q)≤Real.sqrt E:=by
    have hh:=Real.sqrt_le_sqrt henergy
    rwa [Real.sqrt_mul (sq_nonneg a),Real.sqrt_sq ha0.le] at hh
  have hgap:=outlier_denominator_gap M N q hM hN hq hsmall hNmax
  have hgain:=mul_lt_mul_of_pos_left hgap (div_pos hP ha0)
  have hlower:(1-5*(q/M)/4)*balancedParity r a≤balancedParity (r+j) a:=
    (le_div_iff₀ hP).mp hrat
  calc
    |c|/Real.sqrt E ≤ (balancedParity r a*(1+q/M/4))/(a*Real.sqrt (N+5*q)) :=
      div_le_div₀ (by positivity) hcap' (by positivity) hden
    _ = (balancedParity r a/a)*((1+q/M/4)/Real.sqrt (N+5*q)) := by ring
    _ < (balancedParity r a/a)*((1-5*(q/M)/4)/Real.sqrt N) := hgain
    _ = ((1-5*(q/M)/4)*balancedParity r a)/(a*Real.sqrt N) := by ring
    _ ≤ balancedParity (r+j) a/(a*Real.sqrt N) :=
      div_le_div_of_nonneg_right hlower (by positivity)

lemma intrinsicGain_balanced_at_gain (r:ℕ) (a:ℝ) (ha:1≤a) :
    intrinsicGain (fun _ : Fin (2*r+1)=>a)=
      balancedParity r a/(a*Real.sqrt (2*r+1:ℕ)) := by
  have ha0:0<a:=by linarith
  have hE:incomingEnergy (fun _ : Fin (2*r+1)=>a)=(2*r+1:ℕ)*a^2:=by simp [incomingEnergy]
  unfold intrinsicGain
  rw [balancedParity_abs_of_one_le r a ha,hE,Real.sqrt_mul (by positivity),Real.sqrt_sq ha0.le,mul_comm]

/-- This is a literal contradiction to global optimality of the incoming
vector, including the one-outlier even-bulk case j=0. -/
theorem actual_outliers_not_maximizer (r j:ℕ) (a K:ℝ)
    (u:Fin (2*(r+j)+1)→ℝ) (ha:1≤a) (hK:0≤K)
    (hlarge:32*(scalarFirstError+scalarFirstBound+K+1)≤2*(r:ℝ)+1)
    (hsmall:((j:ℝ)+1)/(2*(r:ℝ)+1)≤1/32)
    (hcap:|parityCorrelation u 0|≤balancedParity r a*(1+K/(2*(r:ℝ)+1)^2))
    (henergy:a^2*((2*(r+j:ℕ)+1:ℕ)+5*((j:ℝ)+1)) ≤ incomingEnergy u) :
    ¬IsIntrinsicMaximizer u := by
  intro hmax
  have hh:=outlier_coefficient_strict_comparison r j a K (parityCorrelation u 0)
    (incomingEnergy u) ha hK hlarge hsmall hcap henergy
  have hcompare:=hmax (fun _=>a)
  rw [intrinsicGain_balanced_at_gain (r+j) a ha] at hcompare
  exact (not_le_of_gt hh) hcompare

/-- Only a vanishing relative outlier count is needed; the comparison is
uniform over every positive integer count, not just a fixed finite count. -/
theorem actual_outliers_eventually_not_maximizer
    (r j:ℕ→ℕ) (a:ℕ→ℝ) (K:ℝ) (hK:0≤K)
    (u:(k:ℕ)→Fin (2*(r k+j k)+1)→ℝ)
    (hr:Tendsto r atTop atTop)
    (hrelative:Tendsto (fun k=>((j k:ℝ)+1)/(2*(r k:ℝ)+1)) atTop (𝓝 0))
    (ha:∀ᶠk in atTop,1≤a k)
    (hcap:∀ᶠk in atTop,|parityCorrelation (u k) 0|≤
      balancedParity (r k) (a k)*(1+K/(2*(r k:ℝ)+1)^2))
    (henergy:∀ᶠk in atTop,(a k)^2*((2*(r k+j k:ℕ)+1:ℕ)+5*((j k:ℝ)+1)) ≤ incomingEnergy (u k)) :
    ∀ᶠk in atTop,¬IsIntrinsicMaximizer (u k) := by
  have hdegree:Tendsto (fun k=>2*(r k:ℝ)+1) atTop atTop:=by
    have hh:=(tendsto_natCast_atTop_atTop (R:=ℝ)).comp hr
    apply tendsto_atTop.mpr
    intro B
    filter_upwards [hh.eventually (eventually_ge_atTop B)] with k hk
    simp only [Function.comp_def] at hk
    nlinarith [Nat.cast_nonneg (α:=ℝ) (r k)]
  filter_upwards [ha,hcap,henergy,
    hdegree.eventually (eventually_ge_atTop (32*(scalarFirstError+scalarFirstBound+K+1))),
    hrelative.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1/32))]
    with k hak hck hek hlarge hsmall
  exact actual_outliers_not_maximizer (r k) (j k) (a k) K (u k) hak hK hlarge hsmall.le hck hek

/-- Equal bulk magnitudes and the coarse 5a/2 outlier separation already
supply a stronger energy penalty than the finite comparison requires. -/
lemma separated_outliers_energy {n:ℕ} (A:Finset (Fin n)) (u:Fin n→ℝ)
    (a:ℝ) (ha:0≤a) (hbulk:∀i∈A,|u i|=a)
    (hout:∀i,i∉A→5*a/2≤|u i|) :
    a^2*((n:ℝ)+(21/4:ℝ)*(Aᶜ.card:ℝ)) ≤ incomingEnergy u := by
  have hp (i:Fin n):a^2+(if i∈Aᶜ then (21/4:ℝ)*a^2 else 0)≤(u i)^2:=by
    by_cases hi:i∈A
    · simp only [Finset.mem_compl,hi,not_true_eq_false,if_false,add_zero]
      have hh:=hbulk i hi
      nlinarith [sq_abs (u i)]
    · simp only [Finset.mem_compl,hi,not_false_eq_true,if_true]
      have hh:=hout i hi
      have hs:=(sq_le_sq₀ (by positivity : 0≤5*a/2) (abs_nonneg (u i))).mpr hh
      rw [sq_abs] at hs
      nlinarith
  have hsum:=Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hp i)
  simp only [Finset.sum_add_distrib,Finset.sum_const,Finset.card_univ,Fintype.card_fin,
    nsmul_eq_mul,Fintype.sum_ite_mem] at hsum
  unfold incomingEnergy
  nlinarith only [hsum]

lemma outlier_energy_comparison {r j:ℕ} (A:Finset (Fin (2*(r+j)+1)))
    (u:Fin (2*(r+j)+1)→ℝ) (a:ℝ) (ha:0≤a)
    (hbulk:∀i∈A,|u i|=a) (hout:∀i,i∉A→5*a/2≤|u i|)
    (hcount:j+1≤Aᶜ.card) :
    a^2*((2*(r+j:ℕ)+1:ℕ)+5*((j:ℝ)+1)) ≤ incomingEnergy u := by
  have he:=separated_outliers_energy A u a ha hbulk hout
  have hc:((j:ℝ)+1)≤(Aᶜ.card:ℝ):=by exact_mod_cast hcount
  have hpen:5*((j:ℝ)+1)≤(21/4:ℝ)*(Aᶜ.card:ℝ):=by
    nlinarith [Nat.cast_nonneg (α:=ℝ) Aᶜ.card]
  exact (mul_le_mul_of_nonneg_left (add_le_add_right hpen _) (sq_nonneg a)).trans he

/-- Passing from an even bulk's denominator n² to the adjacent odd
reference (n+1)² changes its fixed error constant by at most four. -/
lemma even_bulk_error_to_odd_reference (n:ℕ) (hn:1≤n) (K:ℝ) (hK:0≤K) :
    K/(n:ℝ)^2≤(4*K)/((n:ℝ)+1)^2 := by
  have hnR:(1:ℝ)≤n:=by exact_mod_cast hn
  apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
  have hs:((n:ℝ)+1)^2≤4*(n:ℝ)^2:=by nlinarith
  have hm:=mul_le_mul_of_nonneg_left hs hK
  nlinarith only [hm]

end NeuralGeneralization.OnlineLowerTanh
