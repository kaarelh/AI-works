import PhysicalCanonicalBlock
import GaussianCovarianceBlockGain

/-! Uniform constants for Gaussian-good blocks. Gaussian cost controls the
linear error; the restricted nonlinear budget uses only variances and the
non-Gaussian entropy, never the raw row entropy. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {I : ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K : Type*} [Fintype K]
variable {anchors : ∀j,K→EuclideanSpace ℝ (I j)} {D : ℕ→ℝ} {H : ℕ}

def canonicalBlockHSBound (E : ℝ) : ℝ := Real.exp (Real.sqrt (2*E))*Real.sqrt (2*E)
def canonicalBlockNonlinearBound (E : ℝ) : ℝ :=
  112*Real.exp (Real.sqrt (2*E))*((1+Real.sqrt (2*E))^2+1)

lemma canonicalBlockNonlinearBound_pos (E : ℝ) : 0<canonicalBlockNonlinearBound E := by
  unfold canonicalBlockNonlinearBound
  positivity

lemma finiteGaussianCost_nonneg
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j)) (j : ℕ) :
    0≤finiteGaussianCost M j := by
  unfold finiteGaussianCost
  split_ifs with hj
  · exact gaussianCovarianceCost_nonneg (M j hj).law (M j hj).finiteKL
  · exact le_rfl

lemma finitePhysicalGain_nonneg
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t : ℝ} (ht : 0≤t) (j : ℕ) : 0≤finitePhysicalGain M t j := by
  unfold finitePhysicalGain
  positivity

lemma finitePhysicalGain_product_le
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t E : ℝ} (ht : 0≤t) (ht1 : t≤1)
    (hcost : (H:ℝ)*(∑j∈Finset.range H,finiteGaussianCost M j)≤E) :
    (∏j∈Finset.range H,finitePhysicalGain M t j)≤Real.exp (Real.sqrt (2*E)) := by
  have hh := product_gain_le_exp_sqrt_cost H (finitePhysicalGain M t) (finiteGaussianCost M)
    (fun j _=>finitePhysicalGain_nonneg M ht j) (fun j _=>finiteGaussianCost_nonneg M j) (by
      intro j hj
      have hmul : t*(1+Real.sqrt (2*finiteGaussianCost M j))≤1+Real.sqrt (2*finiteGaussianCost M j) :=
        mul_le_of_le_one_left (by positivity) ht1
      exact hmul.trans (by linarith [Real.add_one_le_exp (Real.sqrt (2*finiteGaussianCost M j))]))
  exact hh.trans (Real.exp_le_exp.mpr (Real.sqrt_le_sqrt (by nlinarith only [hcost])))

lemma finitePhysicalBlock_nonlinearity_le
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t E : ℝ} (ht : 0≤t) (ht1 : t≤1) (hH : 1≤H) (radius : ℕ→ℝ)
    (hcost : (H:ℝ)*(∑j∈Finset.range H,finiteGaussianCost M j)≤E) :
    (∏j∈Finset.range H,finitePhysicalGain M t j)*
        (∑j∈Finset.range H,finitePhysicalNonlinearity M t radius j)≤
      canonicalBlockNonlinearBound E*
        (∑j∈Finset.range H,((radius j)^2+Real.sqrt (finiteNongaussianCost M j))) := by
  let A := (1+Real.sqrt (2*E))^2+1
  have hA : 1≤A := by dsimp [A]; nlinarith [sq_nonneg (1+Real.sqrt (2*E))]
  have hsum0 : 0≤∑j∈Finset.range H,finiteGaussianCost M j :=
    Finset.sum_nonneg fun j _=>finiteGaussianCost_nonneg M j
  have hHr : (1:ℝ)≤H := by exact_mod_cast hH
  have hsumE : (∑j∈Finset.range H,finiteGaussianCost M j)≤E := by nlinarith only [hcost,hsum0,hHr]
  have hbound (j : ℕ) (hj : j∈Finset.range H) :
      finitePhysicalNonlinearity M t radius j≤112*A*((radius j)^2+Real.sqrt (finiteNongaussianCost M j)) := by
    have hcj := (Finset.single_le_sum (fun i (_:i∈Finset.range H)=>finiteGaussianCost_nonneg M i) hj).trans hsumE
    have hroot := Real.sqrt_le_sqrt (show 2*finiteGaussianCost M j≤2*E by nlinarith only [hcj])
    have hgain : finitePhysicalGain M t j≤1+Real.sqrt (2*E) := by
      have hh : t*(1+Real.sqrt (2*finiteGaussianCost M j))≤1+Real.sqrt (2*finiteGaussianCost M j) :=
        mul_le_of_le_one_left (by positivity) ht1
      unfold finitePhysicalGain
      linarith
    have hsq : (finitePhysicalGain M t j)^2≤A := by
      have hh := pow_le_pow_left₀ (finitePhysicalGain_nonneg M ht j) hgain 2
      dsimp [A]
      linarith
    have hp := mul_le_mul_of_nonneg_right hsq (sq_nonneg (radius j))
    have hq := mul_le_mul_of_nonneg_right hA (Real.sqrt_nonneg (finiteNongaussianCost M j))
    unfold finitePhysicalNonlinearity
    nlinarith only [hp,hq]
  have hs := Finset.sum_le_sum hbound
  rw [←Finset.mul_sum] at hs
  have hprod := finitePhysicalGain_product_le M ht ht1 hcost
  have hsumN : 0≤∑j∈Finset.range H,finitePhysicalNonlinearity M t radius j := by
    apply Finset.sum_nonneg
    intro j _
    unfold finitePhysicalNonlinearity
    positivity
  have htotal := mul_le_mul hprod hs hsumN (Real.exp_pos _).le
  unfold canonicalBlockNonlinearBound
  dsimp only [A] at htotal
  nlinarith only [htotal]

#print axioms finitePhysicalBlock_nonlinearity_le
end ConditionalNonpolynomial.Analytic
