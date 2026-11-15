import NeuralGeneralization.BatchTwoImprovedSourceKernel
import NeuralGeneralization.RobustCompressionTerminalReadout

/-! Absolute-value importance sampling for the manuscript's terminal readout.
The zero readout uses the uniform law, avoiding a non-probability kernel. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptReadout
open Classical CompressionSampling RobustCompressionSampling BatchTwoImprovedWeightedSampling
variable {N m : ℕ}

def readoutSign (a : ℝ) : ℝ := if 0≤a then 1 else -1

def absoluteSum (a : Fin N→ℝ) : ℝ := ∑i,|a i|

def absoluteMean (a : Fin N→ℝ) : ℝ := absoluteSum a/(N:ℝ)

def probability (a : Fin N→ℝ) (i : Fin N) : ℝ :=
  if absoluteSum a=0 then 1/(N:ℝ) else |a i|/absoluteSum a

def observation (a h : Fin N→ℝ) (i : Fin N) : ℝ :=
  absoluteMean a*readoutSign (a i)*h i

def coefficient (a : Fin N→ℝ) (I : Fin m→Fin N) (j : Fin m) : ℝ :=
  absoluteMean a*readoutSign (a (I j))/(m:ℝ)

@[simp] theorem abs_readoutSign (a : ℝ) : |readoutSign a|=1 := by
  unfold readoutSign
  split_ifs <;> norm_num

theorem abs_mul_readoutSign (a : ℝ) : |a| *readoutSign a=a := by
  unfold readoutSign
  split_ifs with h
  · rw [abs_of_nonneg h]; ring
  · rw [abs_of_neg (lt_of_not_ge h)]; ring

theorem absoluteSum_nonneg (a : Fin N→ℝ) : 0≤absoluteSum a :=
  Finset.sum_nonneg (fun i _=>abs_nonneg (a i))

theorem absoluteSum_zero {a : Fin N→ℝ} (ha : absoluteSum a=0) (i : Fin N) : a i=0 := by
  have hi : |a i|≤absoluteSum a := Finset.single_le_sum (fun j _=>abs_nonneg (a j)) (Finset.mem_univ i)
  rw [ha] at hi
  exact abs_eq_zero.mp (le_antisymm hi (abs_nonneg _))

theorem absoluteMean_nonneg (a : Fin N→ℝ) : 0≤absoluteMean a :=
  div_nonneg (absoluteSum_nonneg a) (Nat.cast_nonneg N)

theorem absoluteMean_sq_le (hN : 0<N) (a : Fin N→ℝ) :
    (absoluteMean a)^2≤populationMean (fun i=>a i^2) := by
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (R:=ℝ) Finset.univ (fun i : Fin N=>|a i|) (fun _=>1)
  simp only [mul_one,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one,sq_abs] at hh
  have hn : (0:ℝ)<N := Nat.cast_pos.mpr hN
  unfold absoluteMean absoluteSum populationMean
  rw [div_pow]
  apply (div_le_div_iff₀ (sq_pos_of_pos hn) hn).mpr
  nlinarith [mul_le_mul_of_nonneg_right hh hn.le]

theorem probability_nonneg (a : Fin N→ℝ) (i : Fin N) : 0≤probability a i := by
  unfold probability
  split_ifs
  · positivity
  · exact div_nonneg (abs_nonneg _) (absoluteSum_nonneg a)

theorem probability_mass (hN : 0<N) (a : Fin N→ℝ) : ∑i,probability a i=1 := by
  have hn : (N:ℝ)≠0 := (Nat.cast_pos.mpr hN).ne'
  unfold probability
  split_ifs with h
  · simp [hn]
  · rw [←Finset.sum_div]
    exact div_self h

theorem weighted_observation (hN : 0<N) (a h : Fin N→ℝ) (i : Fin N) :
    probability a i*observation a h i=a i*h i/(N:ℝ) := by
  unfold probability observation absoluteMean
  split_ifs with hz
  · rw [hz,absoluteSum_zero hz i]; simp
  · have hn : (N:ℝ)≠0 := (Nat.cast_pos.mpr hN).ne'
    calc
      _=(|a i| *readoutSign (a i))*h i/(N:ℝ) := by field_simp
      _=_ := by rw [abs_mul_readoutSign]

def indexLaw (hN : 0<N) (a : Fin N→ℝ) : Measure (Fin N) :=
  finiteLaw (probability a) (probability_nonneg a) (probability_mass hN a)

instance indexLaw_probability (hN : 0<N) (a : Fin N→ℝ) :
    IsProbabilityMeasure (indexLaw hN a) := by unfold indexLaw; infer_instance

theorem observation_integral (hN : 0<N) (a h : Fin N→ℝ) :
    (∫i,observation a h i ∂indexLaw hN a)=populationMean (fun i=>a i*h i) := by
  rw [indexLaw,finiteLaw_integral]
  simp only [mean,weighted_observation hN]
  rw [←Finset.sum_div]
  rfl

theorem observation_bound (hN : 0<N) (a h : Fin N→ℝ) (hh : ∀i,|h i|≤1)
    {K : ℝ} (hK : populationMean (fun i=>a i^2)≤K) (i : Fin N) :
    |observation a h i|≤Real.sqrt K := by
  have hb := (absoluteMean_sq_le hN a).trans hK
  have hK0 : 0≤K := (sq_nonneg _).trans hb
  have hs : absoluteMean a≤Real.sqrt K := by
    nlinarith [Real.sqrt_nonneg K,Real.sq_sqrt hK0]
  unfold observation
  rw [abs_mul,abs_mul,abs_readoutSign,abs_of_nonneg (absoluteMean_nonneg a),mul_one]
  exact (mul_le_mul_of_nonneg_left (hh i) (absoluteMean_nonneg a)).trans (by simpa using hs)

theorem coefficient_bound (hN : 0<N) (a : Fin N→ℝ) {K : ℝ}
    (hK : populationMean (fun i=>a i^2)≤K) (I : Fin m→Fin N) (j : Fin m) :
    |coefficient a I j|≤Real.sqrt K/(m:ℝ) := by
  have hb := observation_bound hN a (fun _=>1) (by intro i; norm_num) hK (I j)
  simp only [observation,mul_one] at hb
  unfold coefficient
  rw [abs_div,show |(m:ℝ)|=(m:ℝ) from abs_of_nonneg (Nat.cast_nonneg m)]
  exact div_le_div_of_nonneg_right hb (Nat.cast_nonneg m)

theorem sampling_tail {X : Type*} [Fintype X] (hN : 0<N) (hm : 0<m)
    (a : Fin N→ℝ) (h : X→Fin N→ℝ) (hh : ∀x i,|h x i|≤1)
    {K radius : ℝ} (hK : 0<K) (he : populationMean (fun i=>a i^2)≤K) (hr : 0≤radius) :
    (iidSamples (indexLaw hN a) m).real
      {I | ∃x,radius≤|empiricalMean (observation a (h x)) I-populationMean (fun i=>a i*h x i)|}≤
      (Fintype.card X:ℝ)*(2*Real.exp (-(m:ℝ)*radius^2/(2*K))) := by
  have ht := finite_bank_tail_of_law N m hm (indexLaw hN a) (fun x=>observation a (h x))
    (Real.sqrt_pos.mpr hK) (fun x=>observation_bound hN a (h x) (hh x) he) hr
  simpa only [observation_integral,Real.sq_sqrt hK.le] using ht

end NeuralGeneralization.BatchTwoManuscriptReadout
