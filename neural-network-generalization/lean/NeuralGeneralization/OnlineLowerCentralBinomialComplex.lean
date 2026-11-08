import Mathlib.Analysis.SpecialFunctions.Log.Summable
import Mathlib.Analysis.Complex.LocallyUniformLimit
import Mathlib.Analysis.PSeries
import Mathlib.Tactic

/-! # Holomorphic central-binomial normalization from an elementary product

The logarithmic series avoids any appeal to a complex Stirling formula.
-/

noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

def centralBinomialDomain : Set ℂ := {z | 0 < z.re ∧ 2 < ‖z‖}
def centralBinomialShift (z : ℂ) (j : ℕ) : ℂ := z + (2*(j:ℂ)+1)
def centralBinomialLogTerm (j : ℕ) (z : ℂ) : ℂ :=
  Complex.log (1 - (centralBinomialShift z j)⁻¹ ^ 2)
def centralBinomialLog (z : ℂ) : ℂ := -(1/2:ℂ) * ∑' j, centralBinomialLogTerm j z
def centralBinomialHolomorphic (z : ℂ) : ℂ := Complex.exp (centralBinomialLog z)

theorem halfplane_norm_add_real {z : ℂ} (hz : 0≤z.re) {x : ℝ} (hx : 0≤x) :
    ‖z‖ ≤ ‖z+(x:ℂ)‖ ∧ x≤‖z+(x:ℂ)‖ ∧
      (‖z‖+x)/2≤‖z+(x:ℂ)‖ := by
  have hsq : ‖z+(x:ℂ)‖^2=‖z‖^2+2*x*z.re+x^2 := by
    simp only [← Complex.normSq_eq_norm_sq,Complex.normSq_apply,Complex.add_re,
      Complex.add_im,Complex.ofReal_re,Complex.ofReal_im,add_zero]
    ring
  have h1 : ‖z‖≤‖z+(x:ℂ)‖ := by nlinarith [norm_nonneg z,norm_nonneg (z+(x:ℂ)),mul_nonneg hx hz]
  have h2 : x≤‖z+(x:ℂ)‖ := by nlinarith [norm_nonneg z,norm_nonneg (z+(x:ℂ)),mul_nonneg hx hz]
  exact ⟨h1,h2,by linarith⟩

theorem centralBinomialShift_norm_bounds {z : ℂ} (hz : 0≤z.re) (j : ℕ) :
    ‖z‖≤‖centralBinomialShift z j‖ ∧ (j:ℝ)+1≤‖centralBinomialShift z j‖ := by
  have h := halfplane_norm_add_real hz (show (0:ℝ)≤2*j+1 by positivity)
  have he : z+Complex.ofReal (2*(j:ℝ)+1)=centralBinomialShift z j := by simp [centralBinomialShift]
  rw [he] at h
  exact ⟨h.1,by nlinarith [Nat.cast_nonneg (α:=ℝ) j]⟩

theorem summable_inverse_square_nat_shift : Summable (fun j:ℕ => 1/((j:ℝ)+1)^2) := by
  have h := (summable_nat_add_iff 1).mpr (Real.summable_one_div_nat_pow.mpr (by norm_num : 1<2))
  simpa using h

theorem centralBinomialInverse_norm_le {z : ℂ} (hz : 0≤z.re) (j : ℕ) :
    ‖(centralBinomialShift z j)⁻¹^2‖ ≤ 1/((j:ℝ)+1)^2 := by
  rw [norm_pow,norm_inv,inv_pow,← one_div]
  exact one_div_le_one_div_of_le (by positivity) (pow_le_pow_left₀ (by positivity)
    (centralBinomialShift_norm_bounds hz j).2 2)

theorem summable_centralBinomialInverse {z : ℂ} (hz : 0≤z.re) :
    Summable (fun j => (centralBinomialShift z j)⁻¹^2) :=
  summable_inverse_square_nat_shift.of_norm_bounded (centralBinomialInverse_norm_le hz)

theorem summable_centralBinomialLogTerm {z : ℂ} (hz : 0≤z.re) :
    Summable (fun j => centralBinomialLogTerm j z) := by
  simpa [centralBinomialLogTerm,sub_eq_add_neg] using
    Complex.summable_log_one_add_of_summable (summable_centralBinomialInverse hz).neg

theorem centralBinomialInverse_norm_lt_quarter {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    ‖(centralBinomialShift z j)⁻¹^2‖ < (1:ℝ)/4 := by
  have h := (centralBinomialShift_norm_bounds hz.1.le j).1
  rw [norm_pow,norm_inv,inv_pow,← one_div]
  apply one_div_lt_one_div_of_lt (by norm_num : (0:ℝ)<4)
  nlinarith [hz.2]

theorem centralBinomialLogTerm_norm_bound {z : ℂ} (hz : z∈centralBinomialDomain) (j : ℕ) :
    ‖centralBinomialLogTerm j z‖ ≤ 2/((j:ℝ)+1)^2 := by
  have hq := centralBinomialInverse_norm_lt_quarter hz j
  have h := Complex.norm_log_one_add_half_le_self
    (z := -(centralBinomialShift z j)⁻¹^2) (by rw [norm_neg]; linarith)
  simp only [← sub_eq_add_neg,norm_neg] at h
  have hb := centralBinomialInverse_norm_le hz.1.le j
  unfold centralBinomialLogTerm
  have he : 2/((j:ℝ)+1)^2 = 2*(1/((j:ℝ)+1)^2) := by ring
  rw [he]
  nlinarith [norm_nonneg ((centralBinomialShift z j)⁻¹^2)]

theorem isOpen_centralBinomialDomain : IsOpen centralBinomialDomain :=
  (isOpen_lt continuous_const Complex.continuous_re).inter (isOpen_lt continuous_const continuous_norm)

theorem differentiableOn_centralBinomialLogTerm (j : ℕ) :
    DifferentiableOn ℂ (centralBinomialLogTerm j) centralBinomialDomain := by
  intro z hz
  have hn : centralBinomialShift z j ≠ 0 := by
    have h := (centralBinomialShift_norm_bounds hz.1.le j).2
    intro he
    rw [he,norm_zero] at h
    have := Nat.cast_nonneg (α:=ℝ) j
    linarith
  have hd : DifferentiableAt ℂ (fun z => 1-(centralBinomialShift z j)⁻¹^2) z := by
    dsimp [centralBinomialShift] at hn ⊢
    fun_prop
  have hslit : 1-(centralBinomialShift z j)⁻¹^2 ∈ Complex.slitPlane := by
    apply Complex.mem_slitPlane_iff.mpr
    left
    have hq := centralBinomialInverse_norm_lt_quarter hz j
    have hr := Complex.re_le_norm ((centralBinomialShift z j)⁻¹^2)
    simp only [Complex.sub_re,Complex.one_re]
    linarith
  exact ((Complex.differentiableAt_log hslit).comp z hd).differentiableWithinAt

theorem differentiableOn_centralBinomialLog :
    DifferentiableOn ℂ centralBinomialLog centralBinomialDomain := by
  have hsum : Summable (fun j:ℕ => 2/((j:ℝ)+1)^2) := by
    simpa [div_eq_mul_inv] using summable_inverse_square_nat_shift.mul_left 2
  have ht := Complex.differentiableOn_tsum_of_summable_norm hsum
    differentiableOn_centralBinomialLogTerm isOpen_centralBinomialDomain
    (fun j z hz => centralBinomialLogTerm_norm_bound hz j)
  exact ht.const_mul _

theorem differentiableOn_centralBinomialHolomorphic :
    DifferentiableOn ℂ centralBinomialHolomorphic centralBinomialDomain :=
  differentiableOn_centralBinomialLog.cexp

end NeuralGeneralization.OnlineLowerTanh
