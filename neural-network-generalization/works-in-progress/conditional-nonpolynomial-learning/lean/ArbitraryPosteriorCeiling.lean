import ClosedConditionalImpossibility
import ArbitraryCeilingBridge

/-! The posterior circuit ceiling for every beta in (0,1), for every actual
positive scale, and every sample length up to the prescribed budget. No
teacher, denominator, structural-circuit, or rate premise remains in the
closed endpoint. The common class does not depend on beta, width or scale. -/
noncomputable section
open scoped BigOperators
attribute [local instance] Classical.propDecidable
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial
open NeuralGeneralization.ConcreteModel

def ArbitraryPosteriorCeiling : Prop :=
  ∃ b : CeilingConstants, ∀ d n r : ℕ, 1≤d → 1≤n →
    b.padding*Nat.log2 (ceilingResource d n r)≤r+2 →
    ∀ m : ℕ, m≤n → ∀ N : ℕ, ∀ β t : ℝ, 0<β → β<1 → 0<t → t≤1 →
    (2:ℝ)^(b.width*d)*(ceilingResource d n r:ℝ)^b.width+
      (b.width:ℝ)*(r+1)*Real.log (1/β)≤N →
    ∀ f : BooleanFunction d, ∀ sample : Fin m→Cube d,
    1-β≤∑ g, if g∈ceilingClass b d n r then
      networkPosterior Real.tanh (1/2) (smallPrior d N r (t/Real.sqrt N)) f sample g else 0

namespace Analytic
theorem arbitraryPosteriorCeiling_of_uniform_path_circuits
    (hstruct : UniformPathCircuitBound) : ArbitraryPosteriorCeiling := by
  obtain ⟨W,hW,C,hC,hdenom⟩ := exists_uniform_memorizer_denominator_constants
  obtain ⟨P,K,hP,hK,hpath⟩ := hstruct (2*C+24) (by linarith)
  let p : ℕ := ⌈2*C+260⌉₊+2
  let padding : ℕ := P+⌈2*(6656*targetProgramConstant)+2⌉₊+2
  let width : ℕ := W+20*p+20+1
  let b : CeilingConstants := ⟨padding,width,K,by dsimp [padding]; omega,
    by dsimp [width]; omega,by omega⟩
  refine ⟨b,?_⟩
  intro d n r hd hn hpad m hmn N β t hβ hβ1 ht ht1 hwidth f sample
  let R : ℕ := ceilingResource d n r
  have hR : 2≤R := by dsimp [R,ceilingResource]; omega
  have hRreal : (2:ℝ)≤R := by exact_mod_cast hR
  have hR1 : (1:ℝ)≤R := by linarith
  have hR0 : (0:ℝ)<R := by linarith
  have hdR : (d:ℝ)+1≤R := by exact_mod_cast (show d+1≤R by dsimp [R,ceilingResource]; omega)
  have hnR : (m:ℝ)≤R := by exact_mod_cast (show m≤R by dsimp [R,ceilingResource]; omega)
  have hrR : (r:ℝ)+1≤R := by exact_mod_cast (show r+1≤R by dsimp [R,ceilingResource]; omega)
  have hw1 : 1≤width := by dsimp [width]; omega
  have hwW : W≤width := by dsimp [width]; omega
  have hw20 : 20≤width := by dsimp [width]; omega
  have hwp : 20*p≤width := by dsimp [width]; omega
  have hr : 1≤r := by
    have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
    have hp3 : 3≤padding := by dsimp [padding]; omega
    change padding*Nat.log2 R≤r+2 at hpad
    nlinarith
  have hlog0 : 0≤Real.log (1/β) := Real.log_nonneg ((one_le_div hβ).mpr hβ1.le)
  have hwidebase : (2:ℝ)^(width*d)*(R:ℝ)^width≤N := by
    change (2:ℝ)^(width*d)*(R:ℝ)^width+(width:ℝ)*(r+1)*Real.log (1/β)≤N at hwidth
    exact (le_add_of_nonneg_right (by positivity)).trans hwidth
  have hN : 0<N := by
    have hh : (0:ℝ)<N := lt_of_lt_of_le (by positivity) hwidebase
    exact_mod_cast hh
  have hNreal : (0:ℝ)<N := by exact_mod_cast hN
  have ht0 : 0<t := ht
  have htone : t≤1 := ht1
  have hscaleeq : Real.sqrt N*(t/Real.sqrt N)=t := by
    field_simp [(Real.sqrt_pos.mpr hNreal).ne']
  let A := denominatorBudget C t (R:ℝ) r
  let τ := 1/(t^2*(r:ℝ))
  let U := (2*C+260)*(R:ℝ)^2
  have hA : 0≤A := denominatorBudget_nonneg hC.le ht0 htone hRreal
  have hτ : 0<τ := by dsimp [τ]; positivity
  have hU : 0<U := by dsimp [U]; positivity
  have hrpos : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hpadreal : 2*(6656*targetProgramConstant)+2≤(padding:ℝ) := by
    have hh := Nat.le_ceil (2*(6656*targetProgramConstant)+2)
    dsimp [padding]
    push_cast
    linarith [Nat.cast_nonneg P (α:=ℝ)]
  have htargetpos : 0≤6656*targetProgramConstant := by
    have hh := targetProgramConstant_ge
    positivity
  have hlogdepth : 6656*targetProgramConstant*Real.log (R:ℝ)≤(r:ℝ) :=
    padding_real_log hR htargetpos hpadreal hpad
  have hdenomwidth : (2:ℝ)^d*(R:ℝ)^W≤N := by
    apply le_trans ?_ hwidebase
    apply mul_le_mul
    · exact pow_le_pow_right₀ (by norm_num) (by nlinarith)
    · exact pow_le_pow_right₀ hR1 hwW
    · positivity
    · positivity
  have hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2)
      (smallPrior d N r (t/Real.sqrt N)) f sample :=
    hdenom d m r N sample f (R:ℝ) t hd hr hRreal hdR hnR hrR ht0 htone hlogdepth hdenomwidth
  have hNorm : t^2*(A+2*τ)≤U := by
    have hh := denominatorBudget_normalized hC.le ht0 htone hr hRreal hrR
    simpa only [A,τ,U,mul_one_div] using hh
  have hslack : 1≤t^2*τ*(r:ℝ) := by
    dsimp [τ]
    have htne : t≠0 := ht0.ne'
    have hrne : (r:ℝ)≠0 := hrpos.ne'
    field_simp
    norm_num
  have hp1 : 1≤p := by dsimp [p]; omega
  have hUp : U≤(R:ℝ)^p := by
    have hc := positive_constant_power (by linarith : 0≤2*C+260) hRreal
    have hh := mul_le_mul_of_nonneg_right hc (sq_nonneg (R:ℝ))
    simpa only [U,p,pow_add] using hh
  have hRp : (R:ℝ)≤(R:ℝ)^p := by
    simpa only [pow_one] using pow_le_pow_right₀ hR1 hp1
  have hHpow : ((r+1:ℕ):ℝ)≤(R:ℝ)^p := by
    have hh : ((r+1:ℕ):ℝ)≤R := by exact_mod_cast (show r+1≤R by dsimp [R,ceilingResource]; omega)
    exact hh.trans hRp
  have hwcert := normalizedMarginWidth_power d r p hRreal hp1 hU hrpos hUp
    ((by linarith : (r:ℝ)≤R).trans hRp)
    hHpow
  have hwidthcert : normalizedCertificateWidth d r U r (normalizedRepairLog d r U r)≤N := by
    apply hwcert.trans
    apply le_trans ?_ hwidebase
    apply mul_le_mul
    · exact pow_le_pow_right₀ (by norm_num) (by nlinarith)
    · exact pow_le_pow_right₀ hR1 hwp
    · positivity
    · positivity
  have hlogwidth : (r:ℝ)*Real.log (1/β)≤N := by
    have hwR : (1:ℝ)≤width := by exact_mod_cast hw1
    have hrR0 : (0:ℝ)≤r := Nat.cast_nonneg _
    have hh : (r:ℝ)≤(width:ℝ)*(r+1) := by nlinarith
    have hl := mul_le_mul_of_nonneg_right hh hlog0
    change (2:ℝ)^(width*d)*(R:ℝ)^width+(width:ℝ)*(r+1)*Real.log (1/β)≤N at hwidth
    exact hl.trans ((le_add_of_nonneg_left (by positivity)).trans hwidth)
  have hlog := posterior_ceiling_log_slack_beta hr hN ht0 htone hβ hβ1.le hlogwidth
  have hclass : ∀g : BooleanFunction d,
      ∀path : ControlledMarginPath d (r+1) t g,path.action≤A+3*τ→g∈ceilingClass b d n r := by
    intro g path ha
    have hb := denominatorBudget_shift_depth hC.le ht0 htone hr hRreal
    have hct := subcriticalCostBaseline_nonneg (t^2).toNNReal
      (Real.toNNReal_pos.mpr (sq_pos_of_pos ht0)).ne'
    have haction : path.action≤((r+1:ℕ):ℝ)*subcriticalCostBaseline (t^2).toNNReal+
        scalarBaseline.toReal+(2*C+24)*(((t^2)⁻¹-1)*Real.log (R:ℝ)+
          (Real.log (R:ℝ))^2/((r+1:ℕ):ℝ)) := by
      dsimp [A,τ] at ha
      push_cast
      have hh : 3*(1/(t^2*(r:ℝ)))=3/(t^2*(r:ℝ)) := by ring
      rw [hh] at ha
      linarith
    have hpadpath : P*Nat.log2 R≤r+1 := by
      have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
      have hpp : P+2≤padding := by dsimp [padding]; omega
      dsimp only [b] at hpad
      nlinarith
    obtain ⟨c,hs,hdepth,heval⟩ := hpath d (r+1) R hd (by omega) hR
      (by dsimp [R,ceilingResource]; omega) hpadpath t ht0 htone g path haction
    exact ⟨c,hs,hdepth,heval⟩
  have hfinal := posterior_ceiling_of_margin_path_class_beta (by omega : 0<d) hN
    (div_pos ht0 (Real.sqrt_pos.mpr hNreal)) (by rw [hscaleeq]; exact htone)
    hA hτ hβ hβ1.le f sample (ceilingClass b d n r) hZ hlog
    (by rw [hscaleeq]; exact hNorm) (by rw [hscaleeq]; exact hslack) hwidthcert
    (by rw [hscaleeq]; exact hclass)
  exact hfinal

end Analytic

theorem arbitraryPosteriorCeiling : ArbitraryPosteriorCeiling :=
  Analytic.arbitraryPosteriorCeiling_of_uniform_path_circuits uniformPathCircuitBound

/-- Conversion to the natural-logarithm convention printed in the paper. -/
theorem log2_le_twice_real_log {R : ℕ} (hR : 2≤R) :
    (Nat.log2 R:ℝ)≤2*Real.log (R:ℝ) := by
  have hp : (2:ℝ)^Nat.log2 R≤R := by
    have hn := Nat.pow_log_le_self 2 (show R≠0 by omega)
    simpa only [Nat.log2_eq_log_two] using (show (2:ℝ)^Nat.log 2 R≤R by exact_mod_cast hn)
  have hl := Real.log_le_log (by positivity : (0:ℝ)<(2:ℝ)^Nat.log2 R) hp
  rw [Real.log_pow] at hl
  have hhalf : (1/2:ℝ)≤Real.log 2 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<1/2)
    rw [Real.log_div (by norm_num) (by norm_num), Real.log_one] at hh
    norm_num at hh
    linarith
  have hh := mul_le_mul_of_nonneg_left hhalf (Nat.cast_nonneg (Nat.log2 R) (α:=ℝ))
  linarith

def paperCeilingClass (k d R : ℕ) : Set (BooleanFunction d) :=
  {g | ∃c : ThresholdCircuit d, c.size≤R^k ∧ (c.depth:ℝ)≤k*Real.log R ∧ c.eval=g}

/-- Literal natural-logarithm, arbitrary-beta posterior circuit ceiling.
The constants precede all resource, sample, width, and scale choices. The
class is common even to all sample lengths m<=n, including m=0. -/
theorem posterior_circuit_ceiling_all_beta :
    ∃ b c₀ c₁ : ℕ, 0<b ∧ 0<c₀ ∧ 0<c₁ ∧
    ∀ d n r : ℕ, 1≤d → 1≤n →
      (c₀:ℝ)*Real.log (ceilingResource d n r)≤r+2 →
    ∀ m : ℕ, m≤n → ∀ N : ℕ, ∀ β t : ℝ,
      0<β → β<1 → 0<t → t≤1 →
      (2:ℝ)^(c₁*d)*(ceilingResource d n r:ℝ)^c₁+
        (c₁:ℝ)*(r+1)*Real.log (1/β)≤N →
    ∀ f : BooleanFunction d, ∀ sample : Fin m→Cube d,
      1-β≤∑ g, if g∈paperCeilingClass b d (ceilingResource d n r) then
        networkPosterior Real.tanh (1/2) (smallPrior d N r (t/Real.sqrt N)) f sample g else 0 := by
  obtain ⟨b,h⟩ := arbitraryPosteriorCeiling
  refine ⟨2*b.circuit,2*b.padding,b.width,Nat.mul_pos (by decide) b.circuit_pos,Nat.mul_pos (by decide) b.padding_pos,b.width_pos,?_⟩
  intro d n r hd hn hpad m hmn N β t hβ hβ1 ht ht1 hwidth f sample
  have hR : 2≤ceilingResource d n r := by unfold ceilingResource; omega
  have hlog := log2_le_twice_real_log hR
  have hpad' : b.padding*Nat.log2 (ceilingResource d n r)≤r+2 := by
    have hh := mul_le_mul_of_nonneg_left hlog (Nat.cast_nonneg b.padding (α:=ℝ))
    have hh' : (b.padding:ℝ)*Nat.log2 (ceilingResource d n r)≤(r:ℝ)+2 := by
      push_cast at hpad
      nlinarith
    exact_mod_cast hh'
  have hsmall := h d n r hd hn hpad' m hmn N β t hβ hβ1 ht ht1 hwidth f sample
  apply hsmall.trans
  apply Finset.sum_le_sum
  intro g _
  by_cases hg : g∈ceilingClass b d n r
  · have hlarge : g∈paperCeilingClass (2*b.circuit) d (ceilingResource d n r) := by
      obtain ⟨c,hs,hdc,he⟩ := hg
      refine ⟨c,hs.trans (Nat.pow_le_pow_right (by omega) (by omega)),?_,he⟩
      have hh : (c.depth:ℝ)≤b.circuit*Nat.log2 (ceilingResource d n r) := by exact_mod_cast hdc
      have hh' := mul_le_mul_of_nonneg_left hlog (Nat.cast_nonneg b.circuit (α:=ℝ))
      push_cast
      nlinarith
    simp only [if_pos hg,if_pos hlarge,le_refl]
  · simp only [if_neg hg]
    split_ifs
    · unfold networkPosterior NeuralGeneralization.posterior NeuralGeneralization.normalizer
      apply div_nonneg
      · split_ifs
        · exact functionMass_nonneg _ _ _ _
        · exact le_refl _
      · apply Finset.sum_nonneg
        intro g _
        split_ifs
        · exact functionMass_nonneg _ _ _ _
        · exact le_refl _
    · exact le_refl _

#print axioms arbitraryPosteriorCeiling
#print axioms posterior_circuit_ceiling_all_beta
end ConditionalNonpolynomial
