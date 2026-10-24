import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductStateBounds

/-! The proved Gaussian row event implies the literal physical network's
one-step empirical moment transition, with exact auxiliary RMS normalization. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {d N r n:ℕ}

theorem free_empirical_step (hN:0<N) (free:ℕ→Bool) (hf:free r=true)
    (s:Fin n→BatchTwoContinuous.RealInput d) (w:Weights d N r)
    (ht:(∑i,(auxiliaryChannel free r w i)^2)/(N:ℝ)=1)
    (a:Fin N×Fin N→ℝ) {ε:ℝ} (hε:0<ε) (hεhalf:ε≤1/2)
    (hw:(fun i j=>Real.sqrt (N:ℝ)*a (i,j))∈
      freeRowEvent (fun j=>featureCoefficient w (s j))
        (channelCoefficient (auxiliaryChannel free r w)) ε N):
    (∑i,(auxiliaryChannel free (r+1) (appendLayer w (fun i j=>a (i,j))) i)^2)/(N:ℝ)=1 ∧
      dist (empiricalMoments free s (appendLayer w (fun i j=>a (i,j))))
        (freeMomentMap (empiricalMoments free s w))<4*ε:=by
  have hnorm:=freeRowEvent_normalized (fun j=>featureCoefficient w (s j))
    (channelCoefficient (auxiliaryChannel free r w)) hε hεhalf
    (fun i j=>Real.sqrt (N:ℝ)*a (i,j)) hw
    (fun j=>coefficient_free_mean_bound hN _ ht w (s j))
  have haux:auxiliaryChannel free (r+1) (appendLayer w (fun i j=>a (i,j)))=
      normalizedRowProjection (channelCoefficient (auxiliaryChannel free r w))
        (fun i j=>Real.sqrt (N:ℝ)*a (i,j)):=by
    simp only [auxiliaryChannel_append,hf,if_pos rfl]
    exact (normalizePhysicalProjection_standardized hN a _).symm
  refine ⟨?_,?_⟩
  · rw [haux]
    exact hnorm.1
  · rw [Prod.dist_eq]
    apply max_lt
    · rw [dist_pi_lt_iff (by positivity : 0<4*ε)]
      intro j
      have hh:|empiricalSecond (appendLayer w (fun i j=>a (i,j))) (s j)-
          coolingSecondMoment (empiricalSecond w (s j))|<ε:=by
        simpa only [rowAverage,featureCoefficient_energy,real_finalHidden_append_standardized hN,
          empiricalSecond] using (hw.2 j).1
      change dist (empiricalSecond _ _) (coolingSecondMoment (empiricalSecond _ _))<4*ε
      rw [Real.dist_eq]
      linarith
    · rw [dist_pi_lt_iff (by positivity : 0<4*ε)]
      intro j
      have hh:=hnorm.2 j
      simp only [real_finalHidden_append_standardized hN,coefficient_pairing,featureCoefficient_energy] at hh
      change dist (empiricalPairing (auxiliaryChannel free (r+1) _) _ (s j))
        (empiricalPairing (auxiliaryChannel free r w) w (s j)*coolingDerivative (empiricalSecond w (s j)))<4*ε
      rw [Real.dist_eq]
      unfold empiricalPairing
      rw [haux]
      exact hh

/-- A controlled layer resets its channel, so every possible realization has
unit auxiliary RMS, independently of the controlled event. -/
theorem controlled_auxiliary_unit (hN:0<N) (free:ℕ→Bool) (hf:free r=false)
    (w:Weights d N r) (a:Fin N→Fin N→ℝ):
    (∑i,(auxiliaryChannel free (r+1) (appendLayer w a) i)^2)/(N:ℝ)=1:=by
  rw [auxiliaryChannel_append,hf]
  simp only [Bool.false_eq_true,if_false,one_pow,Finset.sum_const,Finset.card_univ,
    Fintype.card_fin,nsmul_eq_mul,mul_one]
  exact div_self (by exact_mod_cast Nat.ne_of_gt hN)

theorem initial_auxiliary_unit (hN:0<N) (free:ℕ→Bool) (w:Weights d N 0):
    (∑i,(auxiliaryChannel free 0 w i)^2)/(N:ℝ)=1:=by
  simp only [auxiliaryChannel,one_pow,Finset.sum_const,Finset.card_univ,
    Fintype.card_fin,nsmul_eq_mul,mul_one]
  exact div_self (by exact_mod_cast Nat.ne_of_gt hN)

end NeuralGeneralization.BatchTwoContinuousDepthCritical
