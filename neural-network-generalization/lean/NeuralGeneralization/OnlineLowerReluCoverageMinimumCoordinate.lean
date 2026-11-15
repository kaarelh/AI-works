import NeuralGeneralization.OnlineLowerReluSubcube
import NeuralGeneralization.OnlineLowerReluBalancedWalsh
import NeuralGeneralization.OnlineLowerReluCosineProduct

/-! # The literal minimum-coordinate parity inequality for arbitrary affine weights -/
set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLowerGeometry

def positiveSetEquiv (d : ℕ) : ClippingCube d ≃ Finset (Fin d) where
  toFun x := Finset.univ.filter (fun i => x i = true)
  invFun S i := decide (i ∈ S)
  left_inv x := by funext i;cases h : x i <;> simp [h]
  right_inv S := by ext i;simp

lemma positiveSet_sign (d : ℕ) (S : Finset (Fin d)) (i : Fin d) :
    cubeCoordinateSign ((positiveSetEquiv d).symm S i) = if i ∈ S then 1 else -1 := by
  simp [positiveSetEquiv,cubeCoordinateSign]

lemma positiveSet_full_parity (d : ℕ) (S : Finset (Fin d)) :
    walshCharacter Finset.univ ((positiveSetEquiv d).symm S) =
      (-1 : ℝ)^d * (-1 : ℝ)^S.card := by
  have hsign (i : Fin d) : cubeCoordinateSign ((positiveSetEquiv d).symm S i) =
      -(cubeCoordinateSign ((negativeSetEquiv d).symm S i)) := by
    rw [positiveSet_sign,negativeSet_sign]
    split_ifs <;> norm_num
  calc
    walshCharacter Finset.univ ((positiveSetEquiv d).symm S) =
        ∏ i : Fin d, (-1 : ℝ) * cubeCoordinateSign ((negativeSetEquiv d).symm S i) := by
      apply Finset.prod_congr rfl
      intro i _
      rw [hsign]
      ring
    _ = (-1 : ℝ)^d * walshCharacter Finset.univ ((negativeSetEquiv d).symm S) := by
      rw [Finset.prod_mul_distrib]
      simp [walshCharacter]
    _ = _ := by rw [negativeSet_full_parity]

lemma positiveSet_affine (d : ℕ) (b : ℝ) (u : Fin d → ℝ) (S : Finset (Fin d)) :
    cubeAffine b u ((positiveSetEquiv d).symm S) = b-(∑ i,u i)+2*∑ i∈S,u i := by
  unfold cubeAffine
  simp_rw [positiveSet_sign]
  have he (i : Fin d) : u i*(if i ∈ S then 1 else -1) = -u i+2*(if i ∈ S then u i else 0) := by
    split_ifs <;> ring
  simp_rw [he,Finset.sum_add_distrib,Finset.sum_neg_distrib,←Finset.mul_sum]
  simp only [Finset.sum_ite_mem,Finset.univ_inter]
  ring

lemma relu_full_parity_positive_subset_formula (d : ℕ) (b : ℝ) (u : Fin d → ℝ) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) Finset.univ| =
      |(∑ S : Finset (Fin d),(-1 : ℝ)^S.card * max (b-(∑ i,u i)+2*∑ i∈S,u i) 0)/(2 : ℝ)^d| := by
  unfold walshCoefficients uniformCubeMean
  rw [←Equiv.sum_comp (positiveSetEquiv d).symm]
  simp_rw [positiveSet_full_parity,positiveSet_affine]
  simp only [ClippingCube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,Nat.cast_ofNat]
  have he : (∑ S : Finset (Fin d),max (b-(∑ i,u i)+2*∑ i∈S,u i) 0 *
      ((-1 : ℝ)^d * (-1 : ℝ)^S.card)) =
      (-1 : ℝ)^d * ∑ S : Finset (Fin d),(-1 : ℝ)^S.card * max (b-(∑ i,u i)+2*∑ i∈S,u i) 0 := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S _
    ring
  rw [he,mul_div_assoc,abs_mul,abs_neg_one_pow,one_mul]

lemma relu_full_parity_bound_nonneg {n : ℕ} (b : ℝ) (u : Fin (n+2) → ℝ)
    (hu : ∀ i,0 ≤ u i) (j : Fin (n+2)) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) Finset.univ| ≤
      u j*(n.choose (n/2) : ℝ)/(2 : ℝ)^(n+1) := by
  let s := Finset.univ.erase j
  let score : Finset (Fin (n+2)) → ℝ := fun S => b-(∑ i,u i)+2*∑ i∈S,u i
  have hmono : Monotone score := by
    intro S T hST
    have h := Finset.sum_le_sum_of_subset_of_nonneg hST (fun i _ _ => hu i)
    dsimp [score]
    linarith
  have hcard : s.card=n+1 := by simp [s]
  have hstep : ∀ S ⊆ s,score (insert j S)=score S+2*u j := by
    intro S hS
    have hj : j ∉ S := fun hj => (Finset.mem_erase.mp (hS hj)).1 rfl
    dsimp [score]
    rw [Finset.sum_insert hj]
    ring
  have h := subcube_relu_parity_bound s j (by simp [s]) n hcard score hmono (u j) (hu j) hstep
  have hfull : insert j s=Finset.univ := by simp [s]
  have hp : (Finset.univ : Finset (Fin (n+2))).powerset = Finset.univ := by ext S;simp
  rw [hfull,hp] at h
  rw [relu_full_parity_positive_subset_formula]
  exact h

lemma relu_full_parity_abs_weights {d : ℕ} (b : ℝ) (u : Fin d → ℝ) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) Finset.univ| =
      |walshCoefficients (fun x => max (cubeAffine b (fun i => |u i|) x) 0) Finset.univ| := by
  let z : ClippingCube d := fun i => decide (0 ≤ u i)
  have hsign (i : Fin d) : |u i| * cubeCoordinateSign (z i)=u i := by
    by_cases hi : 0 ≤ u i
    · simp [z,cubeCoordinateSign,hi,abs_of_nonneg hi]
    · simp [z,cubeCoordinateSign,hi,abs_of_neg (lt_of_not_ge hi)]
  have heq : (fun x => max (cubeAffine b u x) 0) =
      (fun x => max (cubeAffine b (fun i => |u i|) (cubeTranslation z x)) 0) := by
    funext x
    unfold cubeAffine
    simp_rw [cubeCoordinateSign_translation,←mul_assoc,hsign]
  rw [heq]
  have htrans := walshCoefficients_translation z
    (fun x => max (cubeAffine b (fun i => |u i|) x) 0) Finset.univ
  rw [htrans,abs_mul,OnlineLower.walshCharacter_abs_one,one_mul]

/-- Every coordinate individually supplies the sharp bound. The incoming
weights have arbitrary signs and the additive bias is unrestricted. -/
theorem relu_minimum_coordinate_parity_bound (n : ℕ) (hn : 2 ≤ n)
    (b : ℝ) (u : Fin n → ℝ) (j : Fin n) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) Finset.univ| ≤
      (((n-2).choose ((n-2)/2) : ℝ)/(2 : ℝ)^(n-1)) * |u j| := by
  obtain ⟨r,rfl⟩ : ∃ r,n=r+2 := ⟨n-2,by omega⟩
  rw [relu_full_parity_abs_weights]
  have h := relu_full_parity_bound_nonneg b (fun i => |u i|) (fun i => abs_nonneg _) j
  convert h using 1 <;> simp only [Nat.add_sub_cancel_right,show r+2-1=r+1 by omega] <;> ring

/-- The exact minimum-over-coordinates form printed in the manuscript. -/
theorem relu_minimum_coordinate_parity_inf (n : ℕ) (hn : 2 ≤ n)
    (b : ℝ) (u : Fin n → ℝ) :
    |walshCoefficients (fun x => max (cubeAffine b u x) 0) Finset.univ| ≤
      (((n-2).choose ((n-2)/2) : ℝ)/(2 : ℝ)^(n-1)) *
        Finset.univ.inf' (show (Finset.univ : Finset (Fin n)).Nonempty from ⟨⟨0,by omega⟩,Finset.mem_univ _⟩)
          (fun i => |u i|) := by
  have hne : (Finset.univ : Finset (Fin n)).Nonempty := ⟨⟨0,by omega⟩,Finset.mem_univ _⟩
  obtain ⟨j,hj,hmin⟩ := (Finset.inf'_le_iff hne).mp (le_rfl :
    Finset.univ.inf' hne (fun i => |u i|) ≤ Finset.univ.inf' hne (fun i => |u i|))
  have heq : |u j|=Finset.univ.inf' hne (fun i => |u i|) :=
    le_antisymm hmin (Finset.inf'_le _ hj)
  rw [←heq]
  exact relu_minimum_coordinate_parity_bound n hn b u j

end NeuralGeneralization.OnlineLowerRelu
