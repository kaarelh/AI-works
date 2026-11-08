import NeuralGeneralization.OnlineLowerCostFixedFamily

/-! # Actual degree costs: Bernstein representation and strict path separation -/

noncomputable section
open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

theorem fixedPathDegree_ge (n₀ : ℝ) (n : ℕ) (s : ClippingCube (n+1)) :
    n₀ ≤ fixedPathDegree n₀ n s := by
  unfold fixedPathDegree columnDegree
  apply le_add_of_nonneg_right
  apply Finset.sum_nonneg
  intro j _
  have hinc : 0 ≤ pathColumnIncrement 4 (@alternatingEdgeIncrement n) j := by
    cases j <;> simp [pathColumnIncrement, alternatingEdgeIncrement] <;> split_ifs <;> norm_num
  have hchar := walshCharacter_sq (pathColumn n j) s
  apply mul_nonneg (div_nonneg hinc (by norm_num))
  nlinarith

theorem fixedPathCost_laplace_integrable (μ : Measure ℝ) (n₀ : ℝ)
    (ρ : ℝ → ℝ) (vs : List Bool) (terminal : Bool)
    (hint : ∀ s : ClippingCube (2*vs.length+1),
      Integrable (fun t => Real.exp (-fixedPathDegree n₀ (2*vs.length) s*t) * ρ t) μ) :
    Integrable (fun t => ρ t * fixedPathCost n₀ (fun n => Real.exp (-n*t)) vs terminal) μ := by
  have hi := (integrable_finsetSum (Finset.univ : Finset (ClippingCube (2*vs.length+1)))
    (fun s _ => (hint s).const_mul (walshCharacter (blockSyndromeSupport vs terminal) s))).div_const
      (Fintype.card (ClippingCube (2*vs.length+1)) : ℝ)
  apply hi.congr
  filter_upwards [] with t
  unfold fixedPathCost walshCoefficients uniformCubeMean
  rw [← mul_div_assoc, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem fixedPathCost_bernstein (μ : Measure ℝ) (n₀ A B : ℝ)
    (cost ρ : ℝ → ℝ) (vs : List Bool) (terminal : Bool) (hlen : 3 ≤ vs.length)
    (hint : ∀ s : ClippingCube (2*vs.length+1),
      Integrable (fun t => Real.exp (-fixedPathDegree n₀ (2*vs.length) s*t) * ρ t) μ)
    (hcost : ∀ s : ClippingCube (2*vs.length+1),
      cost (fixedPathDegree n₀ (2*vs.length) s) =
        A * fixedPathDegree n₀ (2*vs.length) s + B -
          ∫ t, Real.exp (-fixedPathDegree n₀ (2*vs.length) s*t) * ρ t ∂μ) :
    fixedPathCost n₀ cost vs terminal =
      -(∫ t, ρ t * fixedPathCost n₀ (fun n => Real.exp (-n*t)) vs terminal ∂μ) := by
  have hcard := blockSyndromeSupport_card_ge_three vs terminal hlen
  have hv : blockSyndromeSupport vs terminal ≠ ∅ := by
    intro he
    rw [he] at hcard
    simp at hcard
  have hc : ∀ j, blockSyndromeSupport vs terminal ≠ pathColumn (2*vs.length) j := by
    intro j he
    rw [he] at hcard
    have hh := pathColumn_card_le_two (2*vs.length) j
    omega
  have h := columnCost_bernstein μ n₀ (pathColumn (2*vs.length))
    (pathColumnIncrement 4 alternatingEdgeIncrement) cost A B
    (fun s t => Real.exp (-fixedPathDegree n₀ (2*vs.length) s*t) * ρ t)
    hint hcost (blockSyndromeSupport vs terminal) hv hc
  change fixedPathCost n₀ cost vs terminal = _ at h
  rw [h]
  congr 1
  apply integral_congr_ae
  filter_upwards [] with t
  unfold fixedPathCost walshCoefficients uniformCubeMean
  rw [← mul_div_assoc, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem fixedCandidateCost_bernstein (μ : Measure ℝ) (n₀ A B : ℝ)
    (cost ρ : ℝ → ℝ) (endpoint : Bool) (digits : List Bool) (hlen : 2 ≤ digits.length)
    (hint : ∀ s : ClippingCube (2*(fixedParityBlocks endpoint digits).length+1),
      Integrable (fun t => Real.exp
        (-fixedPathDegree n₀ (2*(fixedParityBlocks endpoint digits).length) s*t) * ρ t) μ)
    (hcost : ∀ s : ClippingCube (2*(fixedParityBlocks endpoint digits).length+1),
      cost (fixedPathDegree n₀ (2*(fixedParityBlocks endpoint digits).length) s) =
        A * fixedPathDegree n₀ (2*(fixedParityBlocks endpoint digits).length) s + B -
          ∫ t, Real.exp
            (-fixedPathDegree n₀ (2*(fixedParityBlocks endpoint digits).length) s*t) * ρ t ∂μ) :
    fixedCandidateCost n₀ cost endpoint digits =
      integratedEnumeratorCost μ
        (fun t => ρ t * pathLaplacePrefactor n₀ t 4
          (@alternatingEdgeIncrement (2*(digits.length+1))))
        (fun t => Real.exp (-2*t)) endpoint 0 digits := by
  have hl : 3 ≤ (fixedParityBlocks endpoint digits).length := by
    rw [fixedParityBlocks_length]
    omega
  have h := fixedPathCost_bernstein μ n₀ A B cost ρ
    (fixedParityBlocks endpoint digits) false hl hint hcost
  change fixedCandidateCost n₀ cost endpoint digits = _ at h
  rw [h]
  unfold integratedEnumeratorCost
  rw [zero_sub]
  congr 1
  apply integral_congr_ae
  filter_upwards [] with t
  change ρ t * fixedCandidateCost n₀ (fun n => Real.exp (-n*t)) endpoint digits = _
  rw [fixedCandidateCost_exp]
  ring

theorem fixedCandidateCost_integrable (μ : Measure ℝ) (n₀ : ℝ)
    (ρ : ℝ → ℝ) (endpoint : Bool) (digits : List Bool)
    (hint : ∀ n, n₀ ≤ n → Integrable (fun t => Real.exp (-n*t) * ρ t) μ) :
    Integrable (fun t => (ρ t * pathLaplacePrefactor n₀ t 4
      (@alternatingEdgeIncrement (2*(digits.length+1)))) *
        candidatePathEnumerator (Real.exp (-2*t)) endpoint digits) μ := by
  have hi := fixedPathCost_laplace_integrable μ n₀ ρ
    (fixedParityBlocks endpoint digits) false
    (fun s => hint _ (fixedPathDegree_ge n₀ _ s))
  apply hi.congr
  filter_upwards [] with t
  change ρ t * fixedCandidateCost n₀ (fun n => Real.exp (-n*t)) endpoint digits = _
  rw [fixedCandidateCost_exp]
  ring

/-- Distinctness for the actual Fourier coefficients of the degree cost.
The sole analytic assumption is its positive Bernstein representation. -/
theorem fixedCandidateCost_ne_of_ne (μ : Measure ℝ) (hμ : μ ≠ 0)
    (n₀ A B : ℝ) (cost ρ : ℝ → ℝ)
    (hρ : ∀ᵐ t ∂μ, 0 < ρ t) (ht : ∀ᵐ t ∂μ, 0 < t)
    (hint : ∀ n, n₀ ≤ n → Integrable (fun t => Real.exp (-n*t) * ρ t) μ)
    (hcost : ∀ n, n₀ ≤ n → cost n = A*n+B - ∫ t, Real.exp (-n*t)*ρ t ∂μ)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hlarge : 2 ≤ xs.length) (hne : xs ≠ ys) :
    fixedCandidateCost n₀ cost endpoint xs ≠ fixedCandidateCost n₀ cost endpoint ys := by
  have hxrep := fixedCandidateCost_bernstein μ n₀ A B cost ρ endpoint xs hlarge
    (fun s => hint _ (fixedPathDegree_ge n₀ _ s))
    (fun s => hcost _ (fixedPathDegree_ge n₀ _ s))
  have hyrep := fixedCandidateCost_bernstein μ n₀ A B cost ρ endpoint ys
    (by omega) (fun s => hint _ (fixedPathDegree_ge n₀ _ s))
    (fun s => hcost _ (fixedPathDegree_ge n₀ _ s))
  rw [hxrep, hyrep, ← hlen]
  have hk : ∀ᵐ t ∂μ, 0 < ρ t * pathLaplacePrefactor n₀ t 4
      (@alternatingEdgeIncrement (2*(xs.length+1))) := by
    filter_upwards [hρ] with t htρ
    exact mul_pos htρ (pathLaplacePrefactor_pos _ _ _ _)
  have hx : ∀ᵐ t ∂μ, 0 < Real.exp (-2*t) ∧ Real.exp (-2*t) < 1 := by
    filter_upwards [ht] with t htt
    exact ⟨Real.exp_pos _, Real.exp_lt_one_iff.mpr (by linarith)⟩
  apply integratedEnumeratorCost_ne_of_ne μ hμ _ _ hk hx endpoint 0 hlen hne
  · exact fixedCandidateCost_integrable μ n₀ ρ endpoint xs hint
  · have hi := fixedCandidateCost_integrable μ n₀ ρ endpoint ys hint
    let pref (n : ℕ) (t : ℝ) :=
      pathLaplacePrefactor n₀ t 4 (@alternatingEdgeIncrement (2*(n+1)))
    change Integrable (fun t => ρ t * pref xs.length t *
      candidatePathEnumerator (Real.exp (-2*t)) endpoint ys) μ
    rw [hlen]
    exact hi

end NeuralGeneralization.OnlineLower
