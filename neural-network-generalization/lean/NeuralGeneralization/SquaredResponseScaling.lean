import NeuralGeneralization.FiniteSquaredCoercivity

/-! Exact sample-dependent normalization of actual squared row responses. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling

variable {m D : ℕ} {U : Type*} [Fintype U] [Nonempty U]

lemma envelope_const_mul (f : U → ℝ) (r : ℝ) (hr : 0 ≤ r) :
    envelope (fun u => r*f u) = r*envelope f := by
  obtain ⟨u, hu⟩ := Finite.exists_max (fun u => |f u|)
  rw [envelope_eq_of_max f u hu]
  rw [envelope_eq_of_max (fun u => r*f u) u (fun v => by
    simpa only [abs_mul, abs_of_nonneg hr] using mul_le_mul_of_nonneg_left (hu v) hr)]
  rw [abs_mul, abs_of_nonneg hr]

def empiricalSquareEnvelope (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) : ℝ :=
  envelope (fun u => ∑ i, linearEvaluation (a i) (p u)^2)

lemma empiricalSquareEnvelope_nonneg (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) :
    0 ≤ empiricalSquareEnvelope a p := envelope_nonneg_finite _

lemma rowEnergy_le_empiricalSquareEnvelope (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u : U) :
    (∑ i, linearEvaluation (a i) (p u)^2) ≤ empiricalSquareEnvelope a p := by
  have h := le_envelope_finite (fun u => ∑ i, linearEvaluation (a i) (p u)^2) u
  rwa [abs_of_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _))] at h

def normalizedRows (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) : Fin m → Fin D → ℝ :=
  fun i j => a i j/Real.sqrt (empiricalSquareEnvelope a p+1)

lemma linearEvaluation_row_div (a c : Fin D → ℝ) (r : ℝ) :
    linearEvaluation (fun j => a j/r) c = linearEvaluation a c/r := by
  simp only [linearEvaluation, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma normalizedRows_variance (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (V : ℝ)
    (hvar : ∀ i, (∑ j, a i j^2) ≤ V) (i : Fin m) :
    (∑ j, normalizedRows a p i j^2) ≤ V/(empiricalSquareEnvelope a p+1) := by
  have hs : 0 ≤ empiricalSquareEnvelope a p+1 := by have hh := empiricalSquareEnvelope_nonneg a p; linarith
  simp only [normalizedRows, div_pow, ← Finset.sum_div, Real.sq_sqrt hs]
  exact div_le_div_of_nonneg_right (hvar i) hs

lemma normalizedRows_rowEnergy (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u : U) :
    (∑ i, linearEvaluation (normalizedRows a p i) (p u)^2) ≤ 1 := by
  have hs : 0 < empiricalSquareEnvelope a p+1 := by have hh := empiricalSquareEnvelope_nonneg a p; linarith
  change (∑ i, linearEvaluation (fun j => a i j/Real.sqrt (empiricalSquareEnvelope a p+1)) (p u)^2) ≤ 1
  simp only [linearEvaluation_row_div, div_pow, ← Finset.sum_div, Real.sq_sqrt hs.le]
  apply (div_le_one hs).2
  exact (rowEnergy_le_empiricalSquareEnvelope a p u).trans (by linarith)

lemma squared_response_normalization (ψ : ℝ → ℝ)
    (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x)
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u : U) (i : Fin m) :
    ψ (linearEvaluation (a i) (p u))^2 =
      (empiricalSquareEnvelope a p+1)*ψ (linearEvaluation (normalizedRows a p i) (p u))^2 := by
  let R := empiricalSquareEnvelope a p+1
  have hR : 0 < R := by dsimp only [R]; have hh := empiricalSquareEnvelope_nonneg a p; linarith
  have hsqrt : 0 < Real.sqrt R := Real.sqrt_pos.2 hR
  have hlin : linearEvaluation (a i) (p u) = Real.sqrt R*linearEvaluation (normalizedRows a p i) (p u) := by
    change _ = Real.sqrt R*linearEvaluation (fun j => a i j/Real.sqrt R) (p u)
    rw [linearEvaluation_row_div]
    field_simp
  rw [hlin, hscale _ hsqrt.le, mul_pow, Real.sq_sqrt hR.le]

lemma squared_response_process_normalization (ψ : ℝ → ℝ)
    (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x)
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i, cubeCoordinateSign (ε i)*ψ (linearEvaluation (a i) (p u))^2)) =
    (empiricalSquareEnvelope a p+1)*
      finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
        ∑ i, cubeCoordinateSign (ε i)*ψ (linearEvaluation (normalizedRows a p i) (p u))^2)) := by
  have he (ε : Fin m → Bool) (u : U) :
      (∑ i, cubeCoordinateSign (ε i)*ψ (linearEvaluation (a i) (p u))^2) =
      (empiricalSquareEnvelope a p+1)*∑ i, cubeCoordinateSign (ε i)*
        ψ (linearEvaluation (normalizedRows a p i) (p u))^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    rw [squared_response_normalization ψ hscale a p u i]
    ring
  simp_rw [he, envelope_const_mul _ _ (show 0 ≤ empiricalSquareEnvelope a p+1 by
    have hh := empiricalSquareEnvelope_nonneg a p; linarith)]
  exact finiteMean_mul _ _

lemma sqrt_normalization_identity (V L R : ℝ) (hV : 0 ≤ V) (hL : 0 ≤ L) (hR : 0 < R) :
    R*Real.sqrt ((V/R)*L) = Real.sqrt (V*L)*Real.sqrt R := by
  have hs : Real.sqrt R ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hR)
  rw [show V/R*L=(V*L)/R by ring, Real.sqrt_div (mul_nonneg hV hL)]
  calc
    _ = Real.sqrt R^2*(Real.sqrt (V*L)/Real.sqrt R) := by rw [Real.sq_sqrt hR.le]
    _ = _ := by field_simp

end NeuralGeneralization.SquaredSampling
