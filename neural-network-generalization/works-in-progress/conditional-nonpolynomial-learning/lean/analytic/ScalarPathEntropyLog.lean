import ChannelEntropyPolynomial
import CriticalLogResources
import TargetPolynomialFloor

noncomputable section
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def scalarPathEntropyLogConstant (C : ℝ) : ℝ :=
  2*(Real.sqrt (526337*C+4*526336)+3*(1+1/Real.log 2)*dyadicBlockConstant 526336)

theorem scalarPathEntropyLogConstant_nonneg (C : ℝ) : 0≤scalarPathEntropyLogConstant C := by
  have hl : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hb : 0≤dyadicBlockConstant 526336 := Real.sqrt_nonneg _
  unfold scalarPathEntropyLogConstant
  positivity

theorem ScalarChannelPath.entropy_prefix_log_bound {v r C R : ℝ}
    (p : ScalarChannelPath v r) (hinit : v+r≤1) (hC : 0≤C) (hR : 2≤R)
    (hH : 0<p.length) (hHR : (p.length:ℝ)+1≤R)
    (hcost : p.cost≤scalarBaseline.toReal+C*(Real.log R)^2/(p.length:ℝ)) :
    channelEntropyPrefix (fun j=>(klDiv (p.control j) (gaussianReal 0 1)).toReal) p.length≤
      scalarPathEntropyLogConstant C*Real.log R := by
  let ε := C*(Real.log R)^2/(p.length:ℝ)
  have hε : 0≤ε := by dsimp [ε]; positivity
  have hh := p.sqrt_entropy_bound hinit hε hcost
  have hl : 1/2≤Real.log R := logarithm_half_le hR
  have hH0 : (0:ℝ)<p.length := by exact_mod_cast hH
  have he : (p.length:ℝ)*ε=C*(Real.log R)^2 := by dsimp [ε]; field_simp
  have hroot : Real.sqrt (526337*(p.length:ℝ)*ε+526336)≤
      Real.sqrt (526337*C+4*526336)*Real.log R := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · rw [mul_pow,Real.sq_sqrt (by positivity : 0≤526337*C+4*526336)]
      have hs : 1/4≤(Real.log R)^2 := by nlinarith
      have hm : 526337*(p.length:ℝ)*ε=526337*C*(Real.log R)^2 := by nlinarith [he]
      rw [hm]
      nlinarith
  have hj := nat_log2_log_envelope (show 1≤p.length+1 by omega)
    (by simpa using hHR) hR
  have hL : 0≤1+1/Real.log 2 := by positivity
  have hd : 0≤dyadicBlockConstant 526336 := Real.sqrt_nonneg _
  have hdyad : ((Nat.log2 (p.length+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336≤
      3*(1+1/Real.log 2)*dyadicBlockConstant 526336*Real.log R := by
    have hprod := mul_le_mul_of_nonneg_right hj hd
    have hc : 1+Real.log R≤3*Real.log R := by linarith
    have hb := mul_le_mul_of_nonneg_left hc (mul_nonneg hL hd)
    nlinarith
  have hprefix := channelEntropyPrefix_le_twice
    (fun j=>(klDiv (p.control j) (gaussianReal 0 1)).toReal) p.length
  calc
    _ ≤ 2*∑j∈Finset.range p.length,Real.sqrt ((klDiv (p.control j) (gaussianReal 0 1)).toReal) := hprefix
    _ ≤ 2*(Real.sqrt (526337*(p.length:ℝ)*ε+526336)+
        ((Nat.log2 (p.length+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336) :=
      mul_le_mul_of_nonneg_left hh (by norm_num)
    _ ≤ 2*(Real.sqrt (526337*C+4*526336)*Real.log R+
        3*(1+1/Real.log 2)*dyadicBlockConstant 526336*Real.log R) := by
      gcongr
    _ = _ := by unfold scalarPathEntropyLogConstant; ring

#print axioms ScalarChannelPath.entropy_prefix_log_bound
end ConditionalNonpolynomial.Analytic
