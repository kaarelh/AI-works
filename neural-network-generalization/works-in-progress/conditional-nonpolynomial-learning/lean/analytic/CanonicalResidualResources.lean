import CanonicalQuadratureResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

lemma canonicalAmbientDimension_eq_finrank {d : ℕ} (states : ℕ → CanonicalProgramState d) (H : ℕ) :
    canonicalAmbientDimension states H=Module.finrank ℝ (CanonicalAmbient states H) := by
  have hh := LinearEquiv.finrank_eq (canonicalAmbientIso states H).toLinearEquiv
  simpa only [finrank_euclideanSpace,Fintype.card_fin] using hh

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

lemma layerInputDimension_le_ambient (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    M.layerInputDimension j≤canonicalAmbientDimension states H := by
  apply Fintype.card_le_of_injective (fun i:(states j).Index=>
    (⟨j.castSucc,i⟩ : CanonicalAmbientIndex states H))
  intro a b h
  cases h
  rfl

lemma layerRank_le (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    M.layerRank j≤M.layerInputDimension j+S.card := by
  have hh := canonicalGaussian_dimension (M.layer j).law (M.layer j).finiteKL
    (fun s:S=>(states j).feature s)
  simp only [CanonicalIndex,Fintype.card_sum,Fintype.card_fin,Fintype.card_unit,Fintype.card_coe] at hh
  exact Nat.le_of_add_le_add_right hh

lemma quadratureZ_le (M : FiniteCanonicalDynamics P S states) (j : Fin H) :
    M.quadratureZ j≤1+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)+4*criticalLayerCost P j := by
  have hh := reindexedCanonicalNormalizer_bound (M.layer j).law (M.layerSpan j)
    (Fintype.equivFin (states j).Index).symm 1 (M.layer j).finiteKL
  simp only [div_one,one_pow] at hh
  have hc : (klDiv (M.layer j).law (Measure.pi fun _ : (states j).Index=>ProbabilityTheory.gaussianReal 0 1)).toReal≤
      criticalLayerCost P j := (M.layer j).cost_le
  apply hh.trans
  dsimp only [layerRank,layerInputDimension]
  linarith

/-- Primitive resource bounds are subsequently derived from the near-baseline
path. They contain numerical quantities, with no circuit or approximation
claim built into the definition. -/
structure PrimitiveResources (M : FiniteCanonicalDynamics P S states) (W τ : ℝ) : Prop where
  scale : 2≤W
  dimension : (canonicalAmbientDimension states H:ℝ)≤W
  anchors : (S.card:ℝ)≤W
  entropy : (∑j:Fin H,criticalLayerCost P j)≤W
  amplification : Real.exp (canonicalEntropySum P)≤W
  floor : (canonicalSignPrecision P)⁻¹≤W
  tolerance : τ⁻¹≤W

lemma primitive_layer_bounds (M : FiniteCanonicalDynamics P S states) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (j : Fin H) :
    (M.layerInputDimension j:ℝ)≤W ∧ (M.layerRank j:ℝ)≤W^2 ∧
    M.quadratureZ j≤W^6 ∧ normalizingScale M.linearGain j≤W ∧
    (canonicalRadius P (canonicalSignPrecision P) j)⁻¹≤W ∧ 1+M.linearGain j≤W^2 := by
  have hW0 : 0≤W := by linarith [h.scale]
  have hi : (M.layerInputDimension j:ℝ)≤W :=
    (show (M.layerInputDimension j:ℝ)≤canonicalAmbientDimension states H by exact_mod_cast M.layerInputDimension_le_ambient j).trans h.dimension
  have hr0 : (M.layerRank j:ℝ)≤(M.layerInputDimension j:ℝ)+(S.card:ℝ) := by exact_mod_cast M.layerRank_le j
  have hr : (M.layerRank j:ℝ)≤W^2 := by nlinarith [h.scale,h.anchors]
  have hD : criticalLayerCost P j≤W :=
    (Finset.single_le_sum (f:=fun k:Fin H=>criticalLayerCost P k)
      (fun k _=>ENNReal.toReal_nonneg) (Finset.mem_univ j)).trans h.entropy
  have hg : 1+M.linearGain j≤W^2 := by
    have hs : Real.sqrt (2*criticalLayerCost P j)≤W := by
      apply (Real.sqrt_le_iff).mpr
      exact ⟨hW0,by nlinarith [h.scale]⟩
    simp only [linearGain,if_pos j.isLt]
    nlinarith [h.scale]
  have hfour : (4:ℝ)≤W^2 := by nlinarith [h.scale]
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hDi : 4*criticalLayerCost P j≤W^3 := resource_mul h.scale hfour (b:=1)
    (by simpa using hD) ENNReal.toReal_nonneg
  have hini : 2*(M.layerInputDimension j:ℝ)≤W^2 := resource_mul h.scale htwo (b:=1)
    (by simpa using hi) (Nat.cast_nonneg _)
  have hzr : 1+(M.layerRank j:ℝ)≤W^3 := by
    simpa only [add_comm] using resource_add_one h.scale hr
  have hzi : 1+(M.layerRank j:ℝ)+2*(M.layerInputDimension j:ℝ)≤W^4 :=
    resource_add_same h.scale hzr (hini.trans (resource_pow_mono h.scale (by norm_num)))
  have hz : M.quadratureZ j≤W^6 := (M.quadratureZ_le j).trans
    ((resource_add_same h.scale hzi (hDi.trans (resource_pow_mono h.scale (by norm_num)))).trans
      (resource_pow_mono h.scale (by norm_num)))
  have hs : normalizingScale M.linearGain j≤W :=
    (normalizingScale_mono M.linearGain M.linearGain_one_le j.isLt.le).trans
      (M.scale_le_exp.trans h.amplification)
  have hf : (canonicalRadius P (canonicalSignPrecision P) j)⁻¹≤W := by
    have hh : canonicalSignPrecision P≤canonicalRadius P (canonicalSignPrecision P) j := by
      unfold canonicalRadius
      linarith [Real.sqrt_nonneg (maxFeatureVariance (P.feature j))]
    exact (inv_anti₀ (canonicalSignPrecision_pos P) hh).trans h.floor
  exact ⟨hi,hr,hz,hs,hf,hg⟩

lemma primitive_residual_coefficient_bound (M : FiniteCanonicalDynamics P S states) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (j : Fin H) :
    (M.residualCoefficientBudget j:ℝ)≤W^12 := by
  obtain ⟨hi,hr,hZ,hs,hfloor,hgain⟩ := M.primitive_layer_bounds h j
  have hW0 : 0≤W := by linarith [h.scale]
  have hradpos := canonicalRadius_pos P (canonicalSignPrecision_pos P) j
  have hsqr : (canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2≤W^2 :=
    pow_le_pow_left₀ (inv_nonneg.mpr hradpos.le) hfloor 2
  have hs1 : 1+normalizingScale M.linearGain j≤W^2 := by
    have hh := resource_add_one h.scale (a:=1) (by simpa using hs)
    norm_num at hh
    linarith
  have hsum3 := resource_add_same h.scale hs1 hsqr
  have hsum7 := resource_add_same h.scale
    (hsum3.trans (resource_pow_mono h.scale (show 3≤6 by norm_num))) hZ
  have hsum8 := resource_add_same h.scale hsum7
    (hgain.trans (resource_pow_mono h.scale (show 2≤7 by norm_num)))
  have hpos : 0≤1+normalizingScale M.linearGain j+
      (canonicalRadius P (canonicalSignPrecision P) j)⁻¹^2+M.quadratureZ j+(1+M.linearGain j) := by
    have hz := M.quadratureZ_positive j
    have hg := M.linearGain_one_le j
    have hss := normalizingScale_one_le M.linearGain M.linearGain_one_le j
    positivity
  exact (resource_ceil_add_one h.scale hpos hsum8).trans (resource_pow_mono h.scale (by norm_num))

lemma primitive_quadrature_count_bound (M : FiniteCanonicalDynamics P S states) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin H) :
    (M.quadratureCount j τ:ℝ)≤W^648 := by
  obtain ⟨hi,hr,hZ,hs,hfloor,hgain⟩ := M.primitive_layer_bounds h j
  have hW0 : 0≤W := by linarith [h.scale]
  have height : (8:ℝ)≤W^3 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) h.scale 3
    norm_num at hh
    exact hh
  have hg0 : 0≤1+M.linearGain j := by linarith [M.linearGain_one_le j]
  have hprod := resource_mul h.scale (resource_mul h.scale height hgain hg0)
    (b:=1) (by simpa using h.tolerance) (inv_nonneg.mpr hτ.le)
  have hsq := resource_pow h.scale hprod (by positivity) 2
  have he : (M.quadratureError j τ)⁻¹=(8*(1+M.linearGain j)*τ⁻¹)^2 := by
    rw [quadratureError,←inv_pow,inv_div,div_eq_mul_inv]
  have hδinv : (M.quadratureError j τ)⁻¹≤W^12 := by rw [he];exact hsq
  have hWle : W≤W^12 := by simpa only [pow_one] using resource_pow_mono h.scale (show 1≤12 by norm_num)
  have hh := canonicalQuadrature_resources (h.scale.trans hWle) (hi.trans hWle)
    (M.quadratureZ_positive j).le (hZ.trans (resource_pow_mono h.scale (by norm_num)))
    (M.quadratureError_positive j hτ) hδinv
  simpa only [quadratureCount,←pow_mul] using hh.2

/-- Both the actual residual program and its coefficient budget have
universal polynomial resources in the primitive scale. -/
theorem exists_primitive_residual_program (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {W τ : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin H) :
    ∃A : ArithmeticProgram (canonicalAmbientDimension states H) (canonicalAmbientDimension states H),
      A.length=14 ∧ A.bounded (M.residualCoefficientBudget j) ∧
      (A.maxDimension:ℝ)≤W^656 ∧ (M.residualCoefficientBudget j:ℝ)≤W^656 ∧
      ∀x:EuclideanSpace ℝ (CanonicalAmbientIndex states H),‖A.realMap x-M.residualCoordinates j x‖≤τ := by
  obtain ⟨A,hlen,hbound,hdim,happrox⟩ := M.exists_residual_realMap_program hd j hτ hτ1
  refine ⟨A,hlen,hbound,?_,(M.primitive_residual_coefficient_bound h j).trans
    (resource_pow_mono h.scale (by norm_num)),happrox⟩
  have hW0 : 0≤W := by linarith [h.scale]
  obtain ⟨hi,hr,hZ,hs,hfloor,hgain⟩ := M.primitive_layer_bounds h j
  have hn := M.primitive_quadrature_count_bound h hτ j
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hfour : (4:ℝ)≤W^2 := by nlinarith [h.scale]
  have hterm1 : 2*(canonicalAmbientDimension states H:ℝ)≤W^2 :=
    resource_mul h.scale htwo (b:=1) (by simpa using h.dimension) (Nat.cast_nonneg _)
  have hterm2 : 4*(M.layerInputDimension j:ℝ)≤W^3 :=
    resource_mul h.scale hfour (b:=1) (by simpa using hi) (Nat.cast_nonneg _)
  have hterm3 : 2*(M.quadratureCount j τ:ℝ)≤W^649 :=
    resource_mul h.scale htwo hn (Nat.cast_nonneg _)
  have hterm4 : 2*(M.layerRank j:ℝ)≤W^3 :=
    resource_mul h.scale htwo hr (Nat.cast_nonneg _)
  have hsum1 := resource_add_same h.scale
    (hterm1.trans (resource_pow_mono h.scale (show 2≤649 by norm_num)))
    (hterm2.trans (resource_pow_mono h.scale (show 3≤649 by norm_num)))
  have hsum2 := resource_add_same h.scale hsum1
    (hterm3.trans (resource_pow_mono h.scale (show 649≤650 by norm_num)))
  have hsum3 := resource_add_same h.scale hsum2
    (hterm4.trans (resource_pow_mono h.scale (show 3≤651 by norm_num)))
  have hsum4 := resource_add_same h.scale hsum3
    (hfour.trans (resource_pow_mono h.scale (show 2≤652 by norm_num)))
  have hdimR : (A.maxDimension:ℝ)≤2*(canonicalAmbientDimension states H:ℝ)+
      4*(M.layerInputDimension j:ℝ)+2*(M.quadratureCount j τ:ℝ)+2*(M.layerRank j:ℝ)+4 := by
    exact_mod_cast hdim
  exact hdimR.trans (hsum4.trans (resource_pow_mono h.scale (by norm_num)))

#print axioms primitive_residual_coefficient_bound
#print axioms primitive_quadrature_count_bound
#print axioms exists_primitive_residual_program
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
