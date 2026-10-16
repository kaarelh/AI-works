import NeuralGeneralization.ParameterStability
import Mathlib.Algebra.Order.Floor.Ring
import Mathlib.Data.Int.Interval
import Mathlib.Data.Fintype.Card
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Lean.Elab.Tactic.Omega

/-!+# Counting actual bounded-parameter network functions

A finite integer grid injectively encodes the Boolean functions realized with
strict margin. The mesh size comes from the proved parameter-stability bound.
This supplies the counting step once a compression theorem gives a width and
weight bound. It does not assume the function count as a certificate.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

theorem margin_functions_eq_of_output_close {d N r : ℕ}
    (φ : ℝ → ℝ) (w v : Weights d N r) (f g : BooleanFunction d)
    (hf : w ∈ marginEvent φ (1 / 2) f)
    (hg : v ∈ marginEvent φ (1 / 2) g)
    (hclose : ∀ x, |networkOutput φ w x - networkOutput φ v x| ≤ 1) :
    f = g := by
  funext x
  have hfx := hf x
  have hgx := hg x
  have hc := hclose x
  have hu := le_abs_self (networkOutput φ w x - networkOutput φ v x)
  have hl := neg_le_abs (networkOutput φ w x - networkOutput φ v x)
  cases hfb : f x <;> cases hgb : g x <;> simp_all [labelReal] <;> linarith [hclose x]

/-- A concrete finite class of strict-margin functions with bounded weights. -/
def BoundedNetworkFunctions (d N r B : ℕ) (φ : ℝ → ℝ) :=
  {f : BooleanFunction d // ∃ w : Weights d N r,
    w ∈ marginEvent φ (1 / 2) f ∧ boundedWeights B w}

instance (d N r B : ℕ) (φ : ℝ → ℝ) :
    Fintype (BoundedNetworkFunctions d N r B φ) := by
  classical
  unfold BoundedNetworkFunctions
  infer_instance

/-- The actual grid count. The sensitivity premise is a deterministic numeric
inequality in `d,N,r,B,T`, not a hypothesis about a function class or a learner. -/
theorem boundedNetworkFunctions_card_le (d N r B T : ℕ)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (hT : 0 < T)
    (hsensitivity :
      nextSensitivity N B (hiddenSensitivity d N B r) ≤ (T : ℝ)) :
    Fintype.card (BoundedNetworkFunctions d N r B φ) ≤
      (2 * (B * T) + 1) ^ Fintype.card (WeightIndex d N r) := by
  classical
  let H := BoundedNetworkFunctions d N r B φ
  let Q : ℕ := B * T
  let Z := ↥(Finset.Icc (-(Q : ℤ)) (Q : ℤ))
  let w (f : H) : Weights d N r := Classical.choose f.property
  have hw (f : H) :
      w f ∈ marginEvent φ (1 / 2) f.val ∧ boundedWeights B (w f) :=
    Classical.choose_spec f.property
  have hTR : (0 : ℝ) < T := by exact_mod_cast hT
  have hcode (f : H) (i : WeightIndex d N r) :
      ⌊(T : ℝ) * w f i⌋ ∈ Finset.Icc (-(Q : ℤ)) (Q : ℤ) := by
    have hb := abs_le.mp ((hw f).2 i)
    have hlo : -(Q : ℝ) ≤ (T : ℝ) * w f i := by
      dsimp [Q]
      push_cast
      nlinarith [mul_le_mul_of_nonneg_left hb.1 hTR.le]
    have hhi : (T : ℝ) * w f i ≤ (Q : ℝ) := by
      dsimp [Q]
      push_cast
      nlinarith [mul_le_mul_of_nonneg_left hb.2 hTR.le]
    apply Finset.mem_Icc.mpr
    constructor
    · apply Int.le_floor.mpr
      simpa using hlo
    · have hh := Int.floor_mono hhi
      simpa using hh
  let code (f : H) : WeightIndex d N r → Z :=
    fun i => ⟨⌊(T : ℝ) * w f i⌋, hcode f i⟩
  have hinj : Function.Injective code := by
    intro f g hfg
    apply Subtype.ext
    apply margin_functions_eq_of_output_close φ (w f) (w g) f.val g.val (hw f).1 (hw g).1
    intro x
    have hweights (i : WeightIndex d N r) : |w f i - w g i| ≤ 1 / (T : ℝ) := by
      have heq : ⌊(T : ℝ) * w f i⌋ = ⌊(T : ℝ) * w g i⌋ :=
        congrArg Subtype.val (congrFun hfg i)
      have hh := Int.abs_sub_lt_one_of_floor_eq_floor heq
      rw [← mul_sub, abs_mul, abs_of_pos hTR] at hh
      apply (le_div_iff₀ hTR).mpr
      nlinarith
    have hh := networkOutput_parameter_stability φ hφ (w f) (w g)
      (B : ℝ) (1 / (T : ℝ)) (by positivity) (by positivity) (hw g).2 hweights x
    calc
      _ ≤ (1 / (T : ℝ)) * nextSensitivity N B (hiddenSensitivity d N B r) := hh
      _ ≤ (1 / (T : ℝ)) * (T : ℝ) :=
        mul_le_mul_of_nonneg_left hsensitivity (by positivity)
      _ = 1 := by field_simp
  have hz : Fintype.card Z = 2 * Q + 1 := by
    change Fintype.card ↥(Finset.Icc (-(Q : ℤ)) (Q : ℤ)) = _
    rw [Fintype.card_coe, Int.card_Icc]
    omega
  have hh := Fintype.card_le_of_injective code hinj
  simpa only [Fintype.card_fun, hz, Q] using hh

theorem hiddenSensitivity_le_polynomial (d N B r : ℕ) :
    hiddenSensitivity d N B r ≤
      ((d : ℝ) + 1) * ((N : ℝ) * (B + 1) + 1) ^ r := by
  induction r with
  | zero => simp [hiddenSensitivity]
  | succ r ih =>
      let X : ℝ := ((d : ℝ) + 1) * ((N : ℝ) * (B + 1) + 1) ^ r
      have hbase : (1 : ℝ) ≤ (N : ℝ) * (B + 1) + 1 := by
        have hp : (0 : ℝ) ≤ (N : ℝ) * (B + 1) := by positivity
        linarith
      have hd : (1 : ℝ) ≤ (d : ℝ) + 1 := by linarith [Nat.cast_nonneg (α := ℝ) d]
      have hX : 1 ≤ X := one_le_mul_of_one_le_of_one_le hd (one_le_pow₀ hbase)
      change nextSensitivity N B (hiddenSensitivity d N B r) ≤ _
      calc
        _ ≤ (N : ℝ) * (1 + (B : ℝ) * X) := by
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          have hm := mul_le_mul_of_nonneg_left ih (Nat.cast_nonneg (α := ℝ) B)
          exact add_le_add (le_refl 1) hm
        _ ≤ (N : ℝ) * (X + (B : ℝ) * X) :=
          mul_le_mul_of_nonneg_left (add_le_add hX (le_refl ((B : ℝ) * X))) (by positivity)
        _ ≤ ((N : ℝ) * (B + 1) + 1) * X := by
          have hx : 0 ≤ X := le_trans zero_le_one hX
          nlinarith
        _ = _ := by dsimp [X]; rw [pow_succ]; ring

/-- An explicit integer inverse mesh, polynomial at fixed depth. -/
def parameterMesh (d N r B : ℕ) : ℕ :=
  (d + 1) * (N * (B + 1) + 1) ^ (r + 1)

theorem parameterMesh_pos (d N r B : ℕ) : 0 < parameterMesh d N r B := by
  unfold parameterMesh
  positivity

theorem sensitivity_le_parameterMesh (d N r B : ℕ) :
    nextSensitivity N B (hiddenSensitivity d N B r) ≤ (parameterMesh d N r B : ℝ) := by
  have h := hiddenSensitivity_le_polynomial d N B (r + 1)
  simpa [hiddenSensitivity, parameterMesh] using h

/-- Unconditional bounded-network count with an explicit grid. Its logarithm
is polynomial in dimension and width for every fixed depth and polynomial
weight bound. No capacity hypothesis is left in this result. -/
theorem boundedNetworkFunctions_explicit_card_le (d N r B : ℕ)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) :
    Fintype.card (BoundedNetworkFunctions d N r B φ) ≤
      (2 * (B * parameterMesh d N r B) + 1) ^ Fintype.card (WeightIndex d N r) :=
  boundedNetworkFunctions_card_le d N r B (parameterMesh d N r B) φ hφ
    (parameterMesh_pos d N r B) (sensitivity_le_parameterMesh d N r B)

end NeuralGeneralization.ConcreteModel
