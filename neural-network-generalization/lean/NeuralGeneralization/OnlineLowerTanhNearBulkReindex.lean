import NeuralGeneralization.OnlineLowerTanhNearBulk

/-! # Cofinal reindexing of actual near-balanced maximizers -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B : NearBalancedSequence)

def reindex (φ : ℕ → ℕ) (hφ : Tendsto φ atTop atTop) : NearBalancedSequence where
  N := fun k => B.N (φ k)
  N_pos := fun k => B.N_pos (φ k)
  N_odd := fun k => B.N_odd (φ k)
  N_tendsto := B.N_tendsto.comp hφ
  u := fun k => B.u (φ k)
  u_nonneg := fun k => B.u_nonneg (φ k)
  maximal := fun k => B.maximal (φ k)
  bulk := fun k => B.bulk (φ k)
  bulk_tendsto := B.bulk_tendsto.comp hφ
  bulk_fraction := B.bulk_fraction.comp hφ
  a := fun k => B.a (φ k)
  a_tendsto := B.a_tendsto.comp hφ
  D := fun k => B.D (φ k)
  D_nonneg := fun k => B.D_nonneg (φ k)
  D_tendsto := B.D_tendsto.comp hφ
  K := B.K
  K_nonneg := B.K_nonneg
  bulk_close := fun k => B.bulk_close (φ k)
  bulk_energy := fun k => B.bulk_energy (φ k)
  full_energy := B.full_energy.comp hφ
  rms := B.rms.comp hφ
  efficiency_lower := fun ε hε => hφ.eventually (B.efficiency_lower ε hε)

lemma bulk_coordinate_tendsto (i : ∀ k,Fin (B.N k)) (hi : ∀ k,i k∈B.bulk k) :
    Tendsto (fun k => B.u k (i k)) atTop (𝓝 limitingGain) := by
  have hd : Tendsto (fun k => B.u k (i k)-B.a k) atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ B.D_tendsto
    exact Eventually.of_forall (fun k => by
      simpa only [Real.norm_eq_abs] using B.bulk_close k (i k) (hi k))
  simpa only [sub_add_cancel,zero_add] using hd.add B.a_tendsto

lemma near_pair_mean_tendsto (i j : ∀ k,Fin (B.N k))
    (hi : Tendsto (fun k => B.u k (i k)) atTop (𝓝 limitingGain))
    (hj : Tendsto (fun k => B.u k (j k)) atTop (𝓝 limitingGain)) :
    Tendsto (fun k => (B.u k (i k)+B.u k (j k))/2) atTop (𝓝 limitingGain) := by
  convert (hi.add hj).div_const 2 using 1 <;> ring

lemma near_pair_imbalance_tendsto (i j : ∀ k,Fin (B.N k))
    (hi : Tendsto (fun k => B.u k (i k)) atTop (𝓝 limitingGain))
    (hj : Tendsto (fun k => B.u k (j k)) atTop (𝓝 limitingGain)) :
    Tendsto (fun k => (B.u k (i k)-B.u k (j k))/2) atTop (𝓝 0) := by
  simpa only [sub_self,zero_div] using (hi.sub hj).div_const 2

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
