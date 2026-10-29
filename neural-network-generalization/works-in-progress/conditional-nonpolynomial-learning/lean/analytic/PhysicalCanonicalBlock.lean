import PhysicalCanonicalPolar
import FinitePolarBlock
import RestrictedBlockResidual

/-! Polar and nonlinear block estimates for a finite, actual canonical
program. Only the genuine layers before H are required; no fabricated
post-horizon law or isometry appears in the assumptions. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {I : ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K X : Type*} [Fintype K]
variable {anchors : ∀j,K→EuclideanSpace ℝ (I j)} {D : ℕ→ℝ} {H : ℕ}

def finitePhysicalLinear
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j)) (t : ℝ)
    (j : ℕ) : EuclideanSpace ℝ (I j)→ₗ[ℝ] EuclideanSpace ℝ (I (j+1)) :=
  if hj:j<H then t • (M j hj).linear.toLinearMap else 0

def finiteGaussianCost
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j)) (j : ℕ) : ℝ :=
  if hj:j<H then gaussianCovarianceCost (M j hj).law else 0

def finiteNongaussianCost
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j)) (j : ℕ) : ℝ :=
  if hj:j<H then (M j hj).nongaussianCost else 0

def finitePhysicalGain
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j)) (t : ℝ) (j : ℕ) : ℝ :=
  t*(1+Real.sqrt (2*finiteGaussianCost M j))

def finitePhysicalNonlinearity
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (t : ℝ) (radius : ℕ→ℝ) (j : ℕ) : ℝ :=
  112*((finitePhysicalGain M t j)^2*(radius j)^2+Real.sqrt (finiteNongaussianCost M j))

theorem actual_physical_canonical_block
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (u : ∀j,X→EuclideanSpace ℝ (I j)) (radius : ℕ→ℝ)
    (hr : ∀j<H,0<radius j)
    (hu : ∀j<H,∀x,‖u j x‖≤radius j)
    (hrec : ∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x)) :
    (∃U : EuclideanSpace ℝ (I 0)→ₗᵢ[ℝ] EuclideanSpace ℝ (I H),
      frobeniusNorm (hsLinearChain (finitePhysicalLinear M t) H-t^H • U.toLinearMap)≤
        Real.exp (Real.sqrt (2*H*(∑j∈Finset.range H,finiteGaussianCost M j)))*
          Real.sqrt (2*H*(∑j∈Finset.range H,finiteGaussianCost M j))) ∧
    (∀x y,‖u H x-u H y‖≤
      (∏j∈Finset.range H,finitePhysicalGain M t j)*‖u 0 x-u 0 y‖) ∧
    ∀x y,‖(u H x-hsLinearChain (finitePhysicalLinear M t) H (u 0 x))-
      (u H y-hsLinearChain (finitePhysicalLinear M t) H (u 0 y))‖≤
      (∏j∈Finset.range H,finitePhysicalGain M t j)*
        (∑j∈Finset.range H,finitePhysicalNonlinearity M t radius j)*‖u 0 x-u 0 y‖ := by
  have hgn (j : ℕ) (hj : j<H) : 0≤finitePhysicalGain M t j := by
    unfold finitePhysicalGain
    positivity
  have hpre (j : ℕ) (hj : j<H) :
      ‖gaussianFeaturePreconditioner (M j hj).law‖≤1+Real.sqrt (2*finiteGaussianCost M j) := by
    simp only [finiteGaussianCost,dif_pos hj]
    exact gaussianFeaturePreconditioner_norm_covarianceCost (M j hj).law (M j hj).finiteKL
  have hlin (j : ℕ) (hj : j<H) (z : EuclideanSpace ℝ (I j)) :
      ‖finitePhysicalLinear M t j z‖≤finitePhysicalGain M t j*‖z‖ := by
    have hh := (M j hj).physical_linear_bound ht.le (hpre j hj) z
    simp only [finitePhysicalLinear,dif_pos hj,LinearMap.smul_apply]
    change ‖t • ((M j hj).linear z)‖≤_
    rw [←map_smul]
    exact hh
  have hstep (j : ℕ) (hj : j<H) (x y:X) :
      ‖u (j+1) x-u (j+1) y‖≤finitePhysicalGain M t j*‖u j x-u j y‖ := by
    rw [hrec j hj x,hrec j hj y]
    exact (M j hj).physical_value_lipschitz ht.le (hpre j hj) _ _
  refine ⟨?_,actual_state_product_gain u _ H hgn hstep,?_⟩
  · apply finite_polar_block_gaussian_cost (E:=fun j=>EuclideanSpace ℝ (I j))
      (finitePhysicalLinear M t) (finiteGaussianCost M) ht.le ht1 H
    · intro j hj
      simp only [finiteGaussianCost,dif_pos hj]
      exact gaussianCovarianceCost_nonneg (M j hj).law (M j hj).finiteKL
    · intro j hj
      obtain ⟨U,hU⟩ := (M j hj).physical_entropy_polar
      refine ⟨U,?_⟩
      simpa only [finitePhysicalLinear,finiteGaussianCost,dif_pos hj] using hU t
  · apply actual_block_residual u _ _ _ H hgn
    · intro j hj
      unfold finitePhysicalNonlinearity
      positivity
    · exact hlin
    · exact hstep
    · intro j hj x y
      have hh := (M j hj).physical_residual_ball ht
        (by positivity : 0<1+Real.sqrt (2*finiteGaussianCost M j)) (hr j hj)
        (hpre j hj) (u j x) (u j y) (hu j hj x) (hu j hj y)
      have he (z : X) : u (j+1) z-finitePhysicalLinear M t j (u j z)=
          (M j hj).residual (t • u j z) := by
        rw [hrec j hj z,(M j hj).decomposition]
        simp only [finitePhysicalLinear,dif_pos hj,LinearMap.smul_apply,map_smul]
        change (t • (M j hj).linear (u j z)+(M j hj).residual (t • u j z))-
          t • (M j hj).linear (u j z)=_
        abel
      rw [he x,he y]
      simpa only [finitePhysicalNonlinearity,finitePhysicalGain,finiteNongaussianCost,dif_pos hj] using hh

#print axioms actual_physical_canonical_block
end ConditionalNonpolynomial.Analytic
