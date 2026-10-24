import NeuralGeneralization.BatchTwoImprovedLargeWidth
import NeuralGeneralization.RobustCouplingAllWidths

/-! A common finite class for the sharp original-support compressor, uniformly
in every positive width and every mean-field-or-stronger scale. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustStatistics
open BatchTwoImprovedResources
set_option maxHeartbeats 500000
set_option maxRecDepth 4000

theorem all_width_score_compression (p : RobustCompressionInput) {N : ℕ}
    (hd : 0<p.dimension) (hK : 1≤p.energy) (hR : 6≤p.inverseRadius) (hN : 0<N)
    {t c : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2))
    (hrob : ∀ᵐ w ∂Q,w∈robustEvent Real.tanh c)
    (hrad : ∀ᵐ w ∂Q,1/((p.inverseRadius:ℝ)+1)≤robustRadius c w) :
    ∃ Γ : Measure (RobustOutputCode p.dimension (widthBound p) (p.depth-2)
      (weightBound p) (8*(p.inverseRadius+1))), IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube p.dimension, ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (scoreFailure (fun w => networkOutput Real.tanh w x)
            (fun q => robustGridOutput p.dimension (widthBound p) (p.depth-2)
              (weightBound p) (8*(p.inverseRadius+1)) Real.tanh q x))≤
          1/((p.inverseFailure:ℝ)+1) := by
  have hnR : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hσ : 0<t/Real.sqrt (N:ℝ) := by positivity
  have ht2 : t^2≤1 := by nlinarith
  have hscale : t^2=(N:ℝ)*(t/Real.sqrt (N:ℝ))^2 := by
    rw [div_pow,Real.sq_sqrt hnR.le]
    field_simp
  have hKL : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal (N*(p.energy:ℝ)/t^2) := by
    have he : (p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2=N*p.energy/t^2 := by
      rw [div_pow,Real.sq_sqrt hnR.le]
      field_simp
    rwa [he] at hQ
  by_cases hsmall : N≤widthBound p
  · let Γ := Q.map (padAndRoundCode (d:=p.dimension) (r:=p.depth-2) hsmall
      (weightBound p) (8*(p.inverseRadius+1)))
    letI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hsmall (weightBound p) (8*(p.inverseRadius+1))).aemeasurable
    refine ⟨Γ,inferInstance,fun _=>smallWidthGridCoupling Q hsmall (weightBound p)
      (8*(p.inverseRadius+1)),?_⟩
    intro x
    apply smallWidthGridCoupling_score_failure_le Q hsmall Real.tanh x
    · have hden : (12:ℝ)≤(8*(p.inverseRadius+1):ℕ) := by exact_mod_cast (show 12≤8*(p.inverseRadius+1) by omega)
      exact one_div_le_one_div_of_le (by norm_num) hden
    · exact smallWidthGridCoupling_of_kl hd hN hsmall (Nat.cast_nonneg _) ht ht2 hscale
        Q hKL Real.tanh tanh_admissible (weightBound_pos p) (by omega) (small_weight_allocation p)
  · obtain ⟨Γ,hΓ,hraw⟩ := sharp_large_width_raw p hd (Nat.sub_le p.depth 2) hK
      (Nat.le_of_lt (Nat.lt_of_not_ge hsmall)) ht ht1 Q hQ
    letI : IsProbabilityMeasure Γ := hΓ
    have hmM := width_ge_bankSize p
    let Γgrid := Γ.map (padAndRoundCode (d:=p.dimension) (r:=p.depth-2) hmM
      (weightBound p) (8*(p.inverseRadius+1)))
    letI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hmM (weightBound p) (8*(p.inverseRadius+1))).aemeasurable
    refine ⟨Γgrid,inferInstance,?_⟩
    apply hraw.finite_grid hmM Real.tanh tanh_admissible (by positivity)
      (one_div_le_one_div_of_le (by norm_num : (0:ℝ)<6)
        (by exact_mod_cast (show 6≤p.inverseRadius+1 by omega)))
      (weightBound_pos p) (by omega) ?_ hrob hrad
    simp only [Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one]
    exact le_of_eq (by field_simp)
end NeuralGeneralization.BatchTwoImprovedInduction
