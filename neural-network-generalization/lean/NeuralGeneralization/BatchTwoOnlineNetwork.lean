import NeuralGeneralization.BatchTwoOnlineSampling
import NeuralGeneralization.LowEnergyCapacity
import NeuralGeneralization.ConcreteStrongPrior
import NeuralGeneralization.PowerPriorTargetMass

/-!
# Actual Gaussian network posteriors in the online protocol

The network prior is the raw Gaussian mass of each global-margin sign
function. The normalization of the global-margin conditioning cancels in
every posterior, as proved by `posterior_div_const`.
-/
noncomputable section
open scoped BigOperators ENNReal Topology
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling ConcreteModel MeasureTheory Filter

/-- A fixed enumeration is only a coordinate choice; the order is a uniform
permutation of this enumeration. -/
def cubeEnumeration (d : ℕ) : Fin (Fintype.card (Cube d)) ≃ Cube d :=
  (Fintype.equivFin (Cube d)).symm

def networkPermutationTotal {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (μ : Measure (Weights d N r)) (f : BooleanFunction d) :
    Equiv.Perm (Fin (Fintype.card (Cube d))) → ℝ :=
  permutationTotal (functionMass φ a μ)
    (fun g i => g (cubeEnumeration d i) = f (cubeEnumeration d i))

/-- The actual network instantiation of the finite relevant-class theorem. -/
theorem network_expected_permutationTotal_le {d N r : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : Measure (Weights d N r))
    (f : BooleanFunction d) (hf : 0 < functionMass φ a μ f)
    (A : Finset (BooleanFunction d)) (h β : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g ∈ Finset.univ \ A, functionMass φ a μ g) / functionMass φ a μ f ≤ β) :
    finiteMean (networkPermutationTotal φ a μ f) ≤
      1+2*(h+1)*harmonicSum (Fintype.card (Cube d)-1)+Fintype.card (Cube d)*β :=
  expected_permutationTotal_le_general _ Fintype.card_pos _ (functionMass_nonneg φ a μ)
    _ f (fun _ => rfl) hf A h β hh hcard htail

/-- Exact posterior identification at a permutation prefix. -/
theorem permutationPosterior_eq_networkPosterior {d N r : ℕ}
    (φ : ℝ → ℝ) (a : ℝ) (μ : Measure (Weights d N r)) (f : BooleanFunction d)
    (π : Equiv.Perm (Fin (Fintype.card (Cube d))))
    (n : ℕ) (hn : n ≤ Fintype.card (Cube d)) :
    posterior (functionMass φ a μ)
      (prefixKeep (fun g i => g (cubeEnumeration d i) = f (cubeEnumeration d i)) π n) =
      networkPosterior φ a μ f
        (fun i : Fin n => cubeEnumeration d (π ⟨i.val, lt_of_lt_of_le i.isLt hn⟩)) := by
  unfold networkPosterior
  congr 1
  funext g
  apply propext
  constructor
  · intro hk i
    exact hk ⟨i.val, lt_of_lt_of_le i.isLt hn⟩ i.isLt
  · intro hk i hi
    exact hk ⟨i.val, hi⟩

/-- Strong-prior cumulative learning. The variance threshold is selected
once, before the whole random permutation (or its posterior draws). The
capacity and numerical bound are independent of learner width. -/
theorem strongPrior_expected_total {d C N r : ℕ}
    (hd : 1 ≤ d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) :
    ∃ σ₀ : ℝ, 0 < σ₀ ∧ ∀ σ : ℝ, 0 < σ → σ < σ₀ →
      finiteMean (networkPermutationTotal φ (1/2) (smallPrior d N r σ) f) ≤
        2 + 2*((strongCapacity d r C : ℝ)+1)*harmonicSum (Fintype.card (Cube d)-1) := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hcontinuous := admissibleActivation_continuous hφ
  have hlim := network_highEnergy_tail_ratio_tendsto_zero (by omega) hN hcontinuous f
    (margin_witness_at_larger_width φ f hf hCN)
  let β : ℝ := 1 / Fintype.card (Cube d)
  have hβ : 0 < β := by dsimp [β]; positivity
  have he := hlim.eventually (gt_mem_nhds hβ)
  obtain ⟨σ₀, hσ₀, hsub⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp he
  refine ⟨σ₀, hσ₀, ?_⟩
  intro σ hσ hσlt
  have htail := hsub ⟨hσ, hσlt⟩
  change (∑ g ∈ Finset.univ \ lowEnergyFunctions (N := N) (r := r) φ f,
    functionMass φ (1/2) (smallPrior d N r σ) g) /
      functionMass φ (1/2) (smallPrior d N r σ) f < β at htail
  have hb := network_expected_permutationTotal_le φ (1/2) (smallPrior d N r σ) f
    (small_functionMass_pos (by omega) hcontinuous f hf hCN hσ)
    (lowEnergyFunctions (N := N) (r := r) φ f) (strongCapacity d r C) β (by positivity)
    (lowEnergyFunctions_card_le_exp hd hφ f hf hCN) htail.le
  have hm : (Fintype.card (Cube d) : ℝ) ≠ 0 := by exact_mod_cast Fintype.card_ne_zero
  dsimp [β] at hb
  rw [mul_one_div_cancel hm] at hb
  linarith

/-- Finite-variance direct cost, for every input order and every infinite
query stream. This is the small-width branch used by both finite-variance
online theorems. -/
theorem powerPrior_totalError_le_cost {d C N r T : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) φ f C)
    (hCN : C ≤ N) (hNT : N ≤ T) {γ : ℝ} (hγ : 1 ≤ γ)
    (query : ℕ → Cube d) :
    totalError (functionMass φ (1/2) (powerPrior d N r γ))
      (fun g x => g x = f x) query ≤
      ENNReal.ofReal (cylinderPolynomialCoefficient r *
        (1+(d : ℝ)+C)^cylinderPolynomialDegree r * (T : ℝ)^γ) := by
  have hmass := powerPrior_target_mass_below_threshold hd φ hφ f hf hCN hNT hγ
  have hpos := (Real.exp_pos _).trans_le hmass
  have hlog := Real.log_le_log (Real.exp_pos _) hmass
  rw [Real.log_exp] at hlog
  apply (network_totalError_le_prior_cost (admissibleActivation_continuous hφ)
    (1/2) (by norm_num) (powerPrior d N r γ) f hpos query).trans
  exact ENNReal.ofReal_le_ofReal (by linarith)

end NeuralGeneralization.BatchTwoOnline
