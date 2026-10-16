import NeuralGeneralization.ParityNetworkShallow

/-! Lifting the explicit parity network to every fixed depth. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ParityNetwork
open ConcreteModel

theorem tanh_gt_half_of_one_lt {z : ℝ} (hz : 1 < z) : (1/2:ℝ) < Real.tanh z := by
  rw [TanhSaturation.tanh_exp_formula]
  have hd : 0 < Real.exp (2*z)+1 := by positivity
  have he := Real.add_one_le_exp (2*z)
  have hq : 2/(Real.exp (2*z)+1) < (1/2:ℝ) := by
    apply (div_lt_iff₀ hd).2
    linarith
  linarith

theorem tanh_preserves_signed_half (b : Bool) {z : ℝ}
    (hz : (1/2:ℝ) < labelReal b*z) :
    (1/2:ℝ) < labelReal b*Real.tanh (2*z) := by
  cases b with
  | true => simp only [labelReal_true, one_mul] at *
            exact tanh_gt_half_of_one_lt (by linarith)
  | false =>
    simp only [labelReal_false, neg_one_mul] at *
    have hh := tanh_gt_half_of_one_lt (show (1:ℝ)< -(2*z) by linarith)
    simpa only [Real.tanh_neg] using hh

def liftWeights {d N : ℕ} (w : Weights d (N+1) 0) (r : ℕ) : Weights d (N+1) r
  | Sum.inl (i,j) => w (Sum.inl (i,j))
  | Sum.inr (Sum.inl (s,i,j)) =>
      if i = 0 then if s.val = 0 then 2*w (Sum.inr (Sum.inr j))
        else if j = 0 then 2 else 0 else 0
  | Sum.inr (Sum.inr i) => if r = 0 then w (Sum.inr (Sum.inr i))
      else if i = 0 then 1 else 0

theorem firstHidden_lift {d N r : ℕ} (w : Weights d (N+1) 0) (x : Cube d) :
    firstHidden Real.tanh (liftWeights w r) x = firstHidden Real.tanh w x := rfl

theorem hiddenStep_lift_first {d N r : ℕ} (w : Weights d (N+1) 0) (x : Cube d) :
    hiddenStep Real.tanh (liftWeights w (r+1)) (firstHidden Real.tanh w x) 0 0 =
      Real.tanh (2*networkOutput Real.tanh w x) := by
  simp only [hiddenStep, liftWeights, Fin.val_zero, ↓reduceIte,
    networkOutput, finalHidden, List.finRange_zero, List.foldl_nil]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem hiddenStep_lift_succ {d N r : ℕ} (w : Weights d (N+1) 0)
    (h : Fin (N+1) → ℝ) (s : Fin r) :
    hiddenStep Real.tanh (liftWeights w (r+1)) h s.succ 0 = Real.tanh (2*h 0) := by
  simp [hiddenStep, liftWeights, ite_mul]

theorem lift_fold_preserves_margin {d N r : ℕ} (w : Weights d (N+1) 0)
    (b : Bool) (ss : List (Fin r)) (h : Fin (N+1) → ℝ)
    (hh : (1/2:ℝ)<labelReal b*h 0) :
    (1/2:ℝ)<labelReal b*((ss.map Fin.succ).foldl
      (hiddenStep Real.tanh (liftWeights w (r+1))) h) 0 := by
  induction ss generalizing h with
  | nil => simpa using hh
  | cons s ss ih =>
    simp only [List.map_cons, List.foldl_cons]
    apply ih
    rw [hiddenStep_lift_succ]
    exact tanh_preserves_signed_half b hh

theorem liftWeights_margin {d N : ℕ} (w : Weights d (N+1) 0)
    (f : BooleanFunction d) (hw : w ∈ marginEvent Real.tanh (1/2) f) (r : ℕ) :
    liftWeights w r ∈ marginEvent Real.tanh (1/2) f := by
  intro x
  cases r with
  | zero => simpa [networkOutput, finalHidden, liftWeights, firstHidden] using hw x
  | succ r =>
    have hi : (1/2:ℝ)<labelReal (f x)*
        hiddenStep Real.tanh (liftWeights w (r+1)) (firstHidden Real.tanh w x) 0 0 := by
      rw [hiddenStep_lift_first]
      exact tanh_preserves_signed_half (f x) (hw x)
    have hf := lift_fold_preserves_margin w (f x) (List.finRange r) _ hi
    simpa [networkOutput, liftWeights, finalHidden, firstHidden_lift,
      List.finRange_succ, List.foldl_cons, ite_mul] using hf

theorem liftWeights_bounded {d N : ℕ} {B : ℝ} (hB : 1 ≤ B)
    (w : Weights d (N+1) 0) (hw : boundedWeights B w) (r : ℕ) :
    boundedWeights (2*B) (liftWeights w r) := by
  have hB0 : 0 ≤ B := by linarith
  intro a
  rcases a with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · exact (hw _).trans (by linarith)
  · simp only [liftWeights]
    split_ifs
    · simpa only [abs_mul, abs_of_pos (show (0:ℝ)<2 by norm_num)] using
        mul_le_mul_of_nonneg_left (hw (Sum.inr (Sum.inr j))) (show (0:ℝ)≤2 by norm_num)
    · norm_num
      linarith
    · norm_num
      linarith
    · norm_num
      linarith
  · simp only [liftWeights]
    split_ifs
    · exact (hw _).trans (by linarith)
    · norm_num
      linarith
    · norm_num
      linarith

/-- An explicit complexity bound, uniform over every hidden depth. -/
def parityComplexityBound (d : ℕ) : ℕ := 32*(d+1)^2

theorem parity_realizes_every_depth (d r : ℕ) :
    realizesAtComplexity (r := r) Real.tanh (parity d) (parityComplexityBound d) := by
  let w := gridWeights (fun j => (-1:ℝ)^j) d
  have hw : w ∈ marginEvent Real.tanh (1/2) (parity d) := by
    intro x
    linarith [grid_parity_margin d x]
  have hb := gridWeights_bounded (fun j => (-1:ℝ)^j) (fun j => by simp) d
  have hl := liftWeights_bounded (show (1:ℝ) ≤ 16*((d:ℝ)+1)^2 by
    nlinarith [show (0:ℝ) ≤ d from Nat.cast_nonneg d]) w hb r
  have hcast : (parityComplexityBound d:ℝ) = 2*(16*((d:ℝ)+1)^2) := by
    simp [parityComplexityBound]
    ring
  rw [← hcast] at hl
  have hsize : d+1 ≤ parityComplexityBound d := by
    unfold parityComplexityBound
    nlinarith
  obtain ⟨v,hv,hout⟩ := exists_padded_bounded (Nat.cast_nonneg (parityComplexityBound d))
    hsize Real.tanh _ hl
  refine ⟨(by omega),v,?_,hv⟩
  intro x
  rw [hout]
  exact liftWeights_margin w (parity d) hw r x

/-- The minimum complexity exists, with the same explicit upper bound. -/
theorem exists_parity_complexity (d r : ℕ) :
    ∃ C, isComplexity (r := r) Real.tanh (parity d) C ∧
      C ≤ parityComplexityBound d := by
  classical
  have hex : ∃ C, realizesAtComplexity (r := r) Real.tanh (parity d) C :=
    ⟨parityComplexityBound d, parity_realizes_every_depth d r⟩
  refine ⟨Nat.find hex, ⟨Nat.find_spec hex, ?_⟩, ?_⟩
  · intro C hC
    exact Nat.find_min' hex hC
  · exact Nat.find_min' hex (parity_realizes_every_depth d r)

end NeuralGeneralization.ParityNetwork
