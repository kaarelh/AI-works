import PhysicalShortPrimitiveResources
import PhysicalShortGridNumerics

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup

 def criticalRoundingExponent (B : ℝ) : ℕ :=
  ⌈(64*(1+criticalReadoutCoefficient B))*(1+1/Real.log 2)⌉₊+criticalPrecisionExponent B+1
 def criticalGridCoefficient (B : ℝ) : ℝ :=
  criticalNonlinearCoefficient B+criticalIterationCoefficient B+64*(1+criticalReadoutCoefficient B)+1
 def criticalGridExponent (B : ℝ) : ℕ :=
  3*criticalPrimitiveExponent B (criticalRoundingExponent B)+
    ⌈criticalGridCoefficient B*(1+1/Real.log 2)⌉₊+3

 lemma criticalIterationCoefficient_nonneg (B : ℝ) : 0≤criticalIterationCoefficient B := by
  have he := criticalEntropyCoefficient_nonneg B
  have hn := criticalNonlinearCoefficient_nonneg B
  have hlog : 0≤Real.log (1+criticalReadoutCoefficient B) :=
    Real.log_nonneg (by unfold criticalReadoutCoefficient;linarith [Real.sqrt_nonneg (514+2*B)])
  have h384 : 0≤Real.log 384 := Real.log_nonneg (by norm_num)
  have h2 : 0<Real.log 2 := Real.log_pos (by norm_num)
  unfold criticalIterationCoefficient
  positivity

 lemma criticalGridCoefficient_nonneg (B : ℝ) : 0≤criticalGridCoefficient B := by
  have hn:=criticalNonlinearCoefficient_nonneg B
  have hi:=criticalIterationCoefficient_nonneg B
  unfold criticalGridCoefficient criticalReadoutCoefficient
  positivity

 lemma canonicalSignRounding_positive {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : 0<canonicalSignRounding P :=
  causalSignRounding_pos _ _ (norm_nonneg _)

 lemma canonicalSignRounding_le_one {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : canonicalSignRounding P≤1 := by
  have hE : 0≤canonicalEntropySum P := Finset.sum_nonneg (fun _ _=>Real.sqrt_nonneg _)
  have hΛ := canonicalNonlinearBudget_nonneg P (canonicalSignPrecision P)
  have he : 1≤Real.exp (canonicalEntropySum P+canonicalNonlinearBudget P (canonicalSignPrecision P)) :=
    Real.one_le_exp_iff.mpr (add_nonneg hE hΛ)
  unfold canonicalSignRounding causalSignRounding
  apply (div_le_iff₀ (by positivity : 0<64*(1+‖P.readout‖)*
    Real.exp (canonicalEntropySum P+canonicalNonlinearBudget P (canonicalSignPrecision P)))).mpr
  nlinarith [norm_nonneg P.readout,mul_le_mul_of_nonneg_left he (by positivity : 0≤64*(1+‖P.readout‖))]

namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

/-- The selected numerical circuit parameters are dominated by one fixed
power of the original problem scale, derived from the actual path budget. -/
theorem critical_grid_resource_envelope (M : FiniteCanonicalDynamics P S states)
    (hd : 1≤d) (hH : 1≤H) {ε B R : ℝ} (hε : 0≤ε) (hB : 0≤B) (hR : 2≤R)
    (hdR : (d:ℝ)≤R) (hHR : (H:ℝ)≤R)
    (hgap : (H:ℝ)*ε≤B*(1+Real.log R)^2) (hnear : P.action≤scalarBaseline.toReal+ε)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (canonicalSignPrecision P))+
      1024*‖P.readout‖^2) :
    M.PrimitiveResources (R^criticalGridExponent B) (canonicalSignRounding P) ∧
      (Fintype.card M.PicardInputIndex:ℝ)≤R^criticalGridExponent B ∧
      (Fintype.card M.PicardStateIndex:ℝ)≤R^criticalGridExponent B ∧
      ((H+1:ℕ):ℝ)≤R^criticalGridExponent B ∧
      canonicalNonlinearBudget P (canonicalSignPrecision P)≤R^criticalGridExponent B ∧
      normalizingScale M.linearGain H*‖P.readout‖≤R^criticalGridExponent B ∧
      (canonicalSignIterations P:ℝ)≤R^criticalGridExponent B := by
  let p:=criticalPrimitiveExponent B (criticalRoundingExponent B)
  let c:=⌈criticalGridCoefficient B*(1+1/Real.log 2)⌉₊
  have hp2 : 2≤p := by dsimp [p,criticalPrimitiveExponent];omega
  have hR0 : 0≤R := by linarith
  have hRead0 : 0≤criticalReadoutCoefficient B := Real.sqrt_nonneg _
  have hround := (critical_rounding_polynomial_bound P hd hH hε hB hR hHR hgap hnear).1
  have hrcoef := resource_constant (show 0≤64*(1+criticalReadoutCoefficient B) by unfold criticalReadoutCoefficient;positivity) hR
  have hround' : (canonicalSignRounding P)⁻¹≤R^(criticalRoundingExponent B) := by
    exact hround.trans ((resource_mul hR hrcoef (le_refl _) (pow_nonneg hR0 _)).trans_eq (by rfl))
  have hprim := M.critical_primitive_resources hd hH hε hB hR hdR hHR hgap hnear hdim hcard
    (criticalRoundingExponent B) hround'
  change M.PrimitiveResources (R^p) (canonicalSignRounding P) at hprim
  have hmono (n : ℕ) (hn : n≤criticalGridExponent B) : R^n≤R^criticalGridExponent B := resource_pow_mono hR hn
  have hpmono : R^p≤R^criticalGridExponent B := hmono p (by dsimp [criticalGridExponent,p];omega)
  have hHplus : ((H+1:ℕ):ℝ)≤R^p := by
    have hh : (H:ℝ)+1≤R^2 := by nlinarith
    have hc : ((H+1:ℕ):ℝ)≤R^2 := by simpa only [Nat.cast_add,Nat.cast_one] using hh
    exact hc.trans (resource_pow_mono hR hp2)
  have hdplus : ((d+1:ℕ):ℝ)≤R^p := by
    have hh : (d:ℝ)+1≤R^2 := by nlinarith
    have hc : ((d+1:ℕ):ℝ)≤R^2 := by simpa only [Nat.cast_add,Nat.cast_one] using hh
    exact hc.trans (resource_pow_mono hR hp2)
  have hK : (Fintype.card M.PicardStateIndex:ℝ)≤R^(p+p) := by
    have hh := resource_mul hR hHplus hprim.dimension (Nat.cast_nonneg _)
    simpa only [PicardStateIndex,Fintype.card_prod,Fintype.card_fin,Nat.cast_mul,canonicalAmbientDimension] using hh
  have hI : (Fintype.card M.PicardInputIndex:ℝ)≤R^(p+p+1) := by
    have hh := resource_add_same hR (hdplus.trans (resource_pow_mono hR (show p≤p+p by omega))) hK
    simpa only [PicardInputIndex,Fintype.card_sum,Fintype.card_fin,Nat.cast_add] using hh
  have hC := resource_constant (criticalGridCoefficient_nonneg B) hR
  change criticalGridCoefficient B≤R^c at hC
  have hN : criticalNonlinearCoefficient B≤R^c :=
    (show criticalNonlinearCoefficient B≤criticalGridCoefficient B by
      unfold criticalGridCoefficient;linarith [criticalIterationCoefficient_nonneg B,Real.sqrt_nonneg (514+2*B)]).trans hC
  have hIt : criticalIterationCoefficient B≤R^c :=
    (show criticalIterationCoefficient B≤criticalGridCoefficient B by
      unfold criticalGridCoefficient;linarith [criticalNonlinearCoefficient_nonneg B,Real.sqrt_nonneg (514+2*B)]).trans hC
  have hRead : 1+criticalReadoutCoefficient B≤R^c :=
    (show 1+criticalReadoutCoefficient B≤criticalGridCoefficient B by
      unfold criticalGridCoefficient;linarith [criticalNonlinearCoefficient_nonneg B,criticalIterationCoefficient_nonneg B,
        show 0≤criticalReadoutCoefficient B from Real.sqrt_nonneg _]).trans hC
  have hlog : 1+Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos (show 0<R by linarith)]
  have hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤R^(c+1) := by
    exact (critical_normal_form_log_budgets P hd hH hε hB hR hHR hgap hnear).2.trans
      ((mul_le_mul_of_nonneg_left hlog (criticalNonlinearCoefficient_nonneg B)).trans
        (resource_mul hR hN (b:=1) (by simpa only [pow_one] using le_refl R) hR0))
  have hk : (canonicalSignIterations P:ℝ)≤R^(c+1) := by
    exact (critical_iteration_log_bound P hd hH hε hB hR hHR hgap hnear).trans
      ((mul_le_mul_of_nonneg_left hlog (criticalIterationCoefficient_nonneg B)).trans
        (resource_mul hR hIt (b:=1) (by simpa only [pow_one] using le_refl R) hR0))
  have hr : ‖P.readout‖≤R^(c+1) :=
    (show ‖P.readout‖≤1+‖P.readout‖ by linarith).trans
      ((critical_readout_polynomial_envelope P hH hε hB hR hgap hnear).trans
        (resource_mul hR hRead (b:=1) (by simpa only [pow_one] using le_refl R) hR0))
  have hs : normalizingScale M.linearGain H*‖P.readout‖≤R^(p+(c+1)) :=
    resource_mul hR (M.scale_le_exp.trans hprim.amplification) hr (norm_nonneg _)
  refine ⟨⟨hprim.scale.trans hpmono,hprim.dimension.trans hpmono,hprim.anchors.trans hpmono,
    hprim.entropy.trans hpmono,hprim.amplification.trans hpmono,hprim.floor.trans hpmono,hprim.tolerance.trans hpmono⟩,
    hI.trans (hmono _ ?_),hK.trans (hmono _ ?_),hHplus.trans hpmono,
    hΛ.trans (hmono _ ?_),hs.trans (hmono _ ?_),hk.trans (hmono _ ?_)⟩ <;>
    dsimp [criticalGridExponent,p,c] <;> omega

#print axioms critical_grid_resource_envelope
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
