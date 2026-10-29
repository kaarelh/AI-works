import CoordinateEntropyAnchors
import ReadoutProjectionAnchors

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalAnalytic

variable {X J H : Type*} [Fintype X] [DecidableEq X] [Fintype J]
    [NormedAddCommGroup H] [InnerProductSpace ℝ H] [CompleteSpace H]

/-- One actual anchor set simultaneously has small conditional entropy at all
layers and small readout projection error. Cardinality follows from a finite
penalized maximizer, so the theorem makes no efficient-search claim. -/
theorem joint_entropy_readout_anchors
    (Q G : J → Measure (X → ℝ))
    (hQ : ∀ j,IsProbabilityMeasure (Q j)) (hG : ∀ j,IsProbabilityMeasure (G j))
    (hKL : ∀ j,klDiv (Q j) (G j) ≠ ∞)
    (δ : J → ℝ) (hδ : ∀ j,0<δ j)
    (v : X → H) (b : H) (hv : ∀ x,‖v x‖≤1) {ρ : ℝ} (hρ : 0<ρ) :
    ∃ S : Finset X,
      (S.card:ℝ)≤(∑ j,(klDiv (Q j) (G j)).toReal/δ j)+‖b‖^2/ρ^2 ∧
      (∀ j x,coordinateEntropy (Q j) (G j) (insert x S)-coordinateEntropy (Q j) (G j) S≤δ j) ∧
      ∀ x,|⟪b-(featureSpan v S).starProjection b,v x⟫|≤ρ := by
  let energy : J⊕Unit → Finset X → ℝ := Sum.elim
    (fun j => coordinateEntropy (Q j) (G j)) (fun _ => readoutAnchorEnergy v b)
  let threshold : J⊕Unit → ℝ := Sum.elim δ (fun _ => ρ^2)
  let bound : J⊕Unit → ℝ := Sum.elim
    (fun j => (klDiv (Q j) (G j)).toReal) (fun _ => ‖b‖^2)
  have ht : ∀ j,0<threshold j := by
    intro j
    cases j with
    | inl j => exact hδ j
    | inr u => exact sq_pos_of_pos hρ
  have hz : ∀ j,0≤energy j ∅ := by
    intro j
    cases j with
    | inl j => exact ENNReal.toReal_nonneg
    | inr u => exact sq_nonneg _
  have hb : ∀ j S,energy j S≤bound j := by
    intro j S
    cases j with
    | inl j =>
      letI := hQ j
      letI := hG j
      exact coordinateEntropy_le (Q j) (G j) (hKL j) S
    | inr u => exact readoutAnchorEnergy_le v b S
  have hm : ∀ j,Monotone (energy j) := by
    intro j
    cases j with
    | inl j =>
      letI := hQ j
      letI := hG j
      exact coordinateEntropy_monotone (Q j) (G j) (hKL j)
    | inr u => exact readoutAnchorEnergy_monotone v b
  obtain ⟨S,hs,hi⟩ := finite_multi_energy_anchors energy threshold bound ht hz hb hm
  refine ⟨S,?_,fun j x => hi (.inl j) x,?_⟩
  · simpa only [bound,threshold,Fintype.sum_sum_type,Sum.elim_inl,Sum.elim_inr,
      Fintype.sum_unique] using hs
  · exact readout_anchor_error v b S hv hρ.le (fun x => hi (.inr ()) x)

#print axioms joint_entropy_readout_anchors
end ConditionalAnalytic
