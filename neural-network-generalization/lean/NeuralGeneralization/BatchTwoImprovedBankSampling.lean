import NeuralGeneralization.BatchTwoImprovedBankParameters
import NeuralGeneralization.BatchTwoImprovedWhitenedMoment

/-! Integrating the sharp layer comparison in a genuinely parameterized
source bank.  Clipping the active row can only decrease its energy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry RobustCompressionReconstruction
open RobustCompression RobustCompressionClipping RobustCompressionGaussian
open RobustCompressionLayerGaussian BatchTwoImprovedGaussianSquareRoot Classical
variable {A : Type*} [MeasurableSpace A] {N q m D : ℕ}

def sampledBankData (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin D → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h) : SharpBankData (A × (Fin m → Fin N)) N D m q where
  basis := fun θ => b θ.1
  active := fun θ => H θ.1
  feature := fun θ => h θ.1
  indices := Prod.snd
  basis_measurable := hb.comp measurable_fst
  active_measurable := hH.comp measurable_fst
  feature_measurable := hh.comp measurable_fst
  indices_measurable := measurable_snd

/-- The sharp source moment estimate is valid inside the jointly measurable
Gaussian field coupling, with no pointwise choice of a different row law. -/
theorem sampledBankData_whitened_error (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin D → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h) (θ : A) (hbound : ∀ j, (h θ j)^2 ≤ 1)
    {t BH : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 ≤ BH)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    let P := (sampledBankData (m:=m) b hb H hH h hh).sharpParameters t BH
    (∫ s, if sourceBad (b θ) s then 0 else
      (∫ z, ∑ i, (φ (P.idealObservable ((θ,s),z.1) i)-φ (P.finiteObservable ((θ,s),z.2) i))^2
        ∂P.fullCoupling (θ,s))
      ∂sourceIndicesKernel hN hq m (fun j k => sourceRows (b θ) j k)) ≤
        (2*(∑ i, ‖H θ i‖^2)+16*(D:ℝ)*((q:ℝ)+1))/(m:ℝ) := by
  dsimp only
  let data := sampledBankData (m:=m) b hb H hH h hh
  let P := data.sharpParameters t BH
  let HC : Fin D → Fin q → ℝ := fun i k => wholeClip BH (H θ i) k
  have he := whitened_layer_error_of_pointwise hN hq hm (b θ) HC (h θ) hbound ht ht1
    (fun s => ∫ z, ∑ i, (φ (P.idealObservable ((θ,s),z.1) i)-
      φ (P.finiteObservable ((θ,s),z.2) i))^2 ∂P.fullCoupling (θ,s)) (fun s => by
      exact fullCoupling_activation_error_sharp P (data.sharpParameters_contractive t BH) (θ,s) φ hφ)
  refine he.trans ?_
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg m)
  apply add_le_add _ le_rfl
  apply mul_le_mul_of_nonneg_left _ (by norm_num)
  apply Finset.sum_le_sum
  intro i _
  change (∑ k, (wholeClip BH (H θ i) k)^2) ≤ ‖H θ i‖^2
  rw [← EuclideanSpace.real_norm_sq_eq]
  unfold wholeClip
  split_ifs <;> simp [sq_nonneg]

theorem sampledBankData_parameter_error (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : A → Fin q → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (H : A → Fin D → EuclideanSpace ℝ (Fin q)) (hH : Measurable H)
    (h : A → Fin N → ℝ) (hh : Measurable h) (θ : A) (hbound : ∀ j, (h θ j)^2 ≤ 1)
    {t BH : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hBH : 0 ≤ BH) :
    let P := (sampledBankData (m:=m) b hb H hH h hh).sharpParameters t BH
    (∫ s, if sourceBad (b θ) s then 0 else
      (∑ i, ((P.idealMean (θ,s) i-P.finiteMean (θ,s) i)^2+
        (Real.sqrt (P.idealVariance (θ,s) i:ℝ)-Real.sqrt (P.finiteVariance (θ,s) i:ℝ))^2))
      ∂sourceIndicesKernel hN hq m (fun j k => sourceRows (b θ) j k)) ≤
        (2*(∑ i, ‖H θ i‖^2)+16*(D:ℝ)*((q:ℝ)+1))/(m:ℝ) := by
  dsimp only
  let data := sampledBankData (m:=m) b hb H hH h hh
  let P := data.sharpParameters t BH
  let HC : Fin D → Fin q → ℝ := fun i k => wholeClip BH (H θ i) k
  have he := whitened_layer_error_of_pointwise hN hq hm (b θ) HC (h θ) hbound ht ht1
    (fun s => ∑ i, ((P.idealMean (θ,s) i-P.finiteMean (θ,s) i)^2+
      (Real.sqrt (P.idealVariance (θ,s) i:ℝ)-Real.sqrt (P.finiteVariance (θ,s) i:ℝ))^2)) (fun _ => le_rfl)
  refine he.trans ?_
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg m)
  apply add_le_add _ le_rfl
  apply mul_le_mul_of_nonneg_left _ (by norm_num)
  apply Finset.sum_le_sum
  intro i _
  change (∑ k, (wholeClip BH (H θ i) k)^2) ≤ ‖H θ i‖^2
  rw [← EuclideanSpace.real_norm_sq_eq]
  unfold wholeClip
  split_ifs <;> simp [sq_nonneg]

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
