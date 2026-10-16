import NeuralGeneralization.FinitePosterior
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Order.LiminfLimsup

/-!
# Finite posterior concentration from exponential rates

This is the finite normalization step after the network large-deviation theorem.
The exponential-rate hypothesis is explicit. It is NOT a proof that a network
has that rate; that analytic obligation is separate.
-/

namespace NeuralGeneralization

open Filter
open scoped Topology

variable {I : Type*} {l : Filter I}

/-- Two-sided exponential estimates, with arbitrarily small error in the rate.
For a positive speed tending to infinity and positive weights this is equivalent
to `log (w n) / speed n → -E`. The estimates include the multiplicative prefactors
implicitly, because they hold for every positive rate error. -/
def HasExponentialRate (l : Filter I) (speed w : I → ℝ) (E : ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∀ᶠ n in l,
    Real.exp (-(E + ε) * speed n) ≤ w n ∧
      w n ≤ Real.exp (-(E - ε) * speed n)

theorem HasExponentialRate.comp {J : Type*} {k : Filter J}
    {speed w : I → ℝ} {E : ℝ} {f : J → I}
    (h : HasExponentialRate l speed w E) (hf : Tendsto f k l) :
    HasExponentialRate k (fun j => speed (f j)) (fun j => w (f j)) E := by
  intro ε hε
  exact hf.eventually (h ε hε)

theorem HasExponentialRate.congr {speed u v : I → ℝ} {E : ℝ}
    (hu : HasExponentialRate l speed u E) (heq : u =ᶠ[l] v) :
    HasExponentialRate l speed v E := by
  intro ε hε
  filter_upwards [hu ε hε, heq] with n hn he
  simpa only [← he] using hn

/-- Ordinary logarithmic large-deviation rates imply the explicit exponential
estimates used below. This proves the conversion, rather than hiding it in the
definition of the posterior-concentration hypothesis. -/
theorem hasExponentialRate_of_log_tendsto {speed w : I → ℝ} {E : ℝ}
    (hs : Tendsto speed l atTop)
    (hw : ∀ᶠ n in l, 0 < w n)
    (hlog : Tendsto (fun n => Real.log (w n) / speed n) l (𝓝 (-E))) :
    HasExponentialRate l speed w E := by
  intro ε hε
  have hlo := (tendsto_order.mp hlog).1 (-(E + ε)) (by linarith)
  have hhi := (tendsto_order.mp hlog).2 (-(E - ε)) (by linarith)
  filter_upwards [hs.eventually_gt_atTop 0, hw, hlo, hhi] with n hn hwp hl hh
  constructor
  · calc
      Real.exp (-(E + ε) * speed n) ≤ Real.exp (Real.log (w n)) :=
        Real.exp_le_exp.mpr ((lt_div_iff₀ hn).mp hl).le
      _ = w n := Real.exp_log hwp
  · calc
      w n = Real.exp (Real.log (w n)) := (Real.exp_log hwp).symm
      _ ≤ Real.exp (-(E - ε) * speed n) :=
        Real.exp_le_exp.mpr ((div_lt_iff₀ hn).mp hh).le

lemma HasExponentialRate.eventually_pos {speed w : I → ℝ} {E : ℝ}
    (h : HasExponentialRate l speed w E) : ∀ᶠ n in l, 0 < w n := by
  filter_upwards [h 1 zero_lt_one] with n hn
  exact lt_of_lt_of_le (Real.exp_pos _) hn.1

/-- A strictly higher energy has an exponentially small weight ratio.
The explicit factor `1/2` leaves room for both rate errors. -/
theorem HasExponentialRate.ratio_bound {speed u v : I → ℝ} {Eu Ev : ℝ}
    (hu : HasExponentialRate l speed u Eu)
    (hv : HasExponentialRate l speed v Ev) (hgap : Ev < Eu) :
    ∀ᶠ n in l,
      u n / v n ≤ Real.exp (-((Eu - Ev) / 2) * speed n) := by
  have he : 0 < (Eu - Ev) / 4 := by linarith
  filter_upwards [hu ((Eu - Ev) / 4) he, hv ((Eu - Ev) / 4) he] with n hn hm
  have hvpos : 0 < v n := lt_of_lt_of_le (Real.exp_pos _) hm.1
  have hup : 0 < Real.exp (-(Eu - (Eu - Ev) / 4) * speed n) := Real.exp_pos _
  calc
    u n / v n ≤ Real.exp (-(Eu - (Eu - Ev) / 4) * speed n) / v n :=
      div_le_div_of_nonneg_right hn.2 hvpos.le
    _ ≤ Real.exp (-(Eu - (Eu - Ev) / 4) * speed n) /
        Real.exp (-(Ev + (Eu - Ev) / 4) * speed n) :=
      div_le_div_of_nonneg_left hup.le (Real.exp_pos _) hm.1
    _ = Real.exp (-((Eu - Ev) / 2) * speed n) := by
      rw [← Real.exp_sub]
      congr 1
      ring

/-- Strict rate gaps force ratios of raw masses to zero, before either global
margin normalization or data conditioning. This also applies to a real variance
parameter tending to zero, since the indexing filter is arbitrary. -/
theorem HasExponentialRate.ratio_tendsto_zero {speed u v : I → ℝ} {Eu Ev : ℝ}
    (hu : HasExponentialRate l speed u Eu)
    (hv : HasExponentialRate l speed v Ev) (hgap : Ev < Eu)
    (hs : Tendsto speed l atTop) :
    Tendsto (fun n => u n / v n) l (𝓝 0) := by
  have hc : 0 < (Eu - Ev) / 2 := by linarith
  have hexp : Tendsto (fun n => Real.exp (-((Eu - Ev) / 2) * speed n)) l (𝓝 0) := by
    have hm := hs.const_mul_atTop hc
    simpa only [Function.comp_def, neg_mul] using Real.tendsto_exp_neg_atTop_nhds_zero.comp hm
  apply squeeze_zero' _ (hu.ratio_bound hv hgap) hexp
  filter_upwards [hu.eventually_pos, hv.eventually_pos] with n hun hvn
  exact div_nonneg hun.le hvn.le

section Finite

variable {H : Type*} [Fintype H]

omit [Fintype H] in
/-- The raw-mass tail ratio needed in the strong-prior relevant-class proof.
Only hypotheses in the tail and the target need finite exponential rates. -/
theorem high_energy_tail_ratio_tendsto_zero
    (speed : I → ℝ) (w : I → H → ℝ) (E : H → ℝ)
    (hs : Tendsto speed l atTop) (target : H) (A : Finset H)
    (htarget : HasExponentialRate l speed (fun n => w n target) (E target))
    (hrate : ∀ h ∈ A, HasExponentialRate l speed (fun n => w n h) (E h))
    (hgap : ∀ h ∈ A, E target < E h) :
    Tendsto (fun n => (∑ h ∈ A, w n h) / w n target) l (𝓝 0) := by
  have hh : ∀ h ∈ A, Tendsto (fun n => w n h / w n target) l (𝓝 (0 : ℝ)) :=
    fun h hh => (hrate h hh).ratio_tendsto_zero htarget (hgap h hh) hs
  simpa only [Finset.sum_div, Finset.sum_const_zero] using tendsto_finsetSum A hh

omit [Fintype H] in
/-- Version covering nonrepresentable sign functions. Such functions have zero
raw mass and need not be assigned an artificial finite Gaussian rate. -/
theorem high_energy_or_zero_tail_ratio_tendsto_zero
    (speed : I → ℝ) (w : I → H → ℝ) (E : H → ℝ)
    (hs : Tendsto speed l atTop) (target : H) (A : Finset H)
    (htarget : HasExponentialRate l speed (fun n => w n target) (E target))
    (htail : ∀ h ∈ A,
      (∀ᶠ n in l, w n h = 0) ∨
        (HasExponentialRate l speed (fun n => w n h) (E h) ∧ E target < E h)) :
    Tendsto (fun n => (∑ h ∈ A, w n h) / w n target) l (𝓝 0) := by
  have hh : ∀ h ∈ A, Tendsto (fun n => w n h / w n target) l (𝓝 (0 : ℝ)) := by
    intro h hh
    rcases htail h hh with hz | ⟨hr, hg⟩
    · apply tendsto_const_nhds.congr'
      filter_upwards [hz] with n hn
      simp [hn]
    · exact hr.ratio_tendsto_zero htarget hg hs
  simpa only [Finset.sum_div, Finset.sum_const_zero] using tendsto_finsetSum A hh

/-- Conditional large-deviation step: every retained hypothesis with energy
strictly above that of one retained comparator has vanishing posterior mass.
No uniqueness of the minimum is assumed. -/
theorem posterior_tendsto_zero_of_rate_gap
    (speed : I → ℝ) (w : I → H → ℝ) (E : H → ℝ)
    (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ n h, 0 ≤ w n h)
    (hs : Tendsto speed l atTop)
    (hrate : ∀ h, HasExponentialRate l speed (fun n => w n h) (E h))
    (target h : H) (ht : keep target) (hgap : E target < E h) :
    Tendsto (fun n => posterior (w n) keep h) l (𝓝 0) := by
  have htpos := (hrate target).eventually_pos
  have hratio := (hrate h).ratio_tendsto_zero (hrate target) hgap hs
  apply squeeze_zero' _ _ hratio
  · filter_upwards [htpos] with n hn
    exact posterior_nonneg (w n) keep (hw n) target ht hn h
  · filter_upwards [htpos] with n hn
    exact posterior_le_weight_ratio (w n) keep (hw n) target ht hn h

/-- The entire finite set of hypotheses above a retained energy level loses
all posterior mass. In particular, choose a minimum-energy retained hypothesis
as comparator to obtain concentration on all tied minimizers together. -/
theorem posterior_high_energy_mass_tendsto_zero
    (speed : I → ℝ) (w : I → H → ℝ) (E : H → ℝ)
    (keep : H → Prop) [DecidablePred keep]
    (hw : ∀ n h, 0 ≤ w n h)
    (hs : Tendsto speed l atTop)
    (hrate : ∀ h, HasExponentialRate l speed (fun n => w n h) (E h))
    (target : H) (ht : keep target) (A : Finset H)
    (hA : ∀ h ∈ A, E target < E h) :
    Tendsto (fun n => ∑ h ∈ A, posterior (w n) keep h) l (𝓝 0) := by
  have hl : ∀ h ∈ A, Tendsto (fun n => posterior (w n) keep h) l (𝓝 (0 : ℝ)) :=
    fun h hh => posterior_tendsto_zero_of_rate_gap speed w E keep hw hs hrate target h
      ht (hA h hh)
  simpa using tendsto_finsetSum A hl

end Finite

section LimitingConfidence

variable {H X Y : Type*} [Fintype H] [Fintype X] [DecidableEq Y]

/-- A finite mixture whose mass outside a set of hard hypotheses is at most
`t` has risk at least `a*(1-t)`. This does not impose any distribution on ties. -/
theorem mixture_risk_lower_of_hard_set
    (p : H → ℝ) (err : H → ℝ) (A : Finset H) (a : ℝ)
    (hp : ∀ h, 0 ≤ p h) (_hs : ∑ h, p h = 1)
    (herr : ∀ h, 0 ≤ err h) (ha : ∀ h ∈ A, a ≤ err h) :
    a * (∑ h ∈ A, p h) ≤ ∑ h, p h * err h := by
  classical
  calc
    a * (∑ h ∈ A, p h) = ∑ h ∈ A, p h * a := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro h _
      ring
    _ ≤ ∑ h ∈ A, p h * err h := by
      exact Finset.sum_le_sum fun h hh => mul_le_mul_of_nonneg_left (ha h hh) (hp h)
    _ ≤ ∑ h, p h * err h :=
      Finset.sum_le_univ_sum_of_nonneg (fun h => mul_nonneg (hp h) (herr h))

/-- Confidence failure is always between zero and one under an input law. -/
theorem confidenceFailure_mem_unit_interval
    (p : H → ℝ) (D : X → ℝ) (predict : H → X → Y) (truth : X → Y)
    (hD : ∀ x, 0 ≤ D x) (hDs : ∑ x, D x = 1) :
    0 ≤ confidenceFailure p D predict truth ∧
      confidenceFailure p D predict truth ≤ 1 := by
  classical
  unfold confidenceFailure
  constructor
  · apply Finset.sum_nonneg
    intro x _
    split_ifs
    · exact hD x
    · exact le_refl 0
  · rw [← hDs]
    apply Finset.sum_le_sum
    intro x _
    split_ifs
    · exact le_refl _
    · exact hD x

/-- The exact limiting confidence conversion, with room for posterior mass
outside the tied minimizers. No convergence of the individual tie weights is
required. The input `t n` is any error allowance tending to zero. -/
theorem liminf_confidenceFailure_lower
    (p : ℕ → H → ℝ) (D : X → ℝ) (predict : H → X → Y) (truth : X → Y)
    (hp : ∀ᶠ n in atTop, (∀ h, 0 ≤ p n h) ∧ ∑ h, p n h = 1)
    (hD : ∀ x, 0 ≤ D x) (hDs : ∑ x, D x = 1)
    (t : ℕ → ℝ) (ht : Tendsto t atTop (𝓝 0))
    (hrisk : ∀ᶠ n in atTop,
      (3 / 8 : ℝ) - t n ≤ averageRisk (p n) D predict truth) :
    (1 / 16 : ℝ) ≤
      Filter.liminf (fun n => confidenceFailure (p n) D predict truth) atTop := by
  have hlower : ∀ᶠ n in atTop,
      (1 / 16 : ℝ) - (3 / 2 : ℝ) * t n ≤
        confidenceFailure (p n) D predict truth := by
    filter_upwards [hp, hrisk] with n hpn hr
    have hh := risk_le_one_third_add_failure (p n) D predict truth
      hpn.1 hpn.2 hD hDs
    linarith
  have hl : Tendsto (fun n => (1 / 16 : ℝ) - (3 / 2 : ℝ) * t n)
      atTop (𝓝 (1 / 16 : ℝ)) := by
    convert tendsto_const_nhds.sub (ht.const_mul (3 / 2 : ℝ)) using 1; simp
  have hub : IsCoboundedUnder (· ≥ ·) atTop
      (fun n => confidenceFailure (p n) D predict truth) :=
    isCoboundedUnder_ge_of_le atTop fun n =>
      (confidenceFailure_mem_unit_interval (p n) D predict truth hD hDs).2
  have hc := liminf_le_liminf hlower hl.isBoundedUnder_ge hub
  rwa [hl.liminf_eq] at hc

end LimitingConfidence

end NeuralGeneralization
