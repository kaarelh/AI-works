import Mathlib.Analysis.Normed.Operator.NormedSpace
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Tactic

/-! The continuity argument that turns a local quadratic inequality into a
finite-radius estimate. No differential-equation or first-crossing oracle is
assumed. -/
noncomputable section
open Set
namespace NeuralGeneralization.JacobianCertificate

/-- A continuous branch starting at zero cannot cross the forbidden root gap
of a quadratic inequality. -/
theorem quadratic_no_escape {q : ℝ → ℝ} {a b : ℝ}
    (hq : ContinuousOn q (Icc 0 1)) (hq0 : q 0 = 0)
    (ha : 0 < a) (hb : 0 ≤ b) (hsmall : 4*a*b < 1)
    (hquad : ∀ t ∈ Icc (0 : ℝ) 1, q t ≤ a+b*(q t)^2) :
    q 1 < 2*a := by
  by_contra hn
  have hlevel : 2*a ∈ Icc (q 0) (q 1) := by
    rw [hq0]
    exact ⟨by positivity, le_of_not_gt hn⟩
  obtain ⟨t,ht,he⟩ := intermediate_value_Icc (by norm_num : (0 : ℝ) ≤ 1) hq hlevel
  have hh := hquad t ht
  rw [he] at hh
  have hs := mul_lt_mul_of_pos_left hsmall ha
  nlinarith

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Exact nonlinear resolvent identity along a homotopy, with its proved
quadratic remainder, controls every point on the connected branch. -/
theorem transport_norm_lt (K : E →L[ℝ] E) (X e : ℝ → E) (v : E)
    {β R : ℝ} (hβ : 0 ≤ β) (hR : ‖v‖ ≤ R)
    (hsmall : 2*β*‖K‖^2*R < 1)
    (hK : 0 < ‖K‖) (hv : 0 < ‖v‖)
    (hX : ContinuousOn X (Icc 0 1)) (hX0 : X 0 = 0)
    (hid : ∀ t ∈ Icc (0 : ℝ) 1, X t = K (t • v + e t))
    (he : ∀ t ∈ Icc (0 : ℝ) 1, ‖e t‖ ≤ β/2*‖X t‖^2) :
    ‖X 1‖ < 2*‖K‖*‖v‖ := by
  have hs : 4*(‖K‖*‖v‖)*(‖K‖*β/2) < 1 := by
    have hh := mul_le_mul_of_nonneg_left hR (show 0 ≤ 2*β*‖K‖^2 by positivity)
    nlinarith
  rw [mul_assoc (2 : ℝ)]
  apply quadratic_no_escape (q := fun t => ‖X t‖) hX.norm (by rw [hX0,norm_zero])
    (mul_pos hK hv) (by positivity) hs
  intro t ht
  have ht1 : ‖t • v‖ ≤ ‖v‖ := by
    rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg ht.1]
    exact mul_le_of_le_one_left (norm_nonneg _) ht.2
  calc
    ‖X t‖ = ‖K (t • v + e t)‖ := congrArg norm (hid t ht)
    _ ≤ ‖K‖*‖t • v + e t‖ := K.le_opNorm _
    _ ≤ ‖K‖*(‖v‖+β/2*‖X t‖^2) := mul_le_mul_of_nonneg_left
      ((norm_add_le _ _).trans (add_le_add ht1 (he t ht))) (norm_nonneg _)
    _ = _ := by ring

/-- Readout gain is the norm of the signed clean transport, so cancellations
in that transport are retained. -/
theorem readout_bound (K : E →L[ℝ] E) (L : E →L[ℝ] ℝ)
    (X e : ℝ → E) (v : E) {β R : ℝ}
    (hβ : 0 ≤ β) (hR : ‖v‖ ≤ R)
    (hsmall : 2*β*‖K‖^2*R < 1)
    (hv0 : v = 0 → X 1 = 0)
    (hX : ContinuousOn X (Icc 0 1)) (hX0 : X 0 = 0)
    (hid : ∀ t ∈ Icc (0 : ℝ) 1, X t = K (t • v + e t))
    (he : ∀ t ∈ Icc (0 : ℝ) 1, ‖e t‖ ≤ β/2*‖X t‖^2) :
    |L (X 1)| ≤ ‖L.comp K‖*(1+2*β*‖K‖^2*R)*‖v‖ := by
  by_cases hv : v = 0
  · simp [hv0 hv,hv]
  by_cases hK : K = 0
  · have hz := hid 1 (by norm_num)
    simp only [hK, ContinuousLinearMap.zero_apply] at hz
    simp [hz,hK]
  have hnorm := (transport_norm_lt K X e v hβ hR hsmall
    (by exact norm_pos_iff.mpr hK) (by exact norm_pos_iff.mpr hv) hX hX0 hid he).le
  have hr : ‖e 1‖ ≤ 2*β*‖K‖^2*‖v‖^2 := by
    have hh := mul_le_mul_of_nonneg_left
      ((sq_le_sq₀ (norm_nonneg _) (by positivity)).mpr hnorm)
      (show 0 ≤ β/2 by positivity)
    have he1 := he 1 (by norm_num)
    nlinarith
  have hu : ‖v‖+‖e 1‖ ≤ (1+2*β*‖K‖^2*R)*‖v‖ := by
    have hh := mul_le_mul_of_nonneg_left hR
      (show 0 ≤ 2*β*‖K‖^2*‖v‖ by positivity)
    nlinarith
  calc
    |L (X 1)| = ‖(L.comp K) (v+e 1)‖ := by rw [hid 1 (by norm_num)]; simp
    _ ≤ ‖L.comp K‖*‖v+e 1‖ := (L.comp K).le_opNorm _
    _ ≤ ‖L.comp K‖*(‖v‖+‖e 1‖) :=
      mul_le_mul_of_nonneg_left (norm_add_le _ _) (norm_nonneg _)
    _ ≤ _ := by simpa only [mul_assoc] using mul_le_mul_of_nonneg_left hu (norm_nonneg (L.comp K))

end NeuralGeneralization.JacobianCertificate
