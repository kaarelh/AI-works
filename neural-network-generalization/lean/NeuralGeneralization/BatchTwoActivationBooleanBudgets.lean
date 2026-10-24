import NeuralGeneralization.BatchTwoActivationDepthBudgets
import NeuralGeneralization.BatchTwoActivationPolynomialCapacity

/-! The local polynomial hypotheses hold with polynomial dimension/energy
budgets on the Boolean cube, including every intermediate diagonal budget. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1200000
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem cube_log_twice_card (d : ℕ) : Real.log (2*(Fintype.card (Cube d):ℝ))≤(d:ℝ)+1 := by
  have hc : (Fintype.card (Cube d):ℝ)=(2:ℝ)^d := by simp [Cube]
  rw [hc,show 2*(2:ℝ)^d=(2:ℝ)^(d+1) by rw [pow_succ]; ring,Real.log_pow]
  have hlog : Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  have hm := mul_le_mul_of_nonneg_left hlog (show (0:ℝ)≤(d+1:ℕ) by positivity)
  simpa using hm

theorem cube_log_bulk (d : ℕ) :
    Real.log (4*((Fintype.card (Cube d):ℝ)+1))≤(d:ℝ)+4 := by
  have hc : (Fintype.card (Cube d):ℝ)=(2:ℝ)^d := by simp [Cube]
  rw [hc,Real.log_mul (by norm_num : (4:ℝ)≠0) (by positivity)]
  have hlog : Real.log 4≤3 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<4)]
  linarith [cube_log_card_le d]

theorem cube_gaussianBulkThreshold_bound (d : ℕ) {M : ℝ} (hM : 0≤M) :
    gaussianBulkThreshold (Cube d) M≤2*M*((d:ℝ)+4)+1 := by
  have hlog0 : 0≤Real.log (4*((Fintype.card (Cube d):ℝ)+1)) := Real.log_nonneg (by
    have := Nat.cast_nonneg (Fintype.card (Cube d)) (α:=ℝ)
    linarith)
  have hs : (gaussianBulkThreshold (Cube d) M)^2=
      2*M*Real.log (4*((Fintype.card (Cube d):ℝ)+1)) := Real.sq_sqrt (by positivity)
  have hh := mul_le_mul_of_nonneg_left (cube_log_bulk d) (show 0≤2*M by positivity)
  have hn : 0≤2*M*((d:ℝ)+4) := by positivity
  nlinarith [Real.sqrt_nonneg (2*M*Real.log (4*((Fintype.card (Cube d):ℝ)+1))),sq_nonneg (2*M*((d:ℝ)+4))]

theorem activationDiagonalBudget_pos {b d K H : ℕ} (hb : 1≤b) :
    0<activationDiagonalBudget b d K H := by
  unfold activationDiagonalBudget
  positivity

theorem activationDiagonalBudget_mono {b d K s H : ℕ} (hb : 1≤b) (hs : s≤H) :
    activationDiagonalBudget b d K s≤activationDiagonalBudget b d K H := by
  unfold activationDiagonalBudget
  exact Nat.mul_le_mul_left 2 (Nat.pow_le_pow_right (by positivity) hs)

theorem activation_stage_budget_envelopes {b d K H s : ℕ} (hb : 1≤b) (hK : 1≤K)
    (hs : s≤H) {ℓ B : ℝ} (hℓ : ℓ≤b) (hB : B≤b) :
    let k := activationStageBudget H (activationBaseBudget b d K H) s
    128≤k ∧ ℓ≤k ∧ B≤k ∧ (activationDiagonalBudget b d K s:ℝ)≤k ∧
      4*(K:ℝ)≤k ∧ 8*(4*(K:ℝ)+Real.log 3)≤k ∧
      gaussianBulkThreshold (Cube d) (activationDiagonalBudget b d K s)≤k ∧
      Real.log (2*(Fintype.card (Cube d):ℝ))≤k := by
  let b₀ := activationBaseBudget b d K H
  let k := activationStageBudget H b₀ s
  have hbase : b₀≤k := activationPrecisionGrow_ge_base (by dsimp [b₀,activationBaseBudget]; omega) _
  have hbaseR : (b₀:ℝ)≤k := by exact_mod_cast hbase
  have hb128 : 128≤b₀ := by dsimp [b₀,activationBaseBudget]; omega
  have hbb : b≤b₀ := by dsimp [b₀,activationBaseBudget]; omega
  have hbd : d+1≤b₀ := by dsimp [b₀,activationBaseBudget]; omega
  have hbK : 512*K≤b₀ := by dsimp [b₀,activationBaseBudget]; omega
  have hbM : 2*activationDiagonalBudget b d K H*(d+4)+1≤b₀ := by
    dsimp [b₀,activationBaseBudget]
    omega
  have hMs := activationDiagonalBudget_mono (d:=d) (K:=K) hb hs
  have hMsR : (activationDiagonalBudget b d K s:ℝ)≤activationDiagonalBudget b d K H := by exact_mod_cast hMs
  have hbMR : 2*(activationDiagonalBudget b d K H:ℝ)*((d:ℝ)+4)+1≤b₀ := by exact_mod_cast hbM
  have hbdR : (d:ℝ)+1≤b₀ := by exact_mod_cast hbd
  have hbKR : 512*(K:ℝ)≤b₀ := by exact_mod_cast hbK
  have hbbR : (b:ℝ)≤b₀ := by exact_mod_cast hbb
  have hlog3 : Real.log 3≤2 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<3)]
  have hKR : (1:ℝ)≤K := by exact_mod_cast hK
  have hgauss := cube_gaussianBulkThreshold_bound d (Nat.cast_nonneg (activationDiagonalBudget b d K s))
  have hMnonneg : (0:ℝ)≤activationDiagonalBudget b d K H := Nat.cast_nonneg _
  have hdnonneg : (0:ℝ)≤d := Nat.cast_nonneg _
  refine ⟨hb128.trans hbase,le_trans hℓ (hbbR.trans hbaseR),le_trans hB (hbbR.trans hbaseR),?_,?_,?_,?_,?_⟩
  · nlinarith
  · linarith
  · linarith
  · have hm := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hMsR (by norm_num : (0:ℝ)≤2))
      (show 0≤(d:ℝ)+4 by positivity)
    linarith
  · exact (cube_log_twice_card d).trans (hbdR.trans hbaseR)

end NeuralGeneralization.BatchTwoActivation
