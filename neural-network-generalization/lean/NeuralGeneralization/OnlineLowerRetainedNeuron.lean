import NeuralGeneralization.OnlineLowerNetworkNorm
import NeuralGeneralization.OnlineLowerReluLipschitz
import NeuralGeneralization.OnlineLowerGeometrySubcodeStability

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open OnlineLowerGeometry OnlineLowerRelu

def affineRelu {d : ℕ} (u : EuclideanSpace ℝ (Fin (d+1))) (x : ClippingCube d) : ℝ :=
  max (cubeAffine (u 0) (fun i => u i.succ) x) 0

theorem affine_norm_sq {d : ℕ} (u : EuclideanSpace ℝ (Fin (d+1))) :
    ‖u‖^2 = (u 0)^2+∑ i : Fin d,(u i.succ)^2 := by
  rw [EuclideanSpace.real_norm_sq_eq, Fin.sum_univ_succ]

theorem affineRelu_l2_lipschitz {d : ℕ} (u v : EuclideanSpace ℝ (Fin (d+1))) :
    uniformCubeMean (fun x => (affineRelu u x-affineRelu v x)^2) ≤ ‖u-v‖^2 := by
  rw [affine_norm_sq]
  exact relu_neuron_l2_difference_le _ _ _ _

theorem affineRelu_coefficient_lipschitz {d : ℕ} (u v : EuclideanSpace ℝ (Fin (d+1)))
    (S : Finset (Fin d)) :
    |walshCoefficients (affineRelu u) S-walshCoefficients (affineRelu v) S| ≤ ‖u-v‖ := by
  have h := (walsh_difference_sq_le_l2 (affineRelu u) (affineRelu v) S).trans
    (affineRelu_l2_lipschitz u v)
  nlinarith [sq_abs (walshCoefficients (affineRelu u) S-walshCoefficients (affineRelu v) S),
    abs_nonneg (walshCoefficients (affineRelu u) S-walshCoefficients (affineRelu v) S), norm_nonneg (u-v)]

@[simp] theorem affineRelu_zero {d : ℕ} : affineRelu (0 : EuclideanSpace ℝ (Fin (d+1))) = 0 := by
  funext x
  simp [affineRelu,cubeAffine]

theorem projection_residual_le_comparison {d : ℕ} (D : Finset (Finset (Fin d)))
    (F G : ClippingCube d → ℝ)
    (hG : ∀ S,S∉D → walshCoefficients G S=0) :
    uniformCubeMean (fun x => (F x-fourierProject D F x)^2) ≤
      uniformCubeMean (fun x => (F x-G x)^2) := by
  simp only [pow_two]
  rw [walsh_inner_identity,walsh_inner_identity]
  apply Finset.sum_le_sum
  intro S _
  simp only [OnlineLowerGeometry.walshCoefficients_sub,fourierProject_coefficient]
  by_cases hS : S∈D
  · simp only [if_pos hS,sub_self,zero_mul]
    exact mul_self_nonneg _
  · rw [if_neg hS,hG S hS]


def finiteRetainedMass {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (J : Finset ι) (F : ClippingCube d → ℝ) : ℝ :=
  ∑ j∈J,w j*|walshCoefficients F (A j)|

theorem finiteRetainedMass_le_full {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ j,0≤w j)
    (J : Finset ι) (F : ClippingCube d → ℝ) :
    finiteRetainedMass A w J F ≤ retainedFourierMass A w F := by
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ J)
    (fun j _ _ => mul_nonneg (hw j) (abs_nonneg _))

theorem omitted_mass_le_difference {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ j,0≤w j)
    (J : Finset ι) (i : ι) (hi : i∉J) (F : ClippingCube d → ℝ) :
    w i*|walshCoefficients F (A i)| ≤ retainedFourierMass A w F-finiteRetainedMass A w J F := by
  have h := finiteRetainedMass_le_full A w hw (insert i J) F
  unfold finiteRetainedMass at h
  rw [Finset.sum_insert hi] at h
  change w i*|walshCoefficients F (A i)| + finiteRetainedMass A w J F ≤ _ at h
  linarith

/-- A concrete finite-Walsh subcode transfer. The supplied full-code ray
has a literal saturation coefficient, and the alternative witness is zero. -/
theorem retained_neuron_projection_bound {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ j,0≤w j)
    (J : Finset ι) (D : Finset (Finset (Fin d)))
    (u v : EuclideanSpace ℝ (Fin (d+1))) (i : ι) (K W : ℝ)
    (hK : 1≤K) (hW : 0≤W) (hwi : w i≤W)
    (hnorm : retainedFourierMass A w (affineRelu u) ≤ ‖u‖)
    (hfull : ‖u-v‖^2 ≤ K*‖u‖*(‖u‖-retainedFourierMass A w (affineRelu u)))
    (hsat : w i*|walshCoefficients (affineRelu v) (A i)|=‖v‖)
    (hface : i∈J → ∀ S,S∉D → walshCoefficients (affineRelu v) S=0) :
    uniformCubeMean (fun x => (affineRelu u x-fourierProject D (affineRelu u) x)^2) ≤
      4*K*(W+1)^2*‖u‖*(‖u‖-finiteRetainedMass A w J (affineRelu u)) := by
  let δ := ‖u‖-finiteRetainedMass A w J (affineRelu u)
  have hsub := finiteRetainedMass_le_full A w hw J (affineRelu u)
  have hd : 0≤δ := sub_nonneg.mpr (hsub.trans hnorm)
  have hfull' : ‖u-v‖^2 ≤ K*‖u‖*δ := hfull.trans
    (mul_le_mul_of_nonneg_left (by change ‖u‖-retainedFourierMass A w (affineRelu u) ≤ ‖u‖-finiteRetainedMass A w J (affineRelu u); linarith)
      (mul_nonneg (by linarith) (norm_nonneg u)))
  by_cases hi : i∈J
  · have hcomp := (projection_residual_le_comparison D (affineRelu u) (affineRelu v) (hface hi)).trans
      (affineRelu_l2_lipschitz u v)
    have hcoef : 1≤4*(W+1)^2 := by nlinarith [sq_nonneg W]
    have hm := mul_le_mul_of_nonneg_right hcoef (mul_nonneg (mul_nonneg (by linarith : 0≤K) (norm_nonneg u)) hd)
    exact hcomp.trans (hfull'.trans (by nlinarith))
  · have hmiss := omitted_mass_le_difference A w hw J i hi (affineRelu u)
    have hLip := affineRelu_coefficient_lipschitz u v (A i)
    have htri : |walshCoefficients (affineRelu v) (A i)| ≤
        |walshCoefficients (affineRelu u) (A i)|+‖u-v‖ := by
      have h := abs_sub_abs_le_abs_sub (walshCoefficients (affineRelu v) (A i))
        (walshCoefficients (affineRelu u) (A i))
      rw [abs_sub_comm] at h
      linarith
    have hvm : ‖v‖≤δ+W*‖u-v‖ := by
      have hm := mul_le_mul_of_nonneg_left htri (hw i)
      have hwv := mul_le_mul_of_nonneg_right hwi (norm_nonneg (u-v))
      rw [hsat] at hm
      dsimp [δ]
      nlinarith
    have htriangle : ‖u‖ ≤ ‖u-v‖+‖v‖ := by
      simpa only [sub_add_cancel] using norm_add_le (u-v) v
    have hz := omitted_ray_scalar_transfer ‖u‖ δ ‖u-v‖ K W
      (norm_nonneg _) hd (norm_nonneg _) hK hW hfull' (by linarith)
    have hzero := projection_residual_le_comparison D (affineRelu u) 0
      (fun S _ => by change walshCoefficients (fun _ => (0 : ℝ)) S = 0; simp [walshCoefficients_const])
    have hdiff := affineRelu_l2_lipschitz u 0
    rw [affineRelu_zero,sub_zero] at hdiff
    exact (hzero.trans hdiff).trans hz

end NeuralGeneralization.OnlineLower
