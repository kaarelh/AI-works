import NeuralGeneralization.BatchTwoContinuousDepthCriticalContinuity
import Mathlib.Topology.UniformSpace.HeineCantor

/-! Uniform finite-depth tracking on compact moment sets. The initial ideal
moments may depend on width, so deterministic integer seed allocations require
no limiting-proportion theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open Set
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem finite_recursion_uniform_stability {E:Type*} [MetricSpace E]
    (K:Set E) (F:ℕ→E→E) (hF:∀k,UniformContinuousOn (F k) K)
    (n:ℕ) {ε:ℝ} (hε:0<ε) :
    ∃δ:ℝ,0<δ ∧ ∀x y:ℕ→E,
      (∀k,k≤n→x k∈K) → (∀k,k≤n→y k∈K) →
      (∀k,k<n→x (k+1)=F k (x k)) → dist (y 0) (x 0)<δ →
      (∀k,k<n→dist (y (k+1)) (F k (y k))<δ) →
      ∀k,k≤n→dist (y k) (x k)<ε := by
  induction n generalizing ε with
  | zero =>
    refine ⟨ε,hε,?_⟩
    intro x y _ _ _ hy _ k hk
    have hk0:k=0:=Nat.eq_zero_of_le_zero hk
    simpa [hk0] using hy
  | succ n ih =>
    obtain ⟨η,hη,hcont⟩:=Metric.uniformContinuousOn_iff.mp (hF n) (ε/2) (by positivity)
    obtain ⟨δ,hδ,hprev⟩:=ih (ε:=min ε η) (lt_min hε hη)
    refine ⟨min δ (ε/2),lt_min hδ (by positivity),?_⟩
    intro x y hxK hyK hx hy hstep k hk
    have hprior:=hprev x y (fun j hj=>hxK j (by omega)) (fun j hj=>hyK j (by omega))
      (fun j hj=>hx j (by omega)) (hy.trans_le (min_le_left _ _))
      (fun j hj=>(hstep j (by omega)).trans_le (min_le_left _ _))
    by_cases hkn:k≤n
    · exact (hprior k hkn).trans_le (min_le_left _ _)
    · have hke:k=n+1:=by omega
      rw [hke,hx n (by omega)]
      have hc:=hcont (y n) (hyK n (by omega)) (x n) (hxK n (by omega))
        ((hprior n le_rfl).trans_le (min_le_right _ _))
      have hs:dist (y (n+1)) (F n (y n))<ε/2 :=
        (hstep n (by omega)).trans_le (min_le_right _ _)
      have ht:=dist_triangle (y (n+1)) (F n (y n)) (F n (x n))
      linarith

theorem finite_recursion_compact_stability {E:Type*} [MetricSpace E]
    (K:Set E) (hK:IsCompact K) (F:ℕ→E→E) (hF:∀k,ContinuousOn (F k) K)
    (n:ℕ) {ε:ℝ} (hε:0<ε) :
    ∃δ:ℝ,0<δ ∧ ∀x y:ℕ→E,
      (∀k,k≤n→x k∈K) → (∀k,k≤n→y k∈K) →
      (∀k,k<n→x (k+1)=F k (x k)) → dist (y 0) (x 0)<δ →
      (∀k,k<n→dist (y (k+1)) (F k (y k))<δ) →
      ∀k,k≤n→dist (y k) (x k)<ε :=
  finite_recursion_uniform_stability K F (fun k=>hK.uniformContinuousOn_of_continuous (hF k)) n hε

end NeuralGeneralization.BatchTwoContinuousDepthCritical
