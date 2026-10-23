import NeuralGeneralization.BatchTwoOnlineFirstAppearance

/-! # Exact finite IID domination by the uniform first-appearance order -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m n : ℕ}

def iidTotal (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (s : Fin n → Fin m) : ℝ := cumulativeError w good (extendSample m hm s) n

lemma onlineError_relabel_sample (hm : 0 < m) (w : H → ℝ)
    (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (s : Fin n → Fin m) (i : Fin n) :
    onlineError w good (extendSample m hm (fun j => π (s j))) i.val =
    onlineError w (fun g x => good g (π x)) (extendSample m hm s) i.val := by
  have hh : history good (extendSample m hm (fun j => π (s j))) i.val =
      history (fun g x => good g (π x)) (extendSample m hm s) i.val := by
    funext g
    apply propext
    unfold history
    constructor <;> intro h j hj
    all_goals
      have hjn := hj.trans i.isLt
      simpa only [extendSample, dif_pos hjn] using h j hj
  unfold onlineError onlinePosterior
  simp only [hh, extendSample, dif_pos i.isLt]

lemma iidTotal_relabel (hm : 0 < m) (w : H → ℝ)
    (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m)) (s : Fin n → Fin m) :
    iidTotal hm w good (fun j => π (s j)) =
      iidTotal hm w (fun g x => good g (π x)) s := by
  unfold iidTotal cumulativeError
  rw [← Fin.sum_univ_eq_sum_range _ n, ← Fin.sum_univ_eq_sum_range _ n]
  exact Finset.sum_congr rfl fun i _ => onlineError_relabel_sample hm w good π s i

lemma permutationTotal_relabel (w : H → ℝ) (good : H → Fin m → Prop)
    (π σ : Equiv.Perm (Fin m)) :
    permutationTotal w (fun g x => good g (π x)) σ = permutationTotal w good (π*σ) := by
  rfl

/-- Relabeling a fixed sequence uniformly makes its completed first-appearance
order uniform. This gives a pointwise coupling for every fixed sequence. -/
theorem relabeled_iidTotal_le (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (s : Fin n → Fin m) :
    ∃ σ : Equiv.Perm (Fin m), ∀ π : Equiv.Perm (Fin m),
      iidTotal hm w good (fun j => π (s j)) ≤ permutationTotal w good (π*σ) := by
  obtain ⟨σ,hσ⟩ := exists_firstAppearance_permutation s
  refine ⟨σ,fun π => ?_⟩
  rw [iidTotal_relabel, ← permutationTotal_relabel]
  exact cumulativeError_le_firstAppearance_permutation hm s σ hσ w hw
    (fun g x => good g (π x)) target (fun x => htarget (π x)) hwt

def sampleRelabelEquiv (π : Equiv.Perm (Fin m)) :
    (Fin n → Fin m) ≃ (Fin n → Fin m) :=
  Equiv.piCongrRight (fun _ => π)

lemma finiteMean_relabel_samples (π : Equiv.Perm (Fin m))
    (F : (Fin n → Fin m) → ℝ) :
    finiteMean (fun s : Fin n → Fin m => F (fun j => π (s j))) = finiteMean F :=
  finiteMean_equiv (sampleRelabelEquiv π) F

/-- Every finite IID horizon is dominated in expectation by the complete
uniform random order, without waiting for all inputs to appear. -/
theorem expected_iidTotal_le_permutation (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target) (n : ℕ) :
    finiteMean (iidTotal (n := n) hm w good) ≤ finiteMean (permutationTotal w good) := by
  letI : Nonempty (Fin m) := ⟨⟨0,hm⟩⟩
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m) =>
        finiteMean (fun s : Fin n → Fin m => iidTotal hm w good (fun j => π (s j)))) := by
      simp only [finiteMean_relabel_samples, finiteMean_const]
    _ = finiteMean (fun s : Fin n → Fin m =>
        finiteMean (fun π : Equiv.Perm (Fin m) => iidTotal hm w good (fun j => π (s j)))) :=
      finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n → Fin m => finiteMean (permutationTotal w good)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩ := relabeled_iidTotal_le hm w hw good target htarget hwt s
      calc
        _ ≤ finiteMean (fun π => permutationTotal w good (π*σ)) := finiteMean_mono hσ
        _ = _ := finiteMean_equiv (Equiv.mulRight σ) _
    _ = _ := finiteMean_const _

/-- The same first-appearance coupling dominates every upper-tail event. -/
theorem iidTotal_tail_le_permutation (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target) (n : ℕ) (U : ℝ) :
    finiteEvent (fun s : Fin n → Fin m => U < iidTotal hm w good s) ≤
      finiteEvent (fun π : Equiv.Perm (Fin m) => U < permutationTotal w good π) := by
  letI : Nonempty (Fin m) := ⟨⟨0,hm⟩⟩
  unfold finiteEvent
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m) =>
        finiteMean (fun s : Fin n → Fin m => if U < iidTotal hm w good (fun j => π (s j)) then (1:ℝ) else 0)) := by
      have he (π : Equiv.Perm (Fin m)) := finiteMean_relabel_samples π
        (fun s : Fin n → Fin m => if U < iidTotal hm w good s then (1:ℝ) else 0)
      simp_rw [he]
      exact (finiteMean_const _).symm
    _ = finiteMean (fun s : Fin n → Fin m =>
        finiteMean (fun π : Equiv.Perm (Fin m) => if U < iidTotal hm w good (fun j => π (s j)) then (1:ℝ) else 0)) :=
      finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n → Fin m =>
        finiteMean (fun π : Equiv.Perm (Fin m) => if U < permutationTotal w good π then (1:ℝ) else 0)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩ := relabeled_iidTotal_le hm w hw good target htarget hwt s
      calc
        _ ≤ finiteMean (fun π => if U < permutationTotal w good (π*σ) then (1:ℝ) else 0) := by
          apply finiteMean_mono
          intro π
          by_cases he : U < iidTotal hm w good (fun j => π (s j))
          · simp only [if_pos he, if_pos (he.trans_le (hσ π))]; exact le_rfl
          · simp only [if_neg he]; split_ifs <;> norm_num
        _ = _ := finiteMean_equiv (Equiv.mulRight σ)
          (fun π => if U < permutationTotal w good π then (1:ℝ) else 0)
    _ = _ := finiteMean_const _

end NeuralGeneralization.BatchTwoOnline
