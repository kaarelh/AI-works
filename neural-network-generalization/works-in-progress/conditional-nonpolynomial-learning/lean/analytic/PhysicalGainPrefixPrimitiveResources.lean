import PhysicalGainPrefixResidualExistence
import PhysicalShortResidualResources
import ResidualProgramResources

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma layerInputDimension_le_ambient (M : GainPrefixDynamics P S states J) (j : Fin J) :
    M.layerInputDimension j≤canonicalAmbientDimension states J := by
  apply Fintype.card_le_of_injective (fun i:(states j).Index=>
    (⟨j.castSucc,i⟩ : CanonicalAmbientIndex states J))
  intro a b h
  cases h
  rfl

lemma layerRank_le (M : GainPrefixDynamics P S states J) (j : Fin J) :
    M.layerRank j≤M.layerInputDimension j+S.card := by
  have hh := canonicalGaussian_dimension (M.layer j).law (M.layer j).finiteKL
    (fun s:S=>t • (states j).feature s)
  simp only [CanonicalIndex,Fintype.card_sum,Fintype.card_fin,Fintype.card_unit,Fintype.card_coe] at hh
  exact Nat.le_of_add_le_add_right hh

/-- Only actual dimensions, a clipping floor and requested accuracy enter
these primitive resource bounds; physical scale and gain products do not. -/
structure PrimitiveResources (M : GainPrefixDynamics P S states J) (W τ : ℝ) : Prop where
  scale : 2≤W
  dimension : (canonicalAmbientDimension states J:ℝ)≤W
  anchors : (S.card:ℝ)≤W
  floor : ∀j:Fin J,(M.radius j)⁻¹≤W
  tolerance : τ⁻¹≤W

lemma primitive_layer_bounds (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (j : Fin J) :
    (M.layerInputDimension j:ℝ)≤W ∧ (M.layerRank j:ℝ)≤W^2 ∧ M.quadratureZ j≤W^5 := by
  have hi : (M.layerInputDimension j:ℝ)≤W :=
    (show (M.layerInputDimension j:ℝ)≤canonicalAmbientDimension states J by exact_mod_cast M.layerInputDimension_le_ambient j).trans h.dimension
  have hr0 : (M.layerRank j:ℝ)≤(M.layerInputDimension j:ℝ)+(S.card:ℝ) := by exact_mod_cast M.layerRank_le j
  have hr : (M.layerRank j:ℝ)≤W^2 := by nlinarith [h.scale,h.anchors]
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hthree : (3:ℝ)≤W^2 := by nlinarith [h.scale]
  have hini : 2*(M.layerInputDimension j:ℝ)≤W^2 := resource_mul h.scale htwo (b:=1)
    (by simpa using hi) (Nat.cast_nonneg _)
  have hsum := resource_add_same h.scale (resource_add_same h.scale hthree hr)
    (hini.trans (resource_pow_mono h.scale (show 2≤3 by norm_num)))
  exact ⟨hi,hr,(M.quadratureZ_bound j).trans (hsum.trans (resource_pow_mono h.scale (by norm_num)))⟩

lemma primitive_residual_coefficient_bound (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (j : Fin J) :
    (M.residualCoefficientBudget j:ℝ)≤W^10 := by
  obtain ⟨hi,hr,hZ⟩ := M.primitive_layer_bounds h j
  have hW0 : 0≤W := by linarith [h.scale]
  have hsqr : (M.radius j)⁻¹^2≤W^2 := pow_le_pow_left₀
    (inv_nonneg.mpr (M.radius_pos j j.isLt).le) (h.floor j) 2
  have hsix : (6:ℝ)≤W^3 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) h.scale 3
    norm_num at hh
    linarith
  have hini : 2*(M.layerInputDimension j:ℝ)≤W^2 := resource_mul h.scale
    (a:=1) (by simpa using h.scale) (b:=1) (by simpa using hi) (Nat.cast_nonneg _)
  have hsum4 := resource_add_same h.scale hsix (hr.trans (resource_pow_mono h.scale (by norm_num)))
  have hsum5 := resource_add_same h.scale hsum4 (hini.trans (resource_pow_mono h.scale (by norm_num)))
  have hsum6 := resource_add_same h.scale hsum5 (hsqr.trans (resource_pow_mono h.scale (by norm_num)))
  have hp : 0≤6+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)+(M.radius j)⁻¹^2 := by positivity
  exact (resource_ceil_add_one h.scale hp hsum6).trans (resource_pow_mono h.scale (by norm_num))

lemma primitive_quadrature_count_bound (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin J) :
    (M.quadratureCount j τ:ℝ)≤W^972 := by
  obtain ⟨hi,hr,hZ⟩ := M.primitive_layer_bounds h j
  have h64 : (64:ℝ)≤W^6 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) h.scale 6
    norm_num at hh
    exact hh
  have hd1 : (M.layerInputDimension j:ℝ)+1≤W^2 := by
    simpa only [pow_one] using resource_add_one h.scale (a:=1) (by simpa using hi)
  have hprod := resource_mul h.scale (resource_mul h.scale h64 hd1 (by positivity))
    (b:=1) (by simpa using h.tolerance) (inv_nonneg.mpr hτ.le)
  have hsq := resource_pow h.scale hprod (by positivity) 2
  have he : (M.quadratureError j τ)⁻¹=(64*((M.layerInputDimension j:ℝ)+1)*τ⁻¹)^2 := by
    rw [quadratureError,←inv_pow,inv_div,div_eq_mul_inv]
  have hδinv : (M.quadratureError j τ)⁻¹≤W^18 := by rw [he];exact hsq
  have hWle : W≤W^18 := by simpa only [pow_one] using resource_pow_mono h.scale (show 1≤18 by norm_num)
  have hh := canonicalQuadrature_resources (h.scale.trans hWle) (hi.trans hWle)
    (M.quadratureZ_positive j).le (hZ.trans (resource_pow_mono h.scale (by norm_num)))
    (M.quadratureError_positive j hτ) hδinv
  simpa only [quadratureCount,←pow_mul] using hh.2

lemma primitive_residual_dimension_bound (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin J)
    (w : Fin (M.quadratureCount j τ)→Fin (M.layerInputDimension j)→ℝ)
    (a : Fin (M.quadratureCount j τ)→ℝ)
    (A : Fin (M.layerRank j)→Fin (M.quadratureCount j τ)→ℝ)
    (b : Fin (M.quadratureCount j τ)→ℝ) :
    ((M.residualProgram j w a A b).maxDimension:ℝ)≤W^984 := by
  have hdim := residualArithmeticProgram_dimension (linearCoefficients (M.residualPreEncoded j))
    (M.radius j) w a A b (linearCoefficients (M.residualPost j))
  have hdimN : (M.residualProgram j w a A b).maxDimension≤2*canonicalAmbientDimension states J+
      4*M.layerInputDimension j+2*M.quadratureCount j τ+2*M.layerRank j+4 := by
    simpa only [residualProgram,two_mul] using hdim
  have hdimR : ((M.residualProgram j w a A b).maxDimension:ℝ)≤2*(canonicalAmbientDimension states J:ℝ)+
      4*(M.layerInputDimension j:ℝ)+2*(M.quadratureCount j τ:ℝ)+2*(M.layerRank j:ℝ)+4 := by
    exact_mod_cast hdimN
  obtain ⟨hi,hr,hZ⟩ := M.primitive_layer_bounds h j
  have hn := M.primitive_quadrature_count_bound h hτ j
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hfour : (4:ℝ)≤W^2 := by nlinarith [h.scale]
  have ht1 : 2*(canonicalAmbientDimension states J:ℝ)≤W^2 :=
    resource_mul h.scale htwo (b:=1) (by simpa using h.dimension) (Nat.cast_nonneg _)
  have ht2 : 4*(M.layerInputDimension j:ℝ)≤W^3 :=
    resource_mul h.scale hfour (b:=1) (by simpa using hi) (Nat.cast_nonneg _)
  have ht3 : 2*(M.quadratureCount j τ:ℝ)≤W^973 := resource_mul h.scale htwo hn (Nat.cast_nonneg _)
  have ht4 : 2*(M.layerRank j:ℝ)≤W^3 := resource_mul h.scale htwo hr (Nat.cast_nonneg _)
  have hs1 := resource_add_same h.scale
    (ht1.trans (resource_pow_mono h.scale (show 2≤973 by norm_num)))
    (ht2.trans (resource_pow_mono h.scale (show 3≤973 by norm_num)))
  have hs2 := resource_add_same h.scale hs1 (ht3.trans (resource_pow_mono h.scale (by norm_num)))
  have hs3 := resource_add_same h.scale hs2 (ht4.trans (resource_pow_mono h.scale (by norm_num)))
  have hs4 := resource_add_same h.scale hs3 (hfour.trans (resource_pow_mono h.scale (by norm_num)))
  exact hdimR.trans (hs4.trans (resource_pow_mono h.scale (by norm_num)))

/-- Actual fourteen-stage program with a universal polynomial resource bound. -/
theorem exists_primitive_residual_program (M : GainPrefixDynamics P S states J)
    {W τ : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin J) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states J) (canonicalAmbientDimension states J),
      A.length=14 ∧ A.bounded (M.residualCoefficientBudget j) ∧
      (A.maxDimension:ℝ)≤W^984 ∧ (M.residualCoefficientBudget j:ℝ)≤W^984 ∧
      ∀x:EuclideanSpace ℝ (Fin (canonicalAmbientDimension states J)),
        ‖WithLp.toLp 2 (A.eval (fun i=>x i))-
          (canonicalAmbientIso states J).symm (M.residual j (canonicalAmbientIso states J x))‖≤τ := by
  obtain ⟨w,a,A,b,hbound,happrox⟩ := M.exists_residual_program j hτ hτ1
  exact ⟨M.residualProgram j w a A b,M.residualProgram_length j w a A b,hbound,
    M.primitive_residual_dimension_bound h hτ j w a A b,
    (M.primitive_residual_coefficient_bound h j).trans (resource_pow_mono h.scale (by norm_num)),happrox⟩

#print axioms primitive_quadrature_count_bound
#print axioms primitive_residual_dimension_bound
#print axioms exists_primitive_residual_program
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
