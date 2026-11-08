import NeuralGeneralization.OnlineLowerTanhCodeEnvelopeCompact

/-! # Uniform compact peaks for retained code envelopes -/
noncomputable section
open scoped Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem positive_kernel_split (G : ℝ→ℝ)
    (hi : IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (h T : ℝ) (hh : 0≤h) (hhT : h≤T) :
    (∫t:ℝ in Ioi 0,G t/Real.sinh (Real.pi*t/2)) =
      (∫t:ℝ in Ioc 0 h,G t/Real.sinh (Real.pi*t/2))+
      (∫t:ℝ in Ioc h T,G t/Real.sinh (Real.pi*t/2))+
      (∫t:ℝ in Ioi T,G t/Real.sinh (Real.pi*t/2)) := by
  have h1 := intervalIntegral.integral_Ioi_sub_Ioi hi hh
  have h2 := intervalIntegral.integral_Ioi_sub_Ioi (hi.mono_set (Ioi_subset_Ioi hh)) hhT
  rw [intervalIntegral.integral_of_le hh] at h1
  rw [intervalIntegral.integral_of_le hhT] at h2
  linarith

/-- Dimension-independent frequency and height parameters for any actual
positive envelope satisfying the checked Laplace and cubic bounds. -/
theorem exists_code_envelope_peak_parameters (A β : ℝ) (hA : 0<A) (hβ : 0<β) :
    ∃h T μ : ℝ,0<h ∧ h≤1 ∧ 1≤T ∧ 0<μ ∧ μ≤1/4 ∧
      ∀D : ℝ,0≤D → ∀H G : ℝ→ℝ,
        (∀t,0≤H t) → (∀t,H t≤1) → (∀t,0≤G t) →
        (∀t>0,G t≤H t^2) → (∀t>0,H t≤8*A^3*t^3) →
        IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0) →
        (∀c>0,IntegrableOn (fun t=>Real.exp (-c*t)*H t) (Ioi 0) ∧
          Real.sqrt D*(∫t:ℝ in Ioi 0,Real.exp (-c*t)*H t)≤Real.pi/c) →
        β≤Real.sqrt D*(∫t:ℝ in Ioi 0,G t/Real.sinh (Real.pi*t/2)) →
          ∃t∈Ioc h T,μ<G t := by
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hnear,htail,hmid⟩ :=
    exists_peak_parameters (2*A) β (by positivity) hβ
  refine ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,?_⟩
  intro D hD H G hH hH1 hG hGH hsmall hInt hLap hmass
  by_contra hnone
  have hpeak : ∀t∈Ioc h T,G t≤μ := by
    intro t ht
    exact le_of_not_gt (fun hg=>hnone ⟨t,ht,hg⟩)
  have hL1 := hLap 1 (by norm_num)
  have hLπ := hLap (Real.pi/8) (by positivity)
  have h0 := code_envelope_near_zero D hD H G hH hG hGH A hA.le hsmall hInt hL1.1
    (by simpa using hL1.2) h hh hh1
  have h1 := code_envelope_middle D hD H G hH hG hGH hInt hL1.1
    (by simpa using hL1.2) h T μ hh (hh1.trans hT) hμ.le hpeak
  have h2 := code_envelope_tail D hD H G hH hH1 hG hGH hInt hLπ.1 hLπ.2 T hT
  have hsplit := positive_kernel_split G hInt h T hh.le (hh1.trans hT)
  have hscaled := congrArg (fun x:ℝ=>Real.sqrt D*x) hsplit
  have hnpos : 0≤Real.exp 1*A^3*h^2 := by positivity
  have hmpos : 0≤(Real.exp T/h)*Real.sqrt μ := by positivity
  simp only [div_eq_mul_inv] at h0 h1 h2 hnear htail hmid hmpos hscaled hmass
  nlinarith only [h0,h1,h2,hscaled,hmass,hnear,htail,hmid,hnpos,hmpos,hβ]

end NeuralGeneralization.OnlineLowerTanh
