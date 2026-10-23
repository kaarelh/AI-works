import NeuralGeneralization.BatchTwoImprovedResourceWidthGrowth
import NeuralGeneralization.BatchTwoImprovedTargetGrowth
import NeuralGeneralization.BatchTwoImprovedGridGrowth
import NeuralGeneralization.BatchTwoImprovedLearningMain

/-! The original robust-prior learner has a uniform, all-width C^6 log^13 C
sample budget at fixed depth and accuracy. -/
noncomputable section
open Filter Asymptotics MeasureTheory
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel BatchTwoMerging BatchTwoImprovedResources RobustPosterior RobustConfidence RobustStatistics
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000

theorem nonnegative_width_growth_of_le {f g:ℕ→ℝ} {a b:ℕ}
    (hg:WidthGrowth g a b) (hfg:∀C,1≤C→0≤f C ∧ f C≤g C):WidthGrowth f a b := by
  obtain ⟨k,hk,hg⟩:=hg
  refine ⟨k,hk,?_⟩
  intro C hC
  rw [abs_of_nonneg (hfg C hC).1]
  exact (hfg C hC).2.trans ((le_abs_self _).trans (hg C hC))

theorem parameters_dimension_width_growth (d r:ℕ) (c ε:ℝ):
    FixedGrowth (fun C=>parameters d C r c ε) RobustCompressionInput.dimension 0 0 :=
  WidthGrowth.const d

theorem parameters_depth_width_growth (d r:ℕ) (c ε:ℝ):
    FixedGrowth (fun C=>parameters d C r c ε) RobustCompressionInput.depth 0 0 :=
  WidthGrowth.const ((r+2:ℕ):ℝ)

theorem parameters_failure_width_growth (d r:ℕ) (c ε:ℝ):
    FixedGrowth (fun C=>parameters d C r c ε) RobustCompressionInput.inverseFailure 0 0 :=
  WidthGrowth.const (⌈100/ε⌉₊:ℝ)

theorem parameters_energy_width_growth (d r:ℕ) (c ε:ℝ):
    FixedGrowth (fun C=>parameters d C r c ε) RobustCompressionInput.energy 1 2 := by
  exact ((improvedTargetCost_width_growth d r c).add
    ((WidthGrowth.const 1).mono (by omega) (by omega))).ceil

theorem readoutBound_width_growth (d r:ℕ) (c ε:ℝ):
    WidthGrowth (fun C=>readoutBound d C r c ε) 1 2 := by
  exact (((improvedTargetCost_width_growth d r c).add
    ((WidthGrowth.const (-Real.log (ε/100))).mono (by omega) (by omega))).const_mul 4 |>.add
    ((WidthGrowth.const 8).mono (by omega) (by omega))).congr (fun C _=>by unfold readoutBound;ring)

theorem parameters_radiusSq_width_growth (d r:ℕ) {c ε:ℝ}
    (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    FixedGrowth (fun C=>parameters d C r c ε) (fun p=>p.inverseRadius^2) 1 2 := by
  have hQ:WidthGrowth (fun C=>1+((r:ℝ)+1)*readoutBound d C r c ε) 1 2 :=
    ((WidthGrowth.const 1).mono (by omega) (by omega)).add
      ((readoutBound_width_growth d r c ε).const_mul ((r:ℝ)+1))
  have hG:=((hQ.const_mul (2/c^2)).add ((WidthGrowth.const 74).mono (by omega) (by omega)))
  apply nonnegative_width_growth_of_le hG
  intro C hC
  refine ⟨Nat.cast_nonneg _,?_⟩
  let q:ℝ:=1+((r:ℝ)+1)*readoutBound d C r c ε
  have hb:=readoutBound_ge_eight (d:=d) (r:=r) (by omega : 0<C) c hε hε1
  have hq:0≤q:=by dsimp [q];positivity
  let y:ℝ:=Real.sqrt q/c
  have hy:0≤y:=by dsimp [y];positivity
  let x:ℝ:=max 6 y
  have hx:0≤x:=(by norm_num : (0:ℝ)≤6).trans (le_max_left _ _)
  have hceil:((parameters d C r c ε).inverseRadius:ℝ)≤x+1:=by
    exact (Nat.ceil_lt_add_one hx).le
  have hsquare:((parameters d C r c ε).inverseRadius:ℝ)^2≤(x+1)^2 :=
    pow_le_pow_left₀ (Nat.cast_nonneg _) hceil 2
  have hx2:x^2≤36+y^2 := by
    dsimp [x]
    rcases le_total 6 y with h|h
    · rw [max_eq_right h];nlinarith
    · rw [max_eq_left h];nlinarith [sq_nonneg y]
  have hy2:y^2=q/c^2:=by dsimp [y];rw [div_pow,Real.sq_sqrt hq]
  change ↑((parameters d C r c ε).inverseRadius^2)≤2/c^2*q+74
  push_cast
  have hb2:(x+1)^2≤2*x^2+2:=by nlinarith [sq_nonneg (x-1)]
  rw [hy2] at hx2
  have he:2*(q/c^2)=2/c^2*q:=by ring
  nlinarith

theorem candidateWidth_width_growth (d r:ℕ) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    WidthGrowth (fun C=>(candidateWidth d C r c ε:ℝ)) 3 6 :=
  widthBound_fixed_growth (parameters_dimension_width_growth d r c ε)
    (parameters_depth_width_growth d r c ε) (parameters_failure_width_growth d r c ε)
    (parameters_energy_width_growth d r c ε) (parameters_radiusSq_width_growth d r hc hε hε1)

theorem candidateWeightBound_width_growth (d r:ℕ) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    WidthGrowth (fun C=>(candidateWeightBound d C r c ε:ℝ)) 6 12 :=
  weightBound_fixed_growth (parameters_dimension_width_growth d r c ε)
    (parameters_depth_width_growth d r c ε) (parameters_failure_width_growth d r c ε)
    (parameters_energy_width_growth d r c ε) (parameters_radiusSq_width_growth d r hc hε hε1)

theorem candidateResolution_width_growth (d r:ℕ) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    WidthGrowth (fun C=>(candidateResolution d C r c ε:ℝ)) 1 2 := by
  have hR:=radius_fixed_growth (parameters_radiusSq_width_growth d r hc hε hε1)
  exact ((hR.add ((FixedGrowth.const 1).mono (by omega) (by omega))).const_mul 8)

theorem entropy_width_growth (d r:ℕ) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    WidthGrowth (fun C=>entropy d C r c ε) 6 13 :=
  improvedGridEntropy_width_growth d r (candidateWidth_width_growth d r hc hε hε1)
    (candidateWeightBound_width_growth d r hc hε hε1) (candidateResolution_width_growth d r hc hε hε1)
    (fun C _=>candidateWeightBound_pos d C r c ε) (fun C _=>candidateResolution_pos d C r c ε)

theorem entropy_isBigO (d r:ℕ) {c ε:ℝ} (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    (fun C=>entropy d C r c ε)=O[atTop](fun C=>(C:ℝ)^6*Real.log ((C:ℝ)+2)^13) :=
  (entropy_width_growth d r hc hε hε1).isBigO


/-- An explicit all-width learning theorem.  The constant depends on fixed input
dimension, depth, support radius and desired accuracy, but not on circuit width,
learner width, prior strength, failure probability or input distribution. -/
theorem all_width_six_thirteen_learning {d r:ℕ} (hd:0<d) {c ε:ℝ}
    (hc:0<c) (hε:0<ε) (hε1:ε≤1):
    ∃A:ℝ,0<A ∧ ∀C:ℕ,0<C→∀B:LayeredBooleanCircuit d C r,
      ∀δ:ℝ,0<δ→∀D:Measure (Cube d),IsProbabilityMeasure D→∀n:ℕ,0<n→
      A*(C:ℝ)^6*(1+Real.log C)^13+200*Real.log (1/δ)≤(n:ℝ)*ε→
      ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
        1-δ≤(CompressionSampling.iidSamples D n).real E ∧
        ∀sample∈E,∀N,C≤N→∀t,0<t→t≤1→
          0<(smallPrior d N r (t/Real.sqrt N)).real
            (robustPosteriorEvent Real.tanh c B.computes sample) ∧
          gibbsMarginRisk D
            (robustPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N) B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
          D.real {x|correctConfidence
            (robustPosterior (N:=N) (r:=r) Real.tanh c (t/Real.sqrt N) B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨a,ha,hbound⟩:=entropy_width_growth d r hc hε hε1
  refine ⟨200*a,by positivity,?_⟩
  intro C hC B δ hδ D hD n hn hbudget
  letI:IsProbabilityMeasure D:=hD
  apply all_width_all_scale_learning hd hC B hc hε hε1 hδ D n hn
  have hh:entropy d C r c ε≤a*(C:ℝ)^6*(1+Real.log C)^13:=
    (le_abs_self _).trans (hbound C (by omega))
  nlinarith only [hh,hbudget]

end NeuralGeneralization.BatchTwoImprovedLearning
