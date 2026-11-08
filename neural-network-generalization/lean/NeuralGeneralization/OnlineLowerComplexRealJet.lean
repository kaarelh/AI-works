import Mathlib.Analysis.Complex.RealDeriv
import Mathlib.Analysis.Complex.CauchyIntegral
import Mathlib.Analysis.Calculus.IteratedDeriv.Lemmas
import Mathlib.Analysis.Calculus.IteratedDeriv.WithinZpow

/-! Higher real derivatives of the real part of a holomorphic function. -/
noncomputable section
open scoped Topology
open Complex Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma holomorphic_iteratedDeriv_differentiableOn {f:ℂ→ℂ} {U:Set ℂ}
    (hU:IsOpen U) (hf:DifferentiableOn ℂ f U) (j:ℕ) :
    DifferentiableOn ℂ (iteratedDeriv j f) U := by
  induction j with
  | zero => simpa only [iteratedDeriv_zero] using hf
  | succ j ih => rw [iteratedDeriv_succ]; exact ih.deriv hU

lemma iteratedDeriv_realPart {f:ℂ→ℂ} {U:Set ℂ}
    (hU:IsOpen U) (hf:DifferentiableOn ℂ f U) (j:ℕ) (u:ℝ) (hu:(u:ℂ)∈U) :
    iteratedDeriv j (fun x:ℝ=>(f (x:ℂ)).re) u=(iteratedDeriv j f (u:ℂ)).re := by
  induction j generalizing u with
  | zero => simp
  | succ j ih =>
    have he : iteratedDeriv j (fun x:ℝ=>(f (x:ℂ)).re) =ᶠ[𝓝 u]
        (fun x:ℝ=>(iteratedDeriv j f (x:ℂ)).re) := by
      filter_upwards [((hU.preimage Complex.continuous_ofReal).mem_nhds hu)] with x hx
      exact ih x hx
    have hd:=((holomorphic_iteratedDeriv_differentiableOn hU hf j).differentiableAt
      (hU.mem_nhds hu)).hasDerivAt.real_of_complex
    rw [iteratedDeriv_succ,he.deriv_eq,hd.deriv,iteratedDeriv_succ]

lemma iteratedDeriv_one_div_complex (j:ℕ) (z:ℂ) :
    iteratedDeriv j (fun w:ℂ=>1/w) z=(-1:ℂ)^j*(j.factorial:ℂ)/z^(j+1) := by
  have h:=iteratedDerivWithin_one_div (𝕜:=ℂ) (s:=univ) j isOpen_univ (Set.mem_univ z)
  rw [iteratedDerivWithin_univ] at h
  dsimp only at h
  rw [show (-1-(j:ℤ))=-((j+1:ℕ):ℤ) by omega,zpow_neg,zpow_natCast] at h
  simpa only [div_eq_mul_inv] using h

lemma iteratedDeriv_affine_complex (A B z:ℂ) (j:ℕ) (hj:2≤j) :
    iteratedDeriv j (fun w:ℂ=>A*w+B) z=0 := by
  have he : (fun w:ℂ=>A*w+B)=(fun w:ℂ=>B+A*w) := by funext w; ring
  rw [he,iteratedDeriv_const_add (by omega),iteratedDeriv_const_mul_field]
  have hid : iteratedDeriv j (fun w:ℂ=>w) z=0 := by
    have h:=iteratedDeriv_pow (x:=z) 1 j
    rw [Nat.descFactorial_eq_zero_iff_lt.mpr (by omega)] at h
    simpa only [pow_one,Nat.cast_zero,zero_mul] using h
  rw [hid,mul_zero]

lemma iteratedDeriv_affine_reciprocal (A B C z:ℂ) (hz:z≠0) (j:ℕ) (hj:2≤j) :
    iteratedDeriv j (fun w:ℂ=>A*w+B+C/w) z=
      C*((-1:ℂ)^j*(j.factorial:ℂ)/z^(j+1)) := by
  have hlin:ContDiffAt ℂ j (fun w:ℂ=>A*w+B) z := by fun_prop
  have hinv:ContDiffAt ℂ j (fun w:ℂ=>C/w) z := contDiffAt_const.div contDiffAt_id hz
  rw [iteratedDeriv_fun_add hlin hinv,iteratedDeriv_affine_complex A B z j hj,zero_add]
  rw [show (fun w:ℂ=>C/w)=(fun w:ℂ=>C*(1/w)) by funext w; ring,
    iteratedDeriv_const_mul_field,iteratedDeriv_one_div_complex]

end NeuralGeneralization.OnlineLowerTanh
