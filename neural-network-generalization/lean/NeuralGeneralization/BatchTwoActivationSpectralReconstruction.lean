import NeuralGeneralization.BatchTwoActivationSpectralStability
import NeuralGeneralization.BatchTwoActivationStrongPrior

/-! Every spectrally good actual learner has a same-activation, bounded-energy
strict-margin implementation, independent of learner width. -/
noncomputable section
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {d N r K:ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}

theorem spectral_truncation_energy_witness (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (f:BooleanFunction d)
    (w:Weights d N r) (hw:w∈marginEvent φ (1/2) f)
    (hgood:w∈goodSpectralWeightsAtRadius d N r K (activationSpectralRadius d r ℓ K)):
    ∃v:Weights d N r,v∈marginEvent φ (1/2) f ∧ weightedSquaredNorm v≤((r:ℝ)+5)*K := by
  classical
  obtain ⟨hfirst,hread,hmat⟩:=hgood
  choose H hH hres using hmat
  let HH:Fin r→Fin N→Fin N→ℝ:=fun s i j=>H s (i,j)
  have hH':∀s,(∑i,∑j,HH s i j^2)≤(K:ℝ):=by
    intro s
    simpa only [LowRankGrid.squaredSum,Fintype.sum_prod_type] using hH s
  have hres':∀s,matrixActionBound
      (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-HH s i j) (activationSpectralRadius d r ℓ K):=by
    intro s x
    exact matrix_residual_action_bound _ (H s) _
      (activationSpectralRadius_bounds d r ℓ (Nat.cast_nonneg K)).1.le (hres s) x
  let v:=rescaleReadout (3/2) (truncateInternal w HH)
  refine ⟨v,rescaleReadout_preserves_margin φ f w (truncateInternal w HH) hw
    (spectral_networkOutput_error hd hN hφ hℓ (Nat.cast_nonneg K) w HH hfirst hread hH' hres'),?_⟩
  have hi:(∑s,∑i,∑j,HH s i j^2)≤(r:ℝ)*K:=by
    calc
      _ ≤ ∑_s:Fin r,(K:ℝ):=Finset.sum_le_sum (fun s _=>hH' s)
      _ = _:=by simp
  change weightedSquaredNorm (rescaleReadout (3/2) (truncateInternal w HH))≤_
  simp only [weightedSquaredNorm,rescaleReadout,truncateInternal,mul_pow,←Finset.mul_sum]
  have hK:0≤(K:ℝ):=Nat.cast_nonneg K
  nlinarith only [hfirst,hread,hi,hK]

theorem spectral_good_mem_energyFunctions (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (f:BooleanFunction d)
    (w:Weights d N r) (hw:w∈marginEvent φ (1/2) f)
    (hgood:w∈goodSpectralWeightsAtRadius d N r K (activationSpectralRadius d r ℓ K)):
    f∈energyFunctions d r φ (((r:ℝ)+5)*K) := by
  classical
  obtain ⟨v,hv,hcost⟩:=spectral_truncation_energy_witness hd hN hφ hℓ f w hw hgood
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,N,hN,v,hcost,fun x=>(hv x).le⟩

/-- The raw mass, before global-margin or training conditioning, of all excluded
functions is controlled by the actual operator-approximation failure event. -/
theorem spectral_energyFunctions_complement_mass_le (hd:1≤d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    (μ:Measure (Weights d N r)) [IsFiniteMeasure μ]:
    (∑f∈Finset.univ\energyFunctions d r φ (((r:ℝ)+5)*K),functionMass φ (1/2) μ f)≤
      μ.real (goodSpectralWeightsAtRadius d N r K (activationSpectralRadius d r ℓ K))ᶜ := by
  classical
  let A:=Finset.univ\energyFunctions d r φ (((r:ℝ)+5)*K)
  have heq:μ.real (⋃f∈A,marginEvent φ (1/2) f)=∑f∈A,functionMass φ (1/2) μ f:=by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg=>marginEvents_disjoint φ (by norm_num) hfg)
      (fun f _=>(isOpen_marginEvent (zeroLipschitzActivation_continuous hφ hℓ) (1/2) f).measurableSet)
  rw [←heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f,hf,hwf⟩:=Set.mem_iUnion₂.mp hw
  exact (Finset.mem_sdiff.mp hf).2 (spectral_good_mem_energyFunctions hd hN hφ hℓ f w hwf hgood)

end NeuralGeneralization.BatchTwoActivation
