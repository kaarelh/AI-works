import NeuralGeneralization.OnlineLowerTanhOptimizerConcentration
import NeuralGeneralization.OnlineLowerTanhLatticeBulkCLT

/-! # Literal near-balanced bulks of actual maximizers -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

structure NearBalancedSequence where
  N : ℕ → ℕ
  N_pos : ∀ k,0 < N k
  N_odd : ∀ k,Odd (N k)
  N_tendsto : Tendsto N atTop atTop
  u : (k : ℕ) → Fin (N k) → ℝ
  u_nonneg : ∀ k i,0 ≤ u k i
  maximal : ∀ k,IsIntrinsicMaximizer (u k)
  bulk : (k : ℕ) → Finset (Fin (N k))
  bulk_tendsto : Tendsto (fun k => (bulk k).card) atTop atTop
  bulk_fraction : Tendsto (fun k => (N k:ℝ)⁻¹*((bulk k).card:ℝ)) atTop (𝓝 1)
  a : ℕ → ℝ
  a_tendsto : Tendsto a atTop (𝓝 limitingGain)
  D : ℕ → ℝ
  D_nonneg : ∀ k,0 ≤ D k
  D_tendsto : Tendsto D atTop (𝓝 0)
  K : ℝ
  K_nonneg : 0 ≤ K
  bulk_close : ∀ k i,i∈bulk k → |u k i-a k| ≤ D k
  bulk_energy : ∀ k,(∑ i ∈ bulk k,(u k i-a k)^2) ≤ K
  full_energy : Tendsto (fun k => incomingEnergy (u k)/(N k:ℝ)) atTop (𝓝 (limitingGain^2))
  rms : Tendsto (fun k => (N k:ℝ)⁻¹*(∑ i,(u k i-limitingGain)^2)) atTop (𝓝 0)
  efficiency_lower : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)

namespace OptimizerLatticeLimit
variable {r : ℕ → ℕ} {u : ∀ k,Fin (2*r k+1) → ℝ} (O : OptimizerLatticeLimit r u)

lemma singleton_bulk_fraction (hr : Tendsto r atTop atTop) (g : ℕ)
    (hp : O.p=(fun j => if j=g then 1 else 0)) :
    Tendsto (fun k => ((2*r (O.map k)+1:ℕ):ℝ)⁻¹*
      (((O.latticeSequence hr).bulk {g} k).card:ℝ)) atTop (𝓝 1) := by
  have h := threshold_pruned_card_ratio_tendsto
    (O.latticeSequence hr).N (O.latticeSequence hr).N_pos (O.latticeSequence hr).N_tendsto
    (O.latticeSequence hr).q (O.latticeSequence hr).residual (O.latticeSequence hr).K
    (O.latticeSequence hr).residual_bound (O.latticeSequence hr).p
    (O.latticeSequence hr).frequency_tendsto {g}
  simpa [latticeSequence,hp,LatticeSequence.bulk,LatticeSequence.threshold] using h

lemma singleton_bulk_tendsto (hr : Tendsto r atTop atTop) (g : ℕ)
    (hp : O.p=(fun j => if j=g then 1 else 0)) :
    Tendsto (fun k => ((O.latticeSequence hr).bulk {g} k).card) atTop atTop := by
  apply (O.latticeSequence hr).bulk_card_tendsto
  simp [latticeSequence,hp]

lemma singleton_bulk_close (hr : Tendsto r atTop atTop) (g k : ℕ)
    (i : Fin (2*r (O.map k)+1)) (hi : i∈(O.latticeSequence hr).bulk {g} k) :
    abs (|u (O.map k) i|-O.data.spacing (O.map k)*g) ≤ latticeResidualThreshold (2*r (O.map k)+1) := by
  have hh := (Finset.mem_filter.mp hi).2
  have hq : O.data.label (O.map k) i=g := by simpa [latticeSequence] using hh.1
  have hclose := hh.2
  change abs (|u (O.map k) i|-O.data.spacing (O.map k)*(O.data.label (O.map k) i:ℝ)) ≤ _ at hclose
  simpa only [hq,LatticeSequence.threshold,latticeSequence] using hclose

lemma singleton_bulk_energy (hr : Tendsto r atTop atTop) (g k : ℕ) :
    (∑ i ∈ (O.latticeSequence hr).bulk {g} k,(|u (O.map k) i|-O.data.spacing (O.map k)*g)^2)
      ≤ O.data.residualBound := by
  have he : (∑ i ∈ (O.latticeSequence hr).bulk {g} k,(|u (O.map k) i|-O.data.spacing (O.map k)*g)^2)=
      ∑ i ∈ (O.latticeSequence hr).bulk {g} k,
        (|u (O.map k) i|-O.data.spacing (O.map k)*(O.data.label (O.map k) i:ℝ))^2 := by
    apply Finset.sum_congr rfl
    intro i hi
    have hh := (Finset.mem_filter.mp hi).2.1
    have hq : O.data.label (O.map k) i=g := by simpa [latticeSequence] using hh
    rw [hq]
  rw [he]
  exact (Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun i _ _ => sq_nonneg _)).trans (O.data.residual_le (O.map k))

/-- This is an actual bulk of absolute incoming coordinates of the original
maximizers; all asymptotic properties have already been proved. -/
def nearBulk (hr : Tendsto r atTop atTop) (hu : ∀ k,IsIntrinsicMaximizer (u k))
    (g : ℕ) (ha : O.a₀*g=limitingGain) (hp : O.p=(fun j => if j=g then 1 else 0)) :
    NearBalancedSequence where
  N := fun k => 2*r (O.map k)+1
  N_pos := fun _ => by omega
  N_odd := fun k => ⟨r (O.map k),rfl⟩
  N_tendsto := O.degree_tendsto hr
  u := fun k i => |u (O.map k) i|
  u_nonneg := fun _ _ => abs_nonneg _
  maximal := fun k => IsIntrinsicMaximizer_abs_weights _ (hu (O.map k))
  bulk := (O.latticeSequence hr).bulk {g}
  bulk_tendsto := O.singleton_bulk_tendsto hr g hp
  bulk_fraction := O.singleton_bulk_fraction hr g hp
  a := fun k => O.data.spacing (O.map k)*g
  a_tendsto := by simpa only [ha] using O.a_tendsto.mul_const (g:ℝ)
  D := fun k => latticeResidualThreshold (2*r (O.map k)+1)
  D_nonneg := fun k => (latticeResidualThreshold_pos (by omega)).le
  D_tendsto := latticeResidualThreshold_tendsto _ (O.degree_tendsto hr)
  K := O.data.residualBound
  K_nonneg := O.data.residualBound_nonneg
  bulk_close := O.singleton_bulk_close hr g
  bulk_energy := O.singleton_bulk_energy hr g
  full_energy := by simpa only [incomingEnergy_abs] using O.actual_energy_limit hr hu
  rms := by simpa only [abs_abs] using O.rms_concentration hr hu
  efficiency_lower := by
    have h := maximizer_efficiency_eventual_lower (fun k => r (O.map k))
      (hr.comp O.strictMono.tendsto_atTop) (fun k => u (O.map k)) (fun k => hu (O.map k))
    simpa only [intrinsicEfficiency,intrinsicGain_abs_weights] using h

end OptimizerLatticeLimit

namespace NearBalancedSequence
variable (B : NearBalancedSequence)

lemma outside_energy_tendsto :
    Tendsto (fun k => (B.N k:ℝ)⁻¹*(∑ i ∈ (B.bulk k)ᶜ,(B.u k i)^2)) atTop (𝓝 0) := by
  apply complement_energy_fraction_tendsto B.N B.N_pos B.u B.bulk limitingGain B.bulk_fraction
  simpa only [abs_of_nonneg (B.u_nonneg _ _)] using B.rms

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
