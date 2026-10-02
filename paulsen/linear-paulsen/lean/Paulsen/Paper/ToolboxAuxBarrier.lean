import Paulsen.Linear.Barrier
import Paulsen.MedianBarrier
import Paulsen.DenseCore
import Paulsen.FiniteMedian

/-!
# Helper for `Paulsen.Paper.Toolbox`: attainment in `def:barrier`, connectivity, and the
Poisson constants of `rem:poisson`.
-/

namespace Paulsen.Paper.ToolboxAux

open scoped BigOperators
open Paulsen Paulsen.Linear

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
set_option linter.unusedSectionVars false

theorem continuous_weightedLaplacian (w : ι → ι → ℝ) (i : ι) :
    Continuous (fun ψ : ι → ℝ => weightedLaplacian w ψ i) := by
  unfold weightedLaplacian
  exact continuous_finsetSum _ fun j _ =>
    continuous_const.mul ((continuous_apply i).sub (continuous_apply j))

/-- The set of `S`-barriers bounded by `c` is closed. -/
theorem isClosed_barriers (w : ι → ι → ℝ) (S : Finset ι) (c : ℝ) :
    IsClosed {ψ : ι → ℝ | IsBarrier w S ψ ∧ ∀ i, ψ i ≤ c} := by
  have h1 : IsClosed {ψ : ι → ℝ | ∀ i, 0 ≤ ψ i} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun i => isClosed_le continuous_const (continuous_apply i)
  have h2 : IsClosed {ψ : ι → ℝ | ∀ i, i ∉ S → 1 ≤ weightedLaplacian w ψ i} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun i => isClosed_iInter fun _ =>
      isClosed_le continuous_const (continuous_weightedLaplacian w i)
  have h3 : IsClosed {ψ : ι → ℝ | ∀ i, ψ i ≤ c} := by
    simp only [Set.setOf_forall]
    exact isClosed_iInter fun i => isClosed_le (continuous_apply i) continuous_const
  have : {ψ : ι → ℝ | IsBarrier w S ψ ∧ ∀ i, ψ i ≤ c} =
      ({ψ : ι → ℝ | ∀ i, 0 ≤ ψ i} ∩ {ψ | ∀ i, i ∉ S → 1 ≤ weightedLaplacian w ψ i}) ∩
        {ψ | ∀ i, ψ i ≤ c} := by
    ext ψ; simp [IsBarrier, and_assoc]
  rw [this]
  exact (h1.inter h2).inter h3

/-- Barrier bounds are closed under decreasing limits: the infimum in `def:barrier` is
attained. -/
theorem hasBarrierBound_of_forall_gt {w : ι → ι → ℝ} {H : ℝ}
    (h : ∀ ε : ℝ, 0 < ε → HasBarrierBound w (H + ε)) : HasBarrierBound w H := by
  intro S hS
  let t : ℕ → Set (ι → ℝ) := fun k =>
    {ψ | IsBarrier w S ψ ∧ ∀ i, ψ i ≤ H + 1 / ((k : ℝ) + 1)}
  have htd : ∀ k, t (k + 1) ⊆ t k := by
    intro k ψ hψ
    refine ⟨hψ.1, fun i => (hψ.2 i).trans ?_⟩
    have : 1 / (((k + 1 : ℕ) : ℝ) + 1) ≤ 1 / ((k : ℝ) + 1) := by
      apply one_div_le_one_div_of_le (by positivity)
      push_cast; linarith
    linarith
  have htn : ∀ k, (t k).Nonempty := by
    intro k
    obtain ⟨ψ, hψ, hψH⟩ := h (1 / ((k : ℝ) + 1)) (by positivity) S hS
    exact ⟨ψ, hψ, hψH⟩
  have htcl : ∀ k, IsClosed (t k) := fun k => isClosed_barriers w S _
  have ht0 : IsCompact (t 0) := by
    apply IsCompact.of_isClosed_subset (isCompact_univ_pi (fun _ : ι => isCompact_Icc
      (a := (0 : ℝ)) (b := H + 1 / ((0 : ℕ) + 1 : ℝ)))) (htcl 0)
    intro ψ hψ
    simp only [Set.mem_pi, Set.mem_univ, Set.mem_Icc, true_implies]
    exact fun i => ⟨hψ.1.1 i, hψ.2 i⟩
  obtain ⟨ψ, hψ⟩ := IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed t htd htn
    ht0 htcl
  rw [Set.mem_iInter] at hψ
  refine ⟨ψ, (hψ 0).1, fun i => ?_⟩
  apply le_of_forall_pos_lt_add
  intro ε hε
  obtain ⟨k, hk⟩ := exists_nat_one_div_lt hε
  have := (hψ k).2 i
  linarith

/-- No nonempty set of at most half the vertices is closed under positive edges. -/
theorem barrier_connected' {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i) {H : ℝ} (hH : HasBarrierBound w H) (J : Finset ι)
    (hJ : J.Nonempty) (hJn : 2 * J.card ≤ Fintype.card ι) :
    ∃ i ∈ J, ∃ j, j ∉ J ∧ 0 < w i j := by
  by_contra hcon
  push Not at hcon
  have hzero : ∀ i ∈ J, ∀ j, j ∉ J → w i j = 0 :=
    fun i hi j hj => le_antisymm (hcon i hi j hj) (hw i j)
  obtain ⟨ψ, ⟨_, hψ1⟩, -⟩ := hH Jᶜ (by rw [Finset.card_compl]; omega)
  have hrestrict : ∀ i ∈ J, weightedLaplacian w ψ i = ∑ j ∈ J, w i j * (ψ i - ψ j) := by
    intro i hi
    unfold weightedLaplacian
    exact (Finset.sum_subset (Finset.subset_univ J)
      (fun j _ hj => by rw [hzero i hi j hj, zero_mul])).symm
  have hsum : ∑ i ∈ J, weightedLaplacian w ψ i = 0 := by
    rw [Finset.sum_congr rfl hrestrict]
    have h1 : ∑ i ∈ J, ∑ j ∈ J, w i j * (ψ i - ψ j) =
        ∑ i ∈ J, ∑ j ∈ J, w j i * (ψ j - ψ i) := Finset.sum_comm
    have h2 : ∑ i ∈ J, ∑ j ∈ J, w j i * (ψ j - ψ i) =
        -∑ i ∈ J, ∑ j ∈ J, w i j * (ψ i - ψ j) := by
      rw [← Finset.sum_neg_distrib]
      apply Finset.sum_congr rfl; intro i _
      rw [← Finset.sum_neg_distrib]
      apply Finset.sum_congr rfl; intro j _
      rw [hsymm j i]; ring
    linarith
  have hge : (J.card : ℝ) ≤ ∑ i ∈ J, weightedLaplacian w ψ i := by
    calc (J.card : ℝ) = ∑ _i ∈ J, (1 : ℝ) := by simp
      _ ≤ _ := Finset.sum_le_sum (fun i hi => hψ1 i (fun h => (Finset.mem_compl.mp h) hi))
  have : (0 : ℝ) < J.card := by exact_mod_cast hJ.card_pos
  linarith

/-- `rem:poisson`, `H ≤ 2K`. -/
theorem barrier_of_poisson {w : ι → ι → ℝ} {K : ℝ} (hK : BoundedPoissonSolvability w K) :
    HasBarrierBound w (2 * K) := by
  intro S hS
  rcases isEmpty_or_nonempty ι with hι | hι
  · exact ⟨fun _ => 0, ⟨fun _ => le_rfl, fun i => isEmptyElim i⟩, fun i => isEmptyElim i⟩
  · have hcard : 0 < S.card := by
      have := Fintype.card_pos (α := ι); omega
    obtain ⟨g, hg, hgK⟩ := hK (halfSetForcing S) (halfSetForcing_sum S hcard)
      (halfSetForcing_abs_le_one S hS)
    refine ⟨fun i => g i + K, ⟨fun i => by linarith [(abs_le.mp (hgK i)).1], fun i hi => ?_⟩,
      fun i => by linarith [(abs_le.mp (hgK i)).2]⟩
    have : weightedLaplacian w (fun j => g j + K) i = weightedLaplacian w g i := by
      unfold weightedLaplacian
      apply Finset.sum_congr rfl; intro j _; ring
    rw [this, hg i, halfSetForcing_eq_one hi]

/-- On a connected graph (in the half-set form given by `barrier_connected`), harmonic
functions are constant. -/
theorem harmonic_const {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i)
    (hconn : ∀ J : Finset ι, J.Nonempty → 2 * J.card ≤ Fintype.card ι →
      ∃ i ∈ J, ∃ j, j ∉ J ∧ 0 < w i j) (g : ι → ℝ)
    (hg : ∀ i, weightedLaplacian w g i = 0) (i₁ : ι) : ∀ i, g i = g i₁ := by
  classical
  obtain ⟨k, _, hk⟩ := Finset.exists_max_image Finset.univ g ⟨i₁, Finset.mem_univ _⟩
  have hmax : ∀ j, g j ≤ g k := fun j => hk j (Finset.mem_univ j)
  let J : Finset ι := Finset.univ.filter (fun i => g i = g k)
  have hclosed : ∀ i ∈ J, ∀ j, 0 < w i j → j ∈ J := by
    intro i hi j hij
    have hgi : g i = g k := (Finset.mem_filter.mp hi).2
    have hterms : ∀ l ∈ Finset.univ, 0 ≤ w i l * (g i - g l) := fun l _ =>
      mul_nonneg (hw i l) (by rw [hgi]; linarith [hmax l])
    have h0 := (Finset.sum_eq_zero_iff_of_nonneg hterms).mp (hg i) j (Finset.mem_univ j)
    have : g i - g j = 0 := by
      rcases mul_eq_zero.mp h0 with h | h
      · linarith
      · exact h
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, by linarith⟩
  have hall : ∀ i, i ∈ J := by
    by_contra hnot
    push Not at hnot
    obtain ⟨i₀, hi₀⟩ := hnot
    have hJne : J.Nonempty := ⟨k, Finset.mem_filter.mpr ⟨Finset.mem_univ _, rfl⟩⟩
    have hJcne : Jᶜ.Nonempty := ⟨i₀, Finset.mem_compl.mpr hi₀⟩
    have hcard := Finset.card_add_card_compl J
    by_cases hsmall : 2 * J.card ≤ Fintype.card ι
    · obtain ⟨i, hi, j, hj, hij⟩ := hconn J hJne hsmall
      exact hj (hclosed i hi j hij)
    · obtain ⟨i, hi, j, hj, hij⟩ := hconn Jᶜ hJcne (by omega)
      have hjJ : j ∈ J := by simpa using hj
      have := hclosed j hjJ i (by rw [hsymm]; exact hij)
      exact (Finset.mem_compl.mp hi) this
  intro i
  have h1 : g i = g k := (Finset.mem_filter.mp (hall i)).2
  have h2 : g i₁ = g k := (Finset.mem_filter.mp (hall i₁)).2
  rw [h1, h2]

/-- The additive form of the median barrier argument: if `L g ≤ 1` and `g ≤ m` on a
half-set `S`, then `g ≤ m + H`. -/
theorem additive_barrier_bound {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j) {H : ℝ}
    (hH : HasBarrierBound w H) (g : ι → ℝ) (hLg : ∀ i, weightedLaplacian w g i ≤ 1)
    (m : ℝ) (S : Finset ι) (hS : Fintype.card ι ≤ 2 * S.card) (hSm : ∀ i ∈ S, g i ≤ m) :
    ∀ i, g i ≤ m + H := by
  classical
  obtain ⟨ψ, ⟨hψ0, hψ1⟩, hψH⟩ := hH S hS
  intro i
  have hH0 : 0 ≤ H := (hψ0 i).trans (hψH i)
  have key : ∀ c : ℝ, 1 < c → g i ≤ m + c * H := by
    intro c hc
    let v : ι → ℝ := fun j => g j - m - c * ψ j
    obtain ⟨i₀, _, hi₀⟩ := Finset.exists_max_image Finset.univ v ⟨i, Finset.mem_univ _⟩
    have hvmax : ∀ j, v j ≤ v i₀ := fun j => hi₀ j (Finset.mem_univ j)
    have hi₀S : i₀ ∈ S := by
      by_contra hnot
      have hlap0 : 0 ≤ weightedLaplacian w v i₀ :=
        weightedLaplacian_nonneg_at_max (fun j => hw i₀ j) hvmax
      have hlap : weightedLaplacian w v i₀ =
          weightedLaplacian w g i₀ - c * weightedLaplacian w ψ i₀ :=
        weightedLaplacian_sub_const_sub_smul w g ψ m c i₀
      have h1 := hLg i₀
      have h2 := hψ1 i₀ hnot
      have h4 : c * 1 ≤ c * weightedLaplacian w ψ i₀ :=
        mul_le_mul_of_nonneg_left h2 (by linarith)
      linarith
    have hv0 : v i₀ ≤ 0 := by
      have := hSm i₀ hi₀S
      have hψi := hψ0 i₀
      show g i₀ - m - c * ψ i₀ ≤ 0
      nlinarith
    have hvi : v i ≤ 0 := (hvmax i).trans hv0
    have hψi : c * ψ i ≤ c * H := mul_le_mul_of_nonneg_left (hψH i) (by linarith)
    show g i ≤ m + c * H
    have : g i - m - c * ψ i ≤ 0 := hvi
    linarith
  apply le_of_forall_pos_le_add
  intro ε hε
  have := key (1 + ε / (H + 1)) (by have : 0 < ε / (H + 1) := by positivity
                                    linarith)
  have hle : ε / (H + 1) * H ≤ ε := by
    rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
    nlinarith
  nlinarith

/-- `rem:poisson`, `K ≤ H`. -/
theorem poisson_of_barrier {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i) {H : ℝ} (hH : HasBarrierBound w H)
    (hconn : ∀ J : Finset ι, J.Nonempty → 2 * J.card ≤ Fintype.card ι →
      ∃ i ∈ J, ∃ j, j ∉ J ∧ 0 < w i j) :
    BoundedPoissonSolvability w H := by
  classical
  intro f hfsum hf1
  rcases isEmpty_or_nonempty ι with hι | hι
  · exact ⟨fun _ => 0, fun i => isEmptyElim i, fun i => isEmptyElim i⟩
  have hn : 0 < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  -- solvability through the augmented map `g ↦ L g + (∑ g) 𝟙`
  have hsumL : ∀ g : ι → ℝ, ∑ i, augmentedPoissonMap w g i =
      (Fintype.card ι : ℝ) * ∑ j, g j := by
    intro g
    change (∑ i, (weightedLaplacian w g i + ∑ j, g j)) = _
    rw [Finset.sum_add_distrib, symmetric_weightedLaplacian_sum_zero w hsymm g, zero_add,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hinj : Function.Injective (augmentedPoissonMap w) := by
    rw [← LinearMap.ker_eq_bot, LinearMap.ker_eq_bot']
    intro g hg
    have hs := hsumL g
    rw [hg] at hs
    simp only [Pi.zero_apply, Finset.sum_const_zero] at hs
    have hmean : ∑ j, g j = 0 := by
      rcases mul_eq_zero.mp hs.symm with h | h
      · linarith
      · exact h
    have hharm : ∀ i, weightedLaplacian w g i = 0 := by
      intro i
      have := congrFun hg i
      change weightedLaplacian w g i + ∑ j, g j = 0 at this
      linarith
    obtain ⟨i₁⟩ := hι
    have hc := harmonic_const hw hsymm hconn g hharm i₁
    have : ∑ j, g j = (Fintype.card ι : ℝ) * g i₁ := by
      rw [Finset.sum_congr rfl (fun j _ => hc j)]; simp
    funext i
    rw [hc i, Pi.zero_apply]
    rw [this] at hmean
    rcases mul_eq_zero.mp hmean with h | h
    · linarith
    · exact h
  obtain ⟨g, hg⟩ := (LinearMap.injective_iff_surjective.mp hinj) f
  have hs := hsumL g
  rw [hg, hfsum] at hs
  have hmean : ∑ j, g j = 0 := by
    rcases mul_eq_zero.mp hs.symm with h | h
    · linarith
    · exact h
  have hLg : ∀ i, weightedLaplacian w g i = f i := by
    intro i
    have := congrFun hg i
    change weightedLaplacian w g i + ∑ j, g j = f i at this
    linarith
  -- the median bound
  obtain ⟨k, hlow, hhigh⟩ := finite_median_index g
  have hup := additive_barrier_bound hw hH g (fun i => by rw [hLg]; exact (abs_le.mp (hf1 i)).2)
    (g k) (Finset.univ.filter (fun i => g i ≤ g k)) hlow
    (fun i hi => (Finset.mem_filter.mp hi).2)
  have hneg : ∀ i, weightedLaplacian w (fun j => -g j) i = -f i := by
    intro i
    rw [← hLg i]
    unfold weightedLaplacian
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl; intro j _; ring
  have hdown := additive_barrier_bound hw hH (fun j => -g j)
    (fun i => by rw [hneg]; linarith [(abs_le.mp (hf1 i)).1])
    (-g k) (Finset.univ.filter (fun i => g k ≤ g i)) hhigh
    (fun i hi => by have := (Finset.mem_filter.mp hi).2; linarith)
  refine ⟨fun i => g i - g k, fun i => ?_, fun i => ?_⟩
  · have : weightedLaplacian w (fun j => g j - g k) i = weightedLaplacian w g i := by
      unfold weightedLaplacian
      apply Finset.sum_congr rfl; intro j _; ring
    rw [this, hLg]
  · rw [abs_le]
    constructor
    · have := hdown i; linarith
    · have := hup i; linarith

end Paulsen.Paper.ToolboxAux
