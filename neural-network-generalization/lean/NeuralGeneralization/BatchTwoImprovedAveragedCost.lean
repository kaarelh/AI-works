import NeuralGeneralization.BatchTwoImprovedSampledCost

/-! Integrating the actual sharp local coupling against the active-bank law.
Only its genuine active-energy and conditional-entropy integrals enter. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace InformationTheory
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustCompressionLayerGaussian RobustCompressionLayerCost RobustEntropy RobustGaussianGeometry
open BatchTwoImprovedLayerComparison Classical RobustCoupling
variable {A : Type*} [MeasurableSpace A] {N q m : ℕ}

theorem averaged_bank_four_cost (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (μ : Measure A) [IsProbabilityMeasure μ]
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin N → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (hbound : ∀ θ j, |h θ j| ≤ 1)
    {t BH BG : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 < BH) (hBG : 0 < BG)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1)
    {EH EK : ℝ≥0∞}
    (henergy : (∫⁻ θ, ENNReal.ofReal (∑ i, ‖H θ i‖^2) ∂μ) ≤ EH)
    (hentropy : (∫⁻ θ, klDiv (P θ) (standardGaussianVector N) ∂μ) ≤ EK) :
    let data := sampledBankData (m:=m) b hb H hH h hh
    let p := data.sharpParameters t BH
    (∫⁻ θ, ∫⁻ s, if sourceBad (b θ) s then 0 else
      (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
        (φ (⟪H θ i,activeCoordinateVector (b θ) (normalizedFeature (h θ))⟫+
            Real.sqrt (p.idealVariance (θ,s) i:ℝ)*z.1.1 i)-
          φ (p.clippedFiniteObservable BG ((θ,s),z.2) i))^2)
        ∂layerJointKernel (P.comap Prod.fst measurable_fst) p (θ,s))
      ∂sourceIndicesKernel hN hq m (fun j k => sourceRows (b θ) j k) ∂μ) ≤
      4*(ENNReal.ofReal (4/BH^2)*EH + ENNReal.ofReal (2*t^2)*EK +
        (ENNReal.ofReal (2/(m:ℝ))*EH + ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+
        ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) := by
  dsimp only
  let E : A → ℝ := fun θ => ∑ i, ‖H θ i‖^2
  let c₁ : ℝ≥0∞ := ENNReal.ofReal (4/BH^2)
  let c₂ : ℝ≥0∞ := ENNReal.ofReal (2*t^2)
  let c₃ : ℝ≥0∞ := ENNReal.ofReal (2/(m:ℝ))
  let c₄ : ℝ≥0∞ := ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m)
  let c₅ : ℝ≥0∞ := ENNReal.ofReal (128*(N:ℝ)*m/BG^2)
  have hE : Measurable (fun θ => ENNReal.ofReal (E θ)) := by dsimp [E]; fun_prop
  have hkl : Measurable (fun θ => klDiv (P θ) (standardGaussianVector N)) :=
    measurable_kernel_klDiv P (Kernel.const A (standardGaussianVector N))
  have hEnon (θ : A) : 0 ≤ E θ := Finset.sum_nonneg fun i _ => sq_nonneg _
  have hn : (0:ℝ)<m := Nat.cast_pos.mpr hm
  have hc₄ : 0 ≤ 16*(N:ℝ)*((q:ℝ)+1)/m := by positivity
  have hsample (θ : A) :
      ENNReal.ofReal ((2*E θ+16*(N:ℝ)*((q:ℝ)+1))/(m:ℝ)) =
        c₃*ENNReal.ofReal (E θ)+c₄ := by
    rw [add_div, ENNReal.ofReal_add (by positivity) hc₄]
    rw [show 2*E θ/(m:ℝ) = (2/(m:ℝ))*E θ by ring,
      ENNReal.ofReal_mul (by positivity)]
  calc
    _ ≤ ∫⁻ θ, 4*(c₁*ENNReal.ofReal (E θ)+c₂*klDiv (P θ) (standardGaussianVector N)+
        (c₃*ENNReal.ofReal (E θ)+c₄)+c₅) ∂μ := by
      apply lintegral_mono
      intro θ
      have hc := sampled_bank_four_cost hN hq hm b hb H hH h hh P θ (hbound θ)
        ht ht1 hBH hBG φ hφ hφb
      change _ ≤ 4*(ENNReal.ofReal ((4/BH^2)*E θ)+
        ENNReal.ofReal (2*t^2)*klDiv (P θ) (standardGaussianVector N)+
        ENNReal.ofReal ((2*E θ+16*(N:ℝ)*((q:ℝ)+1))/(m:ℝ))+
        ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) at hc
      rw [hsample, ENNReal.ofReal_mul (show 0 ≤ 4/BH^2 by positivity)] at hc
      exact hc
    _ = 4*(c₁*(∫⁻ θ, ENNReal.ofReal (E θ) ∂μ)+
        c₂*(∫⁻ θ, klDiv (P θ) (standardGaussianVector N) ∂μ)+
        (c₃*(∫⁻ θ, ENNReal.ofReal (E θ) ∂μ)+c₄)+c₅) := by
      rw [lintegral_const_mul _ (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_add_left (by fun_prop),
        lintegral_add_left (by fun_prop), lintegral_add_left (by fun_prop),
        lintegral_const_mul _ hE, lintegral_const_mul _ hkl,
        lintegral_const_mul _ hE]
      simp
    _ ≤ _ := mul_le_mul' le_rfl (add_le_add
      (add_le_add (add_le_add (mul_le_mul' le_rfl henergy) (mul_le_mul' le_rfl hentropy))
        (add_le_add (mul_le_mul' le_rfl henergy) le_rfl)) le_rfl)

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
