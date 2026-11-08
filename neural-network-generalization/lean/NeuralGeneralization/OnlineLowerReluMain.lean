import NeuralGeneralization.OnlineLowerFamilyNetwork
import NeuralGeneralization.OnlineLowerGeometryFamilyOrder
import NeuralGeneralization.OnlineLowerReluConstraintBridge
import NeuralGeneralization.OnlineLowerReluFinalBridge
import NeuralGeneralization.OnlineLowerExplicitThreshold

/-!
# The complete actual-model ReLU online lower bound

All scalar, Fourier, geometric, finite-width and Gaussian hypotheses are
instantiated here for the literal prefix/path family. The input permutation
is fixed before choosing learner width, and the Gaussian scale tends to zero
only after fixing that width.
-/

noncomputable section
open scoped BigOperators Topology Classical
open Filter

namespace NeuralGeneralization.OnlineLowerRelu.Family
open ConcreteModel OnlineLowerGeometry OnlineLower

/-- Every designated round of the explicit cost-sorted protocol has an
actual Gaussian-energy gap at every width above its finite orbit count. -/
theorem concrete_stage_gaps (R k : ℕ) (hR : 36 ≤ R) (heven : Even R) (hk : 3 ≤ k)
    (hsmall : tailBudget R k *
      (45 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) / (2 * weight R k ∅)) +
        6 * ((Fintype.card (ClippingCube (logicalDim k)) : ℝ) * varianceBudget R k)) < 1) :
    ∃ π : InputOrder (railDimension (size R k)),
    ∃ J : Finset (Fin (Fintype.card (Cube (railDimension (size R k))))),
      J.card = 2 ^ (k - 1) ∧
      ∀ N : ℕ, 0 < N → 2 ^ logicalDim k * Fintype.card (Cube (railDimension (size R k))) ≤ N →
        ∀ j ∈ J, HasStageEnergyGap (fun t => max 0 t) (target R k) π N j := by
  have hR2 : 2 ≤ R := by omega
  have hR0 : 0 < R := by omega
  have hd : 0 < railDimension (size R k) := by
    rw [physicalDimension_eq, pairDim_eq]
    positivity
  let C := physicalCode R k hR0
  let H := calibrationSubgroup k
  let v := referencePoint k false
  have hv : v ∉ H.carrier := referencePoint_not_subgroup k false
  have hcard : 2 ≤ (H.differenceAnnihilator v).card := concrete_differenceAnnihilator_card k false
  have hM : 4 ≤ Fintype.card (ClippingCube (logicalDim k)) := by
    simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
    exact (by norm_num : 4 ≤ 2 ^ 2).trans
      (Nat.pow_le_pow_right (by norm_num) (by rw [logicalDim_eq]; omega))
  have hMr : (0 : ℝ) < Fintype.card (ClippingCube (logicalDim k)) :=
    Nat.cast_pos.mpr Fintype.card_pos
  have hcostsign : ∀ z, z ≠ cubeOne (logicalDim k) → walshExpansion (weight R k) z ≤ 0 := by
    intro z hz
    have h := (div_lt_iff₀ hMr).mp (weightExpansion_nonconstant_neg R k hR2 z hz)
    simpa using h.le
  have hdetect : ∀ i, logicalColumnPoint (column k) i ∉ H.carrier :=
    fun i => parityKernel_detected (calibrationConstraints (fixedCoordinates k))
      (logicalColumnPoint (column k) i)
      (calibrationConstraints_detect_columns (column k) (fixedCoordinates k)
        (concrete_column_detection_condition k) i)
  obtain ⟨π, J, hJ, hcount, hprotocol⟩ := exists_concrete_family_protocol R k hR2 hk false
  refine ⟨π, J, hcount, ?_⟩
  intro N hN hwidth j hj
  rw [hJ, designated_round_mem_iff] at hj
  obtain ⟨i, rfl⟩ := hj
  obtain ⟨_, hhistory, hfits, hwrong⟩ := hprotocol i
  let zstar := orderedCandidate R k hR2 hk false i
  let live := liveAt R k hR2 hk false i
  have hz : cubeTranslation v zstar ∈ H.carrier := orderedCandidate_mem R k hR2 hk false i
  have hnegative : reluLiveCost (weight R k) H v zstar < 0 := by
    rw [reluLiveCost, if_pos hz]
    exact calibration_weightExpansion_neg R k hR2 false zstar hz
  have hstrict : ∀ z, live z → zstar ≠ z →
      reluLiveCost (weight R k) H v zstar < reluLiveCost (weight R k) H v z := by
    intro z hl hne
    have hzc : cubeTranslation v z ∈ H.carrier := liveAt_mem R k hR2 hk false i z hl
    rw [reluLiveCost, if_pos hz, reluLiveCost, if_pos hzc]
    exact liveAt_strict_weightExpansion R k hR2 hk false i z hl hne
  have hstarcap : reluCalibrationConstant (weight R k) H v +
      reluLiveCost (weight R k) H v zstar < normalizedCap R k := by
    have h := star_cost_lt_ten_base R k (by omega) heven H v zstar hv hz (by omega)
      (hcostsign zstar (orderedCandidate_ne_anchor R k hR2 hk false i))
    rw [reluStar_exact_cost (weight R k) H v zstar hv hz (by omega) hM] at h
    simpa only [reluLiveCost, if_pos hz, normalizedCap] using h
  have hcap : (2 * Real.sqrt (railDimension (size R k) : ℝ)) *
      (reluCalibrationConstant (weight R k) H v + reluLiveCost (weight R k) H v zstar) <
        scoreScale R k * normalizedCap R k :=
    mul_lt_mul_of_pos_left hstarcap (scoreScale_pos R k hR0)
  apply relu_stage_gaps_of_calibrated_constraints hd C (weight R k) (degreeIndex R k)
    (degreeIndex_card R k hR2 heven) (weight_eq_evenReluCost R k hR2 heven)
    H v zstar live (varianceBudget R k) (tailBudget R k) (scoreScale R k * normalizedCap R k)
    hv (weight_pos R k hR2 heven ∅) (weight_empty_le R k hR2 heven) hcard hM
    (six_base_le_sum_weights R k hR2 heven) hcostsign
    (liveAt_self R k hR2 hk false i) hz (tailBudget_nonneg R k hR2)
    (masked_live_cost_bound R k hR2 false) hnegative hstrict hsmall hcap
    (target R k) π (π.symm (firstInput R k hR2 hk false i))
    (starClassifier R k hR2 hk false i) ((hfits i).mpr le_rfl)
    (fun x => (starScore_half_margin R k hR2 hk false i x).ge)
    (lt_of_eq_of_lt hwrong (by norm_num))
    ?_ N hN hwidth
  intro N' hN' net hfeasible hcapnet
  obtain ⟨hcost, hdownward⟩ := network_bounds R k hR heven N' hN' net
  apply actual_relu_mem_score_constraints (size R k) (column k)
    (family_size_pos R k hR0) hd hN' C (physicalCode_support R k hR0)
    (weight R k) H v live hv hcard (weight_pos R k hR2 heven ∅)
    (weight_empty_le R k hR2 heven) (six_base_le_sum_weights R k hR2 heven)
    hcostsign hdetect net (stabilityBudget R k) (normalizedCap R k)
    (by unfold stabilityBudget; positivity) (normalizedCap_pos R k hR0).le
    (normalizedCap_le_ten_weight R k hR2 heven) hfeasible.1
    (history_calibration_margins R k hR2 hk false π i hhistory _ hfeasible.2)
    (history_removed_live_mass R k hR2 hk false π i hhistory _ hfeasible.2)
    hcapnet hcost hdownward

end NeuralGeneralization.OnlineLowerRelu.Family

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

/-- The paper's full ReLU theorem, for the actual Gaussian prior and its
actual sign-conditioned posterior. There are no construction, atom,
geometry, energy-gap, or posterior-concentration hypotheses. -/
theorem relu_concrete_main : ReLUConcreteMainStatement := by
  have hR : 36 ≤ reluFixedRailSize := by
    exact (by norm_num : (36 : ℕ) ≤ 2 ^ 6).trans
      (Nat.pow_le_pow_right (by norm_num) (by norm_num : 6 ≤ 1024))
  have heven : Even reluFixedRailSize := by norm_num [reluFixedRailSize, Nat.even_pow]
  obtain ⟨k₁, hk₁⟩ := Filter.eventually_atTop.mp
    (Family.calibration_absorption_eventually reluFixedRailSize (by omega) heven)
  refine ⟨max k₁ 3, le_max_right _ _, ?_⟩
  intro k hk
  have hk3 : 3 ≤ k := (le_max_right _ _).trans hk
  have hsmall := hk₁ k ((le_max_left _ _).trans hk)
  obtain ⟨hteacher, hcircuit⟩ := reluConcrete_teacher_and_circuit k
  obtain ⟨π, J, hcount, hgaps⟩ :=
    Family.concrete_stage_gaps reluFixedRailSize k hR heven hk3 hsmall
  refine ⟨hteacher, hcircuit, π, J, hcount, ?_⟩
  apply fixed_threshold_limits_of_energy_gaps (reluConcreteDimension_pos k)
    (continuous_const.max continuous_id) hteacher π J
    (reluConcreteTeacher_le_threshold k) (reluConcreteThreshold_pos k)
  intro N hN j hj
  exact hgaps N ((reluConcreteThreshold_pos k).trans_le hN)
    ((reluConcrete_orbits_le_threshold k).trans hN) j hj

/-- A bounded width-C teacher can cause exponentially many mistakes in
sqrt C, at all sufficiently large learner widths, under the actual
strong-prior Gaussian posterior. -/
theorem relu_square_root_main : ReLUSquareRootStatement :=
  relu_concrete_main.squareRootStatement

/-- The same result expressed directly as an exponential lower bound in
the square root of the implementing neural teacher's width. -/
theorem relu_width_square_root_lower_bound : WidthExponentLowerBound relu (1 / 2) :=
  polynomial_quadratic_resources_imply_square_root relu 1 relu_square_root_main

end NeuralGeneralization.OnlineLower
