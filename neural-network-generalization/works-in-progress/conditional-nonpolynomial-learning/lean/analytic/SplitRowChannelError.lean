import ScalarChannelCoordinates
import ScalarChannelEmpirical

/-! One-step tracking for literal Gaussian direction-split network rows. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields ConditionalAnalytic

variable {Ω Ξ X : Type*} [MeasurableSpace Ω] [MeasurableSpace Ξ]

lemma score_product_unit (Q : Measure Ω) (ν : Measure Ξ)
    [IsProbabilityMeasure Q] [IsProbabilityMeasure ν]
    (b : Ω→ℝ) (hb : MemLp b 2 Q) (hunit : (∫z,(b z)^2 ∂Q)=1) :
    MemLp (fun p : Ω×Ξ=>b p.1) 2 (Q.prod ν) ∧
      (∫p : Ω×Ξ,(b p.1)^2 ∂Q.prod ν)=1 := by
  constructor
  · exact hb.comp_measurePreserving (measurePreserving_fst (μ := Q) (ν := ν))
  · calc
      _ = ∫z,(b z)^2 ∂Q := by simpa only [probReal_univ,one_smul] using
        (integral_fun_fst (μ := Q) (ν := ν) (fun z=>(b z)^2))
      _ = 1 := hunit

def scalarSourceMoment (Q : Measure Ω) (Z b : Ω→ℝ)
    (a : WithLp 2 (ℝ×ℝ)) : WithLp 2 (ℝ×ℝ) :=
  scalarChannelMoment (Q.prod (gaussianReal 0 1)) (scalarSourceCoordinates Z)
    (fun p=>b p.1) (channelPairCoefficients a)

theorem scalarSourceMoment_lipschitz [StandardBorelSpace Ω] [Nonempty Ω]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (Z b : Ω→ℝ) (hZ : Measurable Z) (hP : P.map Z=gaussianReal 0 1)
    (hb : MemLp b 2 Q) (hunit : (∫z,(b z)^2 ∂Q)=1)
    (hKL : klDiv Q P≠∞) (a a' : WithLp 2 (ℝ×ℝ)) :
    ‖scalarSourceMoment Q Z b a-scalarSourceMoment Q Z b a'‖≤
      Real.exp (Real.sqrt (2*(klDiv Q P).toReal))*‖a-a'‖ := by
  have hdata := scalarSourceCoordinates_entropy Q P Z hZ hP
  have hfinite : klDiv ((Q.prod (gaussianReal 0 1)).map (scalarSourceCoordinates Z))
      (standardLaw (Fin 2))≠∞ := ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  obtain ⟨hb',hunit'⟩ := score_product_unit Q (gaussianReal 0 1) b hb hunit
  have hh := scalarChannelMoment_lipschitz_exp (Q.prod (gaussianReal 0 1))
    (scalarSourceCoordinates Z) (scalarSourceCoordinates_measurable Z hZ)
    (fun p=>b p.1) hb' hunit' hfinite (channelPairCoefficients a) (channelPairCoefficients a')
  rw [←channelPairCoefficients.map_sub,channelPairCoefficients.norm_map] at hh
  apply hh.trans
  apply mul_le_mul_of_nonneg_right _ (norm_nonneg _)
  apply Real.exp_le_exp.mpr
  apply Real.sqrt_le_sqrt
  exact mul_le_mul_of_nonneg_left (ENNReal.toReal_mono hKL hdata) (by norm_num)

theorem splitRowFeature_canonical_moment (Q : Measure Ω) [IsProbabilityMeasure Q]
    {N : ℕ} (hN : 0<N) (Z b : Ω→ℝ) (hZ : Measurable Z) (hb : Measurable b)
    (u h : Fin N→ℝ) (hu : ∑i,u i^2=1) :
    canonicalCompletion
      (∫p,b p.1*splitRowFeature Z u h p ∂Q.prod (standardLaw (Fin N)))
      (∫p,(splitRowFeature Z u h p)^2 ∂Q.prod (standardLaw (Fin N)))=
    scalarSourceMoment Q Z b (canonicalCompletion (directionCoefficient u h) (∑i,h i^2)) := by
  obtain ⟨hm,hq⟩ := splitRowFeature_moments Q hN Z b hZ hb u h hu
  rw [hm,hq]
  rfl

/-- The one-step finite-width channel estimate, with no assumed Gaussian
coordinate certificate. The reference scalar marginal and actual scalar KL
are the only distributional inputs. -/
theorem splitRowEmpirical_step [StandardBorelSpace Ω] [Nonempty Ω] [Fintype X]
    (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    {N : ℕ} (hN : 0<N) (Z b : Ω→ℝ) (hZ : Measurable Z) (hb : Measurable b)
    (hP : P.map Z=gaussianReal 0 1) (hbLp : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1) (hKL : klDiv Q P≠∞)
    (u : Fin N→ℝ) (hu : ∑i,u i^2=1) (h : X→Fin N→ℝ)
    (a : X→WithLp 2 (ℝ×ℝ)) {e α : ℝ} (hα : 0<α) (hαquarter : α≤1/4)
    (hclose : ∀x,‖canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)-a x‖≤e)
    (w : Fin N→Ω×(Fin N→ℝ))
    (hevent : w∈finiteMomentEvent (Q.prod (standardLaw (Fin N)))
      (channelObservables (fun p=>b p.1) (fun x=>splitRowFeature Z u (h x))) α N)
    (x : X) :
    ‖scalarChannelEmpirical (fun p=>b p.1) (splitRowFeature Z u (h x)) w-
      scalarSourceMoment Q Z b (a x)‖≤
      8*Real.sqrt α+Real.exp (Real.sqrt (2*(klDiv Q P).toReal))*e := by
  obtain ⟨hb',hunit'⟩ := score_product_unit Q (standardLaw (Fin N)) b hbLp hunit
  have hf (x : X) : Measurable (splitRowFeature Z u (h x)) := by
    unfold splitRowFeature directionSplit
    fun_prop
  have hs := (scalarChannelEmpirical_error (Q.prod (standardLaw (Fin N)))
    (fun p=>b p.1) (fun x=>splitRowFeature Z u (h x)) hb' hunit' hf
    (fun _ _=>(Real.abs_tanh_lt_one _).le) w hα hαquarter hevent x).2
  rw [splitRowFeature_canonical_moment Q hN Z b hZ hb u (h x) hu] at hs
  have hp := scalarSourceMoment_lipschitz Q P Z b hZ hP hbLp hunit hKL
    (canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)) (a x)
  have hp' := hp.trans (mul_le_mul_of_nonneg_left (hclose x) (Real.exp_pos _).le)
  have ht := dist_triangle
    (scalarChannelEmpirical (fun p=>b p.1) (splitRowFeature Z u (h x)) w)
    (scalarSourceMoment Q Z b (canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)))
    (scalarSourceMoment Q Z b (a x))
  simp only [dist_eq_norm] at ht
  exact ht.trans (add_le_add hs hp')

#print axioms splitRowEmpirical_step
end ConditionalNonpolynomial.Analytic
