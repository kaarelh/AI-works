import ReindexedCanonicalQuadrature

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] {d : ℕ}
variable (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]

lemma actualTanhL2_norm_le_one (u : EuclideanSpace ℝ I) : ‖actualTanhL2 Q u‖≤1 := by
  have he : ‖actualTanhL2 Q u‖^2=∫z,(Real.tanh (gaussianLinearForm u z))^2 ∂Q := by
    rw [← real_inner_self_eq_norm_sq,L2.inner_def]
    apply integral_congr_ae
    filter_upwards [actualTanhL2_ae Q u] with z hz
    simp only [hz,Real.inner_apply,pow_two]
  have hi : (∫z,(Real.tanh (gaussianLinearForm u z))^2 ∂Q)≤1 := by
    have hh := integral_mono_of_nonneg (μ:=Q) (Filter.Eventually.of_forall (fun z=>sq_nonneg (Real.tanh (gaussianLinearForm u z))))
      (integrable_const (1:ℝ)) (Filter.Eventually.of_forall (fun z=>
        (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le))
    simpa using hh
  nlinarith [norm_nonneg (actualTanhL2 Q u)]

variable (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

/-- A finite arithmetic quadrature for the actual canonical map on any
finite coordinate type. Only finite input coordinates are reindexed, not the
probability law, L² space, or orthonormal basis. -/
theorem actual_reindexed_canonical_program (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (U : ℝ) (hU : 0<U) (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) gaussianRowNorm
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) gaussianRowNorm
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    let Z := canonicalNormalizer Q (canonicalBasisValues Q V) gaussianRowNorm
    ∃w:Fin n→Fin d→ℝ,∃a:Fin n→ℝ,
      ∃A:Fin (Module.finrank ℝ V)→Fin n→ℝ,∃b:Fin n→ℝ,
        (∀j i,|w j i|≤1) ∧ (∀j i,|A j i|≤Z/2) ∧ (∀i,0≤b i∧b i≤Z) ∧
        ∀v:ParameterCube (Fin d) U,
          ‖completionToVector (canonicalProgramVector w a A b v.val)-
            canonicalVector V (actualTanhL2 Q (reindexedVector e (WithLp.toLp 2 v.val)))‖ ≤
              δ+Real.sqrt ((3+2*δ)*δ) := by
  dsimp only
  have hm : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/1)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ := by simpa only [div_one] using hmesh
  have hb : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/1)
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2 := by simpa only [div_one] using hbudget
  obtain ⟨s,hs⟩ := reindexed_canonical_quadrature Q V e hKL 1 1 (by norm_num) (by norm_num)
    U hU T hT δ hδ n hn hm hb
  simp only [div_one,one_mul,normalizedTanhL2,one_smul,inv_one] at hs
  let basis := canonicalBasisValues Q V
  let w := fun z i=>gaussianRowDirection z (e i)
  refine ⟨(fun i=>w (s i)),(fun i=>gaussianRowNorm (s i)),
    quadratureProjectionCoefficient Q basis gaussianRowNorm s,
    quadratureNormCoefficient Q basis gaussianRowNorm s,
    (fun j i=>gaussianRowDirection_bound _ _),
    quadratureProjectionCoefficient_bound Q basis gaussianRowNorm s hn,
    quadratureNormCoefficient_bound Q basis gaussianRowNorm s hn,?_⟩
  intro v
  rw [canonicalVector_eq_completion,← completionToVector.map_sub,completionToVector.norm_map]
  let f := actualTanhL2 Q (reindexedVector e (WithLp.toLp 2 v.val))
  let M : WithLp 2 (EuclideanSpace ℝ (Fin (Module.finrank ℝ V)) × ℝ) :=
    WithLp.toLp 2 (projectionCoefficients V f,‖f‖^2)
  have hproj : ‖M.fst‖≤1 := by
    change ‖projectionCoefficients V f‖≤1
    have he : ‖projectionCoefficients V f‖=‖V.starProjection f‖ :=
      (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (projectionCoefficients_norm_sq V _)
    rw [he]
    exact (V.norm_starProjection_apply_le f).trans (actualTanhL2_norm_le_one Q _)
  have happrox : ‖quadratureJointValue Q basis gaussianRowNorm gaussianRowNorm w s v.val-M‖≤δ :=
    (hs v).le
  have hfinal := quadratureProgram_error Q basis gaussianRowNorm gaussianRowNorm w s v.val M
    (R:=1) (δ:=δ) (by norm_num) hδ.le hproj happrox
  dsimp only [M,f,WithLp.fst,WithLp.snd,WithLp.ofLp_toLp] at hfinal
  simpa only [show (1:ℝ)+2*(1+δ)=3+2*δ by ring] using hfinal

#print axioms actual_reindexed_canonical_program
end ConditionalNonpolynomial.Analytic
