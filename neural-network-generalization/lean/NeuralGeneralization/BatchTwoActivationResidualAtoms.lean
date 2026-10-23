import NeuralGeneralization.BatchTwoActivationLayerCertificate
import NeuralGeneralization.BatchTwoActivationFiniteAtoms

/-! The actual Gaussian layer's residual is a bounded-weight mixture of unit
source atoms. This bridges the empirical decomposition to finite realization. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

theorem linearObservation_eq_inner (c : I → Fin n → ℝ)
    (u : EuclideanSpace ℝ (Fin n)) (i : I) :
    linearObservation c u i = inner ℝ (WithLp.toLp 2 (c i)) u := by
  simp only [linearObservation,EuclideanSpace.inner_eq_star_dotProduct,dotProduct,
    Pi.star_apply,star_trivial,WithLp.ofLp_toLp]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem sourceGram_coefficients (c : I → Fin n → ℝ) (i j : I) :
    sourceGram (fun i => WithLp.toLp 2 (c i)) i j =
      GaussianAngularPrice.gram c i j := by
  rw [sourceGram,←linearObservation_eq_inner]
  simp only [linearObservation,PiLp.toLp_apply,GaussianAngularPrice.gram]

def residualAtomCoefficient (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    (M a T : ℝ) (j : Fin N) : ℝ :=
  cutoffTailWeight a T (fieldLinear c (x j))*‖gaussianResidualSource c M (x j)‖^2/(N:ℝ)

theorem residualAtomCoefficient_nonneg (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    (M a T : ℝ) (j : Fin N) : 0 ≤ residualAtomCoefficient c x M a T j :=
  div_nonneg (mul_nonneg (cutoffTailWeight_bounds a T _).1 (sq_nonneg _)) (Nat.cast_nonneg N)

theorem residualAtomCoefficient_sum (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    (M a T : ℝ) {A : ℝ} (hN : 0<N)
    (henergy : ∑j,‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A) :
    (∑j,residualAtomCoefficient c x M a T j)≤A := by
  unfold residualAtomCoefficient
  rw [←Finset.sum_div]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).2
  calc
    _ ≤ ∑j,‖gaussianResidualSource c M (x j)‖^2 := by
      apply Finset.sum_le_sum
      intro j hj
      exact mul_le_of_le_one_left (sq_nonneg _) (cutoffTailWeight_bounds a T _).2
    _ ≤ _ := by simpa only [mul_comm] using henergy

theorem layerResidualCovariance_atoms (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    {φ : ℝ → ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (M a T : ℝ) (p q : I) :
    layerResidualCovariance c x φ M a T p q =
      ∑j,residualAtomCoefficient c x M a T j *
        tailActivation φ ‖gaussianResidualSource c M (x j)‖
          (inner ℝ (WithLp.toLp 2 (c p)) (unitDirection (gaussianResidualSource c M (x j)))) *
        tailActivation φ ‖gaussianResidualSource c M (x j)‖
          (inner ℝ (WithLp.toLp 2 (c q)) (unitDirection (gaussianResidualSource c M (x j)))) := by
  unfold layerResidualCovariance
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [tail_atom_reconstruction c hφ _ p,tail_atom_reconstruction c hφ _ q,
    linearObservation_eq_inner,linearObservation_eq_inner]
  unfold residualAtomCoefficient
  ring

theorem coefficientSource_norm_bound (c : I → Fin n → ℝ) {M : ℝ} (hM : 0≤M)
    (hvar : ∀i,(∑j,(c i j)^2)≤M) (i : I) : ‖WithLp.toLp 2 (c i)‖≤Real.sqrt M := by
  have hnorm : ‖WithLp.toLp 2 (c i)‖^2 = ∑j,(c i j)^2 := by
    simp only [EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply]
  have hh := hvar i
  rw [←hnorm] at hh
  have hs := Real.sq_sqrt hM
  nlinarith [norm_nonneg (WithLp.toLp 2 (c i)),Real.sqrt_nonneg M]

/-- Uniform finite reconstruction of the actual residual covariance, valid
at every nearby incoming covariance, with ordinary auxiliary neurons. -/
theorem exists_finite_gaussian_residual_atoms (c : I → Fin n → ℝ)
    (x : Fin N → Fin n → ℝ) {φ : ℝ → ℝ} {ℓ M A ε η : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hM : 0<M) (hA : 0<A)
    (hε : 0≤ε) (hη : 0<η) (a T : ℝ) (hN : 0<N)
    (hvar : ∀i,(∑j,(c i j)^2)≤M)
    (henergy : ∑j,‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A)
    {s : ℕ} (hs : 0<s)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(s:ℝ)*((ε/A)/(ℓ*Real.sqrt M)^2)^2/2)<1) :
    ∃(ξ : Fin s → ℝ → ℝ) (β : Fin s → I → ℝ),
      (∀j,zeroLipschitzActivation ℓ (ξ j)) ∧ (∀j,(∑i,|β j i|)≤1/(4*η)) ∧
      ∀Q' : I → I → ℝ, (∀i j,|Q' i j-GaussianAngularPrice.gram c i j|≤η^2) → ∀p q,
        |(A/(s:ℝ))*(∑j,ξ j (∑i,β j i*Q' p i)*ξ j (∑i,β j i*Q' q i))-
          layerResidualCovariance c x φ M a T p q|<
          ε+A*(5*ℓ*η/4)*(2*ℓ*Real.sqrt M+5*ℓ*η/4) := by
  obtain ⟨ξ,β,hξ,hβ,hh⟩ := exists_stable_finite_atoms
    (fun i => WithLp.toLp 2 (c i))
    (fun j => unitDirection (gaussianResidualSource c M (x j)))
    (fun j => tailActivation φ ‖gaussianResidualSource c M (x j)‖)
    hℓ hA (Real.sqrt_pos.mpr hM) hε hη (coefficientSource_norm_bound c hM.le hvar)
    (fun j => norm_unitDirection_le _) (fun j => tailActivation_admissible hφ (norm_nonneg _))
    (residualAtomCoefficient c x M a T) (residualAtomCoefficient_nonneg c x M a T)
    (residualAtomCoefficient_sum c x M a T hN henergy) hs hbudget
  refine ⟨ξ,β,hξ,hβ,?_⟩
  intro Q' hQ p q
  rw [layerResidualCovariance_atoms c x hφ]
  apply hh Q' _ p q
  intro i j
  simpa only [sourceGram_coefficients] using hQ i j

end NeuralGeneralization.BatchTwoActivation
