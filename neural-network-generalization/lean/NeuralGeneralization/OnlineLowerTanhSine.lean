import NeuralGeneralization.OnlineLowerTanhTransform
import NeuralGeneralization.OnlineLowerTanhSineIntegrable
import Mathlib.MeasureTheory.Integral.DominatedConvergence

noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def sineDecay (n:ℕ) : ℝ := ((n:ℝ)+1/2)*Real.pi
lemma sineDecay_pos (n:ℕ) : 0<sineDecay n := by unfold sineDecay; positivity

def sineKernelTerm (t:ℝ) (n:ℕ) : ℝ := 2*Real.exp (-sineDecay n*t)

lemma sineKernelTerm_hasSum (t:ℝ) (ht:0<t) :
    HasSum (sineKernelTerm t) (1/Real.sinh (Real.pi*t/2)) := by
  have hq0 : 0≤Real.exp (-Real.pi*t) := (Real.exp_pos _).le
  have hq1 : Real.exp (-Real.pi*t)<1 := Real.exp_lt_one_iff.mpr (by nlinarith [Real.pi_pos])
  have hh := (hasSum_geometric_of_lt_one hq0 hq1).mul_left
    (2*Real.exp (-Real.pi*t/2))
  have he (n:ℕ) : sineKernelTerm t n =
      (2*Real.exp (-Real.pi*t/2))*Real.exp (-Real.pi*t)^n := by
    rw [←Real.exp_nat_mul]
    unfold sineKernelTerm sineDecay
    rw [mul_assoc,←Real.exp_add]
    congr 2 <;> ring
  have hs : 1/Real.sinh (Real.pi*t/2) =
      2*Real.exp (-Real.pi*t/2)*(1-Real.exp (-Real.pi*t))⁻¹ := by
    let u := Real.pi*t/2
    have hu : 0<u := by dsimp [u]; positivity
    have hs := (Real.sinh_pos_iff.mpr hu).ne'
    have harg : -Real.pi*t=-(2*u) := by dsimp [u]; ring
    have harg2 : -Real.pi*t/2= -u := by dsimp [u]; ring
    rw [harg2,harg]
    change 1/Real.sinh u=2*Real.exp (-u)*(1-Real.exp (-(2*u)))⁻¹
    have hexp : Real.exp (2*u)=(Real.exp u)^2 := by rw [two_mul,Real.exp_add,pow_two]
    rw [Real.exp_neg,Real.exp_neg,hexp,Real.sinh_eq]
    rw [Real.exp_neg]
    have he0 := Real.exp_ne_zero u
    have he1 : Real.exp u ≠ 1 := ne_of_gt (Real.one_lt_exp_iff.mpr hu)
    have he2 : Real.exp u + 1 ≠ 0 := by positivity
    field_simp
  rw [hs]
  convert! hh using 1
  funext n
  exact he n

lemma exp_sine_integrable (a:ℝ) (n:ℕ) :
    IntegrableOn (fun t:ℝ => sineKernelTerm t n*Real.sin (a*t)) (Ioi 0) := by
  have hi := (integrableOn_exp_mul_Ioi (neg_neg_iff_pos.mpr (sineDecay_pos n)) 0).const_mul 2
  apply hi.mono'
  · exact Continuous.aestronglyMeasurable (by unfold sineKernelTerm; fun_prop)
  · filter_upwards [] with t
    simp only [Real.norm_eq_abs,abs_mul,sineKernelTerm,abs_of_nonneg (by positivity : 0≤(2:ℝ)),
      abs_of_pos (Real.exp_pos _)]
    exact mul_le_of_le_one_right (by positivity) (Real.abs_sin_le_one _)

lemma integral_exp_sine (a:ℝ) (n:ℕ) :
    (∫ t:ℝ in Ioi 0,sineKernelTerm t n*Real.sin (a*t))=
      2*a/(sineDecay n^2+a^2) := by
  unfold sineKernelTerm
  simp_rw [mul_assoc]
  rw [integral_const_mul,laplace_sine _ _ (sineDecay_pos n)]
  ring


def sinePartial (a:ℝ) (N:ℕ) (t:ℝ) : ℝ :=
  ∑ n ∈ Finset.range N,sineKernelTerm t n*Real.sin (a*t)

lemma sinePartial_bound (a:ℝ) (N:ℕ) (t:ℝ) (ht:0<t) :
    |sinePartial a N t| ≤ |Real.sin (a*t)/Real.sinh (Real.pi*t/2)| := by
  have hs:=sineKernelTerm_hasSum t ht
  have hnon (n:ℕ) : 0≤sineKernelTerm t n := by unfold sineKernelTerm; positivity
  have hsum := hs.summable.sum_le_tsum (Finset.range N) (fun n _=>hnon n)
  rw [hs.tsum_eq] at hsum
  unfold sinePartial
  rw [←Finset.sum_mul,abs_mul,abs_of_nonneg (Finset.sum_nonneg (fun n _=>hnon n))]
  calc
    _ ≤ (1/Real.sinh (Real.pi*t/2))*|Real.sin (a*t)| :=
      mul_le_mul_of_nonneg_right hsum (abs_nonneg _)
    _ = _ := by
      rw [abs_div,abs_of_pos (Real.sinh_pos_iff.mpr (by positivity))]
      ring

lemma sinePartial_tendsto (a t:ℝ) (ht:0<t) :
    Tendsto (fun N=>sinePartial a N t) atTop
      (𝓝 (Real.sin (a*t)/Real.sinh (Real.pi*t/2))) := by
  have h:=((sineKernelTerm_hasSum t ht).mul_right (Real.sin (a*t))).tendsto_sum_nat
  simpa [sinePartial,div_eq_mul_inv,mul_comm] using h

/-- The exact sine-transform formula, for the actual real tanh function. -/
theorem tanh_sine_integral (a:ℝ) :
    (∫ t:ℝ in Ioi 0,Real.sin (a*t)/Real.sinh (Real.pi*t/2))=Real.tanh a := by
  have hd := tendsto_integral_of_dominated_convergence
    (fun t:ℝ=>|Real.sin (a*t)/Real.sinh (Real.pi*t/2)|)
    (fun N=> (show Continuous (sinePartial a N) by unfold sinePartial sineKernelTerm; fun_prop).aestronglyMeasurable)
    (tanh_sine_integrable a).norm
    (fun N=>by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      simpa only [Real.norm_eq_abs] using sinePartial_bound a N t ht)
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact sinePartial_tendsto a t ht)
  have hfin (N:ℕ) : (∫ t:ℝ in Ioi 0,sinePartial a N t)=
      ∑ n ∈ Finset.range N,2*a/(sineDecay n^2+a^2) := by
    unfold sinePartial
    rw [integral_finsetSum _ (fun n _=>exp_sine_integrable a n)]
    simp_rw [integral_exp_sine]
  simp_rw [hfin] at hd
  exact tendsto_nhds_unique hd (by simpa only [sineDecay] using (tanh_partial_fraction a).tendsto_sum_nat)

end NeuralGeneralization.OnlineLowerTanh

