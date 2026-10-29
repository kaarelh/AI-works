import CanonicalCompletion
import ControlledL2Features

/-! Rank-one canonical geometry for the actual scalar score. -/
noncomputable section
open MeasureTheory
open scoped RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

section Geometry
variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℝ H]

def scalarScoreResidual (b h : H) : H := h-⟪b,h⟫ • b

lemma scalarScoreResidual_norm_sq (b h : H) (hb : ‖b‖=1) :
    ‖scalarScoreResidual b h‖^2=‖h‖^2-⟪b,h⟫^2 := by
  have hbinner : ⟪b,b⟫=1 := by rw [real_inner_self_eq_norm_sq,hb]; norm_num
  rw [scalarScoreResidual,←real_inner_self_eq_norm_sq]
  simp only [inner_sub_left,inner_sub_right,inner_smul_left,inner_smul_right,
    RCLike.conj_to_real,hbinner,real_inner_comm h b]
  rw [real_inner_self_eq_norm_sq]
  ring

lemma scalarScoreResidual_sub (b h k : H) :
    scalarScoreResidual b (h-k)=scalarScoreResidual b h-scalarScoreResidual b k := by
  simp only [scalarScoreResidual,inner_sub_right,sub_smul]
  abel

lemma scalarScoreCompletion_eq (b h : H) (hb : ‖b‖=1) :
    canonicalCompletion ⟪b,h⟫ (‖h‖^2)=
      WithLp.toLp 2 (⟪b,h⟫,‖scalarScoreResidual b h‖) := by
  have hr := scalarScoreResidual_norm_sq b h hb
  unfold canonicalCompletion
  simp only [Real.norm_eq_abs,sq_abs,←hr,max_eq_right (sq_nonneg _),
    Real.sqrt_sq (norm_nonneg _)]

/-- Projection onto a unit score, completed by the residual norm, is
nonexpansive even though it preserves only rank-one anchored Gram data. -/
theorem scalarScoreCompletion_distance (b h k : H) (hb : ‖b‖=1) :
    ‖canonicalCompletion ⟪b,h⟫ (‖h‖^2)-canonicalCompletion ⟪b,k⟫ (‖k‖^2)‖≤‖h-k‖ := by
  rw [scalarScoreCompletion_eq b h hb,scalarScoreCompletion_eq b k hb]
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  rw [WithLp.prod_norm_sq_eq_of_L2]
  change ‖⟪b,h⟫-⟪b,k⟫‖^2+
    ‖‖scalarScoreResidual b h‖-‖scalarScoreResidual b k‖‖^2≤‖h-k‖^2
  simp only [Real.norm_eq_abs,sq_abs]
  have hr := abs_norm_sub_norm_le (scalarScoreResidual b h) (scalarScoreResidual b k)
  have hrs := pow_le_pow_left₀ (abs_nonneg _) hr 2
  rw [sq_abs,←scalarScoreResidual_sub,scalarScoreResidual_norm_sq b (h-k) hb,
    inner_sub_right] at hrs
  linarith
end Geometry

section L2
variable {Ω : Type*} [MeasurableSpace Ω] (Q : Measure Ω)

def scalarScoreL2 (b : Ω→ℝ) (hb : MemLp b 2 Q) : Lp ℝ 2 Q := hb.toLp b

lemma scalarScoreL2_norm_sq (b : Ω→ℝ) (hb : MemLp b 2 Q) :
    ‖scalarScoreL2 Q b hb‖^2=∫z,(b z)^2 ∂Q := by
  rw [←real_inner_self_eq_norm_sq,L2.inner_def]
  apply integral_congr_ae
  filter_upwards [hb.coeFn_toLp] with z hz
  simp only [scalarScoreL2,hz,Real.inner_apply,pow_two]

lemma scalarScoreL2_unit (b : Ω→ℝ) (hb : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1) : ‖scalarScoreL2 Q b hb‖=1 := by
  have hsq := scalarScoreL2_norm_sq Q b hb
  rw [hunit] at hsq
  nlinarith [norm_nonneg (scalarScoreL2 Q b hb)]

lemma scalarScoreL2_inner [IsFiniteMeasure Q]
    (b f : Ω→ℝ) (hb : MemLp b 2 Q) (hf : Measurable f)
    (hbound : ∀z,|f z|≤1) :
    ⟪scalarScoreL2 Q b hb,boundedL2Feature Q f hf hbound⟫=∫z,b z*f z ∂Q := by
  rw [L2.inner_def]
  apply integral_congr_ae
  filter_upwards [hb.coeFn_toLp,boundedL2Feature_ae Q f hf hbound] with z hbz hfz
  simp only [scalarScoreL2,hbz,hfz,Real.inner_apply]

lemma boundedL2Feature_norm_sq [IsFiniteMeasure Q]
    (f : Ω→ℝ) (hf : Measurable f) (hbound : ∀z,|f z|≤1) :
    ‖boundedL2Feature Q f hf hbound‖^2=∫z,(f z)^2 ∂Q := by
  rw [←real_inner_self_eq_norm_sq,boundedL2Feature_inner]
  simp only [pow_two]

lemma scalarScore_integral_bound [IsProbabilityMeasure Q]
    (b f : Ω→ℝ) (hb : MemLp b 2 Q) (hunit : (∫z,(b z)^2 ∂Q)=1)
    (hf : Measurable f) (hbound : ∀z,|f z|≤1) : |∫z,b z*f z ∂Q|≤1 := by
  have hn : ‖boundedL2Feature Q f hf hbound‖≤1 := by
    have hs : ‖boundedL2Feature Q f hf hbound‖^2≤1 := by
      rw [boundedL2Feature_norm_sq]
      calc
        _ ≤ ∫_z : Ω,(1:ℝ) ∂Q := integral_mono_of_nonneg
          (Filter.Eventually.of_forall fun z => sq_nonneg (f z)) (integrable_const _)
          (Filter.Eventually.of_forall fun z => (sq_le_one_iff_abs_le_one _).mpr (hbound z))
        _ = 1 := by simp
    nlinarith [norm_nonneg (boundedL2Feature Q f hf hbound)]
  rw [←scalarScoreL2_inner Q b f hb hf hbound]
  have hi := norm_inner_le_norm (𝕜 := ℝ) (scalarScoreL2 Q b hb) (boundedL2Feature Q f hf hbound)
  rw [scalarScoreL2_unit Q b hb hunit,one_mul,Real.norm_eq_abs] at hi
  exact hi.trans hn

theorem scalarScore_moment_distance [IsFiniteMeasure Q]
    (b f g : Ω→ℝ) (hb : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1)
    (hf : Measurable f) (hg : Measurable g)
    (hfb : ∀z,|f z|≤1) (hgb : ∀z,|g z|≤1) :
    ‖canonicalCompletion (∫z,b z*f z ∂Q) (∫z,(f z)^2 ∂Q)-
      canonicalCompletion (∫z,b z*g z ∂Q) (∫z,(g z)^2 ∂Q)‖≤
      ‖boundedL2Feature Q f hf hfb-boundedL2Feature Q g hg hgb‖ := by
  have hh := scalarScoreCompletion_distance (scalarScoreL2 Q b hb)
    (boundedL2Feature Q f hf hfb) (boundedL2Feature Q g hg hgb)
    (scalarScoreL2_unit Q b hb hunit)
  simpa only [scalarScoreL2_inner,boundedL2Feature_norm_sq] using hh

end L2
#print axioms scalarScore_moment_distance
end ConditionalNonpolynomial.Analytic
