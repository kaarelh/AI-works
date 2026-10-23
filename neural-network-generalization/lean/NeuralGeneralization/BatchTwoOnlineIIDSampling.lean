import NeuralGeneralization.BatchTwoOnlineMarginal

/-! # IID posterior-sampling mistakes and their first-appearance coupling -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m n : ℕ}

def iidDrawWeight (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (s : Fin n → Fin m) : (Fin n → H) → ℝ :=
  sequentialDrawWeight w good (extendSample m hm s) n

def iidMistakes (good : H → Fin m → Prop) (s : Fin n → Fin m)
    (draw : Fin n → H) : ℝ := ∑ i, pointLoss good (draw i) (s i)

def iidSampledTail (hm : 0 < m) (w : H → ℝ) (good : H → Fin m → Prop)
    (U : ℝ) (s : Fin n → Fin m) : ℝ :=
  ∑ draw, if U < iidMistakes good s draw then iidDrawWeight hm w good s draw else 0

lemma iid_weighted_loss_eq_error (hm : 0 < m) (w : H → ℝ)
    (good : H → Fin m → Prop) (s : Fin n → Fin m) (i : Fin n) :
    (∑ g, onlinePosterior w good (extendSample m hm s) i.val g * pointLoss good g (s i)) =
      onlineError w good (extendSample m hm s) i.val := by
  unfold onlineError pointLoss
  simp only [extendSample, dif_pos i.isLt]
  apply Finset.sum_congr rfl
  intro g _
  split_ifs <;> simp

lemma expected_iidMistakes_eq (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (s : Fin n → Fin m) :
    (∑ draw, iidDrawWeight hm w good s draw * iidMistakes good s draw) = iidTotal hm w good s := by
  unfold iidDrawWeight sequentialDrawWeight iidMistakes
  rw [independent_expected_sum
    (fun i : Fin n => onlinePosterior w good (extendSample m hm s) i.val)
    (fun i => onlinePosterior_sum w good _ hw target htarget hwt i.val)
    (fun i g => pointLoss good g (s i))]
  simp_rw [iid_weighted_loss_eq_error]
  exact Fin.sum_univ_eq_sum_range (onlineError w good (extendSample m hm s)) n

lemma repeated_weighted_loss_zero (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (s : Fin n → Fin m) (i : Fin n) (hi : i∉firstPositions s) (g : H) :
    onlinePosterior w good (extendSample m hm s) i.val g * pointLoss good g (s i)=0 := by
  have hn (g : H) : 0 ≤ onlinePosterior w good (extendSample m hm s) i.val g * pointLoss good g (s i) :=
    mul_nonneg (onlinePosterior_nonneg w good _ hw target htarget hwt i.val g)
      (pointLoss_nonneg good g (s i))
  have hz : (∑ g, onlinePosterior w good (extendSample m hm s) i.val g * pointLoss good g (s i))=0 := by
    rw [iid_weighted_loss_eq_error, onlineError_zero_of_not_first hm s w good i hi]
  exact le_antisymm (by
    rw [← hz]
    exact Finset.single_le_sum (fun g _ => hn g) (Finset.mem_univ g)) (hn g)

/-- For each fixed query sequence, the complete first-appearance order
stochastically dominates actual fresh posterior-sampling mistakes. -/
theorem iidSampledTail_le_firstAppearance (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m, (σ.symm x).val < (σ.symm y).val ↔ firstKey s x < firstKey s y)
    (U : ℝ) :
    iidSampledTail hm w good U s ≤
      ∑ draw, if U < sampledMistakes good σ draw then permutationDrawWeight w good σ draw else 0 := by
  let u : {i // i∈firstPositions s} ↪ Fin m :=
    ⟨fun i => σ.symm (s i.val), fun i j hij => Subtype.ext
      (firstPositions_injective s i.property j.property (σ.symm.injective hij))⟩
  have hp (i : {i // i∈firstPositions s}) :
      onlinePosterior w good (extendSample m hm s) i.val.val =
        posterior w (prefixKeep good σ (u i).val) := by
    unfold onlinePosterior
    congr 1
    exact history_eq_firstAppearance_prefix hm s σ hσ good i.val i.property
  have hL (i : {i // i∈firstPositions s}) (g : H) :
      pointLoss good g (s i.val) = pointLoss good g (σ (u i)) := by simp [u]
  have hd := independent_discard_zero
    (fun i : Fin n => onlinePosterior w good (extendSample m hm s) i.val)
    (fun i => onlinePosterior_sum w good _ hw target htarget hwt i.val)
    (fun i => i∈firstPositions s) (fun i g => pointLoss good g (s i))
    (fun i hi g => repeated_weighted_loss_zero hm w hw good target htarget hwt s i hi g)
    (fun t => if U < t then (1:ℝ) else 0)
  have hi := independent_injection_tail_le u
    (fun i => posterior w (prefixKeep good σ i.val))
    (fun i => posterior_sum w _ hw target (fun j _ => htarget (σ j)) hwt)
    (fun i g => posterior_nonneg w _ hw target (fun j _ => htarget (σ j)) hwt g)
    (fun i g => pointLoss good g (σ i)) (fun i g => pointLoss_nonneg good g (σ i)) U
  simp only [hp, hL] at hd
  have hleft : iidSampledTail hm w good U s =
      ∑ draw : Fin n → H,
        independentWeight (fun i => onlinePosterior w good (extendSample m hm s) i.val) draw *
          (if U < ∑ i, pointLoss good (draw i) (s i) then (1:ℝ) else 0) := by
    unfold iidSampledTail iidMistakes iidDrawWeight sequentialDrawWeight
    simp only [mul_ite, mul_one, mul_zero]
  calc
    _ = ∑ draw : {i // i∈firstPositions s} → H,
        independentWeight (fun i => posterior w (prefixKeep good σ (u i).val)) draw *
          (if U < ∑ i, pointLoss good (draw i) (σ (u i)) then (1:ℝ) else 0) := by
      rw [hleft]
      convert hd using 1 <;> congr! 6
    _ ≤ _ := by
      simp only [permutationDrawWeight, sampledMistakes, mul_ite, mul_one, mul_zero] at hi ⊢
      convert hi using 1 <;> congr! 6

lemma iidSampledTail_relabel (hm : 0 < m) (w : H → ℝ)
    (good : H → Fin m → Prop) (π : Equiv.Perm (Fin m))
    (s : Fin n → Fin m) (U : ℝ) :
    iidSampledTail hm w good U (fun j => π (s j)) =
      iidSampledTail hm w (fun g x => good g (π x)) U s := by
  have hp (i : Fin n) : onlinePosterior w good (extendSample m hm (fun j => π (s j))) i.val =
      onlinePosterior w (fun g x => good g (π x)) (extendSample m hm s) i.val := by
    have hh : history good (extendSample m hm (fun j => π (s j))) i.val =
        history (fun g x => good g (π x)) (extendSample m hm s) i.val := by
      funext g
      apply propext
      unfold history
      constructor <;> intro h j hj
      all_goals
        have hjn := hj.trans i.isLt
        simpa only [extendSample, dif_pos hjn] using h j hj
    unfold onlinePosterior
    congr 1
  unfold iidSampledTail iidDrawWeight sequentialDrawWeight independentWeight iidMistakes pointLoss
  simp only [hp]

/-- Exact IID sampled-mistake upper-tail domination, under the actual
uniform product query law and actual independent posterior draws. -/
theorem iidSampledTail_le_permutation (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target) (n : ℕ) (U : ℝ) :
    finiteMean (iidSampledTail (n := n) hm w good U) ≤
      finiteMean (fun π : Equiv.Perm (Fin m) =>
        ∑ draw, if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0) := by
  letI : Nonempty (Fin m) := ⟨⟨0,hm⟩⟩
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m) => finiteMean
        (fun s : Fin n → Fin m => iidSampledTail hm w good U (fun j => π (s j)))) := by
      simp only [finiteMean_relabel_samples, finiteMean_const]
    _ = finiteMean (fun s : Fin n → Fin m => finiteMean
        (fun π : Equiv.Perm (Fin m) => iidSampledTail hm w good U (fun j => π (s j)))) := finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n → Fin m => finiteMean
        (fun π : Equiv.Perm (Fin m) => ∑ draw,
          if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩ := exists_firstAppearance_permutation s
      calc
        _ ≤ finiteMean (fun π : Equiv.Perm (Fin m) => ∑ draw,
            if U < sampledMistakes good (π*σ) draw then permutationDrawWeight w good (π*σ) draw else 0) := by
          apply finiteMean_mono
          intro π
          rw [iidSampledTail_relabel]
          exact iidSampledTail_le_firstAppearance hm w hw (fun g x => good g (π x))
            target (fun x => htarget (π x)) hwt s σ hσ U
        _ = _ := finiteMean_equiv (Equiv.mulRight σ)
          (fun π => ∑ draw, if U < sampledMistakes good π draw then permutationDrawWeight w good π draw else 0)
    _ = _ := finiteMean_const _

end NeuralGeneralization.BatchTwoOnline
