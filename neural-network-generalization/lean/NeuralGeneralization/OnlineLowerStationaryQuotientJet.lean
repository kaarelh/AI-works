import Mathlib.Analysis.Asymptotics.Lemmas
import Mathlib.Analysis.Complex.Basic
import Mathlib.Tactic

/-! # Cancellation of the unknown second-order optimizer displacement

The expansion of a stationary quotient needs only a first-order optimizer
and a quadratic error estimate. The potentially unknown second-order
optimizer coefficient cancels from the value expansion.
-/
noncomputable section
open scoped Topology
open Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

theorem stationary_quotient_jet {α:Type*} (l:Filter α)
    (h δ F:α→ℂ) (a₀ a₁ f₀ f₀' f₀'' f₁ f₁' f₂ p₀ p₁ p₂:ℂ)
    (hh:Tendsto h l (𝓝 0)) (hδ:δ=O[l] h)
    (hδ₁:(fun x=>δ x-a₁*h x)=O[l] (fun x=>h x^2))
    (hF:(fun x=>F x-(f₀+f₀'*δ x+(f₀''/2)*δ x^2+
      (f₁+f₁'*δ x)*h x+f₂*h x^2))=O[l] (fun x=>h x^3))
    (hf₀:f₀≠0)
    (hc₀:p₀*f₀=a₀) (hc₁:p₀*f₀'=1) (hc₂:p₀*f₁+p₁*f₀=0)
    (hc₃:(p₀*f₀''/2)*a₁^2+(p₀*f₁'+p₁*f₀')*a₁+
      p₀*f₂+p₁*f₁+p₂*f₀=0) :
    (fun x=>(a₀+δ x)/F x-(p₀+p₁*h x+p₂*h x^2))=O[l] (fun x=>h x^3) := by
  let P : α→ℂ := fun x=>p₀+p₁*h x+p₂*h x^2
  let Q : α→ℂ := fun x=>f₀+f₀'*δ x+(f₀''/2)*δ x^2+
    (f₁+f₁'*δ x)*h x+f₂*h x^2
  have hself := isBigO_refl h l
  have hhb : h=O[l] (fun _=> (1:ℂ)) := hh.isBigO_one ℂ
  have h2to1 : (fun x=>h x^2)=O[l] h := by
    simpa only [pow_two,mul_one] using hself.mul hhb
  have hd2 : (fun x=>δ x^2)=O[l] (fun x=>h x^2) := hδ.pow 2
  have hdh : (fun x=>δ x*h x)=O[l] (fun x=>h x^2) := by
    simpa only [pow_two] using hδ.mul hself
  have hdiffsq : (fun x=>δ x^2-a₁^2*h x^2)=O[l] (fun x=>h x^3) := by
    have hs := hδ.add (hself.const_mul_left a₁)
    have hp := hδ₁.mul hs
    exact hp.congr (fun x=>by ring) (fun x=>by ring)
  have hdiffh : (fun x=>(δ x-a₁*h x)*h x)=O[l] (fun x=>h x^3) := by
    exact (hδ₁.mul hself).congr (fun x=>rfl) (fun x=>by ring)
  have hbr2 : (fun x=>(f₀''/2)*δ x^2+f₁'*δ x*h x+f₂*h x^2)=O[l] (fun x=>h x^2) := by
    have hmid : (fun x=>f₁'*δ x*h x)=O[l] (fun x=>h x^2) := by
      simpa only [mul_assoc] using hdh.const_mul_left f₁'
    exact ((hd2.const_mul_left (f₀''/2)).add hmid).add ((hself.pow 2).const_mul_left f₂)
  have hbr1 : (fun x=>f₀'*δ x+(f₀''/2)*δ x^2+f₁*h x+f₁'*δ x*h x+f₂*h x^2)=O[l] h := by
    have hmid : (fun x=>f₁'*δ x*h x)=O[l] h := by
      simpa only [mul_assoc] using (hdh.trans h2to1).const_mul_left f₁'
    exact ((((hδ.const_mul_left f₀').add ((hd2.trans h2to1).const_mul_left (f₀''/2))).add
      (hself.const_mul_left f₁)).add hmid).add (h2to1.const_mul_left f₂)
  have hhigh1 : (fun x=>p₁*h x*((f₀''/2)*δ x^2+f₁'*δ x*h x+f₂*h x^2))=O[l] (fun x=>h x^3) := by
    exact ((hself.mul hbr2).const_mul_left p₁).congr (fun x=>by ring) (fun x=>by ring)
  have hhigh2 : (fun x=>p₂*h x^2*(f₀'*δ x+(f₀''/2)*δ x^2+f₁*h x+f₁'*δ x*h x+f₂*h x^2))=O[l] (fun x=>h x^3) := by
    exact (((hself.pow 2).mul hbr1).const_mul_left p₂).congr (fun x=>by ring) (fun x=>by ring)
  have hP0 : Tendsto P l (𝓝 p₀) := by
    have hp := (((tendsto_const_nhds (x:=p₀)).add ((tendsto_const_nhds (x:=p₁)).mul hh)).add
      ((tendsto_const_nhds (x:=p₂)).mul (hh.pow 2)))
    simpa [P] using hp
  have hPE : (fun x=>P x*(F x-Q x))=O[l] (fun x=>h x^3) := by
    simpa only [one_mul] using (hP0.isBigO_one ℂ).mul hF
  have hres : (fun x=>a₀+δ x-P x*F x)=O[l] (fun x=>h x^3) := by
    have hA := hPE.neg_left
    have hB := hdiffsq.const_mul_left (-(p₀*f₀''/2))
    have hC := hdiffh.const_mul_left (-(p₀*f₁'+p₁*f₀'))
    have hhres := (((hA.add hB).add hC).add hhigh1.neg_left).add hhigh2.neg_left
    apply hhres.congr_left
    intro x
    dsimp [P,Q]
    linear_combination hc₀ + (δ x)*hc₁ + (h x)*hc₂ + (h x)^2*hc₃
  have hd0 : Tendsto δ l (𝓝 0) := hδ.trans_tendsto hh
  have hQ0 : Tendsto Q l (𝓝 f₀) := by
    have hq := ((((tendsto_const_nhds (x:=f₀)).add ((tendsto_const_nhds (x:=f₀')).mul hd0)).add
      ((tendsto_const_nhds (x:=f₀''/2)).mul (hd0.pow 2))).add
      (((tendsto_const_nhds (x:=f₁)).add ((tendsto_const_nhds (x:=f₁')).mul hd0)).mul hh)).add
      ((tendsto_const_nhds (x:=f₂)).mul (hh.pow 2))
    simpa [Q] using hq
  have hE0 : Tendsto (fun x=>F x-Q x) l (𝓝 0) := by
    exact hF.trans_tendsto (by simpa using hh.pow 3)
  have hF0 : Tendsto F l (𝓝 f₀) := by
    convert hE0.add hQ0 using 1 <;> simp
  have hInv : (fun x=>(F x)⁻¹)=O[l] (fun _=>(1:ℂ)) :=
    (hF0.inv₀ hf₀).isBigO_one ℂ
  have hdiv := hres.mul hInv
  simp only [mul_one] at hdiv
  apply hdiv.congr' _ Filter.EventuallyEq.rfl
  filter_upwards [hF0.eventually_ne hf₀] with x hx
  dsimp [P]
  field_simp

theorem stationary_quotient_jet_explicit {α:Type*} (l:Filter α)
    (h δ F:α→ℂ) (a f₀ f₀' f₀'' f₁ f₁' f₂:ℂ)
    (hh:Tendsto h l (𝓝 0)) (hδ:δ=O[l] h)
    (hδ₁:(fun x=>δ x-((f₁-a*f₁')/(a*f₀''))*h x)=O[l] (fun x=>h x^2))
    (hF:(fun x=>F x-(f₀+f₀'*δ x+(f₀''/2)*δ x^2+
      (f₁+f₁'*δ x)*h x+f₂*h x^2))=O[l] (fun x=>h x^3))
    (hf₀:f₀≠0) (ha:a≠0) (hf₀'':f₀''≠0) (hstat:a*f₀'=f₀) :
    (fun x=>(a+δ x)/F x-(a/f₀+(-a*f₁/f₀^2)*h x+
      (a*f₁^2/f₀^3-a*f₂/f₀^2+(f₁-a*f₁')^2/(2*a*f₀''*f₀^2))*h x^2))
      =O[l] (fun x=>h x^3) := by
  apply stationary_quotient_jet l h δ F a ((f₁-a*f₁')/(a*f₀''))
    f₀ f₀' f₀'' f₁ f₁' f₂ (a/f₀) (-a*f₁/f₀^2)
    (a*f₁^2/f₀^3-a*f₂/f₀^2+(f₁-a*f₁')^2/(2*a*f₀''*f₀^2))
    hh hδ hδ₁ hF hf₀
  · field_simp
  · simpa only [div_mul_eq_mul_div] using (div_eq_one_iff_eq hf₀).mpr hstat
  · field_simp; ring
  · have hp:f₀'=f₀/a := (eq_div_iff ha).mpr (by simpa [mul_comm] using hstat)
    rw [hp]
    field_simp
    <;> ring

end NeuralGeneralization.OnlineLowerTanh
