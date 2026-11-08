import NeuralGeneralization.OnlineLowerTanhCodePhysicalProduct
import NeuralGeneralization.OnlineLowerTanhCodeMixture

/-! # Weighted actual tanh code mass is bounded by the physical rail envelope -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

def carrierCodeMass {p : ℕ} (size : Fin p→Bool→ℕ)
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (bias : ℝ)
    (u : Fin (carrierDimension size)→ℝ) : ℝ :=
  ∑θ∈A,w θ*|walshCoefficients (fun x=>Real.tanh (bias+incomingLinear u x)) (carrierTransversal size θ)|

theorem carrierCodeMass_nonneg {p : ℕ} (size : Fin p→Bool→ℕ)
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (hw : ∀θ∈A,0≤w θ)
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ) :
    0≤carrierCodeMass size A w bias u :=
  Finset.sum_nonneg fun θ hθ=>mul_nonneg (hw θ hθ) (abs_nonneg _)

theorem carrierCodeMass_le_envelope {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (W : ℝ)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤W) (hW : 0≤W)
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ)
    (hInt : IntegrableOn (fun t=>trimmedRailProduct p R
      (trimmedCarrierRailWeights size hR u false) (trimmedCarrierRailWeights size hR u true) t /
        Real.sinh (Real.pi*t/2)) (Ioi 0)) :
    carrierCodeMass size A w bias u ≤ W*(∫t:ℝ in Ioi 0,
      trimmedRailProduct p R (trimmedCarrierRailWeights size hR u false)
        (trimmedCarrierRailWeights size hR u true) t/Real.sinh (Real.pi*t/2)) := by
  have hki (θ : Fin p→Bool) : IntegrableOn (fun t=>|tanhTrigKernel (carrierTransversal size θ) u t|) (Ioi 0) := by
    obtain ⟨q,hq⟩ := carrierTransversal_odd size heven θ
    have hc : (carrierTransversal size θ).card=2*q+1 := by omega
    simpa only [Real.norm_eq_abs,IntegrableOn] using (integrable_tanhTrigKernel (carrierTransversal size θ) hc u).norm
  have hmass : carrierCodeMass size A w bias u ≤
      ∑θ∈A,w θ*(∫t:ℝ in Ioi 0,|tanhTrigKernel (carrierTransversal size θ) u t|) := by
    apply Finset.sum_le_sum
    intro θ hθ
    obtain ⟨q,hq⟩ := carrierTransversal_odd size heven θ
    exact mul_le_mul_of_nonneg_left (tanh_walsh_abs_le_integral_kernel
      (carrierTransversal size θ) (by omega : (carrierTransversal size θ).card=2*q+1) bias u) (hw0 θ hθ)
  have hsumint : IntegrableOn (fun t=>∑θ∈A,w θ*|tanhTrigKernel (carrierTransversal size θ) u t|) (Ioi 0) :=
    integrable_finset_sum A (fun θ _=>(hki θ).const_mul (w θ))
  have heq : (∑θ∈A,w θ*(∫t:ℝ in Ioi 0,|tanhTrigKernel (carrierTransversal size θ) u t|)) =
      (∫t:ℝ in Ioi 0,∑θ∈A,w θ*|tanhTrigKernel (carrierTransversal size θ) u t|) := by
    rw [integral_finset_sum]
    · simp_rw [integral_const_mul]
    · intro θ _;exact (hki θ).const_mul (w θ)
  rw [heq] at hmass
  have hpoint (t:ℝ) (ht:0<t) :
      (∑θ∈A,w θ*|tanhTrigKernel (carrierTransversal size θ) u t|) ≤
        W*(trimmedRailProduct p R (trimmedCarrierRailWeights size hR u false)
          (trimmedCarrierRailWeights size hR u true) t/Real.sinh (Real.pi*t/2)) := by
    have hsin : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
    have hterm (θ:Fin p→Bool) : |tanhTrigKernel (carrierTransversal size θ) u t| =
        |trigProduct (carrierTransversal size θ) (fun j=>t*u j)|/Real.sinh (Real.pi*t/2) := by
      unfold tanhTrigKernel
      rw [abs_div,abs_of_pos hsin]
    calc
      _ ≤ ∑θ∈A,W*|tanhTrigKernel (carrierTransversal size θ) u t| :=
        Finset.sum_le_sum fun θ hθ=>mul_le_mul_of_nonneg_right (hw θ hθ) (abs_nonneg _)
      _ = W*∑θ∈A,|tanhTrigKernel (carrierTransversal size θ) u t| := by rw [Finset.mul_sum]
      _ ≤ W*∑θ:Fin p→Bool,|tanhTrigKernel (carrierTransversal size θ) u t| :=
        mul_le_mul_of_nonneg_left (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ A)
          (fun θ _ _=>abs_nonneg _)) hW
      _ = W*((∑θ:Fin p→Bool,|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|)/Real.sinh (Real.pi*t/2)) := by
        simp only [hterm,Finset.sum_div]
      _ ≤ _ := mul_le_mul_of_nonneg_left (div_le_div_of_nonneg_right
        (carrier_full_trig_sum_le_trimmed size hR u t) hsin.le) hW
  have hh := integral_mono_ae hsumint (hInt.const_mul W) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hh
  exact hmass.trans hh


/-- The two scale estimates apply to actual tanh Walsh coefficients on
physical coordinates, with arbitrary affine bias and retained subcode. -/
theorem carrierCodeMass_scale_bounds {p r : ℕ} (hp : 2≤p) (hr : 1≤r) (hD : 6≤p*(2*r))
    (size : Fin p→Bool→ℕ) (hR : ∀i s,2*r≤size i s) (heven : ∀i s,Even (size i s))
    (A : Finset (Fin p→Bool)) (w : (Fin p→Bool)→ℝ) (W : ℝ)
    (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤W) (hW : 0≤W)
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ) (z : ℝ) (hz : 0≤z)
    (he : incomingEnergy u≤(p*(2*r):ℕ)*z^2) :
    Real.sqrt ((p*r:ℕ):ℝ)*carrierCodeMass size A w bias u ≤ W*(65536/Real.pi^3)*z^3 ∧
    Real.sqrt ((p*r:ℕ):ℝ)*carrierCodeMass size A w bias u ≤
      W*(4*Real.pi*codeCschMomentConstant)*Real.sqrt (2*z) := by
  let a := trimmedCarrierRailWeights size hR u false
  let b := trimmedCarrierRailWeights size hR u true
  have he' : (∑i:Fin p,∑k:Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*z^2 :=
    (trimmedCarrierRailWeights_energy_le size hR u).trans he
  obtain ⟨hInt,hcubic⟩ := trimmedRailProduct_kernel_cubic p r hp hr hD a b z hz he'
  have hupper := trimmedRailProduct_kernel_sqrt_scale p r hp hr hD a b z hz he'
  have henv := carrierCodeMass_le_envelope size hR heven A w W hw0 hw hW bias u hInt
  have henv' := mul_le_mul_of_nonneg_left henv (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  have hlo := mul_le_mul_of_nonneg_left hcubic hW
  have hhi := mul_le_mul_of_nonneg_left hupper hW
  constructor <;> nlinarith only [henv',hlo,hhi]


def retainedCarrierProduct {p : ℕ} (size : Fin p→Bool→ℕ)
    (A : Finset (Fin p→Bool)) (u : Fin (carrierDimension size)→ℝ) (t : ℝ) : ℝ :=
  ∑θ∈A,|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|

theorem retainedCarrierProduct_nonneg {p : ℕ} (size : Fin p→Bool→ℕ)
    (A : Finset (Fin p→Bool)) (u : Fin (carrierDimension size)→ℝ) (t : ℝ) :
    0≤retainedCarrierProduct size A u t := Finset.sum_nonneg fun _ _=>abs_nonneg _

theorem retainedCarrierProduct_le_trimmed {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (A : Finset (Fin p→Bool))
    (u : Fin (carrierDimension size)→ℝ) (t : ℝ) :
    retainedCarrierProduct size A u t≤trimmedRailProduct p R
      (trimmedCarrierRailWeights size hR u false) (trimmedCarrierRailWeights size hR u true) t := by
  apply le_trans (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ A) (fun _ _ _=>abs_nonneg _))
  exact carrier_full_trig_sum_le_trimmed size hR u t

theorem retainedCarrierProduct_kernel_integrable {p : ℕ} (size : Fin p→Bool→ℕ)
    (heven : ∀i s,Even (size i s)) (A : Finset (Fin p→Bool))
    (u : Fin (carrierDimension size)→ℝ) :
    IntegrableOn (fun t=>retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  have hki (θ:Fin p→Bool) : IntegrableOn (fun t=>|tanhTrigKernel (carrierTransversal size θ) u t|) (Ioi 0) := by
    obtain ⟨q,hq⟩ := carrierTransversal_odd size heven θ
    simpa only [Real.norm_eq_abs,IntegrableOn] using
      (integrable_tanhTrigKernel (carrierTransversal size θ) (by omega : (carrierTransversal size θ).card=2*q+1) u).norm
  apply (integrable_finset_sum A (fun θ _=>hki θ)).congr
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  have htpos : 0<t := ht
  have hsin : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  unfold retainedCarrierProduct tanhTrigKernel
  simp only [Finset.sum_div,abs_div,abs_of_pos hsin]

theorem carrierCodeMass_le_retained_envelope {p : ℕ} (size : Fin p→Bool→ℕ)
    (heven : ∀i s,Even (size i s)) (A : Finset (Fin p→Bool))
    (w : (Fin p→Bool)→ℝ) (W : ℝ) (hw0 : ∀θ∈A,0≤w θ) (hw : ∀θ∈A,w θ≤W)
    (bias : ℝ) (u : Fin (carrierDimension size)→ℝ) :
    carrierCodeMass size A w bias u ≤ W*(∫t:ℝ in Ioi 0,
      retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) := by
  have hki (θ:Fin p→Bool) : IntegrableOn (fun t=>|tanhTrigKernel (carrierTransversal size θ) u t|) (Ioi 0) := by
    obtain ⟨q,hq⟩ := carrierTransversal_odd size heven θ
    simpa only [Real.norm_eq_abs,IntegrableOn] using
      (integrable_tanhTrigKernel (carrierTransversal size θ) (by omega : (carrierTransversal size θ).card=2*q+1) u).norm
  have hfirst : carrierCodeMass size A w bias u≤W*∑θ∈A,
      (∫t:ℝ in Ioi 0,|tanhTrigKernel (carrierTransversal size θ) u t|) := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro θ hθ
    obtain ⟨q,hq⟩ := carrierTransversal_odd size heven θ
    apply (mul_le_mul_of_nonneg_left (tanh_walsh_abs_le_integral_kernel
      (carrierTransversal size θ) (by omega : (carrierTransversal size θ).card=2*q+1) bias u) (hw0 θ hθ)).trans
    exact mul_le_mul_of_nonneg_right (hw θ hθ) (integral_nonneg fun _=>abs_nonneg _)
  have heq : (∑θ∈A,(∫t:ℝ in Ioi 0,|tanhTrigKernel (carrierTransversal size θ) u t|)) =
      (∫t:ℝ in Ioi 0,retainedCarrierProduct size A u t/Real.sinh (Real.pi*t/2)) := by
    rw [←integral_finset_sum A (fun θ _=>hki θ)]
    apply integral_congr_ae
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have htpos : 0<t := ht
    have hsin : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
    unfold retainedCarrierProduct tanhTrigKernel
    simp only [Finset.sum_div,abs_div,abs_of_pos hsin]
  rwa [heq] at hfirst

end NeuralGeneralization.OnlineLowerTanh
