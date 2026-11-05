import NeuralGeneralization.GeneralMarginPolynomial

/-! The paper's literal clipping-at-m corollary, with arbitrary m>u>=0. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel RobustConfidence RobustMainAssembly

/-- Exact support correspondence: the variation tolerance is (m-u)/4. -/
lemma clipped_atInput_iff {d N r : ℕ} {m u : ℝ}
    (hm : 0 < m) (hu : 0 ≤ u) (hum : u < m)
    (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) :
    atInput m u (clip m) φ c w x ↔
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        |clip m (noisyNetworkOutput φ w x η)-clip m (networkOutput φ w x)| ≤ (m-u)/4 := by
  unfold atInput
  rw [clip_gap hm hu hum]

/-- The original main support is recovered at margins 1/2 and 1/4. -/
lemma original_support {d N r : ℕ} (φ : ℝ → ℝ) (c : ℝ) :
    support (d := d) (N := N) (r := r) (1/2) (1/4) (clip (1/2)) φ c = robustEvent φ c := by
  ext w
  simp only [support,Set.mem_setOf_eq,atInput,robustEvent,clip,clippedScore,gap]
  norm_num

/-- Sign scoring at m=1/2 permits the paper's 1/8 score tolerance. -/
lemma sign_atInput_iff {d N r : ℕ} (φ : ℝ → ℝ) (c : ℝ)
    (w : Weights d N r) (x : Cube d) :
    atInput (1/2) 0 (clip (1/2)) φ c w x ↔
      ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
        |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/8 := by
  rw [clipped_atInput_iff (by norm_num) (by norm_num) (by norm_num)]
  norm_num [clip,clippedScore]

/-- General training and test margins: a universal polynomial in the original
parameters, m, and (m-u)^(-1), for the actual Gaussian-conditioned learner. -/
theorem clipped_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ m u : ℝ,0 < m → 0 ≤ u → u < m → ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r 1 m c ε δ (m-u))^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ globalMargin : Bool,
          0 < (smallPrior d N r σ).real (posteriorEvent m u (clip m) c globalMargin B.computes S) ∧
          gibbsMarginRisk D (posterior (N := N) (r := r) m u (clip m) c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u ≤ ε/3 ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) m u (clip m) c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u x ≤ (2/3:ℝ)} ≤ ε := by
  obtain ⟨A,hA,k,h⟩ := polynomial
  refine ⟨A,hA,k,?_⟩
  intro m u hm hu hum
  simpa only [clip_gap hm hu hum] using h m u (clip m) (clip_admissible hm hu hum)

end NeuralGeneralization.GeneralMargin
