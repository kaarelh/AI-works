import NeuralGeneralization.BatchTwoOnlineMeanFieldExactCompression
import NeuralGeneralization.BatchTwoOnlineMeanFieldExactHiddenTail
import NeuralGeneralization.BatchTwoOnlineMeanFieldExactReadout

/-! The literal T_L threshold and G_L class, with all actual-prior estimates
proved at the manuscript's real K≥4 and exceptional rate L exp(-NK/8). -/
noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel MeanFieldGoodEvent

theorem sparseCount_pos (r : ℕ) {K : ℝ} (hK : 0<K) : 0<sparseCount r K := by
  have hg:0<maxTilt r K:=layerBudget_pos r hK 1
  exact Nat.ceil_pos.mpr (by positivity)

theorem layerBudget_sq_le_twice_sparseCount (r : ℕ) {K : ℝ} (hK : 0<K)
    {s : ℕ} (hs : 1≤s) : (layerBudget r K s)^2≤2*(sparseCount r K:ℝ) := by
  have hle:=layerBudget_le_max r K hs
  have hg:0≤layerBudget r K s:=(layerBudget_pos r hK s).le
  have hm:0≤maxTilt r K:=(layerBudget_pos r hK 1).le
  have hh:=sq_le_sq₀ hg hm |>.mpr hle
  have hc:(maxTilt r K)^2/2≤(sparseCount r K:ℝ):=Nat.le_ceil _
  nlinarith

theorem learnerThreshold_pos (d r : ℕ) (K : ℝ) : 0<learnerThreshold d r K := by
  apply Nat.ceil_pos.mpr
  exact lt_of_lt_of_le zero_lt_one (le_max_left _ _)

theorem learnerThreshold_entropy {d r N : ℕ} {K : ℝ} (hK : 4≤K)
    (hN : learnerThreshold d r K≤N) :
    (sparseCount r K:ℝ)*testEntropy d≤(N:ℝ)*(K-1)/2 := by
  have hceil:max 1 (2*(sparseCount r K:ℝ)*testEntropy d/(K-1))≤
      (learnerThreshold d r K:ℝ):=Nat.le_ceil _
  have hNR:(learnerThreshold d r K:ℝ)≤N:=by exact_mod_cast hN
  have hh:=((le_max_right _ _).trans hceil).trans hNR
  have hpos:0<K-1:=by linarith
  have hx:2*(sparseCount r K:ℝ)*testEntropy d≤(N:ℝ)*(K-1):=
    (div_le_iff₀ hpos).mp hh
  linarith

theorem aggregate_tail {d N r : ℕ} (hd : 0<d) {K : ℝ} (hK : 4≤K)
    (hN : learnerThreshold d r K≤N) :
    (∑f∈Finset.univ\functions d r K,functionMass Real.tanh (1/2) (powerPrior d N r 1) f)≤
      (r+2:ℝ)*Real.exp (-(N:ℝ)*K/8) := by
  have hN0:0<N:=(learnerThreshold_pos d r K).trans_le hN
  have hK0:0<K:=by linarith
  let G:ℕ→ℝ:=fun s=>layerBudget r K (s+1)
  have hhidden:=goodHidden_compl_tail (r:=r) (s:=sparseCount r K) hd hN0
    (sparseCount_pos r hK0) G K hK (fun j hj=>layerBudget_pos r hK0 (j+1))
    (fun j hj=>layerBudget_sq_le_twice_sparseCount r hK0 (by omega))
    (learnerThreshold_entropy hK hN)
  have hread:=readout_bad_tail (d:=d) (r:=r) hd hN0 K hK
  have hset:(goodWeights d N r K)ᶜ=
      {w|¬GoodHidden d N r G K w}∪{w|K<(N:ℝ)*(∑i,w (.inr (.inr i))^2)}:=by
    ext w
    simp only [goodWeights,Set.mem_compl_iff,Set.mem_setOf_eq,Set.mem_union,not_and_or,not_le]
    rfl
  apply (excluded_mass_le_bad_event hd hN0 hK0 (powerPrior d N r 1)).trans
  rw [hset]
  apply (measureReal_union_le _ _).trans
  calc
    _ ≤ (r+1:ℝ)*Real.exp (-(N:ℝ)*K/8)+Real.exp (-(N:ℝ)*K/8):=add_le_add hhidden hread
    _ = _:=by ring

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
