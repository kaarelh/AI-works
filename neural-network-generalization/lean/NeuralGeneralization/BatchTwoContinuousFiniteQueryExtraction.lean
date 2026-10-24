import NeuralGeneralization.BatchTwoContinuousFiniteQueryModel
import NeuralGeneralization.BatchTwoNonGaussianRows
import NeuralGeneralization.MeanFieldCertificateExtraction

/-! Actual-law covariance certificates for the mean-field learner. The first
reference distribution stays non-Gaussian; only the later reference fields
are replaced, with the already proved relative Lindeberg cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open BatchTwoNonGaussian ConcreteModel FiniteDifferential GaussianTowerConstruction GaussianAngularPrice GaussianFieldTilt
open MeanFieldCoefficientSequence NetworkLayerSplit TanhDifferential

lemma input_field {d q N : ℕ} (xs : Cube q → RealInput d) (z : Weights d N 0) (i : Fin N) (x : Cube q) :
    fieldLinear (inputMatrix xs) (NonGaussianMeanField.inputRows z i) x=firstRows xs (NonGaussianMeanField.weights z) i x := by
  simp only [fieldLinear_apply,inputMatrix,NonGaussianMeanField.inputRows,firstRows,NonGaussianMeanField.weights]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma last_field {d q N r : ℕ} (xs : Cube q → RealInput d) (z : Weights d N (r+1)) (i : Fin N) (x : Cube q) :
    fieldLinear (activationMatrix xs (NonGaussianMeanField.weights (previousWeights z))) (NonGaussianMeanField.lastRows z i) x=
      lastRows xs (NonGaussianMeanField.weights z) i x := by
  simp only [fieldLinear_apply,activationMatrix,NonGaussianMeanField.lastRows,lastRows,
    NonGaussianMeanField.weights_previous]
  apply Finset.sum_congr rfl
  intro j _
  have hl : NetworkLayerSplit.lastMatrix (NonGaussianMeanField.weights z) (i,j)=
      z (.inr (.inl (Fin.last r,i,j)))/Real.sqrt N := rfl
  rw [hl]
  ring

theorem activationMatrix_small_entries {d q N r : ℕ} (xs : Cube q → RealInput d) (z : Weights d N r) (x : Cube q) (j : Fin N) :
    |activationMatrix xs (NonGaussianMeanField.weights z) x j| ≤ 1/Real.sqrt N := by
  rw [activationMatrix,abs_div,abs_of_nonneg (Real.sqrt_nonneg _)]
  exact div_le_div_of_nonneg_right ((by
      have hh := TowerNetwork.finalHidden_tanh_abs_le_one
        (freezeInput (xs x) (NonGaussianMeanField.weights z)) (fun _ => false) j
      simpa only [finalHidden_freeze] using hh))
    (Real.sqrt_nonneg _)

theorem exists_covariance_certificates (ν : CoordinateLaw) {d q N : ℕ} (xs : Cube q → RealInput d) (hN : 0 < N)
    (G : ℕ → ℝ) (K : ℝ) (hK : 0 ≤ K) :
    ∀ r (z : Weights d N r), (∀ s, s ≤ r → 0 < G s) →
      (∀ s, 1 ≤ s → s ≤ r → 4*(G s)^2 ≤ (N : ℝ)) →
      (∀ s, 1 ≤ s → s ≤ r →
        replacementConstant ν standardGaussian*lindebergPolynomial (G s)/Real.sqrt N ≤ K) →
      GoodHidden ν xs N r G K z →
      ∃ Γ : ℕ → Cube q → Cube q → ℝ,
        (∀ s, s ≤ r → couplingMass (Γ s) ≤ G s) ∧
        (∀ x y, |gram (coefficient xs (NonGaussianMeanField.weights z) 1) x y-
          actualTiltedMoment ν (inputMatrix xs) (Γ 0) x y| ≤ K/G 0) ∧
        ∀ s, 1 ≤ s → s ≤ r → ∀ x y,
          |gram (coefficient xs (NonGaussianMeanField.weights z) (s+1)) x y-
            tiltedMoment (coefficient xs (NonGaussianMeanField.weights z) s) (Γ s) x y| ≤ 2*K/G s := by
  intro r
  induction r with
  | zero =>
    intro z hG _ _ hz
    obtain ⟨Γ,hsym,hΓ,hent,herr⟩ := actual_covariance_lift ν (inputMatrix xs) (hG 0 le_rfl) (NonGaussianMeanField.inputRows z) hz
    refine ⟨fun _ => Γ,fun s hs => ?_,?_,fun s hs hsr => by omega⟩
    · have hs0 : s=0 := by omega
      simpa only [hs0] using hΓ
    · intro x y
      rw [gram_coefficient_one,actualTiltedMoment_eq_mean]
      simpa only [input_field xs] using herr x y
  | succ r ih =>
    intro z hG hsize herr hz
    obtain ⟨hprev,hlast⟩ := hz
    obtain ⟨Γprev,hΓprev,hbaseprev,hcertprev⟩ := ih (previousWeights z)
      (fun s hs => hG s (by omega)) (fun s hs hsr => hsize s hs (by omega))
      (fun s hs hsr => herr s hs (by omega)) hprev
    obtain ⟨Γlast,hsym,hΓlast,hent,hcertlast⟩ := gaussian_proxy_lift ν hN
      (activationMatrix xs (NonGaussianMeanField.weights (previousWeights z))) (hG (r+1) le_rfl)
      (activationMatrix_small_entries xs _) (hsize (r+1) (by omega) le_rfl) (NonGaussianMeanField.lastRows z) hlast
    let Γ : ℕ → Cube q → Cube q → ℝ := fun s => if s=r+1 then Γlast else Γprev s
    refine ⟨Γ,?_,?_,?_⟩
    · intro s hs
      by_cases heq : s=r+1
      · simpa [Γ,heq] using hΓlast
      · simpa [Γ,heq] using hΓprev s (by omega)
    · intro x y
      rw [coefficient_previous xs (NonGaussianMeanField.weights z) (by omega : 1 ≤ r+1),NonGaussianMeanField.weights_previous]
      simpa [Γ] using hbaseprev x y
    · intro s hs hsr x y
      by_cases heq : s=r+1
      · subst s
        rw [gram_coefficient_last hN,coefficient_previous xs (NonGaussianMeanField.weights z) le_rfl,NonGaussianMeanField.weights_previous,coefficient_final]
        simp only [Γ,if_pos rfl]
        have ht := (hcertlast x y).trans
          (div_le_div_of_nonneg_right (show K+replacementConstant ν standardGaussian*lindebergPolynomial (G (r+1))/Real.sqrt N ≤ 2*K by
            linarith [herr (r+1) (by omega) le_rfl]) (hG (r+1) le_rfl).le)
        simpa only [last_field xs] using ht
      · rw [coefficient_previous xs (NonGaussianMeanField.weights z) (by omega : s+1 ≤ r+1),
          coefficient_previous xs (NonGaussianMeanField.weights z) (by omega : s ≤ r+1),NonGaussianMeanField.weights_previous]
        simpa only [Γ,if_neg heq] using hcertprev s hs (by omega) x y

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
