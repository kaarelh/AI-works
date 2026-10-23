import NeuralGeneralization.BatchTwoMergingGeluEvaluation

/-! Finite coefficient perturbations for the population-normalized GELU model,
including perturbations of the positive population masses. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

private theorem perspective_sum_bound {I : Type*} [Fintype I]
    (u v : I→ℝ) {R B : ℝ} (hR : 0≤R)
    (hu : ∀i,|u i|≤R) (hv : ∀i,|v i|≤B) :
    |∑i,u i*v i|≤(Fintype.card I:ℝ)*R*B := by
  calc
    _ ≤ ∑i,|u i*v i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑_i:I,R*B := Finset.sum_le_sum fun i _=>by
      rw [abs_mul]
      exact mul_le_mul (hu i) (hv i) (abs_nonneg _) hR
    _ = _ := by simp [mul_assoc]

private theorem perspective_sum_difference {I : Type*} [Fintype I]
    (w v h k : I→ℝ) {R B η E : ℝ} (hR : 0≤R) (hη : 0≤η)
    (hv : ∀i,|v i|≤R) (hh : ∀i,|h i|≤B)
    (hwv : ∀i,|w i-v i|≤η) (hhk : ∀i,|h i-k i|≤E) :
    |(∑i,w i*h i)-∑i,v i*k i|≤(Fintype.card I:ℝ)*(η*B+R*E) := by
  rw [←Finset.sum_sub_distrib]
  calc
    _ ≤ ∑i,|w i*h i-v i*k i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : I, (η*B+R*E) := by
      apply Finset.sum_le_sum
      intro i _
      calc
        _ = |(w i-v i)*h i+v i*(h i-k i)| := by congr 1; ring
        _ ≤ |w i-v i| *|h i|+|v i| *|h i-k i| := by
          simpa only [abs_mul] using abs_add_le ((w i-v i)*h i) (v i*(h i-k i))
        _ ≤ η*B+R*E := add_le_add
          (mul_le_mul (hwv i) (hh i) (abs_nonneg _) hη)
          (mul_le_mul (hv i) (hhk i) (abs_nonneg _) hR)
    _ = _ := by simp [mul_add]

theorem perspectiveFold_abs_le {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (hmass : ∀s i,0<mass s i)
    {R A : ℝ} (hR : 0≤R) (hA : 1≤A) (hd : (d+1:ℝ)*R≤A)
    (hQR : (Q:ℝ)*R≤A) (hw : ∀i,|w i|≤R)
    (ss : List (Fin r)) (x : Cube d) (i : Fin Q) :
    |ss.foldl (perspectiveStep w mass) (perspectiveFirst w mass x) i|≤A^(ss.length+1) := by
  induction ss using List.reverseRecOn generalizing i with
  | nil =>
    simp only [List.foldl_nil,List.length_nil,zero_add,pow_one]
    apply (geluPerspective_abs_le (hmass 0 i) _).trans
    have hh := perspective_sum_bound (fun j : Fin (d+1)=>w (Sum.inl (i,j)))
      (inputVector x) hR (fun j=>hw _) (fun j=>le_of_eq (abs_inputVector x j))
    simp only [Fintype.card_fin,Nat.cast_add,Nat.cast_one,mul_one] at hh
    exact (show |(firstMatrix w *ᵥ inputVector x) i|≤(d+1:ℝ)*R by
      simpa only [Matrix.mulVec,dotProduct,firstMatrix,Matrix.of_apply] using hh).trans hd
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,
      List.length_append,List.length_singleton]
    apply (geluPerspective_abs_le (hmass s.succ i) _).trans
    calc
      _ ≤ (Q:ℝ)*R*A^(ss.length+1) := by
        simpa only [Fintype.card_fin, Matrix.mulVec, dotProduct, internalMatrix, Matrix.of_apply] using
          perspective_sum_bound (fun j=>w (Sum.inr (Sum.inl (s,i,j)))) _ hR
            (fun j=>hw _) (fun j=>ih j)
      _ ≤ A*A^(ss.length+1) := mul_le_mul_of_nonneg_right hQR (by positivity)
      _ = A^(ss.length+1+1) := by rw [pow_succ]; ring

theorem perspectiveFold_difference {d Q r : ℕ} (w v : Weights d Q r)
    (mass mass' : Fin (r+1)→Fin Q→ℝ)
    (hmass : ∀s i,0<mass s i) (hmass' : ∀s i,0<mass' s i)
    {R A η : ℝ} (hR : 0≤R) (hA : 1≤A) (hη : 0≤η)
    (hdR : (d+1:ℝ)*R≤A) (hd : 2*(d+1:ℝ)+1≤A)
    (hQR : 2*(Q:ℝ)*R≤A) (hQ : 2*(Q:ℝ)+1≤A)
    (hw : ∀i,|w i|≤R) (hv : ∀i,|v i|≤R)
    (hclose : ∀i,|w i-v i|≤η) (hmclose : ∀s i,|mass s i-mass' s i|≤η)
    (ss : List (Fin r)) (x : Cube d) (i : Fin Q) :
    |ss.foldl (perspectiveStep w mass) (perspectiveFirst w mass x) i-
      ss.foldl (perspectiveStep v mass') (perspectiveFirst v mass' x) i|≤
        η*(ss.length+1)*A^(ss.length+1) := by
  have hQR' : (Q:ℝ)*R≤A := by nlinarith [mul_nonneg (Nat.cast_nonneg Q) hR]
  induction ss using List.reverseRecOn generalizing i with
  | nil =>
    simp only [List.foldl_nil,List.length_nil,Nat.cast_zero,zero_add,mul_one,pow_one]
    apply (geluPerspective_joint_lipschitz (hmass 0 i) (hmass' 0 i) _ _).trans
    have hs : |(firstMatrix w *ᵥ inputVector x) i-
        (firstMatrix v *ᵥ inputVector x) i|≤(d+1:ℝ)*η := by
      change |(∑j,w (Sum.inl (i,j))*inputVector x j)-
        ∑j,v (Sum.inl (i,j))*inputVector x j|≤_
      rw [←Finset.sum_sub_distrib]
      calc
        _ ≤ ∑j,|w (Sum.inl (i,j))*inputVector x j-
          v (Sum.inl (i,j))*inputVector x j| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑_j:Fin (d+1),η := Finset.sum_le_sum fun j _=>by
          rw [←sub_mul,abs_mul,abs_inputVector,mul_one]; exact hclose _
        _ = _ := by simp
    nlinarith [hmclose 0 i]
  | append_singleton ss s ih =>
    simp only [List.foldl_append,List.foldl_cons,List.foldl_nil,
      List.length_append,List.length_singleton]
    apply (geluPerspective_joint_lipschitz (hmass s.succ i) (hmass' s.succ i) _ _).trans
    have hpow : 1≤A^(ss.length+1) := one_le_pow₀ hA
    have hp0 : 0≤A^(ss.length+1) := by positivity
    have hs : |(internalMatrix w s *ᵥ
        ss.foldl (perspectiveStep w mass) (perspectiveFirst w mass x)) i-
      (internalMatrix v s *ᵥ
        ss.foldl (perspectiveStep v mass') (perspectiveFirst v mass' x)) i|≤
        (Q:ℝ)*(η*A^(ss.length+1)+R*(η*(ss.length+1)*A^(ss.length+1))) := by
      simpa only [Fintype.card_fin, Matrix.mulVec, dotProduct, internalMatrix, Matrix.of_apply] using
        perspective_sum_difference (fun j=>w (Sum.inr (Sum.inl (s,i,j))))
          (fun j=>v (Sum.inr (Sum.inl (s,i,j)))) _ _ hR hη (fun j=>hv _)
          (fun j=>perspectiveFold_abs_le w mass hmass hR hA hdR hQR' hw ss x j)
          (fun j=>hclose _) (fun j=>ih j)
    calc
      _ ≤ 2*((Q:ℝ)*(η*A^(ss.length+1)+R*(η*(ss.length+1)*A^(ss.length+1))))+η := by
        linarith [hmclose s.succ i]
      _ ≤ η*((2*(Q:ℝ)+1)+(2*(Q:ℝ)*R)*(ss.length+1))*A^(ss.length+1) := by
        nlinarith [mul_le_mul_of_nonneg_left hpow hη]
      _ ≤ η*(A+A*(ss.length+1))*A^(ss.length+1) := by
        apply mul_le_mul_of_nonneg_right _ hp0
        apply mul_le_mul_of_nonneg_left _ hη
        exact add_le_add hQ (mul_le_mul_of_nonneg_right hQR (by positivity))
      _ = η*(↑(ss.length+1)+1)*A^(ss.length+1+1) := by
        rw [pow_succ]; push_cast; ring

theorem perspectiveOutput_difference {d Q r : ℕ} (w v : Weights d Q r)
    (mass mass' : Fin (r+1)→Fin Q→ℝ)
    (hmass : ∀s i,0<mass s i) (hmass' : ∀s i,0<mass' s i)
    {R A η : ℝ} (hR : 0≤R) (hA : 1≤A) (hη : 0≤η)
    (hdR : (d+1:ℝ)*R≤A) (hd : 2*(d+1:ℝ)+1≤A)
    (hQR : 2*(Q:ℝ)*R≤A) (hQ : 2*(Q:ℝ)+1≤A)
    (hw : ∀i,|w i|≤R) (hv : ∀i,|v i|≤R)
    (hclose : ∀i,|w i-v i|≤η) (hmclose : ∀s i,|mass s i-mass' s i|≤η)
    (x : Cube d) :
    |perspectiveOutput w mass x-perspectiveOutput v mass' x|≤η*(r+2)*A^(r+2) := by
  have hQR' : (Q:ℝ)*R≤A := by nlinarith [mul_nonneg (Nat.cast_nonneg Q) hR]
  have hQ' : (Q:ℝ)≤A := by linarith [Nat.cast_nonneg (α:=ℝ) Q]
  have hb := perspectiveFold_abs_le w mass hmass hR hA hdR hQR' hw (List.finRange r) x
  have he := perspectiveFold_difference w v mass mass' hmass hmass' hR hA hη
    hdR hd hQR hQ hw hv hclose hmclose (List.finRange r) x
  simp only [List.length_finRange] at hb he
  have heq : perspectivePrefix w mass x r =
      (List.finRange r).foldl (perspectiveStep w mass) (perspectiveFirst w mass x) := by
    unfold perspectivePrefix
    rw [List.take_of_length_le (by simp)]
  have heq' : perspectivePrefix v mass' x r =
      (List.finRange r).foldl (perspectiveStep v mass') (perspectiveFirst v mass' x) := by
    unfold perspectivePrefix
    rw [List.take_of_length_le (by simp)]
  calc
    _ ≤ (Q:ℝ)*(η*A^(r+1)+R*(η*(r+1)*A^(r+1))) := by
      simp only [perspectiveOutput,heq,heq']
      simpa only [Fintype.card_fin, Matrix.mulVec, dotProduct, internalMatrix, Matrix.of_apply] using
        perspective_sum_difference (readoutVector w) (readoutVector v) _ _
          hR hη (fun j=>hv _) hb (fun j=>hclose _) he
    _ = η*((Q:ℝ)+((Q:ℝ)*R)*(r+1))*A^(r+1) := by ring
    _ ≤ η*(A+A*(r+1))*A^(r+1) := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      apply mul_le_mul_of_nonneg_left _ hη
      exact add_le_add hQ' (mul_le_mul_of_nonneg_right hQR' (by positivity))
    _ = η*(r+2)*A^(r+2) := by rw [show r+2=r+1+1 by omega,pow_succ]; push_cast; ring

end NeuralGeneralization.BatchTwoMerging
