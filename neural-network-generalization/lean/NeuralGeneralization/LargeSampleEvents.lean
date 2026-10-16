import NeuralGeneralization.AdaptiveNeuralGramProbability
import NeuralGeneralization.AdaptiveNormalizedWeights

/-! Simultaneous actual coercivity and tail-Gram sample events.  The single
constant and the dimension threshold are uniform over all adaptive cutoffs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.AdaptiveCutoff
open ConcreteModel SmallSampleCutoff
open Classical
attribute [local instance] Classical.propDecidable

def adaptiveLowBand (d r : ℕ) : Finset (Finset (Fin d)) :=
  Finset.univ.filter (fun S=>S.card≤r)

lemma mem_adaptiveLowBand {d r : ℕ} (S : Finset (Fin d)) :
    S∈adaptiveLowBand d r ↔ S.card≤r := by simp [adaptiveLowBand]

lemma complement_adaptiveLowBand (d r : ℕ) :
    Finset.univ \ adaptiveLowBand d r = Finset.univ.filter (fun S : Finset (Fin d)=>r+1≤S.card) := by
  ext S
  simp only [Finset.mem_sdiff,Finset.mem_univ,mem_adaptiveLowBand,Finset.mem_filter,true_and]
  omega

lemma adaptive_tail_kernel (d k r : ℕ) (x y : ClippingCube d) :
    walshTailKernel (Finset.univ \ adaptiveLowBand d r)
      (walshCoefficients (arcsineProfile d (k+1))) x y =
      arcsineTailCovariance d (k+1) (r+1) x y := by
  rw [complement_adaptiveLowBand]
  simp only [walshTailKernel,Finset.sum_filter,arcsineTailCovariance,walshKernel,featureKernel]
  apply Finset.sum_congr rfl
  intro S _
  by_cases h : r+1≤S.card <;> simp [h]

lemma adaptive_tail_trace (d k r : ℕ) :
    (∑ S∈Finset.univ \ adaptiveLowBand d r,walshCoefficients (arcsineProfile d (k+1)) S)=
      walshSpectralTail (arcsineProfile d (k+1)) (r+1) := by
  rw [complement_adaptiveLowBand]
  rfl

def normalizedGram (C : ℝ) (d k r n : ℕ) : ℝ :=
  C*(r:ℝ)^(-(1/(2:ℝ)^(k+1)))*
    (1+Real.sqrt ((d:ℝ)*Real.log (8*(n:ℝ)))/(r:ℝ)+Real.log (8*(n:ℝ))/(r:ℝ))

lemma normalizedGram_nonneg {C : ℝ} (hC : 0≤C) (d k r : ℕ) {n : ℕ} (hn : 0<n) :
    0≤normalizedGram C d k r n := by
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn)
  unfold normalizedGram
  positivity

lemma normalizedGram_mono {C C' : ℝ} (hCC : C≤C') (d k r : ℕ) {n : ℕ} (hn : 0<n) :
    normalizedGram C d k r n≤normalizedGram C' d k r n := by
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn)
  unfold normalizedGram
  gcongr

structure LargeSampleGood (d k r n : ℕ) (G : ℝ) (s : Fin n → ClippingCube d) : Prop where
  coercivity : ∀ c : Finset (Fin d)→ℝ, (∀ S,c S≠0→S∈adaptiveLowBand d r) →
    (1/4:ℝ)*uniformCubeMean (fun x=>walshExpansion c x^2) ≤
      (∑ j,(max 0 (-(fullParity (s j)*walshExpansion c (s j))))^2)/(n:ℝ)
  gram : ∀ z : Fin n→ℝ,
    finiteQuadratic (fun i j=>walshTailKernel (Finset.univ \ adaptiveLowBand d r)
      (walshCoefficients (arcsineProfile d (k+1))) (s i) (s j)) z ≤ G*(∑i,z i^2)

lemma LargeSampleGood.mono {d k r n : ℕ} {G G' : ℝ} {s : Fin n→ClippingCube d}
    (h : LargeSampleGood d k r n G s) (hGG : G≤G') : LargeSampleGood d k r n G' s := by
  refine ⟨h.coercivity,?_⟩
  intro z
  exact (h.gram z).trans (mul_le_mul_of_nonneg_right hGG
    (Finset.sum_nonneg (fun _ _=>sq_nonneg _)))

lemma sampleProbability_inter_lower {d n : ℕ} (D : InputLaw d)
    (E F : (Fin n→Cube d)→Prop) :
    sampleProbability D n E+sampleProbability D n F-1≤
      sampleProbability D n (fun s=>E s∧F s) := by
  have hp (s : Fin n→Cube d) :
      (if E s then ∏i,D.mass (s i) else 0)+(if F s then ∏i,D.mass (s i) else 0)≤
        (if E s∧F s then ∏i,D.mass (s i) else 0)+(∏i,D.mass (s i)) := by
    have hw : 0≤∏i,D.mass (s i) := Finset.prod_nonneg (fun _ _=>D.nonneg _)
    by_cases he : E s <;> by_cases hf : F s <;> simp only [he,hf,if_true,if_false,and_self,
      false_and,and_false,true_and,true_and,add_zero,zero_add] <;> linarith only [hw]
  have hh := Finset.sum_le_sum (fun s (_ : s∈Finset.univ)=>hp s)
  simp only [Finset.sum_add_distrib] at hh
  have hw : (∑s : Fin n→Cube d, ∏i,D.mass (s i))=1 := by
    simpa only [sampleProbability,if_true] using sampleProbability_true D n
  rw [hw] at hh
  have hs : (∑s : Fin n→Cube d,if E s∧F s then ∏i,D.mass (s i) else 0)=
      sampleProbability D n (fun s=>E s∧F s) := by
    unfold sampleProbability
    apply Finset.sum_congr rfl
    intro s _
    by_cases h : E s∧F s <;> simp [h]
  rw [hs] at hh
  change sampleProbability D n E+sampleProbability D n F≤
    sampleProbability D n (fun s=>E s∧F s)+1 at hh
  linarith only [hh]

/-- Both sample events hold with probability at least seven eighths for the
actual kernel and actual low-degree polynomial class, throughout the range
required by the adaptive construction. -/
theorem eventually_largeSampleGood_probability (k : ℕ) (A : ℝ) (hA : 0≤A) :
    ∃ C : ℝ,1≤C ∧ ∀ᶠ d : ℕ in atTop,∀ n r : ℕ,∀ ε : ℝ,
      4≤n →(n:ℝ)≤Real.exp ((d:ℝ)/128) →LargeCutoff d n A ε r →
      7/8≤sampleProbability (uniformLaw d) n
        (LargeSampleGood d k r n (normalizedGram C d k r n)) := by
  obtain ⟨C,hC,hprob⟩ := actual_adaptive_gram_probability k A hA
  refine ⟨C,hC,?_⟩
  filter_upwards [hprob] with d hprob n r ε hn hnmax hcut
  have hn0 : 0<n := by omega
  have hd : 0<d := by have := hcut.degree_le; omega
  have hdim : 131072*(r+1)≤d := by have := hcut.degree_le; omega
  have hnext := next_threshold_binomial hA hn0 (by omega : 3*(r+2)≤d) hcut.next_threshold
  have hg := hprob r n hcut.positive hcut.odd hdim hcut.large hn hnmax hnext
  have hc := parity_squared_coercivity_probability hd (by omega : 64*r≤d) hn0 hcut.sampling
  have hj := sampleProbability_inter_lower (uniformLaw d)
    (fun s : Fin n→Cube d=>∀ c : Finset (Fin d)→ℝ,(∀ S,c S≠0→S.card≤r)→
      (1/4:ℝ)*uniformCubeMean (fun x=>walshExpansion c x^2)≤
        (∑i,(max 0 (-fullParity (s i)*walshExpansion c (s i)))^2)/(n:ℝ))
    (fun s : Fin n→Cube d=>∀ z : Fin n→ℝ,
      finiteQuadratic (fun i j=>arcsineTailCovariance d (k+1) (r+1) (s i) (s j)) z≤
        normalizedGram C d k r n*(∑i,z i^2))
  have hl : (7:ℝ)/8≤sampleProbability (uniformLaw d) n (fun s=>
      (∀ c : Finset (Fin d)→ℝ,(∀ S,c S≠0→S.card≤r)→
        (1/4:ℝ)*uniformCubeMean (fun x=>walshExpansion c x^2)≤
          (∑i,(max 0 (-fullParity (s i)*walshExpansion c (s i)))^2)/(n:ℝ)) ∧
      (∀ z : Fin n→ℝ,finiteQuadratic (fun i j=>arcsineTailCovariance d (k+1) (r+1) (s i) (s j)) z≤
        normalizedGram C d k r n*(∑i,z i^2))) := by
    change 15/16≤sampleProbability (uniformLaw d) n (fun s=>∀ z : Fin n→ℝ,
      finiteQuadratic (fun i j=>arcsineTailCovariance d (k+1) (r+1) (s i) (s j)) z≤
        normalizedGram C d k r n*(∑i,z i^2)) at hg
    linarith only [hj,hc,hg]
  apply hl.trans
  apply sampleProbability_mono
  intro s hs
  refine ⟨?_,?_⟩
  · intro c hc
    simpa only [neg_mul] using hs.1 c (fun S hS=>(mem_adaptiveLowBand S).mp (hc S hS))
  · intro z
    simpa only [adaptive_tail_kernel] using hs.2 z

end NeuralGeneralization.AdaptiveCutoff
