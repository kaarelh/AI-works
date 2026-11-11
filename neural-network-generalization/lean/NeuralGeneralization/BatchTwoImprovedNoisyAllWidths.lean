import NeuralGeneralization.BatchTwoImprovedNoisyGrid

/-! A finite noisy-output class at every width, for every bounded 1-Lipschitz
activation, without any support or stability assumption. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 600000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel

/-- The small-width branch uses zero disturbance and ordinary output rounding. -/
theorem small_width_noisy_grid {d N M r B R : ℕ}
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hNM : N ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    {radius failure : ℝ} (hrad : 0 < radius) (hB : 0 < B) (hR : 0 < R)
    (htail : Q.real {w | ¬ boundedWeights B w} ≤ failure) :
    ∀ x : Cube d, ∃ π : NoisyGridCoupling Q (Q.map (padAndRoundCode hNM B R)),
      π.joint.real (noisyGridFailure φ (robustGridOutput d M r B R φ) x
        radius (1/(R:ℝ))) ≤ failure := by
  intro x
  let q := padAndRoundCode (d := d) (r := r) hNM B R
  have hq : Measurable q := measurable_padAndRoundCode hNM B R
  let π := NoisyGridCoupling.ofFields Q (Q.map q) Q id q (fun _ => 0)
    measurable_id hq measurable_const Measure.map_id rfl
  refine ⟨π, ?_⟩
  have hset := measurable_noisyGridFailure (N := N) (r := r) φ
    (admissibleActivation_continuous hφ) (robustGridOutput d M r B R φ)
    (fun _ => measurable_of_countable _) x radius (1/(R:ℝ))
  change (Q.map (fun w => (w, q w, (0 : NetworkDisturbance N r)))).real _ ≤ failure
  have hm : Measurable (fun w : Weights d N r => (w, q w, (0 : NetworkDisturbance N r))) :=
    measurable_id.prodMk (hq.prodMk measurable_const)
  rw [Measure.real, Measure.map_apply hm hset]
  refine (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono ?_)).trans htail
  intro w hbad hb
  change radius^2 ≤ noiseBudgetSq (0 : NetworkDisturbance N r) ∨
    1/(R:ℝ) < |robustGridOutput d M r B R φ (q w) x - noisyNetworkOutput φ w x 0| at hbad
  rw [noiseBudgetSq_zero, noisyNetworkOutput_zero] at hbad
  rcases hbad with hn | ho
  · exact not_le_of_gt (sq_pos_of_pos hrad) hn
  · have hh := padAndRoundCode_output_close hNM φ hφ hB hR w hb x
    rw [abs_sub_comm] at hh
    exact not_lt_of_ge hh ho

end NeuralGeneralization.ConcreteModel
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel BatchTwoImprovedResources

/-- This is the appendix's actual pre-stability coupling, uniformly over all
positive widths and all mean-field-or-stronger scales. Radius is expressed as
an inverse integer resource, and the failure probability as another. -/
theorem all_width_noisy_compression (p : RobustCompressionInput) {N : ℕ}
    (hd : 0 < p.dimension) (hK : 1 ≤ p.energy) (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1)
    (Q : Measure (Weights p.dimension N (p.depth - 2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth - 2) (t/Real.sqrt (N:ℝ))) ≤
      ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2)) :
    ∃ Γ : Measure (RobustOutputCode p.dimension (widthBound p) (p.depth - 2)
      (weightBound p) (8*(p.inverseRadius+1))), IsProbabilityMeasure Γ ∧
      ∀ x : Cube p.dimension, ∃ π : NoisyGridCoupling Q Γ,
        π.joint.real (noisyGridFailure φ
          (robustGridOutput p.dimension (widthBound p) (p.depth - 2)
            (weightBound p) (8*(p.inverseRadius+1)) φ) x
          (1/((p.inverseRadius:ℝ)+1)) (1/(8*((p.inverseRadius:ℝ)+1)))) ≤
          1/((p.inverseFailure:ℝ)+1) := by
  have hrad : 0 < 1/((p.inverseRadius:ℝ)+1) := by positivity
  by_cases hsmall : N ≤ widthBound p
  · let Γ := Q.map (padAndRoundCode (d := p.dimension) (r := p.depth - 2) hsmall
      (weightBound p) (8*(p.inverseRadius+1)))
    haveI : IsProbabilityMeasure Γ := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode hsmall (weightBound p) (8*(p.inverseRadius+1))).aemeasurable
    refine ⟨Γ, inferInstance, ?_⟩
    have ht2 : t^2 ≤ 1 := by nlinarith
    have hscale : t^2 = (N:ℝ)*(t/Real.sqrt (N:ℝ))^2 := by
      rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
      field_simp
    have hKL : klDiv Q (smallPrior p.dimension N (p.depth - 2) (t/Real.sqrt (N:ℝ))) ≤
        ENNReal.ofReal (N*(p.energy:ℝ)/t^2) := by
      convert hQ using 1
      congr 1
      rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
      field_simp
    obtain ⟨hi, hm⟩ := smallPrior_entropy_physical_moment hd hN (Nat.cast_nonneg p.energy)
      ht ht2 hscale Q hKL
    have henergy : 4*(N:ℝ)*p.energy + 2*robustParameterCount p.dimension N (p.depth-2) ≤
        4*(widthBound p:ℝ)*p.energy + 2*robustParameterCount p.dimension (widthBound p) (p.depth-2) := by
      have hcount := robustParameterCount_mono_width (d := p.dimension) (r := p.depth-2) hsmall
      have hN' : (N:ℝ) ≤ widthBound p := by exact_mod_cast hsmall
      have hc : (robustParameterCount p.dimension N (p.depth-2):ℝ) ≤
        robustParameterCount p.dimension (widthBound p) (p.depth-2) := by exact_mod_cast hcount
      nlinarith [Nat.cast_nonneg p.energy (α := ℝ)]
    have htail := physical_moment_boundedWeights_tail Q hi
      (Nat.cast_pos.mpr (weightBound_pos p)) (hm.trans (henergy.trans (small_weight_allocation p)))
    simpa only [Nat.cast_mul, Nat.cast_add, Nat.cast_ofNat, Nat.cast_one] using
      small_width_noisy_grid Q hsmall φ hφ hrad (weightBound_pos p) (by omega : 0 < 8*(p.inverseRadius+1)) htail
  · have hφl : LipschitzWith 1 φ := LipschitzWith.mk_one (fun x y => by
      simpa only [Real.dist_eq] using hφ.2 x y)
    obtain ⟨Γ, hΓ, hraw⟩ := sharp_large_width_raw_activation hφl hφ.1 p hd
      (Nat.sub_le p.depth 2) hK (Nat.le_of_lt (Nat.lt_of_not_ge hsmall)) ht ht1 Q hQ
    letI : IsProbabilityMeasure Γ := hΓ
    let Γgrid := Γ.map (padAndRoundCode (d := p.dimension) (r := p.depth-2)
      (width_ge_bankSize p) (weightBound p) (8*(p.inverseRadius+1)))
    haveI : IsProbabilityMeasure Γgrid := Measure.isProbabilityMeasure_map
      (measurable_padAndRoundCode (width_ge_bankSize p) (weightBound p) (8*(p.inverseRadius+1))).aemeasurable
    refine ⟨Γgrid, inferInstance, ?_⟩
    simpa only [Nat.cast_mul, Nat.cast_add, Nat.cast_ofNat, Nat.cast_one] using
      hraw.noisy_grid (width_ge_bankSize p) φ hφ hrad (weightBound_pos p)
        (by omega : 0 < 8*(p.inverseRadius+1))

end NeuralGeneralization.BatchTwoImprovedInduction
