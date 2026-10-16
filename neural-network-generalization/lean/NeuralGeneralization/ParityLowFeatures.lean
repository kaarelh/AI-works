import NeuralGeneralization.SquaredResponseScaling
import NeuralGeneralization.PolynomialThresholdParity
import NeuralGeneralization.FunctionPrior

/-! The actual bounded orthonormal feature rows for low-degree parity sampling. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization
open SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

abbrev lowDimension (d r : ℕ) := Fintype.card (DegreeIndices d r)

def degreeIndex (d r : ℕ) : Fin (lowDimension d r) ≃ DegreeIndices d r :=
  (Fintype.equivFin (DegreeIndices d r)).symm

def lowFeatureCoefficients {d r : ℕ} (c : Fin (lowDimension d r) → ℝ) (S : Finset (Fin d)) : ℝ :=
  if h : S.card ≤ r then c ((degreeIndex d r).symm ⟨S,h⟩) else 0

def parityLowFeatures (d r : ℕ) (x : ClippingCube d) (j : Fin (lowDimension d r)) : ℝ :=
  fullParity x*walshCharacter (degreeIndex d r j).val x

lemma fullParity_square {d : ℕ} (x : ClippingCube d) : fullParity x^2=1 := by
  rcases fullParity_sign x with h | h <;> simp [h]

lemma lowDimension_pos (d r : ℕ) : 0 < lowDimension d r := by
  letI : Nonempty (DegreeIndices d r) := ⟨⟨∅, by simp⟩⟩
  exact Fintype.card_pos

lemma lowFeatureCoefficients_support {d r : ℕ} (c : Fin (lowDimension d r) → ℝ)
    (S : Finset (Fin d)) (h : lowFeatureCoefficients c S ≠ 0) : S.card ≤ r := by
  by_contra hn
  exact h (dif_neg hn)

lemma lowFeatureCoefficients_sum {d r : ℕ} (c : Fin (lowDimension d r) → ℝ)
    (f : Finset (Fin d) → ℝ) :
    (∑ S, lowFeatureCoefficients c S*f S) =
      ∑ j, c j*f (degreeIndex d r j).val := by
  have hd := Fintype.sum_subtype_add_sum_subtype (fun S : Finset (Fin d) => S.card ≤ r)
    (fun S => lowFeatureCoefficients c S*f S)
  have hl : (∑ S : DegreeIndices d r, lowFeatureCoefficients c S.val*f S.val) =
      ∑ S : DegreeIndices d r, c ((degreeIndex d r).symm S)*f S.val := by
    apply Finset.sum_congr rfl
    intro S _
    simp only [lowFeatureCoefficients, dif_pos S.property]
  have hz : (∑ S : {S : Finset (Fin d) // ¬ S.card ≤ r}, lowFeatureCoefficients c S.val*f S.val)=0 := by
    apply Finset.sum_eq_zero
    intro S _
    simp only [lowFeatureCoefficients, dif_neg S.property, zero_mul]
  rw [hl, hz, add_zero] at hd
  rw [← hd, ← (degreeIndex d r).sum_comp]
  simp only [Equiv.symm_apply_apply]

lemma lowFeatureCoefficients_square_sum {d r : ℕ} (c : Fin (lowDimension d r) → ℝ) :
    (∑ S, lowFeatureCoefficients c S^2) = ∑ j, c j^2 := by
  have h := lowFeatureCoefficients_sum c (lowFeatureCoefficients c)
  have he (j : Fin (lowDimension d r)) : lowFeatureCoefficients c (degreeIndex d r j).val = c j := by
    simp only [lowFeatureCoefficients, dif_pos (degreeIndex d r j).property]
    change c ((degreeIndex d r).symm (degreeIndex d r j)) = c j
    rw [Equiv.symm_apply_apply]
  simpa only [he, ← pow_two] using h

lemma parityLowFeatures_evaluation {d r : ℕ} (c : Fin (lowDimension d r) → ℝ) (x : ClippingCube d) :
    linearEvaluation (parityLowFeatures d r x) c =
      fullParity x*walshExpansion (lowFeatureCoefficients c) x := by
  rw [walshExpansion, lowFeatureCoefficients_sum, Finset.mul_sum]
  unfold linearEvaluation parityLowFeatures
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma parityLowFeatures_row_norm (d r : ℕ) (x : ClippingCube d) :
    (∑ j, parityLowFeatures d r x j^2) = (lowDimension d r:ℝ) := by
  simp only [parityLowFeatures, mul_pow, fullParity_square, walshCharacter_sq, mul_one,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]

lemma parityLowFeatures_isometry {d r : ℕ} (c : Fin (lowDimension d r) → ℝ) :
    finiteMean (fun x : ClippingCube d => linearEvaluation (parityLowFeatures d r x) c^2) =
      ∑ j, c j^2 := by
  simp only [parityLowFeatures_evaluation, mul_pow, fullParity_square, one_mul]
  rw [finiteMean, walshExpansion_parseval, lowFeatureCoefficients_square_sum]
  field_simp

lemma parityLowFeatures_population_coercivity {d r : ℕ} (hd : 0 < d) (hr : 64*r ≤ d)
    (c : Fin (lowDimension d r) → ℝ) :
    (3/8:ℝ)*(∑ j, c j^2) ≤
      finiteMean (squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c) := by
  have h := parity_negativePart_square_coercivity hd hr (lowFeatureCoefficients c)
    (fun S hS => lowFeatureCoefficients_support c S hS)
  have hiso : uniformCubeMean (fun x => walshExpansion (lowFeatureCoefficients c) x^2) =
      ∑ j, c j^2 := by
    rw [uniformCubeMean, walshExpansion_parseval, lowFeatureCoefficients_square_sum]
    field_simp
  rw [hiso] at h
  simpa only [squaredResponse, parityLowFeatures_evaluation, uniformCubeMean, finiteMean] using h

lemma sampleProbability_uniform_eq_finiteMean (d n : ℕ) (E : (Fin n → ClippingCube d) → Prop) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n E =
      finiteMean (fun s : Fin n → ClippingCube d => if E s then 1 else 0) := by
  unfold ConcreteModel.sampleProbability ConcreteModel.uniformLaw finiteMean
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin,
    Fintype.card_fun, Nat.cast_pow, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro s _
  split_ifs <;> simp [inv_pow, one_div]

lemma lowFeatureCoefficients_restrict {d r : ℕ} (a : Finset (Fin d) → ℝ)
    (hdegree : ∀ S, a S ≠ 0 → S.card ≤ r) :
    lowFeatureCoefficients (fun j => a (degreeIndex d r j).val)=a := by
  funext S
  by_cases hS : S.card ≤ r
  · simp only [lowFeatureCoefficients, dif_pos hS, Equiv.apply_symm_apply]
  · rw [lowFeatureCoefficients, dif_neg hS]
    symm
    by_contra hn
    exact hS (hdegree S hn)

/-- Convert the finite coefficient-coordinate event to the literal Walsh
polynomial event used by the posterior hardness argument. -/
lemma parityLowFeatures_coercivity_walsh {d r n : ℕ} (s : Fin n → ClippingCube d) (q : ℝ)
    (hcoerce : ∀ c : Fin (lowDimension d r) → ℝ,
      q*(∑ j, c j^2) ≤ (∑ i, squaredResponse (fun t => max 0 (-t)) (parityLowFeatures d r) c (s i))/(n:ℝ)) :
    ∀ a : Finset (Fin d) → ℝ, (∀ S, a S ≠ 0 → S.card ≤ r) →
      q*uniformCubeMean (fun x => walshExpansion a x^2) ≤
        (∑ i, (max 0 (-fullParity (s i)*walshExpansion a (s i)))^2)/(n:ℝ) := by
  intro a hdegree
  let c : Fin (lowDimension d r) → ℝ := fun j => a (degreeIndex d r j).val
  have he : lowFeatureCoefficients c=a := lowFeatureCoefficients_restrict a hdegree
  have hiso : (∑ j, c j^2) = uniformCubeMean (fun x => walshExpansion a x^2) := by
    rw [← he, uniformCubeMean, walshExpansion_parseval, lowFeatureCoefficients_square_sum]
    field_simp
  have hh := hcoerce c
  rw [hiso] at hh
  simpa only [squaredResponse, parityLowFeatures_evaluation, he, neg_mul] using hh

end NeuralGeneralization
