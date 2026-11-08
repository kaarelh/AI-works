import NeuralGeneralization.OnlineLowerTanhIntrinsicMaximum
import NeuralGeneralization.OnlineLowerTanhNearBulkAllEqual

/-! # The eventual sharp intrinsic parity inequality for ordinary tanh

The proof is an actual maximizer contradiction. The full localization,
empirical classification, exact averaging, and outlier exclusion are invoked
through proved theorems about the original finite-cube coefficients.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

theorem eventual_intrinsicParityBound :
    ∀ᶠ r : ℕ in atTop,IntrinsicParityBound (2*r+1) (balancedCost r) := by
  by_contra hbad
  have hf : ∃ᶠ r : ℕ in atTop,¬IntrinsicParityBound (2*r+1) (balancedCost r) := by
    simpa only [Filter.Frequently,not_not] using hbad
  have hex (k : ℕ) : ∃ r,k+3 ≤ r ∧ ¬IntrinsicParityBound (2*r+1) (balancedCost r) :=
    frequently_atTop.1 hf (k+3)
  choose r hr hfail using hex
  have hrt : Tendsto r atTop atTop :=
    tendsto_atTop_mono (fun k => (Nat.le_add_right k 3).trans (hr k)) tendsto_id
  have hmaxex (k : ℕ) : ∃ u : Fin (2*r k+1) → ℝ,
      IsIntrinsicMaximizer u ∧ 1/balancedCost (r k) < intrinsicGain u :=
    exists_bad_intrinsic_maximizer (r k) (by have hh:=hr k;omega) (hfail k)
  choose u hu hgain using hmaxex
  obtain ⟨O⟩ := exists_optimizer_lattice_limit r (fun k => by have hh:=hr k;omega) u hu
  obtain ⟨g,hg,hodd,hQ,ha,hp⟩ := O.classified hrt hu
  let B := O.nearBulk hrt hu g ha hp
  obtain ⟨k,hk,hamp⟩ := (B.eventually_all_equal.and B.bulkAmplitude_eventually_mem).exists
  have heq : (fun i => |u (O.map k) i|)=(fun _ => B.bulkAmplitude k) := by
    funext i
    exact hk i
  have hle := intrinsicGain_constant_le (r (O.map k)) (B.bulkAmplitude k) hamp
  rw [←heq,intrinsicGain_abs_weights] at hle
  exact (not_lt_of_ge hle) (hgain (O.map k))

/-- The sharp coefficient cost is the actual balanced maximizing cost, for
all sufficiently large odd degrees. -/
theorem exists_intrinsicParityBound_threshold :
    ∃ n₀ : ℕ,∀ n : ℕ,n₀ ≤ n → Odd n → IntrinsicParityBound n (balancedCost (n/2)) := by
  obtain ⟨r₀,hr₀⟩ := eventually_atTop.mp eventual_intrinsicParityBound
  refine ⟨2*r₀+1,?_⟩
  intro n hn hodd
  obtain ⟨r,rfl⟩ := hodd
  have hr : r₀ ≤ r := by omega
  simpa only [show (2*r+1)/2=r by omega] using hr₀ r hr

end NeuralGeneralization.OnlineLowerTanh
