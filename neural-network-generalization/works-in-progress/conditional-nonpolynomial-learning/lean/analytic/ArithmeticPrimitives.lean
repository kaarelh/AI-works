import QuantizedScalarLayer
import CanonicalCompletion
import InverseRootClip

/-! A concrete scalar instruction set sufficient for canonical feature-map
evaluation. All range and continuity estimates are proved for the instructions. -/
noncomputable section
namespace ConditionalNonpolynomial.Analytic

inductive ScalarInstruction where
  | identity
  | normalizedTanh (a : ℝ)
  | square
  | clippedSqrt
  | inverseRootClip

def ScalarInstruction.eval : ScalarInstruction → ℝ → ℝ
  | .identity, s => s
  | .normalizedTanh a, s => ConditionalNonpolynomial.Analytic.normalizedTanh a s
  | .square, s => s^2
  | .clippedSqrt, s => Real.sqrt (max 0 s)
  | .inverseRootClip, s => ConditionalNonpolynomial.Analytic.inverseRootClip s

def arithmeticModulus (P r : ℝ) : ℝ := 2*P*r+Real.sqrt r

lemma arithmeticModulus_monotone (P : ℝ) (hP : 0 ≤ P) : Monotone (arithmeticModulus P) := by
  intro r s hrs
  exact add_le_add (mul_le_mul_of_nonneg_left hrs (by positivity)) (Real.sqrt_le_sqrt hrs)

lemma scalar_square_difference (s t P : ℝ) (hs : |s| ≤ P) (ht : |t| ≤ P) :
    |s^2-t^2| ≤ 2*P*|s-t| := by
  have hsum := (abs_add_le s t).trans (add_le_add hs ht)
  have hid : s^2-t^2 = (s-t)*(s+t) := by ring
  rw [hid, abs_mul]
  have h := mul_le_mul_of_nonneg_left hsum (abs_nonneg (s-t))
  nlinarith

theorem ScalarInstruction.range_bound (op : ScalarInstruction) (s P : ℝ)
    (hP : 1 ≤ P) (hs : |s| ≤ P) : |op.eval s| ≤ P^2+1 := by
  cases op with
  | identity =>
    dsimp [ScalarInstruction.eval]
    nlinarith
  | normalizedTanh a =>
    have hh := (normalizedTanh_bound a s).trans hs
    dsimp [ScalarInstruction.eval]
    nlinarith
  | square =>
    dsimp [ScalarInstruction.eval]
    rw [abs_of_nonneg (sq_nonneg s)]
    nlinarith [sq_abs s, abs_nonneg s]
  | clippedSqrt =>
    dsimp [ScalarInstruction.eval]
    rw [abs_of_nonneg (Real.sqrt_nonneg _)]
    have hmax : max 0 s ≤ P := max_le (by linarith) ((le_abs_self s).trans hs)
    have hroot := Real.sq_sqrt (le_max_left 0 s)
    have hnon := Real.sqrt_nonneg (max 0 s)
    nlinarith

  | inverseRootClip =>
    dsimp [ScalarInstruction.eval]
    rw [abs_of_nonneg (inverseRootClip_nonneg s)]
    have hh := inverseRootClip_le_one s
    nlinarith

theorem ScalarInstruction.modulus (op : ScalarInstruction) (s t P : ℝ)
    (hP : 1 ≤ P) (hs : |s| ≤ P) (ht : |t| ≤ P) :
    |op.eval s-op.eval t| ≤ arithmeticModulus P |s-t| := by
  have hr := abs_nonneg (s-t)
  have hroot := Real.sqrt_nonneg |s-t|
  have hm : 0 ≤ 2*P*|s-t| := by positivity
  cases op with
  | identity => dsimp [ScalarInstruction.eval, arithmeticModulus]; nlinarith
  | normalizedTanh a =>
    have hh := normalizedTanh_lipschitz a s t
    dsimp [ScalarInstruction.eval, arithmeticModulus]
    nlinarith
  | square =>
    have hh := scalar_square_difference s t P hs ht
    dsimp [ScalarInstruction.eval, arithmeticModulus]
    linarith
  | clippedSqrt =>
    have hh := clipped_sqrt_difference_bound s t
    dsimp [ScalarInstruction.eval, arithmeticModulus]
    linarith

  | inverseRootClip =>
    have hh := inverseRootClip_modulus s t
    dsimp [ScalarInstruction.eval, arithmeticModulus]
    linarith

#print axioms ScalarInstruction.range_bound
#print axioms ScalarInstruction.modulus
end ConditionalNonpolynomial.Analytic

namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

/-- The concrete scalar instruction set is compiled without analytic
continuity assumptions: the bounds above discharge them. -/
theorem instructionLayer_accuracy {d m : ℕ} (c : Fin m → Fin d → ℝ)
    (ops : Fin m → ScalarInstruction) (Q B Ni No : ℕ) (hQ : 0 < Q)
    (hc : ∀ j i, |c j i| ≤ (B:ℝ))
    (x : Fin d → ℝ) (hx : ∀ i, |x i| ≤ (Ni:ℝ))
    (a : Fin d → ScalarCode Q Ni) (η : ℝ) (hη : 0 ≤ η)
    (hprecision : 1/(2*(Q:ℝ)) ≤ η)
    (hinput : ∀ i, |x i-scalarDecode Q Ni (a i)| ≤ η)
    (hNo : (d*(B+1)*(Ni+1)+1)^2+1 ≤ No) (j : Fin m) :
    |(ops j).eval (∑ i, c j i*x i)-
      scalarDecode Q No (quantizedUpdate c (fun j => (ops j).eval) Q Ni No a j)| ≤
      arithmeticModulus ((d*(B+1)*(Ni+1)+1:ℕ):ℝ)
        ((d:ℝ)*η*((B:ℝ)+Ni+η))+1/(2*(Q:ℝ)) := by
  let P : ℝ := (d*(B+1)*(Ni+1)+1:ℕ)
  have hP : 1 ≤ P := by dsimp [P]; exact_mod_cast (show 1 ≤ d*(B+1)*(Ni+1)+1 by omega)
  have hrange : (d:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) ≤ P := by dsimp [P]; push_cast; linarith
  have hNoR : P^2+1 ≤ (No:ℝ) := by dsimp [P]; exact_mod_cast hNo
  exact quantizedLayer_accuracy c (fun j => (ops j).eval) Q B Ni No hQ hc x hx a η hη
    hprecision hinput (arithmeticModulus P) (arithmeticModulus_monotone P (by linarith))
    (fun j s hs => ((ops j).range_bound s P hP (hs.trans hrange)).trans hNoR)
    (fun j s t hs ht => (ops j).modulus s t P hP (hs.trans hrange) (ht.trans hrange)) j

#print axioms instructionLayer_accuracy
end ConditionalNonpolynomial.AnalyticLookup
