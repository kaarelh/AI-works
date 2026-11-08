import NeuralGeneralization.OnlineLowerTanhResidualPruning
import NeuralGeneralization.OnlineLowerTanhResidualRefit

/-! # A concrete vanishing threshold and finite-alphabet bulk limits -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def latticeResidualThreshold (n : ℕ) : ℝ := (n:ℝ)^(-(1/4:ℝ))

lemma latticeResidualThreshold_pos {n : ℕ} (hn : 0 < n) :
    0 < latticeResidualThreshold n := Real.rpow_pos_of_pos (by exact_mod_cast hn) _

lemma latticeResidualThreshold_tendsto (N : ℕ → ℕ) (hN : Tendsto N atTop atTop) :
    Tendsto (fun k => latticeResidualThreshold (N k)) atTop (𝓝 0) := by
  exact (tendsto_rpow_neg_atTop (by norm_num : (0:ℝ)<1/4)).comp
    (tendsto_natCast_atTop_atTop.comp hN)

lemma latticeResidualThreshold_denominator {n : ℕ} (hn : 0 < n) :
    (n:ℝ)*(latticeResidualThreshold n)^2=(n:ℝ)^(1/2:ℝ) := by
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  unfold latticeResidualThreshold
  rw [←Real.rpow_mul_natCast hnR.le]
  norm_num
  calc
    (n:ℝ)*(n:ℝ)^(-(1/2:ℝ)) = (n:ℝ)^(1:ℝ)*(n:ℝ)^(-(1/2:ℝ)) := by rw [Real.rpow_one]
    _ = (n:ℝ)^((1:ℝ)+(-(1/2:ℝ))) := (Real.rpow_add hnR _ _).symm
    _ = _ := by norm_num

lemma latticeResidualThreshold_bad_tendsto (N : ℕ → ℕ) (hpos : ∀ k, 0 < N k)
    (hN : Tendsto N atTop atTop) (K : ℝ) :
    Tendsto (fun k => K/((N k:ℝ)*(latticeResidualThreshold (N k))^2)) atTop (𝓝 0) := by
  simp_rw [latticeResidualThreshold_denominator (hpos _)]
  exact tendsto_const_nhds.div_atTop
    ((tendsto_rpow_atTop (by norm_num : (0:ℝ)<1/2)).comp
      (tendsto_natCast_atTop_atTop.comp hN))

section Bulk
variable (N : ℕ → ℕ) (hpos : ∀ k, 0 < N k) (hN : Tendsto N atTop atTop)
    (q : ∀ k, Fin (N k) → ℕ) (d : ∀ k, Fin (N k) → ℝ) (K : ℝ)
    (hK : ∀ k, (∑ i,(d k i)^2) ≤ K) (p : ℕ → ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j)))
include hpos hN hK hp

lemma threshold_pruned_frequency_tendsto (j : ℕ) :
    Tendsto (fun k => prunedEmpiricalMass (q k) (d k) (latticeResidualThreshold (N k)) j)
      atTop (𝓝 (p j)) :=
  prunedEmpiricalMass_tendsto N hpos q d _ K
    (fun k => latticeResidualThreshold_pos (hpos k)) hK
    (latticeResidualThreshold_bad_tendsto N hpos hN K) p hp j

lemma threshold_pruned_card_ratio_tendsto (S : Finset ℕ) :
    Tendsto (fun k => (N k:ℝ)⁻¹*
      (prunedLatticeIndices (q k) (d k) (latticeResidualThreshold (N k)) S).card)
      atTop (𝓝 (∑ j ∈ S,p j)) := by
  simp_rw [prunedLattice_card]
  exact tendsto_finsetSum _ (fun j _ => threshold_pruned_frequency_tendsto N hpos hN q d K hK p hp j)

lemma threshold_pruned_moment_ratio_tendsto (S : Finset ℕ) :
    Tendsto (fun k => (N k:ℝ)⁻¹*
      (∑ i ∈ prunedLatticeIndices (q k) (d k) (latticeResidualThreshold (N k)) S,(q k i:ℝ)^2))
      atTop (𝓝 (∑ j ∈ S,p j*(j:ℝ)^2)) := by
  simp_rw [prunedLattice_moment]
  exact tendsto_finsetSum _ (fun j _ =>
    (threshold_pruned_frequency_tendsto N hpos hN q d K hK p hp j).mul_const _)

lemma threshold_pruned_card_tendsto (S : Finset ℕ) (hS : 0 < ∑ j ∈ S,p j) :
    Tendsto (fun k => (prunedLatticeIndices (q k) (d k) (latticeResidualThreshold (N k)) S).card)
      atTop atTop := by
  let M (k : ℕ) := (prunedLatticeIndices (q k) (d k) (latticeResidualThreshold (N k)) S).card
  have hr := threshold_pruned_card_ratio_tendsto N hpos hN q d K hK p hp S
  have he : ∀ᶠ k in atTop, (∑ j ∈ S,p j)/2*(N k:ℝ) ≤ (M k:ℝ) := by
    filter_upwards [hr.eventually (lt_mem_nhds (by linarith : (∑ j ∈ S,p j)/2 < ∑ j ∈ S,p j))] with k hk
    have hnR : (0:ℝ)<N k := by exact_mod_cast hpos k
    have hh := (mul_lt_mul_of_pos_right hk hnR).le
    have hc : (N k:ℝ)⁻¹*(M k:ℝ)*(N k:ℝ)=(M k:ℝ) := by field_simp
    change (∑ j ∈ S,p j)/2*(N k:ℝ) ≤ (N k:ℝ)⁻¹*(M k:ℝ)*(N k:ℝ) at hh
    rwa [hc] at hh
  apply (tendsto_natCast_atTop_iff (R := ℝ)).mp
  exact tendsto_atTop_mono' atTop he
    ((tendsto_natCast_atTop_atTop.comp hN).const_mul_atTop (by positivity : 0 < (∑ j ∈ S,p j)/2))

end Bulk
end NeuralGeneralization.OnlineLowerTanh
