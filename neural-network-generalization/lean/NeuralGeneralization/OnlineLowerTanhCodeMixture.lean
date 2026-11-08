import NeuralGeneralization.OnlineLowerTanhCodeScale
import Mathlib.Analysis.PSeries

/-! # Positive csch mixtures and the uniform upper scale bound -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

/-- The literal csch integral of any nonnegative continuous function is
a sum of its positive exponential moments. Integrability hypotheses here
are discharged for the actual rail product below. -/
theorem positive_csch_hasSum (F : ℝ→ℝ) (hF : ∀t,0≤F t) (hFc : Continuous F)
    (hInt : IntegrableOn (fun t=>F t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (hLap : ∀c>0,IntegrableOn (fun t=>Real.exp (-c*t)*F t) (Ioi 0)) :
    HasSum (fun n=>2*(∫t:ℝ in Ioi 0,Real.exp (-sineDecay n*t)*F t))
      (∫t:ℝ in Ioi 0,F t/Real.sinh (Real.pi*t/2)) := by
  let partialSum : ℕ→ℝ→ℝ := fun N t=>∑n∈Finset.range N,sineKernelTerm t n*F t
  have hnon (N : ℕ) (t : ℝ) : 0≤partialSum N t := by
    dsimp [partialSum,sineKernelTerm]
    exact Finset.sum_nonneg fun n _=>mul_nonneg (by positivity) (hF t)
  have hle (N : ℕ) (t : ℝ) (ht : 0<t) : partialSum N t≤F t/Real.sinh (Real.pi*t/2) := by
    have hs := sineKernelTerm_hasSum t ht
    have hsum := hs.summable.sum_le_tsum (Finset.range N) (fun n _=>by unfold sineKernelTerm;positivity)
    rw [hs.tsum_eq] at hsum
    dsimp [partialSum]
    rw [←Finset.sum_mul]
    have hh := mul_le_mul_of_nonneg_right hsum (hF t)
    simpa only [one_div,div_eq_mul_inv,mul_comm,one_mul] using hh
  have hlim (t : ℝ) (ht : 0<t) :
      Tendsto (fun N=>partialSum N t) atTop (𝓝 (F t/Real.sinh (Real.pi*t/2))) := by
    have hh := ((sineKernelTerm_hasSum t ht).mul_right (F t)).tendsto_sum_nat
    simpa only [partialSum,one_div,div_eq_mul_inv,mul_comm,one_mul] using hh
  have hd := tendsto_integral_of_dominated_convergence (fun t=>F t/Real.sinh (Real.pi*t/2))
    (fun N=>(show Continuous (partialSum N) by dsimp [partialSum,sineKernelTerm];fun_prop).aestronglyMeasurable)
    hInt
    (fun N=>by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      simpa only [Real.norm_eq_abs,abs_of_nonneg (hnon N t)] using hle N t ht)
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact hlim t ht)
  have hfin (N : ℕ) : (∫t:ℝ in Ioi 0,partialSum N t)=
      ∑n∈Finset.range N,2*(∫t:ℝ in Ioi 0,Real.exp (-sineDecay n*t)*F t) := by
    dsimp [partialSum]
    rw [integral_finset_sum]
    · apply Finset.sum_congr rfl
      intro n _
      unfold sineKernelTerm
      simp_rw [mul_assoc]
      rw [integral_const_mul]
    · intro n _
      simpa only [sineKernelTerm,mul_assoc] using (hLap (sineDecay n) (sineDecay_pos n)).const_mul 2
  simp_rw [hfin] at hd
  exact (hasSum_iff_tendsto_nat_of_nonneg (fun n=>mul_nonneg (by norm_num)
    (integral_nonneg fun t=>mul_nonneg (Real.exp_pos _).le (hF t))) _).mpr hd

lemma mul_sqrt_eq_rpow_three_halves (x : ℝ) (hx : 0<x) :
    x*Real.sqrt x=x^((3:ℝ)/2) := by
  calc
    _ = x^(1:ℝ)*x^((1:ℝ)/2) := by rw [Real.rpow_one,Real.sqrt_eq_rpow]
    _ = _ := by rw [←Real.rpow_add hx];congr 1;ring

/-- A fixed finite numerical constant; no dimension or network parameter
appears in this convergent p-series. -/
def codeCschMomentConstant : ℝ := ∑'n:ℕ,1/(sineDecay n*Real.sqrt (sineDecay n))

theorem summable_codeCschMoment :
    Summable (fun n:ℕ=>1/(sineDecay n*Real.sqrt (sineDecay n))) := by
  have hs := (Real.summable_one_div_nat_add_rpow (1/2:ℝ) (3/2:ℝ)).mpr (by norm_num)
  have hh := hs.mul_left (1/Real.pi^((3:ℝ)/2))
  apply hh.congr
  intro n
  rw [abs_of_nonneg (by positivity : (0:ℝ)≤(n:ℝ)+1/2)]
  rw [mul_sqrt_eq_rpow_three_halves _ (sineDecay_pos n)]
  unfold sineDecay
  rw [Real.mul_rpow (by positivity) Real.pi_pos.le]
  field_simp

 theorem codeCschMomentConstant_pos : 0<codeCschMomentConstant := by
  have hnon (n:ℕ) : 0≤1/(sineDecay n*Real.sqrt (sineDecay n)) := by
    have := sineDecay_pos n
    positivity
  have hh := summable_codeCschMoment.le_tsum 0 (fun n _=>hnon n)
  have hpos : 0<1/(sineDecay 0*Real.sqrt (sineDecay 0)) := by
    have := sineDecay_pos 0
    positivity
  exact hpos.trans_le hh

/-- Both compact-scale estimates now hold for an actual arbitrary rail
product. In particular, the upper estimate is sublinear in the RMS gain. -/
theorem trimmedRailProduct_kernel_sqrt_scale (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (hD : 6≤p*(2*r)) (a b : Fin p→Fin (2*r)→ℝ) (z : ℝ) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*z^2) :
    Real.sqrt ((p*r:ℕ):ℝ)*(∫t:ℝ in Ioi 0,
      trimmedRailProduct p (2*r) a b t/Real.sinh (Real.pi*t/2)) ≤
        (4*Real.pi*codeCschMomentConstant)*Real.sqrt (2*z) := by
  have hI := (trimmedRailProduct_kernel_cubic p r hp hr hD a b z hz he).1
  have hLap (c:ℝ) (hc:0<c) := trimmedRailProduct_laplace_sqrt_scale p r hp hr a b z c hz hc he
  have hs := positive_csch_hasSum (trimmedRailProduct p (2*r) a b)
    (trimmedRailProduct_nonneg _ _ _ _) (by unfold trimmedRailProduct;fun_prop) hI
    (fun c hc=>(hLap c hc).1)
  have hl := hs.mul_left (Real.sqrt ((p*r:ℕ):ℝ))
  have hrhs := summable_codeCschMoment.hasSum.mul_left (4*Real.pi*Real.sqrt (2*z))
  have hpoint (n:ℕ) : Real.sqrt ((p*r:ℕ):ℝ)*(2*(∫t:ℝ in Ioi 0,
      Real.exp (-sineDecay n*t)*trimmedRailProduct p (2*r) a b t)) ≤
        (4*Real.pi*Real.sqrt (2*z))*(1/(sineDecay n*Real.sqrt (sineDecay n))) := by
    have hh := (hLap (sineDecay n) (sineDecay_pos n)).2
    simp only [div_eq_mul_inv] at hh ⊢
    nlinarith only [hh]
  have hh := le_of_tendsto_of_tendsto' hl.tendsto_sum_nat hrhs.tendsto_sum_nat
    (fun N=>Finset.sum_le_sum fun n _=>hpoint n)
  simpa only [codeCschMomentConstant,mul_assoc,mul_comm,mul_left_comm] using hh

end NeuralGeneralization.OnlineLowerTanh
