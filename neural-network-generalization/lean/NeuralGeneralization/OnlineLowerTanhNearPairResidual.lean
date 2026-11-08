import NeuralGeneralization.OnlineLowerTanhNearBulkResidual
import NeuralGeneralization.OnlineLowerTanhNearBulkErase
import NeuralGeneralization.OnlineLowerTanhNearBulkReindex
import NeuralGeneralization.OnlineLowerTanhNearBulkEfficiency
import NeuralGeneralization.OnlineLowerTanhNestedSubset
import NeuralGeneralization.OnlineLowerTanhGenericPair

/-! # Literal residual data after removing an arbitrary pair

The selected coordinates are the original near-balanced bulk minus the two
physical coordinates.  The residual arrays preserve those coordinates exactly.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

structure NearPairResidualData (B : NearBalancedSequence)
    (i j : ∀ k,Fin (B.N k)) where
  φ : ℕ → ℕ
  strictMono : StrictMono φ
  S : ResidualSequence Unit
  hi_le : S.hi ≤ 2
  gain_limit : Tendsto S.A atTop (𝓝 limitingGain)
  selected : ∀ k,Finset (Fin (erasedPairSet (i (φ k)) (j (φ k))).card)
  e : ∀ k,Fin (S.N k) ≃ Fin (selected k).card
  incoming_eq : ∀ k,S.incoming k=(fun l => subsetWeights (selected k)
    (subsetWeights (erasedPairSet (i (φ k)) (j (φ k))) (B.u (φ k))) (e k l))
  variance_fraction : Tendsto (fun k => residualVariance (S.alphabet k)/(B.N (φ k):ℝ))
    atTop (𝓝 1)
  outside_fraction : Tendsto (fun k => incomingEnergy (subsetWeights (selected k)ᶜ
    (subsetWeights (erasedPairSet (i (φ k)) (j (φ k))) (B.u (φ k)))) /
      residualVariance (S.alphabet k)) atTop (𝓝 0)

namespace NearBalancedSequence
variable (B : NearBalancedSequence) (i j : ∀ k,Fin (B.N k))

lemma erased_bulk_subset_rest (k : ℕ) :
    (B.erasePair i j).bulk k ⊆ erasedPairSet (i k) (j k) := by
  intro l hl
  rw [mem_erasedPairSet]
  exact ⟨fun h => B.not_mem_erasePair_left i j k (h ▸ hl),
    fun h => B.not_mem_erasePair_right i j k (h ▸ hl)⟩

theorem exists_pair_residual_data : Nonempty (NearPairResidualData B i j) := by
  let C := B.erasePair i j
  obtain ⟨φ,E,h,hupper⟩ := C.residual_subsequence
  have hH : C.toResidualPresequence.A₀ ≤ (3/2:ℝ) := by
    change limitingGain ≤ (3/2:ℝ)
    linarith [limitingGain_mem.2]
  let S := C.toResidualPresequence.toResidualSequenceWithUpper φ E (3/2) h hH hupper
  let A := fun k => nestedInside (erasedPairSet (i (φ k)) (j (φ k))) (C.bulk (φ k))
  have hsub (k : ℕ) : C.bulk (φ k) ⊆ erasedPairSet (i (φ k)) (j (φ k)) :=
    B.erased_bulk_subset_rest i j (φ k)
  have hV (k : ℕ) : residualVariance (S.alphabet k)=((C.bulk (φ k)).card:ℝ) := by
    simp [S,ResidualPresequence.toResidualSequenceWithUpper,
      ResidualPresequence.toResidualSequence,ResidualSequence.alphabet,
      toResidualPresequence,residualVariance]
  have hfrac : Tendsto (fun k => residualVariance (S.alphabet k)/(B.N (φ k):ℝ))
      atTop (𝓝 1) := by
    have ht := C.bulk_fraction.comp h.strictMono.tendsto_atTop
    change Tendsto (fun k => (B.N (φ k):ℝ)⁻¹*((C.bulk (φ k)).card:ℝ)) atTop (𝓝 1) at ht
    simpa only [hV,div_eq_mul_inv,mul_comm] using ht
  have hout0 : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ
      (subsetWeights (erasedPairSet (i (φ k)) (j (φ k))) (B.u (φ k)))) /
        (B.N (φ k):ℝ)) atTop (𝓝 0) := by
    have ht := C.outside_energy_tendsto.comp h.strictMono.tendsto_atTop
    change Tendsto (fun k => (B.N (φ k):ℝ)⁻¹*(∑ l ∈ (C.bulk (φ k))ᶜ,(B.u (φ k) l)^2)) atTop (𝓝 0) at ht
    apply squeeze_zero _ _ ht
    · intro k
      exact div_nonneg (incomingEnergy_nonneg _) (Nat.cast_nonneg _)
    · intro k
      have hh := nested_outside_energy_le (hsub k) (B.u (φ k))
      have hm := div_le_div_of_nonneg_right hh (Nat.cast_nonneg (B.N (φ k)) : (0:ℝ) ≤ _)
      simpa only [A,incomingEnergy_subsetWeights,div_eq_mul_inv,mul_comm] using hm
  have hout : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ
      (subsetWeights (erasedPairSet (i (φ k)) (j (φ k))) (B.u (φ k)))) /
        residualVariance (S.alphabet k)) atTop (𝓝 0) := by
    have ht := hout0.div hfrac (by norm_num : (1:ℝ) ≠ 0)
    simp only [zero_div] at ht
    convert ht using 1
    funext k
    have hn : (B.N (φ k):ℝ) ≠ 0 := by exact_mod_cast (B.N_pos (φ k)).ne'
    dsimp only [Pi.div_apply]
    exact (div_div_div_cancel_right₀ hn _ _).symm
  refine ⟨{
    φ := φ
    strictMono := h.strictMono
    S := S
    hi_le := by norm_num [S,ResidualPresequence.toResidualSequenceWithUpper]
    gain_limit := C.bulkRefitGain_tendsto.comp h.strictMono.tendsto_atTop
    selected := A
    e := fun k => nestedSubsetFinEquiv (hsub k)
    incoming_eq := ?_
    variance_fraction := hfrac
    outside_fraction := hout }⟩
  intro k
  change C.toResidualPresequence.incoming (φ k)=_
  rw [C.toResidualPresequence_incoming]
  exact (nested_subsetWeights_reindex (hsub k) (B.u (φ k))).symm

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
