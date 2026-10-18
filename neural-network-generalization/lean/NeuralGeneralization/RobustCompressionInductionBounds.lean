import NeuralGeneralization.RobustCompressionInductionInitial
import NeuralGeneralization.RobustCompressionTerminalReadout

/-! # Bounded coefficients through the actual canonical prefix recursion -/
noncomputable section
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionClipping

theorem initialPrefix_bounded {d N m r : ℕ} (hd : 0 < d) (σ B : ℝ) (hB : 0 ≤ B)
    (z : FirstBlock d N) : activePrefixBounded B (initialPrefix d N m r σ B z) := by
  intro h
  intro i j
  change |wholeClip B (initialPhysicalRow d N r σ z i) j / Real.sqrt (d : ℝ)| ≤ B
  rw [abs_div,abs_of_nonneg (Real.sqrt_nonneg _)]
  have hc : |wholeClip B (initialPhysicalRow d N r σ z i) j| ≤
      ‖wholeClip B (initialPhysicalRow d N r σ z i)‖ := by
    simpa only [Real.norm_eq_abs] using
      PiLp.norm_apply_le (wholeClip B (initialPhysicalRow d N r σ z i)) j
  have hcoord : |wholeClip B (initialPhysicalRow d N r σ z i) j| ≤ B :=
    hc.trans (wholeClip_norm_le B hB _)
  have hsqrt : 1 ≤ Real.sqrt (d : ℝ) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    exact_mod_cast hd
  exact (div_le_div_of_nonneg_right hcoord (Real.sqrt_nonneg _)).trans
    (div_le_self hB hsqrt)

theorem stepPayload_bounded {d N m s : ℕ} {B : ℝ} (hB : 0 ≤ B)
    (p : PrefixPayload d N m s) (draw : PrefixDraw N m)
    (hp : payloadBounded d N m B s p) (hr : ∀ i j,|draw.2 i j|≤B) :
    payloadBounded d N m B (s+1) (stepPayload d N m s p draw) := by
  cases s with
  | zero =>
    constructor
    · intro z
      rcases z with ⟨i,j⟩ | (⟨l,i,j⟩ | i)
      · exact hp (draw.1 i) j
      · exact Fin.elim0 l
      · simpa [stepPayload,firstPrefix] using hB
    · exact hr
  | succ s => exact extendPrefix_bounded p draw.1 draw.2 hp.1 hp.2 hr

theorem stepActive_bounded {d N m s : ℕ} {B : ℝ} (hB : 0 ≤ B)
    (p : ActivePrefix d N m s) (draw : PrefixDraw N m) (success : Bool)
    (hp : activePrefixBounded B p) (hr : ∀ i j,|draw.2 i j|≤B) :
    activePrefixBounded B (stepActive p draw success) := by
  unfold stepActive activePrefixBounded
  split_ifs with h
  · intro _
    have hh : p.1=true ∧ success=true := by simpa only [Bool.and_eq_true] using h
    exact stepPayload_bounded hB p.2 draw (hp hh.1) hr
  · simp

end NeuralGeneralization.RobustCompressionInduction
