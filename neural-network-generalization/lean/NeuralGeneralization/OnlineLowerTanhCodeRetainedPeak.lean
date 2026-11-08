import NeuralGeneralization.OnlineLowerTanhCodeEnvelopePeak
import NeuralGeneralization.OnlineLowerTanhCodeEnvelope
import NeuralGeneralization.OnlineLowerTanhCodePhysicalDominant

/-! # A uniform actual retained-transversal resonance -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

/-- Physical peak extraction. All integral, finite-product and coordinate
bounds are proved for the literal neuron weights; only the quantitative
energy cap and positive retained mass remain as inputs. -/
theorem exists_physical_retained_peak_parameters (M β : ℝ) (hM : 0<M) (hβ : 0<β) :
    ∃h T μ : ℝ,0<h ∧ h≤1 ∧ 1≤T ∧ 0<μ ∧ μ≤1/4 ∧
      ∀p r : ℕ,2≤p → 1≤r → 6≤p*(2*r) →
      ∀size : Fin p→Bool→ℕ,∀hR : ∀i s,2*r≤size i s,
      (∀i s,Even (size i s)) →
      ∀A : Finset (Fin p→Bool),∀u : Fin (carrierDimension size)→ℝ,
      incomingEnergy u≤(p*(2*r):ℕ)*M^2 →
      β≤Real.sqrt ((p*r:ℕ):ℝ)*(∫t:ℝ in Ioi 0,
        retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) →
      (p:ℝ)*(1/2:ℝ)^(2*r)≤μ/2 →
        ∃t∈Ioc h T,∃θ∈A,μ/2≤|trigProduct (carrierTransversal size θ) (fun j=>t*u j)| := by
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hpeak⟩ := exists_code_envelope_peak_parameters M β hM hβ
  refine ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,?_⟩
  intro p r hp hr hD size hR heven A u henergy hmass hsmall
  let a := trimmedCarrierRailWeights size hR u false
  let b := trimmedCarrierRailWeights size hR u true
  let F := trimmedRailProduct p (2*r) a b
  let H : ℝ→ℝ := fun t=>Real.sqrt (F t)
  let G := retainedCarrierProduct size A u
  have hF0 : ∀t,0≤F t := trimmedRailProduct_nonneg _ _ _ _
  have hF1 : ∀t,F t≤1 := trimmedRailProduct_le_one p (2*r) (by omega) a b
  have hH0 : ∀t,0≤H t := fun t=>Real.sqrt_nonneg _
  have hH1 : ∀t,H t≤1 := fun t=>by simpa only [H,Real.sqrt_one] using Real.sqrt_le_sqrt (hF1 t)
  have hG0 : ∀t,0≤G t := retainedCarrierProduct_nonneg _ _ _
  have hGF : ∀t,G t≤F t := retainedCarrierProduct_le_trimmed size hR A u
  have hGH : ∀t>0,G t≤H t^2 := by
    intro t ht
    simpa only [H,Real.sq_sqrt (hF0 t)] using hGF t
  have he : (∑i:Fin p,∑k:Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*M^2 :=
    (trimmedCarrierRailWeights_energy_le size hR u).trans henergy
  have hHs : ∀t>0,H t≤8*M^3*t^3 := fun t ht=>
    sqrt_trimmedRailProduct_cubic p (2*r) (by omega) (by omega) hD a b t M ht.le hM.le he
  have hInt := retainedCarrierProduct_kernel_integrable size heven A u
  have hLap (c:ℝ) (hc:0<c) := sqrt_trimmedRailProduct_laplace p r hp hr a b c hc
  obtain ⟨t,ht,hGt⟩ := hpeak ((p*r:ℕ):ℝ) (by positivity) H G hH0 hH1 hG0 hGH hHs hInt hLap hmass
  obtain ⟨θ,hθ,hθp⟩ := physical_retained_dominant_peak size (by omega : 0<2*r) hR u t μ hμ A hsmall hGt.le
  exact ⟨t,ht,θ,hθ,hθp⟩

end NeuralGeneralization.OnlineLowerTanh
