import NeuralGeneralization.OnlineLowerReluRailAtom
import NeuralGeneralization.OnlineLowerReluFamilyWeights
import NeuralGeneralization.OnlineLowerGeometryFamily
import NeuralGeneralization.OnlineLowerNetworkActivation

/-! # The unconditional atom norm bound for the explicit logical rail family -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry

def fullRailSupport {p : ℕ} (size : Fin p → Bool → ℕ) (τ : Finset (Fin p)) :
    Finset (Fin (railDimension size)) :=
  Finset.univ.biUnion (fun i => physicalRail size i (decide (i ∈ τ)))

def fullRailCost {p : ℕ} (size : Fin p → Bool → ℕ) (τ : Finset (Fin p)) : ℝ :=
  evenReluCost (((fullRailSupport size τ).card - 2) / 2)

theorem fullRailCost_nonneg {p : ℕ} (size : Fin p → Bool → ℕ) (τ : Finset (Fin p)) :
    0 ≤ fullRailCost size τ :=
  div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le

/-- The canonical sampler theorem expressed for arbitrary actual rail sizes,
so its conclusion uses the original physical coordinate enumeration. -/
theorem full_rail_norm_of_size {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side, 2 ≤ size i side)
    (heven : ∀ i side, Even (size i side))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hmin : ∀ i side, R ≤ (size i side : ℝ))
    (hdiff : ∀ i, |(size i true : ℝ) - size i false| ≤ Δ)
    (u : Fin (railDimension size) → ℝ) (bias : ℝ) :
    retainedFourierMass (fullRailSupport size) (fullRailCost size)
      (fun x => max (cubeAffine bias u x) 0) ≤ Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) := by
  have hrepresentation : ∃ P r : Fin p → ℕ, size = samplerSize P r := by
    refine ⟨(fun i => size i false), (fun i => size i true - 2), ?_⟩
    funext i side
    cases side
    · rfl
    · change size i true = size i true - 2 + 2
      have := htwo i true
      omega
  obtain ⟨P,r,rfl⟩ := hrepresentation
  have hPtwo (i) : 2 ≤ P i := htwo i false
  have hPeven (i) : Even (P i) := heven i false
  have hreven (i) : Even (r i) := by
    obtain ⟨v,hv⟩ := heven i true
    change r i + 2 = v + v at hv
    refine ⟨v-1, ?_⟩
    omega
  have hcost (τ : Finset (Fin p)) : fullRailCost (samplerSize P r) τ =
      samplerTransversalCost P r τ := by
    have hc := samplerSupport_card_half P r hPeven hreven τ
    have hs := samplerSupport_two_le (by omega) P r τ hPtwo
    unfold fullRailCost samplerTransversalCost
    change evenReluCost (((samplerSupport P r τ).card - 2) / 2) = _
    congr 1
    omega
  have h := full_rail_atom_norm hp P r hPtwo hPeven hreven R Δ hΔ hR
    (fun i => hmin i false) (fun i => by simpa only [samplerSize, Nat.cast_add, Nat.cast_ofNat] using hmin i true)
    (fun i => by simpa only [samplerSize, Nat.cast_add, Nat.cast_ofNat] using hdiff i) u bias
  unfold retainedFourierMass
  simp only [hcost]
  exact h

namespace Family

def transversalIndex (k : ℕ) (s : Finset (Fin (logicalDim k))) : Finset (Fin (pairDim k)) :=
  Finset.univ.filter (fun i => railOrientation (column k) s i = true)

theorem targetSupport_eq_transversal (R k : ℕ) (s : Finset (Fin (logicalDim k))) :
    targetSupport R k s = fullRailSupport (size R k) (transversalIndex k s) := by
  unfold targetSupport fullRailSupport
  rw [physical_generatedSupport_eq]
  apply Finset.biUnion_congr rfl
  intro i _
  congr 1
  simp [transversalIndex]

theorem transversalIndex_injective (R k : ℕ) (hR : 0 < R) :
    Function.Injective (transversalIndex k) := by
  intro s t h
  apply (physicalCode R k hR).support_injective
  change targetSupport R k s = targetSupport R k t
  rw [targetSupport_eq_transversal, targetSupport_eq_transversal, h]

theorem weight_eq_transversalCost (R k : ℕ) (hR : 2 ≤ R) (heven : Even R)
    (s : Finset (Fin (logicalDim k))) :
    weight R k s = fullRailCost (size R k) (transversalIndex k s) := by
  rw [weight_eq_evenReluCost R k hR heven s]
  unfold fullRailCost degreeIndex
  rw [targetSupport_eq_transversal]

/-- Every actual affine ReLU neuron satisfies the explicit family's weighted
logical-code mass bound. There are no Fourier or sampled-atom assumptions. -/
theorem affine_atom_retained_norm (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    (u : Fin (railDimension (size R k)) → ℝ) (bias : ℝ) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x => max (cubeAffine bias u x) 0) ≤ Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) := by
  have hsub := retainedFourierMass_subfamily (targetSupport R k)
    (fullRailSupport (size R k)) (weight R k) (fullRailCost (size R k))
    (transversalIndex k) (transversalIndex_injective R k (by omega))
    (targetSupport_eq_transversal R k) (weight_eq_transversalCost R k (by omega) heven)
    (fullRailCost_nonneg (size R k)) (fun x => max (cubeAffine bias u x) 0)
  apply hsub.trans
  apply full_rail_norm_of_size (show 2 ≤ pairDim k by rw [pairDim_eq]; omega)
    (size R k) (fun i side => ?_) (size_even R k heven) (R : ℝ) 6
    (by norm_num) (by exact_mod_cast hR) (fun i side => ?_) (fun i => ?_) u bias
  · cases side <;> simp only [size_false, size_true] <;> omega
  · cases side
    · rfl
    · simp only [size_true, Nat.cast_add]
      exact le_add_of_nonneg_right (Nat.cast_nonneg _)
  · simp only [size_true, size_false, Nat.cast_add, add_sub_cancel_left,
      abs_of_nonneg (Nat.cast_nonneg (α := ℝ) (increment k i))]
    exact_mod_cast (increment_bounds k i).2

/-- Literal first hidden-layer row, with the model's actual ReLU convention. -/
theorem actual_row_retained_norm (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    {N : ℕ} (w : ConcreteModel.Weights (railDimension (size R k)) N 0) (j : Fin N) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x => ConcreteModel.firstHidden (fun z : ℝ => max 0 z) w x j) ≤
        incomingEuclideanNorm w j := by
  simpa only [firstHidden_eq_cubeAffine, max_comm,
    incomingEuclideanNorm_eq_sqrt] using
      affine_atom_retained_norm R k hR heven (incomingPhysical w j) (incomingBias w j)

end Family
end NeuralGeneralization.OnlineLowerRelu
