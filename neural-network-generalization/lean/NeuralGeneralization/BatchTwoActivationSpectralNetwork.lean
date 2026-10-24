import NeuralGeneralization.BatchTwoActivationSpectralGaussian
import NeuralGeneralization.BatchTwoActivationSpectralReconstruction
import NeuralGeneralization.NetworkSpectralTail

/-! Actual Gaussian network spectral tails at every width and sufficiently
small scale. No fixed exponent or asymptotic width hypothesis is used. -/
noncomputable section
open scoped BigOperators
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

theorem map_smallPrior_whiten_subfamily {d N r:ℕ} {ι:Type*} [Fintype ι]
    (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ) (e:ι→WeightIndex d N r) (he:Function.Injective e):
    (smallPrior d N r σ).map (fun w j=>whiten w (e j))=
      Measure.pi (fun _:ι=>gaussianReal 0 (σ^2).toNNReal):=by
  rw [show (fun (w:Weights d N r) j=>whiten w (e j))=
    (fun (x:Weights d N r) j=>x (e j))∘whiten from rfl,
    ←Measure.map_map (by fun_prop) (continuous_whiten d N r).measurable,
    map_smallPrior_whiten hd hN hσ]
  exact productGaussian_map_subfamily _ e he

theorem smallPrior_whiten_subfamily_tail {d N r:ℕ} {ι:Type*} [Fintype ι]
    (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ) (e:ι→WeightIndex d N r) (he:Function.Injective e)
    (b:ℝ) (hb:8*(Fintype.card ι:ℝ)*σ^2≤b):
    (smallPrior d N r σ).real {w|b≤∑j,(whiten w (e j))^2}≤Real.exp (-b/(4*σ^2)):=by
  have hv:((σ^2).toNNReal:ℝ)=σ^2:=Real.coe_toNNReal _ (sq_nonneg σ)
  have hmap:=map_smallPrior_whiten_subfamily hd hN hσ e he
  have hmeas:Measurable (fun w:Weights d N r=>fun j=>whiten w (e j)):=by
    exact measurable_pi_lambda _ (fun j=>(measurable_pi_apply (e j)).comp (continuous_whiten d N r).measurable)
  have hm:=Measure.le_map_apply (μ:=smallPrior d N r σ) hmeas.aemeasurable {z:ι→ℝ|b≤∑j,z j^2}
  rw [hmap] at hm
  have hr:=ENNReal.toReal_mono (measure_ne_top _ _) hm
  have ht:=gaussian_squaredNorm_upper_tail (ι:=ι) (σ^2).toNNReal
    (by rw [hv];exact sq_pos_of_pos hσ) b (by simpa only [hv] using hb)
  rw [hv] at ht
  exact hr.trans ht

theorem smallPrior_first_energy_tail {d N r:ℕ} (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ)
    (b:ℝ) (hb:8*((N*(d+1):ℕ):ℝ)*σ^2≤b):
    (smallPrior d N r σ).real {w|b≤(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)}≤
      Real.exp (-b/(4*σ^2)):=by
  have hh:=smallPrior_whiten_subfamily_tail hd hN (r:=r) hσ
    (Sum.inl:Fin N×Fin (d+1)→WeightIndex d N r) Sum.inl_injective b (by simpa using hb)
  simpa only [first_energy_eq_whitened hd hN] using hh

theorem smallPrior_readout_energy_tail {d N r:ℕ} (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ)
    (b:ℝ) (hb:8*(N:ℝ)*σ^2≤b):
    (smallPrior d N r σ).real {w|b≤(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)}≤
      Real.exp (-b/(4*σ^2)):=by
  have hh:=smallPrior_whiten_subfamily_tail hd hN (r:=r) hσ
    (fun i:Fin N=>Sum.inr (Sum.inr i)) (Sum.inr_injective.comp Sum.inr_injective) b (by simpa using hb)
  simpa only [readout_energy_eq_whitened hd hN] using hh

theorem map_smallPrior_internal {d N r:ℕ} (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ) (s:Fin r):
    (smallPrior d N r σ).map (fun w (ij:Fin N×Fin N)=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))=
      Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal):=by
  have he:Function.Injective (fun ij:Fin N×Fin N=>(Sum.inr (Sum.inl (s,ij.1,ij.2)):WeightIndex d N r)):=by
    intro ij kl h
    simpa using h
  simpa only [whiten_internal] using map_smallPrior_whiten_subfamily hd hN hσ _ he

theorem smallPrior_internal_approximation_tail {d N r:ℕ} (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ)
    (a K B:ℝ) (s:Fin r)
    (hmat:(Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal)).real
      (matrixApproximationFailure N a K)≤B):
    (smallPrior d N r σ).real {w|(fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))∈matrixApproximationFailure N a K}≤B:=by
  have hm:=Measure.le_map_apply (μ:=smallPrior d N r σ)
    (show Measurable (fun (w:Weights d N r) (ij:Fin N×Fin N)=>w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) by fun_prop).aemeasurable
      (matrixApproximationFailure N a K)
  rw [map_smallPrior_internal hd hN hσ s] at hm
  exact (ENNReal.toReal_mono (measure_ne_top _ _) hm).trans hmat

theorem smallPrior_badSpectralWeights_tail {d N r K:ℕ} (hd:0<d) (hN:0<N) {σ:ℝ} (hσ:0<σ)
    (a B:ℝ) (hfirst:8*((N*(d+1):ℕ):ℝ)*σ^2≤(K:ℝ)) (hread:8*(N:ℝ)*σ^2≤(K:ℝ))
    (hmat:(Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal)).real
      (matrixApproximationFailure N a K)≤B):
    (smallPrior d N r σ).real (goodSpectralWeightsAtRadius d N r K a)ᶜ≤
      2*Real.exp (-(K:ℝ)/(4*σ^2))+(r:ℝ)*B:=by
  classical
  let μ:=smallPrior d N r σ
  let F:Set (Weights d N r):={w|(K:ℝ)≤(d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)}
  let R:Set (Weights d N r):={w|(K:ℝ)≤(N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)}
  let M (s:Fin r):Set (Weights d N r):=
    {w|(fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))∈matrixApproximationFailure N a K}
  have hF:μ.real F≤Real.exp (-(K:ℝ)/(4*σ^2)):=smallPrior_first_energy_tail hd hN hσ K hfirst
  have hR:μ.real R≤Real.exp (-(K:ℝ)/(4*σ^2)):=smallPrior_readout_energy_tail hd hN hσ K hread
  have hM:μ.real (⋃s,M s)≤(r:ℝ)*B:=by
    calc
      _ ≤ ∑s,μ.real (M s):=measureReal_iUnion_fintype_le M
      _ ≤ ∑_s:Fin r,B:=Finset.sum_le_sum (fun s _=>smallPrior_internal_approximation_tail hd hN hσ a K B s hmat)
      _ = _:=by simp
  calc
    _ ≤ μ.real ((F∪R)∪⋃s,M s):=measureReal_mono (badSpectralWeights_subset a) (measure_ne_top μ _)
    _ ≤ μ.real (F∪R)+μ.real (⋃s,M s):=measureReal_union_le _ _
    _ ≤ μ.real F+μ.real R+μ.real (⋃s,M s):=add_le_add (measureReal_union_le F R) le_rfl
    _ ≤ _:=by linarith

/-- The complete small-scale spectral branch, for the actual raw function prior.
The finite common class is independent of learner width and Gaussian scale. -/
theorem smallPrior_energyFunctions_spectral_tail {d N r K:ℕ} (hd:1≤d) (hN:0<N)
    {φ:ℝ→ℝ} {ℓ σ:ℝ} (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (hσ:0<σ)
    (hfirst:8*((N*(d+1):ℕ):ℝ)*σ^2≤(K:ℝ))
    (hscale:16*σ*Real.sqrt (N:ℝ)≤activationSpectralRadius d r ℓ K):
    (∑f∈Finset.univ\energyFunctions d r φ (((r:ℝ)+5)*K),
      functionMass φ (1/2) (smallPrior d N r σ) f)≤
        2*((r:ℝ)+1)*Real.exp (-(K:ℝ)/(4*σ^2)):=by
  have hread:8*(N:ℝ)*σ^2≤(K:ℝ):=by
    have hd0:(0:ℝ)≤d:=Nat.cast_nonneg d
    push_cast at hfirst
    nlinarith [sq_nonneg σ]
  have hmat:=gaussian_matrix_spectral_tail (by omega : 1≤N) hσ hscale (K:=(K:ℝ))
  have ht:=smallPrior_badSpectralWeights_tail (r:=r) (by omega) hN hσ (activationSpectralRadius d r ℓ K)
    (2*Real.exp (-(K:ℝ)/(4*σ^2))) hfirst hread hmat
  exact (spectral_energyFunctions_complement_mass_le hd hN hφ hℓ (smallPrior d N r σ)).trans
    (ht.trans_eq (by ring))


/-- The same branch in the manuscript's width-normalized scale t. -/
theorem bandPrior_energyFunctions_spectral_tail {d N r K:ℕ} (hd:1≤d) (hN:0<N)
    {φ:ℝ→ℝ} {ℓ t:ℝ} (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (ht:0<t)
    (hfirst:8*((d:ℝ)+1)*t^2≤(K:ℝ))
    (hscale:16*t≤activationSpectralRadius d r ℓ K):
    (∑f∈Finset.univ\energyFunctions d r φ (((r:ℝ)+5)*K),
      functionMass φ (1/2) (activationBandPrior d N r t) f)≤
        2*((r:ℝ)+1)*Real.exp (-(N:ℝ)*K/(4*t^2)):=by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hs:0<Real.sqrt (N:ℝ):=Real.sqrt_pos.mpr hn
  have hσ:0<t/Real.sqrt (N:ℝ):=by positivity
  have he:8*((N*(d+1):ℕ):ℝ)*(t/Real.sqrt (N:ℝ))^2=8*((d:ℝ)+1)*t^2:=by
    push_cast
    rw [div_pow,Real.sq_sqrt hn.le]
    field_simp
  have ha:16*(t/Real.sqrt (N:ℝ))*Real.sqrt (N:ℝ)≤activationSpectralRadius d r ℓ K:=by
    have hh:16*(t/Real.sqrt (N:ℝ))*Real.sqrt (N:ℝ)=16*t:=by field_simp
    rw [hh]
    exact hscale
  have htail:=smallPrior_energyFunctions_spectral_tail hd hN hφ hℓ hσ (by rw [he];exact hfirst) ha
  have hpow:-(K:ℝ)/(4*(t/Real.sqrt (N:ℝ))^2)=-(N:ℝ)*K/(4*t^2):=by
    rw [div_pow,Real.sq_sqrt hn.le]
    field_simp
  simpa only [activationBandPrior,hpow] using htail

end NeuralGeneralization.BatchTwoActivation
