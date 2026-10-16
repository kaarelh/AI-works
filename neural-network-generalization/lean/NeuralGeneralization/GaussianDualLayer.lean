import NeuralGeneralization.GaussianFieldCovariance
import NeuralGeneralization.CovarianceDualCertificate

/-! Entropy certificates for actual independent Gaussian rows, with finite
coefficient matrices fixed by the preceding network layers. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianDualLayer
open ConcreteModel FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt
open CompressionSampling DualCertificate ActualBoundedDual CovarianceDualLift BoundedDual
open TanhDifferential
variable {d N : ℕ} {J : Type*} [Fintype J]

def rows (A : Cube d → J → ℝ) (a : Fin N → J → ℝ) : Fin N → Cube d → ℝ :=
  fun i => fieldLinear A (a i)

@[fun_prop] theorem measurable_rows (A : Cube d → J → ℝ) : Measurable (rows (N := N) A) := by
  apply measurable_pi_lambda
  intro i
  exact (fieldLinear A).continuous.measurable.comp (measurable_pi_apply i)

theorem map_rows (A : Cube d → J → ℝ) :
    (iidSamples (standardLaw J) N).map (rows A) = iidSamples (fieldLaw A) N := by
  exact Measure.pi_map_pi (fun _ => (fieldLinear A).continuous.measurable.aemeasurable)

def badRows (A : Cube d → J → ℝ) (N : ℕ) (G K : ℝ) : Set (Fin N → J → ℝ) :=
  rows A ⁻¹' badEvent (fieldLaw A) (features Real.tanh) N G K

theorem badRows_measurable (A : Cube d → J → ℝ) (N : ℕ) (G K : ℝ) :
    MeasurableSet (badRows A N G K) := by
  exact (measurableSet_badEvent (fieldLaw A) (features Real.tanh)
    (fun p => (continuous_tanhPairValue p.1 p.2).measurable) N G K).preimage (measurable_rows A)

theorem badRows_tail (hd : 0 < d) (A : Cube d → J → ℝ)
    {N s : ℕ} (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples (standardLaw J) N).real (badRows A N G K) ≤
      Real.exp (4 * (d : ℝ) * (s : ℝ) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hb := CovarianceDualCertificate.covariance_bad_event_tail (fieldLaw A) hd
    Real.tanh continuous_tanh.measurable (fun x => (Real.abs_tanh_lt_one x).le) hN hs hG K
  rw [← map_rows A, Measure.real, Measure.map_apply (measurable_rows A)
    (measurableSet_badEvent (fieldLaw A) (features Real.tanh)
      (fun p => (continuous_tanhPairValue p.1 p.2).measurable) N G K)] at hb
  exact hb

theorem potential_eq (Γ : Cube d → Cube d → ℝ) :
    potential (features Real.tanh) (parameter Γ) = potentialValue Real.tanh Γ := by
  funext z
  rfl

theorem mean_eq_tiltedMoment (A : Cube d → J → ℝ) (Γ : Cube d → Cube d → ℝ) (x y : Cube d) :
    mean (fieldLaw A) (features Real.tanh) (parameter Γ) (x, y) = tiltedMoment A Γ x y := by
  unfold mean tiltedMoment
  rw [potential_eq]
  rfl

/-- Every good raw matrix supplies an actual bounded quadratic Gaussian tilt
whose covariance approximates that matrix's empirical activation covariance. -/
theorem exists_tilt_of_not_badRows (A : Cube d → J → ℝ) {N : ℕ} {G K : ℝ}
    (hG : 0 < G) (a : Fin N → J → ℝ) (ha : a ∉ badRows A N G K) :
    ∃ Γ : Cube d → Cube d → ℝ, (∀ x y, Γ x y = Γ y x) ∧ couplingMass Γ ≤ G ∧
      entropy (fieldLaw A) (features Real.tanh) (parameter Γ) ≤ K ∧
      ∀ x y, |(∑ i, Real.tanh (fieldLinear A (a i) x) *
        Real.tanh (fieldLinear A (a i) y)) / N - tiltedMoment A Γ x y| ≤ K / G := by
  obtain ⟨Γ, hsym, hΓ, hent, herr⟩ := CovarianceDualCertificate.covariance_lift_of_not_bad
    (fieldLaw A) Real.tanh continuous_tanh.measurable
    (fun x => (Real.abs_tanh_lt_one x).le) hG (rows A a) ha
  refine ⟨Γ, hsym, ?_, hent, ?_⟩
  · simpa only [couplingMass, SymmetricTilt.entryL1, Fintype.sum_prod_type] using hΓ
  intro x y
  have h := (abs_le_maxAbs (empirical (features Real.tanh) (rows A a) -
    mean (fieldLaw A) (features Real.tanh) (parameter Γ)) (x, y)).trans herr
  simpa only [Pi.sub_apply, empirical, features, rows, mean_eq_tiltedMoment] using h

variable {R : Type*} [Fintype R]

def rawBadRows (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    (N : ℕ) (G K : ℝ) : Set (Fin N → R → ℝ) :=
  rows H ⁻¹' badEvent (fieldLaw A) (features Real.tanh) N G K

theorem rawBadRows_measurable (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    (N : ℕ) (G K : ℝ) : MeasurableSet (rawBadRows A H N G K) :=
  (measurableSet_badEvent (fieldLaw A) (features Real.tanh)
    (fun p => (continuous_tanhPairValue p.1 p.2).measurable) N G K).preimage (measurable_rows H)

theorem map_raw_rows (A : Cube d → J → ℝ) (H : Cube d → R → ℝ) (v : ℝ≥0)
    (hcov : ∀ x y, (v : ℝ) * gram H x y = gram A x y) :
    (iidSamples (Measure.pi (fun _ : R => gaussianReal 0 v)) N).map (rows H) =
      iidSamples (fieldLaw A) N := by
  rw [show rows (N := N) H = (fun a i => fieldLinear H (a i)) from rfl,
    show iidSamples (Measure.pi (fun _ : R => gaussianReal 0 v)) N =
      Measure.pi (fun _ : Fin N => Measure.pi (fun _ : R => gaussianReal 0 v)) from rfl,
    Measure.pi_map_pi (fun _ => (fieldLinear H).continuous.measurable.aemeasurable)]
  simp_rw [GaussianFieldCovariance.map_field_eq_of_scaled_gram H v A hcov]
  rfl

theorem rawBadRows_tail (hd : 0 < d) (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    (v : ℝ≥0) (hcov : ∀ x y, (v : ℝ) * gram H x y = gram A x y)
    {N s : ℕ} (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples (Measure.pi (fun _ : R => gaussianReal 0 v)) N).real (rawBadRows A H N G K) ≤
      Real.exp (4 * (d : ℝ) * (s : ℝ) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hb := CovarianceDualCertificate.covariance_bad_event_tail (fieldLaw A) hd
    Real.tanh continuous_tanh.measurable (fun x => (Real.abs_tanh_lt_one x).le) hN hs hG K
  rw [← map_raw_rows A H v hcov, Measure.real, Measure.map_apply (measurable_rows H)
    (measurableSet_badEvent (fieldLaw A) (features Real.tanh)
      (fun p => (continuous_tanhPairValue p.1 p.2).measurable) N G K)] at hb
  exact hb

theorem exists_tilt_of_not_rawBadRows (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    {N : ℕ} {G K : ℝ} (hG : 0 < G) (a : Fin N → R → ℝ)
    (ha : a ∉ rawBadRows A H N G K) :
    ∃ Γ : Cube d → Cube d → ℝ, (∀ x y, Γ x y = Γ y x) ∧ couplingMass Γ ≤ G ∧
      entropy (fieldLaw A) (features Real.tanh) (parameter Γ) ≤ K ∧
      ∀ x y, |(∑ i, Real.tanh (fieldLinear H (a i) x) *
        Real.tanh (fieldLinear H (a i) y)) / N - tiltedMoment A Γ x y| ≤ K / G := by
  obtain ⟨Γ, hsym, hΓ, hent, herr⟩ := CovarianceDualCertificate.covariance_lift_of_not_bad
    (fieldLaw A) Real.tanh continuous_tanh.measurable
    (fun x => (Real.abs_tanh_lt_one x).le) hG (rows H a) ha
  refine ⟨Γ, hsym, ?_, hent, ?_⟩
  · simpa only [couplingMass, SymmetricTilt.entryL1, Fintype.sum_prod_type] using hΓ
  intro x y
  have h := (abs_le_maxAbs (empirical (features Real.tanh) (rows H a) -
    mean (fieldLaw A) (features Real.tanh) (parameter Γ)) (x, y)).trans herr
  simpa only [Pi.sub_apply, empirical, features, rows, mean_eq_tiltedMoment] using h

end NeuralGeneralization.GaussianDualLayer
end
