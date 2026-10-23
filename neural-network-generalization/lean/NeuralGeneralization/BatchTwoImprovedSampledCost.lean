import NeuralGeneralization.BatchTwoImprovedBankCost

/-! The sharp full local cost after averaging the actual importance source
sample. All costs use one genuine conditional Gaussian coefficient coupling. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace InformationTheory
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustCompressionLayerGaussian RobustCompressionLayerCost RobustEntropy RobustGaussianGeometry
open BatchTwoImprovedLayerComparison Classical
variable {A : Type*} [MeasurableSpace A] {N q m : ℕ}

theorem sampled_bank_four_cost (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin N → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h)
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (θ : A) (hbound : ∀ j, |h θ j| ≤ 1)
    {t BH BG : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 < BH) (hBG : 0 < BG)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1) :
    let data := sampledBankData (m:=m) b hb H hH h hh
    let p := data.sharpParameters t BH
    (∫⁻ s, if sourceBad (b θ) s then 0 else
      (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
        (φ (⟪H θ i,activeCoordinateVector (b θ) (normalizedFeature (h θ))⟫+
            Real.sqrt (p.idealVariance (θ,s) i:ℝ)*z.1.1 i)-
          φ (p.clippedFiniteObservable BG ((θ,s),z.2) i))^2)
        ∂layerJointKernel (P.comap Prod.fst measurable_fst) p (θ,s))
      ∂sourceIndicesKernel hN hq m (fun j k => sourceRows (b θ) j k)) ≤
      4*(ENNReal.ofReal ((4/BH^2)*∑ i, ‖H θ i‖^2)+
        ENNReal.ofReal (2*t^2)*klDiv (P θ) (Measure.pi (fun _ : Fin N => gaussianReal 0 1))+
        ENNReal.ofReal ((2*(∑ i, ‖H θ i‖^2)+16*(N:ℝ)*((q:ℝ)+1))/(m:ℝ))+
        ENNReal.ofReal (128*(N:ℝ)*m/BG^2)) := by
  dsimp only
  let data := sampledBankData (m:=m) b hb H hH h hh
  let p := data.sharpParameters t BH
  let μ := sourceIndicesKernel hN hq m (fun j k => sourceRows (b θ) j k)
  let c₁ := ENNReal.ofReal ((4/BH^2)*∑ i, ‖H θ i‖^2)
  let c₂ := ENNReal.ofReal (2*t^2)*klDiv (P θ) (Measure.pi (fun _ : Fin N => gaussianReal 0 1))
  let c₄ := ENNReal.ofReal (128*(N:ℝ)*m/BG^2)
  let G := fun s : Fin m → Fin N => if sourceBad (b θ) s then 0 else
    ENNReal.ofReal (gaussianParameterError p (θ,s))
  have hG := sampledBankData_parameter_lintegral hN hq hm b hb H hH h hh θ
    (fun j => by nlinarith [abs_le.mp (hbound j)]) ht ht1 hBH.le
  have hpoint (s : Fin m → Fin N) :
      (if sourceBad (b θ) s then 0 else
        (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
          (φ (⟪H θ i,activeCoordinateVector (b θ) (normalizedFeature (h θ))⟫+
              Real.sqrt (p.idealVariance (θ,s) i:ℝ)*z.1.1 i)-
            φ (p.clippedFiniteObservable BG ((θ,s),z.2) i))^2)
          ∂layerJointKernel (P.comap Prod.fst measurable_fst) p (θ,s))) ≤
        4*(c₁+c₂+G s+c₄) := by
    by_cases hbad : sourceBad (b θ) s
    · rw [if_pos hbad]
      exact bot_le
    · rw [if_neg hbad]
      have hc := sharp_bank_four_cost data hN hq hm (P.comap Prod.fst measurable_fst)
        (θ,s) hbound ht ht1 hBH hBG φ hφ hφb
      simpa only [G, if_neg hbad, Kernel.comap_apply, data, p, sampledBankData, c₁, c₂, c₄] using hc
  calc
    _ ≤ ∫⁻ s, 4*(c₁+c₂+G s+c₄) ∂μ := lintegral_mono hpoint
    _ = 4*(c₁+c₂+(∫⁻ s, G s ∂μ)+c₄) := by
      rw [lintegral_const_mul _ (measurable_of_countable _),
        lintegral_add_left (measurable_of_countable _),
        lintegral_add_left (measurable_of_countable _)]
      simp [μ]
    _ ≤ _ := mul_le_mul' le_rfl (add_le_add (add_le_add le_rfl hG) le_rfl)

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
