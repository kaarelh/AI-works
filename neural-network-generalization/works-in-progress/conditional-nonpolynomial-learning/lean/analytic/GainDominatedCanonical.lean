import GainNormalizedCanonical
noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] {d : ℕ}
variable (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
theorem normalizedTanhL2_norm_of_gain_le
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0)
    (hαgain : Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))≤α)
    (v : EuclideanSpace ℝ I) :
    ‖normalizedTanhL2 Q S α v‖≤‖v‖ := by
  let D := (klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal
  have hα : 0<α := lt_of_lt_of_le
    (Real.sqrt_pos.mpr (lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le D))) hαgain
  have hzero : actualTanhL2 Q (0 : EuclideanSpace ℝ I)=0 := by
    apply Lp.ext
    filter_upwards [actualTanhL2_ae Q (0 : EuclideanSpace ℝ I)] with z hz
    simpa [gaussianLinearForm] using hz
  have hh := actualTanhL2_sharp_gain Q hKL (S • v) 0
  rw [hzero,sub_zero,sub_zero,norm_smul,Real.norm_eq_abs] at hh
  have hh := hh.trans (mul_le_mul_of_nonneg_right hαgain (by positivity : 0≤|S| *‖v‖))
  change ‖(S*α)⁻¹ • actualTanhL2 Q (S • v)‖≤‖v‖
  rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_mul,abs_of_pos hα]
  apply (mul_le_mul_of_nonneg_left hh (by positivity : 0≤(|S| *α)⁻¹)).trans_eq
  have hs : |S|≠0 := abs_ne_zero.mpr hS
  field_simp

variable (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]
theorem gainDominatedNormalizer_bound (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (α : ℝ)
    (hαgain : Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))≤α) :
    canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)≤
      3+(Module.finrank ℝ V:ℝ)+2*(d:ℝ) := by
  let D := (klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal
  have hαpos : 0<α := lt_of_lt_of_le
    (Real.sqrt_pos.mpr (lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le D))) hαgain
  have hsq : gaussianEntropyGain D≤α^2 := by
    have hh := pow_le_pow_left₀ (Real.sqrt_nonneg (gaussianEntropyGain D)) hαgain 2
    rwa [Real.sq_sqrt (le_trans (by norm_num) (gaussianEntropyGain_one_le D))] at hh
  have hratio : (2*(d:ℝ)+4*D)/α^2≤2*(d:ℝ)+2 := by
    apply (div_le_iff₀ (sq_pos_of_pos hαpos)).mpr
    have hg := gaussianEntropyGain_one_le D
    have hd := gaussianEntropyGain_two_cost (D:=D) ENNReal.toReal_nonneg
    have hm := mul_nonneg (show (0:ℝ)≤2*d by positivity) (show 0≤α^2-1 by linarith)
    nlinarith
  have hh := reindexedCanonicalNormalizer_bound Q V e α hKL
  linarith

theorem actual_gain_dominated_canonical_program (e : Fin d≃I)
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞)
    (S α : ℝ) (hS : S≠0)
    (hαgain : Real.sqrt (gaussianEntropyGain ((klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal))≤α) (U : ℝ) (hU : 0<U)
    (T : ℕ) (hT : 0<T) (δ : ℝ) (hδ : 0<δ) (n : ℕ) (hn : 0<n)
    (hmesh : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
      4*(Z*((d+1:ℝ)*(1+2*((d+1:ℝ)*U))))*U≤(T:ℝ)*δ)
    (hbudget : let Z := canonicalNormalizer Q (canonicalBasisValues Q V) (fun z=>gaussianRowNorm z/α)
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
              α
              (reindexedVector e (WithLp.toLp 2 v.val)))‖≤
                δ+Real.sqrt ((1+2*(((d:ℝ)+1)*U+δ))*δ) := by
  have hα : 0<α := lt_of_lt_of_le (Real.sqrt_pos.mpr (lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le _))) hαgain
  obtain ⟨s,hs⟩ := reindexed_canonical_quadrature Q V e hKL S α hS hα.ne'
    U hU T hT δ hδ n hn hmesh hbudget
  let basis := canonicalBasisValues Q V
  let weight := fun (z : I→ℝ)=>gaussianRowNorm z/α
  let ridge := fun (z : I→ℝ)=>S*gaussianRowNorm z
  let directions := fun (z : I→ℝ) i=>gaussianRowDirection z (e i)
  have hZ := gainDominatedNormalizer_bound Q V e hKL α hαgain
  refine ⟨(fun i=>directions (s i)),(fun i=>ridge (s i)),
    quadratureProjectionCoefficient Q basis weight s,
    quadratureNormCoefficient Q basis weight s,
    (fun j i=>gaussianRowDirection_bound _ _),?_,?_,?_⟩
  · intro j i
    exact (quadratureProjectionCoefficient_bound Q basis weight s hn j i).trans
      (by dsimp only [basis,weight]; linarith)
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
      apply (normalizedTanhL2_norm_of_gain_le Q hKL S α hS hαgain _).trans
      rw [(reindexedVector e).norm_map]
      exact cube_euclidean_norm_bound hU.le v
    have happrox : ‖quadratureJointValue Q basis weight ridge directions s v.val-M‖≤δ := (hs v).le
    exact quadratureProgram_error Q basis weight ridge directions s v.val M
      (R:=((d:ℝ)+1)*U) (δ:=δ) (by positivity) hδ.le hproj happrox

#print axioms actual_gain_dominated_canonical_program
end ConditionalNonpolynomial.Analytic
