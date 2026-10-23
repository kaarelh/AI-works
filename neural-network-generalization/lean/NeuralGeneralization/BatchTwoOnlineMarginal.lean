import NeuralGeneralization.BatchTwoOnlineIIDFinite
import Mathlib.Logic.Equiv.Prod

/-! # Marginals of the literal finite product posterior law -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
variable {I J H : Type*} [Fintype I] [Fintype J] [Fintype H]

lemma independentWeight_split (p : I → H → ℝ) (P : I → Prop) (draw : I → H) :
    independentWeight p draw =
      independentWeight (fun i : {i // P i} => p i.val) (fun i => draw i.val) *
      independentWeight (fun i : {i // ¬ P i} => p i.val) (fun i => draw i.val) :=
  (Fintype.prod_subtype_mul_prod_subtype P (fun i => p i (draw i))).symm

/-- Exact marginalization over unused independent coordinates. -/
theorem independent_restrict (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g=1)
    (P : I → Prop) (F : ({i // P i} → H) → ℝ) :
    (∑ draw : I → H, independentWeight p draw * F (fun i => draw i.val)) =
      ∑ draw : {i // P i} → H,
        independentWeight (fun i => p i.val) draw * F draw := by
  let e := Equiv.piEquivPiSubtypeProd P (fun _ : I => H)
  have ht (draw : I → H) :
      independentWeight p draw * F (fun i => draw i.val) =
      (fun z : ({i // P i} → H) × ({i // ¬P i} → H) =>
        independentWeight (fun i => p i.val) z.1 *
        independentWeight (fun i => p i.val) z.2 * F z.1) (e draw) := by
    rw [independentWeight_split p P]
    rfl
  simp_rw [ht]
  rw [e.sum_comp (fun z : ({i // P i} → H) × ({i // ¬P i} → H) =>
    independentWeight (fun i => p i.val) z.1 *
    independentWeight (fun i => p i.val) z.2 * F z.1), Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro draw _
  calc
    _ = (independentWeight (fun i : {i // P i} => p i.val) draw * F draw) *
        (∑ draw' : {i // ¬P i} → H, independentWeight (fun i => p i.val) draw') := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro draw' _
      ring
    _ = _ := by rw [independentWeight_sum (fun i : {i // ¬P i} => p i.val) (fun i => hp i.val), mul_one]

/-- Reindexing an independent family does not change its law. -/
theorem independent_reindex (e : I ≃ J) (p : J → H → ℝ)
    (F : (I → H) → ℝ) :
    (∑ draw : J → H, independentWeight p draw * F (fun i => draw (e i))) =
      ∑ draw : I → H, independentWeight (fun i => p (e i)) draw * F draw := by
  let q : (J → H) ≃ (I → H) := Equiv.arrowCongr e.symm (Equiv.refl H)
  have hp (draw : J → H) : independentWeight p draw =
      independentWeight (fun i => p (e i)) (q draw) := by
    exact (e.prod_comp (fun j => p j (draw j))).symm
  simp_rw [hp]
  exact q.sum_comp (fun draw => independentWeight (fun i => p (e i)) draw * F draw)

/-- A zero weighted loss on discarded coordinates removes them from the
entire distribution of the sum, not only from its expectation. -/
theorem independent_discard_zero (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g=1)
    (P : I → Prop) (L : I → H → ℝ)
    (hz : ∀ i, ¬P i → ∀ g, p i g * L i g=0) (F : ℝ → ℝ) :
    (∑ draw : I → H, independentWeight p draw * F (∑ i, L i (draw i))) =
      ∑ draw : {i // P i} → H,
        independentWeight (fun i => p i.val) draw * F (∑ i, L i.val (draw i)) := by
  have ht (draw : I → H) :
      independentWeight p draw * F (∑ i, L i (draw i)) =
      independentWeight p draw * F (∑ i : {i // P i}, L i.val (draw i.val)) := by
    by_cases hd : independentWeight p draw=0
    · simp only [hd, zero_mul]
    · have hcoord : ∀ i, p i (draw i)≠0 := fun i =>
        (Finset.prod_ne_zero_iff.mp hd) i (Finset.mem_univ i)
      have hzero : ∑ i : {i // ¬P i}, L i.val (draw i.val)=0 := by
        apply Finset.sum_eq_zero
        intro i _
        exact (mul_eq_zero.mp (hz i.val i.property (draw i.val))).resolve_left (hcoord i.val)
      rw [← Fintype.sum_subtype_add_sum_subtype P (fun i => L i (draw i)), hzero, add_zero]
  simp_rw [ht]
  exact independent_restrict p hp P (fun draw => F (∑ i, L i.val (draw i)))

/-- Dropping any subfamily of nonnegative independent losses can only decrease
its upper-tail probability. The selected coordinates retain their exact laws. -/
theorem independent_injection_tail_le (u : I ↪ J)
    (p : J → H → ℝ) (hp : ∀ j, ∑ g, p j g=1) (hp0 : ∀ j g, 0 ≤ p j g)
    (L : J → H → ℝ) (hL : ∀ j g, 0 ≤ L j g) (U : ℝ) :
    (∑ draw : I → H, independentWeight (fun i => p (u i)) draw *
      (if U < ∑ i, L (u i) (draw i) then (1:ℝ) else 0)) ≤
    ∑ draw : J → H, independentWeight p draw *
      (if U < ∑ j, L j (draw j) then (1:ℝ) else 0) := by
  let e : I ≃ {j // ∃ i, u i=j} := Equiv.ofBijective
    (fun i => ⟨u i,⟨i,rfl⟩⟩) ⟨fun i j h => u.injective (Subtype.mk.inj h),
      fun ⟨j,⟨i,hi⟩⟩ => ⟨i,Subtype.ext hi⟩⟩
  have he := independent_reindex e (fun j : {j // ∃ i, u i=j} => p j.val)
    (fun draw : I → H => if U < ∑ i, L (u i) (draw i) then (1:ℝ) else 0)
  have hs (draw : {j // ∃ i, u i=j} → H) :
      (∑ i, L (u i) (draw (e i))) = ∑ j, L j.val (draw j) :=
    e.sum_comp (fun j => L j.val (draw j))
  simp only [hs] at he
  change _ = ∑ draw : I → H, independentWeight (fun i => p (u i)) draw *
    (if U < ∑ i, L (u i) (draw i) then (1:ℝ) else 0) at he
  rw [← he]
  have hr := independent_restrict p hp (fun j => ∃ i, u i=j)
    (fun draw => if U < ∑ j : {j // ∃ i, u i=j}, L j.val (draw j) then (1:ℝ) else 0)
  have hr' : (∑ draw : {j // ∃ i, u i=j} → H, independentWeight (fun j => p j.val) draw *
      (if U < ∑ j, L j.val (draw j) then (1:ℝ) else 0)) =
      ∑ draw : J → H, independentWeight p draw *
        (if U < ∑ j : {j // ∃ i, u i=j}, L j.val (draw j.val) then (1:ℝ) else 0) := by
    convert hr.symm using 1
    congr! 3
  calc
    _ = ∑ draw : J → H, independentWeight p draw *
        (if U < ∑ j : {j // ∃ i, u i=j}, L j.val (draw j.val) then (1:ℝ) else 0) := by
      convert hr' using 1
      congr! 3
    _ ≤ _ := by
      apply Finset.sum_le_sum
      intro draw _
      apply mul_le_mul_of_nonneg_left _ (independentWeight_nonneg p hp0 draw)
      have hsum : (∑ j : {j // ∃ i, u i=j}, L j.val (draw j.val)) ≤ ∑ j, L j (draw j) := by
        rw [← Fintype.sum_subtype_add_sum_subtype (fun j => ∃ i, u i=j)]
        exact le_add_of_nonneg_right (Finset.sum_nonneg (fun j _ => hL j.val (draw j.val)))
      by_cases hevent : U < ∑ j : {j // ∃ i, u i=j}, L j.val (draw j.val)
      · simp only [if_pos hevent, if_pos (hevent.trans_le hsum)]; exact le_rfl
      · simp only [if_neg hevent]; split_ifs <;> norm_num

end NeuralGeneralization.BatchTwoOnline
