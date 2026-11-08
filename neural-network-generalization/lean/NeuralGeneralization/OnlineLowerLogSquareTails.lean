import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Tactic

/-! # Uniform polynomial suppression above a logarithmic-square baseline -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

lemma log_mul_le_sqrt_above_logSquare (ε:ℝ) (hε:0<ε) :
    ∃K R₀:ℝ,1≤K ∧ 1≤R₀ ∧ ∀p R:ℝ,1≤p → R₀≤R → K*(Real.log (p+2))^2≤R →
      Real.log (p*R)≤ε*Real.sqrt R := by
  have he:= (isLittleO_log_rpow_atTop (r:=(1:ℝ)/2) (by norm_num)).bound (half_pos hε)
  obtain ⟨R₁,hR₁⟩:=eventually_atTop.mp he
  let K:ℝ:=max 1 ((2/ε)^2)
  refine ⟨K,max 1 R₁,le_max_left _ _,le_max_left _ _,?_⟩
  intro p R hp hR hKR
  have hp0:0<p:=lt_of_lt_of_le (by norm_num) hp
  have hR0:0<R:=lt_of_lt_of_le (by norm_num) ((le_max_left _ _).trans hR)
  have hR1:R₁≤R:=(le_max_right _ _).trans hR
  have hlogR:=hR₁ R hR1
  have hlogR' : Real.log R≤(ε/2)*Real.sqrt R:=by
    change ‖Real.log R‖≤(ε/2)*‖R^((1:ℝ)/2)‖ at hlogR
    rw [←Real.sqrt_eq_rpow,Real.norm_eq_abs,Real.norm_eq_abs,
      abs_of_nonneg (Real.sqrt_nonneg _)] at hlogR
    exact (le_abs_self _).trans hlogR
  have hl:0≤Real.log (p+2):=Real.log_nonneg (by linarith)
  have hs:Real.sqrt R^2=R:=Real.sq_sqrt hR0.le
  have hks:(2/ε)^2*(Real.log (p+2))^2≤R:=
    (mul_le_mul_of_nonneg_right (le_max_right _ _) (sq_nonneg _)).trans hKR
  have hroot:(2/ε)*Real.log (p+2)≤Real.sqrt R:=by
    have hnon:0≤(2/ε)*Real.log (p+2):=by positivity
    nlinarith [Real.sqrt_nonneg R]
  have hlogp:Real.log p≤(ε/2)*Real.sqrt R:=by
    have hm:=Real.log_le_log hp0 (show p≤p+2 by linarith)
    have hh:=mul_le_mul_of_nonneg_left hroot hε.le
    have hid:ε*((2/ε)*Real.log (p+2))=2*Real.log (p+2):=by field_simp
    rw [hid] at hh
    linarith
  rw [Real.log_mul hp0.ne' hR0.ne']
  linarith

lemma two_exponential_tails_of_log_bounds (p R C a b:ℝ) (q L:ℕ)
    (hp:1≤p) (hR:1≤R) (hC:0≤C) (hcap:2*C≤p*R)
    (hfirst:((2*(q+L+1)+1:ℕ):ℝ)*Real.log (p*R)≤a*R)
    (hsecond:((L+1:ℕ):ℝ)*Real.log (p*R)≤b*Real.sqrt R) :
    C*((p*R)^q*Real.sqrt (p*Real.exp (-a*R))+Real.exp (-b*Real.sqrt R))≤((p*R)^L)⁻¹ := by
  let D:ℝ:=p*R
  have hp0:0<p:=lt_of_lt_of_le (by norm_num) hp
  have hR0:0<R:=lt_of_lt_of_le (by norm_num) hR
  have hD:0<D:=mul_pos hp0 hR0
  have hpD:p≤D:=by dsimp [D]; nlinarith
  have hlogp:Real.log p≤Real.log D:=Real.log_le_log hp0 hpD
  have hleft:0<D^q*Real.sqrt (p*Real.exp (-a*R)):=by positivity
  have hright:0<(D^(L+1))⁻¹:=by positivity
  have h₁:D^q*Real.sqrt (p*Real.exp (-a*R))≤(D^(L+1))⁻¹:=by
    apply (Real.log_le_log_iff hleft hright).mp
    rw [Real.log_mul (pow_pos hD q).ne' (Real.sqrt_pos.mpr (by positivity)).ne',
      Real.log_pow,Real.log_sqrt (by positivity),Real.log_mul hp0.ne' (Real.exp_ne_zero _),
      Real.log_exp,Real.log_inv,Real.log_pow]
    change ((2*(q+L+1)+1:ℕ):ℝ)*Real.log D≤a*R at hfirst
    push_cast at hfirst ⊢
    nlinarith
  have h₂:Real.exp (-b*Real.sqrt R)≤(D^(L+1))⁻¹:=by
    apply (Real.log_le_log_iff (Real.exp_pos _) hright).mp
    rw [Real.log_exp,Real.log_inv,Real.log_pow]
    change ((L+1:ℕ):ℝ)*Real.log D≤b*Real.sqrt R at hsecond
    linarith
  calc
    _ ≤ C*((D^(L+1))⁻¹+(D^(L+1))⁻¹):=mul_le_mul_of_nonneg_left (add_le_add h₁ h₂) hC
    _ = (2*C/D)*(D^L)⁻¹:=by rw [pow_succ]; field_simp; ring
    _ ≤ 1*(D^L)⁻¹:=by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      exact (div_le_one hD).mpr hcap
    _ = _:=one_mul _

/-- The logarithmic-square threshold is uniform in all larger rail sizes,
including arbitrarily large R; it also enforces any fixed minimum size. -/
theorem polynomial_tails_logSquare_real (a b C Rmin:ℝ) (ha:0<a) (hb:0<b) (hC:0≤C) (q L:ℕ) :
    ∃K:ℝ,1≤K ∧ ∀ᶠp:ℝ in atTop,∀R:ℝ,K*(Real.log (p+2))^2≤R →
      Rmin≤R ∧ C*((p*R)^q*Real.sqrt (p*Real.exp (-a*R))+Real.exp (-b*Real.sqrt R))≤((p*R)^L)⁻¹ := by
  let ε:ℝ:=b/(L+1:ℕ)
  have hε:0<ε:=by dsimp [ε]; positivity
  obtain ⟨K,R₀,hK,hR₀,hlog⟩:=log_mul_le_sqrt_above_logSquare ε hε
  let A:ℝ:=((2*(q+L+1)+1:ℕ):ℝ)
  have hA:0≤A:=by dsimp [A]; positivity
  let Rstar:ℝ:=max Rmin (max R₀ ((A*ε/a)^2))
  have hRstar:1≤Rstar:=hR₀.trans ((le_max_left _ _).trans (le_max_right _ _))
  have hlogt:Tendsto (fun p:ℝ=>Real.log (p+2)) atTop atTop:=
    Real.tendsto_log_atTop.comp (tendsto_atTop_add_const_right atTop 2 tendsto_id)
  refine ⟨K,hK,?_⟩
  filter_upwards [eventually_ge_atTop (1:ℝ),eventually_ge_atTop (2*C),
    hlogt.eventually_ge_atTop (Rstar+1)] with p hp hpC hplog
  intro R hKR
  have hRbig:Rstar≤R:=by
    have hs:(Real.log (p+2))^2≤R:=by
      simpa only [one_mul] using (mul_le_mul_of_nonneg_right hK (sq_nonneg _)).trans hKR
    nlinarith
  have hR1:1≤R:=hRstar.trans hRbig
  have hR0:0≤R:=le_trans (by norm_num) hR1
  have hRR:R₀≤R:=((le_max_left _ _).trans (le_max_right _ _)).trans hRbig
  have hsquare:(A*ε/a)^2≤R:=((le_max_right _ _).trans (le_max_right _ _)).trans hRbig
  have hroot:A*ε/a≤Real.sqrt R:=by
    have hs:=Real.sq_sqrt hR0
    have hp:0≤A*ε/a:=by positivity
    nlinarith [Real.sqrt_nonneg R]
  have hlogbound:=hlog p R hp hRR hKR
  have hfirst:A*Real.log (p*R)≤a*R:=by
    have h1:=mul_le_mul_of_nonneg_left hlogbound hA
    have h2: A*ε≤a*Real.sqrt R:=by
      have hh: A*ε≤Real.sqrt R*a := (div_le_iff₀ ha).mp hroot
      nlinarith
    have h3:=mul_le_mul_of_nonneg_right h2 (Real.sqrt_nonneg R)
    have hs:=Real.sq_sqrt hR0
    nlinarith
  have hsecond:((L+1:ℕ):ℝ)*Real.log (p*R)≤b*Real.sqrt R:=by
    have hh:=mul_le_mul_of_nonneg_left hlogbound (show 0≤((L+1:ℕ):ℝ) by positivity)
    have he:((L+1:ℕ):ℝ)*ε=b:=by dsimp [ε]; field_simp
    simpa only [←mul_assoc,he] using hh
  refine ⟨(le_max_left _ _).trans hRbig,?_⟩
  apply two_exponential_tails_of_log_bounds p R C a b q L hp hR1 hC
  · have hp0:0≤p:=le_trans (by norm_num) hp
    have hh:=mul_le_mul_of_nonneg_left hR1 hp0
    nlinarith
  · exact hfirst
  · exact hsecond

/-- Natural-coordinate version used by the physical rail construction. -/
theorem polynomial_tails_logSquare (a b C Rmin:ℝ) (ha:0<a) (hb:0<b) (hC:0≤C) (q L:ℕ) :
    ∃K p₀:ℕ,1≤K ∧ ∀p R:ℕ,p₀≤p → (K:ℝ)*(Real.log ((p:ℝ)+2))^2≤R →
      Rmin≤(R:ℝ) ∧ C*(((p:ℝ)*R)^q*Real.sqrt ((p:ℝ)*Real.exp (-a*R))+
        Real.exp (-b*Real.sqrt R))≤(((p:ℝ)*R)^L)⁻¹ := by
  obtain ⟨K,hK,he⟩:=polynomial_tails_logSquare_real a b C Rmin ha hb hC q L
  have hnat:=he.filter_mono (show Filter.map (fun p:ℕ=>(p:ℝ)) atTop≤atTop from tendsto_natCast_atTop_atTop)
  obtain ⟨p₀,hp₀⟩:=eventually_atTop.mp hnat
  refine ⟨⌈K⌉₊,p₀,?_,?_⟩
  · have hh:=Nat.le_ceil K
    have hpos:0<⌈K⌉₊:=Nat.cast_pos.mp (lt_of_lt_of_le (by linarith) hh)
    omega
  · intro p R hp hR
    apply hp₀ p hp R
    exact (mul_le_mul_of_nonneg_right (Nat.le_ceil K) (sq_nonneg _)).trans hR

theorem exponential_small_logSquare (a μ:ℝ) (ha:0<a) (hμ:0<μ) :
    ∃K p₀:ℕ,1≤K ∧ ∀p R:ℕ,p₀≤p → (K:ℝ)*(Real.log ((p:ℝ)+2))^2≤R →
      (p:ℝ)*Real.exp (-a*R)≤μ := by
  have hs:0<Real.sqrt μ:=Real.sqrt_pos.mpr hμ
  obtain ⟨K,p₀,hK,hbound⟩:=polynomial_tails_logSquare a 1 (Real.sqrt μ)⁻¹ 1 ha (by norm_num)
    (inv_nonneg.mpr hs.le) 0 0
  refine ⟨K,p₀,hK,?_⟩
  intro p R hp hR
  have he:=(hbound p R hp hR).2
  simp only [pow_zero,one_mul,inv_one] at he
  have he':Real.sqrt ((p:ℝ)*Real.exp (-a*R))+Real.exp (-1*Real.sqrt R)≤Real.sqrt μ:=by
    have hh:=mul_le_mul_of_nonneg_left he hs.le
    simpa only [←mul_assoc,mul_inv_cancel₀ hs.ne',one_mul,mul_one] using hh
  have hx:0≤(p:ℝ)*Real.exp (-a*R):=by positivity
  have ht:=Real.sq_sqrt hx
  have hm:=Real.sq_sqrt hμ.le
  nlinarith [Real.exp_pos (-1*Real.sqrt (R:ℝ)),Real.sqrt_nonneg ((p:ℝ)*Real.exp (-a*R))]

theorem half_power_small_logSquare (μ:ℝ) (hμ:0<μ) :
    ∃K p₀:ℕ,1≤K ∧ ∀p R:ℕ,p₀≤p → (K:ℝ)*(Real.log ((p:ℝ)+2))^2≤R →
      (p:ℝ)*(1/2:ℝ)^R≤μ := by
  obtain ⟨K,p₀,hK,hbound⟩:=exponential_small_logSquare (Real.log 2) μ (Real.log_pos (by norm_num)) hμ
  refine ⟨K,p₀,hK,?_⟩
  intro p R hp hR
  have he:=hbound p R hp hR
  have heq:Real.exp (-Real.log 2*(R:ℝ))=(1/2:ℝ)^R:=by
    rw [mul_comm,Real.exp_nat_mul,Real.exp_neg,Real.exp_log (by norm_num)]
    norm_num
  rwa [heq] at he

end NeuralGeneralization.OnlineLowerTanh
