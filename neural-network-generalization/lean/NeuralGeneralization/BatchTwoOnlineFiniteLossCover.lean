import NeuralGeneralization.BatchTwoOnlineRemainingLaw
import NeuralGeneralization.BatchTwoOnlineRawGeneral
import NeuralGeneralization.BatchTwoOnlineRawPosteriorControl

/-! The online paper's general finite-loss extension. A loss cover may be
selected anew at each history and network; only its finite class is fixed
before the input order. No measurable selection of representatives is used. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {H W : Type*} [Fintype H] [DecidableEq H] [MeasurableSpace W] {m : ℕ}

/-- Zero loss is the consistency predicate. Passing to its support indicator
only strengthens domination of a binary tested-error event. -/
def lossGood (loss : H → Fin m → ℝ) (h : H) (x : Fin m) : Prop := loss h x = 0

/-- A posterior controlled outside a small discarded set by one finite
zero-training-loss cover. The cover can depend on the retained network. -/
theorem finite_loss_posterior_bound
    (Q : Measure W) [IsProbabilityMeasure Q] (i : Fin m) (π : Equiv.Perm (Fin m))
    (A : Finset H) (loss : H → Fin m → ℝ) (err : W → Fin m → Prop)
    (herr : ∀ x,MeasurableSet {w | err w x})
    (E : Set W) (hE : MeasurableSet E) {β u : ℝ} (hu : 0 ≤ u)
    (htail : Q.real E ≤ β)
    (hcover : ∀ᵐ w ∂Q,w ∉ E → ∃ h ∈ A,
      prefixKeep (lossGood loss) π i.val h ∧ ∀ x,err w x → 1 ≤ loss h x)
    (hs : ∀ h ∈ A,prefixKeep (lossGood loss) π i.val h → domainError (lossGood loss) h ≤ u) :
    (∫ x,Q.real {w | err w (π x)} ∂remainingLaw i) ≤ (m:ℝ)/(m-i.val:ℕ)*u+β := by
  let τ : ℝ := (m:ℝ)/(m-i.val:ℕ)*u
  have hτ : 0 ≤ τ := by dsimp [τ]; positivity
  let risk : W → ℝ := fun w => ∫ x,(if err w (π x) then (1:ℝ) else 0) ∂remainingLaw i
  have hi (x : Fin m) : Integrable (fun w => if err w (π x) then (1:ℝ) else 0) Q :=
    (integrable_const 1).indicator (herr (π x))
  have hrisk : risk = fun w => ∑ x,(remainingLaw i).real {x} *
      (if err w (π x) then (1:ℝ) else 0) := by
    funext w
    exact integral_fintype (RobustStatistics.integrable_finite_domain _ _)
  have hirisk : Integrable risk Q := by
    rw [hrisk]
    exact integrable_finset_sum _ (fun x _ => (hi x).const_mul _)
  have hone (w : W) : risk w ≤ 1 := by
    have hh := integral_mono (RobustStatistics.integrable_finite_domain (remainingLaw i)
      (fun x => if err w (π x) then (1:ℝ) else 0)) (integrable_const 1)
      (fun x => by split_ifs <;> norm_num)
    simpa [risk] using hh
  have hp : ∀ᵐ w ∂Q,risk w ≤ τ+E.indicator (fun _ => (1:ℝ)) w := by
    filter_upwards [hcover] with w hw
    by_cases he : w ∈ E
    · simp only [Set.indicator_of_mem he]
      linarith [hone w]
    · simp only [Set.indicator_of_notMem he,add_zero]
      obtain ⟨h,hA,hkeep,hdom⟩ := hw he
      have hbound : (∫ x,pointLoss (lossGood loss) h (π x) ∂remainingLaw i) ≤ τ := by
        rw [remainingLaw_integral]
        change remainingLoss (lossGood loss) π i.val h ≤ τ
        rw [remainingLoss_eq _ π i.val i.isLt h hkeep]
        exact mul_le_mul_of_nonneg_left (hs h hA hkeep) (by positivity)
      apply le_trans _ hbound
      apply integral_mono (RobustStatistics.integrable_finite_domain _ _)
        (RobustStatistics.integrable_finite_domain _ _)
      intro x
      by_cases hx : err w (π x)
      · have hbad : ¬lossGood loss h (π x) := by
          intro hz
          have hh := hdom (π x) hx
          change loss h (π x)=0 at hz
          linarith
        simp [hx,pointLoss,hbad]
      · simp only [if_neg hx]
        unfold pointLoss
        split_ifs <;> norm_num
  have hiE : Integrable (E.indicator (fun _ => (1:ℝ))) Q := (integrable_const 1).indicator hE
  have hb := integral_mono_ae hirisk ((integrable_const τ).add hiE) hp
  simp only [Pi.add_apply] at hb
  rw [integral_add (integrable_const τ) hiE,integral_const,probReal_univ,smul_eq_mul,one_mul] at hb
  have hind : (∫ w,E.indicator (fun _ => (1:ℝ)) w ∂Q) = Q.real E := integral_indicator_one hE
  rw [hind] at hb
  have heq : (∫ w,risk w ∂Q) = ∫ x,Q.real {w | err w (π x)} ∂remainingLaw i := by
    rw [hrisk,integral_finset_sum _ (fun x _ => (hi x).const_mul _)]
    simp only [integral_const_mul]
    rw [integral_fintype (RobustStatistics.integrable_finite_domain _ _)]
    apply Finset.sum_congr rfl
    intro x _
    congr 1
    exact integral_indicator_one (herr (π x))
  rw [heq] at hb
  exact hb.trans (add_le_add le_rfl htail)

/-- Literal posterior errors generate the abstract adapted cover process.
All assumptions are the paper's general finite-loss-cover premises; there
is no requirement that the cover elements are posterior hypotheses. -/
def finiteLossProcess
    (A : Finset H) (loss : H → Fin m → ℝ)
    (Q : Fin m → Equiv.Perm (Fin m) → Measure W)
    (hQ : ∀ i π,IsProbabilityMeasure (Q i π))
    (Qadapt : ∀ i k j π,i.val ≤ k.val → k.val ≤ j.val → Q i (π*Equiv.swap k j)=Q i π)
    (err : W → Fin m → Prop) (herr : ∀ x,MeasurableSet {w | err w x})
    (β : ℝ)
    (hcover : ∀ i π,0 < i.val → ∃ E : Set W,MeasurableSet E ∧ (Q i π).real E ≤ β ∧
      ∀ᵐ w ∂Q i π,w ∉ E → ∃ h ∈ A,
        prefixKeep (lossGood loss) π i.val h ∧ ∀ x,err w x → 1 ≤ loss h x) :
    CoverProcess A (lossGood loss) β where
  risk i π := (Q i π).real {w | err w (π i)}
  range i π := by
    letI := hQ i π
    exact ⟨measureReal_nonneg,measureReal_le_one⟩
  adapted i k j π hik hkj := by
    have hi : Equiv.swap k j i=i := by
      apply Equiv.swap_apply_of_ne_of_ne <;> intro he <;> subst i <;> omega
    rw [Qadapt i k j π hik.le hkj,Equiv.Perm.mul_apply,hi]
  control i π hi u hu hs := by
    letI := hQ i π
    obtain ⟨E,hE,htail,hcov⟩ := hcover i π hi
    have hb := finite_loss_posterior_bound (Q i π) i π A loss err herr E hE hu htail hcov hs
    rw [remainingLaw_integral] at hb
    change _ ≤ (m:ℝ)/(m-i.val:ℕ)*u+β
    unfold remainingAverage
    convert hb using 1
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : i.val ≤ j.val
    · simp only [if_pos hj,Qadapt i i j π le_rfl hj,Equiv.Perm.mul_apply,Equiv.swap_apply_left]
    · simp only [if_neg hj]

/-- Both manuscript bounds hold for arbitrary finite loss covers of actual
posterior measures, including history-dependent representative selection. -/
theorem finite_loss_online_bounds (hm : 0 < m)
    (A : Finset H) (loss : H → Fin m → ℝ)
    (Q : Fin m → Equiv.Perm (Fin m) → Measure W)
    (hQ : ∀ i π,IsProbabilityMeasure (Q i π))
    (Qadapt : ∀ i k j π,i.val ≤ k.val → k.val ≤ j.val → Q i (π*Equiv.swap k j)=Q i π)
    (err : W → Fin m → Prop) (herr : ∀ x,MeasurableSet {w | err w x})
    (β h δ : ℝ) (hβ : 0 ≤ β) (hh : 0 ≤ h) (hδ : 0 < δ) (hδ1 : δ < 1)
    (hcard : (A.card:ℝ) ≤ Real.exp h)
    (hcover : ∀ i π,0 < i.val → ∃ E : Set W,MeasurableSet E ∧ (Q i π).real E ≤ β ∧
      ∀ᵐ w ∂Q i π,w ∉ E → ∃ g ∈ A,
        prefixKeep (lossGood loss) π i.val g ∧ ∀ x,err w x → 1 ≤ loss g x) :
    finiteMean (fun π => ∑ i,(Q i π).real {w | err w (π i)}) ≤
      1+2*(h+1)*harmonicSum (m-1)+(m:ℝ)*β ∧
    finiteEvent (fun π => (Real.exp 1-1)*(1+2*(h+Real.log (2*(m:ℝ)/δ))*harmonicSum (m-1)+m*β)+
      Real.log (2/δ) < ∑ i,(Q i π).real {w | err w (π i)}) ≤ δ := by
  let P := finiteLossProcess A loss Q hQ Qadapt err herr β hcover
  exact ⟨expected_total_general hm P h hh hβ hcard,
    total_high_probability_general hm P h δ hh hβ hδ hδ1 hcard⟩

#print axioms finite_loss_online_bounds
end NeuralGeneralization.BatchTwoOnlineRaw
