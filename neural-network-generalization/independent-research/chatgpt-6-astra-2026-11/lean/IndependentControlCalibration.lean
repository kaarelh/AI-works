import Mathlib

/-!
Selected deterministic ingredients of the observed-margin control construction.
The neural atom inequality, code identification, all-dimensional construction,
Gaussian posterior limit, and complete main theorem are not formalized here.
-/

namespace IndependentResearch
open scoped BigOperators

/-- The control coefficient is fixed by the average of the dual. -/
theorem control_dual_average (wc w0 a δ : ℝ) (hδ : δ ≠ 1) :
    -w0 + 2 * a + ((wc + w0 - 2 * a) / (1 - δ)) * (1 - δ) = wc := by
  have hd : 1 - δ ≠ 0 := by intro h; apply hδ; linarith
  field_simp
  <;> ring

/-- Both calibration faces have the required strict signs outside the holes. -/
theorem control_dual_outside_signs (q γ : ℝ) (hq : q < 0) (hγ : 0 < γ) :
    0 < q + (-q + γ) ∧ q - (-q + γ) < 0 := by
  constructor <;> linarith

/-- A live fiber has zero unobserved-face multiplier. -/
theorem control_dual_live_faces (q : ℝ) (hq : 0 ≤ q) :
    0 ≤ q + q ∧ q - q = 0 := by
  constructor <;> linarith

/-- A removed fiber uses its observed negative face. -/
theorem control_dual_removed_faces (q : ℝ) (hq : q < 0) :
    q + (-q) = 0 ∧ q - (-q) < 0 := by
  constructor <;> linarith

/-- A strict rail-weight gap absorbs the nonconstant control perturbation. -/
theorem control_mixed_coefficient_strict (h q perturb w w' : ℝ)
    (hh : h = -q + perturb) (hq : |q| ≤ w)
    (hp : |perturb| < 1) (hgap : w + 1 < w') :
    |h| < w' := by
  calc
    |h| = |-q + perturb| := by rw [hh]
    _ ≤ |-q| + |perturb| := abs_add_le _ _
    _ = |q| + |perturb| := by rw [abs_neg]
    _ < w + 1 := by linarith
    _ < w' := hgap

/-- Translation-invariant variance cannot be supported on an independent set. -/
theorem invariant_supported_on_independent_set_zero {X : Type*}
    (T : X → X) (S : Set X) (ell : X → ℝ)
    (hinvariant : ∀ x, ell (T x) = ell x)
    (houtside : ∀ x, x ∉ S → ell x = 0)
    (hindependent : ∀ x, x ∈ S → T x ∉ S) :
    ∀ x, ell x = 0 := by
  intro x
  by_cases hx : x ∈ S
  · rw [← hinvariant x]
    exact houtside (T x) (hindependent x hx)
  · exact houtside x hx

/-- If only one logical location can hide both tag faces, tag-invariant
variance must be supported at that location. -/
theorem tag_invariant_singleton_support {X : Type*}
    (v : X) (S : Set (X × Bool)) (ell : X → Bool → ℝ)
    (hinvariant : ∀ x, ell x true = ell x false)
    (houtside : ∀ x t, (x, t) ∉ S → ell x t = 0)
    (hpair : ∀ x, x ≠ v → (x, true) ∉ S ∨ (x, false) ∉ S) :
    ∀ x, x ≠ v → ∀ t, ell x t = 0 := by
  intro x hx t
  rcases hpair x hx with ht | hf
  · have hz := houtside x true ht
    cases t
    · rw [← hinvariant x]
      exact hz
    · exact hz
  · have hz := houtside x false hf
    cases t
    · exact hz
    · rw [hinvariant x]
      exact hz

/-- A singleton-supported function cannot have a missing nonzero character
coefficient. This is the final off-code rigidity step. -/
theorem singleton_support_missing_character_zero {X : Type*} [Fintype X]
    [DecidableEq X] (v : X) (g char : X → ℝ)
    (hsupport : ∀ x, x ≠ v → g x = 0)
    (hchar : char v ≠ 0) (hcoeff : ∑ x, char x * g x = 0) :
    ∀ x, g x = 0 := by
  have hs : (∑ x, char x * g x) = char v * g v := by
    apply Finset.sum_eq_single v
    · intro x _ hx
      rw [hsupport x hx, mul_zero]
    · simp
  have hv : g v = 0 := (mul_eq_zero.mp (hs.symm.trans hcoeff)).resolve_left hchar
  intro x
  by_cases hx : x = v
  · simpa [hx] using hv
  · exact hsupport x hx

/-- The two active calibration faces pin the offset and the base value. -/
theorem two_control_margins_pin_offset (g a : ℝ)
    (hp : g + a = 1 / 2) (hm : g - a = -(1 / 2)) :
    a = 1 / 2 ∧ g = 0 := by
  constructor <;> linarith

/-- A forbidden character pins the last exceptional mass to one. -/
theorem missing_character_pins_exceptional_mass (t M : ℝ)
    (hM : M ≠ 0) (h : (1 - t) / M = 0) : t = 1 := by
  have hn : 1 - t = 0 := (div_eq_zero_iff.mp h).resolve_right hM
  linarith

/-- The shallow teacher's positive control face has margin at least one. -/
theorem control_teacher_positive_face (m violations : ℕ)
    (hv : violations ≤ m) :
    1 ≤ ((m : ℤ) - 2 * violations) + m + 1 := by omega

/-- On the negative control face, exactly the zero syndrome is positive. -/
theorem control_teacher_negative_face (m violations : ℕ) :
    (((m : ℤ) - 2 * violations) - m + 1 = 1 ↔ violations = 0) ∧
    (0 < violations → ((m : ℤ) - 2 * violations) - m + 1 ≤ -1) := by
  constructor <;> omega


/-- The precise exceptional-fiber set in the control proof. -/
def controlExceptional {X : Type*} (zero v : X) (U L : Set X)
    (x : X) (t : Bool) : Prop :=
  (x = zero ∧ t = true) ∨ (x ∈ L ∧ t = false) ∨
  (x ∈ U ∧ x ∉ L ∧ t = true) ∨ (x = v ∧ t = true)

/-- Away from the current vertex, at most one control face is exceptional. -/
theorem control_exceptional_pair_unique {X : Type*}
    (zero v : X) (U L : Set X) (hzero : zero ∉ L)
    (x : X) (hx : x ≠ v) :
    ¬ (controlExceptional zero v U L x true ∧
       controlExceptional zero v U L x false) := by
  simp only [controlExceptional, Bool.false_eq_true, Bool.true_eq_false,
    and_false, false_and, or_false, false_or, and_true]
  intro h
  rcases h.1 with hz | hr | hv
  · exact hzero (hz ▸ h.2)
  · exact hr.2 h.2
  · exact hx hv

/-- The projection of every exceptional fiber lies in U or at the anchor. -/
theorem control_exceptional_projection {X : Type*}
    (zero v : X) (U L : Set X) (hsub : L ⊆ U) (hv : v ∈ U)
    (x : X) (t : Bool) (hx : controlExceptional zero v U L x t) :
    x ∈ U ∪ {zero} := by
  rcases hx with hz | hl | hr | hv'
  · exact Or.inr hz.1
  · exact Or.inl (hsub hl.1)
  · exact Or.inl hr.1
  · exact Or.inl (hv'.1 ▸ hv)

/-- Old-column independence passes to the exact exceptional-fiber set. -/
theorem control_exceptional_old_independence {X : Type*}
    (zero v : X) (U L : Set X) (hsub : L ⊆ U) (hv : v ∈ U)
    (T : X → X)
    (hind : ∀ x, x ∈ U ∪ {zero} → T x ∉ U ∪ {zero})
    (x : X) (t : Bool) (hx : controlExceptional zero v U L x t) :
    ¬ controlExceptional zero v U L (T x) t := by
  intro ht
  exact hind x (control_exceptional_projection zero v U L hsub hv x t hx)
    (control_exceptional_projection zero v U L hsub hv (T x) t ht)

end IndependentResearch
