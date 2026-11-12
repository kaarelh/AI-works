import NeuralGeneralization.BatchTwoOnlineReluTeacherCapacity
import NeuralGeneralization.BatchTwoOnlineMain

/-! The exact product-norm strong-prior ReLU cumulative theorem, for actual
uniform permutations and infinite uniform IID inputs, including sampled counts. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal Topology
open MeasureTheory MeasureTheory.Measure Filter
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel BatchTwoOnline

def reluTeacherLogCount (d r : ℕ) (P : ℝ) : ℝ :=
  (reluTeacherCapacity d r P:ℝ)*Real.log ((2:ℝ)^d+1)

theorem reluTeacherLogCount_nonneg (d r : ℕ) (P : ℝ) : 0≤reluTeacherLogCount d r P := by
  unfold reluTeacherLogCount
  exact mul_nonneg (Nat.cast_nonneg _) (Real.log_nonneg (by have h := pow_nonneg (by norm_num : (0:ℝ)≤2) d; linarith))

theorem small_relu_teacher_mass_pos {d C N r : ℕ} (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (w : Weights d C r) (f : BooleanFunction d) (hw : w∈marginEvent relu (1/2) f)
    {σ : ℝ} (hσ : 0<σ) : 0<functionMass relu (1/2) (smallPrior d N r σ) f := by
  letI : IsOpenPosMeasure (smallPrior d N r σ) :=
    productGaussian_openPos d N r _ (smallVariance_pos hd (hC.trans_le hCN) hσ)
  exact functionMass_pos_of_mem (show Continuous relu from continuous_const.max continuous_id) (1/2) _ f (widthPaddedWeights hCN w)
    (fun x=>by rw [networkOutput_widthPaddedWeights]; exact hw x)

/-- The capacity is exactly ceil(4 e (d+1) P_*^2 a_H^2) log(2^d+1).
No bounded-weight premise is needed for a concrete margin teacher. -/
theorem relu_strong_prior_online_product {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) :
    ∃σ₀ : ℝ,0<σ₀ ∧ ∀σ : ℝ,0<σ→σ<σ₀→
      NetworkOnlineBounds relu (1/2) (smallPrior d N r σ) f
        (reluTeacherLogCount d r (physicalProduct hC relu_zeroLipschitz w)) := by
  have hN : 0<N := hC.trans_le hCN
  have hne : (marginEvent (N:=N) (r:=r) relu (1/2) f).Nonempty :=
    ⟨widthPaddedWeights hCN w,fun x=>by rw [networkOutput_widthPaddedWeights]; exact hw x⟩
  have hlim := network_highEnergy_tail_ratio_tendsto_zero hd hN (show Continuous relu from continuous_const.max continuous_id) f hne
  let β : ℝ := 1/Fintype.card (Cube d)
  have hβ : 0<β := by dsimp [β]; positivity
  have he := hlim.eventually (gt_mem_nhds hβ)
  obtain ⟨σ₀,hσ₀,hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt
  have htail := hsub ⟨hσ,hσlt⟩
  have hmass := small_relu_teacher_mass_pos hd hC hCN w f hw hσ
  apply network_online_of_randomOrder (by omega) relu (1/2) _ f _
    (reluTeacherLogCount_nonneg _ _ _) hmass
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg relu (1/2) _) _ f
    (fun _=>rfl) hmass (lowEnergyFunctions (N:=N) (r:=r) relu f) _ β
    (reluTeacherLogCount_nonneg _ _ _) hβ.le
    (lowEnergyFunctions_relu_teacher_card hd hC hCN w f hw) htail.le

#print axioms relu_strong_prior_online_product
end NeuralGeneralization.BatchTwoActivation
