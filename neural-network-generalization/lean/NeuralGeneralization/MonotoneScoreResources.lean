import NeuralGeneralization.RobustConditionedCompression

/-! The finite compression resources for arbitrary transformed-score gaps.
Only the common radius changes; the KL energy and failure allocations agree
with the original robust theorem. -/
noncomputable section
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel RobustCompressionInput

def radius (r : ℕ) (K c ε Δ : ℝ) : ℝ :=
  min (2*Δ/3) (RobustConditioned.radius r K c ε)

def resources (d r : ℕ) (K c ε Δ : ℝ) : RobustCompressionInput :=
  ofRealParameters d (r+2) (K+1) (radius r K c ε Δ) (ε/12)

lemma radius_pos (r : ℕ) {K c ε Δ : ℝ} (hK : 0 ≤ K) (hc : 0 < c)
    (hε : 0 < ε) (hε1 : ε < 1) (hΔ : 0 < Δ) : 0 < radius r K c ε Δ :=
  lt_min (by positivity) (RobustConditioned.radius_pos r hK hc hε hε1)

theorem resources_valid (d r : ℕ) {K c ε Δ : ℝ} (hΔ : 0 < Δ) (hK0 : 0 ≤ K)
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    let p := resources d r K c ε Δ
    2 ≤ p.depth ∧ 1 ≤ p.energy ∧ 0 < p.inverseFailure ∧ 6 ≤ p.inverseRadius ∧
      K+1 ≤ (p.energy : ℝ) ∧
      1/(p.inverseFailure : ℝ) ≤ ε/12 ∧
      1/(p.inverseRadius : ℝ) ≤ radius r K c ε Δ := by
  let ρ := radius r K c ε Δ
  have hρ : 0 < ρ := radius_pos r hK0 hc hε hε1 hΔ
  have hρ6 : ρ ≤ 1/6 := (min_le_right _ _).trans (min_le_left _ _)
  have hK : 1 ≤ K+1 := by
    have := hK0
    linarith
  have hKceil := Nat.le_ceil (K+1)
  have hAc : (ε/12)⁻¹ ≤ (⌈(ε/12)⁻¹⌉₊ : ℝ) := Nat.le_ceil _
  have hRc : ρ⁻¹ ≤ (⌈ρ⁻¹⌉₊ : ℝ) := Nat.le_ceil _
  have hR6 : (6 : ℝ) ≤ ρ⁻¹ := by
    have h := one_div_le_one_div_of_le hρ hρ6
    norm_num only [one_div_div,div_one,one_div] at h
    exact h
  have hAi : 1/(⌈(ε/12)⁻¹⌉₊ : ℝ) ≤ ε/12 := by
    have h := one_div_le_one_div_of_le (inv_pos.mpr (by positivity : 0 < ε/12)) hAc
    simpa only [one_div,inv_inv] using h
  have hRi : 1/(⌈ρ⁻¹⌉₊ : ℝ) ≤ ρ := by
    have h := one_div_le_one_div_of_le (inv_pos.mpr hρ) hRc
    simpa only [one_div,inv_inv] using h
  dsimp [resources,ofRealParameters]
  refine ⟨by omega,?_,Nat.ceil_pos.mpr (by positivity),?_,hKceil,hAi,hRi⟩
  · exact_mod_cast hK.trans hKceil
  · exact_mod_cast hR6.trans hRc


abbrev Code (d r : ℕ) (K c ε Δ : ℝ) :=
  let p := resources d r K c ε Δ
  RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError

def candidate (d r : ℕ) (K c ε Δ : ℝ) : Code d r K c ε Δ → Cube d → ℝ :=
  let p := resources d r K c ε Δ
  robustGridOutput p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError Real.tanh

end NeuralGeneralization.ScoreTransform
