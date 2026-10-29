import NetworkPathRepair

noncomputable section
open MeasureTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

variable {d N r : ℕ}

lemma networkRepairError_nonneg (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (ε : ℝ) (hε : 0≤ε) (n : ℕ) :
    0≤networkRepairError σ w star ε n := by
  apply propagatedFeatureError_nonneg
  · intro k
    unfold networkCertificateCostAt
    split
    · dsimp [networkCertificateCost]; positivity
    · positivity
  · positivity

lemma networkCertificateCost_le_total (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (B : ℝ)
    (hbudget : (∑ j,networkCertificateCost σ w star j)≤B) (j : Fin (r+1)) :
    networkCertificateCost σ w star j≤B := by
  apply le_trans _ hbudget
  exact Finset.single_le_sum (fun j _ => (show 0≤networkCertificateCost σ w star j from ENNReal.toReal_nonneg)) (Finset.mem_univ j)

/-- A closed finite-network precision bound. Its logarithm is polynomial in
hidden depth and log of the full-cube dimension; no precision is exponentiated
at each covariance repair. -/
theorem networkRepairError_bound (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (ε B T : ℝ)
    (hε : 0≤ε) (hB : 0≤B) (hT : 0≤T) (ht : |Real.sqrt N*σ|≤T)
    (hbudget : (∑ j,networkCertificateCost σ w star j)≤B) :
    networkRepairError σ w star ε (r+1) ≤
      ((r+1:ℕ):ℝ)*((Fintype.card (Cube d):ℝ)^4*ε)*
        (1+T*(1+4*B+4*Fintype.card (Cube d)))^(r+1) := by
  let gain := fun n => |Real.sqrt N*σ| *
    (1+4*networkCertificateCostAt σ w star n+4*Fintype.card (Cube d))
  let A := T*(1+4*B+4*Fintype.card (Cube d))
  let δ := (Fintype.card (Cube d):ℝ)^4*ε
  have hg : ∀ n<r+1, gain n≤A := by
    intro n hn
    have hc := networkCertificateCost_le_total σ w star B hbudget ⟨n,hn⟩
    have hcn : 0≤networkCertificateCost σ w star ⟨n,hn⟩ := ENNReal.toReal_nonneg
    dsimp [gain,A]
    simp only [networkCertificateCostAt,dif_pos hn]
    exact mul_le_mul ht (by linarith) (by positivity) hT
  have hstep : ∀ n<r+1, networkRepairError σ w star ε (n+1)≤
      A*networkRepairError σ w star ε n+δ := by
    intro n hn
    change gain n*networkRepairError σ w star ε n+δ≤_
    exact add_le_add (mul_le_mul_of_nonneg_right (hg n hn)
      (networkRepairError_nonneg σ w star ε hε n)) le_rfl
  exact repair_recurrence_constant (networkRepairError σ w star ε) A δ (r+1)
    (by dsimp [A]; positivity) (by dsimp [δ]; positivity) (by rfl) hstep

end ConditionalNonpolynomial.Analytic
