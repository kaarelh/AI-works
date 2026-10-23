import NeuralGeneralization.BatchTwoImprovedResourceCosts
import NeuralGeneralization.RobustCompressionMessages

/-! Width-independent scalar envelopes consumed by the actual selected run. -/
noncomputable section
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedResources
open ConcreteModel
set_option maxHeartbeats 300000
set_option maxRecDepth 4000

theorem sqrt_nat_le_sqrt_add_one (n : ℕ) : Real.sqrt (n:ℝ)≤(Nat.sqrt n:ℝ)+1 := by
  apply (Real.sqrt_le_iff).mpr
  refine ⟨by positivity,?_⟩
  exact_mod_cast (Nat.lt_succ_sqrt' n).le

theorem weightBound_pos (p : Input) : 0<weightBound p := by unfold weightBound; omega

theorem first_weight_bound (p : Input) : Real.sqrt (firstSquared p)≤weightBound p := by
  have hs := sqrt_nat_le_sqrt_add_one (firstSquared p)
  have hb : Nat.sqrt (firstSquared p)+1≤weightBound p := by unfold weightBound; omega
  exact hs.trans (by exact_mod_cast hb)

theorem reconstruction_weight_bound (p : Input) :
    2*Real.sqrt (activeSquared p)*(rank p+1)+2*Real.sqrt (gaussianSquared p)≤weightBound p := by
  have ha := sqrt_nat_le_sqrt_add_one (activeSquared p)
  have hg := sqrt_nat_le_sqrt_add_one (gaussianSquared p)
  have hm := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left ha (by norm_num : (0:ℝ)≤2))
    (by positivity : 0≤(rank p:ℝ)+1)
  have hb : 2*(Nat.sqrt (activeSquared p)+1)*(rank p+1)+
      2*(Nat.sqrt (gaussianSquared p)+1)≤weightBound p := by unfold weightBound; omega
  have hbR : 2*((Nat.sqrt (activeSquared p):ℝ)+1)*((rank p:ℝ)+1)+
      2*((Nat.sqrt (gaussianSquared p):ℝ)+1)≤weightBound p := by exact_mod_cast hb
  linarith

theorem readout_weight_bound (p : Input) : readoutClip p≤weightBound p := by unfold weightBound; omega

theorem width_ge_bankSize (p : Input) : bankSize p≤widthBound p := by unfold widthBound; omega

theorem message_entropy_budget (p : Input) {N j : ℕ} (hN : widthBound p≤N)
    (hK : 1≤p.energy) (hj : j≤p.depth) :
    (j:ℝ)*Real.log (Fintype.card (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)))≤
      (N:ℝ)*p.energy := by
  have hc := queryMessage_log_card_le_of_card_le
    (Fin (Fintype.card (Cube p.dimension))) p.dimension (rank p) (by simp [Cube])
  have hlog2 : Real.log (2:ℝ)≤1 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hb : ((p.dimension+1)*rank p+2:ℕ)≤2*(p.dimension+1)*(rank p+1) := by nlinarith
  have hpos : 0≤Real.log (Fintype.card (QueryMessage
      (Fin (Fintype.card (Cube p.dimension))) (rank p)):ℝ) := by
    apply Real.log_nonneg
    exact_mod_cast Fintype.card_pos_iff.mpr
      (inferInstance : Nonempty (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)))
  have hcut : 2*(p.depth+1)*(p.dimension+1)*(rank p+1)≤N := by
    unfold widthBound at hN
    omega
  have hcutR : 2*((p.depth:ℝ)+1)*(p.dimension+1)*(rank p+1)≤N := by exact_mod_cast hcut
  have hjR : (j:ℝ)≤p.depth := by exact_mod_cast hj
  have hKR : (1:ℝ)≤p.energy := by exact_mod_cast hK
  have hbR : (((p.dimension+1)*rank p+2:ℕ):ℝ)≤2*(p.dimension+1)*(rank p+1) := by exact_mod_cast hb
  have hlog := hc.trans (mul_le_mul_of_nonneg_left hlog2 (Nat.cast_nonneg _))
  have hs := mul_le_mul_of_nonneg_left (hlog.trans (by simpa using hbR)) (Nat.cast_nonneg j)
  have hjmul := mul_le_mul_of_nonneg_right hjR
    (by positivity : 0≤2*((p.dimension:ℝ)+1)*(rank p+1))
  have hNnonneg : (0:ℝ)≤N := Nat.cast_nonneg _
  have hNk := mul_le_mul_of_nonneg_left hKR hNnonneg
  nlinarith

theorem entropy_cap (p : Input) {N j : ℕ} (hN0 : 0<N) (hN : widthBound p≤N)
    (hK : 1≤p.energy) (hj : j≤p.depth) {t : ℝ} (ht : 0<t) (ht1 : t≤1) :
    ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2)+
      j • ENNReal.ofReal (Real.log (Fintype.card (QueryMessage
        (Fin (Fintype.card (Cube p.dimension))) (rank p))))≤
      ENNReal.ofReal (2*N*p.energy/t^2) := by
  have hn : (0:ℝ)<N := Nat.cast_pos.mpr hN0
  have hl : 0≤Real.log (Fintype.card (QueryMessage
      (Fin (Fintype.card (Cube p.dimension))) (rank p)):ℝ) := by
    apply Real.log_nonneg
    exact_mod_cast Fintype.card_pos_iff.mpr
      (inferInstance : Nonempty (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)))
  rw [←ENNReal.ofReal_nsmul,←ENNReal.ofReal_add (by positivity) (by positivity)]
  apply ENNReal.ofReal_le_ofReal
  rw [nsmul_eq_mul]
  have hmsg := message_entropy_budget p hN hK hj
  have he : (p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2=N*p.energy/t^2 := by
    rw [div_pow,Real.sq_sqrt hn.le]
    field_simp
  rw [he]
  have hbase : (N:ℝ)*p.energy≤N*p.energy/t^2 := by
    apply (le_div_iff₀ (sq_pos_of_pos ht)).mpr
    have ht2 : t^2≤1 := by nlinarith
    exact mul_le_of_le_one_right (by positivity) ht2
  calc
    _ ≤ (N:ℝ)*p.energy/t^2+(N:ℝ)*p.energy/t^2 := add_le_add le_rfl (hmsg.trans hbase)
    _ = _ := by ring
end NeuralGeneralization.BatchTwoImprovedResources
