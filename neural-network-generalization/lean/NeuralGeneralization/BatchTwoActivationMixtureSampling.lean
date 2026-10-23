import NeuralGeneralization.BatchTwoActivationCovarianceSampling
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Probability.ProbabilityMassFunction.Integrals

/-! Finite sampling of nonnegative covariance mixtures, including a zero
atom for unused coefficient mass. The neuron count depends logarithmically
on the number of input coordinates through the explicit tail budget. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoActivation
variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq J]

def mixtureWeight (c : J→ℝ) (A : ℝ) : Option J→ℝ
  | none => 1-(∑j,c j)/A
  | some j => c j/A

theorem mixtureWeight_nonneg (c : J→ℝ) {A : ℝ} (hA : 0<A)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) (j : Option J) : 0≤mixtureWeight c A j := by
  cases j with
  | none => exact sub_nonneg.mpr ((div_le_one hA).2 hs)
  | some j => exact div_nonneg (hc j) hA.le

theorem mixtureWeight_sum (c : J→ℝ) (A : ℝ) : (∑j,mixtureWeight c A j)=1 := by
  simp only [Fintype.sum_option,mixtureWeight,←Finset.sum_div]
  ring

def mixturePMF (c : J→ℝ) {A : ℝ} (hA : 0<A)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) : PMF (Option J) :=
  PMF.ofFintype (fun j=>ENNReal.ofReal (mixtureWeight c A j)) (by
    rw [←ENNReal.ofReal_sum_of_nonneg (fun j _=>mixtureWeight_nonneg c hA hc hs j),
      mixtureWeight_sum,ENNReal.ofReal_one])

def mixtureFeature (h : J→I→ℝ) : Option J→I→ℝ
  | none => 0
  | some j => h j

variable [MeasurableSpace (Option J)] [MeasurableSingletonClass (Option J)]

def mixtureLaw (c : J→ℝ) {A : ℝ} (hA : 0<A)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) : Measure (Option J) := (mixturePMF c hA hc hs).toMeasure

instance mixtureLaw_probability (c : J→ℝ) {A : ℝ} (hA : 0<A)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) : IsProbabilityMeasure (mixtureLaw c hA hc hs) := by
  unfold mixtureLaw; infer_instance

theorem mixtureLaw_covariance (c : J→ℝ) {A : ℝ} (hA : 0<A)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) (h : J→I→ℝ) (p q : I) :
    covarianceMean (mixtureLaw c hA hc hs) (mixtureFeature h) p q=
      (∑j,c j*h j p*h j q)/A := by
  unfold covarianceMean mixtureLaw
  rw [PMF.integral_eq_sum]
  simp only [mixturePMF,PMF.ofFintype_apply,ENNReal.toReal_ofReal (mixtureWeight_nonneg c hA hc hs _),
    smul_eq_mul,Fintype.sum_option,mixtureFeature,Pi.zero_apply,mul_zero,zero_add,mixtureWeight]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [ENNReal.toReal_ofReal (div_nonneg (hc j) hA.le)]
  ring

/-- The returned rows are selected original atoms or zero, with uniform
covariance coefficients `A/N`. No inverse Gram matrix is involved. -/
theorem exists_mixture_covariance_sample (c : J→ℝ) {A B ε : ℝ} (hA : 0<A) (hB : 0<B)
    (hc : ∀j,0≤c j) (hs : (∑j,c j)≤A) (h : J→I→ℝ) (hb : ∀j p,|h j p|≤B)
    {N : ℕ} (hN : 0<N) (hε : 0≤ε)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(N:ℝ)*((ε/A)/B^2)^2/2)<1) :
    ∃w:Fin N→Option J, ∀p q,
      |(A/(N:ℝ))*(∑i,mixtureFeature h (w i) p*mixtureFeature h (w i) q)-
        (∑j,c j*h j p*h j q)|<ε := by
  have hmb : ∀j p,|mixtureFeature h j p|≤B := by
    intro j p
    cases j with
    | none => simpa [mixtureFeature] using hB.le
    | some j => exact hb j p
  obtain ⟨w,hw⟩ := exists_covariance_sample (mixtureLaw c hA hc hs) (mixtureFeature h)
    (fun p=>measurable_of_finite _) hB hmb hN (div_nonneg hε hA.le) hbudget
  refine ⟨w,?_⟩
  intro p q
  have hq := hw p q
  rw [mixtureLaw_covariance] at hq
  have he : (A/(N:ℝ))*(∑i,mixtureFeature h (w i) p*mixtureFeature h (w i) q)-
      (∑j,c j*h j p*h j q)=
      A*(empiricalCovariance (mixtureFeature h) w p q-(∑j,c j*h j p*h j q)/A) := by
    unfold empiricalCovariance
    field_simp <;> ring
  rw [he,abs_mul,abs_of_pos hA]
  exact (mul_lt_mul_of_pos_left hq hA).trans_eq (by field_simp)

end NeuralGeneralization.BatchTwoActivation
