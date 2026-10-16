import NeuralGeneralization.RandomMatrixRestriction
import NeuralGeneralization.MatrixSamplingGeometry
import NeuralGeneralization.SelectorToIID

/-!
# Actual IID sampled matrix bound

Literal selector concentration is transferred to literal IID samples. The
only loss is the explicit birthday collision term; the sample operator
norm is the actual Euclidean norm of the sampled matrix.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical
attribute [local instance] Classical.propDecidable

variable {m n : ℕ} {α : Type*} [Fintype α] [Nonempty α]

omit [Nonempty α] in
lemma finiteEvent_le_mean_div (F : α → ℝ) (hF : ∀ x,0 ≤ F x)
    (t : ℝ) (ht : 0 < t) :
    finiteEvent (fun x => t < F x) ≤ finiteMean F/t := by
  have hp (x : α) : t*(if t<F x then (1:ℝ) else 0) ≤ F x := by
    split_ifs with h
    · simpa using h.le
    · simpa using hF x
  have hh := finiteMean_mono hp
  rw [finiteMean_mul] at hh
  apply (le_div_iff₀ ht).mpr
  simpa only [finiteEvent,mul_comm] using hh

/-- A principal-subset bad event is upward closed for the actual operator
norm; this is the geometry required for selector-to-IID transfer. -/
lemma principal_bad_mono (A : Matrix (Fin m) (Fin m) ℝ) (t : ℝ) :
    ∀ S T : Finset (Fin m), S ⊆ T →
      t < operatorSquare (principalMask S A) → t < operatorSquare (principalMask T A) := by
  intro S T hST ht
  exact ht.trans_le (operatorSquare_principalMask_mono A hST)

/-- A generic transfer from the actual selector mean of a matrix norm to
injective IID sample matrices. No conditional sample law is assumed. -/
theorem sampled_operatorSquare_probability_of_mean (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (hn : 4 ≤ n) (hm : 0 < m)
    (hmean : (m:ℝ)*selectionProbability choose=2*(n:ℝ))
    (B t : ℝ) (ht : 0 < t)
    (hB : finiteMean (fun ω : Fin m → α => operatorSquare
      (rowMask (fun i => choose (ω i)) (colMask (fun j => choose (ω j)) A))) ≤ B) :
    finiteEvent (fun s : Fin n → Fin m =>
      Function.Injective s ∧ t < operatorSquare (sampledMatrix A s)) ≤
      2*B/t+(n:ℝ)*((n:ℝ)-1)/(2*(m:ℝ)) := by
  letI : NeZero m := ⟨Nat.ne_of_gt hm⟩
  have hp : selectorProbability choose=selectionProbability choose := by
    unfold selectorProbability selectionProbability
    congr 1
  have hmean' : (Fintype.card (Fin m):ℝ)*selectorProbability choose=2*(n:ℝ) := by
    simpa only [Fintype.card_fin,hp] using hmean
  have htransfer := selector_to_iid_monotone n choose hn hmean'
    (fun S => t < operatorSquare (principalMask S A)) (principal_bad_mono A t)
  have hsample : finiteEvent (fun s : Fin n → Fin m =>
      Function.Injective s ∧ t < operatorSquare (sampledMatrix A s)) ≤
      finiteEvent (fun s : Fin n → Fin m => t < operatorSquare (principalMask (sampleRange s) A)) := by
    apply finiteMean_mono
    intro s
    by_cases hs : Function.Injective s ∧ t < operatorSquare (sampledMatrix A s)
    · rw [if_pos hs,if_pos (hs.2.trans_le (operatorSquare_sampledMatrix_le A s hs.1))]
    · rw [if_neg hs]
      split_ifs <;> norm_num
  have hmarkov := finiteEvent_le_mean_div
    (fun ω : Fin m → α => operatorSquare
      (rowMask (fun i => choose (ω i)) (colMask (fun j => choose (ω j)) A)))
    (fun _ => sq_nonneg _) t ht
  simp_rw [principalMask_selectedSet] at htransfer
  have hmb := hmarkov.trans (div_le_div_of_nonneg_right hB ht.le)
  simp only [Fintype.card_fin] at htransfer
  calc
    _ ≤ _ := hsample.trans htransfer
    _ ≤ 2*(B/t)+(n:ℝ)*((n:ℝ)-1)/(2*(m:ℝ)) :=
      add_le_add (mul_le_mul_of_nonneg_left hmb (show (0:ℝ) ≤ 2 by norm_num)) (le_refl _)
    _ = _ := by ring

/-- The unconditional IID bound includes collisions explicitly. -/
theorem sampled_operatorSquare_probability_of_mean_unconditional (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (hn : 4 ≤ n) (hm : 0 < m)
    (hmean : (m:ℝ)*selectionProbability choose=2*(n:ℝ))
    (B t : ℝ) (ht : 0 < t)
    (hB : finiteMean (fun ω : Fin m → α => operatorSquare
      (rowMask (fun i => choose (ω i)) (colMask (fun j => choose (ω j)) A))) ≤ B) :
    finiteEvent (fun s : Fin n → Fin m => t < operatorSquare (sampledMatrix A s)) ≤
      2*B/t+(n:ℝ)*((n:ℝ)-1)/(m:ℝ) := by
  letI : NeZero m := ⟨Nat.ne_of_gt hm⟩
  have hmain := sampled_operatorSquare_probability_of_mean A choose hn hm hmean B t ht hB
  have hcol := iid_collision_probability (V := Fin m) (n := n) (by omega)
  have hh : finiteEvent (fun s : Fin n → Fin m => t < operatorSquare (sampledMatrix A s)) ≤
      finiteEvent (fun s : Fin n → Fin m => Function.Injective s ∧ t < operatorSquare (sampledMatrix A s))+
      finiteEvent (fun s : Fin n → Fin m => ¬Function.Injective s) := by
    unfold finiteEvent
    rw [←finiteMean_add]
    apply finiteMean_mono
    intro s
    by_cases hi : Function.Injective s <;>
      by_cases hb : t < operatorSquare (sampledMatrix A s) <;> simp [hi,hb]
  simp only [Fintype.card_fin] at hcol
  calc
    _ ≤ _ := hh
    _ ≤ (2*B/t+(n:ℝ)*((n:ℝ)-1)/(2*(m:ℝ)))+
      (n:ℝ)*((n:ℝ)-1)/(2*(m:ℝ)) := add_le_add hmain hcol
    _ = _ := by ring

/-- The fully quantitative actual IID random principal matrix theorem. -/
theorem hollow_sampled_operatorSquare_probability (A : Matrix (Fin m) (Fin m) ℝ)
    (choose : α → Bool) (R C t : ℝ) (hn : 4 ≤ n) (hm : 0 < m)
    (hmean : (m:ℝ)*selectionProbability choose=2*(n:ℝ))
    (hR : 0 < R) (hC : 0 ≤ C) (ht : 0 < t)
    (hdiag : ∀ i,A i i=0) (hentry : ∀ i j,A i j^2 ≤ R)
    (hrow : ∀ i,(∑ j,A i j^2) ≤ C) (hcol : ∀ j,(∑ i,A i j^2) ≤ C) :
    finiteEvent (fun s : Fin n → Fin m => t < operatorSquare (sampledMatrix A s)) ≤
      32*(restrictionConstant*restrictionLog m m*R*Real.log m+
        restrictionConstant*(Real.exp 1+1)*selectionProbability choose*restrictionLog m m*C+
        4*(selectionProbability choose)^2*operatorSquare A)/t+
      (n:ℝ)*((n:ℝ)-1)/(m:ℝ) := by
  have hh := sampled_operatorSquare_probability_of_mean_unconditional A choose hn hm hmean _ t ht
    (hollow_principal_operatorSquare_mean A choose R C hm hR hC hdiag hentry hrow hcol)
  convert hh using 1
  ring

/-- A concrete selector alphabet removes every selector-law premise from
the IID bound: retain the first `2n` labels of a uniform `Fin m` draw. -/
theorem hollow_sampled_operatorSquare_probability_explicit (A : Matrix (Fin m) (Fin m) ℝ)
    (R C t : ℝ) (hn : 4 ≤ n) (hnm : 2*n ≤ m)
    (hR : 0 < R) (hC : 0 ≤ C) (ht : 0 < t)
    (hdiag : ∀ i,A i i=0) (hentry : ∀ i j,A i j^2 ≤ R)
    (hrow : ∀ i,(∑ j,A i j^2) ≤ C) (hcol : ∀ j,(∑ i,A i j^2) ≤ C) :
    finiteEvent (fun s : Fin n → Fin m => t < operatorSquare (sampledMatrix A s)) ≤
      32*(restrictionConstant*restrictionLog m m*R*Real.log m+
        restrictionConstant*(Real.exp 1+1)*(2*(n:ℝ)/(m:ℝ))*restrictionLog m m*C+
        4*(2*(n:ℝ)/(m:ℝ))^2*operatorSquare A)/t+
      (n:ℝ)*((n:ℝ)-1)/(m:ℝ) := by
  have hm : 0<m := by omega
  letI : NeZero m := ⟨Nat.ne_of_gt hm⟩
  have hp : selectionProbability (initialSelector m (2*n))=2*(n:ℝ)/(m:ℝ) := by
    have hh := initialSelector_probability hnm
    have he : selectorProbability (initialSelector m (2*n))=
        selectionProbability (initialSelector m (2*n)) := by
      unfold selectorProbability selectionProbability
      congr 1
    rw [he] at hh
    simpa only [Nat.cast_mul,Nat.cast_ofNat] using hh
  have hmean : (m:ℝ)*selectionProbability (initialSelector m (2*n))=2*(n:ℝ) := by
    rw [hp]
    field_simp
  have hh := hollow_sampled_operatorSquare_probability A (initialSelector m (2*n))
    R C t hn hm hmean hR hC ht hdiag hentry hrow hcol
  simpa only [hp] using hh

end NeuralGeneralization.RandomRestriction
