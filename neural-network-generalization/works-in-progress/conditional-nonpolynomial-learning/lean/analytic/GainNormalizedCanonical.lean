import ReindexedCanonicalProgram
import SharpGaussianFeatureGain

/-! Scale-free bounds for the actual normalized canonical Gaussian map.
Both the importance-sampling normalizer and the output range are bounded
independently of the raw relative entropy and the physical scale. -/
noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic

lemma gaussianEntropyGain_two_cost {D : ℝ} (hD : 0≤D) :
    1+2*D≤gaussianEntropyGain D := by
  have hc := gaussianEntropyGain_cost hD
  have hl := Real.log_nonneg (gaussianEntropyGain_one_le D)
  unfold gaussianVarianceCost at hc
  linarith

lemma normalized_gain_entropy_ratio {D : ℝ} (hD : 0≤D) :
    (1+Real.sqrt (2*D))/Real.sqrt (gaussianEntropyGain D)≤2 := by
  have hg := gaussianEntropyGain_one_le D
  have hc := gaussianEntropyGain_two_cost hD
  have hs : 1≤Real.sqrt (gaussianEntropyGain D) := by
    exact (Real.le_sqrt (by norm_num) (by linarith)).mpr (by nlinarith)
  have hd : Real.sqrt (2*D)≤Real.sqrt (gaussianEntropyGain D) :=
    Real.sqrt_le_sqrt (by linarith)
  exact (div_le_iff₀ (by positivity)).mpr (by linarith)

lemma normalized_gain_trace_ratio {D : ℝ} (hD : 0≤D) (d : ℕ) :
    (2*(d:ℝ)+4*D)/(Real.sqrt (gaussianEntropyGain D))^2≤2*(d:ℝ)+2 := by
  have hg := gaussianEntropyGain_one_le D
  have hc := gaussianEntropyGain_two_cost hD
  rw [Real.sq_sqrt (by linarith)]
  apply (div_le_iff₀ (by linarith)).mpr
  have hm := mul_nonneg (show (0:ℝ)≤2*d by positivity)
    (show 0≤gaussianEntropyGain D-1 by linarith)
  nlinarith

variable {I : Type*} [Fintype I] {d : ℕ}
variable (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]

theorem normalizedTanhL2_sharp_norm
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (S : ℝ) (hS : S≠0) (v : EuclideanSpace ℝ I) :
    ‖normalizedTanhL2 Q S
      (Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))) v‖≤‖v‖ := by
  let D := (klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal
  let α := Real.sqrt (gaussianEntropyGain D)
  have hα : 0<α := Real.sqrt_pos.mpr (lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le D))
  have hzero : actualTanhL2 Q (0 : EuclideanSpace ℝ I)=0 := by
    apply Lp.ext
    filter_upwards [actualTanhL2_ae Q (0 : EuclideanSpace ℝ I)] with z hz
    simpa [gaussianLinearForm] using hz
  have hh := actualTanhL2_sharp_gain Q hKL (S • v) 0
  rw [hzero,sub_zero,sub_zero,norm_smul,Real.norm_eq_abs] at hh
  change ‖actualTanhL2 Q (S • v)‖≤α*(|S| *‖v‖) at hh
  change ‖(S*α)⁻¹ • actualTanhL2 Q (S • v)‖≤‖v‖
  rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_mul,abs_of_pos hα]
  apply (mul_le_mul_of_nonneg_left hh (by positivity : 0≤(|S| *α)⁻¹)).trans_eq
  have hs : |S|≠0 := abs_ne_zero.mpr hS
  field_simp

variable (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

theorem gainNormalizedNormalizer_bound (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    canonicalNormalizer Q (canonicalBasisValues Q V)
      (fun z=>gaussianRowNorm z/Real.sqrt (gaussianEntropyGain
        ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal)))≤
      3+(Module.finrank ℝ V:ℝ)+2*(d:ℝ) := by
  have hh := reindexedCanonicalNormalizer_bound Q V e
    (Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))) hKL
  have hr := normalized_gain_trace_ratio
    (D:=(klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal) ENNReal.toReal_nonneg d
  linarith

/-- An actual five-stage arithmetic program for the normalized map, on any
finite coordinate type. Its coefficients, quadrature budget and error bound
have no dependence on the physical scale S or on unnormalized entropy. -/
theorem actual_gain_normalized_canonical_program (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (S : ℝ) (hS : S≠0) (U : ℝ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal)))
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal)))
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    ∃w:Fin n→Fin d→ℝ,∃a:Fin n→ℝ,
      ∃A:Fin (Module.finrank ℝ V)→Fin n→ℝ,∃b:Fin n→ℝ,
        (∀j i,|w j i|≤1) ∧
        (∀j i,|A j i|≤(3+(Module.finrank ℝ V:ℝ)+2*(d:ℝ))/2) ∧
        (∀i,0≤b i∧b i≤3+(Module.finrank ℝ V:ℝ)+2*(d:ℝ)) ∧
        ∀v:ParameterCube (Fin d) U,
          ‖completionToVector (canonicalProgramVector w a A b v.val)-
            canonicalVector V (normalizedTanhL2 Q S
              (Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal)))
              (reindexedVector e (WithLp.toLp 2 v.val)))‖≤
                δ+Real.sqrt ((1+2*(((d:ℝ)+1)*U+δ))*δ) := by
  let α := Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))
  have hα : 0<α := Real.sqrt_pos.mpr (lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le _))
  obtain ⟨s,hs⟩ := reindexed_canonical_quadrature Q V e hKL S α hS hα.ne'
    U hU T hT δ hδ n hn hmesh hbudget
  let basis := canonicalBasisValues Q V
  let weight := fun (z : I→ℝ)=>gaussianRowNorm z/α
  let ridge := fun (z : I→ℝ)=>S*gaussianRowNorm z
  let directions := fun (z : I→ℝ) i=>gaussianRowDirection z (e i)
  have hZ := gainNormalizedNormalizer_bound Q V e hKL
  refine ⟨(fun i=>directions (s i)),(fun i=>ridge (s i)),
    quadratureProjectionCoefficient Q basis weight s,
    quadratureNormCoefficient Q basis weight s,
    (fun j i=>gaussianRowDirection_bound _ _),?_,?_,?_⟩
  · intro j i
    exact (quadratureProjectionCoefficient_bound Q basis weight s hn j i).trans
      (by dsimp only [basis,weight,α]; linarith)
  · intro i
    obtain ⟨hi,hb⟩ := quadratureNormCoefficient_bound Q basis weight s hn i
    exact ⟨hi,hb.trans hZ⟩
  · intro v
    rw [canonicalVector_eq_completion,←completionToVector.map_sub,completionToVector.norm_map]
    let feature := normalizedTanhL2 Q S α (reindexedVector e (WithLp.toLp 2 v.val))
    let M : WithLp 2 (EuclideanSpace ℝ (Fin (Module.finrank ℝ V)) × ℝ) :=
      WithLp.toLp 2 (projectionCoefficients V feature,‖feature‖^2)
    have hproj : ‖M.fst‖≤((d:ℝ)+1)*U := by
      change ‖projectionCoefficients V feature‖≤_
      have he : ‖projectionCoefficients V feature‖=‖V.starProjection feature‖ :=
        (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (projectionCoefficients_norm_sq V _)
      rw [he]
      apply (V.norm_starProjection_apply_le feature).trans
      apply (normalizedTanhL2_sharp_norm Q hKL S hS _).trans
      rw [(reindexedVector e).norm_map]
      exact cube_euclidean_norm_bound hU.le v
    have happrox : ‖quadratureJointValue Q basis weight ridge directions s v.val-M‖≤δ := (hs v).le
    exact quadratureProgram_error Q basis weight ridge directions s v.val M
      (R:=((d:ℝ)+1)*U) (δ:=δ) (by positivity) hδ.le hproj happrox

#print axioms normalizedTanhL2_sharp_norm
#print axioms gainNormalizedNormalizer_bound
#print axioms actual_gain_normalized_canonical_program
end ConditionalNonpolynomial.Analytic
