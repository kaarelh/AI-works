import NeuralGeneralization.OnlineLowerReluRailScore
import Mathlib.Data.Finset.Max
import Mathlib.Algebra.BigOperators.Field

/-! # The randomized-minimum estimate for explicit conditioned rail scores -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def finiteAverage {Ω : Type*} [Fintype Ω] (f : Ω → ℝ) : ℝ :=
  (∑ ω, f ω) / Fintype.card Ω

theorem finiteAverage_const {Ω : Type*} [Fintype Ω] [Nonempty Ω] (c : ℝ) :
    finiteAverage (fun _ : Ω => c) = c := by
  unfold finiteAverage
  simp [Fintype.card_ne_zero]

theorem finiteAverage_abs_le {Ω : Type*} [Fintype Ω] (f g : Ω → ℝ)
    (h : ∀ ω, |f ω| ≤ g ω) : |finiteAverage f| ≤ finiteAverage g := by
  unfold finiteAverage
  rw [abs_div, Nat.abs_cast]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg _)
  exact (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum (fun ω _ => h ω))

theorem finiteAverage_mono {Ω : Type*} [Fintype Ω] (f g : Ω → ℝ)
    (h : ∀ ω, f ω ≤ g ω) : finiteAverage f ≤ finiteAverage g := by
  unfold finiteAverage
  exact div_le_div_of_nonneg_right (Finset.sum_le_sum (fun ω _ => h ω)) (Nat.cast_nonneg _)

theorem finiteAverage_mul_left {Ω : Type*} [Fintype Ω] (c : ℝ) (f : Ω → ℝ) :
    finiteAverage (fun ω => c * f ω) = c * finiteAverage f := by
  unfold finiteAverage
  rw [← Finset.mul_sum]
  ring

def topSubsetCoefficient {α : Type*} [DecidableEq α]
    (selected : Finset α) (f : Finset α → ℝ) : ℝ :=
  (∑ S ∈ selected.powerset, (-1 : ℝ) ^ S.card * f S) /
    (2 : ℝ) ^ selected.card

theorem topSubsetCoefficient_average {α Ω : Type*} [DecidableEq α] [Fintype Ω]
    (selected : Finset α) (f : Ω → Finset α → ℝ) :
    topSubsetCoefficient selected (fun S => finiteAverage (fun ω => f ω S)) =
      finiteAverage (fun ω => topSubsetCoefficient selected (f ω)) := by
  unfold topSubsetCoefficient finiteAverage
  simp_rw [← mul_div_assoc, Finset.mul_sum, ← Finset.sum_div]
  rw [Finset.sum_comm]
  ring

def minimumRailAmplitude {ι : Type*} [Fintype ι] [Nonempty ι]
    (a b : ι → ℝ) (ε : ι → Bool) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun i => a i + railBit (ε i) * b i)

theorem minimumRailAmplitude_le {ι : Type*} [Fintype ι] [Nonempty ι]
    (a b : ι → ℝ) (ε : ι → Bool) (i : ι) :
    minimumRailAmplitude a b ε ≤ a i + railBit (ε i) * b i :=
  Finset.inf'_le _ (Finset.mem_univ i)

theorem average_minimumRailAmplitude_le_unpaired {ι : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι]
    (a b : ι → ℝ) (i : ι) (hbi : b i = 0) :
    finiteAverage (minimumRailAmplitude a b) ≤ a i := by
  have h := finiteAverage_mono (minimumRailAmplitude a b) (fun _ : ι → Bool => a i)
    (fun ε => by simpa [hbi] using minimumRailAmplitude_le a b ε i)
  rwa [finiteAverage_const] at h

/-- The literal finite coefficient of a fixed conditioned score is bounded
by the smallest randomized distinguished-coordinate coefficient. -/
theorem conditioned_selected_minimum_bound {ι α : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (a b c : ι → ℝ) (bias : ℝ) (ε : ι → Bool)
    (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) (hc : ∀ i, |c i| ≤ b i) :
    |topSubsetCoefficient selected (fun S =>
        max (conditionedSelectedScore blocks distinguished a c
          (fun i => a i + railBit (ε i) * b i) bias S) 0)| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) * minimumRailAmplitude a b ε := by
  classical
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_inf'
    (s := (Finset.univ : Finset ι)) Finset.univ_nonempty
    (fun i => a i + railBit (ε i) * b i)
  have h := conditioned_selected_parity_bound selected n hcard blocks distinguished
    hinj hdisjoint hselected a c (fun i => a i + railBit (ε i) * b i) bias
    (fun i => (hc i).trans (hab i))
    (randomized_distinguished_coefficient_nonneg a b hab hb ε) i
  unfold topSubsetCoefficient
  rw [hcard]
  unfold minimumRailAmplitude
  rw [hi]
  convert h using 1 <;> ring

/-- Randomized minimum, with all averages over finite sign/free-bit
configurations explicit. The conditional rail scores are concrete formulas;
their monotonicity and coordinate finite differences are proved above. -/
theorem randomized_minimum_bound {ι α Ω : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    [Fintype Ω] [Nonempty Ω]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (a b : ι → ℝ) (c : (ι → Bool) → Ω → ι → ℝ)
    (bias : (ι → Bool) → Ω → ℝ)
    (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i)
    (hc : ∀ ε ω i, |c ε ω i| ≤ b i) :
    |topSubsetCoefficient selected (fun S => finiteAverage (fun ε : ι → Bool =>
        finiteAverage (fun ω : Ω =>
          max (conditionedSelectedScore blocks distinguished a (c ε ω)
            (fun i => a i + railBit (ε i) * b i) (bias ε ω) S) 0)))| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        finiteAverage (minimumRailAmplitude a b) := by
  rw [topSubsetCoefficient_average]
  simp_rw [topSubsetCoefficient_average]
  have hε (ε : ι → Bool) :
      |finiteAverage (fun ω : Ω => topSubsetCoefficient selected (fun S =>
        max (conditionedSelectedScore blocks distinguished a (c ε ω)
          (fun i => a i + railBit (ε i) * b i) (bias ε ω) S) 0))| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) * minimumRailAmplitude a b ε := by
    have h := finiteAverage_abs_le _
      (fun _ : Ω => (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        minimumRailAmplitude a b ε)
      (fun ω => conditioned_selected_minimum_bound selected n hcard blocks distinguished
        hinj hdisjoint hselected a b (c ε ω) (bias ε ω) ε hb hab (hc ε ω))
    rwa [finiteAverage_const] at h
  have h := finiteAverage_abs_le _ _ hε
  rwa [finiteAverage_mul_left] at h

end NeuralGeneralization.OnlineLowerRelu
