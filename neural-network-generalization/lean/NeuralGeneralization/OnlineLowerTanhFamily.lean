import NeuralGeneralization.OnlineLowerCarrierRails
import NeuralGeneralization.OnlineLowerIncrementSplit
import NeuralGeneralization.OnlineLowerReluFamily

/-! # The literal tanh family with split distinguished columns

The prefix/path coordinates are the checked ReLU construction; two extra
logical coordinates have repeated private loop columns whose increments
sum exactly to H. Every increment is at most max R 6. A shared physical
carrier makes all transversal supports odd.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

abbrev logicalDim (k : ℕ) : ℕ := OnlineLowerRelu.Family.logicalDim k + 2
abbrev pairDim (R H k : ℕ) : ℕ := OnlineLowerRelu.Family.pairDim k + 2 * splitCount H R

@[simp] theorem logicalDim_eq (k : ℕ) : logicalDim k = 6*k+6 := by
  unfold logicalDim
  rw [OnlineLowerRelu.Family.logicalDim_eq]

def logicalIndex (k : ℕ) :
    (Fin (OnlineLowerRelu.Family.logicalDim k) ⊕ Fin 2) ≃ Fin (logicalDim k) := finSumFinEquiv

def oldLogical (k : ℕ) : Fin (OnlineLowerRelu.Family.logicalDim k) ↪ Fin (logicalDim k) :=
  ⟨fun i => logicalIndex k (.inl i), fun _ _ h => Sum.inl.inj ((logicalIndex k).injective h)⟩

def pairIndex (R H k : ℕ) :
    (Fin (OnlineLowerRelu.Family.pairDim k) ⊕ (Fin 2 × Fin (splitCount H R))) ≃
      Fin (pairDim R H k) :=
  (Equiv.sumCongr (Equiv.refl _) finProdFinEquiv).trans finSumFinEquiv

def rawColumn (R H k : ℕ) :
    Fin (OnlineLowerRelu.Family.pairDim k) ⊕ (Fin 2 × Fin (splitCount H R)) →
      Finset (Fin (logicalDim k))
  | .inl i => (OnlineLowerRelu.Family.column k i).map (oldLogical k)
  | .inr z => {logicalIndex k (.inr z.1)}

def column (R H k : ℕ) (i : Fin (pairDim R H k)) : Finset (Fin (logicalDim k)) :=
  rawColumn R H k ((pairIndex R H k).symm i)

@[simp] theorem column_old (R H k : ℕ) (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    column R H k (pairIndex R H k (.inl i)) =
      (OnlineLowerRelu.Family.column k i).map (oldLogical k) := by simp [column, rawColumn]

@[simp] theorem column_distinguished (R H k : ℕ) (b : Fin 2) (j : Fin (splitCount H R)) :
    column R H k (pairIndex R H k (.inr (b,j))) = {logicalIndex k (.inr b)} := by
  simp [column, rawColumn]

theorem column_card_le (R H k : ℕ) (i : Fin (pairDim R H k)) :
    (column R H k i).card ≤ 2 := by
  obtain ⟨z,rfl⟩ := (pairIndex R H k).surjective i
  cases z with
  | inl j => simpa using OnlineLowerRelu.Family.column_card_le k j
  | inr j => simp [column, rawColumn]

def privatePair (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) (i : Fin (logicalDim k)) :
    Fin (pairDim R H k) :=
  pairIndex R H k (match (logicalIndex k).symm i with
    | .inl j => .inl (OnlineLowerRelu.Family.privatePair k j)
    | .inr b => .inr (b, ⟨0, splitCount_pos H R hH hR⟩))

@[simp] theorem column_privatePair (R H k : ℕ) (hR : 0 < R) (hH : 0 < H)
    (i : Fin (logicalDim k)) : column R H k (privatePair R H k hR hH i) = {i} := by
  obtain ⟨z,rfl⟩ := (logicalIndex k).surjective i
  cases z <;> simp [privatePair, oldLogical]

def rawIncrement (R H k : ℕ) :
    Fin (OnlineLowerRelu.Family.pairDim k) ⊕ (Fin 2 × Fin (splitCount H R)) → ℕ
  | .inl i => OnlineLowerRelu.Family.increment k i
  | .inr z => splitIncrement H R z.2

def increment (R H k : ℕ) (i : Fin (pairDim R H k)) : ℕ :=
  rawIncrement R H k ((pairIndex R H k).symm i)

@[simp] theorem increment_old (R H k : ℕ) (i : Fin (OnlineLowerRelu.Family.pairDim k)) :
    increment R H k (pairIndex R H k (.inl i)) = OnlineLowerRelu.Family.increment k i := by
  simp [increment, rawIncrement]

@[simp] theorem increment_distinguished (R H k : ℕ) (b : Fin 2) (j : Fin (splitCount H R)) :
    increment R H k (pairIndex R H k (.inr (b,j))) = splitIncrement H R j := by
  simp [increment, rawIncrement]

theorem increment_bounds (R H k : ℕ) (hR : 6 ≤ R) (i : Fin (pairDim R H k)) :
    0 < increment R H k i ∧ increment R H k i ≤ R := by
  obtain ⟨z,rfl⟩ := (pairIndex R H k).surjective i
  rcases z with j | ⟨b,j⟩
  · rw [increment_old]
    exact ⟨lt_of_lt_of_le (by norm_num : 0 < 2) (OnlineLowerRelu.Family.increment_bounds k j).1,
      (OnlineLowerRelu.Family.increment_bounds k j).2.trans hR⟩
  · rw [increment_distinguished]
    exact ⟨splitIncrement_pos H R (by omega) j, splitIncrement_le H R (by omega) j⟩

theorem increment_even (R H k : ℕ) (hR : Even R) (hH : Even H)
    (i : Fin (pairDim R H k)) : Even (increment R H k i) := by
  obtain ⟨z,rfl⟩ := (pairIndex R H k).surjective i
  rcases z with j | ⟨b,j⟩
  · simpa using OnlineLowerRelu.Family.increment_even k j
  · simpa using splitIncrement_even H R hH hR j

theorem increment_sum (R H k : ℕ) :
    (∑ i, increment R H k i) = 4 * OnlineLowerRelu.Family.pairDim k + 2*H := by
  rw [← (pairIndex R H k).sum_comp (increment R H k)]
  simp only [increment, Equiv.symm_apply_apply]
  rw [Fintype.sum_sum_type, Fintype.sum_prod_type]
  simp only [rawIncrement, OnlineLowerRelu.Family.increment_sum, splitIncrement_sum,
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]

def size (R H k : ℕ) (i : Fin (pairDim R H k)) : Bool → ℕ
  | false => R
  | true => R + increment R H k i

@[simp] theorem size_false (R H k : ℕ) (i : Fin (pairDim R H k)) : size R H k i false = R := rfl
@[simp] theorem size_true (R H k : ℕ) (i : Fin (pairDim R H k)) :
    size R H k i true = R + increment R H k i := rfl

theorem size_pos (R H k : ℕ) (hR : 0 < R) : ∀ i b, 0 < size R H k i b := by
  intro i b
  cases b <;> simp <;> omega

theorem size_even (R H k : ℕ) (hR : Even R) (hH : Even H) : ∀ i b, Even (size R H k i b) := by
  intro i b
  cases b
  · exact hR
  · exact hR.add (increment_even R H k hR hH i)

abbrev dimension (R H k : ℕ) : ℕ := carrierDimension (size R H k)

theorem dimension_eq (R H k : ℕ) :
    dimension R H k = 1 + 2 * pairDim R H k * R + 4 * OnlineLowerRelu.Family.pairDim k + 2*H := by
  unfold dimension carrierDimension
  rw [railDimension_eq]
  simp only [size_false, size_true]
  have he : (∑ i : Fin (pairDim R H k), (R + (R + increment R H k i))) =
      2 * pairDim R H k * R + ∑ i, increment R H k i := by
    simp_rw [show ∀ i : Fin (pairDim R H k), R + (R + increment R H k i) = 2*R + increment R H k i by intro i; omega]
    rw [Finset.sum_add_distrib]
    simp
    ring
  rw [he, increment_sum]
  omega

def physicalCode (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) :
    WalshCodeMap (dimension R H k) (logicalDim k) :=
  carrierCode (size R H k) (column R H k) (privatePair R H k hR hH)
    (size_pos R H k hR) (column_privatePair R H k hR hH)

def target (R H k : ℕ) : BooleanFunction (dimension R H k) :=
  physicalParityTarget (carrierBase (size R H k)) (carrierColumn (size R H k) (column R H k))

@[simp] theorem physicalCode_support (R H k : ℕ) (hR : 0 < R) (hH : 0 < H)
    (s : Finset (Fin (logicalDim k))) :
    (physicalCode R H k hR hH).support s = carrierSupport (size R H k) (column R H k) s := rfl


theorem support_odd (R H k : ℕ) (hR : Even R) (hH : Even H)
    (s : Finset (Fin (logicalDim k))) :
    Odd ((carrierSupport (size R H k) (column R H k) s).card) := by
  rw [carrierSupport_card]
  exact (by decide : Odd (1:ℕ)).add_even
    (Finset.even_sum _ (fun i _ => size_even R H k hR hH i _))

theorem target_circuit (R H k : ℕ) (hR : 0 < R) (hH : 0 < H) :
    HasCircuitAtMost (target R H k) (17 * dimension R H k + 5) := by
  have hm : 1 ≤ logicalDim k := by rw [logicalDim_eq]; omega
  obtain ⟨_,hc,_⟩ := physicalParityTarget_resources
    (carrierBase (size R H k)) (carrierColumn (size R H k) (column R H k))
    (carrierPrivate (size R H k) (privatePair R H k hR hH) (size_pos R H k hR))
    (carrierColumn_private (size R H k) (column R H k) (privatePair R H k hR hH)
      (size_pos R H k hR) (column_privatePair R H k hR hH))
    (by
      intro j
      refine Fin.cases ?_ (fun j => ?_) j
      · simp
      · exact column_card_le R H k _) hm
    (Nat.le_mul_of_pos_right (dimension R H k) (by omega : 0 < logicalDim k))
  exact hc

end NeuralGeneralization.OnlineLowerTanh.Family
