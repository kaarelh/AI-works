import NeuralGeneralization.OnlineLowerCentralBinomialExpansion
import NeuralGeneralization.OnlineLowerTanhScalarBounds
import Mathlib.Analysis.Real.Pi.Wallis

/-! Identification of the holomorphic product with the actual odd-degree
central-binomial normalization. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

def wallisSmallFactor (j : ℕ) : ℝ := 1-1/(2*(j:ℝ)+2)^2

theorem wallisSmallFactor_pos (j : ℕ) : 0<wallisSmallFactor j := by
  unfold wallisSmallFactor
  have hj : (0:ℝ)≤j := Nat.cast_nonneg j
  have hp : 0<(2*(j:ℝ)+2)^2 := by positivity
  have hh : 1/(2*(j:ℝ)+2)^2<1 := (div_lt_one hp).mpr (by nlinarith)
  linarith

theorem wallisSmallFactor_inverse (j : ℕ) :
    (wallisSmallFactor j)⁻¹ =
      (2*(j:ℝ)+2)/(2*j+1)*((2*j+2)/(2*j+3)) := by
  have he : wallisSmallFactor j=(2*(j:ℝ)+1)*(2*j+3)/(2*j+2)^2 := by
    unfold wallisSmallFactor
    field_simp
    ring
  rw [he,inv_div]
  field_simp

theorem wallisSmallFactor_partial_product (n : ℕ) :
    (∏j∈Finset.range n,(wallisSmallFactor j)⁻¹)=Real.Wallis.W n := by
  simp only [wallisSmallFactor_inverse,Real.Wallis.W]

theorem wallisSmallFactor_partial_tail (r n : ℕ) :
    (∏j∈Finset.range n,(wallisSmallFactor (r+j))⁻¹)=Real.Wallis.W (r+n)/Real.Wallis.W r := by
  have h := Finset.prod_range_add (fun j => (wallisSmallFactor j)⁻¹) r n
  rw [wallisSmallFactor_partial_product,wallisSmallFactor_partial_product] at h
  apply (eq_div_iff (Real.Wallis.W_pos r).ne').mpr
  rw [h]
  ring

theorem centralBinomialLogTerm_odd (r j : ℕ) :
    centralBinomialLogTerm j (2*(r:ℂ)+1)=
      Complex.ofReal (Real.log (wallisSmallFactor (r+j))) := by
  rw [Complex.ofReal_log (wallisSmallFactor_pos _).le]
  congr 1
  simp [centralBinomialLogTerm,centralBinomialShift,wallisSmallFactor]
  congr 2
  ring

theorem summable_wallisSmallFactor_log_tail (r : ℕ) :
    Summable (fun j => Real.log (wallisSmallFactor (r+j))) := by
  apply Complex.summable_ofReal.mp
  have h := summable_centralBinomialLogTerm
    (z:=2*(r:ℂ)+1) (by simp; positivity)
  simpa only [centralBinomialLogTerm_odd] using h

theorem wallis_tail_exp_log_sum (r : ℕ) :
    Real.exp (-(∑'j,Real.log (wallisSmallFactor (r+j)))) =
      (Real.pi/2)/Real.Wallis.W r := by
  have hs := (summable_wallisSmallFactor_log_tail r).neg
  have hp := Real.hasProd_of_hasSum_log
    (fun j => inv_pos.mpr (wallisSmallFactor_pos (r+j)))
    (show HasSum (fun j => Real.log ((wallisSmallFactor (r+j))⁻¹))
      (-(∑'j,Real.log (wallisSmallFactor (r+j)))) by
        simpa only [Real.log_inv] using (summable_wallisSmallFactor_log_tail r).hasSum.neg)
  have hleft := hp.tendsto_prod_nat
  simp_rw [wallisSmallFactor_partial_tail] at hleft
  have ht := Real.Wallis.tendsto_W_nhds_pi_div_two.comp (tendsto_add_atTop_nat r)
  have hright := ht.div_const (Real.Wallis.W r)
  simp only [Nat.add_comm] at hright
  exact tendsto_nhds_unique hleft hright

theorem oddParityKappa_recurrence (r : ℕ) :
    (2*(r:ℝ)+2)*oddParityKappa (r+1)=(2*r+1)*oddParityKappa r := by
  rw [oddParityKappa_eq_twice_relu,oddParityKappa_eq_twice_relu]
  have h := OnlineLowerRelu.evenReluKappa_recurrence r
  nlinarith

theorem wallis_kappa_identity (r : ℕ) :
    Real.Wallis.W r*(2*(r:ℝ)+1)*oddParityKappa r^2=1 := by
  induction r with
  | zero => norm_num [Real.Wallis.W,oddParityKappa]
  | succ r ih =>
    have hr := oddParityKappa_recurrence r
    have hk : oddParityKappa (r+1)=(2*(r:ℝ)+1)*oddParityKappa r/(2*r+2) := by
      apply (eq_div_iff (by positivity : (2*(r:ℝ)+2)≠0)).mpr
      nlinarith
    rw [Real.Wallis.W_succ,hk]
    push_cast
    field_simp
    nlinarith [ih]

theorem centralBinomialHolomorphic_odd (r : ℕ) :
    centralBinomialHolomorphic (2*(r:ℂ)+1)=
      Complex.ofReal (oddParityKappa r*Real.sqrt (Real.pi*(2*(r:ℝ)+1)/2)) := by
  let S : ℝ := ∑'j,Real.log (wallisSmallFactor (r+j))
  have he : centralBinomialHolomorphic (2*(r:ℂ)+1)=Complex.ofReal (Real.exp (-(1/2:ℝ)*S)) := by
    unfold centralBinomialHolomorphic centralBinomialLog
    simp_rw [centralBinomialLogTerm_odd]
    rw [←Complex.ofReal_tsum]
    rw [Complex.ofReal_exp]
    congr 1
    dsimp [S]
    push_cast
    ring
  rw [he]
  congr 1
  have hexp : Real.exp (-(1/2:ℝ)*S)^2=(Real.pi/2)/Real.Wallis.W r := by
    rw [←Real.exp_nat_mul]
    norm_num only [Nat.cast_ofNat]
    have hh : (2:ℝ)*(-(1/2:ℝ)*S)=-S := by ring
    rw [hh]
    exact wallis_tail_exp_log_sum r
  have hid := wallis_kappa_identity r
  have hW := Real.Wallis.W_pos r
  have hk := oddParityKappa_pos r
  have hs : Real.sqrt (Real.pi*(2*(r:ℝ)+1)/2)^2=Real.pi*(2*r+1)/2 :=
    Real.sq_sqrt (by positivity)
  have htarget : (oddParityKappa r*Real.sqrt (Real.pi*(2*(r:ℝ)+1)/2))^2=
      (Real.pi/2)/Real.Wallis.W r := by
    rw [mul_pow,hs]
    apply (eq_div_iff hW.ne').mpr
    nlinarith [congrArg (fun t:ℝ => (Real.pi/2)*t) hid]
  have hp := Real.exp_pos (-(1/2:ℝ)*S)
  have hq : 0≤oddParityKappa r*Real.sqrt (Real.pi*(2*(r:ℝ)+1)/2) := by positivity
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
