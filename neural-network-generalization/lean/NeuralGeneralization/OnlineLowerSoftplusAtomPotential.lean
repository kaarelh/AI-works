import NeuralGeneralization.OnlineLowerReluRailStability
import NeuralGeneralization.OnlineLowerFamilyRetainedStability

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerSoftplus
open OnlineLowerRelu OnlineLower OnlineLowerGeometry

theorem block_potential_distance_le_square_deficit
    {κ : Type*} [Fintype κ] [DecidableEq κ] {β : κ → Type*}
    [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]
    {d : ℕ} {ν : Type*} [Fintype ν]
    [MeasurableSpace ν] [MeasurableSingletonClass ν]
    (e : ((j : κ) × β j) ≃ Fin d) (orientation : ν → κ → Bool)
    (weight : ν → ℝ) (hw : ∀ v, 0 ≤ weight v) (r : ν → ℕ)
    (hcard : ∀ v, (blockSupport e (orientation v)).card = 2 * r v)
    (hsize : ∀ v, 2 ≤ (blockSupport e (orientation v)).card)
    (u : (j : κ) → β j → ℝ) (L dist : ℝ)
    (sampleDist : ((j : κ) → β j) → ℝ) (hL : 0 ≤ L)
    (hround : dist ≤ L * uniformBlockAverage sampleDist)
    (hsample : ∀ pick, sampleDist pick ≤
      blockEnergy (sampledBlockWeights (fun j k => |u j k|) pick) -
        blockCodePotential e orientation weight
          (sampledBlockWeights (fun j k => |u j k|) pick) ^ 2) :
    dist ≤ L * (blockEnergy u - blockCodePotential e orientation weight u ^ 2) := by
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
  apply hround.trans
  apply mul_le_mul_of_nonneg_left _ hL
  exact hmean.trans (sub_le_sub_left hsq _)

theorem full_rail_block_potential_stability {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2 * R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hPmax : ∀ i, (P i : ℝ) ≤ U) (hQmax : ∀ i, (r i + 2 : ℝ) ≤ U)
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ) :
    ∃ (θ : Fin p → Bool) (c : ℝ), 0 ≤ c ∧
      blockEnergy (fun j k => u j k - signedBlockRay u θ c j k) ≤
        48 * U * Real.sqrt (blockEnergy u) *
          (Real.sqrt (blockEnergy u) -
            blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
              (samplerTransversalCost P r) u) := by
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
  have hd := block_potential_distance_le_square_deficit
    (railBlockEquiv (samplerSize P r)) transversalBlockOrientation (samplerTransversalCost P r)
    (fun τ => div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le)
    (samplerHalfDegree P r) hcard htwo u (24 * U)
    (blockEnergy (fun j k => u j k - signedBlockRay u θ₀ c₀ j k))
    (fun pick => blockEnergy (fun j k => sampledBlockWeights v pick j k -
      positiveBlockRay (β := fun j : Fin p × Bool => Fin (samplerSize P r j.1 j.2)) (θ pick) (c pick) j k))
    (by positivity) hround herr
  have hfin := affine_distance_from_square_deficit 0 _ (blockEnergy u)
    (blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) u) (24 * U)
    (Real.sqrt (blockEnergy u)) (by linarith)
    (by simpa using Real.sq_sqrt (blockEnergy_nonneg u)) hd
  convert hfin using 1 <;> ring

theorem full_rail_block_potential_norm {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ) :
    blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) u ≤ Real.sqrt (blockEnergy u) := by
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
  have hw : ∀ τ, 0 ≤ samplerTransversalCost P r τ :=
    fun τ => div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le
  have hsq := blockCodePotential_square_le_sample_mean
    (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
    (samplerTransversalCost P r) hw (samplerHalfDegree P r) hcard hsize u
  have hsample (pick : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2)) :
      blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
        (samplerTransversalCost P r) (sampledBlockWeights u pick)^2 ≤
        blockEnergy (sampledBlockWeights u pick) := by
    rw [blockCodePotential_sampler_sampled, blockEnergy_sampler_sampled]
    exact sampler_arbitrary_balanced_norm hp P r hPtwo hPeven hreven
      (sampledFirstAmplitude P r u pick) (sampledSecondAmplitude P r u pick)
      R Δ hΔ hR hPmin hQmin hdiff
  change _ ≤ uniformBlockAverage (fun pick =>
    blockCodePotential (railBlockEquiv (samplerSize P r)) transversalBlockOrientation
      (samplerTransversalCost P r) (sampledBlockWeights u pick)^2) at hsq
  have hm := uniformBlockAverage_mono _ _ hsample
  rw [blockEnergy_sample_average] at hm
  have hGn := blockCodePotential_nonneg
    (railBlockEquiv (samplerSize P r)) transversalBlockOrientation (samplerTransversalCost P r) hw u
  have he := Real.sq_sqrt (blockEnergy_nonneg u)
  have hn := Real.sqrt_nonneg (blockEnergy u)
  nlinarith

theorem full_rail_potential_stability {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2 * R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hPmax : ∀ i, (P i : ℝ) ≤ U) (hQmax : ∀ i, (r i + 2 : ℝ) ≤ U)
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : Fin (railDimension (samplerSize P r)) → ℝ) :
    ∃ (τ : Finset (Fin p)) (c : ℝ) (v : Fin (railDimension (samplerSize P r)) → ℝ),
      0 ≤ c ∧ (∀ i, |v i| = if i ∈ samplerSupport P r τ then c else 0) ∧
      (∑ i, (u i - v i) ^ 2) ≤
        48 * U * Real.sqrt (∑ i, u i ^ 2) *
          (Real.sqrt (∑ i, u i ^ 2) -
            ∑ σ : Finset (Fin p), samplerTransversalCost P r σ *
              supportFourierPotential (samplerSupport P r σ) u) := by
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
  obtain ⟨θ,c,hc,hd⟩ := full_rail_block_potential_stability hp P r hPtwo hPeven hreven
    R Δ U hΔ hR hRpos hU hUR hPmin hQmin hPmax hQmax hdiff ub
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
    unfold blockCodePotential at hd
    simp only [blockSupport_sampler] at hd
    change _ ≤ 48 * U * Real.sqrt (∑ i, u i ^ 2) *
      (Real.sqrt (∑ i, u i ^ 2) -
        ∑ σ, samplerTransversalCost P r σ *
          supportFourierPotential (samplerSupport P r σ) (blockWeights e ub)) at hd
    rw [he] at hd
    exact hd

theorem full_rail_potential_norm {p : ℕ} (hp : 2 ≤ p)
    (P r : Fin p → ℕ) (hPtwo : ∀ i, 2 ≤ P i)
    (hPeven : ∀ i, Even (P i)) (hreven : ∀ i, Even (r i))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hPmin : ∀ i, R ≤ (P i : ℝ)) (hQmin : ∀ i, R ≤ (r i + 2 : ℝ))
    (hdiff : ∀ i, |(r i + 2 : ℝ) - P i| ≤ Δ)
    (u : Fin (railDimension (samplerSize P r)) → ℝ) :
    (∑ τ : Finset (Fin p), samplerTransversalCost P r τ *
      supportFourierPotential (samplerSupport P r τ) u) ≤
      Real.sqrt (∑ i, u i ^ 2) := by
  let e := railBlockEquiv (samplerSize P r)
  let v : (j : Fin p × Bool) → Fin (samplerSize P r j.1 j.2) → ℝ :=
    fun j k => u (e ⟨j,k⟩)
  have he : blockWeights e v = u := by
    funext i
    change u (e (e.symm i)) = u i
    rw [e.apply_symm_apply]
  have henergy : blockEnergy v = ∑ i, u i ^ 2 := by
    rw [← blockWeights_energy e v, he]
  have h := full_rail_block_potential_norm hp P r hPtwo hPeven hreven R Δ hΔ hR
    hPmin hQmin hdiff v
  rw [henergy] at h
  unfold blockCodePotential at h
  simp only [blockSupport_sampler] at h
  change (∑ τ, samplerTransversalCost P r τ *
    supportFourierPotential (samplerSupport P r τ) (blockWeights e v)) ≤ _ at h
  rw [he] at h
  exact h

end NeuralGeneralization.OnlineLowerSoftplus
