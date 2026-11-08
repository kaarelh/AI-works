import NeuralGeneralization.OnlineLowerTanhExactBulkPhase
import NeuralGeneralization.OnlineLowerTanhEqualBulkMax
import NeuralGeneralization.OnlineLowerTanhOutlierComparison
import NeuralGeneralization.OnlineLowerTanhOutlierFinite
import NeuralGeneralization.OnlineLowerTanhConditioningCap

/-! # Elimination of every actual optimizer outlier -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Both parities of bulk degree share the next odd balanced reference.
The even-degree error is converted to that reference's squared denominator. -/
theorem equalBulk_uniform_reference_cap :
    ∃ K : ℝ, 0 < K ∧ ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ n : ℕ, N₀≤n →
      ∀ a : ℝ, 1≤a → a≤2 → ∀ b : ℝ,
      |parityCorrelation (fun _ : Fin n => a) b| ≤
        balancedParity (n/2) a*(1+K/(2*((n/2 : ℕ) : ℝ)+1)^2) := by
  obtain ⟨N₁,hN₁,hodd⟩ := odd_equalBulk_arbitrary_bias
  obtain ⟨K,hK,N₂,hN₂,heven⟩ := even_equalBulk_arbitrary_bias
  refine ⟨4*K,by positivity,max N₁ N₂,by omega,?_⟩
  intro n hn a ha ha2 b
  have hn1 : N₁≤n := le_trans (le_max_left _ _) hn
  have hn2 : N₂≤n := le_trans (le_max_right _ _) hn
  have hn0 : 0<n := lt_of_lt_of_le hN₁ hn1
  have hcase : n=2*(n/2) ∨ n=2*(n/2)+1 := by omega
  rcases hcase with he | ho
  · have hh := heven (n/2) (by omega) a ha ha2 b
    have he' : (n : ℝ)=2*((n/2 : ℕ) : ℝ) := by exact_mod_cast he
    have hc := even_bulk_error_to_odd_reference n (by omega) K hK.le
    rw [he'] at hc
    have hp := mul_le_mul_of_nonneg_left (add_le_add_right hc 1)
      (balancedParity_pos_of_one_le (n/2) a ha).le
    have hh' : |parityCorrelation (fun _ : Fin n => a) b| ≤
        balancedParity (n/2) a*(1+K/(2*((n/2 : ℕ) : ℝ))^2) := by
      have hcorr := parityCorrelation_equiv (finCongr he) (fun _ => a) b
      change parityCorrelation (fun _ : Fin n => a) b =
        parityCorrelation (fun _ : Fin (2*(n/2)) => a) b at hcorr
      rw [hcorr]
      exact hh
    exact hh'.trans hp
  · have hh := hodd (n/2) (by omega) a ha ha2 b
    have hh' : |parityCorrelation (fun _ : Fin n => a) b| ≤ balancedParity (n/2) a := by
      have hcorr := parityCorrelation_equiv (finCongr ho) (fun _ => a) b
      change parityCorrelation (fun _ : Fin n => a) b =
        parityCorrelation (fun _ : Fin (2*(n/2)+1) => a) b at hcorr
      rw [hcorr]
      exact hh
    have hp : balancedParity (n/2) a ≤ balancedParity (n/2) a*(1+(4*K)/(2*((n/2 : ℕ) : ℝ)+1)^2) := by
      have hq := balancedParity_pos_of_one_le (n/2) a ha
      have hg : 0≤(4*K)/(2*((n/2 : ℕ) : ℝ)+1)^2 := by positivity
      nlinarith
    exact hh'.trans hp

namespace NearBalancedSequence
variable (B : NearBalancedSequence)

/-- The complete equality class of the actual bulk amplitude. -/
def equalCoordinates (k : ℕ) : Finset (Fin (B.N k)) :=
  Finset.univ.filter (fun i => B.u k i=B.bulkAmplitude k)

@[simp] lemma mem_equalCoordinates (k : ℕ) (i : Fin (B.N k)) :
    i∈B.equalCoordinates k ↔ B.u k i=B.bulkAmplitude k := by
  simp [equalCoordinates]

lemma bulk_subset_equalCoordinates_eventually :
    ∀ᶠ k in atTop,B.bulk k⊆B.equalCoordinates k := by
  filter_upwards [B.bulk_eventually_amplitude] with k hk i hi
  exact (B.mem_equalCoordinates k i).mpr (hk i hi)

lemma equalCoordinates_card_tendsto :
    Tendsto (fun k => (B.equalCoordinates k).card) atTop atTop := by
  apply tendsto_atTop_mono' atTop _ B.bulk_tendsto
  exact B.bulk_subset_equalCoordinates_eventually.mono fun k hk => Finset.card_le_card hk

lemma equalCoordinates_fraction_tendsto :
    Tendsto (fun k => (B.N k : ℝ)⁻¹*((B.equalCoordinates k).card : ℝ)) atTop (𝓝 1) := by
  apply tendsto_of_tendsto_of_tendsto_of_le_of_le' B.bulk_fraction tendsto_const_nhds
  · filter_upwards [B.bulk_subset_equalCoordinates_eventually] with k hk
    have hc : ((B.bulk k).card : ℝ)≤(B.equalCoordinates k).card := by
      exact_mod_cast Finset.card_le_card hk
    exact mul_le_mul_of_nonneg_left hc (inv_nonneg.mpr (Nat.cast_nonneg _))
  · filter_upwards [] with k
    have hc : ((B.equalCoordinates k).card : ℝ)≤B.N k := by
      exact_mod_cast (show (B.equalCoordinates k).card≤B.N k by
        simpa only [Fintype.card_fin] using Finset.card_le_univ (B.equalCoordinates k))
    have hN : (B.N k : ℝ)≠0 := by exact_mod_cast (B.N_pos k).ne'
    simpa only [inv_mul_cancel₀ hN] using
      mul_le_mul_of_nonneg_left hc (inv_nonneg.mpr (Nat.cast_nonneg (B.N k) : (0:ℝ)≤B.N k))

/-- A convenient scalar upper bound for the relative outlier count tends to
zero, including the one-coordinate parity correction. -/
lemma equalCoordinates_outlier_ratio_tendsto :
    Tendsto (fun k => ((B.N k : ℝ)-(B.equalCoordinates k).card+1)/(B.equalCoordinates k).card)
      atTop (𝓝 0) := by
  have hInv : Tendsto (fun k => (B.N k : ℝ)⁻¹) atTop (𝓝 0) := by
    simpa only [one_div] using (tendsto_const_nhds.div_atTop
      (tendsto_natCast_atTop_atTop.comp B.N_tendsto) :
      Tendsto (fun k => (1:ℝ)/(B.N k : ℝ)) atTop (𝓝 0))
  have hOne : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
  have hnumer := (hOne.sub B.equalCoordinates_fraction_tendsto).add hInv
  have hh := hnumer.div B.equalCoordinates_fraction_tendsto (by norm_num : (1:ℝ)≠0)
  simp only [sub_self,zero_add,zero_div] at hh
  apply hh.congr'
  filter_upwards [B.equalCoordinates_card_tendsto.eventually_gt_atTop 0] with k hk
  have hb : (((B.equalCoordinates k).card : ℕ) : ℝ)≠0 := by exact_mod_cast hk.ne'
  have hN : (B.N k : ℝ)≠0 := by exact_mod_cast (B.N_pos k).ne'
  dsimp only [Pi.div_apply]
  field_simp [hb,hN]

lemma equalCoordinates_subsetWeights (k : ℕ) :
    subsetWeights (B.equalCoordinates k) (B.u k) =
      (fun _ : Fin (B.equalCoordinates k).card => B.bulkAmplitude k) := by
  funext i
  exact (B.mem_equalCoordinates k ((B.equalCoordinates k).equivFin.symm i).val).mp
    ((B.equalCoordinates k).equivFin.symm i).property

/-- The all-bias theorem is applied to the literal equality class and then
conditioned over every remaining physical input coordinate. -/
theorem equalCoordinates_coefficient_cap :
    ∃ K : ℝ, 0<K ∧ ∀ᶠ k in atTop,
      |parityCorrelation (B.u k) 0| ≤
        balancedParity ((B.equalCoordinates k).card/2) (B.bulkAmplitude k)*
          (1+K/(2*((B.equalCoordinates k).card/2 : ℕ)+1)^2) := by
  obtain ⟨K,hK,N₀,hN₀,hcap⟩ := equalBulk_uniform_reference_cap
  refine ⟨K,hK,?_⟩
  filter_upwards [B.equalCoordinates_card_tendsto.eventually_ge_atTop N₀,
    B.bulkAmplitude_eventually_mem] with k hk ha
  apply parityCorrelation_le_uniform_subset_cap (B.equalCoordinates k) (B.u k) 0
  intro b
  rw [B.equalCoordinates_subsetWeights]
  exact hcap _ hk _ ha.1 ha.2 b

/-- Every coordinate of every sufficiently late actual maximizer equals the
bulk amplitude. All global-bias, conditioning, energy, and parity conditions
are discharged by the preceding literal-vector theorems. -/
theorem eventually_all_equal :
    ∀ᶠ k in atTop,∀i,B.u k i=B.bulkAmplitude k := by
  obtain ⟨K,hK,hcap⟩ := B.equalCoordinates_coefficient_cap
  have hdegree := (tendsto_natCast_atTop_atTop (R:=ℝ)).comp B.equalCoordinates_card_tendsto
  filter_upwards [hcap,B.bulkAmplitude_eventually_mem,B.unequal_coordinate_large_eventually,
    B.equalCoordinates_card_tendsto.eventually_gt_atTop 0,
    hdegree.eventually_ge_atTop (32*(scalarFirstError+scalarFirstBound+K+1)),
    B.equalCoordinates_outlier_ratio_tendsto.eventually
      (gt_mem_nhds (by norm_num : (0:ℝ)<1/32))]
      with k hck hak hout hb hlarge hsmall i
  by_contra hi
  have hnot : i∉B.equalCoordinates k := by simpa only [B.mem_equalCoordinates] using hi
  have hproper : (B.equalCoordinates k).card<B.N k := by
    simpa only [Fintype.card_fin] using Finset.card_lt_univ_of_notMem hnot
  have hfloor : ((B.equalCoordinates k).card : ℝ) ≤
      2*((B.equalCoordinates k).card/2 : ℕ)+1 := by
    exact_mod_cast (show (B.equalCoordinates k).card≤2*((B.equalCoordinates k).card/2)+1 by omega)
  have hbulk : ∀x∈B.equalCoordinates k,|B.u k x|=B.bulkAmplitude k := by
    intro x hx
    rw [abs_of_nonneg (B.u_nonneg k x)]
    exact (B.mem_equalCoordinates k x).mp hx
  have hout' : ∀x,x∉B.equalCoordinates k → 5*B.bulkAmplitude k/2≤|B.u k x| := by
    intro x hx
    have hx' : B.u k x≠B.bulkAmplitude k := by simpa only [B.mem_equalCoordinates] using hx
    rw [abs_of_nonneg (B.u_nonneg k x)]
    convert hout x hx' using 1 <;> ring
  exact (finite_equal_bulk_not_maximizer (B.N_odd k) (B.u k) (B.equalCoordinates k)
    (B.bulkAmplitude k) K hak.1 hK.le hb hproper (hlarge.trans hfloor) hsmall.le hck hbulk hout')
    (B.maximal k)

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
