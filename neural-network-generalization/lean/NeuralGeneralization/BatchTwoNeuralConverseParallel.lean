import NeuralGeneralization.BatchTwoNeuralConverseCloning
import Mathlib.Analysis.SpecificLimits.Basic

/-! Optimal square-root energy addition by finite cloning and direct sums. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Filter
open ConcreteModel

def parallelCopies (C : ℕ) (a q : ℝ) : ℕ := ⌈q*(a/(C : ℝ))⌉₊+1

theorem parallelCopies_pos (C : ℕ) (a q : ℝ) : 0<parallelCopies C a q := Nat.succ_pos _

def exactCloneEquiv (C k : ℕ) : ((Fin C × Fin k) ⊕ Fin 0) ≃ Fin (C*k) :=
  (Equiv.sumEmpty (Fin C × Fin k) (Fin 0)).trans finProdFinEquiv

def blockEquiv (n m : ℕ) : (Fin n ⊕ Fin m) ≃ Fin (n+m) := finSumFinEquiv

theorem parallel_normalized_width {C : ℕ} (hC : 0<C) {a : ℝ} (ha : 0≤a) :
    Tendsto (fun q : ℝ => ((C*parallelCopies C a q : ℕ) : ℝ)/q) atTop (𝓝 a) := by
  have hCR : (0 : ℝ)<C := by exact_mod_cast hC
  have hc := tendsto_nat_ceil_mul_div_atTop (div_nonneg ha hCR.le)
  have hi := tendsto_inv_atTop_zero (𝕜 := ℝ)
  have hsum := (hc.add hi).const_mul (C : ℝ)
  have he : (C : ℝ)*(a/(C : ℝ)+0)=a := by rw [add_zero,mul_div_cancel₀ _ hCR.ne']
  rw [he] at hsum
  convert hsum using 1
  ext q
  simp only [parallelCopies,Nat.cast_mul,Nat.cast_add,Nat.cast_one, mul_comm q (a/(C : ℝ))]
  ring

def parallelBound (n m : ℕ) (A B q : ℝ) : ℝ :=
  ((n*parallelCopies n (Real.sqrt A) q+m*parallelCopies m (Real.sqrt B) q : ℕ) : ℝ)/
      ((n*parallelCopies n (Real.sqrt A) q : ℕ) : ℝ)*A+
  ((n*parallelCopies n (Real.sqrt A) q+m*parallelCopies m (Real.sqrt B) q : ℕ) : ℝ)/
      ((m*parallelCopies m (Real.sqrt B) q : ℕ) : ℝ)*B

theorem parallelBound_tendsto {n m : ℕ} (hn : 0<n) (hm : 0<m)
    {A B : ℝ} (hA : 0<A) (hB : 0<B) :
    Tendsto (parallelBound n m A B) atTop (𝓝 ((Real.sqrt A+Real.sqrt B)^2)) := by
  have hα : 0<Real.sqrt A := Real.sqrt_pos.mpr hA
  have hβ : 0<Real.sqrt B := Real.sqrt_pos.mpr hB
  have h1 := parallel_normalized_width hn (Real.sqrt_nonneg A)
  have h2 := parallel_normalized_width hm (Real.sqrt_nonneg B)
  have hlim := (((h1.add h2).div h1 hα.ne').mul_const A).add
    (((h1.add h2).div h2 hβ.ne').mul_const B)
  have he : (Real.sqrt A+Real.sqrt B)/Real.sqrt A*A+
      (Real.sqrt A+Real.sqrt B)/Real.sqrt B*B=(Real.sqrt A+Real.sqrt B)^2 := by
    field_simp
    nlinarith [Real.sq_sqrt hA.le,Real.sq_sqrt hB.le]
  rw [he] at hlim
  apply hlim.congr'
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with q hq
  unfold parallelBound
  simp only [Pi.div_apply]
  have hnq : ((n*parallelCopies n (Real.sqrt A) q : ℕ) : ℝ)≠0 := by
    exact_mod_cast (Nat.mul_pos hn (parallelCopies_pos _ _ _)).ne'
  have hmq : ((m*parallelCopies m (Real.sqrt B) q : ℕ) : ℝ)≠0 := by
    exact_mod_cast (Nat.mul_pos hm (parallelCopies_pos _ _ _)).ne'
  rw [Nat.cast_add]
  field_simp

/-- Finite networks with arbitrary positive energies can be combined at
arbitrarily close to the sum of their square-root energies, preserving gain. -/
theorem exists_parallel_network {d n m r : ℕ} (hn : 0<n) (hm : 0<m)
    (w : Weights d n r) (v : Weights d m r) (Λ : ℝ)
    (hw : gainSq w<Λ^2*((r : ℝ)+1)*readoutEnergy w)
    (hv : gainSq v<Λ^2*((r : ℝ)+1)*readoutEnergy v)
    (hA : 0<weightedSquaredNorm w) (hB : 0<weightedSquaredNorm v)
    (ε : ℝ) (hε : 0<ε) :
    ∃ N : ℕ, 0<N ∧ ∃ u : Weights d N r,
      (∀ x, networkOutput Real.tanh u x=networkOutput Real.tanh w x+networkOutput Real.tanh v x) ∧
      weightedSquaredNorm u < (Real.sqrt (weightedSquaredNorm w)+Real.sqrt (weightedSquaredNorm v))^2+ε ∧
      gainSq u<Λ^2*((r : ℝ)+1)*readoutEnergy u := by
  have hlim := parallelBound_tendsto hn hm hA hB
  obtain ⟨q,hq⟩ := (hlim.eventually (gt_mem_nhds (lt_add_of_pos_right _ hε))).exists
  let k := parallelCopies n (Real.sqrt (weightedSquaredNorm w)) q
  let l := parallelCopies m (Real.sqrt (weightedSquaredNorm v)) q
  have hk : 0<k := parallelCopies_pos _ _ _
  have hl : 0<l := parallelCopies_pos _ _ _
  have hnk : 0<n*k := Nat.mul_pos hn hk
  have hml : 0<m*l := Nat.mul_pos hm hl
  let wc := clonedWeights (exactCloneEquiv n k) w
  let vc := clonedWeights (exactCloneEquiv m l) v
  let u := directWeights (blockEquiv (n*k) (m*l)) wc vc
  refine ⟨n*k+m*l,by omega,u,?_,?_,?_⟩
  · intro x
    rw [show u=directWeights (blockEquiv (n*k) (m*l)) wc vc from rfl,networkOutput_direct]
    simp only [wc,vc,networkOutput_cloned hk,networkOutput_cloned hl]
  · have hb := weightedSquaredNorm_direct_le hnk hml (Nat.le_add_right _ _) (Nat.le_add_left _ _)
      (blockEquiv (n*k) (m*l)) wc vc
    have hwc : weightedSquaredNorm wc=weightedSquaredNorm w :=
      weightedSquaredNorm_cloned_multiple hn hk rfl (exactCloneEquiv n k) w
    have hvc : weightedSquaredNorm vc=weightedSquaredNorm v :=
      weightedSquaredNorm_cloned_multiple hm hl rfl (exactCloneEquiv m l) v
    rw [hwc,hvc] at hb
    exact hb.trans_lt hq
  · exact gain_strict_direct hnk hml (by omega) (blockEquiv (n*k) (m*l)) wc vc Λ
      (gain_strict_cloned hn hk hnk (exactCloneEquiv n k) w Λ hw)
      (gain_strict_cloned hm hl hml (exactCloneEquiv m l) v Λ hv)

end
end NeuralGeneralization.BatchTwoNeuralConverse
