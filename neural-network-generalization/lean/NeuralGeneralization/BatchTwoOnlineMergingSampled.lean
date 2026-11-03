import NeuralGeneralization.BatchTwoOnlineActualDraws
import NeuralGeneralization.BatchTwoOnlineMergingMain

/-! The previously missing sampled-mistake tail for the actual supported
ReLU Gaussian learner, with the exact polynomial-depth resource budget. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open ConcreteModel BatchTwoMerging BatchTwoOnline SquaredSampling
variable {d C r N : ℕ}

/-- Actual posterior parameter draws, with one fresh draw at each revealed
input. The measured event counts tested-margin errors and hence also controls
sign mistakes. Both global-margin conventions and every finite scale apply. -/
theorem merging_online_sampled_tail (hd : 0 < d) (hC : 0 < C) (B : LayeredNorCircuit d C r)
    (hCN : C ≤ N) {σ δ : ℝ} (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) (globalMargin : Bool)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    finiteMean (fun π => (Measure.pi (fun i =>
      mergingPrefixPosterior (N := N) (r := r) globalMargin σ B.computes i π)).real
      {draw | (Real.exp 1-1)*(2+2*(mergingOnlineCapacity d C r+
        Real.log (2*(cubeSize d:ℝ)/δ))*harmonicSum (cubeSize d-1))+Real.log (2/δ) <
        actualErrorCount (fun w j => labelReal (B.computes (cubeEnumeration d j))*
          networkOutput relu w (cubeEnumeration d j) ≤ 1/4) π draw}) ≤ δ := by
  classical
  obtain ⟨C',B',hCp,hCC,hprune,hf⟩ := B.exists_same_depth_pruning
  have hm : (0:ℝ) < cubeSize d := by exact_mod_cast Fintype.card_pos
  have hm2 : (2:ℝ) ≤ cubeSize d := by exact_mod_cast cube_card_ge_two d hd
  have hε : 0 < (2:ℝ)/cubeSize d := by positivity
  have hε1 : (2:ℝ)/cubeSize d ≤ 1 := (div_le_one hm).mpr hm2
  let P := mergingCoverProcess hd hCp B' (hCC.trans hCN) hσ hscale hε hε1 globalMargin
  have hcap : Real.log (Fintype.card (MainGridCode d C' r (2/(cubeSize d:ℝ))):ℝ) ≤
      mergingOnlineCapacity d C r := by
    apply (merging_online_grid_capacity hd hCp hprune).trans
    unfold mergingOnlineCapacity
    gcongr
  have hcard : ((Finset.univ : Finset (MainGridCode d C' r (2/(cubeSize d:ℝ)))).card:ℝ) ≤
      Real.exp (mergingOnlineCapacity d C r) := by
    simp only [Finset.card_univ]
    by_cases hz : Fintype.card (MainGridCode d C' r (2/(cubeSize d:ℝ)))=0
    · simp only [hz,Nat.cast_zero]
      exact (Real.exp_pos _).le
    · exact (Real.exp_log (by exact_mod_cast Nat.pos_of_ne_zero hz : (0:ℝ) < Fintype.card
        (MainGridCode d C' r (2/(cubeSize d:ℝ))))).symm.le.trans (Real.exp_le_exp.mpr hcap)
  have hb := actual_posterior_draw_tail Fintype.card_pos P
    (mergingPrefixPosterior (N := N) (r := r) globalMargin σ B'.computes)
    (mergingPrefix_probability hd hCp B' (hCC.trans hCN) hσ hscale globalMargin)
    (fun w j => labelReal (B'.computes (cubeEnumeration d j))*networkOutput relu w (cubeEnumeration d j) ≤ 1/4)
    (fun j => measurableSet_le
      ((continuous_networkOutput continuous_relu (cubeEnumeration d j)).measurable.const_mul _) measurable_const)
    (fun _ _ => rfl) (mergingOnlineCapacity d C r) δ
    (by unfold mergingOnlineCapacity; positivity) (by positivity) hδ hδ1 hcard
  have he : (cubeSize d:ℝ)*((2/(cubeSize d:ℝ))/2)=1 := by field_simp
  rw [he,hf] at hb
  convert hb using 1 <;> congr 3 <;> ring

#print axioms merging_online_sampled_tail
end NeuralGeneralization.BatchTwoOnlineRaw
