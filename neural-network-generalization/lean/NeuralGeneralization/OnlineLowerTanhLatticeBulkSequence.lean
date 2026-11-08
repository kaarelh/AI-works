import NeuralGeneralization.OnlineLowerTanhPrunedCoordinates
import NeuralGeneralization.OnlineLowerTanhResidualExtraction

/-! # Actual pruned, primitive, orthogonal bulk sequences -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

/-- Literal localized incoming arrays and their pointwise empirical limit. -/
structure LatticeSequence where
  N : ℕ → ℕ
  N_pos : ∀ k,0 < N k
  N_tendsto : Tendsto N atTop atTop
  u : (k : ℕ) → Fin (N k) → ℝ
  q : (k : ℕ) → Fin (N k) → ℕ
  a : ℕ → ℝ
  a₀ : ℝ
  a₀_pos : 0 < a₀
  a_tendsto : Tendsto a atTop (𝓝 a₀)
  K : ℝ
  K_nonneg : 0 ≤ K
  residual_bound : ∀ k,(∑ i,(|u k i|-a k*(q k i:ℝ))^2) ≤ K
  p : ℕ → ℝ
  p_nonneg : ∀ j,0 ≤ p j
  frequency_tendsto : ∀ j,Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j))

namespace LatticeSequence
variable (L : LatticeSequence)

def residual (k : ℕ) : Fin (L.N k) → ℝ := fun i => |L.u k i|-L.a k*(L.q k i:ℝ)
def threshold (k : ℕ) : ℝ := latticeResidualThreshold (L.N k)
def bulk (S : Finset ℕ) (k : ℕ) : Finset (Fin (L.N k)) :=
  prunedLatticeIndices (L.q k) (L.residual k) (L.threshold k) S
def label (S : Finset ℕ) (k : ℕ) : Fin (L.bulk S k).card → S :=
  prunedAlphabetLabel (L.q k) (L.residual k) (L.threshold k) S
def primitive (S : Finset ℕ) (g : ℕ) (k : ℕ) : Fin (L.bulk S k).card → ℕ :=
  fun i => (L.label S k i).val/g
def rawResidual (S : Finset ℕ) (k : ℕ) : Fin (L.bulk S k).card → ℝ :=
  subsetWeights (L.bulk S k) (L.residual k)
def refitGain (S : Finset ℕ) (g : ℕ) (k : ℕ) : ℝ :=
  L.a k*g+latticeRefitSlope (L.primitive S g k) (L.rawResidual S k)
def refitResidual (S : Finset ℕ) (g : ℕ) (k : ℕ) : Fin (L.bulk S k).card → ℝ :=
  latticeRefitResidual (L.primitive S g k) (L.rawResidual S k)
def alphabetBound (S : Finset ℕ) : ℝ := (S.sup id+1:ℕ)

lemma threshold_pos (k : ℕ) : 0 < L.threshold k := latticeResidualThreshold_pos (L.N_pos k)
lemma threshold_tendsto : Tendsto L.threshold atTop (𝓝 0) :=
  latticeResidualThreshold_tendsto L.N L.N_tendsto
lemma alphabetBound_pos (S : Finset ℕ) : 0 < alphabetBound S := by unfold alphabetBound; positivity
lemma primitive_bound (S : Finset ℕ) (g : ℕ) (j : S) :
    (j.val/g:ℕ) ≤ S.sup id+1 :=
  (Nat.div_le_self _ _).trans ((Finset.le_sup (f := id) j.property).trans (Nat.le_succ _))

lemma bulk_card_le (S : Finset ℕ) (k : ℕ) : (L.bulk S k).card ≤ L.N k := by
  exact (Finset.card_le_card (Finset.subset_univ _)).trans_eq (Finset.card_fin _)

lemma bulk_card_tendsto (S : Finset ℕ) (hS : 0 < ∑ j ∈ S,L.p j) :
    Tendsto (fun k => (L.bulk S k).card) atTop atTop :=
  threshold_pruned_card_tendsto L.N L.N_pos L.N_tendsto L.q L.residual L.K
    L.residual_bound L.p L.frequency_tendsto S hS

lemma bulk_frequency_tendsto (S : Finset ℕ) (j : S) :
    Tendsto (fun k => (L.N k:ℝ)⁻¹*((Finset.univ.filter (fun i => L.label S k i=j)).card:ℝ))
      atTop (𝓝 (L.p j.val)) := by
  have h := threshold_pruned_frequency_tendsto L.N L.N_pos L.N_tendsto L.q L.residual L.K
    L.residual_bound L.p L.frequency_tendsto j.val
  apply h.congr'
  exact Eventually.of_forall (fun k => (pruned_label_count (L.q k) (L.residual k) (L.threshold k) S j).symm)

lemma bulk_positive_frequencies (S : Finset ℕ) (hne : S.Nonempty)
    (hS : ∀ j ∈ S,0 < L.p j) :
    ∃ α : ℝ,0 < α ∧ ∀ᶠ k in atTop,∀ j : S,
      α*((L.bulk S k).card:ℝ) ≤ ((Finset.univ.filter (fun i => L.label S k i=j)).card:ℝ) := by
  let α := S.inf' hne L.p/2
  have ha : 0 < α := by
    have h : (0:ℝ) < S.inf' hne L.p := (Finset.lt_inf'_iff hne).mpr hS
    dsimp [α]
    linarith
  have haj (j : S) : α < L.p j := by
    have h := Finset.inf'_le L.p j.property
    dsimp [α] at ha ⊢
    linarith
  refine ⟨α,ha,?_⟩
  apply Filter.eventually_all.mpr
  intro j
  filter_upwards [(L.bulk_frequency_tendsto S j).eventually (lt_mem_nhds (haj j))] with k hk
  have hnR : (0:ℝ)<L.N k := by exact_mod_cast L.N_pos k
  have hh := (mul_lt_mul_of_pos_right hk hnR).le
  have hcan : (L.N k:ℝ)⁻¹*((Finset.univ.filter (fun i => L.label S k i=j)).card:ℝ)*(L.N k:ℝ)=
      ((Finset.univ.filter (fun i => L.label S k i=j)).card:ℝ) := by field_simp
  rw [hcan] at hh
  have hcard : ((L.bulk S k).card:ℝ) ≤ L.N k := by exact_mod_cast L.bulk_card_le S k
  exact (mul_le_mul_of_nonneg_left hcard ha.le).trans hh

lemma rawResidual_abs_le (S : Finset ℕ) (k : ℕ) (i : Fin (L.bulk S k).card) :
    |L.rawResidual S k i| ≤ L.threshold k := pruned_residual_abs_le _ _ _ _ _
lemma rawResidual_energy_le (S : Finset ℕ) (k : ℕ) :
    (∑ i,(L.rawResidual S k i)^2) ≤ L.K :=
  (pruned_residual_energy_le _ _ _ _).trans (L.residual_bound k)
lemma refitResidual_energy_le (S : Finset ℕ) (g k : ℕ) :
    (∑ i,(L.refitResidual S g k i)^2) ≤ L.K :=
  (latticeRefit_energy_le_all _ _).trans (L.rawResidual_energy_le S k)

lemma primitive_pos_odd (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j) (j : S) :
    0 < j.val/g ∧ Odd (j.val/g) := by
  have ho := hodd j.val j.property
  have hj : 0 < j.val := by rcases ho with ⟨a,ha⟩; omega
  exact normalized_support_positive_odd j.val g hj (hodd j.val j.property) hg (hdiv j.val j.property)

lemma refit_orthogonal (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j) (k : ℕ) :
    (∑ i,(L.primitive S g k i:ℝ)*L.refitResidual S g k i)=0 :=
  latticeRefit_orthogonal_positive _ _ (fun i => (primitive_pos_odd S g hg hodd hdiv (L.label S k i)).1)

lemma refitResidual_abs_le (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j)
    (k : ℕ) (i : Fin (L.bulk S k).card) :
    |L.refitResidual S g k i| ≤ (1+alphabetBound S)*L.threshold k := by
  exact latticeRefitResidual_abs_le (by have hi := i.isLt; omega) (L.primitive S g k)
    (fun j => (primitive_pos_odd S g hg hodd hdiv (L.label S k j)).1)
    (L.rawResidual S k) (L.threshold k) (alphabetBound S)
    (L.rawResidual_abs_le S k) (fun j => by unfold primitive alphabetBound; exact_mod_cast primitive_bound S g (L.label S k j)) i

lemma refitGain_tendsto (S : Finset ℕ) (g : ℕ) (hg : 0 < g)
    (hodd : ∀ j ∈ S,Odd j) (hdiv : ∀ j ∈ S,g∣j) :
    Tendsto (L.refitGain S g) atTop (𝓝 (L.a₀*g)) := by
  have hs : Tendsto (fun k => latticeRefitSlope (L.primitive S g k) (L.rawResidual S k)) atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ L.threshold_tendsto
    exact Eventually.of_forall (fun k => by
      simpa only [Real.norm_eq_abs] using latticeRefitSlope_abs_le_all (L.primitive S g k)
        (fun i => (primitive_pos_odd S g hg hodd hdiv (L.label S k i)).1)
        (L.rawResidual S k) (L.threshold k) (L.threshold_pos k).le (L.rawResidual_abs_le S k))
  change Tendsto (fun k => L.a k*g+latticeRefitSlope (L.primitive S g k) (L.rawResidual S k)) atTop (𝓝 (L.a₀*g))
  simpa only [add_zero] using (L.a_tendsto.mul_const (g:ℝ)).add hs

lemma refit_incoming (S : Finset ℕ) (g : ℕ) (hdiv : ∀ j ∈ S,g∣j) (k : ℕ) :
    (fun i => L.refitGain S g k*(L.primitive S g k i:ℝ)+L.refitResidual S g k i)=
      subsetWeights (L.bulk S k) (fun i => |L.u k i|) := by
  exact (pruned_refit_decomposition (L.q k) (L.u k) (L.a k) (L.threshold k) S g hdiv).symm

end LatticeSequence
end NeuralGeneralization.OnlineLowerTanh
