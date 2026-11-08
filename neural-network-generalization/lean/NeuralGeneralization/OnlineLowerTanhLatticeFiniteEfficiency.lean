import NeuralGeneralization.OnlineLowerTanhLatticeBulkCLT
import NeuralGeneralization.OnlineLowerTanhOptimizerEfficiency
import NeuralGeneralization.OnlineLowerTanhMonotoneEfficiency

/-! # Actual finite-alphabet efficiency inequalities

The finite-prefix estimates here are derived by conditioning the original
finite-cube correlation on its pruned, refitted physical coordinates.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace LatticeSequence
variable (L : LatticeSequence)

def efficiency (k : ℕ) : ℝ :=
  (L.N k:ℝ)*|parityCorrelation (L.u k) 0|/Real.sqrt (incomingEnergy (L.u k))

lemma finite_moment_pos (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ j ∈ S,0 < L.p j) (hodd : ∀ j ∈ S,Odd j) :
    0 < ∑ j ∈ S,L.p j*(j:ℝ)^2 := by
  apply Finset.sum_pos'
  · intro j hj
    exact mul_nonneg (hS j hj).le (sq_nonneg _)
  · obtain ⟨j,hj⟩ := hne
    have hjpos : 0 < j := by rcases hodd j hj with ⟨a,ha⟩; omega
    exact ⟨j,hj,mul_pos (hS j hj) (sq_pos_of_pos (by exact_mod_cast hjpos))⟩

/-- The monotone cap uses every omitted coordinate in the denominator and
works regardless of the parity of the selected bulk size. -/
theorem finite_alphabet_monotone_efficiency
    (Q : ℝ) (hQ : 0 < Q)
    (hE : Tendsto (fun k => incomingEnergy (L.u k)/(L.N k:ℝ)) atTop (𝓝 (L.a₀^2*Q)))
    (hnear : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ L.efficiency k)
    (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j) :
    limitingParityEfficiency ≤ Real.sqrt (2/Real.pi)/
      Real.sqrt ((∑ j ∈ S,L.p j)*(L.a₀^2*Q)) := by
  have hρ := L.finite_mass_pos S hne hS
  have hρlim : Tendsto (fun k => ((L.bulk S k).card:ℝ)/(L.N k:ℝ)) atTop
      (𝓝 (∑ j ∈ S,L.p j)) := by
    have h := threshold_pruned_card_ratio_tendsto L.N L.N_pos L.N_tendsto L.q L.residual L.K
      L.residual_bound L.p L.frequency_tendsto S
    apply h.congr'
    exact Eventually.of_forall (fun k => by change (L.N k:ℝ)⁻¹*((L.bulk S k).card:ℝ)=_; ring)
  have hc := monotone_conditioned_efficiency_upper_bound L.N L.u (fun _ => 0) (L.bulk S)
    (∑ j ∈ S,L.p j) (L.a₀^2*Q) hρ (by positivity [L.a₀_pos])
    (Eventually.of_forall L.N_pos) (L.bulk_card_tendsto S hρ) hρlim hE
  exact eventual_efficiency_bounds_compare L.efficiency _ _ hnear hc

/-- The sharp primitive-alphabet bound is an actual consequence of the
uniform residual CLT. No finite-prefix analytic estimate is assumed. -/
theorem finite_alphabet_sharp_efficiency
    (Q : ℝ) (hQ : 0 < Q)
    (hE : Tendsto (fun k => incomingEnergy (L.u k)/(L.N k:ℝ)) atTop (𝓝 (L.a₀^2*Q)))
    (hnear : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ L.efficiency k)
    (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j)
    (g : ℕ) (hg : 0 < g) (hAg : L.a₀*g < 2)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j)
    (c : S → ℤ) (hc : ∑ j,c j*(j.val/g:ℕ)=1) :
    limitingParityEfficiency ≤
      Real.sqrt (2/Real.pi)*(scalarF0 (L.a₀*g)/(L.a₀*g))*(g:ℝ)^2/
        Real.sqrt ((∑ j ∈ S,L.p j*(j:ℝ)^2)*Q) := by
  let P := L.toResidualPresequence S hne hS g hg hodd hdiv c hc
  obtain ⟨φ,E,hφ⟩ := P.exists_refinement
  let R := P.toResidualSequence φ E hφ
  have hqS := L.finite_moment_pos S hne hS hodd
  have hv : 0 < (∑ j ∈ S,L.p j*(j:ℝ)^2)/(g:ℝ)^2 := by positivity
  have he : 0 < L.a₀^2*Q := by positivity [L.a₀_pos]
  have hid (k : ℕ) (B : ℝ) :
      parityCorrelation (subsetWeights (L.bulk S (φ k)) (fun i => |L.u (φ k) i|)) B =
        parityCorrelation (R.incoming k) B := by
    change parityCorrelation (subsetWeights (L.bulk S (φ k)) (fun i => |L.u (φ k) i|)) B =
      parityCorrelation (P.incoming (φ k)) B
    rw [L.toResidualPresequence_incoming S hne hS g hg hodd hdiv c hc]
  have hV : Tendsto (fun k => residualVariance (R.alphabet k)/(L.N (φ k):ℝ)) atTop
      (𝓝 ((∑ j ∈ S,L.p j*(j:ℝ)^2)/(g:ℝ)^2)) := by
    exact (L.primitive_variance_ratio_tendsto S g hg hdiv).comp hφ.strictMono.tendsto_atTop
  have hEφ := hE.comp hφ.strictMono.tendsto_atTop
  have hcap := R.conditioned_efficiency_upper_bound hAg
    (fun k => L.N (φ k)) (fun k => L.u (φ k)) (fun _ => 0) (fun k => L.bulk S (φ k)) hid
    ((∑ j ∈ S,L.p j*(j:ℝ)^2)/(g:ℝ)^2) (L.a₀^2*Q) hv he
    (Eventually.of_forall (fun k => L.N_pos (φ k))) hV hEφ
  have hlo : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ L.efficiency (φ k) := by
    intro ε hε
    exact hφ.strictMono.tendsto_atTop.eventually (hnear ε hε)
  have hbound := eventual_efficiency_bounds_compare (fun k => L.efficiency (φ k)) _ _ hlo hcap
  change limitingParityEfficiency ≤
    (Real.sqrt (2/Real.pi)*scalarF0 (L.a₀*g))/
      Real.sqrt (((∑ j ∈ S,L.p j*(j:ℝ)^2)/(g:ℝ)^2)*(L.a₀^2*Q)) at hbound
  rw [primitive_efficiency_constant L.a₀ (g:ℝ) _ Q L.a₀_pos (by exact_mod_cast hg) hqS hQ] at hbound
  exact hbound

end LatticeSequence
end NeuralGeneralization.OnlineLowerTanh
