import NeuralGeneralization.BatchTwoNonGaussianFieldProduct

/-! Relative Lindeberg comparison for actual finite independent sums. -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open TanhDifferential

private theorem ratios_of_log_bound {u v B : ℝ} (hu : 0 < u) (hv : 0 < v)
    (h : |Real.log u - Real.log v| ≤ B) : u ≤ Real.exp B * v ∧ v ≤ Real.exp B * u := by
  obtain ⟨hlo, hhi⟩ := abs_le.mp h
  constructor
  · calc
      u = Real.exp (Real.log u) := (Real.exp_log hu).symm
      _ ≤ Real.exp (B + Real.log v) := Real.exp_le_exp.mpr (by linarith)
      _ = _ := by rw [Real.exp_add, Real.exp_log hv]
  · calc
      v = Real.exp (Real.log v) := (Real.exp_log hv).symm
      _ ≤ Real.exp (B + Real.log u) := Real.exp_le_exp.mpr (by linarith)
      _ = _ := by rw [Real.exp_add, Real.exp_log hu]

private theorem log_bound_of_ratios {u v B : ℝ} (hu : 0 < u) (hv : 0 < v)
    (h₁ : u ≤ Real.exp B * v) (h₂ : v ≤ Real.exp B * u) :
    |Real.log u - Real.log v| ≤ B := by
  have hh₁ := Real.log_le_log hu h₁
  have hh₂ := Real.log_le_log hv h₂
  rw [Real.log_mul (Real.exp_pos _).ne' hv.ne', Real.log_exp] at hh₁
  rw [Real.log_mul (Real.exp_pos _).ne' hu.ne', Real.log_exp] at hh₂
  exact abs_le.mpr ⟨by linarith, by linarith⟩

section Replace
variable {I J : Type*} [Fintype I] [Fintype J] [DecidableEq J]

/-- One-coordinate replacement after integrating an arbitrary independent residual.
The actual product law is retained on both sides. -/
theorem fieldPartition_update_log_bound (laws : J → CoordinateLaw) (ν : CoordinateLaw)
    (Γ : I → I → ℝ) (a : J → I → ℝ) (j : J) (G b : ℝ)
    (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b)
    (ha : ∀ i, |a j i| ≤ b) (hsmall : 2 * G * b ≤ 1) :
    |Real.log (fieldPartition (Function.update laws j ν) Γ a) -
        Real.log (fieldPartition laws Γ a)| ≤
      replacementConstant ν (laws j) * lindebergPolynomial G * b ^ 3 := by
  let B := replacementConstant ν (laws j) * lindebergPolynomial G * b ^ 3
  let μ := Measure.pi (fun k : {k : J // k ≠ j} => (laws k).law)
  let U : ({k : J // k ≠ j} → ℝ) → ℝ :=
    fun y => ∫ t, expPotential Γ (residualField a j y) (a j) t ∂ν.law
  let V : ({k : J // k ≠ j} → ℝ) → ℝ :=
    fun y => ∫ t, expPotential Γ (residualField a j y) (a j) t ∂(laws j).law
  have hupd : (fun k : {k : J // k ≠ j} => (Function.update laws j ν k).law) =
      fun k : {k : J // k ≠ j} => (laws k).law := by
    funext k
    rw [Function.update_of_ne k.property]
  have hU : Integrable U μ := by
    have h := fieldMarginal_integrable (Function.update laws j ν) Γ a j
    simpa only [Function.update_self, hupd] using h
  have hV : Integrable V μ := fieldMarginal_integrable laws Γ a j
  have heU : fieldPartition (Function.update laws j ν) Γ a = ∫ y, U y ∂μ := by
    rw [fieldPartition_split _ Γ a j]
    simp only [Function.update_self, hupd]
    rfl
  have heV : fieldPartition laws Γ a = ∫ y, V y ∂μ := fieldPartition_split laws Γ a j
  have hratio (y : {k : J // k ≠ j} → ℝ) : U y ≤ Real.exp B * V y ∧ V y ≤ Real.exp B * U y := by
    have hpos (η : CoordinateLaw) :
        0 < ∫ t, expPotential Γ (residualField a j y) (a j) t ∂η.law :=
      (mul_pos (Real.exp_pos (-1)) (Real.exp_pos _)).trans_le
        (expPotential_expectation_lower η Γ _ _ G b hG hΓ hb ha hsmall)
    exact ratios_of_log_bound (hpos ν) (hpos (laws j))
      (one_coordinate_relative_lindeberg ν (laws j) Γ _ _ G b hG hΓ hb ha hsmall)
  have h₁ := integral_mono hU (hV.const_mul (Real.exp B)) (fun y => (hratio y).1)
  have h₂ := integral_mono hV (hU.const_mul (Real.exp B)) (fun y => (hratio y).2)
  rw [integral_const_mul, ← heU, ← heV] at h₁ h₂
  exact log_bound_of_ratios (fieldPartition_pos _ Γ a) (fieldPartition_pos laws Γ a) h₁ h₂

end Replace

private theorem log_telescope (P : ℕ → ℝ) (B : ℝ) (N : ℕ)
    (h : ∀ k < N, |Real.log (P (k + 1)) - Real.log (P k)| ≤ B) :
    |Real.log (P N) - Real.log (P 0)| ≤ (N : ℝ) * B := by
  have hi : ∀ k ≤ N, |Real.log (P k) - Real.log (P 0)| ≤ (k : ℝ) * B := by
    intro k
    induction k with
    | zero => intro _; simp
    | succ k ih =>
      intro hk
      have hold := ih (by omega)
      have hnew := h k (by omega)
      have htri := abs_sub_le (Real.log (P (k + 1))) (Real.log (P k)) (Real.log (P 0))
      push_cast
      linarith
  exact hi N le_rfl

section FiniteSum
variable {I : Type*} [Fintype I]

def hybridLaws (ν η : CoordinateLaw) (N k : ℕ) (j : Fin N) : CoordinateLaw :=
  if j.val < k then ν else η

theorem hybridLaws_step (ν η : CoordinateLaw) (N k : ℕ) (hk : k < N) :
    hybridLaws ν η N (k + 1) = Function.update (hybridLaws ν η N k) ⟨k, hk⟩ ν := by
  funext j
  by_cases heq : j = ⟨k, hk⟩
  · subst j
    simp [hybridLaws]
  · have hne : j.val ≠ k := by intro h; apply heq; exact Fin.ext h
    rw [Function.update_of_ne heq]
    unfold hybridLaws
    have hi : j.val < k + 1 ↔ j.val < k := by omega
    simp only [hi]

/-- Full finite-product relative Lindeberg estimate, with a general coefficient bound.
Specializing `b = N⁻¹/²` gives the paper's `cν P(G) / sqrt N` rate. -/
theorem finite_product_relative_lindeberg (ν η : CoordinateLaw) (N : ℕ)
    (Γ : I → I → ℝ) (a : Fin N → I → ℝ) (G b : ℝ)
    (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G) (hb : 0 ≤ b)
    (ha : ∀ j i, |a j i| ≤ b) (hsmall : 2 * G * b ≤ 1) :
    |Real.log (fieldPartition (fun _ : Fin N => ν) Γ a) -
        Real.log (fieldPartition (fun _ : Fin N => η) Γ a)| ≤
      (N : ℝ) * (replacementConstant ν η * lindebergPolynomial G * b ^ 3) := by
  let P : ℕ → ℝ := fun k => fieldPartition (hybridLaws ν η N k) Γ a
  have hstep (k : ℕ) (hk : k < N) :
      |Real.log (P (k + 1)) - Real.log (P k)| ≤
        replacementConstant ν η * lindebergPolynomial G * b ^ 3 := by
    have h := fieldPartition_update_log_bound (hybridLaws ν η N k) ν Γ a ⟨k, hk⟩ G b
      hG hΓ hb (ha ⟨k, hk⟩) hsmall
    rw [← hybridLaws_step ν η N k hk] at h
    simpa only [hybridLaws, lt_self_iff_false, if_false] using h
  have h := log_telescope P (replacementConstant ν η * lindebergPolynomial G * b ^ 3) N hstep
  have hN : hybridLaws ν η N N = fun _ => ν := funext fun j => by simp [hybridLaws, j.is_lt]
  have h0 : hybridLaws ν η N 0 = fun _ => η := funext fun j => by simp [hybridLaws]
  simpa only [P, hN, h0] using h

/-- The paper's finite-product relative Lindeberg bound, including its exact
`cν = e Jν / 6` and `N⁻¹/²` rate. The Gaussian comparison uses independent
standard normal variables with exactly the same coefficient vectors. -/
theorem relative_lindeberg (ν : CoordinateLaw) (N : ℕ) (hN : 0 < N)
    (Γ : I → I → ℝ) (a : Fin N → I → ℝ) (G : ℝ)
    (hG : 0 ≤ G) (hΓ : couplingMass Γ ≤ G)
    (ha : ∀ j i, |a j i| ≤ 1 / Real.sqrt N) (hsize : 4 * G ^ 2 ≤ (N : ℝ)) :
    |Real.log (fieldPartition (fun _ : Fin N => ν) Γ a) -
        Real.log (fieldPartition (fun _ : Fin N => standardGaussian) Γ a)| ≤
      replacementConstant ν standardGaussian * lindebergPolynomial G / Real.sqrt N := by
  have hNr : 0 < (N : ℝ) := by exact_mod_cast hN
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hNr
  have hsquare : (Real.sqrt N) ^ 2 = (N : ℝ) := Real.sq_sqrt hNr.le
  have hGsqrt : 2 * G ≤ Real.sqrt N := by nlinarith
  have hsmall : 2 * G * (1 / Real.sqrt N) ≤ 1 := by
    rw [one_div, ← div_eq_mul_inv, div_le_one hs]
    exact hGsqrt
  have h := finite_product_relative_lindeberg ν standardGaussian N Γ a G (1 / Real.sqrt N)
    hG hΓ (div_nonneg zero_le_one hs.le) ha hsmall
  have hcancel : (N : ℝ) * (1 / Real.sqrt N) ^ 3 = 1 / Real.sqrt N := by
    field_simp [hs.ne']
    nlinarith
  refine h.trans_eq ?_
  calc
    (N : ℝ) * (replacementConstant ν standardGaussian * lindebergPolynomial G *
        (1 / Real.sqrt N) ^ 3) =
      (replacementConstant ν standardGaussian * lindebergPolynomial G) *
        ((N : ℝ) * (1 / Real.sqrt N) ^ 3) := by ring
    _ = _ := by rw [hcancel]; ring

end FiniteSum
end NeuralGeneralization.BatchTwoNonGaussian
