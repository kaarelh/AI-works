import NeuralGeneralization.OnlineLowerSamplingRay

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

variable {p:ℕ} {β:(Fin p×Bool)→Type*}
variable [∀j,Fintype (β j)] [∀j,Nonempty (β j)]

def positiveBlockRay (θ:Fin p→Bool) (c:ℝ) (j:Fin p×Bool) (_:β j) : ℝ :=
  if j.2=θ j.1 then c else 0

theorem originalRayError_eq_blockEnergy (u:(j:Fin p×Bool)→β j→ℝ)
    (θ:Fin p→Bool) (c:ℝ) :
    originalRayError u θ c=blockEnergy (fun j a=>u j a-positiveBlockRay θ c j a) := by
  unfold originalRayError blockEnergy positiveBlockRay
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i _
  cases h:θ i <;> simp [h,Fintype.sum_bool,add_comm]
  · rfl
  · exact add_comm _ _

theorem weightedRayError_eq_blockEnergy (u:(j:Fin p×Bool)→β j→ℝ)
    (pick:(j:Fin p×Bool)→β j) (θ:Fin p→Bool) (c:ℝ) :
    weightedRayError (fun j=>(Fintype.card (β j):ℝ)) (fun j=>u j (pick j)) θ c=
      blockEnergy (fun j a=>sampledBlockWeights u pick j a-positiveBlockRay θ c j a) := by
  unfold weightedRayError blockEnergy sampledBlockWeights positiveBlockRay
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro i _
  cases h:θ i <;> simp [h,Fintype.sum_bool,add_comm]
  · rfl
  · exact add_comm _ _

/-- Reinsert each original coordinate's sign after rounding its magnitude.
The convention at zero can be either sign; choosing `+1` is convenient. -/
def signedBlockRay (u:(j:Fin p×Bool)→β j→ℝ) (θ:Fin p→Bool) (c:ℝ)
    (j:Fin p×Bool) (a:β j) : ℝ :=
  (if 0≤u j a then 1 else -1)*positiveBlockRay θ c j a

theorem signed_ray_square (a b:ℝ) :
    (a-(if 0≤a then 1 else -1)*b)^2=(|a|-b)^2 := by
  by_cases h:0≤a
  · simp [h,abs_of_nonneg h]
  · rw [if_neg h,abs_of_neg (lt_of_not_ge h)]
    ring

theorem signedBlockRay_distance (u:(j:Fin p×Bool)→β j→ℝ)
    (θ:Fin p→Bool) (c:ℝ) :
    blockEnergy (fun j a=>u j a-signedBlockRay u θ c j a)=
      originalRayError (fun j a=>|u j a|) θ c := by
  rw [originalRayError_eq_blockEnergy]
  unfold blockEnergy signedBlockRay
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro a _
  exact signed_ray_square _ _

theorem signedBlockRay_support (u:(j:Fin p×Bool)→β j→ℝ)
    (θ:Fin p→Bool) (c:ℝ) (j:Fin p×Bool) (a:β j) (h:j.2≠θ j.1) :
    signedBlockRay u θ c j a=0 := by
  simp [signedBlockRay,positiveBlockRay,h]

theorem signedBlockRay_abs (u:(j:Fin p×Bool)→β j→ℝ)
    (θ:Fin p→Bool) (c:ℝ) (hc:0≤c) (j:Fin p×Bool) (a:β j) :
    |signedBlockRay u θ c j a|=positiveBlockRay θ c j a := by
  unfold signedBlockRay positiveBlockRay
  by_cases h:j.2=θ j.1
  · simp only [h,if_true]
    by_cases hu:0≤u j a <;> simp [hu,abs_of_nonneg hc]
  · simp [h]

/-- Sampling stability in the literal squared norm of physical block weights,
including arbitrary signs. Every object in the conclusion is explicit. -/
theorem sampling_signed_distance (hp:2≤p)
    (u:(j:Fin p×Bool)→β j→ℝ) (r R:ℝ)
    (hr:0<r) (hR:2≤R) (hrR:R≤2*r)
    (hsize:∀j,r≤(Fintype.card (β j):ℝ)∧(Fintype.card (β j):ℝ)≤R)
    (θ:((j:Fin p×Bool)→β j)→Fin p→Bool)
    (c:((j:Fin p×Bool)→β j)→ℝ) (hc:∀pick,0≤c pick) :
    let v := fun j a=>|u j a|
    blockEnergy (fun j a=>u j a-signedBlockRay u (secondMomentChoice v)
      (deterministicGain v) j a)≤24*R*uniformBlockAverage (fun pick=>
        blockEnergy (fun j a=>sampledBlockWeights v pick j a-positiveBlockRay (θ pick) (c pick) j a)) := by
  dsimp only
  rw [signedBlockRay_distance,uniformBlockAverage_eq_finiteAverage]
  simp_rw [←weightedRayError_eq_blockEnergy]
  exact sampling_ray_stability hp (fun j a=>|u j a|) (fun j a=>abs_nonneg _) r R hr hR hrR hsize θ c hc

end NeuralGeneralization.OnlineLowerRelu
