import NeuralGeneralization.BatchTwoNeuralConverseOperatorWitnesses
import NeuralGeneralization.BatchTwoNeuralConverseRepair

/-! Exact one-point repairs inside the separate strict spectral prior. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Filter ConcreteModel

/-- Finite networks with arbitrary positive energies can be combined at
arbitrarily close to the sum of their square-root energies, preserving strict internal operator norms. -/
theorem exists_parallel_operator_network {d n m r : ℕ} (hn : 0<n) (hm : 0<m)
    (w : Weights d n r) (v : Weights d m r)
    (hw : operatorContractive w)
    (hv : operatorContractive v)
    (hA : 0<weightedSquaredNorm w) (hB : 0<weightedSquaredNorm v)
    (ε : ℝ) (hε : 0<ε) :
    ∃ N : ℕ, 0<N ∧ ∃ u : Weights d N r,
      (∀ x, networkOutput Real.tanh u x=networkOutput Real.tanh w x+networkOutput Real.tanh v x) ∧
      weightedSquaredNorm u < (Real.sqrt (weightedSquaredNorm w)+Real.sqrt (weightedSquaredNorm v))^2+ε ∧
      operatorContractive u := by
  have hlim := parallelBound_tendsto hn hm hA hB
  obtain ⟨q,hq⟩ := (hlim.eventually (gt_mem_nhds (lt_add_of_pos_right _ hε))).exists
  let k := parallelCopies n (Real.sqrt (weightedSquaredNorm w)) q
  let l := parallelCopies m (Real.sqrt (weightedSquaredNorm v)) q
  have hk : 0<k := parallelCopies_pos _ _ _
  have hl : 0<l := parallelCopies_pos _ _ _
  have hnk : 0<n*k := Nat.mul_pos hn hk
  have hml : 0<m*l := Nat.mul_pos hm hl
  let wc := clonedWeights (exactCloneEquiv n k) w
  let vc := clonedWeights (exactCloneEquiv m l) v
  let u := directWeights (blockEquiv (n*k) (m*l)) wc vc
  refine ⟨n*k+m*l,by omega,u,?_,?_,?_⟩
  · intro x
    rw [show u=directWeights (blockEquiv (n*k) (m*l)) wc vc from rfl,networkOutput_direct]
    simp only [wc,vc,networkOutput_cloned hk,networkOutput_cloned hl]
  · have hb := weightedSquaredNorm_direct_le hnk hml (Nat.le_add_right _ _) (Nat.le_add_left _ _)
      (blockEquiv (n*k) (m*l)) wc vc
    have hwc : weightedSquaredNorm wc=weightedSquaredNorm w :=
      weightedSquaredNorm_cloned_multiple hn hk rfl (exactCloneEquiv n k) w
    have hvc : weightedSquaredNorm vc=weightedSquaredNorm v :=
      weightedSquaredNorm_cloned_multiple hm hl rfl (exactCloneEquiv m l) v
    rw [hwc,hvc] at hb
    exact hb.trans_lt hq
  · exact operatorContractive_direct (blockEquiv (n*k) (m*l)) wc vc
      (operatorContractive_cloned hk (exactCloneEquiv n k) w hw)
      (operatorContractive_cloned hl (exactCloneEquiv m l) v hv)


theorem operator_repair_output_support {d N M r : ℕ} {U : ℝ} {g : BooleanFunction d}
    (hU : 1<U) (w : Weights d N r) (hw : w ∈ operatorFunctionSupport U g)
    (a : Cube d) (y : Bool) (u : Weights d M r)
    (hout : ∀ x, networkOutput Real.tanh u x =
      networkOutput Real.tanh w x+(if x=a then labelReal y-networkOutput Real.tanh w a else 0))
    (hg : operatorContractive u) :
    u ∈ operatorFunctionSupport U (Function.update g a y) := by
  constructor
  · refine ⟨?_,hg⟩
    intro x
    rw [hout]
    by_cases hx : x=a
    · subst x
      simp only [↓reduceIte,add_sub_cancel_left]
      cases y <;> norm_num [labelReal] <;> exact hU
    · simpa [hx] using hw.1.1 x
  · intro x
    rw [hout]
    by_cases hx : x=a
    · subst x
      simp only [↓reduceIte,add_sub_cancel_left,Function.update_self]
      cases y <;> norm_num [labelReal]
    · simpa [hx] using hw.2 x

/-- The repair remains inside the actual prior support and has square-root
energy arbitrarily close to the old square-root energy plus sqrt(P). -/
theorem exists_repaired_operator_network {d N r : ℕ} (hd : 0<d) {U : ℝ}
    (hU : 1<U) {g : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ operatorFunctionSupport U g)
    (a : Cube d) (y : Bool) (ε : ℝ) (hε : 0<ε) :
    ∃ M : ℕ, 0<M ∧ ∃ u : Weights d M r,
      u ∈ operatorFunctionSupport U (Function.update g a y) ∧
      Real.sqrt (weightedSquaredNorm u) <
        Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U)+ε := by
  let t := labelReal y-networkOutput Real.tanh w a
  have hP : 0<repairBudget d r U := repairBudget_pos d r U
  have hK := functionSupport_energy_pos w (operatorFunctionSupport_subset (by norm_num : (1:ℝ)<2) g hw)
  have hsK := Real.sqrt_nonneg (weightedSquaredNorm w)
  have hsP := Real.sqrt_pos.mpr hP
  by_cases ht : t=0
  · have hsame : Function.update g a y=g := by
      apply Function.update_eq_self_iff.mpr
      have hwa := hw.2 a
      have ht' : networkOutput Real.tanh w a=labelReal y := by dsimp [t] at ht; linarith
      rw [ht'] at hwa
      cases hga : g a <;> cases hy : y <;> simp_all [labelReal] <;> norm_num at hwa
    refine ⟨N,supported_width_pos w (operatorFunctionSupport_subset (by norm_num : (1:ℝ)<2) g hw),w,?_,?_⟩
    · simpa [hsame] using hw
    · linarith
  obtain ⟨M,hM,v,hvout,hvenergy,hvgain⟩ := exists_singleton_operator_network hd a r t
  have htbound : t^2≤(U+1)^2 := by
    have hwa := hw.1.1 a
    have hyabs : |labelReal y|=1 := by cases y <;> norm_num [labelReal]
    have ha : |t|≤U+1 := by
      calc
        |t| ≤ |labelReal y|+|networkOutput Real.tanh w a| := abs_sub _ _
        _ ≤ U+1 := by rw [hyabs]; linarith [hwa.2]
    nlinarith [abs_nonneg t,sq_abs t]
  have hvP : weightedSquaredNorm v≤repairBudget d r U := by
    have hQ : 0≤singletonReadoutBudget (r+1) := by unfold singletonReadoutBudget; positivity
    exact hvenergy.trans (by unfold repairBudget; nlinarith)
  have hvpositive : 0<weightedSquaredNorm v := by
    have ho : networkOutput Real.tanh v a≠0 := by simpa [hvout] using ht
    exact (readoutEnergy_pos_of_output_ne_zero v a ho).trans_le (readoutEnergy_le_weightedSquaredNorm v)
  let S := Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U)
  have hS : 0<S := by dsimp [S]; positivity
  let δ := (S+ε)^2-S^2
  have hδ : 0<δ := by dsimp [δ]; nlinarith
  obtain ⟨J,hJ,u,huout,huenergy,hugain⟩ := exists_parallel_operator_network (supported_width_pos w (operatorFunctionSupport_subset (by norm_num : (1:ℝ)<2) g hw)) hM
    w v hw.1.2 hvgain hK hvpositive δ hδ
  refine ⟨J,hJ,u,?_,?_⟩
  · apply operator_repair_output_support hU w hw a y u _ hugain
    intro x
    rw [huout,hvout]
  · have hvroot : Real.sqrt (weightedSquaredNorm v)≤Real.sqrt (repairBudget d r U) := Real.sqrt_le_sqrt hvP
    have hsq : (Real.sqrt (weightedSquaredNorm w)+Real.sqrt (weightedSquaredNorm v))^2≤S^2 := by
      dsimp [S]
      nlinarith [Real.sqrt_nonneg (weightedSquaredNorm v)]
    have hu : weightedSquaredNorm u<(S+ε)^2 := by dsimp [δ] at huenergy; linarith
    have hroot := Real.sq_sqrt (weightedSquaredNorm_nonneg u)
    change Real.sqrt (weightedSquaredNorm u)<S+ε
    nlinarith [Real.sqrt_nonneg (weightedSquaredNorm u)]


end
end NeuralGeneralization.BatchTwoNeuralConverse
