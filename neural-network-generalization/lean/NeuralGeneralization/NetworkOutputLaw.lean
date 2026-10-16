import NeuralGeneralization.NetworkReadout
import NeuralGeneralization.ConcreteReadoutDual

/-! Exact characteristic function of the normalized finite-width output law.
The result integrates the actual empirical covariance under the actual prior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.NetworkOutputLaw
open ConcreteModel NetworkReadout

def normalizedOutput {d N r : ℕ} (φ : ℝ → ℝ) (γ : ℝ) (w : Weights d N r) :
    EuclideanSpace ℝ (Cube d) :=
  (N : ℝ) ^ (γ / 2) • toLp 2 (networkOutput φ w)

theorem continuous_normalizedOutput {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (γ : ℝ) : Continuous (normalizedOutput (d := d) (N := N) (r := r) φ γ) := by
  unfold normalizedOutput
  have hc : Continuous (fun w : Weights d N r => toLp 2 (networkOutput φ w)) :=
    (PiLp.continuous_toLp (p := 2) (β := fun _ : Cube d => ℝ)).comp
      (continuous_pi (fun x => continuous_networkOutput hφ x))
  fun_prop

def law (d N r : ℕ) (φ : ℝ → ℝ) (γ : ℝ) :
    Measure (EuclideanSpace ℝ (Cube d)) :=
  (powerPrior d N r γ).map (normalizedOutput φ γ)

theorem law_probability {φ : ℝ → ℝ} (hφ : Continuous φ) (d N r : ℕ) (γ : ℝ) :
    IsProbabilityMeasure (law d N r φ γ) :=
  Measure.isProbabilityMeasure_map (continuous_normalizedOutput hφ γ).measurable.aemeasurable

def covarianceChar {I : Type*} [Fintype I] (Q : I → I → ℝ) (t : EuclideanSpace ℝ I) : ℂ :=
  Complex.exp (((-(∑ x, ∑ y, t x * Q x y * t y) / 2 : ℝ) : ℂ))

theorem charFun_frozen_normalized {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (γ : ℝ) (t : EuclideanSpace ℝ (Cube d)) :
    charFun ((readoutPrior N γ).map
      (fun a => normalizedOutput φ γ (assemble h a))) t =
      covarianceChar (empiricalGram φ h) t := by
  have hc : Continuous (fun a : Fin N → ℝ => toLp 2 (networkOutput φ (assemble h a))) :=
    by simpa only [networkOutput_assemble] using
      GaussianReadout.continuous_readout (features φ h)
  simp only [normalizedOutput]
  rw [charFun_map_smul_comp hc.measurable.aemeasurable, readoutPrior,
    charFun_power_frozen_network hN]
  unfold covarianceChar
  congr 2
  have hp : 0 < (N : ℝ) := by exact_mod_cast hN
  have heq : (N : ℝ) ^ (-γ) * ((N : ℝ) ^ (γ / 2)) ^ 2 = 1 := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul hp.le, ← Real.rpow_add hp]
    have he : -γ + γ / 2 * (2 : ℕ) = 0 := by ring
    rw [he, Real.rpow_zero]
  have hquad : (∑ x, ∑ y, ((N : ℝ) ^ (γ / 2) • t) x * empiricalGram φ h x y *
      ((N : ℝ) ^ (γ / 2) • t) y) =
      ((N : ℝ) ^ (γ / 2)) ^ 2 * (∑ x, ∑ y, t x * empiricalGram φ h x y * t y) := by
    simp only [PiLp.smul_apply, smul_eq_mul, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x hx
    apply Finset.sum_congr rfl
    intro y hy
    ring
  rw [hquad]
  rw [neg_mul, ← mul_assoc, heq, one_mul]

theorem continuous_covarianceChar {I : Type*} [Fintype I] (t : EuclideanSpace ℝ I) :
    Continuous (fun Q : I → I → ℝ => covarianceChar Q t) := by
  unfold covarianceChar
  fun_prop

theorem continuous_finalCovariance {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ) :
    Continuous (fun w : Weights d N r => finalCovariance φ w) := by
  apply continuous_pi
  intro x
  apply continuous_pi
  intro y
  unfold finalCovariance
  exact (continuous_finsetSum _ (fun i _ =>
    (continuous_finalHidden hφ x i).mul (continuous_finalHidden hφ y i))).div_const _

theorem covarianceChar_norm_le_one {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (γ : ℝ) (t : EuclideanSpace ℝ (Cube d)) :
    ‖covarianceChar (empiricalGram φ h) t‖ ≤ 1 := by
  rw [← charFun_frozen_normalized hN φ h γ t]
  letI : IsProbabilityMeasure ((readoutPrior N γ).map
      (fun a => normalizedOutput φ γ (assemble h a))) :=
    Measure.isProbabilityMeasure_map (by
      simp only [normalizedOutput, networkOutput_assemble]
      fun_prop)
  exact norm_charFun_le_one _

theorem integral_split {d N r : ℕ} (γ : ℝ) (F : Weights d N r → ℂ)
    (hF : Integrable (fun z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ) =>
      F (assemble z.1 z.2)) ((hiddenPrior d N r γ).prod (readoutPrior N γ))) :
    (∫ w, F w ∂powerPrior d N r γ) =
      ∫ h, ∫ a, F (assemble h a) ∂readoutPrior N γ ∂hiddenPrior d N r γ := by
  have hs := (MeasurePreserving.symm (weightSplit d N r)
    (measurePreserving_weightSplit d N r γ)).integral_comp' F
  have he (z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ)) :
      (weightSplit d N r).symm z = assemble z.1 z.2 := weightSplit_symm z.1 z.2
  simp_rw [he] at hs
  rw [← hs]
  exact integral_prod _ hF

theorem charFun_law {d N r : ℕ} (hN : 0 < N) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (γ : ℝ) (t : EuclideanSpace ℝ (Cube d)) :
    charFun (law d N r φ γ) t =
      ∫ w, covarianceChar (finalCovariance φ w) t ∂powerPrior d N r γ := by
  let F : Weights d N r → ℂ := fun w =>
    Complex.exp (((⟪normalizedOutput φ γ w, t⟫ : ℝ) : ℂ) * Complex.I)
  have hmeas : Measurable F := by
    apply Continuous.measurable
    exact Complex.continuous_exp.comp
      ((Complex.continuous_ofReal.comp ((continuous_normalizedOutput hφ γ).inner continuous_const)).mul
        continuous_const)
  have hsplitmeas : Measurable (fun z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ) =>
      assemble z.1 z.2) := by
    have he : (fun z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ) =>
        assemble z.1 z.2) = (weightSplit d N r).symm :=
      funext fun z => (weightSplit_symm z.1 z.2).symm
    rw [he]
    exact (weightSplit d N r).symm.measurable
  have hF : Integrable (fun z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ) =>
      F (assemble z.1 z.2)) ((hiddenPrior d N r γ).prod (readoutPrior N γ)) := by
    apply (integrable_const (1 : ℝ)).mono' (hmeas.comp hsplitmeas).aestronglyMeasurable
    exact Filter.Eventually.of_forall (fun z => by
      simp only [Function.comp_apply, F, Complex.norm_exp_ofReal_mul_I, le_refl])
  rw [law, charFun_apply, integral_map
    (continuous_normalizedOutput hφ γ).measurable.aemeasurable (by fun_prop)]
  change (∫ w, F w ∂powerPrior d N r γ) = _
  rw [integral_split γ F hF]
  have hfrozen (h : HiddenIndex d N r → ℝ) :
      (∫ a, F (assemble h a) ∂readoutPrior N γ) = covarianceChar (empiricalGram φ h) t := by
    rw [← charFun_frozen_normalized hN φ h γ t, charFun_apply,
      integral_map (by
        simp only [normalizedOutput, networkOutput_assemble]
        fun_prop)
        (by fun_prop)]
  simp_rw [hfrozen]
  let G : Weights d N r → ℂ := fun w => covarianceChar (finalCovariance φ w) t
  have hGmeas : Measurable G :=
    ((continuous_covarianceChar t).comp (continuous_finalCovariance hφ)).measurable
  have hG : Integrable (fun z : (HiddenIndex d N r → ℝ) × (Fin N → ℝ) =>
      G (assemble z.1 z.2)) ((hiddenPrior d N r γ).prod (readoutPrior N γ)) := by
    apply (integrable_const (1 : ℝ)).mono' (hGmeas.comp hsplitmeas).aestronglyMeasurable
    exact Filter.Eventually.of_forall (fun z => covarianceChar_norm_le_one hN φ z.1 γ t)
  change _ = ∫ w, G w ∂powerPrior d N r γ
  rw [integral_split γ G hG]
  apply integral_congr_ae
  filter_upwards [] with h
  change covarianceChar (empiricalGram φ h) t =
    ∫ a, covarianceChar (empiricalGram φ h) t ∂readoutPrior N γ
  simp

theorem covarianceChar_final_norm_le_one {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (t : EuclideanSpace ℝ (Cube d)) :
    ‖covarianceChar (finalCovariance φ w) t‖ ≤ 1 := by
  by_cases hN : N = 0
  · subst N
    simp [covarianceChar, finalCovariance]
  · let h : HiddenIndex d N r → ℝ
      | Sum.inl ij => w (Sum.inl ij)
      | Sum.inr sij => w (Sum.inr (Sum.inl sij))
    have he : finalCovariance φ w = empiricalGram φ h := rfl
    rw [he]
    exact covarianceChar_norm_le_one (Nat.pos_of_ne_zero hN) φ h 0 t

end NeuralGeneralization.NetworkOutputLaw
