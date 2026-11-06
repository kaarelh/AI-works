import NeuralGeneralization.DepthNormBallNetwork

/-! Weighted energy of the appendix's explicit interpolation/replication network. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel BatchTwoNeuralConverse

lemma bumpRow_sq {q : ℕ} (p : Cube q) :
    (∑ j, (bumpRow p j)^2) = (slope q)^2*((q:ℝ)+(q-1:ℝ)^2) := by
  have hb (i : Fin q) : (labelReal (p i))^2=1 := by cases p i <;> norm_num [labelReal]
  rw [Fin.sum_univ_succ]
  simp only [bumpRow,Fin.cases_zero,Fin.cases_succ,mul_pow,neg_sq,hb,mul_one,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  ring

lemma first_sq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ) :
    (∑ i, ∑ j, (weights m v n t (Sum.inl (i,j)))^2) =
      (Fintype.card (Cube q):ℝ)*((slope q)^2*((q:ℝ)+(q-1:ℝ)^2)+1) := by
  rw [← (neurons q).sum_comp]
  simp only [weights,Equiv.symm_apply_apply,Fintype.sum_sum_type]
  simp only [bumpRow_sq]
  simp only [Fin.sum_univ_succ,Fin.cases_zero,Fin.cases_succ,one_pow,
    zero_pow (by norm_num : 2≠0),Finset.sum_const_zero,add_zero,Finset.sum_const,
    Finset.card_univ,nsmul_eq_mul]
  ring

lemma second_sq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ) :
    (∑ i, ∑ j, (weights m v n t (Sum.inr (Sum.inl ((0 : Fin (m+1)),i,j))))^2) =
      (∑ p, (bumpCoefficient v (t 0) p)^2)+
        (Fintype.card (Cube q):ℝ)*(constantCoefficient v (t 0))^2 := by
  simp only [weights,Fin.val_zero,↓reduceIte,ite_pow,zero_pow (by norm_num : 2≠0)]
  simp_rw [Finset.sum_ite_irrel]
  simp only [Finset.sum_const_zero,Finset.sum_ite_eq',Finset.mem_univ,↓reduceIte]
  rw [← (neurons q).sum_comp]
  simp only [Equiv.symm_apply_apply,Fintype.sum_sum_type,Finset.sum_const,
    Finset.card_univ,nsmul_eq_mul]

lemma relay_sq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (s : Fin m) (hn : ∀ j ≤ m, n j ≤ width q) :
    (∑ i, ∑ j, (weights m v n t (Sum.inr (Sum.inl (s.succ,i,j))))^2) =
      (n (s.val+1):ℝ)*(n s.val:ℝ)*(Real.artanh (t (s.val+1))/((n s.val:ℝ)*t s.val))^2 := by
  simp only [weights,Fin.val_succ,Nat.add_eq_zero_iff,one_ne_zero,and_false,↓reduceIte,
    Nat.add_sub_cancel,ite_pow,zero_pow (by norm_num : 2≠0)]
  have he (i : Fin (width q)) :
      (∑ j : Fin (width q), if i.val < n (s.val+1) ∧ j.val < n s.val then
        (Real.artanh (t (s.val+1))/((n s.val:ℝ)*t s.val))^2 else 0) =
      if i.val < n (s.val+1) then (n s.val:ℝ)*(Real.artanh (t (s.val+1))/((n s.val:ℝ)*t s.val))^2 else 0 := by
    by_cases hi : i.val < n (s.val+1)
    · simpa only [hi,true_and,ite_true] using sum_active (hn s.val (by omega)) _
    · simp [hi]
  simp_rw [he]
  rw [sum_active (hn (s.val+1) (by omega))]
  ring

lemma readout_sq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (hn : n m ≤ width q) :
    (∑ i, (weights m v n t (Sum.inr (Sum.inr i)))^2) =
      (n m:ℝ)*(1/((n m:ℝ)*t m))^2 := by
  simp only [weights,ite_pow,zero_pow (by norm_num : 2≠0)]
  exact sum_active hn _

lemma weightedSquaredNorm_eq {q : ℕ} (m : ℕ) (v : Cube q → ℝ) (n : ℕ → ℕ) (t : ℕ → ℝ)
    (hn : ∀ j ≤ m, n j ≤ width q) :
    ConcreteModel.weightedSquaredNorm (weights m v n t) =
      (q:ℝ)/2*((slope q)^2*((q:ℝ)+(q-1:ℝ)^2)+1)+
      ((∑ p, (bumpCoefficient v (t 0) p)^2)+(Fintype.card (Cube q):ℝ)*(constantCoefficient v (t 0))^2)+
      (∑ s : Fin m, (n (s.val+1):ℝ)*(n s.val:ℝ)*(Real.artanh (t (s.val+1))/((n s.val:ℝ)*t s.val))^2)+
      (width q:ℝ)*(n m:ℝ)*(1/((n m:ℝ)*t m))^2 := by
  unfold ConcreteModel.weightedSquaredNorm
  rw [first_sq,Fin.sum_univ_succ,second_sq,readout_sq m v n t (hn m le_rfl)]
  simp_rw [relay_sq m v n t _ hn]
  have hM : (Fintype.card (Cube q):ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  simp only [width,Nat.cast_mul,Nat.cast_ofNat]
  field_simp
  <;> ring

lemma bumpCoefficient_bound {q : ℕ} (v : Cube q → ℝ) (hv : ∀ p, |v p| ≤ 4/3)
    {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 3/4) (p : Cube q) :
    |bumpCoefficient v t p| ≤ 3*t := by
  have ha := Real.artanh_nonneg ht
  have hb := artanh_le_three_mul ht ht1
  have hc := hv p
  simp only [bumpCoefficient,abs_div,abs_mul,abs_of_nonneg ha,abs_of_nonneg (by norm_num : (0:ℝ)≤2)]
  nlinarith [mul_le_mul_of_nonneg_left hc ha]

lemma constantCoefficient_bound {q : ℕ} (v : Cube q → ℝ) (hv : ∀ p, |v p| ≤ 4/3)
    {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 3/4) :
    |constantCoefficient v t| ≤ 6*t := by
  have hM : (0:ℝ) < Fintype.card (Cube q) := by exact_mod_cast Fintype.card_pos
  have hb : 0 < Real.tanh 1 := lt_of_lt_of_le (by norm_num) tanh_one_ge_half
  have hs : |∑ p,bumpCoefficient v t p| ≤ (Fintype.card (Cube q):ℝ)*(3*t) := by
    apply (Finset.abs_sum_le_sum_abs _ _).trans
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] using
      Finset.sum_le_sum (s := Finset.univ) (fun p _ => bumpCoefficient_bound v hv ht ht1 p)
  simp only [constantCoefficient,abs_div,abs_mul,abs_of_pos hM,abs_of_pos hb]
  apply (div_le_iff₀ (mul_pos hM hb)).mpr
  calc
    _ ≤ _ := hs
    _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_left tanh_one_ge_half (by positivity : 0 ≤ (Fintype.card (Cube q):ℝ)*t)]

lemma second_energy_bound {q : ℕ} (v : Cube q → ℝ) (hv : ∀ p, |v p| ≤ 4/3)
    {t : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 3/4) :
    (∑ p, (bumpCoefficient v t p)^2)+(Fintype.card (Cube q):ℝ)*(constantCoefficient v t)^2 ≤
      45*(Fintype.card (Cube q):ℝ)*t^2 := by
  have hs : (∑ p, (bumpCoefficient v t p)^2) ≤ (Fintype.card (Cube q):ℝ)*(3*t)^2 := by
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun p _ =>
      (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr (bumpCoefficient_bound v hv ht ht1 p))
    simpa only [sq_abs,Finset.sum_const,Finset.card_univ,nsmul_eq_mul] using hh
  have hc := (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr (constantCoefficient_bound v hv ht ht1)
  rw [sq_abs] at hc
  have hm := mul_le_mul_of_nonneg_left hc (Nat.cast_nonneg (Fintype.card (Cube q)))
  nlinarith

lemma relay_energy_bound {a b : ℝ} (ha : 0 < a) (hb : 0 ≤ b) {u t : ℝ}
    (hu : 0 < u) (ht : 0 ≤ t) (ht1 : t ≤ 3/4) :
    b*a*(Real.artanh t/(a*u))^2 ≤ 9*(b/a)*(t/u)^2 := by
  have hat := Real.artanh_nonneg ht
  have hat' := artanh_le_three_mul ht ht1
  have hs := (sq_le_sq₀ hat (by positivity)).mpr hat'
  have hh := mul_le_mul_of_nonneg_left hs (show 0 ≤ b/(a*u^2) by positivity)
  calc
    _ = b/(a*u^2)*Real.artanh t^2 := by field_simp <;> ring
    _ ≤ b/(a*u^2)*(3*t)^2 := hh
    _ = _ := by ring

end NeuralGeneralization.DepthNormBall
