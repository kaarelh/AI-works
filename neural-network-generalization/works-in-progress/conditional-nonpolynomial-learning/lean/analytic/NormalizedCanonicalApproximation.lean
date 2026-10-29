import NormalizedCanonicalQuadrature
import DimensionFreeGaussianTransfer

noncomputable section
set_option maxHeartbeats 400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic

variable {d : ℕ} (Q : Measure (Fin d→ℝ)) [IsProbabilityMeasure Q]

lemma actualTanhL2_zero : actualTanhL2 Q (0 : EuclideanSpace ℝ (Fin d))=0 := by
  apply Lp.ext
  filter_upwards [actualTanhL2_ae Q (0 : EuclideanSpace ℝ (Fin d))] with z hz
  simpa [gaussianLinearForm] using hz

lemma normalizedTanhL2_norm_bound
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) (v : EuclideanSpace ℝ (Fin d)) :
    ‖normalizedTanhL2 Q S α v‖≤
      ((1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal))/|α|)*‖v‖ := by
  have hh := actualTanhL2_dimension_free Q hKL (S • v) 0
  rw [actualTanhL2_zero,sub_zero,sub_zero,norm_smul,Real.norm_eq_abs] at hh
  unfold normalizedTanhL2
  rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_mul]
  have he := mul_le_mul_of_nonneg_left hh (inv_nonneg.mpr (mul_nonneg (abs_nonneg S) (abs_nonneg α)))
  apply he.trans_eq
  have hs : |S|≠0 := abs_ne_zero.mpr hS
  have ha : |α|≠0 := abs_ne_zero.mpr hα
  field_simp
  <;> ring

lemma cube_euclidean_norm_bound {U : ℝ} (hU : 0≤U) (v : ParameterCube (Fin d) U) :
    ‖WithLp.toLp 2 v.val‖≤((d:ℝ)+1)*U := by
  have hs : ‖WithLp.toLp 2 v.val‖^2≤(d:ℝ)*U^2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    calc
      _ ≤ ∑_i:Fin d,U^2 := Finset.sum_le_sum fun i _=>by
        simpa only [WithLp.ofLp_toLp,sq_abs] using
          (pow_le_pow_left₀ (abs_nonneg (v.val i)) (v.property i) 2)
      _ = _ := by simp
  have hd : (d:ℝ)≤((d:ℝ)+1)^2 := by nlinarith [Nat.cast_nonneg d (α:=ℝ)]
  have hm := mul_le_mul_of_nonneg_right hd (sq_nonneg U)
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  nlinarith

variable (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

lemma normalizedCanonicalProjection_bound
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) {U : ℝ} (hU : 0≤U)
    (v : ParameterCube (Fin d) U) :
    ‖projectionCoefficients V (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val))‖ ≤
      ((1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal))/|α|)*
        (((d:ℝ)+1)*U) := by
  have hproj : ‖projectionCoefficients V (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val))‖ =
      ‖V.starProjection (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val))‖ :=
    (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp (projectionCoefficients_norm_sq V _)
  rw [hproj]
  apply (V.norm_starProjection_apply_le _).trans
  apply (normalizedTanhL2_norm_bound Q hKL S α hS hα _).trans
  exact mul_le_mul_of_nonneg_left (cube_euclidean_norm_bound hU v) (by positivity)

/-- The actual normalized canonical Gaussian map is uniformly approximated
by a bounded five-layer real program. The subsequent finite-grid compiler
uses only the displayed polynomial resources, independently of the scale S. -/
theorem actual_normalized_canonical_program
    (hKL : klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0) (hα : α≠0) (U : ℝ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      1024*(Z*(((d+1:ℝ)*U)+((d+1:ℝ)*U)^2))^2*
        (1+(d:ℝ)*Real.log (2*(T:ℝ)+1))≤(n:ℝ)*δ^2) :
    let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
    let R := ((1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal))/|α|)*
      (((d:ℝ)+1)*U)
    ∃w:Fin n→Fin d→ℝ,∃a:Fin n→ℝ,
      ∃A:Fin (Module.finrank ℝ V)→Fin n→ℝ,∃b:Fin n→ℝ,
        (∀j i,|w j i|≤1) ∧ (∀j i,|A j i|≤Z/2) ∧ (∀i,0≤b i∧b i≤Z) ∧
        ∀v:ParameterCube (Fin d) U,
          ‖completionToVector (canonicalProgramVector w a A b v.val)-
            canonicalVector V (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val))‖ ≤
              δ+Real.sqrt ((1+2*(R+δ))*δ) := by
  dsimp only
  obtain ⟨s,hs⟩ := actual_normalized_canonical_quadrature Q V hKL S α hS hα U hU
    T hT δ hδ n hn hmesh hbudget
  let e := canonicalBasisValues Q V
  let k := fun z:Fin d→ℝ=>gaussianRowNorm z/α
  let a := fun z:Fin d→ℝ=>S*gaussianRowNorm z
  refine ⟨(fun i=>gaussianRowDirection (s i)),(fun i=>a (s i)),
    quadratureProjectionCoefficient Q e k s,quadratureNormCoefficient Q e k s,
    (fun j i=>gaussianRowDirection_bound _ _),
    quadratureProjectionCoefficient_bound Q e k s hn,
    quadratureNormCoefficient_bound Q e k s hn,?_⟩
  intro v
  rw [canonicalVector_eq_completion,← completionToVector.map_sub,completionToVector.norm_map]
  let f := normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)
  let M : WithLp 2 (EuclideanSpace ℝ (Fin (Module.finrank ℝ V)) × ℝ) :=
    WithLp.toLp 2 (projectionCoefficients V f,‖f‖^2)
  let R : ℝ := ((1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : Fin d=>gaussianReal 0 1)).toReal))/|α|)*
    (((d:ℝ)+1)*U)
  have hR : 0≤R := by dsimp [R]; positivity
  have hproj : ‖M.fst‖≤R := normalizedCanonicalProjection_bound Q V hKL S α hS hα hU.le v
  have happrox : ‖quadratureJointValue Q e k a gaussianRowDirection s v.val-M‖≤δ := (hs v).le
  have hfinal := quadratureProgram_error Q e k a gaussianRowDirection s v.val M
    (R:=R) (δ:=δ) hR hδ.le hproj happrox
  exact hfinal

#print axioms actual_normalized_canonical_program
end ConditionalNonpolynomial.Analytic
