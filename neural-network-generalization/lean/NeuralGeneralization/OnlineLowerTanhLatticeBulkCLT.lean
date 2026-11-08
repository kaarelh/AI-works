import NeuralGeneralization.OnlineLowerTanhLatticeBulkSequence

/-! # A proved residual-CLT instance for every finite positive lattice alphabet -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh
namespace LatticeSequence
variable (L : LatticeSequence)

lemma finite_mass_pos (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j) :
    0 < ∑ j ∈ S,L.p j :=
  Finset.sum_pos' (fun j hj => (hS j hj).le) (hne.imp (fun j hj => ⟨hj,hS j hj⟩))

def frequencyConstant (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j) : ℝ :=
  Classical.choose (L.bulk_positive_frequencies S hne hS)

lemma frequencyConstant_pos (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j) :
    0 < L.frequencyConstant S hne hS :=
  (Classical.choose_spec (L.bulk_positive_frequencies S hne hS)).1

lemma frequencyConstant_bound (S : Finset ℕ) (hne : S.Nonempty) (hS : ∀ j ∈ S,0 < L.p j) :
    ∀ᶠ k in atTop,∀ j : S,L.frequencyConstant S hne hS*((L.bulk S k).card:ℝ) ≤
      ((Finset.univ.filter (fun i => L.label S k i=j)).card:ℝ) :=
  (Classical.choose_spec (L.bulk_positive_frequencies S hne hS)).2

/-- All inputs of the residual CLT are derived from the original localized
arrays, finite positive frequencies, and a literal primitive Bezout vector. -/
def toResidualPresequence (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ j ∈ S,0 < L.p j) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j)
    (c : S → ℤ) (hc : ∑ j,c j*(j.val/g:ℕ)=1) : ResidualPresequence S where
  N := fun k => (L.bulk S k).card
  N_tendsto := L.bulk_card_tendsto S (L.finite_mass_pos S hne hS)
  label := L.label S
  q := fun j => j.val/g
  q_odd := fun j => (primitive_pos_odd S g hg hodd hdiv j).2
  c := c
  bezout := hc
  α := L.frequencyConstant S hne hS
  Q := alphabetBound S
  K := L.K
  α_pos := L.frequencyConstant_pos S hne hS
  Q_pos := alphabetBound_pos S
  K_nonneg := L.K_nonneg
  freq := L.frequencyConstant_bound S hne hS
  q_bound := fun j => by unfold alphabetBound; exact_mod_cast primitive_bound S g j
  A := L.refitGain S g
  D := fun k => (1+alphabetBound S)*L.threshold k
  A₀ := L.a₀*g
  A₀_pos := mul_pos L.a₀_pos (by exact_mod_cast hg)
  A_tendsto := L.refitGain_tendsto S g hg hodd hdiv
  D_tendsto := by simpa only [mul_zero] using L.threshold_tendsto.const_mul (1+alphabetBound S)
  d := L.refitResidual S g
  d_bound := Eventually.of_forall (fun k => L.refitResidual_abs_le S g hg hodd hdiv k)
  orthogonal := L.refit_orthogonal S g hg hodd hdiv
  energy_bound := L.refitResidual_energy_le S g

lemma toResidualPresequence_incoming (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ j ∈ S,0 < L.p j) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j)
    (c : S → ℤ) (hc : ∑ j,c j*(j.val/g:ℕ)=1) (k : ℕ) :
    (L.toResidualPresequence S hne hS g hg hodd hdiv c hc).incoming k =
      subsetWeights (L.bulk S k) (fun i => |L.u k i|) :=
  L.refit_incoming S g hdiv k

lemma primitive_variance_identity (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hdiv : ∀ j ∈ S,g∣j) (k : ℕ) :
    residualVariance (L.primitive S g k) =
      (∑ i ∈ L.bulk S k,(L.q k i:ℝ)^2)/(g:ℝ)^2 := by
  have hgR : (g:ℝ)≠0 := by exact_mod_cast (Nat.ne_of_gt hg)
  unfold residualVariance
  change (∑ i,(L.primitive S g k i:ℝ)^2)=
    (∑ i ∈ prunedLatticeIndices (L.q k) (L.residual k) (L.threshold k) S,(L.q k i:ℝ)^2)/(g:ℝ)^2
  rw [←pruned_label_variance (L.q k) (L.residual k) (L.threshold k) S,Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  let j := L.label S k i
  have hj : g*(j.val/g)=j.val := Nat.mul_div_cancel' (hdiv j.val j.property)
  have hjR : (g:ℝ)*(j.val/g:ℕ)=j.val := by exact_mod_cast hj
  change ((j.val/g:ℕ):ℝ)^2=(j.val:ℝ)^2/(g:ℝ)^2
  rw [←hjR,mul_pow]
  field_simp

lemma primitive_variance_ratio_tendsto (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hdiv : ∀ j ∈ S,g∣j) :
    Tendsto (fun k => residualVariance (L.primitive S g k)/(L.N k:ℝ)) atTop
      (𝓝 ((∑ j ∈ S,L.p j*(j:ℝ)^2)/(g:ℝ)^2)) := by
  have h := (threshold_pruned_moment_ratio_tendsto L.N L.N_pos L.N_tendsto L.q L.residual L.K
    L.residual_bound L.p L.frequency_tendsto S).div_const ((g:ℝ)^2)
  apply h.congr'
  exact Eventually.of_forall (fun k => by
    change ((L.N k:ℝ)⁻¹*(∑ i ∈ L.bulk S k,(L.q k i:ℝ)^2))/(g:ℝ)^2 =
      residualVariance (L.primitive S g k)/(L.N k:ℝ)
    rw [L.primitive_variance_identity S g hg hdiv k]
    ring)

/-- Every finite positive primitive alphabet admits an actual residual CLT
subsequence, with its incoming vector exactly the selected original weights. -/
theorem finite_alphabet_residual_subsequence (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ j ∈ S,0 < L.p j) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j)
    (c : S → ℤ) (hc : ∑ j,c j*(j.val/g:ℕ)=1) :
    ∃ φ : ℕ → ℕ, ∃ E : ℝ,
      (L.toResidualPresequence S hne hS g hg hodd hdiv c hc).Refinement φ E :=
  (L.toResidualPresequence S hne hS g hg hodd hdiv c hc).exists_refinement

end LatticeSequence
end NeuralGeneralization.OnlineLowerTanh
