import NeuralGeneralization.TiltedRowSampling

/-! Covariance sampling for arbitrary bounded features, with explicit scale.
Both sampling assertions use the actual IID measure. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoActivation
open CompressionSampling TiltedRowSampling
variable {Ω I : Type*} [MeasurableSpace Ω] [Fintype I]

def empiricalCovariance (h : Ω→I→ℝ) {N : ℕ} (w : Fin N→Ω) (p q : I) : ℝ :=
  (∑i,h (w i) p*h (w i) q)/(N:ℝ)

def covarianceMean (ν : Measure Ω) (h : Ω→I→ℝ) (p q : I) : ℝ := ∫z,h z p*h z q ∂ν

theorem covariance_normalization (ν : Measure Ω) (h : Ω→I→ℝ) (B : ℝ) {N : ℕ}
    (w : Fin N→Ω) (p q : I) :
    empiricalCovariance (fun z i=>h z i/B) w p q-covarianceMean ν (fun z i=>h z i/B) p q=
      (empiricalCovariance h w p q-covarianceMean ν h p q)/B^2 := by
  have he (z : Ω) : h z p/B*(h z q/B)=(h z p*h z q)/B^2 := by ring
  simp only [empiricalCovariance,covarianceMean,he,←Finset.sum_div,integral_div]
  ring

theorem scaled_covariance_sampling_tail (ν : Measure Ω) [IsProbabilityMeasure ν]
    (h : Ω→I→ℝ) (hh : ∀i,Measurable (fun z=>h z i)) {B ε : ℝ} (hB : 0<B)
    (hbound : ∀z i,|h z i|≤B) {N : ℕ} (hN : 0<N) (hε : 0≤ε) :
    (iidSamples ν N).real {w | ∃p q,ε≤|empiricalCovariance h w p q-covarianceMean ν h p q|}≤
      2*(Fintype.card I:ℝ)^2*Real.exp (-(N:ℝ)*(ε/B^2)^2/2) := by
  have hn : ∀z i,|h z i/B|≤1 := fun z i=>by
    rw [abs_div,abs_of_pos hB]
    exact (div_le_one hB).2 (hbound z i)
  have hs := covariance_sampling_tail ν (fun z i=>h z i/B) (fun i=>(hh i).div_const B) hn hN
    (div_nonneg hε (sq_nonneg B))
  have he : {w : Fin N→Ω | ∃p q,ε/B^2≤|empiricalCovariance (fun z i=>h z i/B) w p q-
      covarianceMean ν (fun z i=>h z i/B) p q|}=
      {w | ∃p q,ε≤|empiricalCovariance h w p q-covarianceMean ν h p q|} := by
    ext w
    simp only [Set.mem_setOf_eq,covariance_normalization,abs_div,abs_of_pos (sq_pos_of_pos hB),
      div_le_div_iff_of_pos_right (sq_pos_of_pos hB)]
  change (iidSamples ν N).real {w | ∃p q,ε/B^2≤|empiricalCovariance (fun z i=>h z i/B) w p q-
    covarianceMean ν (fun z i=>h z i/B) p q|}≤_ at hs
  rwa [he] at hs

/-- A strict union bound selects actual bounded-feature sample rows. -/
theorem exists_covariance_sample (ν : Measure Ω) [IsProbabilityMeasure ν]
    (h : Ω→I→ℝ) (hh : ∀i,Measurable (fun z=>h z i)) {B ε : ℝ} (hB : 0<B)
    (hbound : ∀z i,|h z i|≤B) {N : ℕ} (hN : 0<N) (hε : 0≤ε)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(N:ℝ)*(ε/B^2)^2/2)<1) :
    ∃w:Fin N→Ω, ∀p q,|empiricalCovariance h w p q-covarianceMean ν h p q|<ε := by
  have ht := scaled_covariance_sampling_tail ν h hh hB hbound hN hε
  by_contra hnone
  have he : {w : Fin N→Ω | ∃p q,ε≤|empiricalCovariance h w p q-covarianceMean ν h p q|}=Set.univ := by
    ext w
    simp only [Set.mem_setOf_eq,Set.mem_univ,iff_true]
    by_contra hn
    apply hnone
    refine ⟨w,fun p q=>lt_of_not_ge (fun hpq=>hn ⟨p,q,hpq⟩)⟩
  rw [he,probReal_univ] at ht
  linarith

/-- Under a bounded Gaussian tilt, choose rows with both bounded source
coordinates and accurate empirical covariance. -/
theorem exists_bounded_source_covariance_sample {J : Type*} [Fintype J] [DecidableEq J]
    (V : (J→ℝ)→ℝ) (hV : Measurable V) {G : ℝ} (hVbound : ∀z,|V z|≤G)
    (h : (J→ℝ)→I→ℝ) (hh : ∀i,Measurable (fun z=>h z i)) {B ε R : ℝ}
    (hB : 0<B) (hbound : ∀z i,|h z i|≤B) {N : ℕ} (hN : 0<N)
    (hε : 0≤ε) (hR : 0≤R)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(N:ℝ)*(ε/B^2)^2/2)+
      2*(N:ℝ)*(Fintype.card J:ℝ)*Real.exp (2*G-R^2/2)<1) :
    ∃w:Fin N→J→ℝ, (∀i j,|w i j|<R) ∧ ∀p q,
      |empiricalCovariance h w p q-
        covarianceMean ((Measure.pi fun _ : J=>gaussianReal 0 1).tilted V) h p q|<ε := by
  have hn : ∀z i,|h z i/B|≤1 := fun z i=>by
    rw [abs_div,abs_of_pos hB]
    exact (div_le_one hB).2 (hbound z i)
  obtain ⟨w,hw,hcov⟩ := exists_bounded_covariance_rows (fun _ : J=>(1:ℝ≥0)) (by simp)
    V hV hVbound (fun z i=>h z i/B) (fun i=>(hh i).div_const B) hn hN
    (div_nonneg hε (sq_nonneg B)) hR hbudget
  refine ⟨w,hw,?_⟩
  intro p q
  have hq := hcov p q
  change |empiricalCovariance (fun z i=>h z i/B) w p q-
    covarianceMean ((Measure.pi fun _ : J=>gaussianReal 0 1).tilted V) (fun z i=>h z i/B) p q|<ε/B^2 at hq
  rw [covariance_normalization,abs_div,abs_of_pos (sq_pos_of_pos hB)] at hq
  exact (div_lt_div_iff_of_pos_right (sq_pos_of_pos hB)).1 hq

end NeuralGeneralization.BatchTwoActivation
