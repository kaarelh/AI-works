import NeuralGeneralization.OnlineLowerReluConditionalLaw
import Mathlib.Algebra.Ring.Parity

/-! # The exact finite expansion into transversal Fourier coefficients -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def transversalCharacter {ι : Type*} [Fintype ι] [DecidableEq ι]
    (τ : Finset ι) (x y : ι → ℝ) : ℝ :=
  (∏ i ∈ τ, y i) * ∏ i ∈ Finset.univ \ τ, x i

theorem signed_projector_expansion {ι : Type*} [Fintype ι] [DecidableEq ι]
    (x y η : ι → ℝ) (hx : ∀ i, x i ^ 2 = 1) :
    (∏ i, x i) * (∏ i, (1 + η i * x i * y i)) =
      ∑ τ : Finset ι, (∏ i ∈ τ, η i) * transversalCharacter τ x y := by
  rw [← Finset.prod_mul_distrib]
  have hterm (i : ι) : x i * (1 + η i * x i * y i) = η i * y i + x i := by
    nlinarith [congrArg (fun z : ℝ => z * (η i * y i)) (hx i)]
  simp_rw [hterm]
  rw [Finset.prod_add]
  simp only [Finset.powerset_univ]
  apply Finset.sum_congr rfl
  intro τ _
  unfold transversalCharacter
  rw [Finset.prod_mul_distrib]
  ring

theorem finiteAverage_sum {Ω ν : Type*} [Fintype Ω] [Fintype ν] (f : Ω → ν → ℝ) :
    finiteAverage (fun ω => ∑ j, f ω j) = ∑ j, finiteAverage (fun ω => f ω j) := by
  unfold finiteAverage
  rw [Finset.sum_comm, Finset.sum_div]

def selectedAverage {α : Type*} [DecidableEq α] (selected : Finset α)
    (f : Finset α → ℝ) : ℝ := (∑ S ∈ selected.powerset, f S) / (2 : ℝ) ^ selected.card

theorem selectedAverage_sum {α ν : Type*} [DecidableEq α] [Fintype ν]
    (selected : Finset α) (f : Finset α → ν → ℝ) :
    selectedAverage selected (fun S => ∑ j, f S j) =
      ∑ j, selectedAverage selected (fun S => f S j) := by
  unfold selectedAverage
  rw [Finset.sum_comm, Finset.sum_div]

theorem selectedAverage_mul_left {α : Type*} [DecidableEq α]
    (selected : Finset α) (c : ℝ) (f : Finset α → ℝ) :
    selectedAverage selected (fun S => c * f S) = c * selectedAverage selected f := by
  unfold selectedAverage
  rw [← Finset.mul_sum]
  ring

def physicalRailExpectation {ι α : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (r : ι → ℕ)
    (f : Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) : ℝ :=
  selectedAverage selected (fun S => finiteAverage (fun y =>
    finiteAverage (fun z => finiteAverage (fun last => f S y z last))))

theorem physicalRailExpectation_sum {ι α ν : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α] [Fintype ν]
    (selected : Finset α) (r : ι → ℕ)
    (f : ν → Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) :
    physicalRailExpectation selected r (fun S y z last => ∑ j, f j S y z last) =
      ∑ j, physicalRailExpectation selected r (f j) := by
  unfold physicalRailExpectation
  simp_rw [finiteAverage_sum, selectedAverage_sum]

theorem physicalRailExpectation_mul_left {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (r : ι → ℕ) (c : ℝ)
    (f : Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) :
    physicalRailExpectation selected r (fun S y z last => c * f S y z last) =
      c * physicalRailExpectation selected r f := by
  unfold physicalRailExpectation
  simp_rw [finiteAverage_mul_left, selectedAverage_mul_left]

def oppositeRailParity {ι : Type*} (r : ι → ℕ) (y : ι → Bool)
    (z : (i : ι) → Fin (r i) → Bool) (last : ι → Bool) (i : ι) : ℝ :=
  railBit (y i) * freeRailParity r z i * railBit (last i)

def physicalTransversalCoefficient {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (τ : Finset ι)
    (f : Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) : ℝ :=
  physicalRailExpectation selected r (fun S y z last =>
    transversalCharacter τ (selectedRailParity blocks distinguished S)
      (oppositeRailParity r y z last) * f S y z last)

theorem physical_projector_expansion {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (blocks : ι → Finset α) (distinguished : ι → α) (r : ι → ℕ)
    (η : ι → Bool)
    (f : Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) :
    physicalRailExpectation selected r (fun S y z last =>
      ((∏ i, selectedRailParity blocks distinguished S i) *
        parityConditioningWeight blocks distinguished r η y z last S) * f S y z last) =
      ∑ τ : Finset ι, (∏ i ∈ τ, railBit (η i)) *
        physicalTransversalCoefficient selected blocks distinguished r τ f := by
  have hsq (S : Finset α) (i : ι) : selectedRailParity blocks distinguished S i ^ 2 = 1 := by
    have h := selectedRailParity_abs blocks distinguished S i
    nlinarith [sq_abs (selectedRailParity blocks distinguished S i)]
  have heq (S : Finset α) (y : ι → Bool) (z : (i : ι) → Fin (r i) → Bool)
      (last : ι → Bool) :
      (∏ i, selectedRailParity blocks distinguished S i) *
        parityConditioningWeight blocks distinguished r η y z last S =
      ∑ τ : Finset ι, (∏ i ∈ τ, railBit (η i)) *
        transversalCharacter τ (selectedRailParity blocks distinguished S)
          (oppositeRailParity r y z last) := by
    exact signed_projector_expansion _ _ _ (hsq S)
  simp_rw [heq, Finset.sum_mul, mul_assoc]
  rw [physicalRailExpectation_sum]
  simp_rw [physicalRailExpectation_mul_left]
  rfl

theorem selected_rail_product_eq_full {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (blocks : ι → Finset α) (distinguished : ι → α)
    (hfirst : ∀ i, distinguished i ∉ blocks i)
    (hpairwise : ∀ i j, i ≠ j → Disjoint (insert (distinguished i) (blocks i))
      (insert (distinguished j) (blocks j)))
    (hcover : Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)) = selected)
    (S : Finset α) :
    (∏ i, selectedRailParity blocks distinguished S i) = ∏ j ∈ selected, selectedSign S j := by
  calc
    (∏ i, selectedRailParity blocks distinguished S i) =
        ∏ i, ∏ j ∈ insert (distinguished i) (blocks i), selectedSign S j := by
      apply Finset.prod_congr rfl
      intro i _
      rw [Finset.prod_insert (hfirst i)]
      rfl
    _ = ∏ j ∈ Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)),
        selectedSign S j := by
      symm
      apply Finset.prod_biUnion
      intro i _ j _ hij
      exact hpairwise i j hij
    _ = _ := by rw [hcover]

theorem selected_rail_product_eq_parity {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (blocks : ι → Finset α) (distinguished : ι → α)
    (hfirst : ∀ i, distinguished i ∉ blocks i)
    (hpairwise : ∀ i j, i ≠ j → Disjoint (insert (distinguished i) (blocks i))
      (insert (distinguished j) (blocks j)))
    (hcover : Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)) = selected)
    (heven : Even selected.card) (S : Finset α) (hS : S ⊆ selected) :
    (∏ i, selectedRailParity blocks distinguished S i) = (-1 : ℝ) ^ S.card := by
  rw [selected_rail_product_eq_full selected blocks distinguished hfirst hpairwise hcover,
    prod_selectedSign, Finset.inter_eq_left.mpr hS, heven.neg_one_pow, one_mul]

theorem top_coefficient_projector_expansion {ι α : Type*}
    [Fintype ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (blocks : ι → Finset α) (distinguished : ι → α)
    (hfirst : ∀ i, distinguished i ∉ blocks i)
    (hpairwise : ∀ i j, i ≠ j → Disjoint (insert (distinguished i) (blocks i))
      (insert (distinguished j) (blocks j)))
    (hcover : Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)) = selected)
    (heven : Even selected.card) (r : ι → ℕ) (η : ι → Bool)
    (f : Finset α → (ι → Bool) → ((i : ι) → Fin (r i) → Bool) → (ι → Bool) → ℝ) :
    topSubsetCoefficient selected (fun S => finiteAverage (fun y : ι → Bool =>
      finiteAverage (fun z : (i : ι) → Fin (r i) → Bool =>
        finiteAverage (fun last : ι → Bool =>
          parityConditioningWeight blocks distinguished r η y z last S * f S y z last)))) =
      ∑ τ : Finset ι, (∏ i ∈ τ, railBit (η i)) *
        physicalTransversalCoefficient selected blocks distinguished r τ f := by
  rw [← physical_projector_expansion selected blocks distinguished r η f]
  unfold topSubsetCoefficient physicalRailExpectation selectedAverage
  congr 1
  apply Finset.sum_congr rfl
  intro S hS
  rw [← selected_rail_product_eq_parity selected blocks distinguished hfirst hpairwise
    hcover heven S (Finset.mem_powerset.mp hS)]
  simp_rw [← finiteAverage_mul_left]
  simp only [mul_assoc]

/-- A direct bound on the signed sum of the actual physical transversal
coefficients. Their fixed Fourier signs convert this to a sum of absolute
coefficients in the even-rail application. -/
theorem signed_transversal_randomized_minimum {ι α : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (hpairwise : ∀ i j, i ≠ j → Disjoint (insert (distinguished i) (blocks i))
      (insert (distinguished j) (blocks j)))
    (hcover : Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)) = selected)
    (heven : Even selected.card) (r : ι → ℕ) (a b : ι → ℝ)
    (η : ι → Bool) (bias : ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i) :
    |∑ τ : Finset ι, (∏ i ∈ τ, railBit (η i)) *
      physicalTransversalCoefficient selected blocks distinguished r τ
        (fun S y z last => max (unconditionedRailScore blocks distinguished r a b y z last bias S) 0)| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) *
        finiteAverage (minimumRailAmplitude a b) := by
  rw [← top_coefficient_projector_expansion selected blocks distinguished
    (fun i => hdisjoint i i) hpairwise hcover heven r η]
  exact block_constant_randomized_minimum_bound selected n hcard blocks distinguished
    hinj hdisjoint hselected r a b η bias hb hab

/-- The version with one unpaired selected rail. Representing its absent
opposite rail by zero amplitude makes its distinguished coefficient
deterministic, so no randomized minimum remains. -/
theorem signed_transversal_unpaired_bound {ι α : Type*}
    [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (selected : Finset α) (n : ℕ) (hcard : selected.card = n + 2)
    (blocks : ι → Finset α) (distinguished : ι → α)
    (hinj : Function.Injective distinguished)
    (hdisjoint : ∀ i j, distinguished i ∉ blocks j)
    (hselected : ∀ i, distinguished i ∈ selected)
    (hpairwise : ∀ i j, i ≠ j → Disjoint (insert (distinguished i) (blocks i))
      (insert (distinguished j) (blocks j)))
    (hcover : Finset.univ.biUnion (fun i => insert (distinguished i) (blocks i)) = selected)
    (heven : Even selected.card) (r : ι → ℕ) (a b : ι → ℝ)
    (η : ι → Bool) (bias : ℝ) (hb : ∀ i, 0 ≤ b i) (hab : ∀ i, b i ≤ a i)
    (i : ι) (hbi : b i = 0) :
    |∑ τ : Finset ι, (∏ j ∈ τ, railBit (η j)) *
      physicalTransversalCoefficient selected blocks distinguished r τ
        (fun S y z last => max (unconditionedRailScore blocks distinguished r a b y z last bias S) 0)| ≤
      (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) * a i := by
  have h := signed_transversal_randomized_minimum selected n hcard blocks distinguished
    hinj hdisjoint hselected hpairwise hcover heven r a b η bias hb hab
  exact h.trans (mul_le_mul_of_nonneg_left
    (average_minimumRailAmplitude_le_unpaired a b i hbi) (by positivity))

end NeuralGeneralization.OnlineLowerRelu
