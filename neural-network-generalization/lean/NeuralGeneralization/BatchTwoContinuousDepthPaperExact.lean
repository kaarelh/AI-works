import NeuralGeneralization.BatchTwoContinuousDepthPaperMemorizer
import NeuralGeneralization.BatchTwoContinuousDepthSmoothIterated

/-! Literal Lambda_n ceilings for the fixed and smooth circle laws. The full
exact-minimizer and actual iterated-limit statements share one sample event. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

theorem memorizerWidth_two (n : ℕ) : memorizerWidth 2 n (sampleSeparation n)=interpolationWidth n := by
  norm_num [memorizerWidth,interpolationWidth]

def sampleResource (n : ℕ) : ℝ := 4*(interpolationWidth n : ℝ)*(n : ℝ)

theorem sampleResource_ge_one {n : ℕ} (hn : 0<n) : 1 ≤ sampleResource n := by
  have hM := (memorizerWidth_ge 2 n (sampleSeparation n)).1
  rw [memorizerWidth_two] at hM
  have hnR : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hMR : (n : ℝ) ≤ interpolationWidth n := by exact_mod_cast hM
  unfold sampleResource
  nlinarith

theorem separated_paper_memorizer {r n N : ℕ} (hn : 0<n) (hN : interpolationWidth n ≤ N)
    (s : Fin n → RealInput 2) (hs : ∀ i, |s i 0| ≤ 1)
    (hy : ∀ i, |depthTarget (r+2) (s i)| ≤ 13/20) (hsep : s ∈ separatedSample n) :
    ∃ v : Weights 2 N (r+1), (∀ i,output Real.tanh v (s i)=depthTarget (r+2) (s i)) ∧
      (∀ x : RealInput 2, |output Real.tanh v x| ≤ 1) ∧
      weightedSquaredNorm v ≤ energyBudget (r+3) (sampleResource n) := by
  let u : Fin 2 → ℝ := ![1,0]
  have hM := memorizerWidth_ge 2 n (sampleSeparation n)
  rw [memorizerWidth_two] at hM
  apply exists_paper_memorizer (k:=r) hn hM.1 hN (sampleSeparation_pos hn) u
    (by norm_num [u,Fin.sum_univ_two]) s (fun i => depthTarget (r+2) (s i)) _ _
    (fun i => (hy i).trans (by norm_num)) hM.2
  · intro i
    simpa [u,Fin.sum_univ_two] using hs i
  · intro i j hij
    simpa [u,Fin.sum_univ_two] using hsep i j hij

theorem separated_minimizer_paper_ceiling {r n N : ℕ} (hn : 0<n) (hN : interpolationWidth n ≤ N)
    (s : Fin n → RealInput 2) (hs : ∀ i, |s i 0| ≤ 1)
    (hy : ∀ i, |depthTarget (r+2) (s i)| ≤ 13/20) (hsep : s ∈ separatedSample n) :
    ∀ w ∈ energyMinimizers (N:=N) (r:=r+1) Real.tanh (depthTarget (r+2)) s,
      outputLipschitz (lipschitzCeiling 2 (sampleResource n)) w := by
  obtain ⟨v,hv,_,hcost⟩ := separated_paper_memorizer hn hN s hs hy hsep
  have hNpos : 0<N := by have := (interpolationWidth_ge hn).1; omega
  intro w hw x y
  apply energyMinimizer_output_lipschitz (by norm_num) hNpos (by omega)
    (sampleResource_ge_one hn) _ s v hv _ w hw x y
  simpa only [Nat.add_assoc] using hcost

def FullExactStatement (D : Measure (RealInput 2)) (r n N : ℕ) (s : Fin n → RealInput 2) : Prop :=
  (energyMinimizers (N:=N) (r:=r+1) Real.tanh (depthTarget (r+2)) s).Nonempty ∧
  (∀ w ∈ energyMinimizers (N:=N) (r:=r+1) Real.tanh (depthTarget (r+2)) s,
    outputLipschitz (lipschitzCeiling 2 (sampleResource n)) w) ∧
  (∀ Q : Measure (Weights 2 N (r+1)), IsProbabilityMeasure Q →
    (∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) →
    (1/2 : ℝ) ≤ risk Real.tanh D Q (depthTarget (r+2)) (1/4) ∧
    (1/2 : ℝ) ≤ D.real {x | correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 1/2})

theorem measurable_separation_event {n : ℕ} (μ : Measure (Fin n → RealInput 2))
    [IsProbabilityMeasure μ] (hsep : (49/50 : ℝ) ≤ μ.real (separatedSample n))
    (P : (Fin n → RealInput 2) → Prop) (hP : ∀ᵐ s ∂μ, s ∈ separatedSample n → P s) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧ (49/50 : ℝ) ≤ μ.real G ∧ ∀ s∈G,P s := by
  let A := {s | s ∈ separatedSample n → P s}
  have hnull : μ Aᶜ = 0 := ae_iff.mp hP
  let B := toMeasurable μ Aᶜ
  have hB : MeasurableSet B := measurableSet_toMeasurable μ _
  have hnullB : μ B=0 := by simpa only [B,measure_toMeasurable] using hnull
  let G := separatedSample n ∩ Bᶜ
  refine ⟨G,(separatedSample_measurable n).inter hB.compl,?_,?_⟩
  · apply hsep.trans
    apply ENNReal.toReal_mono (measure_ne_top μ G)
    apply measure_mono_ae
    filter_upwards [measure_eq_zero_iff_ae_notMem.mp hnullB] with s hs
    exact fun h => ⟨h,hs⟩
  · intro s hs
    have hsA : s ∈ A := by
      by_contra hh
      exact hs.2 (subset_toMeasurable μ Aᶜ hh)
    exact hsA hs.1

/-- All pieces of cor:exact, including its literal Lambda_n, now hold
simultaneously on one measurable 49/50 event for the fixed distribution. -/
theorem fixed_full_exact_event {r n : ℕ} (hr : max 6 interpolationDepthThreshold ≤ r)
    (hn : 0<n) (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧
      (49/50 : ℝ) ≤ (Measure.pi (fun _ : Fin n => inputLaw)).real G ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N → FullExactStatement inputLaw r n N s := by
  apply measurable_separation_event _ (separatedSample_probability hn)
  have hwidth (N : ℕ) : ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => inputLaw)),
      s∈separatedSample n → interpolationWidth n ≤ N → FullExactStatement inputLaw r n N s := by
    by_cases hN : interpolationWidth n ≤ N
    · filter_upwards [iid_sample_bounds (r+2) n,separated_sample_exact_minimizers hr hn hnr hN] with s hs hm
      intro hsep _
      exact ⟨(hm hsep).1,separated_minimizer_paper_ceiling hn hN s hs.1 hs.2 hsep,(hm hsep).2.2⟩
    · exact Eventually.of_forall (fun _ _ hh => (hN hh).elim)
  filter_upwards [ae_all_iff.mpr hwidth] with s hs hsep
  exact fun N hN => hs N hsep hN

/-- The same literal exact-minimizer ceiling and failure conclusions for D_r. -/
theorem smooth_full_exact_event {r n : ℕ} (hr : max 6 interpolationDepthThreshold ≤ r)
    (hn : 0<n) (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧
      (49/50 : ℝ) ≤ (Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))).real G ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N → FullExactStatement (smoothInputLaw (r+2)) r n N s := by
  apply measurable_separation_event _ (jittered_separatedSample_probability (r+2) (smoothJitterLaw (r+2)) hn)
  have hwidth (N : ℕ) : ∀ᵐ s ∂(Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))),
      s∈separatedSample n → interpolationWidth n ≤ N → FullExactStatement (smoothInputLaw (r+2)) r n N s := by
    by_cases hN : interpolationWidth n ≤ N
    · filter_upwards [smooth_iid_sample_bounds (r+2) n,smooth_separated_sample_exact_minimizers hr hn hnr hN] with s hs hm
      intro hsep _
      exact ⟨(hm hsep).1,separated_minimizer_paper_ceiling hn hN s hs.1 hs.2 hsep,(hm hsep).2.2⟩
    · exact Eventually.of_forall (fun _ _ hh => (hN hh).elim)
  filter_upwards [ae_all_iff.mpr hwidth] with s hs hsep
  exact fun N hN => hs N hsep hN


def FullIteratedStatement (D : Measure (RealInput 2)) (r n N : ℕ) (s : Fin n → RealInput 2) : Prop :=
  (∃ Q : ProbabilityMeasure (Weights 2 N (r+1)), IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q) ∧
  (∀ Q : ProbabilityMeasure (Weights 2 N (r+1)), IsIteratedLimit Real.tanh (depthTarget (r+2)) s Q →
    (∀ᵐ w ∂(Q : Measure (Weights 2 N (r+1))), w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) ∧
    (∀ᵐ w ∂(Q : Measure (Weights 2 N (r+1))), outputLipschitz (lipschitzCeiling 2 (sampleResource n)) w) ∧
    (1/2 : ℝ) ≤ risk Real.tanh D (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4) ∧
    (1/2 : ℝ) ≤ D.real {x | correctProbability Real.tanh
      (Q : Measure (Weights 2 N (r+1))) (depthTarget (r+2)) (1/4) x ≤ 1/2})

theorem full_exact_implies_iterated {r n N : ℕ} (hN : 0<N) (D : Measure (RealInput 2))
    (s : Fin n → RealInput 2) (hfull : FullExactStatement D r n N s) :
    FullIteratedStatement D r n N s := by
  have hne : (exactInterpolants (N:=N) (r:=r+1) Real.tanh (depthTarget (r+2)) s).Nonempty :=
    hfull.1.mono (fun _ hw => hw.1)
  refine ⟨iteratedLimit_exists (by norm_num) hN tanh_continuous _ _ hne,?_⟩
  intro Q hQ
  have hsupport := iteratedLimit_support_minimizers (by norm_num) hN tanh_continuous _ _ hne Q hQ
  refine ⟨hsupport,?_,hfull.2.2 (Q : Measure (Weights 2 N (r+1))) inferInstance hsupport⟩
  filter_upwards [hsupport] with w hw
  exact hfull.2.1 w hw

/-- Full literal cor:exact, for the fixed law, on one measurable all-width event. -/
theorem fixed_full_exact_and_iterated {r n : ℕ} (hr : max 6 interpolationDepthThreshold ≤ r)
    (hn : 0<n) (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧
      (49/50 : ℝ) ≤ (Measure.pi (fun _ : Fin n => inputLaw)).real G ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N →
        FullExactStatement inputLaw r n N s ∧ FullIteratedStatement inputLaw r n N s := by
  obtain ⟨G,hG,hprob,hg⟩ := fixed_full_exact_event hr hn hnr
  refine ⟨G,hG,hprob,?_⟩
  intro s hs N hN
  have hNpos : 0<N := by have := (interpolationWidth_ge hn).1; omega
  exact ⟨hg s hs N hN,full_exact_implies_iterated hNpos _ s (hg s hs N hN)⟩

/-- Full literal cor:exact for the smooth law, completing this quantitative
part of the smooth-distribution corollary. -/
theorem smooth_full_exact_and_iterated {r n : ℕ} (hr : max 6 interpolationDepthThreshold ≤ r)
    (hn : 0<n) (hnr : (n : ℝ) ≤ Real.exp (((r : ℝ)+2)/100)) :
    ∃ G : Set (Fin n → RealInput 2), MeasurableSet G ∧
      (49/50 : ℝ) ≤ (Measure.pi (fun _ : Fin n => smoothInputLaw (r+2))).real G ∧
      ∀ s∈G, ∀ N : ℕ, interpolationWidth n ≤ N →
        FullExactStatement (smoothInputLaw (r+2)) r n N s ∧
        FullIteratedStatement (smoothInputLaw (r+2)) r n N s := by
  obtain ⟨G,hG,hprob,hg⟩ := smooth_full_exact_event hr hn hnr
  refine ⟨G,hG,hprob,?_⟩
  intro s hs N hN
  have hNpos : 0<N := by have := (interpolationWidth_ge hn).1; omega
  exact ⟨hg s hs N hN,full_exact_implies_iterated hNpos _ s (hg s hs N hN)⟩


theorem full_exact_individual_error {r n N : ℕ} (D : Measure (RealInput 2)) [IsProbabilityMeasure D]
    (s : Fin n → RealInput 2) (hfull : FullExactStatement D r n N s)
    (w : Weights 2 N (r+1)) (hw : w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) :
    (1/2 : ℝ) ≤ D.real {x | (1/4 : ℝ) < |output Real.tanh w x-depthTarget (r+2) x|} := by
  have h := (hfull.2.2 (Measure.dirac w) inferInstance (by simpa [ae_dirac_eq] using hw)).1
  have hid : risk Real.tanh D (Measure.dirac w) (depthTarget (r+2)) (1/4) =
      D.real {x | (1/4 : ℝ) < |output Real.tanh w x-depthTarget (r+2) x|} := by
    unfold risk
    rw [Measure.prod_dirac]
    rw [map_measureReal_apply (show Measurable (fun x : RealInput 2 => (x,w)) by fun_prop)
      (measurable_jointErrorEvent (f:=depthTarget (r+2)) tanh_continuous
        (show Measurable (depthTarget (r+2)) from (continuous_target (r+2)).measurable) (1/4))]
    rfl
  rwa [hid] at h

theorem full_exact_confidence_two_thirds {r n N : ℕ} (D : Measure (RealInput 2)) [IsProbabilityMeasure D]
    (s : Fin n → RealInput 2) (hfull : FullExactStatement D r n N s)
    (Q : Measure (Weights 2 N (r+1))) [IsProbabilityMeasure Q]
    (hQ : ∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh (depthTarget (r+2)) s) :
    (1/2 : ℝ) ≤ BatchTwoContinuous.confidenceFailure Real.tanh D Q (depthTarget (r+2)) (1/4) := by
  apply (hfull.2.2 Q inferInstance hQ).2.trans
  unfold BatchTwoContinuous.confidenceFailure
  have hsub : {x | correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 1/2} ⊆
      {x | correctProbability Real.tanh Q (depthTarget (r+2)) (1/4) x ≤ 2/3} := by
    intro x hx
    exact le_trans hx (by norm_num : (1/2 : ℝ) ≤ 2/3)
  exact measureReal_mono hsub (measure_ne_top D _)

/-- The literal depth-independent strong-prior ceiling at every separated,
bounded sample, for every positive training tolerance. -/
theorem separated_posterior_paper_ceiling {r n N : ℕ} (hn : 0<n) (hN : interpolationWidth n ≤ N)
    (s : Fin n → RealInput 2) (hs : ∀ i, |s i 0| ≤ 1)
    (hy : ∀ i, |depthTarget (r+2) (s i)| ≤ 13/20) (hsep : s ∈ separatedSample n)
    {ρ : ℝ} (hρ : 0<ρ) :
    Tendsto (fun σ => (BatchTwoContinuous.posterior Real.tanh (smallPrior 2 N (r+1) σ)
      (depthTarget (r+2)) ρ s).real {w | ¬ outputLipschitz (lipschitzCeiling 2 (sampleResource n)) w})
      (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  obtain ⟨v,hv,_,hcost⟩ := separated_paper_memorizer hn hN s hs hy hsep
  have hNpos : 0<N := by have := (interpolationWidth_ge hn).1; omega
  apply posterior_lipschitz_ceiling_tendsto_zero (by norm_num) hNpos (by omega)
    (sampleResource_ge_one hn) _ s hρ v hv
  simpa only [Nat.add_assoc] using hcost

end NeuralGeneralization.BatchTwoContinuousDepthPaper
