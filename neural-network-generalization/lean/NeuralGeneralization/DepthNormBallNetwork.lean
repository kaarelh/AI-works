import NeuralGeneralization.DepthNormBallInterpolation
import Mathlib.Data.Fintype.Fin
import NeuralGeneralization.BatchTwoNeuralConverseNoise

/-! The appendix's actual finite-width network, before choosing its schedule. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel BatchTwoNeuralConverse

def width (q : ℕ) : ℕ := 2*Fintype.card (Cube q)
lemma width_pos (q : ℕ) : 0 < width q := by unfold width; positivity
instance (q : ℕ) : NeZero (width q) := ⟨(width_pos q).ne'⟩
lemma width_eq (q : ℕ) : width q = 2^(q+1) := by
  simp [width,Cube,Fintype.card_fun,pow_succ,Nat.mul_comm]

def neurons (q : ℕ) : Cube q ⊕ Cube q ≃ Fin (width q) :=
  Fintype.equivOfCardEq (by simp [width,two_mul])

def bumpRow {q : ℕ} (p : Cube q) : Fin (q+1) → ℝ :=
  Fin.cases (-slope q*((q:ℝ)-1)) (fun i => slope q*labelReal (p i))

lemma bumpRow_preactivation {q : ℕ} (p x : Cube q) :
    (∑ j, bumpRow p j*inputVector x j) = slope q*(1-2*(hammingShell x p:ℝ)) := by
  rw [Fin.sum_univ_succ]
  simp only [bumpRow,Fin.cases_zero,Fin.cases_succ,inputVector,mul_one]
  simp_rw [mul_assoc,← Finset.mul_sum,label_dot_shell,hammingShell_comm p x]
  ring

def weights {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ) :
    Weights q (width q) (m+1)
  | Sum.inl (i,j) => match (neurons q).symm i with
    | Sum.inl p => bumpRow p j
    | Sum.inr _ => Fin.cases 1 (fun _ => 0) j
  | Sum.inr (Sum.inl (s,i,j)) => if s.val=0 then
      if i=0 then match (neurons q).symm j with
        | Sum.inl p => bumpCoefficient v (t 0) p
        | Sum.inr _ => constantCoefficient v (t 0)
      else 0
    else if i.val < n s.val ∧ j.val < n (s.val-1) then
      Real.artanh (t s.val)/((n (s.val-1):ℝ)*t (s.val-1)) else 0
  | Sum.inr (Sum.inr i) => if i.val < n m then 1/((n m:ℝ)*t m) else 0

lemma sum_active {N n : ℕ} (hn : n ≤ N) (a : ℝ) :
    (∑ i : Fin N, if i.val < n then a else 0) = (n:ℝ)*a := by
  rw [← Finset.sum_filter]
  simp only [Finset.sum_const,nsmul_eq_mul,Fin.card_filter_val_lt,min_eq_right hn]

lemma firstHidden_value {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (x : Cube q) (i : Fin (width q)) :
    firstHidden Real.tanh (weights m v n t) x i = match (neurons q).symm i with
      | Sum.inl p => Real.tanh (slope q*(1-2*(hammingShell x p:ℝ)))
      | Sum.inr _ => Real.tanh 1 := by
  cases hi : (neurons q).symm i with
  | inl p => simpa only [firstHidden,weights,hi] using congrArg Real.tanh (bumpRow_preactivation p x)
  | inr p => simp [firstHidden,weights,hi,Fin.sum_univ_succ,inputVector]

lemma secondHidden_value {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (f : BooleanFunction q) (hv : ∀ x, (∑ p, v p*softCube x p) = labelReal (f x))
    (ht : 0 ≤ t 0) (ht1 : t 0 < 1) (x : Cube q) (i : Fin (width q)) :
    cleanAfter (weights m v n t) x 1 i = if i=0 then t 0*labelReal (f x) else 0 := by
  rw [cleanAfter_succ (weights m v n t) x (⟨0,by omega⟩ : Fin (m+1))]
  simp only [hiddenStep,weights,↓reduceIte,cleanAfter,List.take_zero,List.foldl_nil]
  by_cases hi : i=0
  · simp only [if_pos hi]
    have he : (∑ j : Fin (width q),
        (match (neurons q).symm j with | Sum.inl p => bumpCoefficient v (t 0) p | Sum.inr _ => constantCoefficient v (t 0))*
          firstHidden Real.tanh (weights m v n t) x j) =
        (∑ p, bumpCoefficient v (t 0) p*Real.tanh (slope q*(1-2*(hammingShell x p:ℝ))))+
          (Fintype.card (Cube q):ℝ)*constantCoefficient v (t 0)*Real.tanh 1 := by
      simp_rw [firstHidden_value]
      rw [← (neurons q).sum_comp]
      simp only [Equiv.symm_apply_apply,Fintype.sum_sum_type,Finset.sum_const,
        Finset.card_univ,nsmul_eq_mul,mul_assoc]
    rw [he,second_preactivation v (t 0) f hv x,tanh_artanh_label ht ht1]
  · simp [hi]

lemma relay_step {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (s : Fin (m+1)) (hs : s.val ≠ 0) (hn : n (s.val-1) ≤ width q)
    (hn0 : 0 < n (s.val-1)) (ht0 : t (s.val-1) ≠ 0)
    (ht : 0 ≤ t s.val) (ht1 : t s.val < 1) (b : Bool) (i : Fin (width q)) :
    hiddenStep Real.tanh (weights m v n t)
      (fun j => if j.val < n (s.val-1) then t (s.val-1)*labelReal b else 0) s i =
        if i.val < n s.val then t s.val*labelReal b else 0 := by
  have hnR : (n (s.val-1):ℝ) ≠ 0 := by exact_mod_cast hn0.ne'
  unfold hiddenStep
  simp only [weights,if_neg hs]
  by_cases hi : i.val < n s.val
  · simp only [hi,true_and,ite_true]
    have he (j : Fin (width q)) :
        (if j.val < n (s.val-1) then Real.artanh (t s.val)/((n (s.val-1):ℝ)*t (s.val-1)) else 0)*
          (if j.val < n (s.val-1) then t (s.val-1)*labelReal b else 0) =
        if j.val < n (s.val-1) then Real.artanh (t s.val)*labelReal b/(n (s.val-1):ℝ) else 0 := by
      split_ifs
      · field_simp
      · simp
    simp_rw [he]
    rw [sum_active hn,mul_div_cancel₀ _ hnR,tanh_artanh_label ht ht1]
  · simp [hi]

lemma cleanAfter_value {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (f : BooleanFunction q) (hv : ∀ x, (∑ p, v p*softCube x p) = labelReal (f x))
    (hn0 : n 0=1) (hn : ∀ j ≤ m, 0 < n j ∧ n j ≤ width q)
    (ht : ∀ j ≤ m, 0 < t j ∧ t j < 1) (x : Cube q) (j : ℕ) (hj : j ≤ m)
    (i : Fin (width q)) :
    cleanAfter (weights m v n t) x (j+1) i = if i.val < n j then t j*labelReal (f x) else 0 := by
  induction j generalizing i with
  | zero =>
    rw [secondHidden_value m v n t f hv (ht 0 (by omega)).1.le (ht 0 (by omega)).2,hn0]
    have hi : i.val < 1 ↔ i=0 := by
      constructor
      · intro h
        apply Fin.ext
        change i.val=0
        omega
      · intro h
        subst i
        norm_num
    simp only [hi]
  | succ j ih =>
    rw [show j+1+1=(⟨j+1,by omega⟩ : Fin (m+1)).val+1 by rfl,cleanAfter_succ]
    have he : cleanAfter (weights m v n t) x (j+1) =
        fun k => if k.val < n j then t j*labelReal (f x) else 0 := by
      funext k
      exact ih (by omega) k
    rw [he]
    simpa using relay_step m v n t ⟨j+1,by omega⟩ (by simp) (hn j (by omega)).2
      (hn j (by omega)).1 (ht j (by omega)).1.ne' (ht (j+1) hj).1.le (ht (j+1) hj).2 (f x) i

/-- For every admissible population/amplitude schedule, these are actual
weights whose final linear output equals the desired Boolean label exactly. -/
theorem networkOutput_eq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (f : BooleanFunction q) (hv : ∀ x, (∑ p, v p*softCube x p) = labelReal (f x))
    (hn0 : n 0=1) (hn : ∀ j ≤ m, 0 < n j ∧ n j ≤ width q)
    (ht : ∀ j ≤ m, 0 < t j ∧ t j < 1) (x : Cube q) :
    networkOutput Real.tanh (weights m v n t) x = labelReal (f x) := by
  have htake : (List.finRange (m+1)).take (m+1)=List.finRange (m+1) := by simp
  have hstate (i : Fin (width q)) : finalHidden Real.tanh (weights m v n t) x i =
      if i.val < n m then t m*labelReal (f x) else 0 := by
    simpa only [cleanAfter,htake,finalHidden] using cleanAfter_value m v n t f hv hn0 hn ht x m le_rfl i
  unfold networkOutput
  simp_rw [hstate]
  simp only [weights]
  have he (i : Fin (width q)) :
      (if i.val < n m then 1/((n m:ℝ)*t m) else 0)*
        (if i.val < n m then t m*labelReal (f x) else 0) =
      if i.val < n m then labelReal (f x)/(n m:ℝ) else 0 := by
    have ht0 := (ht m le_rfl).1.ne'
    split_ifs
    · field_simp
    · simp
  simp_rw [he]
  rw [sum_active (hn m le_rfl).2,mul_div_cancel₀]
  exact_mod_cast (hn m le_rfl).1.ne'

end NeuralGeneralization.DepthNormBall
