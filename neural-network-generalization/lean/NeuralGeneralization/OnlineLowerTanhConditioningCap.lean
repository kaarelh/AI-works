import NeuralGeneralization.OnlineLowerTanhCodePartial
import NeuralGeneralization.OnlineLowerTanhCodeKernel

/-! Uniform external-bias bounds survive conditioning on any selected
subset of the actual physical coordinates. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

@[simp] theorem ridgeParity_tanh {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    ridgeParity Real.tanh u b = parityCorrelation u b :=
  (parityCorrelation_eq_cubeMean u b).symm

theorem tanh_walshCoefficient_le_uniform_subset_cap {d : ℕ}
    (A B : Finset (Fin d)) (hAB : A⊆B) (u : Fin d → ℝ) (b M : ℝ)
    (hcap : ∀s:ℝ,|parityCorrelation (subsetWeights A u) s|≤M) :
    |walshCoefficients (fun x => Real.tanh (b+incomingLinear u x)) B|≤M := by
  rw [tanh_walshCoefficient_partial_formula A B hAB]
  apply (abs_cubeMean_le _).trans
  have h := cubeMean_mono
    (fun y => |outsideWalsh A B y*ridgeParity Real.tanh (subsetWeights A u)
      (b+incomingLinear (subsetWeights Aᶜ u) y)|)
    (fun _ => M) (fun y => by
      rw [abs_mul,outsideWalsh_abs_one,one_mul,ridgeParity_tanh]
      exact hcap _)
  simpa only [cubeMean_const] using h

theorem parityCorrelation_le_uniform_subset_cap {n : ℕ}
    (A : Finset (Fin n)) (u : Fin n → ℝ) (b M : ℝ)
    (hcap : ∀s:ℝ,|parityCorrelation (subsetWeights A u) s|≤M) :
    |parityCorrelation u b|≤M := by
  rw [parityCorrelation_eq_walsh_univ]
  exact tanh_walshCoefficient_le_uniform_subset_cap A Finset.univ
    (Finset.subset_univ _) u b M hcap

end NeuralGeneralization.OnlineLowerTanh
