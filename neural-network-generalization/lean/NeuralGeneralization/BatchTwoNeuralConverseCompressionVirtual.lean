import NeuralGeneralization.BatchTwoNeuralConverseNoise
import NeuralGeneralization.SamplingLaw

/-! Forward virtual evaluation of the actual sampled network. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel CompressionSampling
variable {d N r M : ℕ}

def virtualStep (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (h : Fin N → ℝ) (s : Fin r) : Fin N → ℝ :=
  fun i => Real.tanh ((N : ℝ)/M*∑ a, w (Sum.inr (Sum.inl (s,i,I s.castSucc a)))*h (I s.castSucc a))

def virtualPrefix (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (x : Cube d) (n : ℕ) : Fin N → ℝ :=
  ((List.finRange r).take n).foldl (virtualStep w I) (firstHidden Real.tanh w x)

def virtualOutput (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) : ℝ :=
  (N : ℝ)/M*∑ a, w (Sum.inr (Sum.inr (I (Fin.last r) a)))*virtualPrefix w I x r (I (Fin.last r) a)

theorem virtualPrefix_zero (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) :
    virtualPrefix w I x 0=firstHidden Real.tanh w x := by simp [virtualPrefix]

theorem virtualPrefix_succ (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (x : Cube d) (s : Fin r) :
    virtualPrefix w I x (s.val+1)=virtualStep w I (virtualPrefix w I x s.val) s := by
  unfold virtualPrefix
  rw [List.take_succ_eq_append_getElem (by simp)]
  simp

theorem virtualPrefix_bounded (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (x : Cube d) (n : ℕ) (i : Fin N) : |virtualPrefix w I x n i|≤1 := by
  have aux (ss : List (Fin r)) (h : Fin N → ℝ) (hh : ∀ i,|h i|≤1) :
      ∀ i, |ss.foldl (virtualStep w I) h i|≤1 := by
    induction ss generalizing h with
    | nil => exact hh
    | cons s ss ih =>
      apply ih
      intro j
      exact tanh_admissible.1 _
  exact aux _ _ (fun j => tanh_admissible.1 _) i

theorem sampled_prefix_eq_virtual (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (x : Cube d) (s : Fin (r+1)) (a : Fin M) :
    hiddenPrefix Real.tanh (sampledWeights w I) x s.val a=virtualPrefix w I x s.val (I s a) := by
  induction s using Fin.induction generalizing a with
  | zero => rfl
  | succ s ih =>
    simp only [Fin.val_succ, Fin.val_castSucc] at ih ⊢
    rw [hiddenPrefix_succ,virtualPrefix_succ]
    simp only [hiddenStep,sampledWeights,virtualStep]
    simp_rw [ih]
    rw [Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro b _
    ring

theorem sampled_output_eq_virtual (w : Weights d N r) (I : Fin (r+1) → Fin M → Fin N)
    (x : Cube d) : networkOutput Real.tanh (sampledWeights w I) x=virtualOutput w I x := by
  unfold networkOutput virtualOutput
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro a _
  have hs := sampled_prefix_eq_virtual w I x (Fin.last r) a
  simp only [Fin.val_last,hiddenPrefix_last] at hs
  rw [hs]
  simp only [sampledWeights]
  ring

theorem virtualPrefix_congr_lists (w : Weights d N r)
    (I J : Fin (r+1) → Fin M → Fin N) (x : Cube d) (n : ℕ)
    (hIJ : ∀ s : Fin r, s.val<n → I s.castSucc=J s.castSucc) :
    virtualPrefix w I x n=virtualPrefix w J x n := by
  have aux (ss : List (Fin r)) (h : Fin N → ℝ)
      (hss : ∀ s∈ss, I s.castSucc=J s.castSucc) :
      ss.foldl (virtualStep w I) h=ss.foldl (virtualStep w J) h := by
    induction ss generalizing h with
    | nil => rfl
    | cons s ss ih =>
      simp only [List.foldl_cons]
      have he : virtualStep w I h s=virtualStep w J h s := by
        funext i
        dsimp only [virtualStep]
        rw [hss s (List.mem_cons_self ..)]
      rw [he]
      exact ih _ (fun t ht => hss t (List.mem_cons_of_mem _ ht))
  apply aux
  intro s hs
  apply hIJ
  obtain ⟨k,hk,hks⟩ := List.mem_take_iff_getElem.mp hs
  have he : s.val=k := by
    have := congrArg Fin.val hks
    simpa using this.symm
  omega

theorem virtualPrefix_update_fresh (w : Weights d N r)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) (s : Fin (r+1)) (J : Fin M → Fin N) :
    virtualPrefix w (Function.update I s J) x s.val=virtualPrefix w I x s.val := by
  apply virtualPrefix_congr_lists
  intro t ht
  have hne : t.castSucc≠s := by intro he; have := congrArg Fin.val he; simp at this; omega
  exact Function.update_of_ne hne _ _

def virtualDisturbance (original sampled : Weights d N r)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) : NetworkDisturbance N r :=
  (Fin.cases
    (firstHidden Real.tanh sampled x-firstHidden Real.tanh original x)
    (fun s => virtualPrefix sampled I x (s.val+1)-hiddenStep Real.tanh original (virtualPrefix sampled I x s.val) s),
    virtualOutput sampled I x-∑ i,original (Sum.inr (Sum.inr i))*virtualPrefix sampled I x r i)

theorem virtual_disturbance_prefix (original sampled : Weights d N r)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) (s : Fin (r+1)) :
    noisyAfter original x (virtualDisturbance original sampled I x) s.val=virtualPrefix sampled I x s.val := by
  induction s using Fin.induction with
  | zero =>
    funext i
    simp [noisyAfter,noisyFirstHidden,virtualDisturbance,virtualPrefix,Pi.sub_apply]
  | succ s ih =>
    simp only [Fin.val_succ, Fin.val_castSucc] at ih ⊢
    rw [noisyAfter_succ, ih]
    funext i
    simp only [noisyHiddenStep,virtualDisturbance,Fin.cases_succ,Pi.sub_apply,hiddenStep]
    ring

theorem virtual_disturbance_output (original sampled : Weights d N r)
    (I : Fin (r+1) → Fin M → Fin N) (x : Cube d) :
    noisyNetworkOutput Real.tanh original x (virtualDisturbance original sampled I x)=
      virtualOutput sampled I x := by
  have htake : (List.finRange r).take r=List.finRange r := by
    simpa only [List.length_finRange] using (List.take_length (l := List.finRange r))
  have hs := virtual_disturbance_prefix original sampled I x (Fin.last r)
  simp only [Fin.val_last,noisyAfter,htake] at hs
  change noisyFinalHidden Real.tanh original x (virtualDisturbance original sampled I x)=_ at hs
  unfold noisyNetworkOutput
  rw [hs]
  simp only [virtualDisturbance]
  ring

end
end NeuralGeneralization.BatchTwoNeuralConverse
