import NeuralGeneralization.OnlineLowerTanhLatticeFiniteEfficiency
import NeuralGeneralization.OnlineLowerTanhEmpiricalEfficiency

/-! # Classification of actual near-optimal localized arrays

Every finite-prefix inequality is discharged by literal conditioning and
the proved residual CLT. The remaining hypotheses are the actual empirical
limits and the elementary lower efficiency shared by global maximizers.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace LatticeSequence
variable (L : LatticeSequence)

theorem empirical_classification
    (Q : ℝ)
    (hE : Tendsto (fun k => incomingEnergy (L.u k)/(L.N k:ℝ)) atTop (𝓝 (L.a₀^2*Q)))
    (hnear : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ L.efficiency k)
    (hsum : HasSum L.p 1) (hmoment : Summable (fun j => L.p j*(j:ℝ)^2))
    (g J₀ : ℕ) (hg : 0 < g)
    (hodd : ∀ j,0 < L.p j → Odd j)
    (hdiv : ∀ j,0 < L.p j → g∣j)
    (hstable : ∀ J,J₀ ≤ J → supportPrefixGcd L.p J=g)
    (hQ : (∑' j,L.p j*(j:ℝ)^2) ≤ Q) :
    L.a₀*g < 2 ∧ Q=(g:ℝ)^2 ∧ (∑' j,L.p j*(j:ℝ)^2)=(g:ℝ)^2 ∧
      L.a₀*g=limitingGain ∧ L.p=(fun j => if j=g then 1 else 0) := by
  have hpositive (j : ℕ) (hj : 0 < L.p j) : 0 < j := by
    rcases hodd j hj with ⟨a,ha⟩
    omega
  have hM := support_gcd_moment_lower L.p g L.p_nonneg hsum hmoment hpositive hdiv
  have hQpos : 0 < Q := (sq_pos_of_pos (show (0:ℝ)<g by exact_mod_cast hg)).trans_le (hM.trans hQ)
  obtain ⟨j₀,hj₀⟩ := positive_support_nonempty_of_hasSum_one L.p L.p_nonneg hsum
  have hprefix (J : ℕ) (hJ : j₀+1 ≤ J) : (positiveSupportPrefix L.p J).Nonempty := by
    refine ⟨j₀,?_⟩
    exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega),hj₀⟩
  have hSpos (J : ℕ) (j : ℕ) (hj : j ∈ positiveSupportPrefix L.p J) : 0 < L.p j :=
    (Finset.mem_filter.mp hj).2
  apply empirical_efficiency_classification L.p L.p_nonneg hsum hmoment g hg hpositive hdiv
    Q L.a₀ L.a₀_pos hQ
  · filter_upwards [eventually_ge_atTop (j₀+1)] with J hJ
    have h := L.finite_alphabet_monotone_efficiency Q hQpos hE hnear
      (positiveSupportPrefix L.p J) (hprefix J hJ) (hSpos J)
    rwa [positiveSupportPrefix_sum L.p L.p_nonneg J] at h
  · intro hag
    filter_upwards [eventually_ge_atTop (max J₀ (j₀+1))] with J hJ
    have hJ₀ : J₀ ≤ J := (le_max_left _ _).trans hJ
    have hJj : j₀+1 ≤ J := (le_max_right _ _).trans hJ
    obtain ⟨c,hc⟩ := normalized_prefix_bezout L.p J g hg (hstable J hJ₀)
    let S := positiveSupportPrefix L.p J
    let cS : S → ℤ := fun j => c j.val
    have hcS : ∑ j : S,cS j*(j.val/g:ℕ)=1 := by
      have he : (∑ j : S,c j.val*(j.val/g:ℕ))=
          ∑ j ∈ S,c j*(j/g:ℕ) := (Finset.sum_subtype S (fun _ => Iff.rfl) (fun j => c j*(j/g:ℕ))).symm
      exact he.trans hc
    have h := L.finite_alphabet_sharp_efficiency Q hQpos hE hnear S (hprefix J hJj)
      (hSpos J) g hg hag (fun j hj => hodd j (hSpos J j hj))
      (fun j hj => hdiv j (hSpos J j hj)) cS hcS
    change limitingParityEfficiency ≤
      Real.sqrt (2/Real.pi)*(scalarF0 (L.a₀*g)/(L.a₀*g))*(g:ℝ)^2/
        Real.sqrt ((∑ j ∈ positiveSupportPrefix L.p J,L.p j*(j:ℝ)^2)*Q) at h
    rwa [positiveSupportPrefix_moment_sum L.p L.p_nonneg J] at h

end LatticeSequence
end NeuralGeneralization.OnlineLowerTanh
