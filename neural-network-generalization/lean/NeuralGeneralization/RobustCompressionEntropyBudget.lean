import NeuralGeneralization.RobustCompressionResourceAllocations
import NeuralGeneralization.RobustCompressionMessages

/-! # Paying all finite query messages from the literal width cutoff -/

noncomputable section
open scoped ENNReal

namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem active_rank_constructor_budget (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) (hδ : 0 < p.inverseSelectionError) :
    2*(p.energy : ℝ) ≤ (p.inverseLayerFailure : ℝ)⁻¹ *
      ((p.inverseSelectionError : ℝ)⁻¹)^3 * p.activeRank := by
  have hH : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  have hD : (0 : ℝ) < p.inverseSelectionError := by exact_mod_cast hδ
  have hq : (p.activeRank : ℝ) =
      2*p.energy*p.inverseLayerFailure*(p.inverseSelectionError : ℝ)^3+1 := by
    simp only [activeRank,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one]
  rw [hq]
  have heq : (p.inverseLayerFailure : ℝ)⁻¹ *
      ((p.inverseSelectionError : ℝ)⁻¹)^3 *
      (2*p.energy*p.inverseLayerFailure*(p.inverseSelectionError : ℝ)^3+1) =
      2*p.energy + 1/((p.inverseLayerFailure : ℝ)*(p.inverseSelectionError : ℝ)^3) := by
    field_simp
  rw [heq]
  exact le_add_of_nonneg_right (by positivity)

theorem message_entropy_stage_budget (p : RobustCompressionInput)
    (I : Type*) [Fintype I] {N stage : ℕ}
    (hcard : Fintype.card I ≤ 2^p.dimension)
    (hN : p.widthBound ≤ N) (hK : 0 < p.energy) (hs : stage ≤ p.depth) :
    (stage : ℝ) * Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ) ≤
      (N : ℝ)*p.energy := by
  have hc := queryMessage_log_card_le_of_card_le I p.dimension p.activeRank hcard
  have hlog : 0 ≤ Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ) := by
    apply Real.log_nonneg
    exact_mod_cast Fintype.card_pos_iff.mpr
      (inferInstance : Nonempty (QueryMessage I p.activeRank))
  calc
    _ ≤ (p.depth : ℝ) * Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ) :=
      mul_le_mul_of_nonneg_right (by exact_mod_cast hs) hlog
    _ ≤ (p.depth : ℝ) *
        ((((p.dimension+1)*p.activeRank+2 : ℕ) : ℝ)*Real.log 2) :=
      mul_le_mul_of_nonneg_left hc (Nat.cast_nonneg _)
    _ ≤ _ := p.message_entropy_budget hN hK

theorem initial_and_messages_budget_real (p : RobustCompressionInput)
    (I : Type*) [Fintype I] {N stage : ℕ} {t : ℝ}
    (hcard : Fintype.card I ≤ 2^p.dimension)
    (hN : p.widthBound ≤ N) (hK : 0 < p.energy) (hs : stage ≤ p.depth)
    (ht : 0 < t) (ht1 : t^2 ≤ 1) :
    (N : ℝ)*p.energy/t^2 +
      (stage : ℝ)*Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ) ≤
      2*(N : ℝ)*p.energy/t^2 := by
  have hb := p.message_entropy_stage_budget I hcard hN hK hs
  have hsq : 0 < t^2 := sq_pos_of_pos ht
  have hbase : (N : ℝ)*p.energy ≤ (N : ℝ)*p.energy/t^2 := by
    apply (le_div_iff₀ hsq).mpr
    nlinarith [show (0 : ℝ) ≤ (N : ℝ)*p.energy by positivity]
  calc
    _ ≤ (N : ℝ)*p.energy/t^2 + (N : ℝ)*p.energy/t^2 := add_le_add le_rfl (hb.trans hbase)
    _ = _ := by ring

/-- The bound consumed by the genuine finite-message induction: its initial
KL and every message cost together fit twice the initial scaled budget. -/
theorem initial_and_messages_budget (p : RobustCompressionInput)
    (I : Type*) [Fintype I] {N stage : ℕ} {t : ℝ}
    (hcard : Fintype.card I ≤ 2^p.dimension)
    (hN : p.widthBound ≤ N) (hK : 0 < p.energy) (hs : stage ≤ p.depth)
    (ht : 0 < t) (ht1 : t^2 ≤ 1) :
    ENNReal.ofReal ((N : ℝ)*p.energy/t^2) +
      stage • ENNReal.ofReal
        (Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ)) ≤
      ENNReal.ofReal (2*(N : ℝ)*p.energy/t^2) := by
  have hlog : 0 ≤ Real.log (Fintype.card (QueryMessage I p.activeRank) : ℝ) := by
    apply Real.log_nonneg
    exact_mod_cast Fintype.card_pos_iff.mpr
      (inferInstance : Nonempty (QueryMessage I p.activeRank))
  rw [nsmul_eq_mul, ← ENNReal.ofReal_natCast,
    ← ENNReal.ofReal_mul (Nat.cast_nonneg stage),
    ← ENNReal.ofReal_add (by positivity) (by positivity)]
  exact ENNReal.ofReal_le_ofReal (p.initial_and_messages_budget_real I hcard hN hK hs ht ht1)

end NeuralGeneralization.ConcreteModel.RobustCompressionInput
