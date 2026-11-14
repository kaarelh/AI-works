import NeuralGeneralization.OnlineLowerReluCoverageRepresentation
import NeuralGeneralization.OnlineLowerReluMain

/-! Actual variation infima, rather than chosen representation costs, obey
the closed calibrated constraints and the unique cheapest-star classification. -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerRelu
open ConcreteModel OnlineLower OnlineLowerGeometry

/-- A closed constraint on a capped representation cost persists at the
actual variation infimum. No attainment of the infimum is assumed. -/
theorem variation_mem_closed_capped {d : ℕ} (F : Cube d → ℝ)
    (S : Set (ℝ × (Cube d → ℝ))) (hS : IsClosed S) (cap : ℝ)
    (hne : (reluVariationCosts F).Nonempty) (hcap : reluVariation F < cap)
    (hcost : ∀ B ∈ reluVariationCosts F,B < cap → (B,F) ∈ S) :
    (reluVariation F,F) ∈ S := by
  let T : Set ℝ := (fun B:ℝ=>(B,F)) ⁻¹' S ∪ Set.Ici cap
  have hT : IsClosed T :=
    (hS.preimage (continuous_id.prodMk continuous_const)).union isClosed_Ici
  have hsub : reluVariationCosts F ⊆ T := by
    intro B hB
    by_cases hb : B < cap
    · exact Or.inl (hcost B hB hb)
    · exact Or.inr (le_of_not_gt hb)
  have hbdd : BddBelow (reluVariationCosts F) := by
    refine ⟨0,?_⟩
    rintro B ⟨q,a,c,_,rfl⟩
    exact finiteVariationCost_nonneg a c
  have hmem := closure_mono hsub (csInf_mem_closure hne hbdd)
  rw [hT.closure_eq] at hmem
  rcases hmem with hs | hc
  · exact hs
  · exact (not_le_of_gt hcap hc).elim

namespace Family
open OnlineLowerRelu.Family

/-- Exact finite representations satisfy the literal family Fourier and
residual estimates with their own variation cost. -/
theorem finite_representation_bounds (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    {q : ℕ} (a : Fin q → Fin (railDimension (size R k)+1) → ℝ) (c : Fin q → ℝ) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (atomicScore (fun t=>max t 0) a c) ≤ finiteVariationCost a c ∧
    uniformCubeMean (fun x=>(atomicScore (fun t=>max t 0) a c x-
      fourierProject (railDownwardSupports (size R k) (column k))
        (atomicScore (fun t=>max t 0) a c) x)^2) ≤
      stabilityBudget R k*finiteVariationCost a c*(finiteVariationCost a c-
        retainedFourierMass (targetSupport R k) (weight R k)
          (atomicScore (fun t=>max t 0) a c)) := by
  apply network_fourier_deficit (targetSupport R k) (weight R k)
    (fun s=>(weight_pos R k (by omega) heven s).le)
    (railDownwardSupports (size R k) (column k)) c
    (fun j=>Real.sqrt (∑i,a j i^2)) (fun j=>atomOutput (fun t=>max t 0) (a j))
    (stabilityBudget R k) (finiteVariationCost a c)
    (by unfold stabilityBudget;positivity) (fun j=>Real.sqrt_nonneg _) ?_ ?_ le_rfl
  · intro j
    rw [atomOutput_eq_affine,Fin.sum_univ_succ]
    exact affine_atom_retained_norm R k hR heven (fun i=>a j i.succ) (a j 0)
  · intro j
    rw [atomOutput_eq_affine,Fin.sum_univ_succ]
    exact affine_atom_retained_stability R k hR heven (fun i=>a j i.succ) (a j 0)

/-- The actual variation infimum obeys the same closed calibrated score
constraints used by the finite-network proof. -/
theorem variation_mem_score_constraints (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    (H : CubeSubgroup (logicalDim k)) (v : ClippingCube (logicalDim k))
    (live : ClippingCube (logicalDim k) → Prop)
    (hv : v ∉ H.carrier) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hcostsign : ∀ z,z ≠ cubeOne (logicalDim k) → walshExpansion (weight R k) z ≤ 0)
    (hdetect : ∀ i,logicalColumnPoint (column k) i ∉ H.carrier)
    (F : Cube (railDimension (size R k)) → ℝ)
    (hcap : reluVariation F < normalizedCap R k)
    (hmargin : ∀ x,(1:ℝ)/2 ≤ |F x|)
    (hcal : ∀ x,cubeTranslation v ((physicalCode R k (by omega)).syndrome x) ∉ H.carrier →
      (1:ℝ)/2 ≤ (if (physicalCode R k (by omega)).syndrome x=cubeOne (logicalDim k) then 1 else -1)*
        ((physicalCode R k (by omega)).base x*F x))
    (hremoved : ∀ z,¬live z →
      reluLiveMass H v ((physicalCode R k (by omega)).logicalProjection F) z ≤ 0) :
    (reluVariation F,F) ∈ (physicalCode R k (by omega)).reluScoreConstraints
      (weight R k) H v live 1 (varianceBudget R k) := by
  let C := physicalCode R k (by omega : 0 < R)
  have hd : 0 < railDimension (size R k) := by rw [physicalDimension_eq,pairDim_eq];positivity
  apply variation_mem_closed_capped F _
    (C.isClosed_reluScoreConstraints (weight R k) H v live 1 (varianceBudget R k))
    (normalizedCap R k) (reluVariationCosts_nonempty F) hcap
  intro B hB hBcap
  obtain ⟨q,a,c,hscore,rfl⟩ := hB
  have he : atomicScore (fun t=>max t 0) a c=F := funext hscore
  obtain ⟨hcost,hdown⟩ := finite_representation_bounds R k hR heven a c
  have hm : retainedFourierMass (targetSupport R k) (weight R k) F =
      weightedWalshCost (weight R k) (C.logicalProjection F) :=
    retainedFourierMass_eq_logicalCost C (weight R k) F
  rw [he,hm] at hcost hdown
  have hscorebound : ∀ x,|F x| ≤ scoreScale R k*normalizedCap R k := by
    intro x
    have hh := atomicScore_abs_le_cost hd (fun t=>max t 0)
      (fun t=>by rw [abs_of_nonneg (le_max_right _ _)];exact max_le (le_abs_self _) (abs_nonneg _)) a c x
    rw [he,atomicWeightedCost_eq_variation] at hh
    exact hh.trans (mul_le_mul_of_nonneg_left hBcap.le (scoreScale_pos R k (by omega)).le)
  have hvar := relu_variance_budget_of_downward_deficit (size R k) (column k)
    (family_size_pos R k (by omega)) C (physicalCode_support R k (by omega))
    (weight R k) H v hv hcard (weight_pos R k (by omega) heven ∅)
    (weight_empty_le R k (by omega) heven) (six_base_le_sum_weights R k (by omega) heven)
    hcostsign hdetect F (finiteVariationCost a c) (scoreScale R k*normalizedCap R k)
    (stabilityBudget R k) (normalizedCap R k) (finiteVariationCost_nonneg a c)
    (mul_nonneg (scoreScale_pos R k (by omega)).le (normalizedCap_pos R k (by omega)).le)
    (by unfold stabilityBudget;positivity) hscorebound hcal hcost hBcap.le hdown
  refine ⟨hmargin,hcal,?_,?_,hremoved,?_⟩
  · simpa only [div_one] using hcost
  · simp only [div_one]
    apply (div_le_iff₀ (weight_pos R k (by omega) heven ∅)).mpr
    exact hBcap.le.trans (normalizedCap_le_ten_weight R k (by omega) heven)
  · simpa only [div_one,varianceBudget,scoreScale] using hvar

end Family
end NeuralGeneralization.OnlineLowerRelu

namespace NeuralGeneralization.OnlineLowerRelu.Family
open ConcreteModel OnlineLower OnlineLowerGeometry

lemma starScore_variation (R k : ℕ) (hR : 36 ≤ R) (heven : Even R) (hk : 3 ≤ k)
    (i : Fin (candidateCount k)) :
    reluVariation (starScore R k (by omega) hk false i) =
      weightedWalshCost (weight R k) (reluStar (orderedCandidate R k (by omega) hk false i)) := by
  let C := physicalCode R k (by omega : 0 < R)
  let g := reluStar (orderedCandidate R k (by omega) hk false i)
  have he : (fun x=>∑s,walshCoefficients g s*walshCharacter (targetSupport R k s) x)=
      starScore R k (by omega) hk false i := by
    funext x
    exact code_fourier_lift C g x
  rw [←he,retained_variation_eq R k hR heven]
  rfl

/-- Literal closed-margin feasibility of a real score after the observed signs. -/
def FeasibleScore {d n : ℕ} (f : BooleanFunction d) (sample : Fin n → Cube d)
    (F : Cube d → ℝ) : Prop :=
  (∀ x,(1:ℝ)/2 ≤ |F x|) ∧ ∀ a,(1:ℝ)/2 ≤ labelReal (f (sample a))*F (sample a)

/-- At every stage in the fixed physical permutation, the actual variation
infimum has the unique cheapest live star as its minimizing score. The
quantification is over every real-valued cube function, not just a Fourier
subspace or a chosen finite neural representation. -/
theorem concrete_variation_minimizers (R k : ℕ) (hR : 36 ≤ R) (heven : Even R) (hk : 3 ≤ k)
    (hsmall : tailBudget R k *
      (45*((Fintype.card (ClippingCube (logicalDim k)):ℝ)/(2*weight R k ∅))+
        6*((Fintype.card (ClippingCube (logicalDim k)):ℝ)*varianceBudget R k)) < 1) :
    ∃ π : InputOrder (railDimension (size R k)),
      ∀ i : Fin (candidateCount k),
        HistoryAt R k (by omega) hk false π i ∧
        FeasibleScore (target R k) (observedPrefix π (π.symm (firstInput R k (by omega) hk false i)))
          (starScore R k (by omega) hk false i) ∧
        ∀ F : Cube (railDimension (size R k)) → ℝ,
          FeasibleScore (target R k) (observedPrefix π (π.symm (firstInput R k (by omega) hk false i))) F →
          reluVariation (starScore R k (by omega) hk false i) ≤ reluVariation F ∧
          (reluVariation F ≤ reluVariation (starScore R k (by omega) hk false i) →
            F=starScore R k (by omega) hk false i) := by
  have hR2 : 2 ≤ R := by omega
  have hR0 : 0 < R := by omega
  let C := physicalCode R k hR0
  let H := calibrationSubgroup k
  let v := referencePoint k false
  have hv : v ∉ H.carrier := referencePoint_not_subgroup k false
  have hcard : 2 ≤ (H.differenceAnnihilator v).card := concrete_differenceAnnihilator_card k false
  have hM : 4 ≤ Fintype.card (ClippingCube (logicalDim k)) := by
    simp only [ClippingCube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin]
    exact (by norm_num : 4 ≤ 2^2).trans
      (Nat.pow_le_pow_right (by norm_num) (by rw [logicalDim_eq];omega))
  have hMr : (0:ℝ) < Fintype.card (ClippingCube (logicalDim k)) := Nat.cast_pos.mpr Fintype.card_pos
  have hcostsign : ∀ z,z ≠ cubeOne (logicalDim k) → walshExpansion (weight R k) z ≤ 0 := by
    intro z hz
    have h := (div_lt_iff₀ hMr).mp (weightExpansion_nonconstant_neg R k hR2 z hz)
    simpa using h.le
  have hdetect : ∀ i,logicalColumnPoint (column k) i ∉ H.carrier :=
    fun i=>parityKernel_detected (calibrationConstraints (fixedCoordinates k))
      (logicalColumnPoint (column k) i)
      (calibrationConstraints_detect_columns (column k) (fixedCoordinates k)
        (concrete_column_detection_condition k) i)
  obtain ⟨π,J,hJ,hcount,hprotocol⟩ := exists_concrete_family_protocol R k hR2 hk false
  refine ⟨π,?_⟩
  intro i
  obtain ⟨_,hhistory,hfits,_⟩ := hprotocol i
  let zstar := orderedCandidate R k hR2 hk false i
  let live := liveAt R k hR2 hk false i
  have hz : cubeTranslation v zstar ∈ H.carrier := orderedCandidate_mem R k hR2 hk false i
  have hnegative : reluLiveCost (weight R k) H v zstar < 0 := by
    rw [reluLiveCost,if_pos hz]
    exact calibration_weightExpansion_neg R k hR2 false zstar hz
  have hstrict : ∀ z,live z → zstar ≠ z →
      reluLiveCost (weight R k) H v zstar < reluLiveCost (weight R k) H v z := by
    intro z hl hne
    have hzc : cubeTranslation v z ∈ H.carrier := liveAt_mem R k hR2 hk false i z hl
    rw [reluLiveCost,if_pos hz,reluLiveCost,if_pos hzc]
    exact liveAt_strict_weightExpansion R k hR2 hk false i z hl hne
  have hstarEq : reluVariation (starScore R k hR2 hk false i)=
      reluCalibrationConstant (weight R k) H v+reluLiveCost (weight R k) H v zstar := by
    rw [starScore_variation R k hR heven hk i,reluStar_exact_cost (weight R k) H v zstar hv hz (by omega) hM]
    simp only [reluLiveCost,if_pos hz]
  have hstarcap : reluVariation (starScore R k hR2 hk false i) < normalizedCap R k := by
    rw [starScore_variation R k hR heven hk i]
    exact star_cost_lt_ten_base R k (by omega) heven H v zstar hv hz (by omega)
      (hcostsign zstar (orderedCandidate_ne_anchor R k hR2 hk false i))
  refine ⟨hhistory,?_,?_⟩
  · constructor
    · intro x
      have hh := starScore_half_margin R k hR2 hk false i x
      have ha := congrArg abs hh
      rw [abs_mul,abs_labelReal,one_mul] at ha
      norm_num at ha
      linarith
    · intro a
      have hf := ((hfits i).mpr le_rfl) a
      rw [←hf]
      exact (starScore_half_margin R k hR2 hk false i _).ge
  · intro F hF
    by_cases hupper : reluVariation F ≤ reluVariation (starScore R k hR2 hk false i)
    · have hconstraint := variation_mem_score_constraints R k hR heven H v live hv hcard
        hcostsign hdetect F (hupper.trans_lt hstarcap) hF.1
        (history_calibration_margins R k hR2 hk false π i hhistory F hF.2)
        (history_removed_live_mass R k hR2 hk false π i hhistory F hF.2)
      obtain ⟨hlower,hequal⟩ := C.reluScoreConstraints_minimum (weight R k) H v zstar live
        1 (varianceBudget R k) (tailBudget R k) (by norm_num) hv
        (weight_pos R k hR2 heven ∅) (weight_empty_le R k hR2 heven) hcard
        (six_base_le_sum_weights R k hR2 heven) hcostsign (liveAt_self R k hR2 hk false i) hz
        (tailBudget_nonneg R k hR2) (masked_live_cost_bound R k hR2 false)
        hnegative hstrict hsmall (reluVariation F,F) hconstraint
      simp only [one_mul] at hlower hequal
      rw [←hstarEq] at hlower hequal
      exact ⟨hlower,fun _=>hequal (le_antisymm hupper hlower)⟩
    · exact ⟨(lt_of_not_ge hupper).le,fun hh=>(hupper hh).elim⟩

end NeuralGeneralization.OnlineLowerRelu.Family
