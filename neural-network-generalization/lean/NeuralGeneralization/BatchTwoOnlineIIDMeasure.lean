import NeuralGeneralization.BatchTwoOnlineIIDSampling
import Mathlib.Probability.ProductMeasure
import Mathlib.Probability.Distributions.Uniform
import Mathlib.Probability.ProbabilityMassFunction.Integrals

/-! # Actual infinite product laws and their exact finite-prefix distributions -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {X : Type*} [MeasurableSpace X]

def sequencePrefix (n : ℕ) (s : ℕ → X) : Fin n → X := fun i => s i.val

lemma measurable_sequencePrefix (n : ℕ) : Measurable (sequencePrefix (X := X) n) := by
  exact measurable_pi_lambda _ (fun i => measurable_pi_apply i.val)

/-- Restricting the actual countable product to its first `n` coordinates gives
exactly the finite product, including non-identical posterior laws. -/
theorem infinitePi_map_sequencePrefix (ν : ℕ → Measure X)
    [∀ i, IsProbabilityMeasure (ν i)] (n : ℕ) :
    (Measure.infinitePi ν).map (sequencePrefix n) = Measure.pi (fun i : Fin n => ν i.val) := by
  let e : (Finset.range n) ≃ Fin n :=
    { toFun := fun i => ⟨i.val,Finset.mem_range.mp i.property⟩
      invFun := fun i => ⟨i.val,Finset.mem_range.mpr i.isLt⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
  have he : sequencePrefix (X := X) n =
      (MeasurableEquiv.piCongrLeft (fun _ : Fin n => X) e) ∘ (Finset.range n).restrict := rfl
  rw [he, ← Measure.map_map
    (MeasurableEquiv.measurable (MeasurableEquiv.piCongrLeft (fun _ : Fin n => X) e))
    (Finset.measurable_restrict (Finset.range n)), Measure.infinitePi_map_restrict]
  exact Measure.pi_map_piCongrLeft e (fun i : Fin n => ν i.val)

variable [Fintype X] [MeasurableSingletonClass X]

/-- A genuine discrete probability measure with the specified real weights. -/
def finiteWeightLaw (p : X → ℝ) (hp : ∀ x, 0 ≤ p x) (hs : ∑ x,p x=1) : Measure X :=
  (PMF.ofFintype (fun x => ENNReal.ofReal (p x)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun x _ => hp x), hs]
    simp)).toMeasure

instance finiteWeightLaw_probability (p : X → ℝ) (hp : ∀ x, 0 ≤ p x) (hs : ∑ x,p x=1) :
    IsProbabilityMeasure (finiteWeightLaw p hp hs) := by unfold finiteWeightLaw; infer_instance

@[simp] lemma finiteWeightLaw_singleton (p : X → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hs : ∑ x,p x=1) (x : X) : finiteWeightLaw p hp hs {x}=ENNReal.ofReal (p x) := by
  unfold finiteWeightLaw
  rw [PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton x)]
  rfl

lemma finiteWeightLaw_lintegral (p : X → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hs : ∑ x,p x=1) (F : X → ℝ) (hF : ∀ x, 0 ≤ F x) :
    (∫⁻ x, ENNReal.ofReal (F x) ∂finiteWeightLaw p hp hs) =
      ENNReal.ofReal (∑ x,p x*F x) := by
  rw [lintegral_fintype, ENNReal.ofReal_sum_of_nonneg (fun x _ => mul_nonneg (hp x) (hF x))]
  apply Finset.sum_congr rfl
  intro x _
  rw [finiteWeightLaw_singleton, ENNReal.ofReal_mul (hp x), mul_comm]

lemma productWeightLaw_lintegral {I : Type*} [Fintype I]
    (p : I → X → ℝ) (hp : ∀ i x, 0 ≤ p i x) (hs : ∀ i, ∑ x,p i x=1)
    (F : (I → X) → ℝ) (hF : ∀ s, 0 ≤ F s) :
    (∫⁻ s, ENNReal.ofReal (F s) ∂Measure.pi (fun i => finiteWeightLaw (p i) (hp i) (hs i))) =
      ENNReal.ofReal (∑ s, independentWeight p s * F s) := by
  rw [lintegral_fintype,
    ENNReal.ofReal_sum_of_nonneg (fun s _ => mul_nonneg
      (independentWeight_nonneg p hp s) (hF s))]
  apply Finset.sum_congr rfl
  intro s _
  rw [Measure.pi_singleton]
  simp only [finiteWeightLaw_singleton]
  rw [ENNReal.ofReal_mul (independentWeight_nonneg p hp s)]
  have he : ENNReal.ofReal (independentWeight p s) = ∏ i, ENNReal.ofReal (p i (s i)) := by
    exact ENNReal.ofReal_prod_of_nonneg (fun i _ => hp i (s i))
  rw [he, mul_comm]

lemma productWeightLaw_event {I : Type*} [Fintype I]
    (p : I → X → ℝ) (hp : ∀ i x, 0 ≤ p i x) (hs : ∀ i, ∑ x,p i x=1)
    (E : (I → X) → Prop) :
    (Measure.pi (fun i => finiteWeightLaw (p i) (hp i) (hs i))) {s | E s} =
      ENNReal.ofReal (∑ s,if E s then independentWeight p s else 0) := by
  have he := productWeightLaw_lintegral p hp hs (fun s => if E s then (1:ℝ) else 0)
    (fun s => by split_ifs <;> norm_num)
  have hi : (fun s : I → X => ENNReal.ofReal (if E s then (1:ℝ) else 0)) =
      ({s | E s} : Set (I → X)).indicator (fun _ => (1:ℝ≥0∞)) := by
    funext s
    by_cases h : E s <;> simp [h]
  rw [hi, lintegral_indicator (Set.to_countable _).measurableSet] at he
  simpa only [lintegral_const, Measure.restrict_apply_univ, one_mul, mul_ite, mul_one, mul_zero] using he

variable [Nonempty X]

def uniformLaw (X : Type*) [MeasurableSpace X] [Fintype X] [Nonempty X] : Measure X :=
  (PMF.uniformOfFintype X).toMeasure

instance uniformLaw_probability : IsProbabilityMeasure (uniformLaw X) := by
  unfold uniformLaw
  infer_instance

@[simp] lemma uniformLaw_singleton (x : X) : uniformLaw X {x} = (Fintype.card X : ℝ≥0∞)⁻¹ := by
  unfold uniformLaw
  rw [PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton x)]
  exact PMF.uniformOfFintype_apply x

lemma uniformLaw_integral (F : X → ℝ) : (∫ x,F x ∂uniformLaw X)=finiteMean F := by
  unfold uniformLaw
  rw [PMF.integral_eq_sum]
  simp only [PMF.uniformOfFintype_apply, ENNReal.toReal_inv, ENNReal.toReal_natCast, smul_eq_mul]
  rw [← Finset.mul_sum]
  exact inv_mul_eq_div _ _

lemma uniformLaw_lintegral (F : X → ℝ) (hF : ∀ x, 0 ≤ F x) :
    (∫⁻ x,ENNReal.ofReal (F x) ∂uniformLaw X)=ENNReal.ofReal (finiteMean F) := by
  rw [← ofReal_integral_eq_lintegral_ofReal (Integrable.of_finite : Integrable F (uniformLaw X))
    (Filter.Eventually.of_forall hF), uniformLaw_integral]

lemma uniformLaw_event (E : X → Prop) :
    uniformLaw X {x | E x} = ENNReal.ofReal (finiteEvent E) := by
  have he := uniformLaw_lintegral (fun x => if E x then (1:ℝ) else 0)
    (fun x => by split_ifs <;> norm_num)
  have hi : (fun x => ENNReal.ofReal (if E x then (1:ℝ) else 0)) =
      ({x | E x} : Set X).indicator (fun _ => (1:ℝ≥0∞)) := by
    funext x
    by_cases h : E x <;> simp [h]
  rw [hi, lintegral_indicator (Set.to_countable _).measurableSet] at he
  simpa only [lintegral_const, Measure.restrict_apply_univ, one_mul, finiteEvent] using he

lemma pi_uniformLaw {I : Type*} [Fintype I] :
    Measure.pi (fun _ : I => uniformLaw X) = uniformLaw (I → X) := by
  apply Measure.ext_of_singleton
  intro s
  rw [Measure.pi_singleton]
  simp only [uniformLaw_singleton, Finset.prod_const, Finset.card_univ, Fintype.card_fun,
    Nat.cast_pow, ENNReal.inv_pow]

/-- The literal infinite IID uniform query law. -/
def iidQueryLaw (X : Type*) [MeasurableSpace X] [Fintype X] [Nonempty X] : Measure (ℕ → X) :=
  Measure.infinitePi (fun _ : ℕ => uniformLaw X)

instance iidQueryLaw_probability : IsProbabilityMeasure (iidQueryLaw X) := by
  unfold iidQueryLaw
  infer_instance

lemma iidQueryLaw_prefix (n : ℕ) :
    (iidQueryLaw X).map (sequencePrefix n) = uniformLaw (Fin n → X) := by
  unfold iidQueryLaw
  rw [infinitePi_map_sequencePrefix]
  convert pi_uniformLaw (I := Fin n) (X := X) using 1 <;> congr! 3

lemma iidQueryLaw_prefix_lintegral (n : ℕ) (F : (Fin n → X) → ℝ) (hF : ∀ s, 0 ≤ F s) :
    (∫⁻ s,ENNReal.ofReal (F (sequencePrefix n s)) ∂iidQueryLaw X)=ENNReal.ofReal (finiteMean F) := by
  have he := lintegral_map (μ := iidQueryLaw X)
    (f := fun s : Fin n → X => ENNReal.ofReal (F s))
    (measurable_of_finite _) (measurable_sequencePrefix n)
  rw [iidQueryLaw_prefix] at he
  exact he.symm.trans (uniformLaw_lintegral F hF)

lemma iidQueryLaw_prefix_event (n : ℕ) (E : (Fin n → X) → Prop) :
    iidQueryLaw X {s | E (sequencePrefix n s)} = ENNReal.ofReal (finiteEvent E) := by
  have he := Measure.map_apply (μ := iidQueryLaw X) (f := sequencePrefix (X := X) n)
    (measurable_sequencePrefix n) ((Set.to_countable {s : Fin n → X | E s}).measurableSet)
  rw [iidQueryLaw_prefix] at he
  exact he.symm.trans (uniformLaw_event E)

end NeuralGeneralization.BatchTwoOnline
