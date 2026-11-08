import NeuralGeneralization.NonpolynomialInterpolationFinite
import NeuralGeneralization.Network

/-! A single finite dictionary realizes every Boolean gate of a fixed arity.
All its coefficients are finite real numbers, with no regularity assumption
beyond the original continuity and nonpolynomiality of the activation. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel

/-- The finite interpolation theorem in the usual dot-product form. -/
theorem finite_dot_interpolation {κ : Type*} [Fintype κ]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hn : Nonpolynomial φ)
    {v : ι → κ → ℝ} [Fintype ι] (hv : Function.Injective v) :
    ∃ a : ι → κ → ℝ, ∃ b : ι → ℝ, ∀ y : ι → ℝ, ∃ c : ι → ℝ,
      ∀ i, y i = ∑ j, c j * φ ((∑ k, a j k * v i k) + b j) := by
  classical
  obtain ⟨ℓ, a, b, hab⟩ := finite_vector_interpolation hφ hn hv
  refine ⟨fun j k => a j * ℓ (fun l => if k = l then 1 else 0), b, ?_⟩
  intro y
  obtain ⟨c, hc⟩ := hab y
  refine ⟨c, fun i => ?_⟩
  rw [hc i]
  apply Finset.sum_congr rfl
  intro j _
  congr 3
  rw [ℓ.pi_apply_eq_sum_univ (v i), Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  simp only [smul_eq_mul]
  ring

/-- The gate dictionary, including an explicit constant hidden-unit value. -/
structure GateDictionary (φ : ℝ → ℝ) (q : ℕ) where
  input : Cube q → Fin q → ℝ
  bias : Cube q → ℝ
  readout : BooleanFunction q → Cube q → ℝ
  exact_gate : ∀ (g : BooleanFunction q) (x : Cube q),
    (∑ j, readout g j * φ ((∑ k, input j k * labelReal (x k)) + bias j)) = labelReal (g x)
  constantInput : ℝ
  constant_ne_zero : φ constantInput ≠ 0

/-- Every continuous nonpolynomial activation has a finite universal dictionary
for all Boolean gates of arity `q`, using exactly `2^q` features per signal. -/
theorem exists_gateDictionary {φ : ℝ → ℝ} (hφ : Continuous φ) (hn : Nonpolynomial φ)
    (q : ℕ) : Nonempty (GateDictionary φ q) := by
  have hinj : Function.Injective (fun x : Cube q => fun k => labelReal (x k)) := by
    intro x y h
    funext k
    have hk := congrFun h k
    cases hx : x k <;> cases hy : y k <;>
      simp only [hx, hy, labelReal_true, labelReal_false] at hk ⊢ <;> norm_num at *
  obtain ⟨a, b, hab⟩ := finite_dot_interpolation hφ hn hinj
  have hd (g : BooleanFunction q) : ∃ c : Cube q → ℝ, ∀ x,
      labelReal (g x) = ∑ j, c j * φ ((∑ k, a j k * labelReal (x k)) + b j) :=
    hab (fun x => labelReal (g x))
  choose c hc using hd
  have hne : ∃ β, φ β ≠ 0 := by
    by_contra! hz
    exact hn ⟨0, fun x => by simpa using hz x⟩
  obtain ⟨β, hβ⟩ := hne
  exact ⟨⟨a, b, c, fun g x => (hc g x).symm, β, hβ⟩⟩

end NeuralGeneralization.NonpolynomialInterpolation
