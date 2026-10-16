import NeuralGeneralization.LowRankWitness
import NeuralGeneralization.LowRankGrid

/-! # Concrete array factorization of the orthogonal energy witness -/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators RealInnerProductSpace
open InnerProductSpace LowRankGrid

abbrev EuclideanN (N : ℕ) := EuclideanSpace ℝ (Fin N)

/-- The continuous Euclidean operator represented by a real coefficient array. -/
def matrixOperator {N : ℕ} (M : Fin N × Fin N → ℝ) :
    EuclideanN N →L[ℝ] EuclideanN N :=
  LinearMap.toContinuousLinearMap (Matrix.toEuclideanLin (fun i j => M (i, j)))

/-- Matrix entries of the actual operator in the standard orthonormal basis. -/
def operatorMatrix {N : ℕ} (A : EuclideanN N →L[ℝ] EuclideanN N) :
    Fin N × Fin N → ℝ := fun ij => A (EuclideanSpace.basisFun (Fin N) ℝ ij.2) ij.1

@[simp] theorem operatorMatrix_matrixOperator {N : ℕ} (M : Fin N × Fin N → ℝ) :
    operatorMatrix (matrixOperator M) = M := by
  classical
  funext ij
  simp [operatorMatrix, matrixOperator, EuclideanSpace.basisFun_apply, Matrix.toLpLin_apply]

lemma hsPairing_eq_matrix_sum {N : ℕ} (A B : EuclideanN N →L[ℝ] EuclideanN N) :
    hsPairing (EuclideanSpace.basisFun (Fin N) ℝ) A B =
      ∑ ij : Fin N × Fin N, operatorMatrix A ij * operatorMatrix B ij := by
  simp only [hsPairing, PiLp.inner_apply, RCLike.inner_apply, conj_trivial]
  rw [Fintype.sum_prod_type, Finset.sum_comm]
  simp only [operatorMatrix, mul_comm]

lemma squaredSum_operatorMatrix {N : ℕ} (A : EuclideanN N →L[ℝ] EuclideanN N) :
    squaredSum (operatorMatrix A) = hsPairing (EuclideanSpace.basisFun (Fin N) ℝ) A A := by
  rw [hsPairing_eq_matrix_sum]
  simp [squaredSum, pow_two]

/-- Scalar, left-vector, and right-vector coordinates of the normalized
capture. The two vector factors are unit vectors; each coefficient is at most
one because its energy is a term in total captured energy. -/
def captureFactors {N : ℕ} (A : EuclideanN N →L[ℝ] EuclideanN N)
    (s : Finset (EuclideanN N)) : FactorIndex N s.card → ℝ
  | .inl l => ‖A (s.equivFin.symm l)‖ / Real.sqrt (capturedEnergy A s)
  | .inr (.inl (i, l)) => A (s.equivFin.symm l) i / ‖A (s.equivFin.symm l)‖
  | .inr (.inr (j, l)) => (s.equivFin.symm l : EuclideanN N) j

lemma captureFactors_bounded {N : ℕ} (A : EuclideanN N →L[ℝ] EuclideanN N)
    (s : Finset (EuclideanN N)) (hs : orthonormalFinset s)
    (henergy : 0 < capturedEnergy A s)
    (hpos : ∀ v ∈ s, 0 < ‖A v‖) : ∀ i, |captureFactors A s i| ≤ 1 := by
  intro i
  rcases i with l | (⟨i, l⟩ | ⟨j, l⟩)
  · dsimp [captureFactors]
    rw [abs_div, abs_of_nonneg (norm_nonneg _), abs_of_pos (Real.sqrt_pos.mpr henergy)]
    apply (div_le_one (Real.sqrt_pos.mpr henergy)).mpr
    exact image_norm_le_sqrt_energy A s _ (s.equivFin.symm l).property
  · dsimp [captureFactors]
    rw [abs_div, abs_of_nonneg (norm_nonneg _)]
    apply (div_le_one (hpos _ (s.equivFin.symm l).property)).mpr
    simpa only [Real.norm_eq_abs] using PiLp.norm_apply_le (A (s.equivFin.symm l)) i
  · dsimp [captureFactors]
    have hb := PiLp.norm_apply_le (s.equivFin.symm l : EuclideanN N) j
    simpa only [Real.norm_eq_abs, hs.1 _ (s.equivFin.symm l).property] using hb

lemma factorMatrix_captureFactors {N : ℕ} (A : EuclideanN N →L[ℝ] EuclideanN N)
    (s : Finset (EuclideanN N))
    (hpos : ∀ v ∈ s, 0 < ‖A v‖) :
    factorMatrix (captureFactors A s) = operatorMatrix (normalizedEnergyCapture A s) := by
  funext ij
  let e := EuclideanSpace.basisFun (Fin N) ℝ
  have hterm (l : Fin s.card) :
      captureFactors A s (.inl l) * captureFactors A s (.inr (.inl (ij.1, l))) *
        captureFactors A s (.inr (.inr (ij.2, l))) =
      (Real.sqrt (capturedEnergy A s))⁻¹ *
        ((s.equivFin.symm l : EuclideanN N) ij.2 * A (s.equivFin.symm l) ij.1) := by
    dsimp [captureFactors]
    have hn := ne_of_gt (hpos _ (s.equivFin.symm l).property)
    field_simp
  change (∑ l, _) = _
  simp_rw [hterm]
  rw [← Finset.mul_sum]
  have hsum : (∑ l : Fin s.card,
      (s.equivFin.symm l : EuclideanN N) ij.2 * A (s.equivFin.symm l) ij.1) =
      ∑ v ∈ s, v ij.2 * A v ij.1 := by
    calc
      _ = ∑ v : s, (v : EuclideanN N) ij.2 * A v ij.1 :=
        s.equivFin.symm.sum_comp (fun v : s => (v : EuclideanN N) ij.2 * A v ij.1)
      _ = _ := Finset.sum_coe_sort s (fun v : EuclideanN N => v ij.2 * A v ij.1)
  rw [hsum]
  simp only [operatorMatrix, normalizedEnergyCapture, smul_apply,
    PiLp.smul_apply, smul_eq_mul, energyCapture_apply, WithLp.ofLp_sum, Finset.sum_apply,
    EuclideanSpace.inner_basisFun_real]

@[simp] theorem matrixOperator_operatorMatrix {N : ℕ}
    (A : EuclideanN N →L[ℝ] EuclideanN N) : matrixOperator (operatorMatrix A) = A := by
  have hlinear : (matrixOperator (operatorMatrix A)).toLinearMap = A.toLinearMap := by
    apply (EuclideanSpace.basisFun (Fin N) ℝ).toBasis.ext
    intro j
    apply PiLp.ext
    intro i
    exact congrFun (operatorMatrix_matrixOperator (operatorMatrix A)) (i, j)
  apply ContinuousLinearMap.ext
  intro x
  exact congrArg (fun T : EuclideanN N →ₗ[ℝ] EuclideanN N => T x) hlinear

/-- A concrete coefficient array either has a bounded-Frobenius-energy
operator approximation, or admits the bounded-factor witness required by the
finite low-rank grid. No matrix concentration theorem is assumed here. -/
theorem matrix_approximation_or_factor_witness {N : ℕ}
    (M : Fin N × Fin N → ℝ) (a K : ℝ) (ha : 0 < a) (hK : 0 ≤ K) :
    (∃ H : Fin N × Fin N → ℝ, squaredSum H ≤ K ∧
      ‖matrixOperator M - matrixOperator H‖ ≤ a) ∨
    (∃ R : ℕ, R ≤ N ∧ (R : ℝ) ≤ K / a ^ 2 + 1 ∧
      ∃ p : FactorIndex N R → ℝ, (∀ i, |p i| ≤ 1) ∧
        squaredSum (factorMatrix p) = 1 ∧
        Real.sqrt K < ∑ ij, M ij * factorMatrix p ij) := by
  let A := matrixOperator M
  let e := EuclideanSpace.basisFun (Fin N) ℝ
  rcases energy_approximation_or_small_witness A a K ha hK with hgood | hbad
  · obtain ⟨s, hs, henergy, hnorm⟩ := hgood
    refine Or.inl ⟨operatorMatrix (energyCapture A s), ?_, ?_⟩
    · rw [squaredSum_operatorMatrix, hsPairing_capture_self e A s hs]
      exact henergy
    · simpa only [matrixOperator_operatorMatrix] using hnorm
  · obtain ⟨s, hs, hlarge, hcard, henergy⟩ := hbad
    have hpositive : 0 < capturedEnergy A s := lt_of_le_of_lt hK henergy
    have hpos : ∀ v ∈ s, 0 < ‖A v‖ := fun v hv => ha.trans (hlarge v hv)
    have hdim : s.card ≤ N := by simpa using orthonormalFinset_card_le s hs
    refine Or.inr ⟨s.card, hdim, hcard, captureFactors A s,
      captureFactors_bounded A s hs hpositive hpos, ?_, ?_⟩
    · rw [factorMatrix_captureFactors A s hpos, squaredSum_operatorMatrix]
      exact normalizedEnergyCapture_unit e A s hs hpositive
    · rw [factorMatrix_captureFactors A s hpos]
      have hpair := normalizedEnergyCapture_pairing e A s hpositive
      rw [hsPairing_eq_matrix_sum, operatorMatrix_matrixOperator] at hpair
      rw [hpair]
      exact Real.sqrt_lt_sqrt hK henergy

end NeuralGeneralization
