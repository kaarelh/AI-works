import NeuralGeneralization.OnlineLowerTanhSharpParity
import NeuralGeneralization.OnlineLowerTanhGlobalBalancedGain

/-! # Equality classification for every sufficiently large intrinsic parity

This strengthens the sharp inequality to a statement about every actual
maximizer, and identifies the magnitude using the proved strict balanced gain.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

theorem eventual_intrinsic_maximizer_equal_magnitudes :
    ∀ᶠ r : ℕ in atTop, ∀ u : Fin (2*r+1) → ℝ,
      IsIntrinsicMaximizer u → ∃ a : ℝ, a ∈ Icc (1:ℝ) 2 ∧ ∀ i, |u i| = a := by
  by_contra hbad
  have hf : ∃ᶠ r : ℕ in atTop, ¬(∀ u : Fin (2*r+1) → ℝ,
      IsIntrinsicMaximizer u → ∃ a : ℝ, a ∈ Icc (1:ℝ) 2 ∧ ∀ i, |u i| = a) := by
    simpa only [Filter.Frequently,not_not] using hbad
  have hex (k : ℕ) : ∃ r, k+3 ≤ r ∧ ¬(∀ u : Fin (2*r+1) → ℝ,
      IsIntrinsicMaximizer u → ∃ a : ℝ, a ∈ Icc (1:ℝ) 2 ∧ ∀ i, |u i| = a) :=
    frequently_atTop.1 hf (k+3)
  choose r hr hfail using hex
  have hrt : Tendsto r atTop atTop :=
    tendsto_atTop_mono (fun k => (Nat.le_add_right k 3).trans (hr k)) tendsto_id
  have huEx (k : ℕ) : ∃ u : Fin (2*r k+1) → ℝ,
      IsIntrinsicMaximizer u ∧ ¬(∃ a : ℝ, a ∈ Icc (1:ℝ) 2 ∧ ∀ i, |u i|=a) := by
    have hh := hfail k
    push Not at hh
    obtain ⟨u,hu,hx⟩ := hh
    refine ⟨u,hu,?_⟩
    rintro ⟨a,ha,hi⟩
    obtain ⟨i,hne⟩ := hx a ha
    exact hne (hi i)
  choose u hu hnot using huEx
  obtain ⟨O⟩ := exists_optimizer_lattice_limit r (fun k => by have hh:=hr k; omega) u hu
  obtain ⟨g,hg,hodd,hQ,ha,hp⟩ := O.classified hrt hu
  let B := O.nearBulk hrt hu g ha hp
  obtain ⟨k,hk,hamp⟩ := (B.eventually_all_equal.and B.bulkAmplitude_eventually_mem).exists
  exact hnot (O.map k) ⟨B.bulkAmplitude k,hamp,fun i => hk i⟩

/-- Every actual nonzero optimizer, including arbitrary coordinate signs,
is exactly a balanced optimizer once the odd degree is sufficiently large. -/
theorem eventual_intrinsic_maximizer_classification :
    ∀ᶠ r : ℕ in atTop, ∀ u : Fin (2*r+1) → ℝ,
      IsIntrinsicMaximizer u → ∀ i, |u i| = balancedGain r := by
  filter_upwards [eventual_intrinsic_maximizer_equal_magnitudes,
    eventually_ge_atTop 2,
    (tendsto_natCast_atTop_atTop (R:=ℝ)).eventually_gt_atTop actualGainBranch.threshold]
    with r hr hr2 hthreshold u hu
  obtain ⟨a,ha,heq⟩ := hr u hu
  have hfun : (fun i => |u i|) = (fun _ => a) := funext heq
  have hmax := hu (fun _ => balancedGain r)
  rw [←intrinsicGain_abs_weights u,hfun,intrinsicGain_constant r a ha.1,
    intrinsicGain_constant r (balancedGain r) (balancedGain_mem r).1] at hmax
  have hn : (0:ℝ) < Real.sqrt (2*r+1:ℕ) := Real.sqrt_pos.mpr (by positivity)
  have hratio := (div_le_div_iff_of_pos_right hn).mp hmax
  have heqa : a=balancedGain r := by
    by_contra hne
    have hstrict := balancedGain_global_strict_max actualGainBranch r hr2
      (by push_cast; linarith) a (by linarith [ha.1]) hne
    exact (not_lt_of_ge hratio) hstrict
  simpa only [heqa] using heq

lemma intrinsicGain_le_of_sharp {n:ℕ} {w:ℝ} (hw:0<w)
    (hsharp:IntrinsicParityBound n w) (u:Fin n→ℝ) : intrinsicGain u≤1/w := by
  by_cases hz:Real.sqrt (incomingEnergy u)=0
  · simp only [intrinsicGain,hz,div_zero]
    positivity
  have hp:0<Real.sqrt (incomingEnergy u):=lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm hz)
  apply (div_le_div_iff₀ hp hw).mpr
  simpa only [one_mul,mul_comm] using hsharp u

/-- Exact gain equality in the unrestricted intrinsic problem. -/
theorem eventual_intrinsic_gain_bound_and_equality :
    ∀ᶠr:ℕ in atTop,∀u:Fin (2*r+1)→ℝ,
      intrinsicGain u≤1/balancedCost r ∧
      (intrinsicGain u=1/balancedCost r ↔ ∀i,|u i|=balancedGain r) := by
  filter_upwards [eventual_intrinsicParityBound,eventual_intrinsic_maximizer_classification]
    with r hsharp hclass u
  have hbound:=intrinsicGain_le_of_sharp (balancedCost_pos r) hsharp
  refine ⟨hbound u,?_⟩
  constructor
  · intro he
    exact hclass u (fun v=>by rw [he];exact hbound v)
  · intro he
    have hfun:(fun i=>|u i|)=(fun _=>balancedGain r):=funext he
    rw [←intrinsicGain_abs_weights u,hfun,intrinsicGain_balanced]

/-- Natural-degree version, convenient for arbitrary selected physical supports. -/
theorem exists_intrinsic_gain_equality_threshold :
    ∃n₀:ℕ,∀n:ℕ,n₀≤n → Odd n → ∀u:Fin n→ℝ,
      intrinsicGain u≤1/balancedCost (n/2) ∧
      (intrinsicGain u=1/balancedCost (n/2) ↔ ∀i,|u i|=balancedGain (n/2)) := by
  obtain ⟨r₀,hr₀⟩:=eventually_atTop.mp eventual_intrinsic_gain_bound_and_equality
  refine ⟨2*r₀+1,?_⟩
  intro n hn hodd u
  obtain ⟨r,hr⟩:=hodd
  have he:n=2*r+1:=by omega
  subst n
  simpa only [show (2*r+1)/2=r by omega] using hr₀ r (by omega) u

end NeuralGeneralization.OnlineLowerTanh
