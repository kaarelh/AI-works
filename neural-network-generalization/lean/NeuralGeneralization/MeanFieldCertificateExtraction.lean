import NeuralGeneralization.MeanFieldGoodEvent
import NeuralGeneralization.MeanFieldCoefficientSequence
import NeuralGeneralization.MeanFieldCompression

/-! Extraction from the actual recursive good event into the complete
deterministic compression theorem. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.MeanFieldCertificateExtraction
open ConcreteModel GaussianDualLayer GaussianAngularPrice GaussianFieldTilt
open GaussianTowerConstruction TanhDifferential NetworkLayerSplit FiniteDifferential
open MeanFieldCoefficientSequence

lemma input_field {d N : ℕ} (w : Weights d N 0) (i : Fin N) (x : Cube d) :
    fieldLinear (MeanFieldGoodEvent.inputFeatures d) (MeanFieldGoodEvent.inputRows w i) x =
      firstRows w i x := by
  simp only [fieldLinear_apply, MeanFieldGoodEvent.inputFeatures,
    MeanFieldGoodEvent.inputRows, firstRows]
  apply Finset.sum_congr rfl
  intro j hj
  ring

lemma last_field {d N r : ℕ} (w : Weights d N (r + 1)) (i : Fin N) (x : Cube d) :
    fieldLinear (MeanFieldGoodEvent.incomingFeatures (previousWeights w))
      (MeanFieldGoodEvent.lastRows w i) x = MeanFieldCoefficientSequence.lastRows w i x := by
  simp only [fieldLinear_apply, MeanFieldGoodEvent.incomingFeatures,
    MeanFieldGoodEvent.lastRows, MeanFieldCoefficientSequence.lastRows]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- The actual good event supplies a single sequence of bounded symmetric
Gaussian tilt parameters and every advertised covariance certificate. -/
theorem exists_covariance_certificates {d N : ℕ} (hN : 0 < N)
    (G : ℕ → ℝ) (K : ℝ) :
    ∀ r (w : Weights d N r), (∀ s, s ≤ r → 0 < G s) →
      MeanFieldGoodEvent.GoodHidden d N r G K w →
      ∃ Γ : ℕ → Cube d → Cube d → ℝ,
        (∀ s, s ≤ r → couplingMass (Γ s) ≤ G s) ∧
        ∀ s, s ≤ r → ∀ x y,
          |gram (coefficient w (s + 1)) x y - tiltedMoment (coefficient w s) (Γ s) x y| ≤ K / G s := by
  intro r
  induction r with
  | zero =>
    intro w hG hw
    obtain ⟨Γ, hsym, hΓ, hent, herr⟩ := exists_tilt_of_not_rawBadRows (inputMatrix d)
      (MeanFieldGoodEvent.inputFeatures d) (hG 0 le_rfl) (MeanFieldGoodEvent.inputRows w) hw
    refine ⟨fun _ => Γ, (fun s hs => ?_), ?_⟩
    · have hs0 : s = 0 := by omega
      simpa only [hs0] using hΓ
    · intro s hs x y
      have hs0 : s = 0 := by omega
      subst s
      rw [gram_coefficient_one]
      change |(∑ i : Fin N, Real.tanh (firstRows w i x) * Real.tanh (firstRows w i y)) /
        (N : ℝ) - tiltedMoment (inputMatrix d) Γ x y| ≤ K / G 0
      simpa only [input_field] using herr x y
  | succ r ih =>
    intro w hG hw
    obtain ⟨hprev, hlast⟩ := hw
    obtain ⟨Γprev, hΓprev, hcertprev⟩ := ih (previousWeights w)
      (fun s hs => hG s (Nat.le_trans hs (Nat.le_succ r))) hprev
    obtain ⟨Γlast, hsym, hΓlast, hent, hcertlast⟩ := exists_tilt_of_not_rawBadRows
      (activationMatrix (previousWeights w)) (MeanFieldGoodEvent.incomingFeatures (previousWeights w))
      (hG (r + 1) le_rfl) (MeanFieldGoodEvent.lastRows w) hlast
    let Γ : ℕ → Cube d → Cube d → ℝ := fun s => if s = r + 1 then Γlast else Γprev s
    refine ⟨Γ, ?_, ?_⟩
    · intro s hs
      by_cases hlastIndex : s = r + 1
      · simpa [Γ, hlastIndex] using hΓlast
      · simpa [Γ, hlastIndex] using hΓprev s (show s ≤ r by omega)
    · intro s hs x y
      by_cases hlastIndex : s = r + 1
      · subst s
        rw [gram_coefficient_last hN]
        rw [coefficient_previous w (le_refl (r + 1)), coefficient_final]
        simp only [Γ, if_pos rfl]
        change |(∑ i : Fin N, Real.tanh (MeanFieldCoefficientSequence.lastRows w i x) *
          Real.tanh (MeanFieldCoefficientSequence.lastRows w i y)) / (N : ℝ) -
          tiltedMoment (activationMatrix (previousWeights w)) Γlast x y| ≤ K / G (r + 1)
        simpa only [last_field] using hcertlast x y
      · rw [coefficient_previous w (show s + 1 ≤ r + 1 by omega),
          coefficient_previous w (show s ≤ r + 1 by omega)]
        simpa only [Γ, if_neg hlastIndex] using hcertprev s (show s ≤ r by omega) x y

/-- Complete actual-network good-event-to-counted-class bridge. -/
theorem good_network_mem_functions {d N r K : ℕ} (hd : 0 < d) (hN : 0 < N) (hK : 0 < K)
    (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w ∈ marginEvent Real.tanh (1 / 2) f)
    (henergy : (N : ℝ) * (∑ i, w (.inr (.inr i)) ^ 2) ≤ (K : ℝ))
    (hgood : MeanFieldGoodEvent.GoodHidden d N r
      (fun s => (MeanFieldBudgets.layerBudget r K (s + 1) : ℝ)) (K : ℝ) w) :
    f ∈ MeanFieldFunctionClass.functions d r K := by
  obtain ⟨Γ, hΓ, hcert⟩ := exists_covariance_certificates hN
    (fun s => (MeanFieldBudgets.layerBudget r K (s + 1) : ℝ)) (K : ℝ) r w
    (fun s hs => by exact_mod_cast MeanFieldBudgets.layerBudget_pos r hK (s + 1)) hgood
  apply MeanFieldCompression.mem_functions_of_covariance_certificates hd hN hK w f
    (coefficient w) Γ hmargin henergy
  · intro x y
    rfl
  · exact gram_coefficient_final hN w
  · exact hΓ
  · exact hcert

end NeuralGeneralization.MeanFieldCertificateExtraction
