import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Laplace integration by parts used to identify the actual ReLU cost kernel. -/

noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.OnlineLowerBernstein

def laplace (z : ℝ) (f : ℝ → ℝ) : ℝ :=
  ∫ t in Ioi (0 : ℝ), Real.exp (-z * t) * f t

def LaplaceIntegrable (z : ℝ) (f : ℝ → ℝ) : Prop :=
  IntegrableOn (fun t => Real.exp (-z * t) * f t) (Ioi (0 : ℝ))

theorem laplace_derivative (z : ℝ) (f f' : ℝ → ℝ)
    (hderiv : ∀ t ∈ Ici (0 : ℝ), HasDerivAt f (f' t) t)
    (hf : LaplaceIntegrable z f) (hf' : LaplaceIntegrable z f')
    (hlim : Tendsto (fun t => Real.exp (-z * t) * f t) atTop (𝓝 0)) :
    laplace z f' = z * laplace z f - f 0 := by
  let F := fun t => Real.exp (-z * t) * f t
  let D := fun t => -z * (Real.exp (-z * t) * f t) + Real.exp (-z * t) * f' t
  have hFD : ∀ t ∈ Ici (0 : ℝ), HasDerivAt F (D t) t := by
    intro t ht
    convert! ((((hasDerivAt_id t).const_mul (-z)).exp).mul (hderiv t ht)) using 1 <;>
      (try dsimp [F, D]) <;> ring
  have hDi : IntegrableOn D (Ioi (0 : ℝ)) := (hf.const_mul (-z)).add hf'
  have hFTC := integral_Ioi_of_hasDerivAt_of_tendsto' hFD hDi hlim
  have hDint : (∫ t in Ioi (0 : ℝ), D t) = -z * laplace z f + laplace z f' := by
    dsimp [D, laplace]
    rw [integral_add (hf.const_mul (-z)) hf', integral_const_mul]
  rw [hDint] at hFTC
  simp only [F, mul_zero, Real.exp_zero, one_mul, zero_sub] at hFTC
  linarith

theorem laplace_linear_combination (z a b : ℝ) (f g : ℝ → ℝ)
    (hf : LaplaceIntegrable z f) (hg : LaplaceIntegrable z g) :
    laplace z (fun t => a * f t + b * g t) = a * laplace z f + b * laplace z g := by
  unfold laplace
  have he (t : ℝ) : Real.exp (-z * t) * (a * f t + b * g t) =
      a * (Real.exp (-z * t) * f t) + b * (Real.exp (-z * t) * g t) := by ring
  simp_rw [he]
  rw [integral_add (hf.const_mul a) (hg.const_mul b), integral_const_mul, integral_const_mul]

/-- Two integrations by parts. Actual `B`, `B'`, and `B''` must supply
the differentiability, integrability and boundary conditions below. -/
theorem bernstein_laplace_identity (z : ℝ) (B B' B'' : ℝ → ℝ)
    (hB : ∀ t ∈ Ici (0 : ℝ), HasDerivAt B (B' t) t)
    (hB' : ∀ t ∈ Ici (0 : ℝ), HasDerivAt B' (B'' t) t)
    (hi : LaplaceIntegrable z B) (hi' : LaplaceIntegrable z B')
    (hi'' : LaplaceIntegrable z B'')
    (hl : Tendsto (fun t => Real.exp (-z * t) * B t) atTop (𝓝 0))
    (hl' : Tendsto (fun t => Real.exp (-z * t) * B' t) atTop (𝓝 0))
    (hzero : B 0 = 1) (hzero' : B' 0 = 1 / 8) :
    z * (z - 1 / 2) * laplace z B =
      z - 3 / 8 - laplace z (fun t => (1 / 2 : ℝ) * B' t - B'' t) := by
  have h₁ := laplace_derivative z B B' hB hi hi' hl
  have h₂ := laplace_derivative z B' B'' hB' hi' hi'' hl'
  have hc := laplace_linear_combination z (1 / 2) (-1) B' B'' hi' hi''
  simp only [neg_one_mul, ← sub_eq_add_neg] at hc
  rw [hc, h₁, h₂, h₁, hzero, hzero']
  ring

end NeuralGeneralization.OnlineLowerBernstein
