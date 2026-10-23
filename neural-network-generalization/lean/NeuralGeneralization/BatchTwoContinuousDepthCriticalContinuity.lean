import NeuralGeneralization.BatchTwoContinuousDepthCriticalRowLaw
import NeuralGeneralization.BatchTwoContinuousDepthCriticalAmplificationBudget

/-! Continuity of the actual Gaussian moment maps and stability of a finite
controlled trajectory. These statements let finite-width laws of large numbers
follow a fixed-depth limiting trajectory without assuming a large-deviation
principle. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

def shiftedMean (q m : ℝ) : ℝ := ∫ z, Real.tanh (m+Real.sqrt q*z) ∂gaussianReal 0 1

def shiftedSecond (q m : ℝ) : ℝ := ∫ z, (Real.tanh (m+Real.sqrt q*z))^2 ∂gaussianReal 0 1

theorem shiftedMean_continuous : Continuous (fun p:ℝ×ℝ=>shiftedMean p.1 p.2) := by
  apply continuous_of_dominated (bound:=fun _=>1) (fun p=>by fun_prop)
    (fun p=>Filter.Eventually.of_forall fun z=>by
      simpa only [Real.norm_eq_abs] using (Real.abs_tanh_lt_one (p.2+Real.sqrt p.1*z)).le)
    (integrable_const 1)
  filter_upwards [] with z
  fun_prop

theorem shiftedSecond_continuous : Continuous (fun p:ℝ×ℝ=>shiftedSecond p.1 p.2) := by
  apply continuous_of_dominated (bound:=fun _=>1) (fun p=>by fun_prop)
    (fun p=>Filter.Eventually.of_forall fun z=>by
      rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
      exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le)
    (integrable_const 1)
  filter_upwards [] with z
  fun_prop

theorem coolingSecondMoment_continuous : Continuous coolingSecondMoment := by
  unfold coolingSecondMoment
  have h:=shiftedSecond_continuous.comp (continuous_id.prodMk (continuous_const (y:=(0:ℝ))))
  simpa only [Function.comp_def,id_eq,shiftedSecond,coolingSecondMoment,zero_add] using h

theorem coolingDerivative_continuous : Continuous coolingDerivative := by
  have he : coolingDerivative=fun q=>1-coolingSecondMoment q := funext coolingDerivative_eq
  rw [he]
  exact continuous_const.sub coolingSecondMoment_continuous

def freeMomentMap {J:Type*} (s:(J→ℝ)×(J→ℝ)) : (J→ℝ)×(J→ℝ) :=
  (fun i=>coolingSecondMoment (s.1 i),fun i=>s.2 i*coolingDerivative (s.1 i))

def controlledMomentMap {J:Type*} (A:ℝ) (s:(J→ℝ)×(J→ℝ)) : (J→ℝ)×(J→ℝ) :=
  (fun i=>shiftedSecond (s.1 i) (A*s.2 i),fun i=>shiftedMean (s.1 i) (A*s.2 i))

theorem freeMomentMap_continuous {J:Type*} : Continuous (@freeMomentMap J) := by
  apply Continuous.prodMk
  · exact continuous_pi fun i=>coolingSecondMoment_continuous.comp ((continuous_apply i).comp continuous_fst)
  · exact continuous_pi fun i=>((continuous_apply i).comp continuous_snd).mul
      (coolingDerivative_continuous.comp ((continuous_apply i).comp continuous_fst))

/-- Any finite continuous deterministic trajectory is tracked by sufficiently
accurate one-step approximations. The tolerance is uniform over every step. -/
theorem finite_recursion_stability {E:Type*} [MetricSpace E]
    (F:ℕ→E→E) (x:ℕ→E) (hF:∀k,ContinuousAt (F k) (x k))
    (hx:∀k,x (k+1)=F k (x k)) (n:ℕ) {ε:ℝ} (hε:0<ε) :
    ∃δ:ℝ,0<δ ∧ ∀y:ℕ→E,dist (y 0) (x 0)<δ →
      (∀k,k<n→dist (y (k+1)) (F k (y k))<δ) →
      ∀k,k≤n→dist (y k) (x k)<ε := by
  induction n generalizing ε with
  | zero =>
    refine ⟨ε,hε,?_⟩
    intro y hy _ k hk
    have hk0:k=0:=Nat.eq_zero_of_le_zero hk
    simpa [hk0] using hy
  | succ n ih =>
    obtain ⟨η,hη,hcont⟩:=Metric.continuousAt_iff.mp (hF n) (ε/2) (by positivity)
    obtain ⟨δ,hδ,hprev⟩:=ih (ε:=min ε η) (lt_min hε hη)
    refine ⟨min δ (ε/2),lt_min hδ (by positivity),?_⟩
    intro y hy hstep k hk
    have hprior:=hprev y (hy.trans_le (min_le_left _ _))
      (fun j hj=>(hstep j (by omega)).trans_le (min_le_left _ _))
    by_cases hkn:k≤n
    · exact (hprior k hkn).trans_le (min_le_left _ _)
    · have hke:k=n+1:=by omega
      rw [hke,hx n]
      have hc:=hcont ((hprior n le_rfl).trans_le (min_le_right _ _))
      have hs:dist (y (n+1)) (F n (y n))<ε/2 :=
        (hstep n (by omega)).trans_le (min_le_right _ _)
      have ht:=dist_triangle (y (n+1)) (F n (y n)) (F n (x n))
      linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
