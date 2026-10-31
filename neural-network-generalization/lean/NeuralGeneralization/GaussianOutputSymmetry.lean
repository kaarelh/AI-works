import NeuralGeneralization.ModelFacts
import NeuralGeneralization.MarginRescaling

/-! Exact output-sign symmetry of the actual Gaussian function prior, and
one-half label confidence before observing data. The global margin event is
preserved; no symmetry of the target or activation is assumed. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
open CompressionSampling

private def reflectCoordinate {d N r : ℕ} : WeightIndex d N r → ℝ → ℝ
  | Sum.inl _, x => x
  | Sum.inr (Sum.inl _), x => x
  | Sum.inr (Sum.inr _), x => -x

private theorem measurable_reflectCoordinate {d N r : ℕ} (i : WeightIndex d N r) :
    Measurable (reflectCoordinate i) := by
  rcases i with ij | (sij | j)
  · change Measurable (fun x : ℝ => x)
    exact measurable_id
  · change Measurable (fun x : ℝ => x)
    exact measurable_id
  · change Measurable (fun x : ℝ => -x)
    exact measurable_neg

@[fun_prop] theorem measurable_negateReadout {d N r : ℕ} :
    Measurable (rescaleReadout (d := d) (N := N) (r := r) (-1)) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ij | (sij | j) <;> dsimp [rescaleReadout] <;> fun_prop

theorem productGaussian_map_negateReadout {d N r : ℕ} (v : WeightIndex d N r → ℝ) :
    (productGaussian d N r v).map (rescaleReadout (-1)) = productGaussian d N r v := by
  have he : rescaleReadout (d := d) (N := N) (r := r) (-1) =
      fun w i => reflectCoordinate i (w i) := by
    funext w i
    rcases i with ij | (sij | j) <;> simp [rescaleReadout, reflectCoordinate]
  rw [he, productGaussian, Measure.pi_map_pi (fun i => (measurable_reflectCoordinate i).aemeasurable)]
  congr 1
  funext i
  rcases i with ij | (sij | j)
  · change (gaussianReal 0 (v (Sum.inl ij)).toNNReal).map id = _
    exact Measure.map_id
  · change (gaussianReal 0 (v (Sum.inr (Sum.inl sij))).toNNReal).map id = _
    exact Measure.map_id
  · change (gaussianReal 0 (v (Sum.inr (Sum.inr j))).toNNReal).map (fun x : ℝ => -x) = _
    simp only [gaussianReal_map_neg, neg_zero]

theorem negateReadout_preimage_margin {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (g : BooleanFunction d) :
    rescaleReadout (-1) ⁻¹' (marginEvent (N := N) (r := r) φ a g) =
      marginEvent φ a (fun x => !(g x)) := by
  ext w
  simp only [Set.mem_preimage, marginEvent, Set.mem_setOf_eq, rescaleReadout_output]
  constructor <;> intro h x <;> have hx := h x <;>
    cases hg : g x <;> simpa [hg, labelReal] using hx

theorem gaussian_functionMass_not {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (a : ℝ) (v : WeightIndex d N r → ℝ) (g : BooleanFunction d) :
    functionMass φ a (productGaussian d N r v) (fun x => !(g x)) =
      functionMass φ a (productGaussian d N r v) g := by
  unfold functionMass
  rw [← negateReadout_preimage_margin φ a g,
    ← Measure.map_apply measurable_negateReadout (isOpen_marginEvent hφ a g).measurableSet,
    productGaussian_map_negateReadout]

def functionNegation (d : ℕ) : Equiv.Perm (BooleanFunction d) where
  toFun g x := !(g x)
  invFun g x := !(g x)
  left_inv g := by funext x; simp
  right_inv g := by funext x; simp

theorem correctConfidence_eq_half_of_sign_symmetry {d : ℕ}
    (p : BooleanFunction d → ℝ) (hsum : ∑ g, p g = 1)
    (hsym : ∀ g, p (fun x => !(g x)) = p g)
    (f : BooleanFunction d) (x : Cube d) : correctConfidence f p x = 1/2 := by
  classical
  have he : (∑ g, if g x = f x then p g else 0) =
      ∑ g, if g x ≠ f x then p g else 0 := by
    calc
      _ = ∑ g, if functionNegation d g x = f x then p (functionNegation d g) else 0 :=
        (Equiv.sum_comp (functionNegation d) (fun g => if g x = f x then p g else 0)).symm
      _ = _ := by
        apply Finset.sum_congr rfl
        intro g _
        change (if (!(g x)) = f x then p (fun y => !(g y)) else 0) = _
        rw [hsym g]
        cases g x <;> cases f x <;> simp
  have ht : (∑ g, if g x = f x then p g else 0) +
      (∑ g, if g x ≠ f x then p g else 0) = 1 := by
    rw [← Finset.sum_add_distrib]
    convert hsum using 1
    apply Finset.sum_congr rfl
    intro g _
    by_cases h : g x = f x <;> simp [h]
  unfold correctConfidence
  linarith

theorem gaussian_empty_correctConfidence {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (a : ℝ) (v : WeightIndex d N r → ℝ) (f : BooleanFunction d)
    (s : Fin 0 → Cube d) (hf : 0 < functionMass φ a (productGaussian d N r v) f)
    (x : Cube d) :
    correctConfidence f (networkPosterior φ a (productGaussian d N r v) f s) x = 1/2 := by
  apply correctConfidence_eq_half_of_sign_symmetry _
    (networkPosterior_sum φ a (productGaussian d N r v) f s hf) _ f x
  intro g
  simp only [networkPosterior, NeuralGeneralization.posterior, consistent, Fin.forall_fin_zero,
    if_true, gaussian_functionMass_not hφ a v g]

theorem gaussian_empty_confidenceFailure {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (a : ℝ) (v : WeightIndex d N r → ℝ) (f : BooleanFunction d)
    (s : Fin 0 → Cube d) (hf : 0 < functionMass φ a (productGaussian d N r v) f)
    (D : InputLaw d) :
    confidenceFailure D f (networkPosterior φ a (productGaussian d N r v) f s) = 1 := by
  classical
  unfold confidenceFailure
  simp_rw [gaussian_empty_correctConfidence hφ a v f s hf, if_pos (by norm_num : (1/2 : ℝ) ≤ 2/3)]
  exact D.sum_one

end NeuralGeneralization.ConcreteModel
