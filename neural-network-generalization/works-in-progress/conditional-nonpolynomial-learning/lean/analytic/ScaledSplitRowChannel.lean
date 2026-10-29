import SplitRowChannelError

/-! Physical scalar controls for 0<t≤1. Tracking uses entropy relative to the
critical scalar Gaussian, while the actual prior cost can use a different
Gaussian reference with variance t². -/
noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields ConditionalAnalytic

def residualScale (t : ℝ) : WithLp 2 (ℝ×ℝ)→ₗ[ℝ] WithLp 2 (ℝ×ℝ) where
  toFun p := WithLp.toLp 2 (p.fst,t*p.snd)
  map_add' p q := by apply WithLp.ofLp_injective 2; ext <;> simp <;> ring
  map_smul' c p := by apply WithLp.ofLp_injective 2; ext <;> simp <;> ring

theorem residualScale_norm_le {t : ℝ} (ht : 0≤t) (ht1 : t≤1) (p : WithLp 2 (ℝ×ℝ)) :
    ‖residualScale t p‖≤‖p‖ := by
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [WithLp.prod_norm_sq_eq_of_L2,WithLp.prod_norm_sq_eq_of_L2]
  change ‖p.fst‖^2+‖t*p.snd‖^2≤‖p.fst‖^2+‖p.snd‖^2
  simp only [Real.norm_eq_abs,sq_abs,mul_pow]
  have hsq : t^2≤1 := by nlinarith
  nlinarith [mul_le_mul_of_nonneg_right hsq (sq_nonneg p.snd)]

theorem residualScale_distance {t : ℝ} (ht : 0≤t) (ht1 : t≤1) (p q : WithLp 2 (ℝ×ℝ)) :
    ‖residualScale t p-residualScale t q‖≤‖p-q‖ := by
  rw [←map_sub]
  exact residualScale_norm_le ht ht1 _

def scaledSplitRowFeature {Ω : Type*} {N : ℕ} (t : ℝ) (Z : Ω→ℝ) (u h : Fin N→ℝ)
    (p : Ω×(Fin N→ℝ)) : ℝ :=
  Real.tanh (∑i,t*directionSplit u (Z p.1/t) p.2 i*h i)

variable {Ω : Type*} [MeasurableSpace Ω]

theorem scaledSplitRowFeature_moment (Q : Measure Ω) [IsProbabilityMeasure Q]
    {N : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t)
    (Z b : Ω→ℝ) (hZ : Measurable Z) (hb : Measurable b)
    (u h : Fin N→ℝ) (hu : ∑i,u i^2=1) :
    canonicalCompletion
      (∫p,b p.1*scaledSplitRowFeature t Z u h p ∂Q.prod (standardLaw (Fin N)))
      (∫p,(scaledSplitRowFeature t Z u h p)^2 ∂Q.prod (standardLaw (Fin N)))=
      scalarSourceMoment Q Z b
        (residualScale t (canonicalCompletion (directionCoefficient u h) (∑i,h i^2))) := by
  let T : Ω×(Fin N→ℝ)→Ω×ℝ := fun p=>(p.1,directionNoise hN u h p.2)
  have hT : Measurable T := by unfold T directionNoise; fun_prop
  have hmap : (Q.prod (standardLaw (Fin N))).map T=Q.prod (gaussianReal 0 1) :=
    directionNoise_product_map Q hN u h
  have hres : 0≤(∑i,h i^2)-(directionCoefficient u h)^2 := by
    rw [←directionResidual_squared u h hu]
    exact Finset.sum_nonneg fun i _=>sq_nonneg _
  let a := residualScale t (canonicalCompletion (directionCoefficient u h) (∑i,h i^2))
  have hpoint (p : Ω×(Fin N→ℝ)) : scaledSplitRowFeature t Z u h p=
      scalarChannelFeature (scalarSourceCoordinates Z) (channelPairCoefficients a) (T p) := by
    unfold scaledSplitRowFeature scalarChannelFeature
    change Real.tanh (∑i,t*directionSplit u (Z p.1/t) p.2 i*h i)=_
    have he : (∑i,t*directionSplit u (Z p.1/t) p.2 i*h i)=
        t*(∑i,directionSplit u (Z p.1/t) p.2 i*h i) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he,directionSplit_scalar_identity hN u h hu]
    change _=Real.tanh (gaussianLinearForm
      (channelPairCoefficients (WithLp.toLp 2
        (directionCoefficient u h,t*Real.sqrt (max 0 ((∑i,h i^2)-‖directionCoefficient u h‖^2)))) )
      (channelPairCoordinates (Z p.1,directionNoise hN u h p.2)))
    rw [channelPair_linear]
    simp only [Real.norm_eq_abs,sq_abs,max_eq_right hres]
    congr 1
    field_simp
  have hmean : (∫p,b p.1*scaledSplitRowFeature t Z u h p ∂Q.prod (standardLaw (Fin N)))=
      ∫p,b p.1*scalarChannelFeature (scalarSourceCoordinates Z) (channelPairCoefficients a) p
        ∂Q.prod (gaussianReal 0 1) := by
    rw [←hmap,integral_map hT.aemeasurable]
    · apply integral_congr_ae
      exact Filter.Eventually.of_forall fun p=>by dsimp only; rw [hpoint]
    · exact ((hb.comp measurable_fst).mul
        (scalarChannelFeature_measurable _ (scalarSourceCoordinates_measurable Z hZ) _)).aestronglyMeasurable
  have hsecond : (∫p,(scaledSplitRowFeature t Z u h p)^2 ∂Q.prod (standardLaw (Fin N)))=
      ∫p,(scalarChannelFeature (scalarSourceCoordinates Z) (channelPairCoefficients a) p)^2
        ∂Q.prod (gaussianReal 0 1) := by
    rw [←hmap,integral_map hT.aemeasurable]
    · apply integral_congr_ae
      exact Filter.Eventually.of_forall fun p=>by dsimp only; rw [hpoint]
    · exact ((scalarChannelFeature_measurable _ (scalarSourceCoordinates_measurable Z hZ) _).pow_const 2).aestronglyMeasurable
  rw [hmean,hsecond]
  rfl

theorem scaledSplitRowEmpirical_step [StandardBorelSpace Ω] [Nonempty Ω]
    {X : Type*} [Fintype X]
    (Q R : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure R]
    {N : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Z b : Ω→ℝ) (hZ : Measurable Z) (hb : Measurable b)
    (hR : R.map Z=gaussianReal 0 1) (hbLp : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1) (hKL : klDiv Q R≠∞)
    (u : Fin N→ℝ) (hu : ∑i,u i^2=1) (h : X→Fin N→ℝ)
    (a : X→WithLp 2 (ℝ×ℝ)) {e α : ℝ} (hα : 0<α) (hαquarter : α≤1/4)
    (hclose : ∀x,‖canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)-a x‖≤e)
    (w : Fin N→Ω×(Fin N→ℝ))
    (hevent : w∈finiteMomentEvent (Q.prod (standardLaw (Fin N)))
      (channelObservables (fun p=>b p.1) (fun x=>scaledSplitRowFeature t Z u (h x))) α N)
    (x : X) :
    ‖scalarChannelEmpirical (fun p=>b p.1) (scaledSplitRowFeature t Z u (h x)) w-
      scalarSourceMoment Q Z b (residualScale t (a x))‖≤
      8*Real.sqrt α+Real.exp (Real.sqrt (2*(klDiv Q R).toReal))*e := by
  obtain ⟨hb',hunit'⟩ := score_product_unit Q (standardLaw (Fin N)) b hbLp hunit
  have hf (x : X) : Measurable (scaledSplitRowFeature t Z u (h x)) := by
    unfold scaledSplitRowFeature directionSplit
    fun_prop
  have hs := (scalarChannelEmpirical_error (Q.prod (standardLaw (Fin N)))
    (fun p=>b p.1) (fun x=>scaledSplitRowFeature t Z u (h x)) hb' hunit' hf
    (fun _ _=>(Real.abs_tanh_lt_one _).le) w hα hαquarter hevent x).2
  rw [scaledSplitRowFeature_moment Q hN ht Z b hZ hb u (h x) hu] at hs
  have hp := scalarSourceMoment_lipschitz Q R Z b hZ hR hbLp hunit hKL
    (residualScale t (canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)))
    (residualScale t (a x))
  have hc := (residualScale_distance ht.le ht1
    (canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2)) (a x)).trans (hclose x)
  have hp' := hp.trans (mul_le_mul_of_nonneg_left hc (Real.exp_pos _).le)
  have ht' := dist_triangle
    (scalarChannelEmpirical (fun p=>b p.1) (scaledSplitRowFeature t Z u (h x)) w)
    (scalarSourceMoment Q Z b (residualScale t (canonicalCompletion (directionCoefficient u (h x)) (∑i,h x i^2))))
    (scalarSourceMoment Q Z b (residualScale t (a x)))
  simp only [dist_eq_norm] at ht'
  exact ht'.trans (add_le_add hs hp')

#print axioms scaledSplitRowEmpirical_step
end ConditionalNonpolynomial.Analytic
