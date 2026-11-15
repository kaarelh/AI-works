import NeuralGeneralization.OnlineLowerTanhCodeAbsorption
import NeuralGeneralization.OnlineLowerTanhCodeEnvelope
import NeuralGeneralization.OnlineLowerTanhCodeNumerical
import NeuralGeneralization.OnlineLowerTanhPhysicalSupportSharpConstant

/-! The actual local-to-global absorption, with explicit polynomial radii. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

 theorem carrierCodeMass_exact_core_paper {p R:ℕ} (size:Fin p→Bool→ℕ)
    (hR:16≤R) (hsize:∀i s,R≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (w:(Fin p→Bool)→ℝ)
    (hw0:∀θ∈A,0≤w θ) (hw:∀θ∈A,w θ≤((p*R:ℕ):ℝ)^2)
    (bias:ℝ) (u:Fin (carrierDimension size)→ℝ) (θ:Fin p→Bool) (hθ:θ∈A)
    (hsharp:IntrinsicParityBound (carrierTransversal size θ).card (w θ))
    (hD:2≤((p*R:ℕ):ℝ))
    (hρ:0<Real.sqrt (bias^2+incomingEnergy u))
    (hρD:Real.sqrt (bias^2+incomingEnergy u)≤(p*R:ℕ))
    (hS:max 2 (96*Real.sqrt 6*(w θ)^2)≤((p*R:ℕ):ℝ)^3)
    (hoff:carrierCodeMass size (A.erase θ) w bias u≤
      ((((p*R:ℕ):ℝ)^12)⁻¹)*Real.sqrt (bias^2+incomingEnergy u)) :
    carrierCodeMass size A w bias u≤Real.sqrt (bias^2+incomingEnergy u) ∧
    bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤
      2*max 2 (96*Real.sqrt 6*(w θ)^2)*Real.sqrt (bias^2+incomingEnergy u)*
        (Real.sqrt (bias^2+incomingEnergy u)-carrierCodeMass size A w bias u) := by
  let D:ℝ:=(p*R:ℕ)
  let ρ:=Real.sqrt (bias^2+incomingEnergy u)
  let v:=bias^2+(∑i∈(carrierTransversal size θ)ᶜ,u i^2)
  let mass:=fun t=>w t*|walshCoefficients (fun x=>Real.tanh (bias+incomingLinear u x))
    (carrierTransversal size t)|
  let δ:=ρ-mass θ
  let E:=carrierCodeMass size (A.erase θ) w bias u
  have hv:0≤v := add_nonneg (sq_nonneg _) (Finset.sum_nonneg fun _ _=>sq_nonneg _)
  have hE:0≤E := carrierCodeMass_nonneg size (A.erase θ) w
    (fun t ht=>hw0 t (Finset.mem_erase.mp ht).2) bias u
  have hs:=intrinsicParityBound_physical_support_paper (carrierTransversal size θ)
    (carrierTransversal_odd size heven θ) (w θ) (hw0 θ hθ) hsharp u bias
  change mass θ≤ρ ∧ v≤max 2 (96*Real.sqrt 6*(w θ)^2)*ρ*δ at hs
  have hδ:0≤δ := sub_nonneg.mpr hs.1
  have hs':v≤D^3*ρ*δ := hs.2.trans (by gcongr)
  have hpD:(p:ℝ)≤D := by
    dsimp [D]
    exact_mod_cast (show p≤p*R by nlinarith)
  obtain ⟨hη,hsmall,hboot,habs⟩:=inverse_power_absorption_numerics D p R hD hpD hR
  have hlocal (hnear:v≤((D^2)⁻¹)^2) : 2*D^3*D*E≤v := by
    have ht:Real.sqrt v≤(D^2)⁻¹ := by
      have ht2:=Real.sq_sqrt hv
      have ht0:=Real.sqrt_nonneg v
      nlinarith
    have he:(∑i∈(carrierTransversal size θ)ᶜ,u i^2)≤(Real.sqrt v)^2 := by
      rw [Real.sq_sqrt hv]
      dsimp [v]
      nlinarith [sq_nonneg bias]
    have hl:=tanh_local_offmass_small size (by omega : 2≤R) hsize θ A w (D^2)
      hw0 hw (by positivity) u bias (Real.sqrt v) ((D^2)⁻¹)
      (Real.sqrt_nonneg v) ht hη he hsmall
    change E≤2*D^2*(p:ℝ)*(D*(D^2)⁻¹)^R/((D^2)⁻¹)^2*(Real.sqrt v)^2 at hl
    rw [Real.sq_sqrt hv] at hl
    have hm:=mul_le_mul_of_nonneg_left hl (show 0≤2*D^3*D by positivity)
    have hn:=mul_le_mul_of_nonneg_right habs hv
    nlinarith only [hm,hn]
  have habsorb:=code_half_absorption ρ (D^3) D ((D^12)⁻¹) ((D^2)⁻¹) v δ E
    hρ (by positivity) hρD (by positivity) hv hδ hE hs' hoff hboot hlocal
  have hident:ρ-carrierCodeMass size A w bias u=δ-E := by
    exact code_deficit_identity A θ hθ mass ρ
  exact code_norm_and_support_of_absorption ρ (max 2 (96*Real.sqrt 6*(w θ)^2)) δ E v
    (carrierCodeMass size A w bias u) hρ.le (by positivity) hδ habsorb hident hs.2

end NeuralGeneralization.OnlineLowerTanh
