import NeuralGeneralization.BatchTwoCircuitConverseIIDCoverage

/-!
# Infinite posterior samples and a.s. finite support coverage

The actual total is the extended nonnegative sum of literal 0/1 mistakes.
The conditional sampling law, Tonelli, and the zero-error property at repeated
inputs identify it with the finite complete-reveal compensator in expectation.
-/
namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped ENNReal BigOperators
open MeasureTheory
noncomputable section
open Classical
variable {d : ℕ} {Ω : Type*}

def sampledError (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (n : ℕ) (ω : Ω) : ℝ :=
  if prediction ω n = f (query ω n) then 0 else 1

def infiniteSampledMistakes (f : Input d → Bool) (query : Ω → ℕ → Input d)
    (prediction : Ω → ℕ → Bool) (ω : Ω) : ℝ≥0∞ :=
  ∑' n, ENNReal.ofReal (sampledError f query prediction n ω)

/-- Once the support has been covered, every remaining query is a repetition. -/
theorem totalError_eq_prefix_of_cover (w : (Input d → Bool) → ℝ)
    (f : Input d → Bool) (hw : ∀ g, 0 ≤ w g) (hwf : 0 < w f)
    (query : ℕ → Input d) (A : Finset (Input d)) (n : ℕ)
    (hcover : history query n = A) (hin : ∀ i, query i ∈ A) :
    BatchTwoOnline.totalError w (fun g x => g x = f x) query =
      ENNReal.ofReal (BatchTwoOnline.cumulativeError w (fun g x => g x = f x) query n) := by
  unfold BatchTwoOnline.totalError
  rw [tsum_eq_sum (s := Finset.range n) (fun i hi => by
    have hni : n ≤ i := Nat.le_of_not_gt (fun hh => hi (Finset.mem_range.mpr hh))
    have hx : query i ∈ history query n := hcover.symm ▸ hin i
    obtain ⟨j, hj, heq⟩ := Finset.mem_image.mp hx
    rw [BatchTwoOnline.onlineError_eq_zero_of_repeated _ _ _
      (lt_of_lt_of_le (Finset.mem_range.mp hj) hni) heq, ENNReal.ofReal_zero])]
  unfold BatchTwoOnline.cumulativeError
  exact (ENNReal.ofReal_sum_of_nonneg (fun i _ =>
    BatchTwoOnline.onlineError_nonneg _ _ _ hw f (fun _ => rfl) hwf i)).symm

/-- A generic integration bridge. Its pathwise hypotheses are numerical bounds
on complete finite reveals, discharged from each explicit prior below. -/
theorem infinite_sampled_bounds_of_complete_paths
    [mΩ : MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (information : ℕ → MeasurableSpace Ω) (hinfo : ∀ n, information n ≤ mΩ)
    (w : (Input d → Bool) → ℝ) (hw : ∀ g, 0 ≤ w g) (hwsum : ∑ g, w g ≤ 1)
    (f : Input d → Bool) (hwf : 0 < w f) (A : Finset (Input d))
    (query : Ω → ℕ → Input d) (prediction : Ω → ℕ → Bool)
    (hcomplete : ∀ᵐ ω ∂μ, (∀ i, query ω i ∈ A) ∧
      ∃ n, history (query ω) n = A)
    (hmeas : ∀ n, AEStronglyMeasurable (sampledError f query prediction n) μ)
    (hlaw : ∀ n, μ[sampledError f query prediction n | information n] =ᵐ[μ]
      fun ω => BatchTwoOnline.onlineError w (fun g x => g x = f x) (query ω) n)
    (L a : ℝ)
    (hpath : ∀ q n, history q n = A →
      BatchTwoOnline.cumulativeError w (fun g x => g x = f x) q n ≤ L ∧
      L ≤ a*BatchTwoOnline.cumulativeError w (fun g x => g x = f x) q n) :
    let E := ∫⁻ ω, infiniteSampledMistakes f query prediction ω ∂μ
    E ≠ ⊤ ∧ L ≤ a*E.toReal ∧ E.toReal ≤ L := by
  let pred := fun n ω => BatchTwoOnline.onlineError w (fun g x => g x = f x) (query ω) n
  have hpred : ∀ n ω, 0 ≤ pred n ω ∧ pred n ω ≤ 1 := fun n ω =>
    ⟨BatchTwoOnline.onlineError_nonneg _ _ _ hw f (fun _ => rfl) hwf n,
      BatchTwoOnline.onlineError_le_one _ _ _ hw f (fun _ => rfl) hwf n⟩
  have hactual : ∀ n ω, 0 ≤ sampledError f query prediction n ω ∧
      sampledError f query prediction n ω ≤ 1 := by
    intro n ω
    unfold sampledError
    split_ifs <;> norm_num
  have he := expected_counts_equal_of_conditional_law μ information hinfo _ pred
    hmeas hactual hpred hlaw
  let total := fun ω => BatchTwoOnline.totalError w (fun g x => g x = f x) (query ω)
  have hpm : ∀ n, AEStronglyMeasurable (pred n) μ := fun n =>
    (integrable_condExp (μ := μ) (f := sampledError f query prediction n)
      (m := information n)).aestronglyMeasurable.congr (hlaw n)
  have htm : AEMeasurable total μ := AEMeasurable.ennreal_tsum (fun n =>
    ENNReal.measurable_ofReal.comp_aemeasurable (hpm n).aemeasurable)
  have htbound (ω) : total ω ≤ ENNReal.ofReal (-Real.log (w f)) :=
    BatchTwoOnline.totalError_le_neg_log _ _ _ hw f (fun _ => rfl) hwf hwsum
  have htfinite (ω) : total ω ≠ ⊤ := ne_top_of_le_ne_top ENNReal.ofReal_ne_top (htbound ω)
  have htmeas : AEStronglyMeasurable (fun ω => (total ω).toReal) μ :=
    (ENNReal.measurable_toReal.comp_aemeasurable htm).aestronglyMeasurable
  have hcost0 : 0 ≤ -Real.log (w f) := by
    have hweight : w f ≤ 1 := (Finset.single_le_sum (fun g _ => hw g)
      (Finset.mem_univ f)).trans hwsum
    have hlog := Real.log_le_log hwf hweight
    simp only [Real.log_one] at hlog
    linarith
  have htInt : Integrable (fun ω => (total ω).toReal) μ :=
    (integrable_const (-Real.log (w f))).mono' htmeas
      (Filter.Eventually.of_forall (fun ω => by
        rw [Real.norm_eq_abs, abs_of_nonneg ENNReal.toReal_nonneg]
        have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top (htbound ω)
        rwa [ENNReal.toReal_ofReal hcost0] at hh))
  have he' : (∫⁻ ω, infiniteSampledMistakes f query prediction ω ∂μ) =
      ENNReal.ofReal (∫ ω, (total ω).toReal ∂μ) := by
    change (∫⁻ ω, infiniteSampledMistakes f query prediction ω ∂μ) = _ at he ⊢
    calc
      _ = ∫⁻ ω, total ω ∂μ := he
      _ = ∫⁻ ω, ENNReal.ofReal (total ω).toReal ∂μ := by
        apply lintegral_congr
        intro ω
        exact (ENNReal.ofReal_toReal (htfinite ω)).symm
      _ = _ := (ofReal_integral_eq_lintegral_ofReal htInt
        (Filter.Eventually.of_forall (fun _ => ENNReal.toReal_nonneg))).symm
  have hbounds : ∀ᵐ ω ∂μ, (total ω).toReal ≤ L ∧ L ≤ a*(total ω).toReal :=
    hcomplete.mono (fun ω hω => by
      obtain ⟨hin, n, hn⟩ := hω
      have heq := totalError_eq_prefix_of_cover w f hw hwf (query ω) A n hn hin
      have hnonneg : 0 ≤ BatchTwoOnline.cumulativeError w
          (fun g x => g x = f x) (query ω) n :=
        Finset.sum_nonneg (fun i _ => (hpred i ω).1)
      change (BatchTwoOnline.totalError w (fun g x => g x = f x) (query ω)).toReal ≤ L ∧
        L ≤ a*(BatchTwoOnline.totalError w (fun g x => g x = f x) (query ω)).toReal
      rw [heq, ENNReal.toReal_ofReal hnonneg]
      exact hpath (query ω) n hn)
  have hupper := integral_mono_ae htInt (integrable_const L) (hbounds.mono (fun _ h => h.1))
  have hlower := integral_mono_ae (integrable_const L) (htInt.const_mul a)
    (hbounds.mono (fun _ h => h.2))
  simp only [integral_const, probReal_univ, one_smul, integral_const_mul] at hupper hlower
  have hm0 : 0 ≤ ∫ ω, (total ω).toReal ∂μ := integral_nonneg (fun _ => ENNReal.toReal_nonneg)
  dsimp only
  rw [he', ENNReal.toReal_ofReal hm0]
  exact ⟨ENNReal.ofReal_ne_top, hlower, hupper⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse
