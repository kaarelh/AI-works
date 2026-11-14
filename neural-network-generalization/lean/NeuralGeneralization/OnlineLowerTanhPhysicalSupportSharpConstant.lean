import NeuralGeneralization.OnlineLowerTanhSupportSharpConstant
import NeuralGeneralization.OnlineLowerTanhCodeSupport

/-! The literal arbitrary-affine support constant stated in the paper. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

theorem intrinsicParityBound_conditioned_support_paper {n k : ℕ} (hn : Odd n)
    (w : ℝ) (hw : 0 ≤ w) (hsharp : IntrinsicParityBound n w)
    (u : Fin n → ℝ) (v : Fin k → ℝ) (b : ℝ) :
    let ρ := Real.sqrt (incomingEnergy u + (b^2 + incomingEnergy v))
    let q := w * |conditionedParityCorrelation u v b|
    q ≤ ρ ∧ b^2 + incomingEnergy v ≤ max 2 (96*Real.sqrt 6*w^2) * ρ * (ρ-q) := by
  dsimp only
  let ρ := Real.sqrt (incomingEnergy u + (b^2 + incomingEnergy v))
  let q := w * |conditionedParityCorrelation u v b|
  let p : Cube k → ℝ := fun _ => ((2:ℝ)^k)⁻¹
  let B : Cube k → ℝ := fun y => b + incomingLinear v y
  let V := b^2 + incomingEnergy v
  let i : Fin n := ⟨0,hn.pos⟩
  have hU : 0 ≤ incomingEnergy u := incomingEnergy_nonneg u
  have hV : 0 ≤ V := add_nonneg (sq_nonneg _) (incomingEnergy_nonneg _)
  have hρ : 0 ≤ ρ := Real.sqrt_nonneg _
  have hρsq : ρ^2 = incomingEnergy u + V := Real.sq_sqrt (add_nonneg hU hV)
  have hp : ∀ y, 0 ≤ p y := fun _ => by dsimp [p]; positivity
  have hpsum : ∑ y, p y = 1 := by
    simpa only [p,cubeMean, Finset.mul_sum, mul_one] using (cubeMean_const (n:=k) 1)
  have hsecond : ∑ y, p y * B y ^ 2 = V := by
    simpa only [p,B,V,cubeMean,←Finset.mul_sum] using affine_secondMoment v b
  have hfourth : ∑ y, p y * B y ^ 4 ≤ 3 * V^2 := by
    simpa only [p,B,V,cubeMean,←Finset.mul_sum] using affine_fourthMoment_le v b
  have htransfer : q ≤ ∑ y, p y * sqrtPair (incomingEnergy u + B y^2) (2*u i*B y) := by
    simpa only [q,p,B,cubeMean,←Finset.mul_sum] using
      conditionedParityCorrelation_transfer hn w hw hsharp u v b i
  have hcoord : q ≤ w*|u i| := mul_le_mul_of_nonneg_left
    (conditionedParityCorrelation_abs_le_coordinate u v b i) hw
  by_cases hz : ρ = 0
  · have hVzero : V = 0 := by rw [hz] at hρsq; nlinarith
    have hUzero : incomingEnergy u = 0 := by rw [hz] at hρsq; nlinarith
    have hizero : u i = 0 := by
      have hi := coordinate_sq_le_energy u i
      rw [hUzero] at hi
      nlinarith [sq_nonneg (u i)]
    have hqzero : q = 0 := by
      have hq : 0 ≤ q := mul_nonneg hw (abs_nonneg _)
      simp only [hizero,abs_zero,mul_zero] at hcoord
      linarith
    change q ≤ ρ ∧ V ≤ max 2 (96*Real.sqrt 6*w^2)*ρ*(ρ-q)
    simp [hz,hqzero,hVzero]
  · have hρpos : 0 < ρ := lt_of_le_of_ne hρ (Ne.symm hz)
    have hX (y : Cube k) : 0 ≤ incomingEnergy u + B y^2 := add_nonneg hU (sq_nonneg _)
    have hmean : ∑ y, p y*(incomingEnergy u+B y^2) = ρ^2 := by
      simp only [mul_add,Finset.sum_add_distrib,←Finset.sum_mul,hpsum,one_mul,hsecond,hρsq]
    have hpair : (∑ y, p y * sqrtPair (incomingEnergy u+B y^2) (2*u i*B y)) ≤
        ∑ y, p y * Real.sqrt (incomingEnergy u+B y^2) := by
      exact Finset.sum_le_sum (fun y _ => mul_le_mul_of_nonneg_left
        (sqrtPair_le _ _ (biasTransfer_abs_le _ _ _ (coordinate_sq_le_energy u i))) (hp y))
    have hnorm := htransfer.trans (hpair.trans (weighted_sqrt_le p _ ρ hp hpsum hX hρpos hmean))
    have hsupport := finite_support_stability_paper p B (incomingEnergy u) (u i) V ρ w q hp hpsum
      (coordinate_sq_le_energy u i) hρpos hw hsecond hfourth hρsq htransfer hcoord
    exact ⟨hnorm,hsupport⟩


theorem intrinsicParityBound_physical_support_paper {d : ℕ}
    (A : Finset (Fin d)) (hA : Odd A.card) (w : ℝ) (hw : 0 ≤ w)
    (hsharp : IntrinsicParityBound A.card w) (u : Fin d → ℝ) (b : ℝ) :
    let r := Real.sqrt (b^2 + incomingEnergy u)
    let q := w * |walshCoefficients (fun x => Real.tanh (b + incomingLinear u x)) A|
    q ≤ r ∧ b^2 + (∑ i ∈ Aᶜ, u i^2) ≤ max 2 (96*Real.sqrt 6*w^2) * r * (r-q) := by
  have h := intrinsicParityBound_conditioned_support_paper hA w hw hsharp
    (subsetWeights A u) (subsetWeights Aᶜ u) b
  dsimp only at h ⊢
  rw [← tanh_walshCoefficient_eq_conditioned] at h
  have hnorm : incomingEnergy (subsetWeights A u) +
      (b^2 + incomingEnergy (subsetWeights Aᶜ u)) = b^2 + incomingEnergy u := by
    rw [← incomingEnergy_partition A u]
    ring
  rw [hnorm, incomingEnergy_subsetWeights] at h
  exact h

end NeuralGeneralization.OnlineLowerTanh
