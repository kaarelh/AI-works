import NeuralGeneralization.GaussianReadout
import Mathlib.Tactic.FieldSimp

/-!
# The exact readout covariance of the concrete neural network

These identities hold before any width limit. The independent readout weights
are integrated under their actual Gaussian product law; the features are the
outputs of the actual preceding network layers.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.NetworkReadout
open ConcreteModel GaussianReadout

abbrev HiddenIndex (d N r : ℕ) :=
  (Fin N × Fin (d + 1)) ⊕ (Fin r × Fin N × Fin N)

def assemble {d N r : ℕ} (h : HiddenIndex d N r → ℝ) (a : Fin N → ℝ) :
    Weights d N r
  | Sum.inl ij => h (Sum.inl ij)
  | Sum.inr (Sum.inl sij) => h (Sum.inr sij)
  | Sum.inr (Sum.inr i) => a i

def features {d N r : ℕ} (φ : ℝ → ℝ) (h : HiddenIndex d N r → ℝ)
    (i : Fin N) (x : Cube d) : ℝ := finalHidden φ (assemble h 0) x i

@[simp] theorem finalHidden_assemble {d N r : ℕ} (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (a : Fin N → ℝ) (x : Cube d) :
    finalHidden φ (assemble h a) x = finalHidden φ (assemble h 0) x := rfl

theorem networkOutput_assemble {d N r : ℕ} (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (a : Fin N → ℝ) :
    toLp 2 (networkOutput φ (assemble h a)) = readout (features φ h) a := rfl

def empiricalGram {d N r : ℕ} (φ : ℝ → ℝ) (h : HiddenIndex d N r → ℝ)
    (x y : Cube d) : ℝ := gram (features φ h) x y / N

/-- The characteristic function of the actual network output when its hidden
weights are fixed and only its independent readout weights are integrated. -/
theorem charFun_frozen_network {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (v : ℝ≥0) (t : EuclideanSpace ℝ (Cube d)) :
    charFun ((Measure.pi fun _ : Fin N => gaussianReal 0 v).map
      (fun a => toLp 2 (networkOutput φ (assemble h a)))) t =
      Complex.exp (((-((v : ℝ) * N) *
        (∑ x, ∑ y, t x * empiricalGram φ h x y * t y) / 2 : ℝ) : ℂ)) := by
  simp only [networkOutput_assemble, charFun_readout_gram, empiricalGram]
  congr 2
  have hNne : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  simp only [div_eq_mul_inv]
  simp_rw [mul_assoc, mul_comm (N : ℝ)⁻¹, ← mul_assoc]
  simp only [← Finset.sum_mul]
  field_simp

/-- Substitution of the paper's readout variance gives exactly `N⁻ᵞ Q_N`.
This holds for every real exponent, including both nonpositive endpoints. -/
theorem charFun_power_frozen_network {d N r : ℕ} (hN : 0 < N) (φ : ℝ → ℝ)
    (h : HiddenIndex d N r → ℝ) (γ : ℝ) (t : EuclideanSpace ℝ (Cube d)) :
    charFun ((Measure.pi fun _ : Fin N => gaussianReal 0
      ((N : ℝ) ^ (-γ - 1)).toNNReal).map
      (fun a => toLp 2 (networkOutput φ (assemble h a)))) t =
      Complex.exp (((-((N : ℝ) ^ (-γ)) *
        (∑ x, ∑ y, t x * empiricalGram φ h x y * t y) / 2 : ℝ) : ℂ)) := by
  rw [charFun_frozen_network hN]
  have hNp : (0 : ℝ) < N := by exact_mod_cast hN
  rw [Real.toNNReal_of_nonneg (Real.rpow_nonneg hNp.le _)]
  have hpower : (N : ℝ) ^ (-γ - 1) * N = (N : ℝ) ^ (-γ) := by
    rw [Real.rpow_sub hNp, Real.rpow_one]
    exact div_mul_cancel₀ _ hNp.ne'
  simp only [NNReal.coe_mk]
  rw [hpower]

/-- Splits the actual weight coordinates into hidden and readout coordinates. -/
def weightSplit (d N r : ℕ) : Weights d N r ≃ᵐ
    (HiddenIndex d N r → ℝ) × (Fin N → ℝ) :=
  ((MeasurableEquiv.piCongrLeft (fun _ : WeightIndex d N r => ℝ)
    (Equiv.sumAssoc _ _ _)).symm).trans
      (MeasurableEquiv.sumPiEquivProdPi (fun _ : HiddenIndex d N r ⊕ Fin N => ℝ))

@[simp] theorem weightSplit_symm {d N r : ℕ}
    (h : HiddenIndex d N r → ℝ) (a : Fin N → ℝ) :
    (weightSplit d N r).symm (h, a) = assemble h a := by
  funext i
  rcases i with ij | (sij | k) <;> rfl

def hiddenPrior (d N r : ℕ) (γ : ℝ) : Measure (HiddenIndex d N r → ℝ) :=
  Measure.pi (fun i : HiddenIndex d N r => gaussianReal 0
    (powerVariance d N r γ ((Equiv.sumAssoc _ _ _) (Sum.inl i))).toNNReal)

def readoutPrior (N : ℕ) (γ : ℝ) : Measure (Fin N → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 ((N : ℝ) ^ (-γ - 1)).toNNReal)

instance hiddenPrior_probability (d N r : ℕ) (γ : ℝ) :
    IsProbabilityMeasure (hiddenPrior d N r γ) := by unfold hiddenPrior; infer_instance

instance readoutPrior_probability (N : ℕ) (γ : ℝ) :
    IsProbabilityMeasure (readoutPrior N γ) := by unfold readoutPrior; infer_instance

/-- Exact factorization of the original product-Gaussian network prior. -/
theorem measurePreserving_weightSplit (d N r : ℕ) (γ : ℝ) :
    MeasurePreserving (weightSplit d N r) (powerPrior d N r γ)
      ((hiddenPrior d N r γ).prod (readoutPrior N γ)) := by
  let μ : WeightIndex d N r → Measure ℝ :=
    fun i => gaussianReal 0 (powerVariance d N r γ i).toNNReal
  have h1 := measurePreserving_piCongrLeft (α := fun _ : WeightIndex d N r => ℝ)
    μ (Equiv.sumAssoc (Fin N × Fin (d + 1)) (Fin r × Fin N × Fin N) (Fin N))
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun i => μ (Equiv.sumAssoc (Fin N × Fin (d + 1))
      (Fin r × Fin N × Fin N) (Fin N) i))
  have hs : MeasurePreserving (weightSplit d N r).symm
      ((hiddenPrior d N r γ).prod (readoutPrior N γ)) (powerPrior d N r γ) := h1.comp h2
  exact MeasurePreserving.symm (weightSplit d N r).symm hs

/-- The probability of every measurable output event is the actual mixture
of its frozen-hidden Gaussian readout probabilities. In particular this
identity applies to the exponentially rare all-input strict-margin events. -/
theorem output_event_probability {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (γ : ℝ) (B : Set (EuclideanSpace ℝ (Cube d))) (hB : MeasurableSet B) :
    powerPrior d N r γ ((fun w => toLp 2 (networkOutput φ w)) ⁻¹' B) =
      ∫⁻ h, readoutPrior N γ
        ((fun a => toLp 2 (networkOutput φ (assemble h a))) ⁻¹' B)
        ∂hiddenPrior d N r γ := by
  have houtput : Measurable (fun w : Weights d N r => toLp 2 (networkOutput φ w)) :=
    (WithLp.measurable_toLp 2 (Cube d → ℝ)).comp
      (measurable_pi_lambda _ (fun x => (continuous_networkOutput hφ x).measurable))
  have hs := MeasurePreserving.symm (weightSplit d N r)
    (measurePreserving_weightSplit d N r γ)
  rw [← hs.map_eq, Measure.map_apply hs.measurable (hB.preimage houtput),
    Measure.prod_apply (hs.measurable (hB.preimage houtput))]
  apply lintegral_congr
  intro h
  congr 1

end NeuralGeneralization.NetworkReadout
