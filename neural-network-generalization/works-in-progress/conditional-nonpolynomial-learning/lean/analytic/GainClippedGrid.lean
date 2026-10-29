import GainClippedResources
import UniformGridResources

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup

def gainGridSizeExponent : ℕ := 4000*uniformGridExponent 14

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

theorem exists_gainClipped_grid
    (M:CanonicalLayerModel (J:=J) anchors D) {S α δ R:ℝ} (Q:ℕ)
    (hS:0<S)
    (hαgain:Real.sqrt (gaussianEntropyGain ((klDiv M.law
      (NeuralGeneralization.GaussianAngularFields.standardLaw I)).toReal))≤α)
    (hδ:0<δ) (hδ1:δ≤1) (hR:2≤R)
    (hd:(Fintype.card I:ℝ)≤R) (ho:(Fintype.card J:ℝ)≤R) (hm:(M.gainRank:ℝ)≤R)
    (hi:δ⁻¹≤R) (hQ:0<Q) (hQup:(Q:ℝ)≤R^4)
    (hQlow:2*((Fintype.card J:ℝ)+1)/δ≤(Q:ℝ)) :
    ∃c:CircuitMap (Fintype.card I*Fintype.card (ScalarGrid Q 3))
      (Fintype.card J*Fintype.card (ScalarGrid Q 3)),
      c.depth≤80 ∧ (c.size:ℝ)≤R^gainGridSizeExponent ∧
      GridApproximates Q 3 Q 3 (M.gainClippedValue S α) c δ := by
  let τ:=δ/4
  let ε:=δ/(4*((Fintype.card J:ℝ)+1))
  have hτ:0<τ := by dsimp [τ];positivity
  have hτ1:τ≤1 := by dsimp [τ];linarith
  have hε:0<ε := by dsimp [ε];positivity
  have ho1:0<(Fintype.card J:ℝ)+1 := by positivity
  have hε1:ε≤1 := by
    dsimp [ε]
    apply (div_le_one (by positivity)).mpr
    have hn:=Nat.cast_nonneg (α:=ℝ) (Fintype.card J)
    linarith
  have hR4:R≤R^4 := by simpa using resource_pow_mono hR (show 1≤4 by omega)
  have hbase:2≤R^4 := hR.trans hR4
  have h4:(4:ℝ)≤R^2 := by nlinarith
  have hτinv:τ⁻¹≤R^4 := by
    have hh:=resource_mul hR h4 (a:=2) (b:=1) (by simpa using hi) (inv_nonneg.mpr hδ.le)
    have he:τ⁻¹=4*δ⁻¹ := by dsimp [τ];field_simp
    rw [he]
    exact hh.trans (resource_pow_mono hR (by omega))
  have hεinv:1/ε≤R^5 := by
    have ho':(Fintype.card J:ℝ)+1≤R^2 :=
      resource_add_one hR (a:=1) (by simpa using ho)
    have hh:=resource_mul hR (resource_mul hR h4 ho' (by positivity))
      (b:=1) (by simpa using hi) (inv_nonneg.mpr hδ.le)
    have he:1/ε=4*((Fintype.card J:ℝ)+1)*δ⁻¹ := by dsimp [ε];field_simp
    rw [he]
    exact hh
  obtain ⟨P,hplen,hpB,hpdim,hpapprox⟩:=M.exists_gainClipped_realMap_program hS hαgain hτ hτ1
  let c:=uniformProgramGrid P M.gainCoefficientBudget 4 Q 3 ε
  refine ⟨c,?_,?_,?_⟩
  · have hh:=uniformProgramGrid_depth P M.gainCoefficientBudget 4 Q 3 ε
    rw [hplen] at hh
    exact hh
  · have hbr:=(M.gain_primitive_resources hbase (hd.trans hR4) (hm.trans hR4) hτ hτinv hαgain).1
    have hdr:=M.gain_primitive_dimension_resource hbase (hd.trans hR4) (ho.trans hR4)
      (hm.trans hR4) hτ hτinv hαgain
    rw [←pow_mul] at hbr hdr
    have hPdim:(P.maxDimension:ℝ)≤R^4000 :=
      (show (P.maxDimension:ℝ)≤(5*Fintype.card I+Fintype.card J+
        2*M.gainQuadratureCount α τ+2*M.gainRank+4:ℕ) by exact_mod_cast hpdim).trans hdr
    have hRlarge:R≤R^4000 := by simpa using resource_pow_mono hR (show 1≤4000 by omega)
    have hlarge:2≤R^4000 := hR.trans hRlarge
    have hB:(M.gainCoefficientBudget:ℝ)≤R^4000 :=
      hbr.trans (resource_pow_mono hR (show 4*6≤4000 by omega))
    have hh:=uniformProgramGrid_resource P hlarge M.gainCoefficientBudget 4 Q 3 14 hε
      hplen.le hpB hPdim (ho.trans hRlarge) hB
      (h4.trans (resource_pow_mono hR (show 2≤4000 by omega)))
      (hQup.trans (resource_pow_mono hR (show 4≤4000 by omega)))
      ((show (3:ℝ)≤R^2 by nlinarith).trans (resource_pow_mono hR (show 2≤4000 by omega)))
      (hεinv.trans (resource_pow_mono hR (show 5≤4000 by omega)))
    simpa only [gainGridSizeExponent,←pow_mul] using hh
  · have he:((Fintype.card J:ℝ)+1)*ε=δ/4 := by
      dsimp [ε];field_simp
    have hqreal:0<(Q:ℝ) := by exact_mod_cast hQ
    have hqerr:((Fintype.card J:ℝ)+1)/(2*(Q:ℝ))≤δ/4 := by
      apply (div_le_iff₀ (by positivity)).mpr
      have hh:2*((Fintype.card J:ℝ)+1)≤(Q:ℝ)*δ := (div_le_iff₀ hδ).mp hQlow
      nlinarith
    have hh:=uniformProgramGrid_approximates P M.gainCoefficientBudget 4 Q 3 hpB hQ
      (by norm_num) (M.gainClippedValue S α) hε hε1
      (τ:=τ) (R:=2) (fun x _=>by simpa only [norm_sub_rev] using hpapprox x)
      (fun a=>M.gainClippedValue_norm hS hαgain _) (by rw [he];dsimp [τ];norm_num;linarith)
    intro a
    obtain ⟨b,hb,herr⟩:=hh a
    refine ⟨b,hb,herr.trans ?_⟩
    rw [he]
    dsimp [τ]
    linarith

#print axioms exists_gainClipped_grid
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
