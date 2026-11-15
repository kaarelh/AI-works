import NeuralGeneralization.BatchTwoManuscriptAllocation
import NeuralGeneralization.BatchTwoManuscriptHistoryComplete

/-! The literal resources instantiate the original-weight history construction. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustEntropy RobustCompressionInduction BatchTwoImprovedInduction

theorem messageCost_nonneg (p : Input) : 0≤messageCost p := by
  unfold messageCost
  exact mul_nonneg (by positivity) (Real.log_nonneg (by norm_num))
theorem first_weight_allocation (p : Input) : firstBound p≤weightBound p :=
  (le_max_left _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans
    ((le_max_right _ _).trans (le_max_left _ _))))
theorem reconstruction_weight_allocation (p : Input) :
    2*activeBound p*Real.sqrt ((rank p:ℝ)+1)/(bankSize p:ℝ)+
      Real.sqrt 2*gaussianBound p/Real.sqrt (bankSize p:ℝ)≤weightBound p :=
  (le_max_right _ _).trans ((le_max_left _ _).trans ((le_max_left _ _).trans
    ((le_max_right _ _).trans (le_max_left _ _))))
theorem readout_weight_allocation (p : Input) :
    Real.sqrt (readoutEnergy p)/(bankSize p:ℝ)≤weightBound p :=
  (le_max_right _ _).trans ((le_max_left _ _).trans ((le_max_right _ _).trans (le_max_left _ _)))

theorem message_allocation (p : Input) {N : ℕ} (hN : widthBound p≤N) :
    (p.depth:ℝ)*messageCost p≤(N:ℝ)*p.energy := by
  have hceil : ⌈(p.depth:ℝ)*messageCost p/p.energy⌉₊≤N :=
    ((le_max_right _ _).trans (le_max_left _ _)).trans hN
  have hh : (p.depth:ℝ)*messageCost p/p.energy≤(N:ℝ) := (Nat.le_ceil ((p.depth:ℝ)*messageCost p/p.energy)).trans (by exact_mod_cast hceil)
  exact (div_le_iff₀ (energy_pos p)).mp hh

theorem entropy_cap (p : Input) {N j : ℕ} (hN : widthBound p≤N)
    (hj : j≤p.depth) {t : ℝ} (ht : 0<t) (ht1 : t≤1) :
    ENNReal.ofReal (p.energy/(t/Real.sqrt (N:ℝ))^2)+
      j • ENNReal.ofReal (Real.log (Fintype.card
        (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)):ℝ))≤
      ENNReal.ofReal (2*(N:ℝ)*p.energy/t^2) := by
  have hn : 0<N := (widthBound_pos p).trans_le hN
  have hc := queryMessage_log_card_le_of_card_le (Fin (Fintype.card (Cube p.dimension)))
    p.dimension (rank p) (by simp [Cube])
  have hc' : Real.log (Fintype.card (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)):ℝ)≤messageCost p := by
    simpa only [messageCost,Nat.cast_add,Nat.cast_mul,Nat.cast_one,Nat.cast_ofNat] using hc
  have hlog : 0≤Real.log (Fintype.card (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)):ℝ) := by
    apply Real.log_nonneg
    exact_mod_cast Fintype.card_pos_iff.mpr (inferInstance : Nonempty (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)))
  have hjr : (j:ℝ)≤p.depth := by exact_mod_cast hj
  have hmessage := (mul_le_mul_of_nonneg_left hc' (Nat.cast_nonneg j)).trans
    ((mul_le_mul_of_nonneg_right hjr (messageCost_nonneg p)).trans (message_allocation p hN))
  have ht2 : t^2≤1 := by nlinarith
  have hbase : (N:ℝ)*p.energy≤(N:ℝ)*p.energy/t^2 := by
    apply (le_div_iff₀ (sq_pos_of_pos ht)).mpr
    have hNK : 0≤(N:ℝ)*p.energy := mul_nonneg (Nat.cast_nonneg N) (energy_pos p).le
    nlinarith [mul_le_mul_of_nonneg_left ht2 hNK]
  have heq : p.energy/(t/Real.sqrt (N:ℝ))^2=(N:ℝ)*p.energy/t^2 := by
    rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    field_simp
  rw [heq,nsmul_eq_mul,←ENNReal.ofReal_natCast,←ENNReal.ofReal_mul (Nat.cast_nonneg j),
    ←ENNReal.ofReal_add (by have := energy_pos p; positivity) (by positivity)]
  apply ENNReal.ofReal_le_ofReal
  ring_nf at hmessage hbase ⊢
  linarith only [hmessage,hbase]

theorem exists_literal_resource_histories (p : Input) {N : ℕ}
    (hN : widthBound p≤N) {φ : ℝ→ℝ} (hφ : LipschitzWith 1 φ) (hφb : ∀z,|φ z|≤1)
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal ((N:ℝ)*p.energy/t^2)) :
    ∃ Γ : CanonicalStateLaw p.dimension N (bankSize p) (p.depth-2) 0,
      (∀ᵐ z ∂Γ.law,activePrefixBounded (weightBound p) z.1) ∧
      Γ.law {z | z.1.1=false}≤(p.depth-2) • (2*ENNReal.ofReal (localFailure p)) ∧
      ∀x : Cube p.dimension,∃ H : CanonicalHistoryComparison Q Γ.law
          (Prod.fst : OriginalHistory p.dimension N (p.depth-2) (p.depth-2)→Weights p.dimension N (p.depth-2)),
        (∀ᵐ z ∂H.joint,HistoryAligned (by omega : p.depth-2+0≤p.depth-2)
          (t/Real.sqrt (N:ℝ)) φ x z.1 z.2) ∧
        (∀ᵐ z ∂H.joint,validHiddenPath z.1.2) ∧
        (∫⁻ z,liveOriginalCost (m:=bankSize p) (k:=0) le_rfl φ x z ∂H.joint)≤
          ENNReal.ofReal (20*(p.depth:ℝ)*localError p) := by
  have hn : 0<N := (widthBound_pos p).trans_le hN
  letI : NeZero N := ⟨hn.ne'⟩
  letI : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) (rank p)) := ⊤
  have hQ' : klDiv Q (smallPrior p.dimension N (p.depth-2) (t/Real.sqrt (N:ℝ)))≤
      ENNReal.ofReal (p.energy/(t/Real.sqrt (N:ℝ))^2) := by
    convert hQ using 1
    congr 1
    rw [div_pow,Real.sq_sqrt (Nat.cast_nonneg N)]
    field_simp
  obtain ⟨Γ,hb,ha,_,hhistory⟩ := exists_manuscript_terminal_histories_activation hφ hφb p.dimension_pos
    (bankSize_pos p) (rank_pos p) (energy_pos p).le ht ht1 (firstBound_pos p) (activeBound_pos p)
    (gaussianBound_ge_two p) (selectionError_pos p) (localFailure_pos p) (localFailure_le_one p)
    (first_weight_allocation p) (reconstruction_weight_allocation p)
    (by rw [selectionError_cube]; exact rank_allocation p) (bankSize_gram_allocation p)
    (fun j hj=>entropy_cap p hN (hj.trans (Nat.sub_le _ _)) ht ht1) Q hQ'
  refine ⟨Γ,hb,ha,?_⟩
  intro x
  obtain ⟨H,hal,hvalid,hcost⟩ := hhistory x
  refine ⟨H,hal,hvalid,hcost.trans ?_⟩
  calc
    _ ≤ENNReal.ofReal (2*localError p)+(p.depth-2) • ENNReal.ofReal (20*localError p) :=
      add_le_add (ENNReal.ofReal_le_ofReal (first_allocation p))
        (nsmul_le_nsmul_right (ENNReal.ofReal_le_ofReal (layer_allocation p)) _)
    _ ≤_ := by
      rw [←ENNReal.ofReal_nsmul,←ENNReal.ofReal_add (by have := localError_pos p; positivity) (by have := localError_pos p; positivity)]
      apply ENNReal.ofReal_le_ofReal
      rw [nsmul_eq_mul,Nat.cast_sub p.depth_ge_two]
      have he := localError_pos p
      norm_num
      nlinarith

end NeuralGeneralization.BatchTwoManuscriptResources
