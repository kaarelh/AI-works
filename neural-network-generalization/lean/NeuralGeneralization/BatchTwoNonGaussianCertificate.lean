import NeuralGeneralization.BatchTwoNonGaussianLindeberg
import NeuralGeneralization.GaussianDualLayer

/-! The actual non-Gaussian field law, its distribution-free empirical
certificate, and transfer to a genuine Gaussian quadratic tilt. The comparison
does not replace the learner's row distribution by its covariance. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel FiniteDifferential TanhDifferential GaussianFieldTilt
open CovarianceDualLift ActualBoundedDual BoundedDual BoundedTilt
open CompressionSampling DualCertificate

section Fields
variable {I J : Type*} [Fintype I] [Fintype J]

def actualFieldLaw (ν : CoordinateLaw) (A : I → J → ℝ) : Measure (I → ℝ) :=
  (Measure.pi (fun _ : J => ν.law)).map (fieldLinear A)

instance actualFieldLaw_probability (ν : CoordinateLaw) (A : I → J → ℝ) :
    IsProbabilityMeasure (actualFieldLaw ν A) :=
  Measure.isProbabilityMeasure_map (fieldLinear A).continuous.measurable.aemeasurable

theorem actualFieldLaw_gaussian (A : I → J → ℝ) :
    actualFieldLaw standardGaussian A = fieldLaw A := rfl

theorem actualField_partition (ν : CoordinateLaw) (A : I → J → ℝ) (Γ : I → I → ℝ) :
    partition (actualFieldLaw ν A) (potential (features Real.tanh) (parameter Γ)) =
      fieldPartition (fun _ : J => ν) Γ (fun j i => A i j) := by
  unfold partition actualFieldLaw
  rw [integral_map (fieldLinear A).continuous.measurable.aemeasurable]
  · apply integral_congr_ae
    exact ae_of_all _ (fun x => by
      simp only [fieldExp, fieldLinear_apply, potential, pairing, features, parameter,
        potentialValue, pairValue, Fintype.sum_prod_type, mul_assoc])
  · exact (measurable_potential (features Real.tanh)
      (measurable_features Real.tanh continuous_tanh.measurable) (parameter Γ)).exp.aestronglyMeasurable

end Fields

section Certificate
variable {d : ℕ} {J : Type*} [Fintype J]

def actualBadRows (ν : CoordinateLaw) (A : Cube d → J → ℝ)
    (N : ℕ) (G K : ℝ) : Set (Fin N → J → ℝ) :=
  GaussianDualLayer.rows A ⁻¹' badEvent (actualFieldLaw ν A) (features Real.tanh) N G K

theorem actualBadRows_measurable (ν : CoordinateLaw) (A : Cube d → J → ℝ)
    (N : ℕ) (G K : ℝ) : MeasurableSet (actualBadRows ν A N G K) :=
  (measurableSet_badEvent (actualFieldLaw ν A) (features Real.tanh)
    (measurable_features Real.tanh continuous_tanh.measurable) N G K).preimage
      (GaussianDualLayer.measurable_rows A)

theorem map_actual_rows (ν : CoordinateLaw) (A : Cube d → J → ℝ) (N : ℕ) :
    (iidSamples (Measure.pi (fun _ : J => ν.law)) N).map (GaussianDualLayer.rows A) =
      iidSamples (actualFieldLaw ν A) N :=
  Measure.pi_map_pi (fun _ => (fieldLinear A).continuous.measurable.aemeasurable)

/-- The exact actual-law bad-row event has the dimension-linear certificate tail.
It applies equally to the first layer and to each fixed preceding activation matrix. -/
theorem actualBadRows_tail (ν : CoordinateLaw) (hd : 0 < d) (A : Cube d → J → ℝ)
    {N s : ℕ} (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (iidSamples (Measure.pi (fun _ : J => ν.law)) N).real (actualBadRows ν A N G K) ≤
      Real.exp (4 * (d : ℝ) * (s : ℝ) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have h := CovarianceDualCertificate.covariance_bad_event_tail (actualFieldLaw ν A) hd
    Real.tanh continuous_tanh.measurable (fun t => (Real.abs_tanh_lt_one t).le) hN hs hG K
  rw [← map_actual_rows ν A N, Measure.real,
    Measure.map_apply (GaussianDualLayer.measurable_rows A)
      (measurableSet_badEvent (actualFieldLaw ν A) (features Real.tanh)
        (measurable_features Real.tanh continuous_tanh.measurable) N G K)] at h
  exact h

/-- A good first layer gives a tilt of its actual non-Gaussian field law. -/
theorem actual_covariance_lift (ν : CoordinateLaw) (A : Cube d → J → ℝ)
    {N : ℕ} {G K : ℝ} (hG : 0 < G) (a : Fin N → J → ℝ)
    (ha : a ∉ actualBadRows ν A N G K) :
    ∃ Γ : Cube d → Cube d → ℝ, (∀ x y, Γ x y = Γ y x) ∧ couplingMass Γ ≤ G ∧
      entropy (actualFieldLaw ν A) (features Real.tanh) (parameter Γ) ≤ K ∧
      ∀ x y, |(∑ i, Real.tanh (fieldLinear A (a i) x) *
          Real.tanh (fieldLinear A (a i) y)) / N -
          mean (actualFieldLaw ν A) (features Real.tanh) (parameter Γ) (x, y)| ≤ K / G := by
  obtain ⟨Γ, hsym, hΓ, hent, herr⟩ := CovarianceDualCertificate.covariance_lift_of_not_bad
    (actualFieldLaw ν A) Real.tanh continuous_tanh.measurable
    (fun t => (Real.abs_tanh_lt_one t).le) hG (GaussianDualLayer.rows A a) ha
  refine ⟨Γ, hsym, ?_, hent, ?_⟩
  · simpa only [couplingMass, SymmetricTilt.entryL1, Fintype.sum_prod_type] using hΓ
  · intro x y
    exact (abs_le_maxAbs _ (x, y)).trans herr

/-- Lindeberg transfers the whole bounded dual objective, rather than assuming
that the true row law is determined by its covariance. -/
theorem covariance_objective_transfer (ν : CoordinateLaw) {N : ℕ} (hN : 0 < N)
    (A : Cube d → Fin N → ℝ) (q : Cube d × Cube d → ℝ) (G : ℝ)
    (hG : 0 ≤ G) (hA : ∀ x j, |A x j| ≤ 1 / Real.sqrt N)
    (hsize : 4 * G ^ 2 ≤ (N : ℝ))
    (v : Cube d × Cube d → ℝ) (hv : entryL1 v ≤ G) :
    objective (fieldLaw A) (features Real.tanh) q v ≤
      objective (actualFieldLaw ν A) (features Real.tanh) q v +
        replacementConstant ν standardGaussian * lindebergPolynomial G / Real.sqrt N := by
  let Γ : Cube d → Cube d → ℝ := fun x y => v (x, y)
  have hΓ : couplingMass Γ ≤ G := by
    simpa only [couplingMass, entryL1, Fintype.sum_prod_type] using hv
  have hp : parameter Γ = v := by funext p; cases p; rfl
  have h := relative_lindeberg ν N hN Γ (fun j x => A x j) G hG hΓ
    (fun j x => hA x j) hsize
  rw [← actualField_partition ν A Γ, ← actualField_partition standardGaussian A Γ,
    actualFieldLaw_gaussian, hp] at h
  unfold objective
  linarith [(abs_le.mp h).2]

/-- Every good actual internal row matrix supplies a Gaussian proxy tilt with
the precise additional relative-Lindeberg error budget. -/
theorem gaussian_proxy_lift (ν : CoordinateLaw) {N : ℕ} (hN : 0 < N)
    (A : Cube d → Fin N → ℝ) {G K : ℝ} (hG : 0 < G)
    (hA : ∀ x j, |A x j| ≤ 1 / Real.sqrt N) (hsize : 4 * G ^ 2 ≤ (N : ℝ))
    (a : Fin N → Fin N → ℝ) (ha : a ∉ actualBadRows ν A N G K) :
    ∃ Γ : Cube d → Cube d → ℝ, (∀ x y, Γ x y = Γ y x) ∧ couplingMass Γ ≤ G ∧
      entropy (fieldLaw A) (features Real.tanh) (parameter Γ) ≤
        K + replacementConstant ν standardGaussian * lindebergPolynomial G / Real.sqrt N ∧
      ∀ x y, |(∑ i, Real.tanh (fieldLinear A (a i) x) *
        Real.tanh (fieldLinear A (a i) y)) / N - tiltedMoment A Γ x y| ≤
          (K + replacementConstant ν standardGaussian * lindebergPolynomial G / Real.sqrt N) / G := by
  have hrate (v : Cube d × Cube d → ℝ) (hv : entryL1 v ≤ G) :
      objective (actualFieldLaw ν A) (features Real.tanh)
        (empirical (features Real.tanh) (GaussianDualLayer.rows A a)) v ≤ K := by
    by_contra h
    exact ha ⟨v, hv, lt_of_not_ge h⟩
  obtain ⟨Γ, hsym, hΓ, hent, herr⟩ := exists_symmetric_covariance_lift (fieldLaw A)
    Real.tanh continuous_tanh.measurable (fun t => (Real.abs_tanh_lt_one t).le)
    (empirical (features Real.tanh) (GaussianDualLayer.rows A a)) hG
    (fun v hv => (covariance_objective_transfer ν hN A _ G hG.le hA hsize v hv).trans
      (add_le_add (hrate v hv) le_rfl))
  refine ⟨Γ, hsym, ?_, hent, ?_⟩
  · simpa only [couplingMass, SymmetricTilt.entryL1, Fintype.sum_prod_type] using hΓ
  · intro x y
    have h := (abs_le_maxAbs _ (x, y)).trans herr
    simpa only [Pi.sub_apply, empirical, features, GaussianDualLayer.rows,
      GaussianDualLayer.mean_eq_tiltedMoment] using h

end Certificate
end NeuralGeneralization.BatchTwoNonGaussian
