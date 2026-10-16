import NeuralGeneralization.PolynomialThresholdParity
import NeuralGeneralization.ConfidenceClipping
import NeuralGeneralization.SmallSampleCutoff
import NeuralGeneralization.BinomialAntiConcentration

/-! The finite ABFR obstruction transfers to actual margin predictions and
to actual confidence values without any posterior-mean classifier convention. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization
open ConfidenceClipping

/-- A low-degree polynomial classifies correctly wherever the confidence
is high outside the exceptional set. Its ABFR errors must therefore be
confidence failures or exceptions. -/
theorem confidence_failure_lower_of_polynomial_sign {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hst : s+2*t < d) (q : ClippingCube d → ℝ) (θ : ℝ)
    (V : Set (ClippingCube d))
    (hsign : ∀ x, θ < q x → x ∉ V → 0 < fullParity x * walshExpansion a x) :
    (Fintype.card (DegreeIndices d t) : ℝ)/Fintype.card (ClippingCube d) - fraction V ≤
      ConfidenceClipping.failure q θ := by
  classical
  have hpt := polynomial_threshold_parity_error a hdegree hst
  have hpoint (x : ClippingCube d) :
      (if binarySign (walshExpansion a x) = fullParity x then (0 : ℝ) else 1) ≤
      (if q x ≤ θ then (1 : ℝ) else 0) + (if x ∈ V then (1 : ℝ) else 0) := by
    by_cases hq : q x ≤ θ
    · split_ifs <;> norm_num
    by_cases hx : x ∈ V
    · split_ifs <;> norm_num
    have hh := hsign x (lt_of_not_ge hq) hx
    have he : binarySign (walshExpansion a x) = fullParity x := by
      rcases fullParity_sign x with hf | hf <;> rw [hf] at hh ⊢
      · simp only [one_mul] at hh
        simp [binarySign, hh.le]
      · have hn : ¬ 0 ≤ walshExpansion a x := by nlinarith
        simp [binarySign, hn]
    simp [he, hq, hx]
  have hm := mean_mono _ _ hpoint
  have he : uniformCubeMean (fun x =>
      (if q x ≤ θ then (1 : ℝ) else 0) + (if x ∈ V then (1 : ℝ) else 0)) =
      ConfidenceClipping.failure q θ + fraction V := by
    simp only [ConfidenceClipping.failure, fraction, uniformCubeMean, Set.mem_setOf_eq,
      Finset.sum_add_distrib, add_div]
    rfl
  rw [he] at hm
  change uniformParityError (walshExpansion a) ≤ _ at hm
  linarith

/-- Quantitative ABFR transfer through an actual squared approximation
error and a conditional-mean margin outside an exceptional set. -/
theorem confidence_failure_lower_of_ABFR_approximation {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hst : s+2*t < d) (q m : ClippingCube d → ℝ) (θ b : ℝ) (hb : 0 < b)
    (V : Set (ClippingCube d))
    (hmargin : ∀ x, θ < q x → x ∉ V → b ≤ fullParity x*m x) :
    (Fintype.card (DegreeIndices d t) : ℝ)/Fintype.card (ClippingCube d) - fraction V -
      uniformCubeMean (fun x => (m x-walshExpansion a x)^2)/b^2 ≤ ConfidenceClipping.failure q θ := by
  classical
  let T : Set (ClippingCube d) := {x | b ≤ |m x-walshExpansion a x|}
  have hbound := confidence_failure_lower_of_polynomial_sign a hdegree hst q θ (V ∪ T)
    (fun x hq hx => by
      have hV : x ∉ V := fun h => hx (Or.inl h)
      have hT : x ∉ T := fun h => hx (Or.inr h)
      have hr : |m x-walshExpansion a x| < b := lt_of_not_ge hT
      have hm := hmargin x hq hV
      have hd := abs_lt.mp hr
      rcases fullParity_sign x with hf | hf <;> rw [hf] at hm ⊢ <;> nlinarith)
  have hT := fraction_large_residual_le (fun x => m x-walshExpansion a x) b hb
  have hU := fraction_union_le V T
  change fraction T ≤ _ at hT
  linarith

/-- Margin predictions obey the same ABFR error bound, with their actual
classification convention including ties. -/
theorem parity_error_lower_of_ABFR_approximation {d s t : ℕ}
    (a : Finset (Fin d) → ℝ) (hdegree : ∀ S, a S ≠ 0 → S.card ≤ s)
    (hst : s+2*t < d) (z : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b)
    (hmargin : ∀ x, b ≤ |z x|) :
    (Fintype.card (DegreeIndices d t) : ℝ)/Fintype.card (ClippingCube d) -
      uniformCubeMean (fun x => (z x-walshExpansion a x)^2)/b^2 ≤ uniformParityError z := by
  classical
  let q : ClippingCube d → ℝ := fun x => if binarySign (z x)=fullParity x then 1 else 0
  have he : ConfidenceClipping.failure q (1/2) = uniformParityError z := by
    unfold ConfidenceClipping.failure fraction uniformParityError
    congr 1
    funext x
    simp only [Set.mem_setOf_eq, q]
    split_ifs <;> norm_num at *
  have h := confidence_failure_lower_of_ABFR_approximation a hdegree hst q z (1/2) b hb ∅
    (fun x hq hx => by
      have hs : binarySign (z x)=fullParity x := by
        by_contra hn
        norm_num [q, hn] at hq
      have hm := hmargin x
      rcases fullParity_sign x with hf | hf <;> rw [hf] at hs ⊢
      · have hz : 0 ≤ z x := by
          by_contra hn
          norm_num [binarySign, hn] at hs
        simpa [abs_of_nonneg hz] using hm
      · have hz : z x < 0 := by
          by_contra hn
          norm_num [binarySign, le_of_not_gt hn] at hs
        simpa [abs_of_neg hz] using hm)
  simpa only [he, fraction, Set.mem_empty_iff_false, if_false, mean_const, sub_zero] using h

namespace SmallSampleCutoff

/-- The exact finite ABFR lower bound approaches one half at our actual cutoff. -/
theorem eventually_ABFR_lower (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, cutoff d < d ∧
      (1/2 : ℝ)-ε ≤ (Fintype.card (DegreeIndices d ((d-cutoff d-1)/2)) : ℝ)/
        Fintype.card (ClippingCube d) := by
  have hcut := cutoff_div_rpow_tendsto (1/2) (by norm_num)
  have hconst : Tendsto (fun d : ℕ => (2 : ℝ)/((d : ℝ)+1)^(1/2 : ℝ)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop ((tendsto_rpow_atTop (by norm_num : (0 : ℝ)<1/2)).comp
      (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop))
  have hlim : Tendsto (fun d : ℕ => 2*((cutoff d : ℝ)+2)/Real.sqrt ((d : ℝ)+1))
      atTop (𝓝 0) := by
    simpa only [Real.sqrt_eq_rpow, mul_add, add_div, mul_div_assoc, mul_zero, add_zero] using
      (hcut.add hconst).const_mul 2
  filter_upwards [hlim.eventually (eventually_le_nhds hε), eventually_multiple_cutoff_le 2]
    with d he hd
  have hs : cutoff d < d := by have hp := cutoff_pos d; omega
  refine ⟨hs, ?_⟩
  exact (by linarith : (1/2 : ℝ)-ε ≤ 1/2-2*((cutoff d : ℝ)+2)/Real.sqrt ((d : ℝ)+1)).trans
    (degreeIndices_fraction_lower d (cutoff d) hs)

/-- Uniform small-sample parity obstruction for actual neural RKHS fields
with global margin. Its conclusion is one half minus any prescribed error. -/
theorem eventually_margin_parity_error (C : ℝ) (hC : 0 ≤ C) (m : ℕ)
    (b : ℝ) (hb : 0 < b) (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℝ, 0 ≤ n → n ≤ Real.exp (logDimension d^3) →
      ∀ k : ℕ, ∀ z : ClippingCube d → ℝ, (∀ x, b ≤ |z x|) →
      finiteQuadratic (walshPrecisionKernel (walshCoefficients (arcsineProfile d (k+1)))) z ≤
        C*((d : ℝ)+1)^m*(1+n) →
      (1/2 : ℝ)-ε ≤ uniformParityError z := by
  classical
  filter_upwards [eventually_ABFR_lower (ε/2) (by positivity),
    eventually_projection_error C hC m (b^2*(ε/2)) (by positivity)]
    with d hd he n hn hnmax k z hm henergy
  let a := maskCoefficients (lowBand d) (walshCoefficients z)
  have hdegree : ∀ S, a S ≠ 0 → S.card ≤ cutoff d := by
    intro S hS
    have hmem : S ∈ lowBand d := by
      by_contra hn
      exact hS (by simp [a, maskCoefficients, hn])
    exact (Finset.mem_filter.mp hmem).2.le
  have hst : cutoff d+2*((d-cutoff d-1)/2) < d := by omega
  have h := parity_error_lower_of_ABFR_approximation a hdegree hst z b hb hm
  have ht := he n hn hnmax k z henergy
  have hdiv : uniformCubeMean (fun x => (z x-walshExpansion a x)^2)/b^2 ≤ ε/2 := by
    apply (div_le_iff₀ (sq_pos_of_pos hb)).mpr
    simpa only [a, walshProjection, mul_comm] using ht
  linarith [hd.2]

end SmallSampleCutoff
end NeuralGeneralization
