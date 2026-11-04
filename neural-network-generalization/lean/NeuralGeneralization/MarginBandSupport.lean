import NeuralGeneralization.MarginBandScore

/-! Measurable margin-band support, its relation to the primary clipped
support, and its sufficient condition for two-margin transport. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.MarginBand
open ConcreteModel
variable {d N r : ℕ}

def atInput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
    |score (noisyNetworkOutput φ w x η)-score (networkOutput φ w x)| ≤ 1/16

def support (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ x,atInput φ c w x}

lemma isClosed_atInput {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : IsClosed {w : Weights d N r | atInput φ c w x} := by
  have heq : {w : Weights d N r | atInput φ c w x} =
      {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 →
        |score (noisyNetworkOutput φ w x (scaleDisturbance (robustRadius c w) η))-
          score (networkOutput φ w x)| ≤ 1/16} := by
    ext w
    exact TwoMarginTransport.all_noise_iff_unitBall (robustRadius_pos hc w) _
  rw [heq]
  simp only [Set.setOf_forall]
  exact isClosed_iInter fun η => isClosed_iInter fun _ =>
    isClosed_le (((continuous_score.comp
      (TwoMarginTransport.continuous_scaledNoiseOutput hφ c x η)).sub
      (continuous_score.comp (continuous_networkOutput hφ x))).abs) continuous_const

lemma measurable_support {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter fun x => (isClosed_atInput hφ hc x).measurableSet

lemma of_clipped_atInput {φ : ℝ → ℝ} {c : ℝ} {w : Weights d N r} {x : Cube d}
    (hw : stableAt φ c w x) : atInput φ c w x :=
  fun η hη => (score_clipped_contraction _ _).trans (hw η hη)

lemma to_twoMargin_atInput {φ : ℝ → ℝ} {c : ℝ} {w : Weights d N r} {x : Cube d}
    (hw : atInput φ c w x) : TwoMarginTransport.atInput φ c w x := by
  intro b
  constructor
  · intro hz η hη
    exact (transport_of_score_close (hw η hη) b).1 hz
  · intro hz η hη
    exact (transport_of_score_close (hw η hη) b).2 hz

/-- The three literal label-free support sets are ordered at the same
calibrated radius; no prior or training likelihood has been changed. -/
theorem support_inclusions (φ : ℝ → ℝ) (c : ℝ) :
    robustEvent (d := d) (N := N) (r := r) φ c ⊆ support φ c ∧
      support (d := d) (N := N) (r := r) φ c ⊆ TwoMarginTransport.support φ c :=
  ⟨fun _ hw x => of_clipped_atInput (hw x),fun _ hw x => to_twoMargin_atInput (hw x)⟩

/-- An actual enclosure of every perturbed raw output gives the manuscript's
endpoint interval certificate without controlling intermediate outputs. -/
theorem interval_certificate {φ : ℝ → ℝ} {c : ℝ} {w : Weights d N r} {x : Cube d}
    (B : ℝ)
    (henclose : ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
      networkOutput φ w x-B ≤ noisyNetworkOutput φ w x η ∧
        noisyNetworkOutput φ w x η ≤ networkOutput φ w x+B)
    (hcertificate : max (score (networkOutput φ w x+B)-score (networkOutput φ w x))
      (score (networkOutput φ w x)-score (networkOutput φ w x-B)) ≤ 1/16) :
    atInput φ c w x := by
  intro η hη
  have hh := henclose η hη
  have hlo := score_monotone hh.1
  have hhi := score_monotone hh.2
  have hc := max_le_iff.mp hcertificate
  exact abs_le.mpr ⟨by linarith [hc.2],by linarith [hc.1]⟩

end NeuralGeneralization.MarginBand
