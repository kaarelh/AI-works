import NeuralGeneralization.OnlineLowerTanhNearBulk

/-! The literal nearly equal coordinates instantiate the actual residual CLT. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace NearBalancedSequence
variable (B:NearBalancedSequence)

def bulkRawResidual (k:ℕ) : Fin (B.bulk k).card→ℝ :=
  subsetWeights (B.bulk k) (fun i=>B.u k i-B.a k)
def bulkRefitGain (k:ℕ) : ℝ :=
  B.a k+latticeRefitSlope (fun _:Fin (B.bulk k).card=>1) (B.bulkRawResidual k)
def bulkRefitResidual (k:ℕ) : Fin (B.bulk k).card→ℝ :=
  latticeRefitResidual (fun _:Fin (B.bulk k).card=>1) (B.bulkRawResidual k)

lemma bulkRawResidual_abs (k:ℕ) (i:Fin (B.bulk k).card) : |B.bulkRawResidual k i|≤B.D k :=
  B.bulk_close k _ ((B.bulk k).equivFin.symm i).property

lemma bulkRawResidual_energy (k:ℕ) : (∑i,(B.bulkRawResidual k i)^2)≤B.K := by
  change incomingEnergy (subsetWeights (B.bulk k) (fun i=>B.u k i-B.a k))≤B.K
  rw [incomingEnergy_subsetWeights]
  exact B.bulk_energy k

lemma bulkRefitGain_tendsto : Tendsto B.bulkRefitGain atTop (𝓝 limitingGain) := by
  have hs:Tendsto (fun k=>latticeRefitSlope (fun _:Fin (B.bulk k).card=>1) (B.bulkRawResidual k))
      atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ B.D_tendsto
    exact Eventually.of_forall (fun k=>by
      simpa only [Real.norm_eq_abs] using latticeRefitSlope_abs_le_all
        (fun _:Fin (B.bulk k).card=>1) (fun _=>by decide) (B.bulkRawResidual k)
        (B.D k) (B.D_nonneg k) (B.bulkRawResidual_abs k))
  change Tendsto (fun k=>B.a k+latticeRefitSlope (fun _:Fin (B.bulk k).card=>1) (B.bulkRawResidual k)) atTop (𝓝 limitingGain)
  simpa only [add_zero] using B.a_tendsto.add hs

lemma bulkRefitResidual_abs (k:ℕ) (i:Fin (B.bulk k).card) : |B.bulkRefitResidual k i|≤2*B.D k := by
  have hn:0<(B.bulk k).card:=by have hi:=i.isLt;omega
  have hh:=latticeRefitResidual_abs_le hn (fun _:Fin (B.bulk k).card=>1)
    (fun _=>by decide) (B.bulkRawResidual k) (B.D k) 1 (B.bulkRawResidual_abs k)
    (fun _=>by norm_num) i
  simpa only [bulkRefitResidual,one_add_one_eq_two] using hh

lemma bulkRefitResidual_energy (k:ℕ) : (∑i,(B.bulkRefitResidual k i)^2)≤B.K :=
  (latticeRefit_energy_le_all _ _).trans (B.bulkRawResidual_energy k)

/-- The primitive alphabet is the singleton `{1}`; the refit is the literal
least-squares shift, preserving each selected original incoming coordinate. -/
def toResidualPresequence : ResidualPresequence Unit where
  N := fun k=>(B.bulk k).card
  N_tendsto := B.bulk_tendsto
  label := fun _ _=>()
  q := fun _=>1
  q_odd := fun _=>by decide
  c := fun _=>1
  bezout := by simp
  α := 1
  Q := 1
  K := B.K
  α_pos := by norm_num
  Q_pos := by norm_num
  K_nonneg := B.K_nonneg
  freq := Eventually.of_forall (fun k j=>by cases j;simp)
  q_bound := fun _=>by norm_num
  A := B.bulkRefitGain
  D := fun k=>2*B.D k
  A₀ := limitingGain
  A₀_pos := limitingGain_pos
  A_tendsto := B.bulkRefitGain_tendsto
  D_tendsto := by simpa only [mul_zero] using B.D_tendsto.const_mul 2
  d := B.bulkRefitResidual
  d_bound := Eventually.of_forall (B.bulkRefitResidual_abs)
  orthogonal := fun k=>latticeRefit_orthogonal_positive (fun _:Fin (B.bulk k).card=>1)
    (B.bulkRawResidual k) (fun _=>by decide)
  energy_bound := B.bulkRefitResidual_energy

lemma toResidualPresequence_incoming (k:ℕ) :
    B.toResidualPresequence.incoming k=subsetWeights (B.bulk k) (B.u k) := by
  funext i
  change Fin (B.bulk k).card at i
  have hh:=latticeRefit_decomposition (fun _:Fin (B.bulk k).card=>1)
    (B.bulkRawResidual k) (B.a k) i
  simp only [Nat.cast_one,mul_one] at hh
  simp only [ResidualPresequence.incoming,toResidualPresequence,Nat.cast_one,mul_one]
  unfold bulkRefitGain bulkRefitResidual
  rw [←hh]
  unfold bulkRawResidual subsetWeights
  ring

/-- One may use the fixed actual gain interval with upper endpoint `3/2`.
The arrays remain exactly the selected coordinates of the maximizing nets. -/
theorem residual_subsequence :
    ∃φ:ℕ→ℕ,∃E:ℝ,∃h:B.toResidualPresequence.Refinement φ E,
      ∀k,B.toResidualPresequence.A (φ k)≤(3/2:ℝ) := by
  apply B.toResidualPresequence.exists_refinement_below
  change limitingGain<(3/2:ℝ)
  linarith [limitingGain_mem.2]

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
