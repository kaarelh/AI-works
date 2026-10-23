import NeuralGeneralization.BatchTwoContinuousFiniteQueryModel
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldHiddenTail
import NeuralGeneralization.MeanFieldHiddenTail

/-! Recursive whole-network covariance-certificate tails for the actual
non-Gaussian product coordinates. Each conditional incoming matrix is fixed
only after preceding coordinates are integrated. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open BatchTwoNonGaussian ConcreteModel NetworkLayerSplit ProductFiberBound LayerGramConcentration
open GaussianTowerConstruction

theorem inputBad_tail (ν : CoordinateLaw) {d q N s : ℕ} (xs : Cube q → RealInput d)
    (hq : 0 < q) (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (rawPrior ν d N 0).real (inputBad ν xs G K) ≤
      Real.exp (4*(q : ℝ)*(s : ℝ)-(N : ℝ)*(K-G^2/(2*(s : ℝ)))) := by
  have hp := MeasurePreserving.symm (NetworkInputSplit.split d N) (rawPrior_input_split ν d N)
  have hset : (NetworkInputSplit.split d N).symm ⁻¹' inputBad ν xs G K=
      NonGaussianMeanField.badMatrix ν (inputMatrix xs) N G K ×ˢ Set.univ := by
    ext p
    rcases p with ⟨a,b⟩
    simp only [Set.mem_preimage,Set.mem_prod,Set.mem_univ,and_true]
    rfl
  rw [←hp.map_eq,Measure.real,Measure.map_apply hp.measurable (isOpen_inputBad ν xs G K).measurableSet,
    hset,Measure.prod_prod,measure_univ,mul_one]
  exact NonGaussianMeanField.badMatrix_tail ν hq (inputMatrix xs) hN hs hG K

theorem lastBad_tail (ν : CoordinateLaw) {d q N r s : ℕ} (xs : Cube q → RealInput d)
    (hq : 0 < q) (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (rawPrior ν d N (r+1)).real (lastBad ν xs G K) ≤
      Real.exp (4*(q : ℝ)*(s : ℝ)-(N : ℝ)*(K-G^2/(2*(s : ℝ)))) := by
  have hp := MeasurePreserving.symm (NetworkLayerSplit.split d N r) (rawPrior_layer_split ν d N r)
  rw [←hp.map_eq,Measure.real,Measure.map_apply hp.measurable (isOpen_lastBad ν xs G K).measurableSet]
  apply real_prod_le (rawPrior ν d N r) (Measure.pi fun _ : Fin N × Fin N => ν.law)
    ((NetworkLayerSplit.split d N r).symm ⁻¹' lastBad ν xs G K)
    ((isOpen_lastBad ν xs G K).measurableSet.preimage hp.measurable) (Real.exp_pos _).le
  intro z
  have hset : Prod.mk z ⁻¹' ((NetworkLayerSplit.split d N r).symm ⁻¹' lastBad ν xs G K)=
      NonGaussianMeanField.badMatrix ν (activationMatrix xs (NonGaussianMeanField.weights z)) N G K := by
    ext a
    simp only [Set.mem_preimage,lastBad,Set.mem_setOf_eq,split_symm_apply,
      previousWeights_appendLayer,NonGaussianMeanField.badMatrix]
    change (fun i j => lastMatrix (TowerNetwork.appendLayer z (fun i j => a (i,j))) (i,j)) ∈ _ ↔ _
    rw [lastMatrix_appendLayer]
  rw [hset]
  exact NonGaussianMeanField.badMatrix_tail ν hq (activationMatrix xs (NonGaussianMeanField.weights z)) hN hs hG K

theorem goodHidden_compl_tail (ν : CoordinateLaw) {d q N r s : ℕ} (xs : Cube q → RealInput d)
    (hq : 0 < q) (hN : 0 < N) (hs : 0 < s)
    (G : ℕ → ℝ) (K : ℝ) (hK : 4 ≤ K)
    (hG : ∀ j, j ≤ r → 0 < G j) (hGs : ∀ j, j ≤ r → (G j)^2 ≤ 2*(s : ℝ))
    (hthreshold : 4*(q : ℝ)*(s : ℝ) ≤ (N : ℝ)*(K-1)/2) :
    (rawPrior ν d N r).real {z | ¬GoodHidden ν xs N r G K z} ≤
      (r+1 : ℝ)*Real.exp (-(N : ℝ)*K/8) := by
  induction r with
  | zero =>
    have ht := (inputBad_tail ν xs hq hN hs (hG 0 (by omega)) K).trans
      (Real.exp_le_exp.mpr (MeanFieldHiddenTail.entropy_exponent_le hs hK (hGs 0 (by omega)) hthreshold))
    simpa only [GoodHidden,not_not,Nat.cast_zero,zero_add,one_mul,Set.setOf_mem_eq] using ht
  | succ r ih =>
    have hprev := ih (fun j hj => hG j (by omega)) (fun j hj => hGs j (by omega))
    have hp : MeasurePreserving (@previousWeights d N r) (rawPrior ν d N (r+1)) (rawPrior ν d N r) :=
      measurePreserving_fst.comp (rawPrior_layer_split ν d N r)
    have hprevmeas : MeasurableSet {z : Weights d N r | ¬GoodHidden ν xs N r G K z} :=
      (isClosed_GoodHidden ν xs N r G K).measurableSet.compl
    have heq : (rawPrior ν d N (r+1)).real {z | ¬GoodHidden ν xs N r G K (previousWeights z)}=
        (rawPrior ν d N r).real {z | ¬GoodHidden ν xs N r G K z} := by
      rw [←hp.map_eq]
      simp only [Measure.real]
      rw [Measure.map_apply hp.measurable hprevmeas]
      rfl
    have hlast := (lastBad_tail ν xs (r := r) hq hN hs (hG (r+1) le_rfl) K).trans
      (Real.exp_le_exp.mpr (MeanFieldHiddenTail.entropy_exponent_le hs hK (hGs (r+1) le_rfl) hthreshold))
    have hset : {z | ¬GoodHidden ν xs N (r+1) G K z}=
        {z | ¬GoodHidden ν xs N r G K (previousWeights z)} ∪ lastBad ν xs (G (r+1)) K := by
      ext z
      simp only [Set.mem_setOf_eq,GoodHidden,Set.mem_union]
      tauto
    rw [hset]
    calc
      _ ≤ (rawPrior ν d N (r+1)).real {z | ¬GoodHidden ν xs N r G K (previousWeights z)}+
          (rawPrior ν d N (r+1)).real (lastBad ν xs (G (r+1)) K) := measureReal_union_le _ _
      _ ≤ (r+1 : ℝ)*Real.exp (-(N : ℝ)*K/8)+Real.exp (-(N : ℝ)*K/8) := by
        rw [heq]
        exact add_le_add hprev hlast
      _ = _ := by push_cast; ring

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
