import NeuralGeneralization.BatchTwoImprovedLearningPolynomialParameters
import NeuralGeneralization.BatchTwoImprovedLearningScales
import NeuralGeneralization.BatchTwoImprovedResourceGrowth
import NeuralGeneralization.BatchTwoImprovedGridBudget

/-! Universal degree-46 sample complexity for the original robustness support. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedLearning
open ConcreteModel RobustPosterior RobustConfidence
set_option maxHeartbeats 600000

theorem entropy_global_polynomial:
    ∃K:ℝ,0<K ∧ ∀(d C r:ℕ),0<C→∀c ε S:ℝ,0<c→0<ε→ε≤1→2≤S→
      (d:ℝ)≤S→(C:ℝ)≤S→(r:ℝ)+2≤S→c≤S→c⁻¹≤S→ε⁻¹≤S→
      entropy d C r c ε≤K*S^45 := by
  obtain ⟨a,ha,hwidth⟩:=BatchTwoImprovedResources.widthBound_global_growth
    (show (0:ℝ)<100000000000 by norm_num) (show (0:ℝ)<10000000 by norm_num) (show (0:ℝ)<101 by norm_num)
  obtain ⟨b,hb,hweight⟩:=BatchTwoImprovedResources.weightBound_global_growth
    (show (0:ℝ)<100000000000 by norm_num) (show (0:ℝ)<10000000 by norm_num) (show (0:ℝ)<101 by norm_num)
  refine ⟨improvedGridBudgetCoefficient (a+1) (b+1) 100000000,?_,?_⟩
  · unfold improvedGridBudgetCoefficient
    positivity
  · intro d C r hC c ε S hc hε hε1 hS hd hCS hr hcS hci hεS
    obtain ⟨hdp,hlp,hkp,hrp,hap⟩:=parameters_global hC hc hε hε1 hS hd hCS hr hcS hci hεS
    have hp:BatchTwoImprovedResources.ResourceHypotheses 100000000000 10000000 101 (parameters d C r c ε) S :=
      ⟨hS,hdp,hlp,hkp,hrp,hap⟩
    have hS0:0≤S:=by linarith
    have hw:(candidateWidth d C r c ε:ℝ)≤(a+1)*S^21:=by
      have hh:=hwidth _ _ hp
      change (candidateWidth d C r c ε:ℝ)≤a*S^21 at hh
      nlinarith [pow_nonneg hS0 21]
    have hB:(candidateWeightBound d C r c ε:ℝ)≤(b+1)*S^24:=by
      have hh:=hweight _ _ hp
      change (candidateWeightBound d C r c ε:ℝ)≤b*S^24 at hh
      nlinarith [pow_nonneg hS0 24]
    have hR:(candidateResolution d C r c ε:ℝ)≤100000000*S^3:=by
      unfold candidateResolution
      push_cast
      have hs3:1≤S^3:=one_le_pow₀ (by linarith : 1≤S)
      nlinarith
    exact improvedGridEntropy_resource_polynomial (by linarith) (by linarith)
      (by norm_num : (1:ℝ)≤100000000) (by linarith) hd (by linarith) hw hB hR
      (candidateWeightBound_pos d C r c ε) (candidateResolution_pos d C r c ε)

def problemSize (d C r:ℕ) (c ε δ:ℝ):ℝ :=
  2+(d:ℝ)+(C:ℝ)+((r:ℝ)+2)+c+c⁻¹+ε⁻¹+Real.log (1/δ)

theorem problemSize_bounds (d C r:ℕ) {c ε δ:ℝ} (hc:0<c) (hε:0<ε) (hδ:0<δ) (hδ1:δ≤1):
    let S:=problemSize d C r c ε δ
    2≤S ∧ (d:ℝ)≤S ∧ (C:ℝ)≤S ∧ (r:ℝ)+2≤S ∧ c≤S ∧ c⁻¹≤S ∧ ε⁻¹≤S ∧
      Real.log (1/δ)≤S := by
  have hci:0≤c⁻¹:=inv_nonneg.mpr hc.le
  have hei:0≤ε⁻¹:=inv_nonneg.mpr hε.le
  have hl:0≤Real.log (1/δ):=Real.log_nonneg ((le_div_iff₀ hδ).mpr (by linarith))
  have hd:0≤(d:ℝ):=Nat.cast_nonneg d
  have hC:0≤(C:ℝ):=Nat.cast_nonneg C
  have hr:0≤(r:ℝ):=Nat.cast_nonneg r
  dsimp [problemSize]
  constructor <;> try linarith
  constructor <;> try linarith
  constructor <;> try linarith
  constructor <;> try linarith
  constructor <;> try linarith
  constructor <;> try linarith
  exact ⟨by linarith,by linarith⟩

theorem universal_polynomial_depth_learning:
    ∃A:ℝ,0<A ∧ ∀(d C r:ℕ),0<d→0<C→∀B:LayeredBooleanCircuit d C r,
      ∀c ε δ:ℝ,0<c→0<ε→ε≤1→0<δ→δ≤1→
      ∀D:Measure (Cube d),IsProbabilityMeasure D→∀n:ℕ,
      A*(problemSize d C r c ε δ)^46≤(n:ℝ)→
      ∃E:Set (Fin n→Cube d),MeasurableSet E ∧
        1-δ≤(CompressionSampling.iidSamples D n).real E ∧
        ∀sample∈E,∀N,C≤N→∀σ,0<σ→(N:ℝ)*σ^2≤1→
          0<(smallPrior d N r σ).real (robustPosteriorEvent Real.tanh c B.computes sample) ∧
          gibbsMarginRisk D (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4)≤ε/3 ∧
          D.real {x|correctConfidence (robustPosterior (N:=N) (r:=r) Real.tanh c σ B.computes sample)
            (fun x=>labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x≤(2/3:ℝ)}≤ε := by
  obtain ⟨K,hK,hent⟩:=entropy_global_polynomial
  refine ⟨200*(K+1),by positivity,?_⟩
  intro d C r hd hC B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI:IsProbabilityMeasure D:=hD
  let S:=problemSize d C r c ε δ
  obtain ⟨hS,hds,hCs,hrs,hcs,hcis,hεs,hδs⟩:=problemSize_bounds d C r hc hε hδ hδ1
  have hS0:0<S:=by dsimp [S];linarith
  have hn0:0<n:=by
    have hh:0<(n:ℝ):=lt_of_lt_of_le (by positivity : 0<200*(K+1)*S^46) hn
    exact_mod_cast hh
  have he:=hent d C r hC c ε S hc hε hε1 hS hds hCs hrs hcs hcis hεs
  have hS45:S≤S^45:=by simpa using pow_le_pow_right₀ (by linarith : 1≤S) (show 1≤45 by omega)
  have hnum:entropy d C r c ε+Real.log (1/δ)≤(K+1)*S^45:=by nlinarith
  have hεS:1≤ε*S:=by
    have hh:=mul_le_mul_of_nonneg_left hεs hε.le
    rw [mul_inv_cancel₀ hε.ne'] at hh
    exact hh
  have hmul:=mul_le_mul_of_nonneg_left hεS (show 0≤200*(K+1)*S^45 by positivity)
  have hnε:=mul_le_mul_of_nonneg_right hn hε.le
  have hpow:200*(K+1)*S^45*(ε*S)=200*(K+1)*S^46*ε:=by ring
  rw [hpow] at hmul
  have hbudget:200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε:=by
    nlinarith
  exact learning_scaled_variance hd hC B hc hε hε1 hδ D n hn0 hbudget

theorem universal_sample_budget:
    ∃A:ℝ,0<A ∧ ∀(d C r:ℕ),0<C→∀c ε δ:ℝ,0<c→0<ε→ε≤1→0<δ→δ≤1→∀n:ℕ,
      A*(problemSize d C r c ε δ)^46≤(n:ℝ)→
      0<n ∧ 200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε := by
  obtain ⟨K,hK,hent⟩:=entropy_global_polynomial
  refine ⟨200*(K+1),by positivity,?_⟩
  intro d C r hC c ε δ hc hε hε1 hδ hδ1 n hn
  let S:=problemSize d C r c ε δ
  obtain ⟨hS,hds,hCs,hrs,hcs,hcis,hεs,hδs⟩:=problemSize_bounds d C r hc hε hδ hδ1
  have hS0:0<S:=by dsimp [S];linarith
  have hn0:0<n:=by
    have hh:0<(n:ℝ):=lt_of_lt_of_le (by positivity : 0<200*(K+1)*S^46) hn
    exact_mod_cast hh
  have he:=hent d C r hC c ε S hc hε hε1 hS hds hCs hrs hcs hcis hεs
  have hS45:S≤S^45:=by simpa using pow_le_pow_right₀ (by linarith : 1≤S) (show 1≤45 by omega)
  have hnum:entropy d C r c ε+Real.log (1/δ)≤(K+1)*S^45:=by nlinarith
  have hεS:1≤ε*S:=by
    have hh:=mul_le_mul_of_nonneg_left hεs hε.le
    rw [mul_inv_cancel₀ hε.ne'] at hh
    exact hh
  have hmul:=mul_le_mul_of_nonneg_left hεS (show 0≤200*(K+1)*S^45 by positivity)
  have hnε:=mul_le_mul_of_nonneg_right hn hε.le
  have hpow:200*(K+1)*S^45*(ε*S)=200*(K+1)*S^46*ε:=by ring
  rw [hpow] at hmul
  have hbudget:200*(entropy d C r c ε+Real.log (1/δ))≤(n:ℝ)*ε:=by
    nlinarith
  exact ⟨hn0,hbudget⟩


end NeuralGeneralization.BatchTwoImprovedLearning
