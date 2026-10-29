import TaggedScalarSequence
import TaggedScalarEntropy
import UniformPrescribedSteering

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

/-- Package a genuine finite scalar control sequence with a chosen tracked
component into the actual tagged channel program. All score and entropy
obligations are discharged internally. -/
theorem exists_tagged_prescribed_sequence {t β : ℝ} (ht : 0<t) (hβ : 0<β)
    (H : ℕ) (s : ℕ→ℝ×ℝ) (Q : ℕ→Measure ℝ)
    (hpos : ∀j≤H,0<(s j).1 ∧ 0≤(s j).2)
    (hfloor : ∀j≤H,β≤(s j).1)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hKL : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (hsignal : ∀j<H,(s (j+1)).1≤controlledSignal (Q j) (s j).1 (t^2*(s j).2))
    (hresidual : ∀j<H,(s (j+1)).2=
      controlledSignal (Q j) (s j).1 (t^2*(s j).2)+
      controlledResidual (Q j) (s j).1 (t^2*(s j).2)-(s (j+1)).1) :
    ∃P : TaggedScalarPath t (s 0).1 (s 0).2,
      P.length=H ∧ (∀j≤H,P.state j=s j) ∧
      (∀j<H,P.control j=(Q j).prod scoreSignLaw) ∧ P.bound≤1/Real.sqrt β+1 := by
  let b := fun j=>prescribedConditionalScore (Q j) (s j).1 (t^2*(s j).2) (s (j+1)).1
  have hb (j : ℕ) (_hj : j<H) : Measurable (b j) := prescribedConditionalScore_measurable _ _ _ _
  have hbound (j : ℕ) (hj : j<H) (z : ℝ×Bool) : |b j z|≤1/Real.sqrt β+1 := by
    have hh := prescribedConditionalScore_bound (Q j) (hpos (j+1) (by omega)).1 (hsignal j hj) z
    have hinv := one_div_le_one_div_of_le (Real.sqrt_pos.mpr hβ)
      (Real.sqrt_le_sqrt (hfloor (j+1) (by omega)))
    dsimp only [b]
    linarith
  have hbLp (j : ℕ) (hj : j<H) : MemLp (b j) 2 ((Q j).prod scoreSignLaw) := by
    letI := hprob j hj
    exact MemLp.of_bound (hb j hj).aestronglyMeasurable (1/Real.sqrt β+1)
      (ae_of_all _ fun z=>by simpa only [Real.norm_eq_abs] using hbound j hj z)
  have hunit (j : ℕ) (hj : j<H) : (∫z,(b j z)^2 ∂(Q j).prod scoreSignLaw)=1 := by
    letI := hprob j hj
    exact prescribedConditionalScore_unit _ (hpos (j+1) (by omega)).1 (hsignal j hj)
  have hstep (j : ℕ) (hj : j<H) (f : Bool) :
      scalarSourceMoment ((Q j).prod scoreSignLaw) Prod.fst (b j)
        (residualScale t (scalarBooleanState f (s j).1 (s j).2))=
        scalarBooleanState f (s (j+1)).1 (s (j+1)).2 := by
    letI := hprob j hj
    rw [hresidual j hj]
    exact uniform_prescribed_score_channel (Q j) ht.le (hpos j (by omega)).2
      (hpos (j+1) (by omega)).1 (hsignal j hj) f
  obtain ⟨P,hLen,hstate,hcontrol,hscore,hB⟩ := TaggedScalarPath.exists_of_sequence t H s
    (fun j=>(Q j).prod scoreSignLaw) b (1/Real.sqrt β+1) (by linarith [div_nonneg (show (0:ℝ)≤1 by norm_num) (Real.sqrt_nonneg β)]) hpos
    (fun j hj=>by letI := hprob j hj; infer_instance)
    (fun j hj=>by letI := hprob j hj; exact tagged_control_criticalKL _ (hKL j hj))
    (fun j hj=>by letI := hprob j hj; exact tagged_control_priorKL _ ht (hKL j hj))
    hb hbLp hunit hbound hstep
  exact ⟨P,hLen,hstate,hcontrol,hB⟩

#print axioms exists_tagged_prescribed_sequence
end ConditionalNonpolynomial.Analytic
