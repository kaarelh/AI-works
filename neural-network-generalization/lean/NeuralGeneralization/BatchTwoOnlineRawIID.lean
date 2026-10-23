import NeuralGeneralization.BatchTwoOnlineRawFirstAppearance
import NeuralGeneralization.BatchTwoOnlineIIDInfinite

/-! The set-dependent raw-posterior risk on an actual infinite IID stream. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
open Classical MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {m : ℕ}

def streamRound (R : Finset (Fin m) → Fin m → ℝ) (i : ℕ) (s : ℕ→Fin m) : ℝ :=
  R ((Finset.range i).image s) (s i)

def streamTotal (R : Finset (Fin m) → Fin m → ℝ) (s : ℕ→Fin m) : ℝ≥0∞ :=
  ∑'i,ENNReal.ofReal (streamRound R i s)

theorem seenSet_prefix {n : ℕ} (s : ℕ→Fin m) (i : Fin n) :
    seenSet (sequencePrefix n s) i=(Finset.range i.val).image s := by
  ext x
  rw [mem_seenSet]
  simp only [Finset.mem_image,Finset.mem_range,sequencePrefix]
  constructor
  · rintro ⟨j,hj,hx⟩
    exact ⟨j.val,hj,hx⟩
  · rintro ⟨j,hj,hx⟩
    exact ⟨⟨j,hj.trans i.isLt⟩,hj,hx⟩

theorem setCumulativeRisk_prefix (R : Finset (Fin m) → Fin m → ℝ) (s : ℕ→Fin m) (n : ℕ) :
    setCumulativeRisk R (sequencePrefix n s)=∑i∈Finset.range n,streamRound R i s := by
  unfold setCumulativeRisk
  simp only [seenSet_prefix,sequencePrefix]
  exact Fin.sum_univ_eq_sum_range (fun i=>streamRound R i s) n

theorem streamRound_prefix (R : Finset (Fin m) → Fin m → ℝ) (s : ℕ→Fin m) (i : ℕ) :
    streamRound R i s=R (seenSet (sequencePrefix (i+1) s) ⟨i,Nat.lt_succ_self i⟩)
      (sequencePrefix (i+1) s ⟨i,Nat.lt_succ_self i⟩) := by
  rw [seenSet_prefix]
  rfl

theorem measurable_streamRound (R : Finset (Fin m) → Fin m → ℝ) (i : ℕ) :
    Measurable (streamRound R i) := by
  have he : streamRound R i=(fun t : Fin (i+1)→Fin m=>R (seenSet t ⟨i,Nat.lt_succ_self i⟩)
    (t ⟨i,Nat.lt_succ_self i⟩))∘sequencePrefix (i+1) := by
    funext s
    exact streamRound_prefix R s i
  rw [he]
  exact (measurable_of_finite _).comp (measurable_sequencePrefix (i+1))

variable [NeZero m]

theorem iid_expected_streamTotal (hm : 0<m) (R : Finset (Fin m) → Fin m → ℝ)
    (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0) :
    (∫⁻s,streamTotal R s ∂iidQueryLaw (Fin m))≤ENNReal.ofReal (finiteMean (setPermutationRisk R)) := by
  apply infinite_expectation_le_of_prefix (iidQueryLaw (Fin m)) (streamRound R)
    (fun i s=>hR _ _) (measurable_streamRound R)
  intro n
  have he : (fun s : ℕ→Fin m=>ENNReal.ofReal (∑i∈Finset.range n,streamRound R i s))=
      (fun s=>ENNReal.ofReal (setCumulativeRisk R (sequencePrefix n s))) := by
    funext s
    rw [setCumulativeRisk_prefix]
  have hn (s : Fin n→Fin m) : 0≤setCumulativeRisk R s := Finset.sum_nonneg (fun i _=>hR _ _)
  rw [he,iidQueryLaw_prefix_lintegral n (setCumulativeRisk R) hn]
  exact ENNReal.ofReal_le_ofReal (expected_setCumulativeRisk_le_permutation hm R hR hrepeat n)

theorem iid_streamTotal_tail (hm : 0<m) (R : Finset (Fin m) → Fin m → ℝ)
    (hR : ∀S x,0≤R S x) (hrepeat : ∀S x,x∈S→R S x=0) (U : ℝ) (hU : 0≤U) :
    iidQueryLaw (Fin m) {s | ENNReal.ofReal U<streamTotal R s}≤
      ENNReal.ofReal (finiteEvent (fun π=>U<setPermutationRisk R π)) := by
  apply infinite_tail_le_of_prefix (iidQueryLaw (Fin m)) (streamRound R) (fun i s=>hR _ _) U hU
  intro n
  have he : {s : ℕ→Fin m | U<∑i∈Finset.range n,streamRound R i s}=
      {s | U<setCumulativeRisk R (sequencePrefix n s)} := by
    ext s
    simp only [Set.mem_setOf_eq]
    rw [setCumulativeRisk_prefix]
  rw [he,iidQueryLaw_prefix_event n (fun t=>U<setCumulativeRisk R t)]
  exact ENNReal.ofReal_le_ofReal (setCumulativeRisk_tail_le_permutation hm R hR hrepeat n U)

end NeuralGeneralization.BatchTwoOnlineRaw
