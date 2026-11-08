import NeuralGeneralization.OnlineLowerStationaryQuotientJet

noncomputable section
open scoped Topology
open Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

theorem quadratic_jet_mul {α:Type*} (l:Filter α) (h F G:α→ℂ)
    (a₀ a₁ a₂ b₀ b₁ b₂:ℂ) (hh:Tendsto h l (𝓝 0))
    (hF:(fun x=>F x-(a₀+a₁*h x+a₂*h x^2))=O[l] (fun x=>h x^3))
    (hG:(fun x=>G x-(b₀+b₁*h x+b₂*h x^2))=O[l] (fun x=>h x^3)) :
    (fun x=>F x*G x-(a₀*b₀+(a₀*b₁+a₁*b₀)*h x+
      (a₀*b₂+a₁*b₁+a₂*b₀)*h x^2))=O[l] (fun x=>h x^3) := by
  let P:α→ℂ:=fun x=>a₀+a₁*h x+a₂*h x^2
  let Q:α→ℂ:=fun x=>b₀+b₁*h x+b₂*h x^2
  have hp:Tendsto P l (𝓝 a₀):=by
    simpa [P] using (((tendsto_const_nhds (x:=a₀)).add ((tendsto_const_nhds (x:=a₁)).mul hh)).add
      ((tendsto_const_nhds (x:=a₂)).mul (hh.pow 2)))
  have hq:Tendsto Q l (𝓝 b₀):=by
    simpa [Q] using (((tendsto_const_nhds (x:=b₀)).add ((tendsto_const_nhds (x:=b₁)).mul hh)).add
      ((tendsto_const_nhds (x:=b₂)).mul (hh.pow 2)))
  have hge:Tendsto (fun x=>G x-Q x) l (𝓝 0):=hG.trans_tendsto (by simpa using hh.pow 3)
  have hg:Tendsto G l (𝓝 b₀):=by convert hge.add hq using 1 <;> simp
  have h3: (fun x=>h x^3)=O[l] (fun x=>h x^3):=isBigO_refl _ _
  have h4: (fun x=>h x^4)=O[l] (fun x=>h x^3):=by
    exact (h3.mul (hh.isBigO_one ℂ)).congr (fun x=>by ring) (fun x=>by ring)
  have he1:(fun x=>(F x-P x)*G x)=O[l] (fun x=>h x^3):=by
    simpa only [mul_one] using hF.mul (hg.isBigO_one ℂ)
  have he2:(fun x=>P x*(G x-Q x))=O[l] (fun x=>h x^3):=by
    simpa only [one_mul] using (hp.isBigO_one ℂ).mul hG
  have hs:=((he1.add he2).add (h3.const_mul_left (a₁*b₂+a₂*b₁))).add
    (h4.const_mul_left (a₂*b₂))
  exact hs.congr_left (fun x=>by dsimp [P,Q]; ring)

end NeuralGeneralization.OnlineLowerTanh
