import NeuralGeneralization.OnlineLowerReluAtomClosure
import NeuralGeneralization.OnlineLowerSamplerOrientation

/-! # Concrete paired rails in the arbitrary-weight Fourier balancing theorem -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- Flatten the pair and side indices while preserving each within-rail coordinate. -/
def flatRailCoordEquiv {p : ℕ} (size : Fin p → Bool → ℕ) :
    ((j : Fin p × Bool) × Fin (size j.1 j.2)) ≃ RailCoord size where
  toFun x := ⟨x.1.1, x.1.2, x.2⟩
  invFun x := ⟨(x.1, x.2.1), x.2.2⟩
  left_inv := by rintro ⟨⟨i,b⟩,k⟩; rfl
  right_inv := by rintro ⟨i,b,k⟩; rfl

def railBlockEquiv {p : ℕ} (size : Fin p → Bool → ℕ) :
    ((j : Fin p × Bool) × Fin (size j.1 j.2)) ≃ Fin (railDimension size) :=
  (flatRailCoordEquiv size).trans (railIndex size)

@[simp] theorem railBlockEquiv_apply {p : ℕ} (size : Fin p → Bool → ℕ)
    (i : Fin p) (b : Bool) (k : Fin (size i b)) :
    railBlockEquiv size ⟨(i,b),k⟩ = railIndex size ⟨i,b,k⟩ := rfl

/-- True means that the entire physical block is selected. -/
def railBlockOrientation {p : ℕ} (choice : Fin p → Bool) (j : Fin p × Bool) : Bool :=
  decide (j.2 = choice j.1)

def transversalBlockOrientation {p : ℕ} (τ : Finset (Fin p)) : Fin p × Bool → Bool :=
  railBlockOrientation (fun i => decide (i ∈ τ))

theorem blockSupport_railChoice {p : ℕ} (size : Fin p → Bool → ℕ)
    (choice : Fin p → Bool) :
    blockSupport (railBlockEquiv size) (railBlockOrientation choice) =
      Finset.univ.biUnion (fun i => physicalRail size i (choice i)) := by
  classical
  ext x
  obtain ⟨⟨i,b,k⟩,rfl⟩ := (railIndex size).surjective x
  simp [blockSupport, railBlockOrientation, railBlockEquiv, flatRailCoordEquiv,
    physicalRail, Equiv.trans_apply]

theorem blockSupport_sampler {p : ℕ} (P r : Fin p → ℕ) (τ : Finset (Fin p)) :
    blockSupport (railBlockEquiv (samplerSize P r)) (transversalBlockOrientation τ) =
      samplerSupport P r τ :=
  blockSupport_railChoice _ _

/-- Literal logical code supports are among these same physical block transversals. -/
theorem generatedSupport_eq_blockSupport {p m : ℕ} (size : Fin p → Bool → ℕ)
    (column : Fin p → Finset (Fin m)) (s : Finset (Fin m)) :
    generatedSupport (physicalBase size) (coordinateGenerator (physicalColumn size column)) s =
      blockSupport (railBlockEquiv size) (railBlockOrientation (railOrientation column s)) := by
  rw [physical_generatedSupport_eq, blockSupport_railChoice]

theorem blockWeights_sampler_constant {p : ℕ} (P r : Fin p → ℕ) (a b : Fin p → ℝ) :
    blockWeights (railBlockEquiv (samplerSize P r))
      (fun j _ => if j.2 then b j.1 else a j.1) = samplerWeights P r a b := by
  funext x
  obtain ⟨⟨i,side,k⟩,rfl⟩ := (railIndex (samplerSize P r)).surjective x
  rw [← railBlockEquiv_apply, blockWeights_apply]
  rw [railBlockEquiv_apply, samplerWeights_apply]

def sampledFirstAmplitude {p : ℕ} (P r : Fin p → ℕ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ)
    (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) (i : Fin p) : ℝ :=
  u (i,false) (pick (i,false))

def sampledSecondAmplitude {p : ℕ} (P r : Fin p → ℕ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ)
    (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) (i : Fin p) : ℝ :=
  u (i,true) (pick (i,true))

theorem blockWeights_sampler_sampled {p : ℕ} (P r : Fin p → ℕ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ)
    (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) :
    blockWeights (railBlockEquiv (samplerSize P r)) (sampledBlockWeights u pick) =
      samplerWeights P r (sampledFirstAmplitude P r u pick) (sampledSecondAmplitude P r u pick) := by
  rw [← blockWeights_sampler_constant]
  congr 1
  funext j k
  rcases j with ⟨i,b⟩
  cases b <;> rfl

theorem blockCodePotential_sampler_sampled {p : ℕ} (P r : Fin p → ℕ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ)
    (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) :
    blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) (sampledBlockWeights u pick) =
      samplerWeightedPotential P r (sampledFirstAmplitude P r u pick)
        (sampledSecondAmplitude P r u pick) := by
  unfold blockCodePotential samplerWeightedPotential
  simp_rw [blockSupport_sampler, blockWeights_sampler_sampled]

theorem blockEnergy_sampler_sampled {p : ℕ} (P r : Fin p → ℕ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ)
    (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) :
    blockEnergy (sampledBlockWeights u pick) =
      weightedRailEnergy (fun i => (P i : ℝ)) (fun i => (r i + 2 : ℝ))
        (sampledFirstAmplitude P r u pick) (sampledSecondAmplitude P r u pick) := by
  rw [blockEnergy_sampled, Fintype.sum_prod_type]
  simp only [Fintype.sum_bool, samplerSize]
  unfold weightedRailEnergy sampledFirstAmplitude sampledSecondAmplitude
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  simp only [Fintype.card_eq_nat_card, Nat.card_fin, Nat.cast_add, Nat.cast_ofNat]
  ring

/-- The unconditional weighted atom inequality for arbitrary incoming weights
on the literal full even-rail code. No balanced or Fourier premise remains. -/
theorem full_rail_block_atom_norm {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ) (bias : ℝ) :
    blockCodeMass (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) bias u ≤ Real.sqrt (bias ^ 2 + blockEnergy u) := by
  classical
  letI : ∀ j : Fin p × Bool, Nonempty (Fin (samplerSize P r j.1 j.2)) := fun j => by
    rcases j with ⟨i,b⟩
    cases b
    · exact ⟨⟨0, by have := hPtwo i; change 0 < P i; omega⟩⟩
    · exact ⟨⟨0, by change 0 < r i + 2; omega⟩⟩
  letI : MeasurableSpace (Finset (Fin p)) := ⊤
  letI : MeasurableSingletonClass (Finset (Fin p)) := ⟨fun _ => trivial⟩
  have hcard (τ : Finset (Fin p)) :
      (blockSupport (railBlockEquiv (samplerSize P r)) (transversalBlockOrientation τ)).card =
        2 * samplerHalfDegree P r τ := by
    rw [blockSupport_sampler]
    exact samplerSupport_card_half P r hPeven hreven τ
  have hsize (τ : Finset (Fin p)) :
      2 ≤ (blockSupport (railBlockEquiv (samplerSize P r)) (transversalBlockOrientation τ)).card := by
    rw [blockSupport_sampler]
    exact samplerSupport_two_le (by omega) P r τ hPtwo
  have heven (j : Fin p × Bool) : Even (Fintype.card (Fin (samplerSize P r j.1 j.2))) := by
    rcases j with ⟨i,b⟩
    cases b
    · simpa only [samplerSize, Fintype.card_eq_nat_card, Nat.card_fin] using hPeven i
    · simpa only [samplerSize, Fintype.card_eq_nat_card, Nat.card_fin] using (hreven i).add (by decide : Even 2)
  apply arbitrary_affine_atom_mass_of_sampled_bound
    (railBlockEquiv (samplerSize P r)) transversalBlockOrientation (samplerTransversalCost P r)
    (fun τ => div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le)
    (samplerHalfDegree P r) hcard hsize heven u bias
  intro pick
  rw [← blockCodePotential_sample_eq_mass _ _ _ _ hcard hsize heven u pick,
    blockCodePotential_sampler_sampled, blockEnergy_sampler_sampled]
  exact sampler_arbitrary_balanced_norm hp P r hPtwo hPeven hreven
    (sampledFirstAmplitude P r u pick) (sampledSecondAmplitude P r u pick)
    R Δ hΔ hR hPmin hQmin hdiff

/-- The same sharp inequality stated entirely in the existing physical
Boolean cube and incoming-coordinate model. -/
theorem full_rail_atom_norm {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : Fin (railDimension (samplerSize P r)) → ℝ) (bias : ℝ) :
    (∑ τ : Finset (Fin p), samplerTransversalCost P r τ *
      |walshCoefficients (fun x => max (cubeAffine bias u x) 0) (samplerSupport P r τ)|) ≤
      Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) := by
  let e := railBlockEquiv (samplerSize P r)
  let v : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ :=
    fun j k => u (e ⟨j,k⟩)
  have he : blockWeights e v = u := by
    funext i
    change u (e (e.symm i)) = u i
    rw [e.apply_symm_apply]
  have henergy : blockEnergy v = ∑ i, u i ^ 2 := by
    rw [← blockWeights_energy e v, he]
  have h := full_rail_block_atom_norm hp P r hPtwo hPeven hreven R Δ hΔ hR
    hPmin hQmin hdiff v bias
  rw [henergy] at h
  unfold blockCodeMass at h
  simp only [blockSupport_sampler] at h
  change (∑ τ, samplerTransversalCost P r τ *
    |walshCoefficients (fun x => max (cubeAffine bias (blockWeights e v) x) 0)
      (samplerSupport P r τ)|) ≤ _ at h
  rw [he] at h
  exact h

end NeuralGeneralization.OnlineLowerRelu
