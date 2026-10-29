import SharpNetworkPathRepair
import NetworkRepairErrorBound
noncomputable section
open MeasureTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

lemma normalized_entropy_gain {t D B : ℝ} (ht : 0≤t) (ht1 : t≤1)
    (hD : 0≤D) (hB : t^2*D≤B) : t*(1+Real.sqrt (2*D))≤1+Real.sqrt (2*B) := by
  have hB0 : 0≤B := le_trans (mul_nonneg (sq_nonneg _) hD) hB
  have hsD := Real.sq_sqrt (show 0≤2*D by positivity)
  have hsB := Real.sq_sqrt (show 0≤2*B by positivity)
  have hg : t*Real.sqrt (2*D)≤Real.sqrt (2*B) := by
    apply (sq_le_sq₀ (by positivity) (Real.sqrt_nonneg _)).mp
    rw [mul_pow,hsD,hsB]
    nlinarith
  nlinarith

lemma sharpNetworkRepairError_nonneg (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (ε : ℝ) (hε : 0≤ε) (n : ℕ) :
    0≤sharpNetworkRepairError σ w star ε n := by
  apply propagatedFeatureError_nonneg
  · intro k; positivity
  · positivity

/-- Uniform repair amplification depends on the normalized physical energy,
not the unnormalized entropy which can diverge as the prior scale vanishes. -/
theorem sharpNetworkRepairError_bound (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (ε B : ℝ)
    (hε : 0≤ε) (hB : 0≤B) (ht : |Real.sqrt N*σ|≤1)
    (hbudget : (Real.sqrt N*σ)^2*(∑ j,networkCertificateCost σ w star j)≤B) :
    sharpNetworkRepairError σ w star ε (r+1) ≤
      ((r+1:ℕ):ℝ)*((Fintype.card (Cube d):ℝ)^4*ε)*
        (2+Real.sqrt (2*B))^(r+1) := by
  let gain := fun n => |Real.sqrt N*σ| *
    (1+Real.sqrt (2*networkCertificateCostAt σ w star n))
  let A := 1+Real.sqrt (2*B)
  let δ := (Fintype.card (Cube d):ℝ)^4*ε
  have hg : ∀ n<r+1, gain n≤A := by
    intro n hn
    have hc := networkCertificateCost_le_total σ w star
      (∑j,networkCertificateCost σ w star j) le_rfl ⟨n,hn⟩
    have hcn : 0≤networkCertificateCost σ w star ⟨n,hn⟩ := ENNReal.toReal_nonneg
    dsimp [gain,A]
    simp only [networkCertificateCostAt,dif_pos hn]
    apply normalized_entropy_gain (abs_nonneg _) ht hcn
    rw [sq_abs]
    exact (mul_le_mul_of_nonneg_left hc (sq_nonneg _)).trans hbudget
  have hstep : ∀ n<r+1, sharpNetworkRepairError σ w star ε (n+1)≤
      A*sharpNetworkRepairError σ w star ε n+δ := by
    intro n hn
    change gain n*sharpNetworkRepairError σ w star ε n+δ≤_
    exact add_le_add (mul_le_mul_of_nonneg_right (hg n hn)
      (sharpNetworkRepairError_nonneg σ w star ε hε n)) le_rfl
  have hh := repair_recurrence_constant (sharpNetworkRepairError σ w star ε) A δ (r+1)
    (by dsimp [A]; positivity) (by dsimp [δ]; positivity) (by rfl) hstep
  convert hh using 1 <;> simp only [A,δ] <;> congr 2 <;> ring

#print axioms sharpNetworkRepairError_bound
end ConditionalNonpolynomial.Analytic
