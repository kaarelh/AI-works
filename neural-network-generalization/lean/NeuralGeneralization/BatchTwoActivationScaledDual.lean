import NeuralGeneralization.DualCertificate

/-! The sparse bounded-dual certificate at arbitrary observable scale.
The probability tail and returned tilt both refer to the actual IID law. -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open BoundedDual ActualBoundedDual DualCertificate CompressionSampling
variable {Ω J : Type*} [MeasurableSpace Ω] [Fintype J] [DecidableEq J] [Nonempty J]

def normalizedObservables (F : J→Ω→ℝ) (B : ℝ) (j : J) (x : Ω) : ℝ := F j x/B

theorem normalizedObservables_bound (F : J→Ω→ℝ) {B : ℝ} (hB : 0<B)
    (hb : ∀j x,|F j x|≤B) : ∀j x,|normalizedObservables F B j x|≤1 := by
  intro j x
  rw [normalizedObservables,abs_div,abs_of_pos hB]
  exact (div_le_one hB).2 (hb j x)

theorem normalizedObservables_potential (F : J→Ω→ℝ) (B : ℝ) (lam : J→ℝ) :
    potential (normalizedObservables F B) lam=potential F (fun j=>lam j/B) := by
  funext x
  unfold potential pairing normalizedObservables
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem normalizedObservables_mean (μ : Measure Ω) (F : J→Ω→ℝ) (B : ℝ)
    (lam : J→ℝ) (j : J) :
    mean μ (normalizedObservables F B) lam j=mean μ F (fun j=>lam j/B) j/B := by
  unfold mean
  rw [normalizedObservables_potential]
  exact integral_div B (F j)

theorem normalizedObservables_empirical (F : J→Ω→ℝ) (B : ℝ) {N : ℕ}
    (a : Fin N→Ω) (j : J) : empirical (normalizedObservables F B) a j=empirical F a j/B := by
  simp only [empirical,normalizedObservables,←Finset.sum_div]
  ring

def scaledDualBad (μ : Measure Ω) (F : J→Ω→ℝ) (N : ℕ) (B G K : ℝ) : Set (Fin N→Ω) :=
  badEvent μ (normalizedObservables F B) N (G*B) K

theorem scaledDualBad_tail (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : J→Ω→ℝ) (hF : ∀j,Measurable (F j)) {B G K : ℝ} (hB : 0<B) (hG : 0<G)
    (hb : ∀j x,|F j x|≤B) {N s : ℕ} (hN : 0<N) (hs : 0<s) :
    (iidSamples μ N).real (scaledDualBad μ F N B G K)≤
      Real.exp ((s:ℝ)*Real.log (2*(Fintype.card J:ℝ)+1)-
        (N:ℝ)*(K-(G*B)^2/(2*(s:ℝ)))) :=
  bounded_dual_tail_exp μ (normalizedObservables F B) (fun j=>(hF j).div_const B)
    (normalizedObservables_bound F hB hb) hN hs (mul_pos hG hB) K

theorem scaledDualBad_measurable (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : J→Ω→ℝ) (hF : ∀j,Measurable (F j)) {B : ℝ} (hB : 0<B)
    (hb : ∀j x,|F j x|≤B) (N : ℕ) (G K : ℝ) :
    MeasurableSet (scaledDualBad μ F N B G K) := by
  exact measurableSet_badEvent μ (normalizedObservables F B) (fun j=>(hF j).div_const B)
    N (G*B) K

/-- The bound is on an actual unnormalized-scale exponential potential. -/
theorem exists_scaled_tilt_of_not_bad (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : J→Ω→ℝ) (hF : ∀j,Measurable (F j)) {B G K : ℝ} (hB : 0<B) (hG : 0<G)
    (hb : ∀j x,|F j x|≤B) {N : ℕ} (a : Fin N→Ω)
    (ha : a∉scaledDualBad μ F N B G K) :
    ∃Γ:J→ℝ, (∑j,|Γ j|)≤G ∧ entropy μ F Γ≤K ∧
      ∀j, |empirical F a j-mean μ F Γ j|≤K/G := by
  obtain ⟨lam,hlam,he,herr⟩ := exists_tilt_of_not_bad μ (normalizedObservables F B)
    (fun j=>(hF j).div_const B) (normalizedObservables_bound F hB hb) (mul_pos hG hB) a ha
  let Γ : J→ℝ := fun j=>lam j/B
  refine ⟨Γ,?_,?_,?_⟩
  · simp only [Γ,abs_div,abs_of_pos hB,←Finset.sum_div]
    exact (div_le_iff₀ hB).2 hlam
  · simpa only [entropy,normalizedObservables_potential] using he
  · intro j
    have hj := (abs_le_maxAbs (empirical (normalizedObservables F B) a-
      mean μ (normalizedObservables F B) lam) j).trans herr
    simp only [Pi.sub_apply,normalizedObservables_mean,normalizedObservables_empirical,←sub_div,
      abs_div,abs_of_pos hB] at hj
    have hd := (div_le_iff₀ hB).1 hj
    apply hd.trans_eq
    field_simp

end NeuralGeneralization.BatchTwoActivation
