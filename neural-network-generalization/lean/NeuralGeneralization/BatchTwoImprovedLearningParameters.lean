import NeuralGeneralization.BatchTwoImprovedTargetMain
import NeuralGeneralization.BatchTwoImprovedResources
import NeuralGeneralization.BatchTwoImprovedGrid
import NeuralGeneralization.RobustPosterior

/-! Common compression and entropy parameters for the actual original robust
prior. They depend on the teacher and accuracy, never the learner width. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel

def readoutBound (d C r:ℕ) (c ε:ℝ):ℝ :=
  8+4*(improvedTargetCost d C r c-Real.log (ε/100))

def parameters (d C r:ℕ) (c ε:ℝ):RobustCompressionInput :=
  { dimension:=d,depth:=r+2,energy:=⌈improvedTargetCost d C r c+1⌉₊,
    inverseFailure:=⌈100/ε⌉₊,
    inverseRadius:=⌈max 6 (Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c)⌉₊ }

def candidateWidth (d C r:ℕ) (c ε:ℝ):ℕ :=
  BatchTwoImprovedResources.widthBound (parameters d C r c ε)
def candidateWeightBound (d C r:ℕ) (c ε:ℝ):ℕ :=
  BatchTwoImprovedResources.weightBound (parameters d C r c ε)
def candidateResolution (d C r:ℕ) (c ε:ℝ):ℕ :=
  8*((parameters d C r c ε).inverseRadius+1)
abbrev CandidateCode (d C r:ℕ) (c ε:ℝ) :=
  RobustOutputCode d (candidateWidth d C r c ε) r
    (candidateWeightBound d C r c ε) (candidateResolution d C r c ε)
def candidate (d C r:ℕ) (c ε:ℝ) (q:CandidateCode d C r c ε):Cube d→ℝ :=
  robustGridOutput d (candidateWidth d C r c ε) r
    (candidateWeightBound d C r c ε) (candidateResolution d C r c ε) Real.tanh q

def entropy (d C r:ℕ) (c ε:ℝ):ℝ :=
  improvedGridEntropy d (candidateWidth d C r c ε) r
    (candidateWeightBound d C r c ε) (candidateResolution d C r c ε)

theorem readoutBound_ge_eight {d C r:ℕ} (hC:0<C) (c:ℝ) {ε:ℝ} (hε:0<ε) (hε1:ε≤1):
    8≤ readoutBound d C r c ε := by
  have hT:=improvedTargetCost_nonneg d r hC c
  have hlog:=Real.log_nonpos (by positivity : 0≤ε/100) (show ε/100≤1 by linarith)
  unfold readoutBound
  linarith

theorem parameters_energy {d C r:ℕ} (hC:0<C) (c ε:ℝ):
    1≤(parameters d C r c ε).energy ∧
      improvedTargetCost d C r c+1≤((parameters d C r c ε).energy:ℝ) := by
  have hT:=improvedTargetCost_nonneg d r hC c
  have hh:=Nat.le_ceil (improvedTargetCost d C r c+1)
  refine ⟨?_,hh⟩
  have hreal:(1:ℝ)≤⌈improvedTargetCost d C r c+1⌉₊ := by linarith
  exact_mod_cast hreal

theorem parameters_inverseRadius_ge_six (d C r:ℕ) (c ε:ℝ):
    6≤(parameters d C r c ε).inverseRadius := by
  have hreal:(6:ℝ)≤⌈max 6 (Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c)⌉₊ :=
    (le_max_left _ _).trans (Nat.le_ceil _)
  change (6:ℝ)≤((parameters d C r c ε).inverseRadius:ℝ) at hreal
  exact_mod_cast hreal

theorem parameters_failure (d C r:ℕ) (c:ℝ) {ε:ℝ} (hε:0<ε):
    1/(((parameters d C r c ε).inverseFailure:ℝ)+1)≤ε/100 := by
  have hh:=Nat.le_ceil (100/ε)
  change 1/((⌈100/ε⌉₊:ℝ)+1)≤ε/100
  apply (div_le_iff₀ (by positivity : 0<(⌈100/ε⌉₊:ℝ)+1)).mpr
  have hm:=mul_le_mul_of_nonneg_left hh hε.le
  have he:ε*(100/ε)=100 := by field_simp
  rw [he] at hm
  nlinarith

theorem parameters_radius {d C r:ℕ} (hC:0<C) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    0<1/(((parameters d C r c ε).inverseRadius:ℝ)+1) ∧
    1/(((parameters d C r c ε).inverseRadius:ℝ)+1)≤1/6 ∧
    1/(((parameters d C r c ε).inverseRadius:ℝ)+1)≤
      c/Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε) := by
  have hb:=readoutBound_ge_eight (d:=d) (r:=r) hC c hε hε1
  have hs:0<Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε) := by
    apply Real.sqrt_pos.mpr
    have hh:0≤((r:ℝ)+1)*readoutBound d C r c ε := mul_nonneg (by positivity) (by linarith)
    linarith
  have hR:=parameters_inverseRadius_ge_six d C r c ε
  have hRreal:(6:ℝ)≤(parameters d C r c ε).inverseRadius := by exact_mod_cast hR
  have hceil:Real.sqrt (1+((r:ℝ)+1)*readoutBound d C r c ε)/c≤
      ((parameters d C r c ε).inverseRadius:ℝ) :=
    (le_max_right _ _).trans (Nat.le_ceil _)
  refine ⟨by positivity,?_,?_⟩
  · apply (div_le_div_iff₀ (by positivity : 0<((parameters d C r c ε).inverseRadius:ℝ)+1)
      (by norm_num : (0:ℝ)<6)).mpr
    linarith
  · apply (div_le_div_iff₀ (by positivity : 0<((parameters d C r c ε).inverseRadius:ℝ)+1) hs).mpr
    have hh:=(div_le_iff₀ hc).mp hceil
    nlinarith

theorem candidateWeightBound_pos (d C r:ℕ) (c ε:ℝ):0<candidateWeightBound d C r c ε := by
  unfold candidateWeightBound BatchTwoImprovedResources.weightBound
  omega

theorem candidateResolution_pos (d C r:ℕ) (c ε:ℝ):0<candidateResolution d C r c ε := by
  unfold candidateResolution
  positivity

theorem candidate_entropy (d C r:ℕ) (c ε:ℝ):
    Real.log (Fintype.card (CandidateCode d C r c ε):ℝ)≤ entropy d C r c ε :=
  robustOutputCode_log_card_sharp _ _ _ (candidateWeightBound_pos d C r c ε)
    (candidateResolution_pos d C r c ε)

end NeuralGeneralization.BatchTwoImprovedLearning
