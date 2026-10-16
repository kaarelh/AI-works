import NeuralGeneralization.RudelsonFiniteRestriction
import NeuralGeneralization.RandomPartitionDecoupling
import NeuralGeneralization.MatrixOperatorGeometry
import NeuralGeneralization.SelectorColumnMaximum

/-!
# Actual random principal-submatrix second moment

The proof combines the checked rank-one Rademacher estimate, literal
independent selectors, a scalar column maximum estimate, and partition
decoupling. No random-matrix concentration theorem is assumed.
-/
noncomputable section
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {α : Type*} [Fintype α] [Nonempty α]

def restrictionConstant : ℝ := 2*(536870913:ℝ)^2

/-- The actual Euclidean operator estimate for a random row restriction. -/
theorem mean_operatorSquare_rowMask (A : Matrix (Fin m) (Fin D) ℝ)
    (choose : α → Bool) (V : ℝ) (hm : 0 < m) (hV : 0 ≤ V)
    (ha : ∀ i,(∑ j,A i j^2) ≤ V) :
    finiteMean (fun s : Fin m → α => operatorSquare (rowMask (fun i => choose (s i)) A)) ≤
      restrictionConstant*V*restrictionLog m D+2*selectionProbability choose*operatorSquare A := by
  obtain ⟨p,hroot,hp,he⟩ := finite_unit_witnesses
    (fun s : Fin m → α => rowMask (fun i => choose (s i)) A)
  have h := finite_selected_square_envelope_mean A p none hroot choose V (operatorSquare A)
    hm hV (sq_nonneg _) ha hp (fun u => unit_quadratic_le A (p u) (hp u))
  have hsel (s : Fin m → α) : selectedRows A choose s = rowMask (fun i => choose (s i)) A := rfl
  simp_rw [hsel,he] at h
  exact h

/-- Transposition gives the corresponding actual random-column estimate. -/
theorem mean_operatorSquare_colMask (A : Matrix (Fin m) (Fin D) ℝ)
    (choose : α → Bool) (V : ℝ) (hD : 0 < D) (hV : 0 ≤ V)
    (ha : ∀ j,(∑ i,A i j^2) ≤ V) :
    finiteMean (fun s : Fin D → α => operatorSquare (colMask (fun j => choose (s j)) A)) ≤
      restrictionConstant*V*restrictionLog D m+2*selectionProbability choose*operatorSquare A := by
  have h := mean_operatorSquare_rowMask A.transpose choose V hD hV ha
  simp_rw [← colMask_transpose,operatorSquare_transpose] at h
  exact h

/-- The actual twice-independent restriction bound. The entry and column
parameters are squared magnitudes, matching the scalar MGF estimate. -/
theorem decoupled_operatorSquare_mean (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (R C : ℝ) (hm : 0 < m) (hR : 0 < R) (hC : 0 ≤ C)
    (hentry : ∀ i j,A i j^2 ≤ R)
    (hrow : ∀ i,(∑ j,A i j^2) ≤ C)
    (hcol : ∀ j,(∑ i,A i j^2) ≤ C) :
    finiteMean (fun s : Fin m → α => finiteMean (fun t : Fin m → α =>
      operatorSquare (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A)))) ≤
      restrictionConstant*restrictionLog m m*R*Real.log m+
      restrictionConstant*(Real.exp 1+1)*selectionProbability choose*restrictionLog m m*C+
      4*(selectionProbability choose)^2*operatorSquare A := by
  letI : NeZero m := ⟨Nat.ne_of_gt hm⟩
  let q := selectionProbability choose
  let L := restrictionLog m m
  let V := fun t : Fin m → α => envelope (fun i : Fin m =>
    ∑ j,(colMask (fun j => choose (t j)) A) i j^2)
  have hq : 0 ≤ q := selectionProbability_nonneg choose
  have hL : 0 ≤ L := (show (0:ℝ) ≤ 1 by norm_num).trans (restrictionLog_ge_one hm)
  have hK : 0 ≤ restrictionConstant := by unfold restrictionConstant; positivity
  have hV (t : Fin m → α) : 0 ≤ V t := envelope_nonneg_finite _
  have hrowV (t : Fin m → α) (i : Fin m) :
      (∑ j,(colMask (fun j => choose (t j)) A) i j^2) ≤ V t := by
    have h := le_envelope_finite (fun i : Fin m => ∑ j,(colMask (fun j => choose (t j)) A) i j^2) i
    rw [abs_of_nonneg (show (0:ℝ) ≤ ∑ j,(colMask (fun j => choose (t j)) A) i j^2 from
      Finset.sum_nonneg (fun j _ => sq_nonneg _))] at h
    exact h
  have hcond (t : Fin m → α) := mean_operatorSquare_rowMask
    (colMask (fun j => choose (t j)) A) choose (V t) hm (hV t) (hrowV t)
  have hVmean : finiteMean V ≤ R*Real.log m+(Real.exp 1-1)*q*C := by
    have h := selector_column_maximum m choose (fun j i : Fin m => A i j^2) hR
      (fun _ _ => sq_nonneg _) (fun j i => hentry i j) hrow
    have he (t : Fin m → α) (i : Fin m) :
        (∑ j,selector choose (t j)*A i j^2) =
        ∑ j,(colMask (fun j => choose (t j)) A) i j^2 := by
      apply Finset.sum_congr rfl
      intro j _
      unfold selector colMask
      split_ifs <;> simp
    simpa only [he,Fintype.card_fin] using h
  have hcolmean := mean_operatorSquare_colMask A choose C hm hC hcol
  have hmean := finiteMean_mono hcond
  have he (t : Fin m → α) :
      restrictionConstant*V t*restrictionLog m m+2*selectionProbability choose*
        operatorSquare (colMask (fun j => choose (t j)) A) =
      (restrictionConstant*L)*V t+(2*q)*operatorSquare (colMask (fun j => choose (t j)) A) := by
    dsimp only [L,q]
    ring
  simp_rw [he] at hmean
  rw [finiteMean_add,finiteMean_mul,finiteMean_mul] at hmean
  rw [finiteMean_comm]
  apply hmean.trans
  have hv := mul_le_mul_of_nonneg_left hVmean (mul_nonneg hK hL)
  have hc := mul_le_mul_of_nonneg_left hcolmean (show 0 ≤ 2*q by positivity)
  calc
    _ ≤ (restrictionConstant*L)*(R*Real.log m+(Real.exp 1-1)*q*C)+
        (2*q)*(restrictionConstant*C*restrictionLog m m+2*selectionProbability choose*operatorSquare A) :=
      add_le_add hv hc
    _ = _ := by dsimp only [q,L]; ring

lemma sum_smul_single (A c : Matrix (Fin m) (Fin m) ℝ) :
    (∑ i,∑ j,c i j • Matrix.single i j (A i j)) = fun i j => c i j*A i j := by
  ext i j
  simp [Matrix.sum_apply,Matrix.single_apply,ite_and]

omit [Fintype α] [Nonempty α] in
lemma selector_sum_single (A : Matrix (Fin m) (Fin m) ℝ) (choose : α → Bool)
    (s t : Fin m → α) :
    (∑ i,∑ j,((if choose (s i) then (1:ℝ) else 0)*
      (if choose (t j) then (1:ℝ) else 0)) • Matrix.single i j (A i j)) =
      rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A) := by
  rw [sum_smul_single]
  ext i j
  unfold rowMask colMask
  split_ifs <;> simp

omit [Fintype α] [Nonempty α] in
lemma selectorCross_single (A : Matrix (Fin m) (Fin m) ℝ) (choose : α → Bool)
    (ε : Fin m → Bool) (s t : Fin m → α) :
    selectorCross choose ε s t (fun i j => Matrix.single i j (A i j)) =
      rowMask ε (colMask (fun i => !(ε i))
        (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A))) := by
  unfold selectorCross crossBlock
  simp_rw [smul_smul]
  rw [sum_smul_single]
  ext i j
  unfold rowMask colMask
  cases hi : ε i <;> cases hj : ε j <;>
    cases hs : choose (s i) <;> cases ht : choose (t j) <;> simp [hj,hs,ht]

/-- Actual Euclidean second-moment decoupling for a hollow matrix. -/
theorem hollow_operatorSquare_decoupling (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (hdiag : ∀ i,A i i=0) :
    finiteMean (fun s : Fin m → α =>
      operatorSquare (rowMask (fun i => choose (s i)) (colMask (fun j => choose (s j)) A))) ≤
      16*finiteMean (fun s : Fin m → α => finiteMean (fun t : Fin m → α =>
        operatorSquare (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A)))) := by
  have h := selector_partition_decoupling choose (fun i j => Matrix.single i j (A i j))
    (fun i => by rw [hdiag i,Matrix.single_zero])
  simp_rw [selector_sum_single,selectorCross_single] at h
  change _ ≤ 16*finiteMean (fun ε : Fin m → Bool => finiteMean (fun s : Fin m → α =>
    finiteMean (fun t : Fin m → α => operatorSquare (rowMask ε (colMask (fun i => !(ε i))
      (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A))))))) at h
  apply h.trans
  have hh := finiteMean_mono (fun ε : Fin m → Bool =>
    finiteMean_mono (fun s : Fin m → α => finiteMean_mono (fun t : Fin m → α =>
      (operatorSquare_rowMask_le ε (colMask (fun i => !(ε i))
        (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A)))).trans
      (operatorSquare_colMask_le (fun i => !(ε i))
        (rowMask (fun i => choose (s i)) (colMask (fun j => choose (t j)) A))))))
  rw [finiteMean_const] at hh
  exact mul_le_mul_of_nonneg_left hh (by norm_num)

/-- A fully proved principal-submatrix second moment, in the exact form
needed for the masked Walsh tail. All randomness is the original finite
product selector law. -/
theorem hollow_principal_operatorSquare_mean (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (R C : ℝ) (hm : 0 < m) (hR : 0 < R) (hC : 0 ≤ C)
    (hdiag : ∀ i,A i i=0) (hentry : ∀ i j,A i j^2 ≤ R)
    (hrow : ∀ i,(∑ j,A i j^2) ≤ C) (hcol : ∀ j,(∑ i,A i j^2) ≤ C) :
    finiteMean (fun s : Fin m → α =>
      operatorSquare (rowMask (fun i => choose (s i)) (colMask (fun j => choose (s j)) A))) ≤
      16*(restrictionConstant*restrictionLog m m*R*Real.log m+
        restrictionConstant*(Real.exp 1+1)*selectionProbability choose*restrictionLog m m*C+
        4*(selectionProbability choose)^2*operatorSquare A) := by
  exact (hollow_operatorSquare_decoupling A choose hdiag).trans
    (mul_le_mul_of_nonneg_left (decoupled_operatorSquare_mean A choose R C hm hR hC hentry hrow hcol)
      (by norm_num))

end NeuralGeneralization.RandomRestriction
