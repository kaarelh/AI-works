import NeuralGeneralization.OnlineLowerReluRailAtom
import NeuralGeneralization.OnlineLowerSamplerRay
import NeuralGeneralization.OnlineLowerSamplingDistance

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

/-- The square-mean argument can round magnitudes while measuring the actual
signed input's Fourier deficit. -/
theorem block_signed_distance_le_square_deficit
    {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
    [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]
    {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (u : (j : κ) → β j → ℝ) (b L dist : ℝ)
    (sampleDist : ((j : κ) → β j) → ℝ) (hL : 0 ≤ L)
    (hround : dist ≤ L * uniformBlockAverage sampleDist)
    (hsample : ∀ pick, sampleDist pick ≤
      blockEnergy (sampledBlockWeights (fun j k => |u j k|) pick) -
        blockCodePotential e orientation weight
          (sampledBlockWeights (fun j k => |u j k|) pick) ^ 2) :
    dist ≤ L * (blockEnergy u - blockCodeMass e orientation weight b u ^ 2) := by
  have hsq := blockCodePotential_square_le_sample_mean e orientation weight hw r hcard hsize
    (fun j k => |u j k|)
  rw [blockCodePotential_abs_weights] at hsq
  change blockCodePotential e orientation weight u ^ 2 ≤
    uniformBlockAverage (fun pick => blockCodePotential e orientation weight
      (sampledBlockWeights (fun j k => |u j k|) pick) ^ 2) at hsq
  have hmean := uniformBlockAverage_mono _ _ hsample
  rw [uniformBlockAverage_sub, blockEnergy_sample_average] at hmean
  have he : blockEnergy (fun j k => |u j k|) = blockEnergy u := by
    simp [blockEnergy, sq_abs]
  rw [he] at hmean
  have hQnonneg : 0 ≤ blockCodeMass e orientation weight b u :=
    Finset.sum_nonneg (fun v _ => mul_nonneg (hw v) (abs_nonneg _))
  have hQG := blockCodeMass_le_potential e orientation weight hw r hcard hsize b u
  have hQsq : blockCodeMass e orientation weight b u ^ 2 ≤
      blockCodePotential e orientation weight u ^ 2 := by
    simpa only [pow_two] using mul_self_le_mul_self hQnonneg hQG
  apply hround.trans
  apply mul_le_mul_of_nonneg_left _ hL
  exact hmean.trans ((sub_le_sub_left hsq _).trans (sub_le_sub_left hQsq _))

/-- Every arbitrary signed affine rail atom admits a literal balanced ray.
The squared coordinate distance includes the discarded bias. -/
theorem full_rail_block_atom_stability {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2 * R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hPmax : ∀ i, (P i : ℝ) ≤ U) (hQmax : ∀ i, (r i + 2 : ℝ) ≤ U)
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ) (bias : ℝ) :
    ∃ (θ : Fin p → Bool) (c : ℝ), 0 ≤ c ∧
      bias ^ 2 + blockEnergy (fun j k => u j k - signedBlockRay u θ c j k) ≤
        48 * U * Real.sqrt (bias ^ 2 + blockEnergy u) *
          (Real.sqrt (bias ^ 2 + blockEnergy u) -
            blockCodeMass (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
              (samplerTransversalCost P r) bias u) := by
  classical
  letI : ∀ j : Fin p × Bool, Nonempty (Fin (samplerSize P r j.1 j.2)) := fun j => by
    rcases j with ⟨i,b⟩
    cases b
    · exact ⟨⟨0, by have := hPtwo i; change 0 < P i; omega⟩⟩
    · exact ⟨⟨0, by change 0 < r i + 2; omega⟩⟩
  letI : MeasurableSpace (Finset (Fin p)) := ⊤
  letI : MeasurableSingletonClass (Finset (Fin p)) := ⟨fun _ => trivial⟩
  let v := fun j k => |u j k|
  have hsamples (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) :
      ∃ (θ : Fin p → Bool) (c : ℝ), 0 ≤ c ∧
        blockEnergy (fun j k => sampledBlockWeights v pick j k - positiveBlockRay (β := fun j : Fin p × Bool => Fin (samplerSize P r j.1 j.2)) θ c j k) ≤
          blockEnergy (sampledBlockWeights v pick) -
            blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
              (samplerTransversalCost P r) (sampledBlockWeights v pick) ^ 2 := by
    obtain ⟨θ,c,hc,he⟩ := sampler_balanced_ray_exists hp P r hPtwo hPeven hreven
      (sampledFirstAmplitude P r v pick) (sampledSecondAmplitude P r v pick)
      R Δ hΔ hR hPmin hQmin hdiff
    refine ⟨θ,c,hc,?_⟩
    rw [blockEnergy_sampler_sampled, blockCodePotential_sampler_sampled]
    have hw : railPairWeights P r =
        fun j : Fin p × Bool => (Fintype.card (Fin (samplerSize P r j.1 j.2)) : ℝ) := by
      funext j
      rcases j with ⟨i,b⟩
      cases b <;> simp only [railPairWeights, samplerSize, Fintype.card_eq_nat_card,
        Nat.card_fin, Nat.cast_add, Nat.cast_ofNat, Bool.false_eq_true, if_false, if_true]
    have ha : (fun j => |railPairAmplitudes (sampledFirstAmplitude P r v pick)
        (sampledSecondAmplitude P r v pick) j|) = fun j => v j (pick j) := by
      funext j
      rcases j with ⟨i,b⟩
      cases b <;> simp [railPairAmplitudes, sampledFirstAmplitude, sampledSecondAmplitude, v]
    rw [hw, ha, weightedRayError_eq_blockEnergy] at he
    exact he
  choose θ c hc herr using hsamples
  let θ₀ := secondMomentChoice v
  let c₀ := deterministicGain v
  have hc₀ : 0 ≤ c₀ := deterministicGain_nonneg v (fun _ _ => abs_nonneg _)
  refine ⟨θ₀,c₀,hc₀,?_⟩
  have hsize (j : Fin p × Bool) :
      R ≤ (Fintype.card (Fin (samplerSize P r j.1 j.2)) : ℝ) ∧
        (Fintype.card (Fin (samplerSize P r j.1 j.2)) : ℝ) ≤ U := by
    rcases j with ⟨i,b⟩
    cases b
    · simpa only [samplerSize, Fintype.card_eq_nat_card, Nat.card_fin] using ⟨hPmin i,hPmax i⟩
    · simpa only [samplerSize, Fintype.card_eq_nat_card, Nat.card_fin,
        Nat.cast_add, Nat.cast_ofNat] using ⟨hQmin i,hQmax i⟩
  have hround := sampling_signed_distance hp u R U hRpos hU hUR hsize θ c hc
  have hcard (τ : Finset (Fin p)) :
      (blockSupport (railBlockEquiv (samplerSize P r)) (transversalBlockOrientation τ)).card =
        2 * samplerHalfDegree P r τ := by
    rw [blockSupport_sampler]
    exact samplerSupport_card_half P r hPeven hreven τ
  have htwo (τ : Finset (Fin p)) :
      2 ≤ (blockSupport (railBlockEquiv (samplerSize P r)) (transversalBlockOrientation τ)).card := by
    rw [blockSupport_sampler]
    exact samplerSupport_two_le (by omega) P r τ hPtwo
  have hd := block_signed_distance_le_square_deficit
    (railBlockEquiv (samplerSize P r)) transversalBlockOrientation (samplerTransversalCost P r)
    (fun τ => div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le)
    (samplerHalfDegree P r) hcard htwo u bias (24 * U)
    (blockEnergy (fun j k => u j k - signedBlockRay u θ₀ c₀ j k))
    (fun pick => blockEnergy (fun j k => sampledBlockWeights v pick j k -
      positiveBlockRay (β := fun j : Fin p × Bool => Fin (samplerSize P r j.1 j.2)) (θ pick) (c pick) j k))
    (by positivity) hround herr
  have hfin := affine_distance_from_square_deficit bias _ (blockEnergy u)
    (blockCodeMass (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) bias u) (24 * U)
    (Real.sqrt (bias ^ 2 + blockEnergy u)) (by linarith)
    (Real.sq_sqrt (add_nonneg (sq_nonneg _) (blockEnergy_nonneg _))) hd
  convert hfin using 1 <;> ring


/-- The rounded witness has one common magnitude on its chosen support. -/
theorem blockWeights_signedBlockRay_abs {p d : ℕ}
    {β : (Fin p × Bool) → Type*} [∀ j, Fintype (β j)]
    (e : ((j : Fin p × Bool) × β j) ≃ Fin d)
    (u : (j : Fin p × Bool) → β j → ℝ) (θ : Fin p → Bool)
    (c : ℝ) (hc : 0 ≤ c) (i : Fin d) :
    |blockWeights e (signedBlockRay u θ c) i| =
      if i ∈ blockSupport e (railBlockOrientation θ) then c else 0 := by
  classical
  obtain ⟨⟨j,k⟩,rfl⟩ := e.surjective i
  rw [blockWeights_apply]
  by_cases hu : 0 ≤ u j k <;> by_cases hj : j.2 = θ j.1 <;>
    simp [signedBlockRay, positiveBlockRay, blockSupport, railBlockOrientation, hu, hj, abs_of_nonneg hc]

/-- Full affine stability on the literal physical Boolean cube. The witness
is an actual coordinate vector with a balanced selected-rail magnitude. -/
theorem full_rail_atom_stability {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2 * R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hPmax : ∀ i, (P i : ℝ) ≤ U) (hQmax : ∀ i, (r i + 2 : ℝ) ≤ U)
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : Fin (railDimension (samplerSize P r)) → ℝ) (bias : ℝ) :
    ∃ (τ : Finset (Fin p)) (c : ℝ) (v : Fin (railDimension (samplerSize P r)) → ℝ),
      0 ≤ c ∧ (∀ i, |v i| = if i ∈ samplerSupport P r τ then c else 0) ∧
      bias ^ 2 + (∑ i, (u i - v i) ^ 2) ≤
        48 * U * Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) *
          (Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) -
            ∑ σ : Finset (Fin p), samplerTransversalCost P r σ *
              |walshCoefficients (fun x => max (cubeAffine bias u x) 0) (samplerSupport P r σ)|) := by
  classical
  let e := railBlockEquiv (samplerSize P r)
  let ub : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ :=
    fun j k => u (e ⟨j,k⟩)
  have he : blockWeights e ub = u := by
    funext i
    change u (e (e.symm i)) = u i
    rw [e.apply_symm_apply]
  have henergy : blockEnergy ub = ∑ i, u i ^ 2 := by
    rw [← blockWeights_energy e ub, he]
  obtain ⟨θ,c,hc,hd⟩ := full_rail_block_atom_stability hp P r hPtwo hPeven hreven
    R Δ U hΔ hR hRpos hU hUR hPmin hQmin hPmax hQmax hdiff ub bias
  let τ := Finset.univ.filter (fun i => θ i = true)
  have hθ : (fun i => decide (i ∈ τ)) = θ := by
    funext i
    cases h : θ i <;> simp [τ,h]
  let v := blockWeights e (signedBlockRay ub θ c)
  refine ⟨τ,c,v,hc,?_,?_⟩
  · intro i
    have h := blockWeights_signedBlockRay_abs e ub θ c hc i
    have hsupport : blockSupport e (railBlockOrientation θ) = samplerSupport P r τ := by
      rw [← hθ]
      exact blockSupport_sampler P r τ
    rw [hsupport] at h
    exact h
  · have hdist : blockEnergy (fun j k => ub j k - signedBlockRay ub θ c j k) =
        ∑ i, (u i - v i) ^ 2 := by
      rw [← blockWeights_energy e]
      apply Finset.sum_congr rfl
      intro i _
      have hui := congrFun he i
      change (blockWeights e ub i - v i) ^ 2 = _
      rw [hui]
    rw [henergy,hdist] at hd
    unfold blockCodeMass at hd
    simp only [blockSupport_sampler] at hd
    change _ ≤ 48 * U * Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) *
      (Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) -
        ∑ σ, samplerTransversalCost P r σ *
          |walshCoefficients (fun x => max (cubeAffine bias (blockWeights e ub) x) 0)
            (samplerSupport P r σ)|) at hd
    rw [he] at hd
    exact hd

end NeuralGeneralization.OnlineLowerRelu
