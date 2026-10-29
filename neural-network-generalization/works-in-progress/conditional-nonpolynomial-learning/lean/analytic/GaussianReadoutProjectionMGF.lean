import NeuralGeneralization.GaussianFieldCovariance
import NeuralGeneralization.GaussianTail
import NeuralGeneralization.GaussianResidualTrace
import NeuralGeneralization.RobustGaussianGeometry
import Mathlib.Tactic.Ring

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace ConditionalAnalytic
open NeuralGeneralization
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {I J : Type*} [Fintype I] [Fintype J]

theorem gaussian_square_sum_mgf (s : ℝ) (hs : 0 < 1 - 2 * s) :
    (∫ x : I → ℝ, Real.exp (s * ∑ i, x i ^ 2) ∂standardLaw I) =
      (Real.sqrt (1 - 2 * s))⁻¹ ^ Fintype.card I := by
  have hInd := iIndepFun_pi (μ := fun _ : I => gaussianReal 0 1)
    (fun _ => (show AEMeasurable (fun x : ℝ => x ^ 2)
      (gaussianReal 0 1) by fun_prop))
  have hh := hInd.mgf_sum (by fun_prop) Finset.univ (t := s)
  change mgf (fun x : I → ℝ => ∑ i, x i ^ 2) (standardLaw I) s = _
  have hf : (fun x : I → ℝ => ∑ i, x i ^ 2) =
      ∑ i, (fun x : I → ℝ => x i ^ 2) := by ext x; simp
  have hh2 : mgf (∑ i, (fun x : I → ℝ => x i ^ 2)) (standardLaw I) s =
      ∏ i, mgf (fun x : I → ℝ => x i ^ 2) (standardLaw I) s := by
    simpa [standardLaw] using hh
  rw [hf, hh2]
  have hterm (i : I) : mgf (fun x : I → ℝ => x i ^ 2) (standardLaw I) s =
      (Real.sqrt (1 - 2 * s))⁻¹ := by
    unfold mgf standardLaw
    rw [integral_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
      (f := fun y : ℝ => Real.exp (s * y ^ 2)) (by fun_prop)]
    simpa using GaussianTail.integral_exp_mul_sq_gaussianReal 1 s (by simpa using hs)
  simp_rw [hterm]
  simp

theorem orthonormal_field_square_mgf [DecidableEq I] (B : I → J → ℝ)
    (horth : ∀ i k, ∑ j, B i j * B k j = if i = k then 1 else 0)
    (s : ℝ) (hs : 0 < s) :
    (∫ g : J → ℝ, Real.exp (((1-s)/2) * ∑ i, (fieldLinear B g i)^2)
      ∂standardLaw J) = (Real.sqrt s)⁻¹ ^ Fintype.card I := by
  classical
  let A : I → I → ℝ := fun i j => if i = j then 1 else 0
  have hA (z : I → ℝ) : fieldLinear A z = z := by
    ext i
    simp [fieldLinear_apply, A]
  have hlaw : fieldLaw B = fieldLaw A := by
    apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
    intro i k
    rw [show gram B i k = if i = k then 1 else 0 from horth i k]
    simp [gram, A]
  let F : (I → ℝ) → ℝ := fun x => Real.exp (((1-s)/2) * ∑ i, (x i)^2)
  have hF : Measurable F := by dsimp [F]; fun_prop
  change (∫ g, F (fieldLinear B g) ∂standardLaw J) = _
  rw [← integral_fieldLaw B F hF, hlaw, integral_fieldLaw A F hF]
  simp_rw [hA]
  have heq : 1 - 2 * ((1-s)/2) = s := by ring
  simpa only [F, heq] using gaussian_square_sum_mgf (I := I) ((1-s)/2) (by rwa [heq])

open scoped RealInnerProductSpace

theorem projection_square_mgf (K : Submodule ℝ (EuclideanSpace ℝ J))
    (s : ℝ) (hs : 0 < s) :
    (∫ g : J → ℝ,
      Real.exp (((1-s)/2) * ‖K.starProjection (WithLp.toLp 2 g)‖^2)
      ∂standardLaw J) = (Real.sqrt s)⁻¹ ^ Module.finrank ℝ K := by
  classical
  let B : Fin (Module.finrank ℝ K) → J → ℝ :=
    fun i j => ((stdOrthonormalBasis ℝ K i : K) : EuclideanSpace ℝ J) j
  have horth : ∀ i k, ∑ j, B i j * B k j = if i = k then 1 else 0 := by
    intro i k
    have hh := orthonormal_iff_ite.mp (stdOrthonormalBasis ℝ K).orthonormal i k
    change ⟪((stdOrthonormalBasis ℝ K i : K) : EuclideanSpace ℝ J),
      ((stdOrthonormalBasis ℝ K k : K) : EuclideanSpace ℝ J)⟫ = _ at hh
    simpa [PiLp.inner_apply, B, mul_comm] using hh
  have hsum (g : J → ℝ) :
      ‖K.starProjection (WithLp.toLp 2 g)‖^2 =
        ∑ i, (fieldLinear B g i)^2 := by
    rw [GaussianResidualTrace.projection_norm_sq_eq_sum]
    apply Finset.sum_congr rfl
    intro i hi
    congr 1
    simp [PiLp.inner_apply, fieldLinear_apply, B, mul_comm]
  simp_rw [hsum]
  simpa using orthonormal_field_square_mgf B horth s hs

open NeuralGeneralization.RobustGaussianGeometry

@[fun_prop] theorem measurable_active_readout_integrand {m N : ℕ} (s : ℝ) :
    Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) × (Fin N → ℝ) =>
      Real.exp (((1-s)/2) * ‖activeProjection p.1 (WithLp.toLp 2 p.2)‖^2)) := by
  have hm : Measurable (fun p : (Fin m → EuclideanSpace ℝ (Fin N)) × (Fin N → ℝ) =>
      (p.1, WithLp.toLp 2 p.2)) := by fun_prop
  exact (measurable_activeProjection.comp hm).norm.pow_const 2 |>.const_mul _ |>.exp

theorem active_projection_square_mgf {m N : ℕ}
    (f : Fin m → EuclideanSpace ℝ (Fin N)) (s : ℝ) (hs : 0 < s) :
    (∫ g : Fin N → ℝ, Real.exp (((1-s)/2) * ‖activeProjection f (WithLp.toLp 2 g)‖^2)
      ∂standardLaw (Fin N)) =
        (Real.sqrt s)⁻¹ ^ Module.finrank ℝ (Submodule.span ℝ (Set.range f)) := by
  simp_rw [activeProjection_eq_starProjection]
  exact projection_square_mgf _ s hs

theorem active_projection_square_mgf_le {m N : ℕ}
    (f : Fin m → EuclideanSpace ℝ (Fin N)) (s : ℝ) (hs : 0 < s) (hs1 : s ≤ 1) :
    (∫ g : Fin N → ℝ, Real.exp (((1-s)/2) * ‖activeProjection f (WithLp.toLp 2 g)‖^2)
      ∂standardLaw (Fin N)) ≤ (Real.sqrt s)⁻¹ ^ m := by
  rw [active_projection_square_mgf f s hs]
  apply pow_le_pow_right₀
  · apply (one_le_inv₀ (Real.sqrt_pos.mpr hs)).mpr
    exact Real.sqrt_le_one.mpr hs1
  · simpa [Set.finrank] using finrank_range_le_card (R := ℝ) f

theorem integrable_active_readout {m N : ℕ}
    (f : Fin m → EuclideanSpace ℝ (Fin N)) (s : ℝ) (hs : 0 < s) :
    Integrable (fun g : Fin N → ℝ =>
      Real.exp (((1-s)/2) * ‖activeProjection f (WithLp.toLp 2 g)‖^2))
      (standardLaw (Fin N)) := by
  apply Integrable.of_integral_ne_zero
  rw [active_projection_square_mgf f s hs]
  exact pow_ne_zero _ (inv_ne_zero (ne_of_gt (Real.sqrt_pos.mpr hs)))

#print axioms integrable_active_readout
#print axioms active_projection_square_mgf_le
#print axioms measurable_active_readout_integrand
#print axioms projection_square_mgf
#print axioms gaussian_square_sum_mgf
#print axioms orthonormal_field_square_mgf
end ConditionalAnalytic
