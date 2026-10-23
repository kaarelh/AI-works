import NeuralGeneralization.BatchTwoNeuralConverseNeumann

/-! Stable exact inversion of the finite Hamming-shell staircase matrix. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical

def staircase {d : ℕ} (s j : Fin (d+1)) : ℝ :=
  if j=0 then 1 else if s.val<j.val then 1 else 0

def staircaseDecode {d : ℕ} (q : Fin (d+1) → ℝ) : Fin (d+1) → ℝ :=
  Fin.cases (q (Fin.last d)) (fun i => q i.castSucc-q i.succ)

theorem staircaseDecode_injective {d : ℕ} : Function.Injective (staircaseDecode (d := d)) := by
  intro p q hpq
  funext i
  induction i using Fin.reverseInduction with
  | last => simpa [staircaseDecode] using congrFun hpq 0
  | cast i ih =>
      have h := congrFun hpq i.succ
      simp only [staircaseDecode, Fin.cases_succ] at h
      linarith

theorem staircaseDecode_column {d : ℕ} (j i : Fin (d+1)) :
    staircaseDecode (fun s => staircase s j) i = if i=j then 1 else 0 := by
  induction i using Fin.cases with
  | zero =>
      simp only [staircaseDecode, Fin.cases_zero, staircase, Fin.val_last]
      by_cases hj : j=0
      · simp [hj]
      · have hn : ¬d<j.val := by omega
        simp [hj, hn, Ne.symm hj]
  | succ i =>
      simp only [staircaseDecode, Fin.cases_succ, staircase, Fin.val_castSucc, Fin.val_succ]
      by_cases hj : j=0
      · simp [hj]
      · simp only [hj, ↓reduceIte]
        by_cases hij : i.succ=j
        · subst j
          simp
        · have hneq : i.val+1 ≠ j.val := by
            intro he
            exact hij (Fin.ext he)
          rcases lt_or_gt_of_ne hneq with hlt | hgt
          · have hlt' : i.val<j.val := by omega
            simp [hlt', hlt, hij]
          · have hn : ¬i.val<j.val := by omega
            have hn' : ¬i.val+1<j.val := by omega
            simp [hn, hn', hij]

theorem staircaseDecode_sub {d : ℕ} (p q : Fin (d+1) → ℝ) :
    staircaseDecode (fun i => p i-q i) = fun i => staircaseDecode p i-staircaseDecode q i := by
  funext i
  induction i using Fin.cases <;> simp [staircaseDecode] <;> ring

theorem staircaseDecode_matrix {d : ℕ} (Q : Fin (d+1) → Fin (d+1) → ℝ)
    (v : Fin (d+1) → ℝ) :
    staircaseDecode (applyMatrix Q v) =
      applyMatrix (fun i j => staircaseDecode (fun s => Q s j) i) v := by
  funext i
  induction i using Fin.cases <;>
    simp [staircaseDecode, applyMatrix, sub_mul, Finset.sum_sub_distrib]

theorem staircaseDecode_l1 {d : ℕ} (q : Fin (d+1) → ℝ) :
    vectorL1 (staircaseDecode q) ≤ 2*vectorL1 q := by
  unfold vectorL1
  rw [Fin.sum_univ_succ]
  simp only [staircaseDecode, Fin.cases_zero, Fin.cases_succ]
  have htri : (∑ i : Fin d, |q i.castSucc-q i.succ|) ≤
      (∑ i : Fin d, |q i.castSucc|)+(∑ i : Fin d, |q i.succ|) := by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_le_sum (fun i _ => abs_sub _ _)
  have hcast := Fin.sum_univ_castSucc (fun i : Fin (d+1) => |q i|)
  have hsucc := Fin.sum_univ_succ (fun i : Fin (d+1) => |q i|)
  have h0 := abs_nonneg (q 0)
  linarith

theorem staircase_first_column_indicator {d : ℕ} (hd : 0 < d) (s : Fin (d+1)) :
    staircase s ⟨1,by omega⟩ = if s=0 then 1 else 0 := by
  have hone : (⟨1,by omega⟩ : Fin (d+1)) ≠ 0 := by intro he; have := congrArg Fin.val he; simp at this
  simp only [staircase, hone, ↓reduceIte]
  have he : s.val<1 ↔ s=0 := by rw [Fin.ext_iff]; simp
  simp only [he]

/-- If every staircase entry is perturbed by at most 1/(4(d+1)), its first
nonconstant column can still be selected exactly with coefficient l1 norm≤2. -/
theorem exists_staircase_coefficients {d : ℕ} (hd : 0 < d)
    (Q : Fin (d+1) → Fin (d+1) → ℝ)
    (hQ : ∀ s j, |Q s j-staircase s j| ≤ 1/(4*(d+1 : ℝ))) :
    ∃ v : Fin (d+1) → ℝ, vectorL1 v ≤ 2 ∧
      ∀ s, applyMatrix Q v s = if s=0 then 1 else 0 := by
  let M : Fin (d+1) → Fin (d+1) → ℝ := fun i j => staircaseDecode (fun s => Q s j) i
  let A : Fin (d+1) → Fin (d+1) → ℝ := fun i j => (if i=j then 1 else 0)-M i j
  let j₀ : Fin (d+1) := ⟨1,by omega⟩
  let b : Fin (d+1) → ℝ := fun i => if i=j₀ then 1 else 0
  have hb : vectorL1 b = 1 := by simp [vectorL1, b, abs_ite]
  have hA : ∀ j, (∑ i, |A i j|) ≤ 1/2 := by
    intro j
    let e : Fin (d+1) → ℝ := fun s => staircase s j-Q s j
    have he : ∀ i, A i j = staircaseDecode e i := by
      intro i
      dsimp [A, M, e]
      simp only [staircaseDecode_sub, staircaseDecode_column]
    simp_rw [he]
    have hl1 : vectorL1 e ≤ 1/4 := by
      calc
        _ ≤ ∑ _s : Fin (d+1), 1/(4*(d+1 : ℝ)) := by
          apply Finset.sum_le_sum
          intro s _
          simpa only [e, abs_sub_comm] using hQ s j
        _ = _ := by simp; field_simp
    have h := staircaseDecode_l1 e
    change vectorL1 (staircaseDecode e) ≤ 1/2
    linarith
  obtain ⟨v,hv,hvbound⟩ := exists_neumann_solution A b hA
  refine ⟨v, by rw [hb] at hvbound; linarith, ?_⟩
  have hM : applyMatrix M v = b := by
    funext i
    have he := hv i
    have hAeq : applyMatrix A v i = v i-applyMatrix M v i := by
      simp [applyMatrix, A, sub_mul, Finset.sum_sub_distrib]
    rw [hAeq] at he
    linarith
  have hdecode : staircaseDecode (applyMatrix Q v) = staircaseDecode (fun s => staircase s j₀) := by
    rw [staircaseDecode_matrix]
    change applyMatrix M v = _
    rw [hM]
    funext i
    exact (staircaseDecode_column j₀ i).symm
  have heq := staircaseDecode_injective hdecode
  intro s
  rw [congrFun heq s]
  exact staircase_first_column_indicator hd s

end
end NeuralGeneralization.BatchTwoNeuralConverse
