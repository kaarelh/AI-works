import NeuralGeneralization.WalshMarginMinimizers
import NeuralGeneralization.ModelLearning

/-!
# From all hard minimizers to the actual positive-subcritical confidence bound

This is the final analytic transfer to the finite-width posterior. The
remaining statistical premise is stated for the actual global-margin energy
minimizers. No limiting distribution among tied minima is assumed.
-/

noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.NetworkSubcriticalConfidence
open ConcreteModel NetworkSubcriticalWalshRate WalshMarginMinimizers

/-- A compatible minimum of the finite full-sign energies always exists. -/
theorem exists_function_energy_minimizer {d n : ℕ} (r : ℕ) (a : ℝ)
    (f : BooleanFunction d) (sample : Fin n → Cube d) :
    ∃ target, consistent f sample target ∧
      ∀ g, consistent f sample g →
        walshMarginEnergy d r a target ≤ walshMarginEnergy d r a g := by
  classical
  let A := Finset.univ.filter (consistent f sample)
  have hA : A.Nonempty := ⟨f, Finset.mem_filter.mpr ⟨Finset.mem_univ _, fun _ => rfl⟩⟩
  obtain ⟨g, hg, hm⟩ := A.exists_min_image (walshMarginEnergy d r a) hA
  exact ⟨g, (Finset.mem_filter.mp hg).2, fun h hh =>
    hm h (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hh⟩)⟩

/-- Under hardness of every compatible energy minimizer, posterior mass on
functions with error below three eighths tends to zero. -/
theorem low_error_mass_tendsto_zero {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (D : InputLaw d) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hhard : ∀ target, consistent f sample target →
      (∀ g, consistent f sample g →
        walshMarginEnergy d r a target ≤ walshMarginEnergy d r a g) →
      (3/8 : ℝ) ≤ functionError D f target) :
    Tendsto (fun N => ∑ g ∈ Finset.univ.filter (fun g => functionError D f g < (3/8 : ℝ)),
      networkPosterior Real.tanh a (powerPrior d N r γ) f sample g) atTop (𝓝 0) := by
  classical
  obtain ⟨target, ht, hmin⟩ := exists_function_energy_minimizer r a f sample
  have hlim (g : BooleanFunction d) (hg : functionError D f g < (3/8 : ℝ)) :
      Tendsto (fun N => networkPosterior Real.tanh a (powerPrior d N r γ) f sample g)
        atTop (𝓝 (0 : ℝ)) := by
    by_cases hk : consistent f sample g
    · have hgap : walshMarginEnergy d r a target < walshMarginEnergy d r a g := by
        apply lt_of_le_of_ne (hmin g hk)
        intro he
        have hgm : ∀ h, consistent f sample h →
            walshMarginEnergy d r a g ≤ walshMarginEnergy d r a h := by
          intro h hh
          rw [← he]
          exact hmin h hh
        exact (not_le_of_gt hg) (hhard g hk hgm)
      exact networkPosterior_tendsto_zero_of_energy_gap hd r hγ0 hγ1 ha f target g sample ht hgap
    · have hz (N : ℕ) : networkPosterior Real.tanh a (powerPrior d N r γ) f sample g = 0 := by
        simp [networkPosterior, posterior, hk]
      simpa only [hz] using (tendsto_const_nhds : Tendsto (fun _ : ℕ => (0 : ℝ)) atTop (𝓝 0))
  have hsum := tendsto_finsetSum
    (Finset.univ.filter (fun g => functionError D f g < (3/8 : ℝ)))
    (fun g hg => hlim g (Finset.mem_filter.mp hg).2)
  simpa using hsum

/-- The actual neural posterior satisfies the strict-confidence lower bound
whenever every minimizing compatible full-sign function has error at least
three eighths. This includes all ties without selecting one. -/
theorem confidence_liminf_of_hard_function_minimizers {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (D : InputLaw d) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hhard : ∀ target, consistent f sample target →
      (∀ g, consistent f sample g →
        walshMarginEnergy d r a target ≤ walshMarginEnergy d r a g) →
      (3/8 : ℝ) ≤ functionError D f target) :
    (1/16 : ℝ) ≤ Filter.liminf (fun N => ConcreteModel.confidenceFailure D f
      (networkPosterior Real.tanh a (powerPrior d N r γ) f sample)) atTop := by
  classical
  let p := fun N => networkPosterior Real.tanh a (powerPrior d N r γ) f sample
  let B := Finset.univ.filter (fun g => functionError D f g < (3/8 : ℝ))
  let t := fun N => (3/8 : ℝ) * ∑ g ∈ B, p N g
  have ht : Tendsto t atTop (𝓝 0) := by
    simpa only [t, zero_mul, mul_zero] using
      (low_error_mass_tendsto_zero hd r hγ0 hγ1 ha D f sample hhard).const_mul (3/8 : ℝ)
  have hpos := (actual_functionMass_hasExponentialRate hd r hγ0 hγ1 ha f).eventually_pos
  have hp : ∀ᶠ N in atTop, (∀ g, 0 ≤ p N g) ∧ ∑ g, p N g = 1 := by
    filter_upwards [hpos] with N hN
    exact ⟨networkPosterior_nonneg Real.tanh a (powerPrior d N r γ) f sample hN,
      networkPosterior_sum Real.tanh a (powerPrior d N r γ) f sample hN⟩
  have hrisk : ∀ᶠ N in atTop,
      (3/8 : ℝ) - t N ≤ averageRisk (p N) D.mass (fun g x => g x) f := by
    filter_upwards [hp] with N hN
    have herr (g : BooleanFunction d) : 0 ≤ functionError D f g := by
      apply Finset.sum_nonneg
      intro x _
      split_ifs
      · exact le_rfl
      · exact D.nonneg x
    have hA (g : BooleanFunction d) (hg : g ∈ Finset.univ \ B) :
        (3/8 : ℝ) ≤ functionError D f g := by
      have hnot := (Finset.mem_sdiff.mp hg).2
      exact le_of_not_gt (fun hh => hnot (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hh⟩))
    have hm := mixture_risk_lower_of_hard_set (p N) (functionError D f)
      (Finset.univ \ B) (3/8 : ℝ) hN.1 hN.2 herr hA
    have hs : (∑ g ∈ Finset.univ \ B, p N g) = 1 - ∑ g ∈ B, p N g := by
      rw [Finset.sum_sdiff_eq_sub (Finset.subset_univ B), hN.2]
    rw [hs] at hm
    rw [← posteriorRisk_eq_averageRisk]
    change (3/8 : ℝ) - (3/8 : ℝ) * (∑ g ∈ B, p N g) ≤ ∑ g, p N g * functionError D f g
    linarith
  exact liminf_confidenceFailure_lower p D.mass (fun g x => g x) f
    hp D.nonneg D.sum_one t ht hrisk

/-- A positive closed margin fixes the Boolean sign without a zero tie. -/
theorem closedWalshMargin_sign {d : ℕ} {a : ℝ} (ha : 0 < a)
    (g : BooleanFunction d) {c : Finset (Fin d) → ℝ}
    (hc : c ∈ closedWalshMarginSet d a g) :
    (fun x => decide (0 ≤ walshExpansion c x)) = g := by
  funext x
  have hx := hc x
  cases hg : g x
  · have hn : ¬ 0 ≤ walshExpansion c x := by
      simp only [hg, labelReal_false, neg_one_mul] at hx
      linarith
    simp [hn]
  · have hn : 0 ≤ walshExpansion c x := by
      simp only [hg, labelReal_true, one_mul] at hx
      linarith
    simp [hn]

/-- The statistical premise is exactly the manuscript's global-margin field
minimization problem. Its conclusion concerns the original finite networks,
with the user's strict correct-label probability greater than two thirds. -/
theorem confidence_liminf_of_hard_global_minimizers {d n : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ0 : 0 < γ) (hγ1 : γ < 1) {a : ℝ} (ha : 0 < a)
    (D : InputLaw d) (f : BooleanFunction d) (sample : Fin n → Cube d)
    (hhard : ∀ c ∈ globalTrainingMarginSet a f sample,
      (∀ z ∈ globalTrainingMarginSet a f sample,
        featureEnergy (walshCoefficients (arcsineProfile d (r+1))) c ≤
          featureEnergy (walshCoefficients (arcsineProfile d (r+1))) z) →
      (3/8 : ℝ) ≤ functionError D f (fun x => decide (0 ≤ walshExpansion c x))) :
    (1/16 : ℝ) ≤ Filter.liminf (fun N => ConcreteModel.confidenceFailure D f
      (networkPosterior Real.tanh a (powerPrior d N r γ) f sample)) atTop := by
  apply confidence_liminf_of_hard_function_minimizers hd r hγ0 hγ1 ha D f sample
  intro target ht hmin
  obtain ⟨c, hc, hfeas, _, hcm⟩ :=
    exists_global_minimizer_of_function_minimizer r ha f target sample ht hmin
  have he := hhard c hfeas hcm
  rwa [closedWalshMargin_sign ha target hc] at he

end NeuralGeneralization.NetworkSubcriticalConfidence
