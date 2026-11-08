import NeuralGeneralization.OnlineLowerTanhResidualCellIntegral
import NeuralGeneralization.OnlineLowerTanhResidualNormalization

/-! # Finite-cell approximation and the exact periodic leading term -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualCellError {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (A ρ : ℝ) (l j : ℕ) : ℝ :=
  ∫ y : ℝ, |residualCellWindow (fun i => (q i:ℝ)) d A (residualScale A q) l ρ
      (residualDerivativeKernel j) y -
    residualWindowModel d (residualPeak A l) (residualDerivativeKernel j) y|

def residualLeading {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) (A B : ℝ) : ℝ :=
  residualPhaseSign q * Real.sqrt (2/(Real.pi*residualVariance q)) *
    Real.exp (-B^2/(2*A^2*residualVariance q)) *
      smoothedResponse A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)

def residualPeakModel {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (A B θ : ℝ) (l j : ℕ) : ℝ :=
  residualScale A q * (-1:ℝ)^((∑ i, (q i-1)/2)+n*l) *
    (Real.sqrt (2*Real.pi)*Real.exp (-(B*residualScale A q)^2/2)*
      Real.sin (B*residualPeak A l+θ)*
        Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)*
          residualDerivativeKernel j (residualPeak A l))

lemma residual_sqrt_scale {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) {A : ℝ} (hA : 0 < A) :
    Real.sqrt (residualVariance q)*residualScale A q = 1/A := by
  have hV := Real.sqrt_pos.mpr (residualVariance_pos hn q hq)
  unfold residualScale
  field_simp

lemma residual_cell_model_error {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, Odd (q i)) (d : Fin n → ℝ) {A : ℝ} (hA : 0 < A)
    (ρ B θ : ℝ) (l j : ℕ)
    (hi : Integrable (residualCellWindow (fun i => (q i:ℝ)) d A (residualScale A q)
      l ρ (residualDerivativeKernel j))) :
    |(∫ t : ℝ in Ioc ((l:ℝ)*(Real.pi/A)) (((l:ℝ)+1)*(Real.pi/A)) ∩ Ici ρ,
      residualRawKernel (fun i => A*(q i:ℝ)+d i) B θ (residualDerivativeKernel j) t) -
      residualPeakModel q d A B θ l j| ≤ residualScale A q*residualCellError q d A ρ l j := by
  have hqpos (i : Fin n) : 0 < q i := by rcases hq i with ⟨a,ha⟩; omega
  have hs := residualScale_pos hn q hqpos hA
  rw [residual_cell_integral hA hs q hq]
  unfold residualPeakModel
  rw [← mul_sub,abs_mul,abs_mul,abs_of_pos hs]
  simp only [abs_pow,abs_neg,abs_one,one_pow,mul_one]
  apply mul_le_mul_of_nonneg_left _ hs.le
  exact residualCellWindow_sine_error _ _ _ _ _ _ _ _ _ hi

lemma residual_finite_cell_error {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, Odd (q i)) (d : Fin n → ℝ) {A lo : ℝ} (hlo : 0 < lo) (hAlo : lo ≤ A)
    (ρ B θ : ℝ) (L j : ℕ)
    (hi : ∀ l < L, Integrable (residualCellWindow (fun i => (q i:ℝ)) d A (residualScale A q)
      l ρ (residualDerivativeKernel j))) :
    Real.sqrt (residualVariance q) *
      |(∑ l ∈ Finset.range L, ∫ t : ℝ in Ioc ((l:ℝ)*(Real.pi/A)) (((l:ℝ)+1)*(Real.pi/A)) ∩ Ici ρ,
        residualRawKernel (fun i => A*(q i:ℝ)+d i) B θ (residualDerivativeKernel j) t) -
        ∑ l ∈ Finset.range L, residualPeakModel q d A B θ l j| ≤
      (1/lo)*(∑ l ∈ Finset.range L, residualCellError q d A ρ l j) := by
  have hA := hlo.trans_le hAlo
  have hqpos (i : Fin n) : 0 < q i := by rcases hq i with ⟨a,ha⟩; omega
  rw [← Finset.sum_sub_distrib]
  have hsum := Finset.abs_sum_le_sum_abs (s := Finset.range L)
    (f := fun l : ℕ => (∫ t : ℝ in Ioc ((l:ℝ)*(Real.pi/A)) (((l:ℝ)+1)*(Real.pi/A)) ∩ Ici ρ,
        residualRawKernel (fun i => A*(q i:ℝ)+d i) B θ (residualDerivativeKernel j) t) -
        residualPeakModel q d A B θ l j)
  have hh := Finset.sum_le_sum (s := Finset.range L) (fun l hl =>
    residual_cell_model_error hn q hq d hA ρ B θ l j (hi l (Finset.mem_range.mp hl)))
  have he : (∑ l ∈ Finset.range L, residualScale A q*residualCellError q d A ρ l j) =
      residualScale A q*(∑ l ∈ Finset.range L, residualCellError q d A ρ l j) := by rw [Finset.mul_sum]
  rw [he] at hh
  have hm := mul_le_mul_of_nonneg_left (hsum.trans hh) (Real.sqrt_nonneg (residualVariance q))
  rw [← mul_assoc,residual_sqrt_scale hn q hqpos hA] at hm
  apply hm.trans
  apply mul_le_mul_of_nonneg_right (one_div_le_one_div_of_le hlo hAlo)
  exact Finset.sum_nonneg (fun l hl => integral_nonneg (fun y => abs_nonneg _))

lemma residual_peak_model_coefficient {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A : ℝ} (hA : 0 < A) (B : ℝ) (l : ℕ) :
    residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 0 =
      (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q))*
        Real.exp (-B^2/(2*A^2*residualVariance q))) *
      (smoothedCoefficient A (∑ i, (d i)^2) l *
        Real.sin ((2*(l:ℝ)+1)*periodicFrequency A*(B+(n%2:ℕ)*A))) := by
  unfold residualPeakModel residualDerivativeKernel
  simp only [pow_zero]
  have hphase := residual_peak_signed_phase hA.ne' q l B 0
  simp only [add_zero] at hphase
  have hcoef := residual_peak_coefficient hA.ne' (∑ i, (d i)^2) l
  have he : residualScale A q * (-1:ℝ)^((∑ i, (q i-1)/2)+n*l) *
      (Real.sqrt (2*Real.pi)*Real.exp (-(B*residualScale A q)^2/2)*
        Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2)*
          Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)*(1/Real.sinh (Real.pi*residualPeak A l/2))) =
      (residualScale A q*Real.sqrt (2*Real.pi)*(A/Real.pi))*
      Real.exp (-(B*residualScale A q)^2/2)*residualPhaseSign q*
      smoothedCoefficient A (∑ i, (d i)^2) l *
        Real.sin (residualPeak A l*(B+(n%2:ℕ)*A)) := by
    calc
      _ = residualScale A q*Real.sqrt (2*Real.pi)*Real.exp (-(B*residualScale A q)^2/2)*
          ((-1:ℝ)^((∑ i, (q i-1)/2)+n*l)*Real.sin (B*residualPeak A l+(n:ℝ)*Real.pi/2))*
          (Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)/Real.sinh (Real.pi*residualPeak A l/2)) := by ring
      _ = _ := by rw [hphase,hcoef]; ring
  rw [he,residual_gaussian_normalization hn q hq hA,residual_gaussian_exponent hn q hq hA]
  unfold residualPeak
  ring

lemma residual_sqrt_normalization {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) :
    Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q)) =
      Real.sqrt (2*Real.pi)/Real.pi := by
  rw [← residual_gaussian_normalization hn q hq (by norm_num : (0:ℝ)<1)]
  rw [show Real.sqrt (residualVariance q)*(residualScale 1 q*Real.sqrt (2*Real.pi)*(1/Real.pi)) =
    (Real.sqrt (residualVariance q)*residualScale 1 q)*Real.sqrt (2*Real.pi)*(1/Real.pi) by ring]
  rw [residual_sqrt_scale hn q hq (by norm_num)]
  ring

lemma residual_model_tail {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) {A lo hi : ℝ}
    (hlo : 0 < lo) (hAlo : lo ≤ A) (hAhi : A ≤ hi) (B : ℝ) (L : ℕ) :
    Real.sqrt (residualVariance q)*
      |(∑ l ∈ Finset.range L, residualPeakModel q d A B ((n:ℝ)*Real.pi/2) l 0)-
        residualLeading q d A B| ≤
      (Real.sqrt (2*Real.pi)/Real.pi)*
        (((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^L/(1-periodicRatio hi)) := by
  have hA := hlo.trans_le hAlo
  have hE : 0 ≤ ∑ i, (d i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  simp_rw [residual_peak_model_coefficient hn q hq d hA B]
  rw [← Finset.mul_sum]
  unfold residualLeading
  rw [← mul_sub,abs_mul,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),abs_of_pos (Real.exp_pos _)]
  have he : Real.exp (-B^2/(2*A^2*residualVariance q)) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have hden : 0 < 2*A^2*residualVariance q := by
      have hV := residualVariance_pos hn q hq
      positivity
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg _)) hden.le
  have htail := smoothedResponse_partial_error hlo hAlo hAhi hE L (B+(n%2:ℕ)*A)
  rw [abs_sub_comm] at htail
  have hm := mul_le_mul_of_nonneg_left htail
    (Real.sqrt_nonneg (2/(Real.pi*residualVariance q)))
  have hbound : Real.sqrt (2/(Real.pi*residualVariance q))*
      Real.exp (-B^2/(2*A^2*residualVariance q))*
        |(∑ l ∈ Finset.range L, smoothedCoefficient A (∑ i, (d i)^2) l *
          Real.sin ((2*(l:ℝ)+1)*periodicFrequency A*(B+(n%2:ℕ)*A))) -
          smoothedResponse A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)| ≤
      Real.sqrt (2/(Real.pi*residualVariance q))*
        (((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^L/(1-periodicRatio hi)) := by
    apply le_trans _ hm
    have hprod := mul_le_mul_of_nonneg_right
      (mul_le_of_le_one_right (Real.sqrt_nonneg (2/(Real.pi*residualVariance q))) he)
      (abs_nonneg ((∑ l ∈ Finset.range L, smoothedCoefficient A (∑ i, (d i)^2) l *
          Real.sin ((2*(l:ℝ)+1)*periodicFrequency A*(B+(n%2:ℕ)*A))) -
          smoothedResponse A (∑ i, (d i)^2) (B+(n%2:ℕ)*A)))
    exact hprod
  have hmul := mul_le_mul_of_nonneg_left hbound (Real.sqrt_nonneg (residualVariance q))
  apply hmul.trans_eq
  rw [← mul_assoc,residual_sqrt_normalization hn q hq]

end NeuralGeneralization.OnlineLowerTanh
