import NeuralGeneralization.OnlineLowerTanhCodeEnvelopeCompact
import NeuralGeneralization.OnlineLowerTanhCodeEnvelope
import NeuralGeneralization.OnlineLowerTanhCodeSqrtKernel

/-! # Actual off-orientation integral from a low-frequency height bound -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

theorem retained_code_integral_height_tail {p r:ℕ} (hp:2≤p) (hr:1≤r)
    (size:Fin p→Bool→ℕ) (hR:∀i s,2*r≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (u:Fin (carrierDimension size)→ℝ)
    (M E T:ℝ) (hM:0≤M) (hE:0≤E) (hT:1≤T)
    (henergy:incomingEnergy u≤(p*(2*r):ℕ)*M^2)
    (hheight:∀t∈Ioc 0 T,retainedCarrierProduct size A u t≤E) :
    Real.sqrt ((p*r:ℕ):ℝ)*(∫t:ℝ in Ioi 0,
      retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) ≤
      Real.sqrt ((p*r:ℕ):ℝ)*Real.sqrt (2*M*E)*sqrtFrequencyKernelConstant+
        (32/Real.pi)*Real.exp (-(Real.pi/8)*T) := by
  let a:=trimmedCarrierRailWeights size hR u false
  let b:=trimmedCarrierRailWeights size hR u true
  let F:=trimmedRailProduct p (2*r) a b
  let H:ℝ→ℝ:=fun t=>Real.sqrt (F t)
  let G:=retainedCarrierProduct size A u
  have he : (∑i:Fin p,∑k:Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*M^2 :=
    (trimmedCarrierRailWeights_energy_le size hR u).trans henergy
  have hInt := retainedCarrierProduct_kernel_integrable size heven A u
  have hG0 : ∀t,0≤G t := retainedCarrierProduct_nonneg _ _ _
  have hGF : ∀t,G t≤F t := retainedCarrierProduct_le_trimmed size hR A u
  have hF0 : ∀t,0≤F t := trimmedRailProduct_nonneg _ _ _ _
  have hF1 : ∀t,F t≤1 := trimmedRailProduct_le_one p (2*r) (by omega) a b
  have hH0 : ∀t,0≤H t := fun _=>Real.sqrt_nonneg _
  have hH1 : ∀t,H t≤1 := fun t=>by simpa only [H,Real.sqrt_one] using Real.sqrt_le_sqrt (hF1 t)
  have hGH : ∀t>0,G t≤H t^2 := by intro t ht;simpa only [H,Real.sq_sqrt (hF0 t)] using hGF t
  have hlin : ∀t>0,G t≤2*M*t := fun t ht=>(hGF t).trans
    (trimmedRailProduct_linear p (2*r) (by omega) (by omega) a b t M ht.le hM he)
  have hlo := kernel_low_frequency_height_bound G M E T hM hE (by linarith) (fun t _=>hG0 t) hInt hlin hheight
  have hL := sqrt_trimmedRailProduct_laplace p r hp hr a b (Real.pi/8) (by positivity)
  have hhi := code_envelope_tail ((p*r:ℕ):ℝ) (by positivity) H G hH0 hH1 hG0 hGH hInt hL.1 hL.2 T hT
  have hsplit := intervalIntegral.integral_Ioi_sub_Ioi hInt (show 0≤T by linarith)
  rw [intervalIntegral.integral_of_le (show 0≤T by linarith)] at hsplit
  have hsplit' := congrArg (fun x:ℝ=>Real.sqrt ((p*r:ℕ):ℝ)*x) hsplit
  have hlo' := mul_le_mul_of_nonneg_left hlo (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  nlinarith only [hlo',hhi,hsplit']

theorem carrierCodeMass_height_tail {p r:ℕ} (hp:2≤p) (hr:1≤r)
    (size:Fin p→Bool→ℕ) (hR:∀i s,2*r≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (w:(Fin p→Bool)→ℝ) (W:ℝ)
    (hw0:∀θ∈A,0≤w θ) (hw:∀θ∈A,w θ≤W) (hW:0≤W)
    (bias:ℝ) (u:Fin (carrierDimension size)→ℝ)
    (M E T:ℝ) (hM:0≤M) (hE:0≤E) (hT:1≤T)
    (henergy:incomingEnergy u≤(p*(2*r):ℕ)*M^2)
    (hheight:∀t∈Ioc 0 T,retainedCarrierProduct size A u t≤E) :
    Real.sqrt ((p*r:ℕ):ℝ)*carrierCodeMass size A w bias u ≤
      W*(Real.sqrt ((p*r:ℕ):ℝ)*Real.sqrt (2*M*E)*sqrtFrequencyKernelConstant+
        (32/Real.pi)*Real.exp (-(Real.pi/8)*T)) := by
  have henv := carrierCodeMass_le_retained_envelope size heven A w W hw0 hw bias u
  have hi := retained_code_integral_height_tail hp hr size hR heven A u M E T hM hE hT henergy hheight
  have henv' := mul_le_mul_of_nonneg_left henv (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  have hi' := mul_le_mul_of_nonneg_left hi hW
  nlinarith only [henv',hi']

end NeuralGeneralization.OnlineLowerTanh
