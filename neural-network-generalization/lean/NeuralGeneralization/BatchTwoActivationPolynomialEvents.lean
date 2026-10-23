import NeuralGeneralization.BatchTwoActivationPolynomialStep

/-! The explicit polynomial reconstruction parameters also give an actual,
jointly measurable exceptional set with an exponential probability bound. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open GaussianAngularFields CompressionSampling
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

theorem polynomialLayerBad_tail (c : I → Fin n → ℝ) (k : ℕ) (hk : 128≤k)
    {φ : ℝ → ℝ} {ℓ B M q K : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hM : 0<M) (hℓ : ℓ≤k) (hB : B≤k)
    (hlog : Real.log (2*Fintype.card I)≤k)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (hvar : ∀i,(∑j,(c i j)^2)≤M) (hN : k^84≤N) (hK : 1≤K) (hq : 4*K≤q) :
    (iidSamples (standardLaw (Fin n)) N).real (polynomialLayerBad c φ k N M q)≤
      2*Real.exp (-(N:ℝ)*K) := by
  have hk0 : 0<k := by omega
  have hkR0 : (0:ℝ)<k := Nat.cast_pos.mpr hk0
  have hkR : (128:ℝ)≤k := by exact_mod_cast hk
  have hk16 : (16:ℝ)≤k := by linarith
  let b := polynomialCutoffJet (I:=I) hk16 hℓ0 hB0 hℓ hB hlog hφ hb hbb
  let F : I×I → (I→ℝ) → ℝ := fun pq z => polynomialCutoffFeature φ k pq.1 z*
    polynomialCutoffFeature φ k pq.2 z
  have hF : ∀pq,Measurable (F pq) := fun pq =>
    (b pq.1).continuous.measurable.mul (b pq.2).continuous.measurable
  have hFb : ∀pq z,|F pq z|≤(k:ℝ)^32 := by
    intro pq z
    change |(b pq.1).value z*(b pq.2).value z|≤_
    rw [abs_mul]
    have hm := mul_le_mul ((b pq.1).value_bound z) ((b pq.2).value_bound z)
      (abs_nonneg _) (pow_nonneg hkR0.le 16)
    apply hm.trans_eq
    ring
  have hwidth := polynomial_dual_width
    (show (1:ℝ)≤Fintype.card I from Nat.one_le_cast.mpr Fintype.card_pos)
    hkR hlog (show (k:ℝ)^84≤N by exact_mod_cast hN) hK hq
  have hwidth' : (k^80:ℝ)*Real.log (2*(Fintype.card (I×I):ℝ)+1)-
      (N:ℝ)*(q-((k:ℝ)^4*(k:ℝ)^32)^2/(2*(k^80:ℝ)))≤-(N:ℝ)*K := by
    simpa only [Fintype.card_prod,Nat.cast_mul,pow_two] using hwidth
  exact activationLayerBad_tail c F hF (s:=k^80) hM (pow_pos hkR0 32) (pow_pos hkR0 4) hvar hFb
    (lt_of_lt_of_le (show 0<k^84 from Nat.pow_pos hk0) hN)
    (show 0<k^80 from Nat.pow_pos hk0) (by linarith)
    (by simpa only [Nat.cast_pow] using hwidth')

theorem polynomialLayerBad_joint_measurable (k : ℕ) (hk : 128≤k)
    {φ : ℝ → ℝ} {ℓ B M : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hM : 0<M) (hℓ : ℓ≤k) (hB : B≤k)
    (hlog : Real.log (2*Fintype.card I)≤k)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B) (q : ℝ) :
    MeasurableSet {p : (I → Fin n → ℝ) × (Fin N → Fin n → ℝ) |
      p.2∈polynomialLayerBad p.1 φ k N M q} := by
  have hk0 : (0:ℝ)<k := Nat.cast_pos.mpr (by omega)
  have hk16 : (16:ℝ)≤k := by
    have h : (128:ℝ)≤k := by exact_mod_cast hk
    linarith
  let b := polynomialCutoffJet (I:=I) hk16 hℓ0 hB0 hℓ hB hlog hφ hb hbb
  let F : I×I → (I→ℝ) → ℝ := fun pq z => polynomialCutoffFeature φ k pq.1 z*
    polynomialCutoffFeature φ k pq.2 z
  have hF : ∀pq,Continuous (F pq) := fun pq => (b pq.1).continuous.mul (b pq.2).continuous
  have hFb : ∀pq z,|F pq z|≤(k:ℝ)^32 := by
    intro pq z
    change |(b pq.1).value z*(b pq.2).value z|≤_
    rw [abs_mul]
    have hm := mul_le_mul ((b pq.1).value_bound z) ((b pq.2).value_bound z)
      (abs_nonneg _) (pow_nonneg hk0.le 16)
    apply hm.trans_eq
    ring
  exact activationLayerBad_joint_measurable F hF hM (pow_pos hk0 32) hFb ((k:ℝ)^4) q

end NeuralGeneralization.BatchTwoActivation
