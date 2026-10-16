import NeuralGeneralization.Network
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Lean.Elab.Tactic.Omega

/-!
# Actual finite cloning of the neural-network parameters

The construction replicates each original hidden neuron `k` times and pads
with disconnected neurons. Padding does not require `φ 0 = 0`.
Theorems concern the concrete `Weights` and `networkOutput` of `Model.lean`.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

variable {d C N r k p : ℕ}

/-- `e` enumerates the active copies and disconnected padding positions. -/
def clonedWeights (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) : Weights d N r
  | Sum.inl (i, j) =>
      match e.symm i with
      | Sum.inl (a, _) => w (Sum.inl (a, j))
      | Sum.inr _ => 0
  | Sum.inr (Sum.inl (s, i, j)) =>
      match e.symm i, e.symm j with
      | Sum.inl (a, _), Sum.inl (b, _) =>
          w (Sum.inr (Sum.inl (s, a, b))) / (k : ℝ)
      | _, _ => 0
  | Sum.inr (Sum.inr i) =>
      match e.symm i with
      | Sum.inl (a, _) => w (Sum.inr (Sum.inr a)) / (k : ℝ)
      | Sum.inr _ => 0

/-- Padded hidden neurons have activation `φ 0`, but no outgoing effect. -/
def clonedHidden (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin C → ℝ) : Fin N → ℝ :=
  fun i => match e.symm i with
    | Sum.inl (a, _) => h a
    | Sum.inr _ => φ 0

/-- Summation over active copies, with zero contribution from the padding. -/
theorem sum_copies (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (F : Fin C → ℝ) :
    (∑ i : Fin N, match e.symm i with
      | Sum.inl (a, _) => F a
      | Sum.inr _ => 0) = (k : ℝ) * ∑ a, F a := by
  classical
  let G : (Fin C × Fin k) ⊕ Fin p → ℝ :=
    fun j => match j with
      | Sum.inl (a, _) => F a
      | Sum.inr _ => 0
  change (∑ i, G (e.symm i)) = _
  rw [e.symm.sum_comp]
  simp [G, Fintype.sum_prod_type, Finset.mul_sum]

theorem firstHidden_cloned (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (x : Cube d) :
    firstHidden φ (clonedWeights e w) x =
      clonedHidden φ e (firstHidden φ w x) := by
  classical
  funext i
  cases hi : e.symm i with
  | inl ab => simp [firstHidden, clonedWeights, clonedHidden, hi]
  | inr z => simp [firstHidden, clonedWeights, clonedHidden, hi]

theorem hiddenStep_cloned (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (h : Fin C → ℝ) (s : Fin r) :
    hiddenStep φ (clonedWeights e w) (clonedHidden φ e h) s =
      clonedHidden φ e (hiddenStep φ w h s) := by
  classical
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hk)
  funext i
  cases hi : e.symm i with
  | inr z => simp [hiddenStep, clonedWeights, clonedHidden, hi]
  | inl ab =>
    change φ (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s, i, j))) *
      clonedHidden φ e h j) = _
    simp only [clonedHidden, hi]
    change φ (∑ j, _) = φ (∑ j, w (Sum.inr (Sum.inl (s, ab.1, j))) * h j)
    congr 1
    calc
      (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s, i, j))) *
          clonedHidden φ e h j) =
          ∑ j, match e.symm j with
            | Sum.inl (a, _) =>
                (w (Sum.inr (Sum.inl (s, ab.1, a))) * h a) / (k : ℝ)
            | Sum.inr _ => 0 := by
        apply Finset.sum_congr rfl
        intro j hj
        cases hj' : e.symm j with
        | inl cd => simp [clonedWeights, clonedHidden, hi, hj', div_mul_eq_mul_div]
        | inr z => simp [clonedWeights, clonedHidden, hi, hj']
      _ = (k : ℝ) * ∑ j, (w (Sum.inr (Sum.inl (s, ab.1, j))) * h j) /
          (k : ℝ) := sum_copies e _
      _ = ∑ j, w (Sum.inr (Sum.inl (s, ab.1, j))) * h j := by
        rw [← Finset.sum_div]
        exact mul_div_cancel₀ _ hkR

theorem hiddenFold_cloned (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (ss : List (Fin r)) (h : Fin C → ℝ) :
    ss.foldl (hiddenStep φ (clonedWeights e w)) (clonedHidden φ e h) =
      clonedHidden φ e (ss.foldl (hiddenStep φ w) h) := by
  induction ss generalizing h with
  | nil => rfl
  | cons s ss ih =>
    simp only [List.foldl_cons, hiddenStep_cloned hk]
    exact ih _

theorem finalHidden_cloned (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (x : Cube d) :
    finalHidden φ (clonedWeights e w) x =
      clonedHidden φ e (finalHidden φ w x) := by
  unfold finalHidden
  rw [firstHidden_cloned]
  exact hiddenFold_cloned hk φ e w _ _

/-- Cloning preserves the real-valued output, for an arbitrary activation. -/
theorem networkOutput_cloned (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (x : Cube d) :
    networkOutput φ (clonedWeights e w) x = networkOutput φ w x := by
  classical
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hk)
  unfold networkOutput
  rw [finalHidden_cloned hk]
  calc
    (∑ i, clonedWeights e w (Sum.inr (Sum.inr i)) *
        clonedHidden φ e (finalHidden φ w x) i) =
        ∑ i, match e.symm i with
          | Sum.inl (a, _) =>
              (w (Sum.inr (Sum.inr a)) * finalHidden φ w x a) / (k : ℝ)
          | Sum.inr _ => 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      cases hi' : e.symm i with
      | inl ab => simp [clonedWeights, clonedHidden, hi', div_mul_eq_mul_div]
      | inr z => simp [clonedWeights, clonedHidden, hi']
    _ = (k : ℝ) * ∑ i, (w (Sum.inr (Sum.inr i)) * finalHidden φ w x i) /
          (k : ℝ) := sum_copies e _
    _ = ∑ i, w (Sum.inr (Sum.inr i)) * finalHidden φ w x i := by
      rw [← Finset.sum_div]
      exact mul_div_cancel₀ _ hkR

/-- Exact first-layer squared Frobenius norm after replication. -/
theorem first_squaredSum_cloned
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    (∑ i, ∑ j, clonedWeights e w (Sum.inl (i, j)) ^ 2) =
      (k : ℝ) * ∑ a, ∑ j, w (Sum.inl (a, j)) ^ 2 := by
  classical
  calc
    _ = ∑ i, match e.symm i with
        | Sum.inl (a, _) => ∑ j, w (Sum.inl (a, j)) ^ 2
        | Sum.inr _ => 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      cases hi' : e.symm i <;> simp [clonedWeights, hi']
    _ = _ := sum_copies e _

/-- Exact squared norm of one replicated internal layer. -/
theorem internal_squaredSum_cloned (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (s : Fin r) :
    (∑ i, ∑ j, clonedWeights e w (Sum.inr (Sum.inl (s, i, j))) ^ 2) =
      ∑ a, ∑ b, w (Sum.inr (Sum.inl (s, a, b))) ^ 2 := by
  classical
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hk)
  have hrow (i : Fin N) :
      (∑ j, clonedWeights e w (Sum.inr (Sum.inl (s, i, j))) ^ 2) =
      match e.symm i with
      | Sum.inl (a, _) => (k : ℝ) * ∑ b,
          (w (Sum.inr (Sum.inl (s, a, b))) / (k : ℝ)) ^ 2
      | Sum.inr _ => 0 := by
    cases hi : e.symm i with
    | inr z => simp [clonedWeights, hi]
    | inl ab =>
      calc
        _ = ∑ j, match e.symm j with
            | Sum.inl (b, _) =>
                (w (Sum.inr (Sum.inl (s, ab.1, b))) / (k : ℝ)) ^ 2
            | Sum.inr _ => 0 := by
          apply Finset.sum_congr rfl
          intro j hj
          cases hj' : e.symm j <;> simp [clonedWeights, hi, hj']
        _ = _ := sum_copies e _
  simp_rw [hrow]
  rw [sum_copies]
  simp_rw [div_pow, ← Finset.sum_div, ← Finset.mul_sum]
  rw [← Finset.sum_div, ← mul_assoc, ← sq]
  exact mul_div_cancel₀ _ (pow_ne_zero 2 hkR)

/-- Exact squared readout norm after replication. -/
theorem readout_squaredSum_cloned (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) :
    (∑ i, clonedWeights e w (Sum.inr (Sum.inr i)) ^ 2) =
      (∑ a, w (Sum.inr (Sum.inr a)) ^ 2) / (k : ℝ) := by
  classical
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hk)
  calc
    _ = ∑ i, match e.symm i with
        | Sum.inl (a, _) => (w (Sum.inr (Sum.inr a)) / (k : ℝ)) ^ 2
        | Sum.inr _ => 0 := by
      apply Finset.sum_congr rfl
      intro i hi
      cases hi' : e.symm i <;> simp [clonedWeights, hi']
    _ = (k : ℝ) * ∑ a, (w (Sum.inr (Sum.inr a)) / (k : ℝ)) ^ 2 :=
      sum_copies e _
    _ = _ := by
      simp_rw [div_pow]
      rw [← Finset.sum_div]
      rw [← mul_div_assoc, mul_comm (k : ℝ), pow_two, mul_div_mul_right _ _ hkR]

/-- The exact weighted cost, retaining the padding dependence through `N`. -/
theorem weightedSquaredNorm_cloned (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    weightedSquaredNorm (clonedWeights e w) =
      ((d : ℝ) * k / N) * (∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2) +
      (∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2) +
      ((N : ℝ) / k) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2) := by
  unfold weightedSquaredNorm
  rw [first_squaredSum_cloned, readout_squaredSum_cloned hk]
  simp_rw [internal_squaredSum_cloned hk]
  ring

/-- At an exact multiple of the teacher width the weighted cost is preserved. -/
theorem weightedSquaredNorm_cloned_multiple (hC : 0 < C) (hk : 0 < k)
    (hN : N = C * k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) :
    weightedSquaredNorm (clonedWeights e w) = weightedSquaredNorm w := by
  have hCR : (C : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hC)
  have hkR : (k : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hk)
  rw [weightedSquaredNorm_cloned hk]
  unfold weightedSquaredNorm
  rw [hN, Nat.cast_mul]
  rw [mul_div_mul_right _ _ hkR, mul_div_cancel_right₀ _ hkR]

/-- A clone with fewer than twice the original effective width has at most
    twice the weighted cost. -/
theorem weightedSquaredNorm_cloned_le (hC : 0 < C) (hk : 0 < k)
    (hbelow : C * k ≤ N) (habove : N ≤ 2 * C * k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    weightedSquaredNorm (clonedWeights e w) ≤ 2 * weightedSquaredNorm w := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.mul_pos hC hk) hbelow
  have hCR : 0 < (C : ℝ) := by exact_mod_cast hC
  have hkR : 0 < (k : ℝ) := by exact_mod_cast hk
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have hbelowR : (C : ℝ) * k ≤ N := by exact_mod_cast hbelow
  have haboveR : (N : ℝ) ≤ 2 * C * k := by exact_mod_cast habove
  have hf : (d : ℝ) * k / N ≤ (d : ℝ) / C := by
    apply (div_le_div_iff₀ hNR hCR).2
    nlinarith [mul_le_mul_of_nonneg_left hbelowR (Nat.cast_nonneg d : (0 : ℝ) ≤ d)]
  have ho : (N : ℝ) / k ≤ 2 * C := by
    apply (div_le_iff₀ hkR).2
    nlinarith
  rw [weightedSquaredNorm_cloned hk]
  unfold weightedSquaredNorm
  have hfirst : 0 ≤ (∑ i : Fin C, ∑ j : Fin (d + 1), w (Sum.inl (i, j)) ^ 2) :=
    Finset.sum_nonneg (fun i _ => Finset.sum_nonneg (fun j _ => sq_nonneg _))
  have hinter : 0 ≤ (∑ s : Fin r, ∑ i : Fin C, ∑ j : Fin C,
      w (Sum.inr (Sum.inl (s, i, j))) ^ 2) :=
    Finset.sum_nonneg (fun s _ => Finset.sum_nonneg (fun i _ =>
      Finset.sum_nonneg (fun j _ => sq_nonneg _)))
  have hout : 0 ≤ (∑ i : Fin C, w (Sum.inr (Sum.inr i)) ^ 2) :=
    Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hfirstcost : 0 ≤ (d : ℝ) / C *
      (∑ i : Fin C, ∑ j : Fin (d + 1), w (Sum.inl (i, j)) ^ 2) :=
    mul_nonneg (div_nonneg (Nat.cast_nonneg _) hCR.le) hfirst
  nlinarith [mul_le_mul_of_nonneg_right hf hfirst, mul_le_mul_of_nonneg_right ho hout]

/-- Every larger positive width admits a genuine parameter clone preserving
    the output on every input and increasing weighted cost by at most two. -/
theorem exists_clone_at_every_width (hC : 0 < C) (hCN : C ≤ N)
    (φ : ℝ → ℝ) (w : Weights d C r) :
    ∃ v : Weights d N r,
      (∀ x, networkOutput φ v x = networkOutput φ w x) ∧
      weightedSquaredNorm v ≤ 2 * weightedSquaredNorm w := by
  classical
  let k := N / C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N % C < C := Nat.mod_lt _ hC
  have hsplit : N % C + C * k = N := Nat.mod_add_div N C
  have hbelow : C * k ≤ N := by omega
  have hCk : C ≤ C * k := by
    simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N ≤ 2 * C * k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N - C * k)) ≃ Fin N :=
    Fintype.equivOfCardEq (by
      simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin]
      omega)
  exact ⟨clonedWeights e w, fun x => networkOutput_cloned hk φ e w x,
    weightedSquaredNorm_cloned_le hC hk hbelow habove e w⟩

/-- All global strict margins, not just observed training margins, survive cloning. -/
theorem marginEvent_cloned_iff (hk : 0 < k) (φ : ℝ → ℝ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (a : ℝ) (f : BooleanFunction d) :
    clonedWeights e w ∈ marginEvent φ a f ↔ w ∈ marginEvent φ a f := by
  simp only [marginEvent, Set.mem_setOf_eq, networkOutput_cloned hk]

/-- A bounded teacher has the explicit norm bound used before cloning. -/
theorem weightedSquaredNorm_bounded_teacher (hC : 0 < C)
    (w : Weights d C r) (hw : boundedWeights C w) :
    weightedSquaredNorm w ≤
      (d : ℝ) * (d + 1) * C ^ 2 + (r + 1) * C ^ 4 := by
  classical
  have hCR : 0 < (C : ℝ) := by exact_mod_cast hC
  have hs (i : WeightIndex d C r) : w i ^ 2 ≤ (C : ℝ) ^ 2 := by
    have h := (sq_le_sq₀ (abs_nonneg (w i)) (Nat.cast_nonneg C)).2 (hw i)
    simpa only [sq_abs] using h
  have hf : (∑ i : Fin C, ∑ j : Fin (d + 1), w (Sum.inl (i, j)) ^ 2) ≤
      (C : ℝ) * (d + 1) * C ^ 2 := by
    calc
      _ ≤ ∑ _i : Fin C, ∑ _j : Fin (d + 1), (C : ℝ) ^ 2 := by
        exact Finset.sum_le_sum (fun i _ => Finset.sum_le_sum (fun j _ => hs _))
      _ = _ := by
        simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, Nat.cast_add, Nat.cast_one]
        ring
  have hi : (∑ s : Fin r, ∑ i : Fin C, ∑ j : Fin C,
      w (Sum.inr (Sum.inl (s, i, j))) ^ 2) ≤ (r : ℝ) * C ^ 4 := by
    calc
      _ ≤ ∑ _s : Fin r, ∑ _i : Fin C, ∑ _j : Fin C, (C : ℝ) ^ 2 := by
        exact Finset.sum_le_sum (fun s _ => Finset.sum_le_sum (fun i _ =>
          Finset.sum_le_sum (fun j _ => hs _)))
      _ = _ := by
        simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        ring
  have ho : (∑ i : Fin C, w (Sum.inr (Sum.inr i)) ^ 2) ≤ (C : ℝ) ^ 3 := by
    calc
      _ ≤ ∑ _i : Fin C, (C : ℝ) ^ 2 := Finset.sum_le_sum (fun i _ => hs _)
      _ = _ := by
        simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        ring
  have hf' := mul_le_mul_of_nonneg_left hf
    (show (0 : ℝ) ≤ d / C from div_nonneg (Nat.cast_nonneg _) hCR.le)
  have ho' := mul_le_mul_of_nonneg_left ho (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
  have hfc : (d : ℝ) / C * ((C : ℝ) * (d + 1) * C ^ 2) =
      (d : ℝ) * (d + 1) * C ^ 2 := by
    calc
      _ = ((d : ℝ) / C * C) * ((d + 1) * C ^ 2) := by ring
      _ = (d : ℝ) * ((d + 1) * C ^ 2) := by rw [div_mul_cancel₀ _ (ne_of_gt hCR)]
      _ = _ := by ring
  rw [hfc] at hf'
  unfold weightedSquaredNorm
  nlinarith

/-- The target-complexity witness remains inexpensive at every larger width.
    The factor-two bound is deliberately uniform across all three layer types. -/
theorem realizesAtComplexity_larger_width (φ : ℝ → ℝ) (f : BooleanFunction d)
    (h : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ v : Weights d N r,
      v ∈ marginEvent φ (1 / 2) f ∧
      weightedSquaredNorm v ≤
        2 * ((d : ℝ) * (d + 1) * C ^ 2 + (r + 1) * C ^ 4) := by
  rcases h with ⟨hC, w, hwmargin, hwbounded⟩
  rcases exists_clone_at_every_width (Nat.lt_of_lt_of_le Nat.zero_lt_one hC)
      hCN φ w with ⟨v, hvoutput, hvcost⟩
  refine ⟨v, ?_, ?_⟩
  · intro x
    simpa only [hvoutput x] using hwmargin x
  · exact hvcost.trans (mul_le_mul_of_nonneg_left
      (weightedSquaredNorm_bounded_teacher (Nat.lt_of_lt_of_le Nat.zero_lt_one hC)
        w hwbounded) (by norm_num))

end NeuralGeneralization.ConcreteModel
