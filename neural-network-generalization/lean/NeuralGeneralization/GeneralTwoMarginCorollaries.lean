import NeuralGeneralization.GeneralTwoMarginPolynomial
import NeuralGeneralization.GeneralMarginClipped

/-! Literal support comparisons, the numerical specialization, and the
paper's arbitrary positive residual-gap polynomial theorem. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.GeneralTwoMargin
open ConcreteModel RobustConfidence RobustMainAssembly
open GeneralMargin (polynomialBase)
variable {d N r : ℕ} {m u θ : ℝ}

lemma le_clip_iff {a z : ℝ} (hl : -m < a) (hu : a ≤ m) :
    a ≤ GeneralMargin.clip m z ↔ a ≤ z := by
  simp only [GeneralMargin.clip,le_max_iff,le_min_iff,not_le_of_gt hl,hu,false_or,true_and]

lemma clip_le_iff {a z : ℝ} (hl : -m ≤ a) (hu : a < m) :
    GeneralMargin.clip m z ≤ a ↔ z ≤ a := by
  simp only [GeneralMargin.clip,max_le_iff,min_le_iff,hl,not_le_of_gt hu,false_or,true_and]

/-- Clipped-score stability by θ implies both transport implications, also
when the clean score equals one of the triggering margins. -/
theorem of_clipped_variation (hp : Parameters m u θ) {φ : ℝ → ℝ} {c : ℝ}
    {w : Weights d N r} {x : Cube d}
    (hw : ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
      |GeneralMargin.clip m (noisyNetworkOutput φ w x η)-GeneralMargin.clip m (networkOutput φ w x)| ≤ θ) :
    atInput m u θ φ c w x := by
  have hm := hp.train_pos
  have hu := hp.test_nonneg
  have ht := hp.tolerance_nonneg
  have hg := hp.gap_pos
  change 0 < m-u-2*θ at hg
  let hF := GeneralMargin.clip_admissible hm hu hp.test_lt_train
  intro b
  constructor
  · intro hz η hη
    have he := abs_le.mp (show |labelReal b*GeneralMargin.clip m (noisyNetworkOutput φ w x η)-
        labelReal b*GeneralMargin.clip m (networkOutput φ w x)| ≤ θ by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hw η hη)
    have hc : labelReal b*GeneralMargin.clip m (networkOutput φ w x) = m := by
      rw [← hF.signed]
      exact GeneralMargin.clip_of_ge hm.le hz
    rw [← le_clip_iff (by linarith : -m < m-θ) (by linarith),hF.signed]
    linarith
  · intro hz η hη
    have he := abs_le.mp (show |labelReal b*GeneralMargin.clip m (noisyNetworkOutput φ w x η)-
        labelReal b*GeneralMargin.clip m (networkOutput φ w x)| ≤ θ by
      simpa only [← mul_sub,abs_mul,abs_labelReal,one_mul] using hw η hη)
    have hc : labelReal b*GeneralMargin.clip m (networkOutput φ w x) ≤ u := by
      rw [← hF.signed]
      exact (clip_le_iff (by linarith) hp.test_lt_train).mpr hz
    rw [← clip_le_iff (by linarith : -m ≤ u+θ) (by linarith),hF.signed]
    linarith

/-- The general clipped-margin condition is a sufficient support condition
for the general two-level weakening, with θ=(m-u)/4. -/
theorem clipped_support_subset (hm : 0 < m) (hu : 0 ≤ u) (hum : u < m)
    (φ : ℝ → ℝ) (c : ℝ) :
    GeneralMargin.support (d := d) (N := N) (r := r) m u (GeneralMargin.clip m) φ c ⊆
      support m u ((m-u)/4) φ c := by
  intro w hw x
  apply of_clipped_variation (show Parameters m u ((m-u)/4) from
    ⟨hm,hu,by linarith,by dsimp [gap]; linarith⟩)
  simpa only [GeneralMargin.atInput,GeneralMargin.clip_gap hm hu hum] using hw x

lemma original_support (φ : ℝ → ℝ) (c : ℝ) :
    support (d := d) (N := N) (r := r) (1/2) (1/4) (1/16) φ c = TwoMarginTransport.support φ c := by
  ext w
  simp only [support,TwoMarginTransport.support,Set.mem_setOf_eq,atInput,TwoMarginTransport.atInput]
  norm_num

theorem test_redundant_of_global_margin (hp : Parameters m u θ) {z z' : ℝ} (hz : m < |z|)
    (htrain : ∀ b : Bool,m ≤ labelReal b*z → m-θ ≤ labelReal b*z') :
    ∀ b : Bool,labelReal b*z ≤ u → labelReal b*z' ≤ u+θ := by
  have hm := hp.train_pos
  have hu := hp.test_nonneg
  have hum := hp.test_lt_train
  intro b hb
  cases b
  · simp only [labelReal_false,neg_one_mul] at hb ⊢
    have ht := htrain true
    simp only [labelReal_true,one_mul] at ht
    rcases lt_abs.mp hz with hpos | hneg
    · linarith [ht hpos.le]
    · linarith
  · simp only [labelReal_true,one_mul] at hb ⊢
    have ht := htrain false
    simp only [labelReal_false,neg_one_mul] at ht
    rcases lt_abs.mp hz with hpos | hneg
    · linarith
    · linarith [ht (by linarith)]

/-- The sample bound can be stated using any positive residual gap after an
arbitrary nonnegative rounding allowance e, precisely as in the paper. -/
theorem residual_gap_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ m u θ e : ℝ,0 < m → 0 ≤ u → 0 ≤ θ → 0 ≤ e → 0 < m-u-2*θ-2*e → ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r 1 m c ε δ (m-u-2*θ-2*e))^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ globalMargin : Bool,
          0 < (smallPrior d N r σ).real (posteriorEvent m u θ c globalMargin B.computes S) ∧
          gibbsMarginRisk D (posterior (N := N) (r := r) m u θ c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u ≤ ε/3 ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) m u θ c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u x ≤ (2/3:ℝ)} ≤ ε := by
  obtain ⟨A,hA,k,h⟩ := polynomial
  refine ⟨A,hA,k,?_⟩
  intro m u θ e hm hu ht he hgap d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  have hbasegap : 0 < gap m u θ := by dsimp [gap]; linarith
  have hp : Parameters m u θ := ⟨hm,hu,ht,hbasegap⟩
  have hinv : (gap m u θ)⁻¹ ≤ (m-u-2*θ-2*e)⁻¹ := by
    have hg : m-u-2*θ-2*e ≤ gap m u θ := by dsimp [gap]; linarith
    simpa only [one_div] using one_div_le_one_div_of_le hgap hg
  have hbase : polynomialBase d C r 1 m c ε δ (gap m u θ) ≤
      polynomialBase d C r 1 m c ε δ (m-u-2*θ-2*e) := by
    unfold GeneralMargin.polynomialBase ScoreTransform.polynomialBase
    linarith
  have hnonneg : 0 ≤ polynomialBase d C r 1 m c ε δ (gap m u θ) :=
    (by norm_num : (0 : ℝ) ≤ 1).trans
      (GeneralMargin.polynomialBase_bounds d C r (by decide : 0 < 1) hm.le hc hε hδ hδ1 hbasegap).1
  exact h m u θ hp d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n
    ((mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hnonneg hbase k) hA.le).trans hn)

end NeuralGeneralization.GeneralTwoMargin
