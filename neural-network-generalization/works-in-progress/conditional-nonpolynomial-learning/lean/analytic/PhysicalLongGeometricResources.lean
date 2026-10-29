import PhysicalLongPrecisionResources
import PhysicalGainPrefixPrimitiveResources
import PhysicalGainPrefixConstruction

noncomputable section
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
  {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma prefixAmbient_dimension_le (hJ : J≤H)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) :
    canonicalAmbientDimension states J≤(J+1)*(d+1+J*(S.card+1)) := by
  unfold canonicalAmbientDimension
  rw [Fintype.card_sigma]
  calc
    _ ≤ ∑_j:Fin (J+1),(d+1+J*(S.card+1)) := by
      apply Finset.sum_le_sum
      intro j hj
      have hjJ : j.val≤J := by omega
      exact (hdim j (hjJ.trans hJ)).trans (by
        have hm:=Nat.mul_le_mul_right (S.card+1) hjJ
        omega)
    _ = _ := by simp

 theorem long_anchor_card_resource (P : ControlledMarginPath d H t f)
    {W : ℝ} (hW : 2≤W) (hH : (H:ℝ)+1≤W) (hr : ‖P.readout‖≤W)
    (hG : physicalGainProduct P H≤W)
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
      ‖P.readout‖^2/((1:ℝ)/32)^2) : (S.card:ℝ)≤W^186 := by
  have hη := physicalAbsolutePrecision_pos P (longCompressionPrecision_pos P)
  have hηinv := (long_precision_primitive_resources P hW hH hr hG).2.2.2
  have hH' : (H:ℝ)≤W^1 := by simpa only [pow_one] using (by linarith : (H:ℝ)≤W)
  have hfirst : (H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))≤W^185 := by
    have hh := div_le_div_of_nonneg_left (Nat.cast_nonneg (α:=ℝ) H) hη (by linarith :
      physicalAbsolutePrecision P (longCompressionPrecision P)≤2*physicalAbsolutePrecision P (longCompressionPrecision P))
    apply hh.trans
    rw [div_eq_mul_inv]
    exact resource_mul hW hH' hηinv (inv_nonneg.mpr hη.le)
  have h1024 : (1024:ℝ)≤W^10 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hW 10
    norm_num at hh
    exact hh
  have hsquare := resource_pow hW (a:=1) (by simpa only [pow_one] using hr) (norm_nonneg _) 2
  have hsecond : ‖P.readout‖^2/((1:ℝ)/32)^2≤W^12 := by
    have hh := resource_mul hW h1024 hsquare (sq_nonneg _)
    convert hh using 1 <;> norm_num <;> ring
  exact hcard.trans (resource_add_same hW hfirst
    (hsecond.trans (resource_pow_mono hW (by norm_num))))

 theorem long_prefix_geometric_resources (M : GainPrefixDynamics P S states J)
    {W : ℝ} (hW : 2≤W) (hH : (H:ℝ)+1≤W) (hd : (d:ℝ)+1≤W)
    (hr : ‖P.readout‖≤W) (hG : physicalGainProduct P H≤W)
    (hcard : (S.card:ℝ)≤(H:ℝ)/(2*physicalAbsolutePrecision P (longCompressionPrecision P))+
      ‖P.readout‖^2/((1:ℝ)/32)^2)
    (hdim : ∀j≤H,(states j).dimension≤d+1+j*(S.card+1))
    (hfloor : ∀j:Fin J,(M.radius j)⁻¹≤((H:ℝ)+1)*(physicalPartialGainBound P+1)) :
    (S.card:ℝ)≤W^186 ∧ (canonicalAmbientDimension states J:ℝ)≤W^190 ∧
      (Fintype.card (Fin (J+1)×CanonicalAmbientIndex states J):ℝ)≤W^191 ∧
      (Fintype.card (Fin (d+1)⊕(Fin (J+1)×CanonicalAmbientIndex states J)):ℝ)≤W^192 ∧
      ∀j:Fin J,(M.radius j)⁻¹≤W^5 := by
  have hc := long_anchor_card_resource P hW hH hr hG hcard
  have hc1 := resource_add_one hW hc
  have hj : (J:ℝ)≤W^1 := by
    have hJ : (J:ℝ)≤H := by exact_mod_cast M.length_le
    simpa only [pow_one] using (by linarith : (J:ℝ)≤W)
  have hj1 : (J:ℝ)+1≤W^1 := by
    have hJ : (J:ℝ)≤H := by exact_mod_cast M.length_le
    simpa only [pow_one] using (by linarith : (J:ℝ)+1≤W)
  have hinside := resource_add_same hW
    ((by simpa only [pow_one] using hd : (d:ℝ)+1≤W^1).trans (resource_pow_mono hW (show 1≤188 by norm_num)))
    (resource_mul hW hj hc1 (by positivity))
  have hdim0 : (canonicalAmbientDimension states J:ℝ)≤((J:ℝ)+1)*((d:ℝ)+1+(J:ℝ)*((S.card:ℝ)+1)) := by
    exact_mod_cast prefixAmbient_dimension_le M.length_le hdim
  have hD : (canonicalAmbientDimension states J:ℝ)≤W^190 :=
    hdim0.trans (resource_mul hW hj1 hinside (by positivity))
  have hK : (Fintype.card (Fin (J+1)×CanonicalAmbientIndex states J):ℝ)≤W^191 := by
    have hh := resource_mul hW hj1 hD (Nat.cast_nonneg _)
    simpa only [Fintype.card_prod,Fintype.card_fin,Nat.cast_mul,Nat.cast_add,Nat.cast_one] using hh
  have hI : (Fintype.card (Fin (d+1)⊕(Fin (J+1)×CanonicalAmbientIndex states J)):ℝ)≤W^192 := by
    have hh := resource_add_same hW
      ((by simpa only [pow_one] using hd : (d:ℝ)+1≤W^1).trans (resource_pow_mono hW (show 1≤191 by norm_num))) hK
    simpa only [Fintype.card_sum,Fintype.card_fin,Nat.cast_add,Nat.cast_one] using hh
  have hp := (long_precision_primitive_resources P hW hH hr hG).1
  refine ⟨hc,hD,hK,hI,fun j=>(hfloor j).trans ?_⟩
  exact resource_mul hW (a:=1) (by simpa only [pow_one] using hH) hp (by linarith [physicalPartialGainBound_pos P])

#print axioms long_prefix_geometric_resources
end ConditionalNonpolynomial.Analytic.PhysicalLong
