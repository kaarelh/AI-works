import NeuralGeneralization.BatchTwoMergingModel

/-! # The finite union over population witnesses -/

noncomputable section

namespace NeuralGeneralization.BatchTwoMerging

def BoundedPartition (N Q : ℕ) := {p : PopulationPartition N // populationCount p ≤ Q}

instance (N Q : ℕ) : Fintype (BoundedPartition N Q) := by
  unfold BoundedPartition
  infer_instance

/-- Encode the number of populations and the label of every original neuron. -/
def partitionCode {N Q : ℕ} (hN : 0 < N) (p : BoundedPartition N Q) :
    Fin Q × (Fin N → Fin Q) :=
  (⟨populationCount p.val - 1, by
      have hpos := populationCount_pos hN p.val
      have hle := p.property
      omega⟩,
    fun i => ⟨(populationLabel p.val i).val,
      (populationLabel p.val i).isLt.trans_le p.property⟩)

theorem partitionCode_injective {N Q : ℕ} (hN : 0 < N) :
    Function.Injective (partitionCode (Q := Q) hN) := by
  intro p q h
  have hfirst := congrArg (fun a : Fin Q × (Fin N → Fin Q) => a.1.val) h
  have hposp := populationCount_pos hN p.val
  have hposq := populationCount_pos hN q.val
  change populationCount p.val - 1 = populationCount q.val - 1 at hfirst
  have hcount : populationCount p.val = populationCount q.val := by omega
  rcases p with ⟨⟨⟨qp, lp⟩, hp⟩, hcp⟩
  rcases q with ⟨⟨⟨qq, lq⟩, hq⟩, hcq⟩
  change qp.val = qq.val at hcount
  have hqq : qp = qq := Fin.ext hcount
  subst qq
  have hl : lp = lq := by
    funext i
    apply Fin.ext
    have hi := congrArg (fun a : Fin Q × (Fin N → Fin Q) => (a.2 i).val) h
    exact hi
  subst lq
  rfl

/-- At most `Q^(N+1)` labelled nonempty partitions with at most `Q` groups. -/
theorem boundedPartition_card_le {N Q : ℕ} (hN : 0 < N) :
    Fintype.card (BoundedPartition N Q) ≤ Q ^ (N + 1) := by
  have h := Fintype.card_le_of_injective (partitionCode (Q := Q) hN)
    (partitionCode_injective hN)
  simpa only [Fintype.card_prod, Fintype.card_fun, Fintype.card_fin,
    pow_succ, Nat.mul_comm] using h

def BoundedLayerPartitions (N r Q : ℕ) :=
  {p : LayerPartitions N r // ∀ s, populationCount (p s) ≤ Q}

instance (N r Q : ℕ) : Fintype (BoundedLayerPartitions N r Q) := by
  unfold BoundedLayerPartitions
  infer_instance

def layerPartitionCode {N r Q : ℕ} (p : BoundedLayerPartitions N r Q) :
    Fin (r + 1) → BoundedPartition N Q := fun s => ⟨p.val s, p.property s⟩

theorem layerPartitionCode_injective {N r Q : ℕ} :
    Function.Injective (layerPartitionCode (N := N) (r := r) (Q := Q)) := by
  intro p q h
  apply Subtype.ext
  funext s
  exact congrArg Subtype.val (congrFun h s)

/-- This count precedes selecting any witness from the sampled network. -/
theorem boundedLayerPartitions_card_le {N r Q : ℕ} (hN : 0 < N) :
    Fintype.card (BoundedLayerPartitions N r Q) ≤ Q ^ ((r + 1) * (N + 1)) := by
  have h := Fintype.card_le_of_injective
    (layerPartitionCode (N := N) (r := r) (Q := Q)) layerPartitionCode_injective
  simp only [Fintype.card_fun, Fintype.card_fin] at h
  calc
    _ ≤ Fintype.card (BoundedPartition N Q) ^ (r + 1) := h
    _ ≤ (Q ^ (N + 1)) ^ (r + 1) := Nat.pow_le_pow_left (boundedPartition_card_le hN) _
    _ = Q ^ ((r + 1) * (N + 1)) := by rw [← pow_mul, Nat.mul_comm]

end NeuralGeneralization.BatchTwoMerging
