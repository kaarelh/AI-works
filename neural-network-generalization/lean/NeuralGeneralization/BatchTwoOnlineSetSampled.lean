import NeuralGeneralization.BatchTwoOnlineRawSampled
import NeuralGeneralization.BatchTwoOnlineRawFirstAppearance
import NeuralGeneralization.BatchTwoOnlineIIDSampling

/-! Exact first-appearance domination for sampled mistakes from arbitrary
set-dependent posterior risks. Duplicate queries have zero error probability. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {m n : ℕ}

def setSampledTail (R : Finset (Fin m) → Fin m → ℝ) (U : ℝ) (s : Fin n → Fin m) : ℝ :=
  ∑ b,if U < errorCount b then independentWeight (fun i => errorBitWeight (R (seenSet s i) (s i))) b else 0

def setPermutationSampledTail (R : Finset (Fin m) → Fin m → ℝ) (U : ℝ)
    (π : Equiv.Perm (Fin m)) : ℝ :=
  ∑ b,if U < errorCount b then independentWeight (fun i => errorBitWeight (R (permutationSeen π i) (π i))) b else 0

theorem setSampledTail_le_firstAppearance
    (R : Finset (Fin m) → Fin m → ℝ) (hR : ∀ S x,0 ≤ R S x ∧ R S x ≤ 1)
    (hrepeat : ∀ S x,x ∈ S → R S x=0)
    (s : Fin n → Fin m) (σ : Equiv.Perm (Fin m))
    (hσ : ∀ x y : Fin m,(σ.symm x).val < (σ.symm y).val ↔ firstKey s x < firstKey s y)
    (U : ℝ) : setSampledTail R U s ≤ setPermutationSampledTail R U σ := by
  let u : {i // i ∈ firstPositions s} ↪ Fin m :=
    ⟨fun i => σ.symm (s i.val),fun i j hij => Subtype.ext
      (firstPositions_injective s i.property j.property (σ.symm.injective hij))⟩
  have hp (i : {i // i ∈ firstPositions s}) :
      errorBitWeight (R (seenSet s i.val) (s i.val)) =
        errorBitWeight (R (permutationSeen σ (u i)) (σ (u i))) := by
    rw [seenSet_firstAppearance s σ hσ i.val i.property]
    simp [u]
  have hz (i : Fin n) (hi : i ∉ firstPositions s) (b : Bool) :
      errorBitWeight (R (seenSet s i) (s i)) b*(if b then (1:ℝ) else 0)=0 := by
    have hk : firstKey s (s i) < i.val := lt_of_le_of_ne (firstKey_le s i)
      (fun he => hi ((mem_firstPositions s i).mpr he))
    have hseen : s i ∈ seenSet s i := (mem_seenSet s i _).mpr
      ⟨⟨firstKey s (s i),hk.trans i.isLt⟩,hk,firstKey_hit s (s i) (hk.trans i.isLt)⟩
    rw [hrepeat _ _ hseen]
    cases b <;> norm_num [errorBitWeight]
  have hd := independent_discard_zero
    (fun i : Fin n => errorBitWeight (R (seenSet s i) (s i)))
    (fun _ => errorBitWeight_sum _) (fun i => i ∈ firstPositions s)
    (fun _ (b : Bool) => if b then (1:ℝ) else 0) hz
    (fun t => if U < t then (1:ℝ) else 0)
  have hi := independent_injection_tail_le u
    (fun i => errorBitWeight (R (permutationSeen σ i) (σ i)))
    (fun _ => errorBitWeight_sum _) (fun i => errorBitWeight_nonneg (hR _ _))
    (fun _ (b : Bool) => if b then (1:ℝ) else 0)
    (fun _ b => by cases b <;> norm_num) U
  simp only [hp] at hd
  have hleft : setSampledTail R U s =
      ∑ b : Fin n → Bool,independentWeight (fun i => errorBitWeight (R (seenSet s i) (s i))) b *
        (if U < ∑ i,if b i then (1:ℝ) else 0 then (1:ℝ) else 0) := by
    simp only [setSampledTail,errorCount,mul_ite,mul_one,mul_zero]
  calc
    _ = ∑ b : {i // i ∈ firstPositions s} → Bool,
        independentWeight (fun i => errorBitWeight (R (permutationSeen σ (u i)) (σ (u i)))) b *
        (if U < ∑ i,if b i then (1:ℝ) else 0 then (1:ℝ) else 0) := by
      rw [hleft]
      convert hd using 1 <;> congr! 6
    _ ≤ _ := by
      simp only [setPermutationSampledTail,errorCount,mul_ite,mul_one,mul_zero] at hi ⊢
      convert hi using 1 <;> congr! 6

lemma setSampledTail_relabel (R : Finset (Fin m) → Fin m → ℝ)
    (π : Equiv.Perm (Fin m)) (s : Fin n → Fin m) (U : ℝ) :
    setSampledTail R U (fun i => π (s i)) = setSampledTail (relabelSetRisk R π) U s := by
  simp [setSampledTail,seenSet_relabel,relabelSetRisk]

lemma setPermutationSampledTail_relabel (R : Finset (Fin m) → Fin m → ℝ)
    (π σ : Equiv.Perm (Fin m)) (U : ℝ) :
    setPermutationSampledTail (relabelSetRisk R π) U σ = setPermutationSampledTail R U (π*σ) := by
  simp [setPermutationSampledTail,permutationSeen_relabel,relabelSetRisk,Equiv.Perm.mul_apply]

/-- The actual uniform-IID finite query law is dominated by the complete
uniform-order sampled-mistake law, with no loss in the tail constant. -/
theorem setSampledTail_le_permutation (hm : 0 < m)
    (R : Finset (Fin m) → Fin m → ℝ) (hR : ∀ S x,0 ≤ R S x ∧ R S x ≤ 1)
    (hrepeat : ∀ S x,x ∈ S → R S x=0) (n : ℕ) (U : ℝ) :
    finiteMean (setSampledTail (n := n) R U) ≤ finiteMean (setPermutationSampledTail R U) := by
  letI : Nonempty (Fin m) := ⟨⟨0,hm⟩⟩
  calc
    _ = finiteMean (fun π : Equiv.Perm (Fin m) => finiteMean
        (fun s : Fin n → Fin m => setSampledTail R U (fun i => π (s i)))) := by
      simp only [finiteMean_relabel_samples,finiteMean_const]
    _ = finiteMean (fun s : Fin n → Fin m => finiteMean
        (fun π : Equiv.Perm (Fin m) => setSampledTail R U (fun i => π (s i)))) := finiteMean_comm _
    _ ≤ finiteMean (fun _s : Fin n → Fin m => finiteMean (setPermutationSampledTail R U)) := by
      apply finiteMean_mono
      intro s
      obtain ⟨σ,hσ⟩ := exists_firstAppearance_permutation s
      calc
        _ ≤ finiteMean (fun π : Equiv.Perm (Fin m) => setPermutationSampledTail R U (π*σ)) := by
          apply finiteMean_mono
          intro π
          rw [setSampledTail_relabel,← setPermutationSampledTail_relabel]
          exact setSampledTail_le_firstAppearance (relabelSetRisk R π) (fun S x => hR _ _)
            (fun S x hx => hrepeat _ _ (Finset.mem_image.mpr ⟨x,hx,rfl⟩)) s σ hσ U
        _ = _ := finiteMean_equiv (Equiv.mulRight σ) _
    _ = _ := finiteMean_const _

end NeuralGeneralization.BatchTwoOnlineRaw
