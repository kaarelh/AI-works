import NeuralGeneralization.BatchTwoImprovedBankBounds

/-! The exact sharp Gaussian parameter cost in nonnegative integral form. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open RobustCompressionLayerGaussian Classical
variable {A : Type*} [MeasurableSpace A] {N q m D : ℕ}

def gaussianParameterError (p : GaussianLayerParameters A D m q) (θ : A) : ℝ :=
  ∑ i, ((p.idealMean θ i-p.finiteMean θ i)^2+
    (Real.sqrt (p.idealVariance θ i:ℝ)-Real.sqrt (p.finiteVariance θ i:ℝ))^2)

theorem gaussianParameterError_nonneg (p : GaussianLayerParameters A D m q) (θ : A) :
    0 ≤ gaussianParameterError p θ :=
  Finset.sum_nonneg (fun _ _ => add_nonneg (sq_nonneg _) (sq_nonneg _))

theorem gaussianParameterError_measurable (p : GaussianLayerParameters A D m q) :
    Measurable (gaussianParameterError p) := by
  have ha := p.idealMean_measurable
  have hb := p.finiteMean_measurable
  have hv := p.idealVariance_measurable
  have hw := p.finiteVariance_measurable
  unfold gaussianParameterError
  fun_prop

theorem sampledBankData_parameter_lintegral (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin D → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h) (θ : A) (hbound : ∀ j, (h θ j)^2 ≤ 1)
    {t BH : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 ≤ BH) :
    let P := (sampledBankData (m:=m) b hb H hH h hh).sharpParameters t BH
    (∫⁻ s, if sourceBad (b θ) s then 0 else ENNReal.ofReal (gaussianParameterError P (θ,s))
      ∂sourceIndicesKernel hN hq m (fun j k => RobustGaussianGeometry.sourceRows (b θ) j k)) ≤
      ENNReal.ofReal ((2*(∑ i, ‖H θ i‖^2)+16*(D:ℝ)*((q:ℝ)+1))/(m:ℝ)) := by
  classical
  dsimp only
  let P := (sampledBankData (m:=m) b hb H hH h hh).sharpParameters t BH
  let F := fun s : Fin m → Fin N => if sourceBad (b θ) s then 0 else gaussianParameterError P (θ,s)
  have hF : ∀ s, 0 ≤ F s := by
    intro s
    dsimp only [F]
    split_ifs
    · exact le_rfl
    · exact gaussianParameterError_nonneg _ _
  have he (s : Fin m → Fin N) :
      (if sourceBad (b θ) s then 0 else ENNReal.ofReal (gaussianParameterError P (θ,s))) =
        ENNReal.ofReal (F s) := by dsimp only [F]; split_ifs <;> simp
  change (∫⁻ s, if sourceBad (b θ) s then 0 else ENNReal.ofReal (gaussianParameterError P (θ,s))
    ∂sourceIndicesKernel hN hq m (fun j k => RobustGaussianGeometry.sourceRows (b θ) j k)) ≤ _
  simp_rw [he]
  rw [← ofReal_integral_eq_lintegral_ofReal Integrable.of_finite (Filter.Eventually.of_forall hF)]
  exact ENNReal.ofReal_le_ofReal (sampledBankData_parameter_error hN hq hm b hb H hH h hh θ hbound ht ht1 hBH)

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
