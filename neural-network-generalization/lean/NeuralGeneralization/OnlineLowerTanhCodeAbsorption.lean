import NeuralGeneralization.OnlineLowerTanhCodeSupport
import Mathlib.Tactic.GCongr

/-!
# Exact weighted norm from global localization and local vanishing

This is the finite, quantitative absorption step of the ordinary-tanh code
argument. Its hypotheses are explicit bounds on a chosen actual support; no
asymptotic or analytic fact is added as an axiom. The localization and local
vanishing modules must discharge those hypotheses before it is used in the
final unconditional code theorem.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerTanh

/-- If the off-support mass is initially tiny, global support stability puts
it in the local regime, where quadratic vanishing absorbs it into half of
the selected-support deficit. All constants and smallness conditions are
explicit and multiplicative. -/
theorem code_half_absorption (r S M ε ρ v δ E : ℝ)
    (hr : 0 < r) (hS : 0 < S) (hM : r ≤ M)
    (hε : 0 ≤ ε) (hv : 0 ≤ v) (hδ : 0 ≤ δ) (hE : 0 ≤ E)
    (hsupport : v ≤ S*r*δ) (hoff : E ≤ ε*r)
    (hbootstrap : 2*S*ε*M^2 ≤ ρ^2)
    (hlocal : v ≤ ρ^2 → 2*S*M*E ≤ v) :
    2*E ≤ δ := by
  by_cases hgood : 2*E ≤ δ
  · exact hgood
  · have hbad : δ < 2*E := lt_of_not_ge hgood
    have hr0 := hr.le
    have hS0 := hS.le
    have hM0 : 0 ≤ M := hr0.trans hM
    have hsr : 0 < S*r := mul_pos hS hr
    have hnear : v ≤ ρ^2 := by
      calc
        v ≤ S*r*δ := hsupport
        _ ≤ S*r*(2*E) := mul_le_mul_of_nonneg_left hbad.le hsr.le
        _ ≤ S*r*(2*(ε*r)) := by gcongr
        _ = 2*S*ε*r^2 := by ring
        _ ≤ 2*S*ε*M^2 := by gcongr
        _ ≤ ρ^2 := hbootstrap
    have hl := hlocal hnear
    have hm : 2*S*r*E ≤ 2*S*M*E := by gcongr
    have hh : (S*r)*(2*E) ≤ (S*r)*δ := by nlinarith
    exact (mul_le_mul_iff_right₀ hsr).mp hh

/-- Numerical consequence after writing the exact total-code deficit as
selected deficit minus off-support mass. -/
theorem code_norm_and_support_of_absorption (r S δ E v Q : ℝ)
    (hr : 0 ≤ r) (hS : 0 ≤ S) (hδ : 0 ≤ δ)
    (habsorb : 2*E ≤ δ) (hidentity : r-Q = δ-E)
    (hsupport : v ≤ S*r*δ) :
    Q ≤ r ∧ v ≤ 2*S*r*(r-Q) := by
  constructor
  · linarith
  · have hd : δ ≤ 2*(r-Q) := by linarith
    have hm := mul_le_mul_of_nonneg_left hd (mul_nonneg hS hr)
    nlinarith

/-- Finite weighted masses have the deficit identity used by absorption. -/
theorem code_deficit_identity {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (j : ι) (hj : j ∈ s) (mass : ι → ℝ) (r : ℝ) :
    r - (∑ i ∈ s, mass i) =
      (r - mass j) - (∑ i ∈ s.erase j, mass i) := by
  rw [← Finset.add_sum_erase s mass hj]
  ring

/-- An exact weighted code norm follows after all its analytic hypotheses
have been supplied. The coefficient is the literal physical tanh coefficient. -/
theorem physical_code_norm_of_localization {d : ℕ}
    (C : Finset (Finset (Fin d))) (weight : Finset (Fin d) → ℝ)
    (u : Fin d → ℝ) (b S M ε ρ : ℝ)
    (A : Finset (Fin d)) (hAC : A ∈ C)
    (hS : 0 < S) (hε : 0 ≤ ε)
    (hweight : ∀ B ∈ C, 0 ≤ weight B)
    (hsharp : IntrinsicParityBound A.card (weight A)) (hodd : Odd A.card)
    (hr : 0 < Real.sqrt (b^2 + incomingEnergy u))
    (hM : Real.sqrt (b^2 + incomingEnergy u) ≤ M)
    (hSbig : max 2 (288*(weight A)^2) ≤ S)
    (hoff : (∑ B ∈ C.erase A,
        weight B * |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B|) ≤
      ε * Real.sqrt (b^2 + incomingEnergy u))
    (hbootstrap : 2*S*ε*M^2 ≤ ρ^2)
    (hlocal : b^2 + (∑ i ∈ Aᶜ, u i^2) ≤ ρ^2 →
      2*S*M*(∑ B ∈ C.erase A,
        weight B * |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B|) ≤
        b^2 + (∑ i ∈ Aᶜ, u i^2)) :
    let r := Real.sqrt (b^2 + incomingEnergy u)
    let Q := ∑ B ∈ C,
      weight B * |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B|
    Q ≤ r ∧ b^2 + (∑ i ∈ Aᶜ, u i^2) ≤ 2*S*r*(r-Q) := by
  let r := Real.sqrt (b^2 + incomingEnergy u)
  let mass := fun B => weight B *
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B|
  let δ := r - mass A
  let E := ∑ B ∈ C.erase A, mass B
  let v := b^2 + (∑ i ∈ Aᶜ, u i^2)
  have hs := intrinsicParityBound_physical_support A hodd (weight A)
    (hweight A hAC) hsharp u b
  change mass A ≤ r ∧ v ≤ max 2 (288*(weight A)^2)*r*(r-mass A) at hs
  have hδ : 0 ≤ δ := sub_nonneg.mpr hs.1
  have hv : 0 ≤ v := add_nonneg (sq_nonneg _) (Finset.sum_nonneg fun _ _ => sq_nonneg _)
  have hE : 0 ≤ E := Finset.sum_nonneg (fun B hB =>
    mul_nonneg (hweight B (Finset.mem_of_mem_erase hB)) (abs_nonneg _))
  have hs' : v ≤ S*r*δ := by
    apply hs.2.trans
    change max 2 (288*(weight A)^2)*r*δ ≤ S*r*δ
    gcongr
  have habsorb := code_half_absorption r S M ε ρ v δ E hr hS hM hε hv hδ hE
    hs' hoff hbootstrap hlocal
  exact code_norm_and_support_of_absorption r S δ E v (∑ B ∈ C, mass B)
    hr.le hS.le hδ habsorb (code_deficit_identity C A hAC mass r) hs'

end NeuralGeneralization.OnlineLowerTanh
