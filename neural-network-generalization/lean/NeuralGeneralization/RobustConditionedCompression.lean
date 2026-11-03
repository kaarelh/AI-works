import NeuralGeneralization.PointwiseRobustMainCompression
import NeuralGeneralization.RobustReadoutTruncation

/-! Concrete compression resources for any conditioned Gaussian event with
an exponential mass lower bound. No global stability assumption is used. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
namespace NeuralGeneralization.RobustConditioned
open ConcreteModel RobustPosterior RobustMainProofs RobustCompressionInput

def cap (K ε : ℝ) : ℝ := 8+4*(K-Real.log (ε/12))
def radius (r : ℕ) (K c ε : ℝ) : ℝ := min (1/6) (c/Real.sqrt (1+((r:ℝ)+1)*cap K ε))
def resources (d r : ℕ) (K c ε : ℝ) : RobustCompressionInput :=
  ofRealParameters d (r+2) (K+1) (radius r K c ε) (ε/12)

lemma cap_ge_eight {K ε : ℝ} (hK : 0 ≤ K) (hε : 0 < ε) (hε1 : ε < 1) : 8 ≤ cap K ε := by
  have hl := Real.log_nonpos (show 0 ≤ ε/12 by positivity) (show ε/12 ≤ 1 by linarith)
  dsimp [cap]
  linarith

lemma radius_pos (r : ℕ) {K c ε : ℝ} (hK : 0 ≤ K) (hc : 0 < c)
    (hε : 0 < ε) (hε1 : ε < 1) : 0 < radius r K c ε := by
  have hcap := cap_ge_eight hK hε hε1
  apply lt_min (by norm_num)
  apply div_pos hc (Real.sqrt_pos.mpr _)
  have hr : (0:ℝ) ≤ r := Nat.cast_nonneg _
  nlinarith

theorem resources_valid (d r : ℕ) {K c ε : ℝ} (hK0 : 0 ≤ K)
    (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1) :
    let p := resources d r K c ε
    2 ≤ p.depth ∧ 1 ≤ p.energy ∧ 0 < p.inverseFailure ∧ 6 ≤ p.inverseRadius ∧
      K+1 ≤ (p.energy : ℝ) ∧
      1/(p.inverseFailure : ℝ) ≤ ε/12 ∧
      1/(p.inverseRadius : ℝ) ≤ radius r K c ε := by
  let ρ := radius r K c ε
  have hρ : 0 < ρ := radius_pos r hK0 hc hε hε1
  have hρ6 : ρ ≤ 1/6 := min_le_left _ _
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

abbrev Code (d r : ℕ) (K c ε : ℝ) :=
  let p := resources d r K c ε
  RobustOutputCode p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError

def candidate (d r : ℕ) (K c ε : ℝ) : Code d r K c ε → Cube d → ℝ :=
  let p := resources d r K c ε
  robustGridOutput p.dimension p.widthBound (p.depth-2) p.weightBound p.inverseOutputError Real.tanh

theorem pointwise_compression {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K c ε σ : ℝ} (hK0 : 0 ≤ K) (hc : 0 < c) (hε : 0 < ε) (hε1 : ε < 1)
    (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal ((K+1)/σ^2))
    (hrad : ∀ᵐ w ∂Q,radius r K c ε ≤ robustRadius c w) :
    ∃ Γ : Measure (Code d r K c ε),IsProbabilityMeasure Γ ∧
      ∃ π : ∀ x : Cube d,RobustStatistics.ProbabilityCoupling Q Γ,
        ∀ x,(π x).joint.real
          (RobustStatistics.scoreFailure (fun w => networkOutput Real.tanh w x)
            (fun h => candidate d r K c ε h x)) ≤
          ε/12+Q.real {w | ¬ stableAt Real.tanh c w x} := by
  let p := resources d r K c ε
  obtain ⟨hL,hK,hAf,hR,hKreal,hfailure,hradius⟩ := resources_valid d r hK0 hc hε hε1
  let t := Real.sqrt ((N:ℝ)*σ^2)
  have ht : 0 < t := Real.sqrt_pos.mpr (by positivity)
  have htdef : t^2 = (N:ℝ)*σ^2 := Real.sq_sqrt (by positivity)
  have ht1 : t^2 ≤ 1 := htdef.le.trans hscale
  have hKLp : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (N*(p.energy:ℝ)/t^2) := by
    refine hKL.trans (ENNReal.ofReal_le_ofReal ?_)
    rw [htdef]
    calc
      (K+1)/σ^2 ≤ (p.energy:ℝ)/σ^2 :=
        div_le_div_of_nonneg_right hKreal (sq_nonneg σ)
      _ = (N:ℝ)*p.energy/((N:ℝ)*σ^2) := by
        have hNR : (N:ℝ) ≠ 0 := by positivity
        field_simp
  have hrad' : ∀ᵐ w ∂Q,1/(p.inverseRadius:ℝ) ≤ robustRadius c w :=
    hrad.mono (fun w hw => hradius.trans hw)
  haveI : IsProbabilityMeasure (Q : Measure (Weights p.dimension N (p.depth-2))) :=
    inferInstanceAs (IsProbabilityMeasure (Q : Measure (Weights d N r)))
  obtain ⟨Γ,hΓ,π,hfail⟩ := p.pointwise_finite_grid_of_large_width_raw hd hN hAf hR
    hc ht ht1 htdef Q hKLp Real.tanh tanh_admissible hrad' (fun hlarge =>
      largeWidthRawCompression p hd hL hK hAf hR N hlarge σ t hσ ht ht1 htdef Q inferInstance hKLp)
  refine ⟨Γ,hΓ,π,?_⟩
  intro x
  change 1/(p.inverseFailure:ℝ) ≤ ε/12 at hfailure
  exact (hfail x).trans (add_le_add hfailure le_rfl)

/-- Truncate the actual raw restriction and derive normalization, KL,
common radius and additive restoration from its raw mass. -/
theorem retained_inputs {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {K c σ ε : ℝ} (hK : 0 ≤ K) (hc : 0 < c) (hσ : 0 < σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hε : 0 < ε) (hε1 : ε < 1)
    (E : Set (Weights d N r)) (hE : MeasurableSet E)
    (hmass : Real.exp (-K/σ^2) ≤ (smallPrior d N r σ).real E) :
    let Q := cond (smallPrior d N r σ) E
    let Q' := cond (smallPrior d N r σ) (E ∩ readoutCap (cap K ε))
    IsProbabilityMeasure Q ∧ IsProbabilityMeasure Q' ∧
    klDiv Q' (smallPrior d N r σ) ≤ ENNReal.ofReal ((K+1)/σ^2) ∧
    (∀ᵐ w ∂Q', w ∈ E ∧ radius r K c ε ≤ robustRadius c w) ∧
    (∀ A : Set (Weights d N r), Q.real A ≤ ε/12+Q'.real A) := by
  let μ := smallPrior d N r σ
  let F : Set (Weights d N r) := readoutCap (cap K ε)
  have hF : MeasurableSet F := measurable_readoutCap _
  have hN1 : (1:ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ^2 ≤ 1 := by nlinarith [sq_nonneg σ]
  have hβ : 0 < ε/12 := by positivity
  have hβ1 : ε/12 ≤ 1 := by linarith
  have hβhalf : ε/12 ≤ (1/2:ℝ) := by linarith
  have hcap := cap_ge_eight hK hε hε1
  have htail : (cond μ E).real Fᶜ ≤ ε/12 := by
    apply conditional_tail_of_exponential_bounds μ E Fᶜ hE (B := cap K ε)
      (sq_pos_of_pos hσ) hs1 hβ hβ1 hmass _ (by dsimp [cap]; linarith)
    have heq : Fᶜ = {w | cap K ε < readoutEnergy w} := by
      ext w; simp [F,readoutCap]
    rw [heq]
    exact smallPrior_readout_tail hd hN hσ (by nlinarith)
  have hne : μ E ≠ 0 := by
    intro hz
    have hp := (Real.exp_pos _).trans_le hmass
    change 0 < μ.real E at hp
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
    exact (lt_irrefl 0) hp
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hne
  have hret := retained_exponential_mass μ E F hE hF (sq_pos_of_pos hσ) hs1 hβhalf hmass htail
  have hretne : μ (E ∩ F) ≠ 0 := by
    intro hz
    have hp := (Real.exp_pos _).trans_le hret
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hp
    exact (lt_irrefl 0) hp
  letI : IsProbabilityMeasure (cond μ (E ∩ F)) := cond_isProbabilityMeasure hretne
  refine ⟨inferInstance,inferInstance,?_,?_,?_⟩
  · exact retained_klDiv_bound μ E F hE hF (sq_pos_of_pos hσ) hs1 hβhalf hmass htail
  · filter_upwards [ae_cond_mem (μ := μ) (hE.inter hF)] with w hw
    exact ⟨hw.1,(min_le_right _ _).trans (calibrated_radius_lower hc w hw.2)⟩
  · intro A
    have hpos : 0 < (cond μ E).real F := by
      rw [probReal_compl_eq_one_sub hF] at htail
      linarith
    have hh := retained_restore_of_tail (cond μ E) F A hF hpos htail
    rw [cond_cond_eq_cond_inter hE hF] at hh
    exact hh

end NeuralGeneralization.RobustConditioned
