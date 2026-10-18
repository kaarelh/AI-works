import NeuralGeneralization.RobustModelContinuity
import NeuralGeneralization.CylinderContainment
import NeuralGeneralization.NetworkCylinderProbability

/-!
# Gaussian probability of the robust circuit's orthogonal cylinder

This module closes the probability calculation in the actual Gaussian
network prior. Deterministic cylinder containment is a separate obligation;
it is not replaced by a target-mass hypothesis here.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

/-- The exact product cylinder in whitened orthogonal coordinates. -/
def robustCoordinateCylinder
    (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (ρ σ : ℝ) : Set (Weights d N r) :=
  orthogonalWhiten (internalRowIsometry b.repr) ⁻¹'
    ((MeasurableEquiv.piEquivPiSubtypeProd
      (fun _ : WeightIndex d N r => ℝ) (constrainedIndex J)) ⁻¹'
      ((Set.pi Set.univ fun q =>
        Set.Icc (rotateInternalRows b.repr (whiten v) q.val - ρ*σ)
          (rotateInternalRows b.repr (whiten v) q.val + ρ*σ)) ×ˢ
        freeCoordinateEvent J (16*((r:ℝ)+1))))

/-- Explicit width-independent cost once radius and teacher cost are fixed. -/
def robustCylinderCost (d r : ℕ) (K G ρ : ℝ) : ℝ :=
  K + ((d:ℝ)+2+(r:ℝ)*G) *
    (ρ^2 + Real.sqrt (2*Real.pi)/(2*ρ)) + 1

/-- The actual Gaussian law gives the cylinder the claimed exponential mass.
Only geometric center energy and the number of constrained directions are
inputs; Gaussian independence and the bulk probability are proved. -/
theorem robustCoordinateCylinder_mass
    (hd : 0 < d) (hN : 0 < N) (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {K G ρ σ : ℝ}
    (hρ : 0 < ρ) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hJ : (J.card:ℝ) ≤ G) (hcost : weightedSquaredNorm v ≤ K) :
    Real.exp (-robustCylinderCost d r K G ρ / σ^2) ≤
      (smallPrior d N r σ).real (robustCoordinateCylinder v b J ρ σ) := by
  classical
  let a : {q : WeightIndex d N r // constrainedIndex J q} → ℝ :=
    fun q => rotateInternalRows b.repr (whiten v) q.val
  have hfree := freeCoordinateEvent_real_ge_half (d:=d) (r:=r) hN J hσ hscale
  have hm := smallPrior_selected_cylinder_exp_lower hd hN hσ hρ
    (internalRowIsometry b.repr) (constrainedIndex J) a
    (freeCoordinateEvent J (16*((r:ℝ)+1))) hfree
  have he : (∑ q, a q^2) ≤ K :=
    (selected_rotated_center_energy_le hd hN b.repr (constrainedIndex J) v).trans hcost
  have hdim : (Fintype.card {q : WeightIndex d N r // constrainedIndex J q}:ℝ) ≤
      (N:ℝ)*((d:ℝ)+2+(r:ℝ)*G) := by
    rw [card_constrainedIndex]
    push_cast
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
    linarith [mul_le_mul_of_nonneg_left hJ (Nat.cast_nonneg r)]
  let q : ℝ := (d:ℝ)+2+(r:ℝ)*G
  let k : ℝ := ρ^2 + Real.sqrt (2*Real.pi)/(2*ρ)
  have hG : 0 ≤ G := (Nat.cast_nonneg _).trans hJ
  have hq : 0 ≤ q := by dsimp [q]; positivity
  have hk : 0 ≤ k := by dsimp [k]; positivity
  have hσ2 : 0 < σ^2 := sq_pos_of_pos hσ
  have hN1 : (1:ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ^2 ≤ 1 := by nlinarith
  have hdimσ : (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*σ^2 ≤ q := by
    calc
      _ ≤ ((N:ℝ)*q)*σ^2 := mul_le_mul_of_nonneg_right hdim hσ2.le
      _ = q*((N:ℝ)*σ^2) := by ring
      _ ≤ q*1 := mul_le_mul_of_nonneg_left hscale hq
      _ = q := mul_one _
  have htotal : (∑ i, a i^2) +
      (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*k*σ^2 + σ^2 ≤
      robustCylinderCost d r K G ρ := by
    change _ ≤ K+q*k+1
    have hh := mul_le_mul_of_nonneg_right hdimσ hk
    nlinarith
  have hexp : -robustCylinderCost d r K G ρ / σ^2 ≤
      -(∑ i,a i^2)/σ^2 -
      (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*k - 1 := by
    apply (div_le_iff₀ hσ2).mpr
    simp only [neg_div]
    have hh : (∑ i, a i^2) / σ^2 * σ^2 = ∑ i, a i^2 :=
      div_mul_cancel₀ _ hσ2.ne'
    nlinarith
  have hhalf : Real.exp (-1) ≤ (1:ℝ)/2 := by
    have hh : (2:ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp 1]
    have hi := one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2) hh
    simpa only [one_div, ← Real.exp_neg] using hi
  calc
    _ ≤ Real.exp (-(∑ i,a i^2)/σ^2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*k - 1) :=
      Real.exp_le_exp.mpr hexp
    _ = Real.exp (-1) * Real.exp (-(∑ i,a i^2)/σ^2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*k) := by
      rw [← Real.exp_add]
      congr 1
      ring
    _ ≤ (1/2) * Real.exp (-(∑ i,a i^2)/σ^2 -
        (Fintype.card {i : WeightIndex d N r // constrainedIndex J i}:ℝ)*k) :=
      mul_le_mul_of_nonneg_right hhalf (Real.exp_nonneg _)
    _ ≤ _ := hm

/-- Once the constructive circuit theorem proves containment, monotonicity
transfers the fully proved cylinder probability to the support-and-target
intersection. This theorem explicitly records the remaining geometry. -/
theorem robust_target_mass_of_cylinder_containment
    (hd : 0 < d) (hN : 0 < N) (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {K G ρ σ c : ℝ}
    (hρ : 0 < ρ) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hJ : (J.card:ℝ) ≤ G) (hcost : weightedSquaredNorm v ≤ K)
    (f : BooleanFunction d)
    (hcontain : robustCoordinateCylinder v b J ρ σ ⊆
      robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) f) :
    Real.exp (-robustCylinderCost d r K G ρ / σ^2) ≤
      (smallPrior d N r σ).real
        (robustEvent Real.tanh c ∩ marginEvent Real.tanh (1/2) f) :=
  (robustCoordinateCylinder_mass hd hN v b J hρ hσ hscale hJ hcost).trans
    (measureReal_mono hcontain (measure_ne_top _ _))

end NeuralGeneralization.ConcreteModel
