import NeuralGeneralization.BatchTwoOnlineSharpSpectralClass
import NeuralGeneralization.BatchTwoOnlineSharpSpectralGaussian
import NeuralGeneralization.BatchTwoActivationSpectralNetwork

/-! Exact aggregate spectral tail for the boxed online above-mean-field
corollary, with real energy K and the manuscript's literal constants. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel MeasureTheory ProbabilityTheory

theorem badSpectral_subset {d N r : ℕ} (a K : ℝ) :
    (goodSpectralWeights d N r K a)ᶜ⊆
      ({w|K≤(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)}∪
       {w|K≤(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)})∪
       ⋃s : Fin r,{w|(fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))∈matrixApproximationFailure N a K} := by
  intro w hbad
  by_cases hf:K≤(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)
  · exact Or.inl (Or.inl hf)
  by_cases hr:K≤(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)
  · exact Or.inl (Or.inr hr)
  right
  by_contra hh
  have hm:∀s : Fin r,∃H : Fin N×Fin N→ℝ,LowRankGrid.squaredSum H≤K ∧
      ‖matrixOperator (fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))-matrixOperator H‖≤a := by
    intro s
    by_contra hn
    exact hh (Set.mem_iUnion.mpr ⟨s,hn⟩)
  exact hbad ⟨(lt_of_not_ge hf).le,(lt_of_not_ge hr).le,hm⟩

theorem smallPrior_badSpectral_tail {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (a K B : ℝ)
    (hfirst : 8*((N*(d+1):ℕ):ℝ)*σ^2≤K) (hread : 8*(N:ℝ)*σ^2≤K)
    (hmat : (Measure.pi (fun _ : Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal)).real
      (matrixApproximationFailure N a K)≤B) :
    (smallPrior d N r σ).real (goodSpectralWeights d N r K a)ᶜ≤
      2*Real.exp (-K/(4*σ^2))+(r:ℝ)*B := by
  classical
  let μ:=smallPrior d N r σ
  let F:Set (Weights d N r):={w|K≤(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)}
  let R:Set (Weights d N r):={w|K≤(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)}
  let M (s:Fin r):Set (Weights d N r):=
    {w|(fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))∈matrixApproximationFailure N a K}
  have hF:μ.real F≤Real.exp (-K/(4*σ^2)):=BatchTwoActivation.smallPrior_first_energy_tail hd hN hσ K hfirst
  have hR:μ.real R≤Real.exp (-K/(4*σ^2)):=BatchTwoActivation.smallPrior_readout_energy_tail hd hN hσ K hread
  have hM:μ.real (⋃s,M s)≤(r:ℝ)*B:=by
    calc
      _ ≤ ∑s,μ.real (M s):=measureReal_iUnion_fintype_le M
      _ ≤ ∑_s:Fin r,B:=Finset.sum_le_sum (fun s _=>
        BatchTwoActivation.smallPrior_internal_approximation_tail hd hN hσ a K B s hmat)
      _ = _:=by simp
  calc
    _ ≤ μ.real ((F∪R)∪⋃s,M s):=measureReal_mono (badSpectral_subset a K) (measure_ne_top μ _)
    _ ≤ μ.real (F∪R)+μ.real (⋃s,M s):=measureReal_union_le _ _
    _ ≤ μ.real F+μ.real R+μ.real (⋃s,M s):=add_le_add (measureReal_union_le F R) le_rfl
    _ ≤ _:=by linarith

theorem spectral_prefactor_absorption {r : ℕ} {K σ : ℝ} (hσ : 0<σ)
    (hcost : 8*σ^2≤K) :
    2*((r:ℝ)+1)*Real.exp (-K/(4*σ^2))≤((r:ℝ)+2)*Real.exp (-K/(8*σ^2)) := by
  let t:=K/(8*σ^2)
  have ht:1≤t:=(one_le_div (by positivity)).mpr hcost
  have he:2≤Real.exp t:=by linarith [Real.add_one_le_exp t]
  have hrec:Real.exp (-K/(4*σ^2))*Real.exp t=Real.exp (-K/(8*σ^2)):=by
    rw [←Real.exp_add]
    congr 1
    dsimp [t]
    ring
  have hh:=mul_le_mul_of_nonneg_left he (Real.exp_pos (-K/(4*σ^2))).le
  rw [hrec] at hh
  have hr:0≤(r:ℝ):=Nat.cast_nonneg _
  nlinarith [Real.exp_pos (-K/(8*σ^2))]

theorem smallPrior_normFunctions_tail {d N r : ℕ} {K σ : ℝ}
    (hd : 1≤d) (hN : 0<N) (hK : 1≤K) (hσ : 0<σ)
    (hφ : admissibleActivation φ)
    (hfirst : 8*((N*(d+1):ℕ):ℝ)*σ^2≤K)
    (hscale : 8*σ*Real.sqrt (N:ℝ)≤spectralRadius r K) :
    (∑f∈Finset.univ\normFunctions d r φ (((r:ℝ)+5)*K),
      functionMass φ (1/2) (smallPrior d N r σ) f)≤
      ((r:ℝ)+2)*Real.exp (-K/(8*σ^2)) := by
  have hn:1≤(N:ℝ):=by exact_mod_cast hN
  have hd0:0≤(d:ℝ):=Nat.cast_nonneg _
  have hread:8*(N:ℝ)*σ^2≤K:=by
    push_cast at hfirst
    nlinarith [sq_nonneg σ]
  have hcost:8*σ^2≤K:=by nlinarith [sq_nonneg σ]
  have hmat:=gaussian_matrix_spectral_tail (by omega : 1≤N) hσ hscale (K:=K)
  have ht:=smallPrior_badSpectral_tail (r:=r) (by omega) hN hσ (spectralRadius r K) K
    (2*Real.exp (-K/(4*σ^2))) hfirst hread hmat
  exact (spectral_normFunctions_complement_mass_le hd hN hK φ hφ _).trans
    ((ht.trans_eq (by ring)).trans (spectral_prefactor_absorption hσ hcost))

end NeuralGeneralization.BatchTwoOnlineSharp
