import Paulsen.MedianBarrier
import Mathlib.LinearAlgebra.FiniteDimensional.Basic

/-!
# Maximum--minimum comparison and bounded Poisson solvability

The direct overlap argument compares a maximizing and a minimizing row.
Finite-dimensional invertibility supplies solutions, and midpoint centering
gives the infinity bound. Earlier stochastic lemmas are retained as auxiliary
results, but are not used by the dense-core or exceptional-set proof route.
-/

namespace Paulsen

open scoped BigOperators

variable {ι : Type*} [Fintype ι]

/-- The elementary two-row Dobrushin inequality. -/
theorem stochastic_rows_difference_bound
    (p q f : ι → ℝ) (m M γ : ℝ)
    (hp : (∑ j, p j) = 1) (hq : (∑ j, q j) = 1)
    (hoverlap : γ ≤ ∑ j, min (p j) (q j))
    (hinterval : m ≤ M)
    (hlower : ∀ j, m ≤ f j) (hupper : ∀ j, f j ≤ M) :
    (∑ j, p j * f j) - (∑ j, q j * f j) ≤ (1 - γ) * (M - m) := by
  have hterm : ∀ j, (p j - q j) * f j ≤
      (p j - min (p j) (q j)) * M - (q j - min (p j) (q j)) * m := by
    intro j
    have hleft := mul_le_mul_of_nonneg_left (hupper j)
      (sub_nonneg.mpr (min_le_left (p j) (q j)))
    have hright := mul_le_mul_of_nonneg_left (hlower j)
      (sub_nonneg.mpr (min_le_right (p j) (q j)))
    nlinarith
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ (Finset.univ : Finset ι)) => hterm j)
  simp only [sub_mul, Finset.sum_sub_distrib, ← Finset.sum_mul, hp, hq] at hsum
  nlinarith

/-- A row-stochastic kernel's weighted Laplacian is its identity defect. -/
theorem stochastic_weightedLaplacian (T : ι → ι → ℝ)
    (hrows : ∀ i, (∑ j, T i j) = 1) (g : ι → ℝ) (i : ι) :
    weightedLaplacian T g i = g i - ∑ j, T i j * g j := by
  unfold weightedLaplacian
  simp_rw [mul_sub]
  rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hrows i, one_mul]

/-- A doubly stochastic kernel's Laplacian has total output zero. -/
theorem stochastic_laplacian_sum_zero (T : ι → ι → ℝ)
    (hrows : ∀ i, (∑ j, T i j) = 1)
    (hcols : ∀ j, (∑ i, T i j) = 1) (g : ι → ℝ) :
    (∑ i, weightedLaplacian T g i) = 0 := by
  simp_rw [stochastic_weightedLaplacian T hrows]
  rw [Finset.sum_sub_distrib]
  have hsum : (∑ i, ∑ j, T i j * g j) = ∑ j, g j := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j _
    rw [← Finset.sum_mul, hcols j, one_mul]
  rw [hsum, sub_self]

/-- Quantitative oscillation gives an infinity bound for any mean-zero
solution, before existence of the solution is considered. -/
theorem stochastic_poisson_solution_bound [Nonempty ι]
    (T : ι → ι → ℝ) (γ B : ℝ) (f g : ι → ℝ)
    (hγ : 0 < γ)
    (hrows : ∀ i, (∑ j, T i j) = 1)
    (hoverlap : ∀ i k, γ ≤ ∑ j, min (T i j) (T k j))
    (hmean : (∑ i, g i) = 0)
    (heq : ∀ i, weightedLaplacian T g i = f i)
    (hf : ∀ i, |f i| ≤ B) :
    ∀ i, |g i| ≤ 2 * B / γ := by
  classical
  obtain ⟨imax, _, hmax⟩ := Finset.exists_max_image Finset.univ g Finset.univ_nonempty
  obtain ⟨imin, _, hmin⟩ := Finset.exists_min_image Finset.univ g Finset.univ_nonempty
  have hgmax : ∀ i, g i ≤ g imax := fun i => hmax i (Finset.mem_univ i)
  have hgmin : ∀ i, g imin ≤ g i := fun i => hmin i (Finset.mem_univ i)
  have hc := stochastic_rows_difference_bound (T imax) (T imin) g (g imin) (g imax) γ
    (hrows imax) (hrows imin) (hoverlap imax imin) (hgmax imin) hgmin hgmax
  have heqmax := heq imax
  have heqmin := heq imin
  rw [stochastic_weightedLaplacian T hrows] at heqmax heqmin
  have hfmax := (abs_le.mp (hf imax)).2
  have hfmin := (abs_le.mp (hf imin)).1
  have hoscmul : (g imax - g imin) * γ ≤ 2 * B := by nlinarith
  have hosc : g imax - g imin ≤ 2 * B / γ := (le_div_iff₀ hγ).mpr hoscmul
  have hsummin := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset ι)) => hgmin i)
  have hsummax := Finset.sum_le_sum (fun i (_ : i ∈ (Finset.univ : Finset ι)) => hgmax i)
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, hmean] at hsummin hsummax
  have hn : 0 < (Fintype.card ι : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hmin0 : g imin ≤ 0 := by nlinarith
  have hmax0 : 0 ≤ g imax := by nlinarith
  intro i
  rw [abs_le]
  constructor <;> linarith [hgmin i, hgmax i]

/-- The Laplacian plus the unnormalized mean map, a linear endomorphism. -/
noncomputable def augmentedPoissonMap (T : ι → ι → ℝ) : (ι → ℝ) →ₗ[ℝ] (ι → ℝ) where
  toFun g i := weightedLaplacian T g i + ∑ j, g j
  map_add' g h := by
    ext i
    simp only [weightedLaplacian, Pi.add_apply, add_sub_add_comm, mul_add,
      Finset.sum_add_distrib]
    ring
  map_smul' c g := by
    ext i
    simp only [weightedLaplacian, Pi.smul_apply, smul_eq_mul, RingHom.id_apply,
      mul_add, mul_sub, Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    ring

theorem augmentedPoissonMap_sum (T : ι → ι → ℝ)
    (hrows : ∀ i, (∑ j, T i j) = 1)
    (hcols : ∀ j, (∑ i, T i j) = 1) (g : ι → ℝ) :
    (∑ i, augmentedPoissonMap T g i) = (Fintype.card ι : ℝ) * ∑ j, g j := by
  change (∑ i, (weightedLaplacian T g i + ∑ j, g j)) = _
  rw [Finset.sum_add_distrib, stochastic_laplacian_sum_zero T hrows hcols,
    zero_add, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- Finite-dimensional invertibility supplies Poisson solutions with the
Dobrushin infinity bound. No Neumann series is needed. -/
theorem boundedPoisson_of_stochastic_overlap [Nonempty ι]
    (T : ι → ι → ℝ) (γ : ℝ)
    (hγ : 0 < γ)
    (hrows : ∀ i, (∑ j, T i j) = 1)
    (hcols : ∀ j, (∑ i, T i j) = 1)
    (hoverlap : ∀ i k, γ ≤ ∑ j, min (T i j) (T k j)) :
    BoundedPoissonSolvability T (2 / γ) := by
  have hn : 0 < (Fintype.card ι : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hkernel : ∀ g : ι → ℝ, augmentedPoissonMap T g = 0 → g = 0 := by
    intro g hg
    have hsum := augmentedPoissonMap_sum T hrows hcols g
    rw [hg] at hsum
    simp only [Pi.zero_apply, Finset.sum_const_zero] at hsum
    have hmean : (∑ i, g i) = 0 := by nlinarith
    have heq : ∀ i, weightedLaplacian T g i = 0 := by
      intro i
      have hi := congrFun hg i
      change weightedLaplacian T g i + ∑ j, g j = 0 at hi
      simpa only [hmean, add_zero] using hi
    have hb := stochastic_poisson_solution_bound T γ 0 (fun _ => 0) g hγ hrows
      hoverlap hmean heq (fun _ => by simp)
    ext i
    have hi := hb i
    have hi0 : |g i| ≤ 0 := by simpa only [mul_zero, zero_div] using hi
    exact abs_eq_zero.mp (le_antisymm hi0 (abs_nonneg _))
  have hinj : Function.Injective (augmentedPoissonMap T) := by
    intro x y hxy
    have hzero : augmentedPoissonMap T (x - y) = 0 := by rw [map_sub, hxy, sub_self]
    exact sub_eq_zero.mp (hkernel (x - y) hzero)
  have hsurj : Function.Surjective (augmentedPoissonMap T) :=
    LinearMap.injective_iff_surjective.mp hinj
  intro f hfmean hfbound
  obtain ⟨g, hg⟩ := hsurj f
  have hsum := augmentedPoissonMap_sum T hrows hcols g
  rw [hg, hfmean] at hsum
  have hmean : (∑ i, g i) = 0 := by nlinarith
  have heq : ∀ i, weightedLaplacian T g i = f i := by
    intro i
    have hi := congrFun hg i
    change weightedLaplacian T g i + ∑ j, g j = f i at hi
    simpa only [hmean, add_zero] using hi
  refine ⟨g, heq, ?_⟩
  simpa only [mul_one] using stochastic_poisson_solution_bound T γ 1 f g hγ hrows
    hoverlap hmean heq hfbound

variable [DecidableEq ι]

/-- Add self-loop mass to complete a sub-stochastic kernel to a stochastic one.
Self-loops do not affect the weighted Laplacian. -/
noncomputable def stochasticCompletion (w : ι → ι → ℝ) (i j : ι) : ℝ :=
  w i j + if i = j then 1 - ∑ k, w i k else 0

theorem stochasticCompletion_row_sum (w : ι → ι → ℝ) (i : ι) :
    (∑ j, stochasticCompletion w i j) = 1 := by
  simp [stochasticCompletion, Finset.sum_add_distrib]

theorem stochasticCompletion_symmetric (w : ι → ι → ℝ)
    (hsymm : ∀ i j, w i j = w j i) (i j : ι) :
    stochasticCompletion w i j = stochasticCompletion w j i := by
  by_cases hij : i = j
  · subst j
    rfl
  · simp [stochasticCompletion, hij, Ne.symm hij, hsymm i j]

theorem stochasticCompletion_ge (w : ι → ι → ℝ)
    (hmass : ∀ i, (∑ j, w i j) ≤ 1) (i j : ι) :
    w i j ≤ stochasticCompletion w i j := by
  unfold stochasticCompletion
  split_ifs
  · linarith [hmass i]
  · simp

theorem stochasticCompletion_laplacian (w : ι → ι → ℝ) (g : ι → ℝ) (i : ι) :
    weightedLaplacian (stochasticCompletion w) g i = weightedLaplacian w g i := by
  unfold weightedLaplacian
  apply Finset.sum_congr rfl
  intro j _
  by_cases hij : i = j
  · subst j
    simp
  · simp [stochasticCompletion, hij]

omit [DecidableEq ι] in
/-- Symmetry makes the Laplacian image have coordinate sum zero. -/
theorem symmetric_weightedLaplacian_sum_zero
    (w : ι → ι → ℝ) (hsymm : ∀ i j, w i j = w j i) (g : ι → ℝ) :
    (∑ i, weightedLaplacian w g i) = 0 := by
  have hflip : (∑ i, weightedLaplacian w g i) = -(∑ i, weightedLaplacian w g i) := by
    unfold weightedLaplacian
    calc
      (∑ i, ∑ j, w i j * (g i - g j)) = ∑ j, ∑ i, w i j * (g i - g j) :=
        Finset.sum_comm
      _ = ∑ j, ∑ i, -(w j i * (g j - g i)) := by
        apply Finset.sum_congr rfl
        intro j _
        apply Finset.sum_congr rfl
        intro i _
        rw [hsymm i j]
        ring
      _ = _ := by simp only [Finset.sum_neg_distrib]
  linarith

omit [DecidableEq ι] in
/-- Comparing the maximizing and minimizing equations gives the overlap
bound immediately, with no stochastic normalization or iteration. -/
theorem laplacian_extrema_overlap_bound
    (w : ι → ι → ℝ) (g : ι → ℝ) (γ : ℝ) (imax imin : ι)
    (hoverlap : γ ≤ ∑ j, min (w imax j) (w imin j))
    (hmax : ∀ j, g j ≤ g imax) (hmin : ∀ j, g imin ≤ g j) :
    γ * (g imax - g imin) ≤
      weightedLaplacian w g imax - weightedLaplacian w g imin := by
  have hterm (j : ι) : min (w imax j) (w imin j) * (g imax - g imin) ≤
      w imax j * (g imax - g j) - w imin j * (g imin - g j) := by
    have h1 := mul_le_mul_of_nonneg_right (min_le_left (w imax j) (w imin j))
      (sub_nonneg.mpr (hmax j))
    have h2 := mul_le_mul_of_nonneg_right (min_le_right (w imax j) (w imin j))
      (sub_nonneg.mpr (hmin j))
    nlinarith
  calc
    γ * (g imax - g imin) ≤ (∑ j, min (w imax j) (w imin j)) * (g imax - g imin) :=
      mul_le_mul_of_nonneg_right hoverlap (sub_nonneg.mpr (hmax imin))
    _ = ∑ j, min (w imax j) (w imin j) * (g imax - g imin) := Finset.sum_mul _ _ _
    _ ≤ ∑ j, (w imax j * (g imax - g j) - w imin j * (g imin - g j)) :=
      Finset.sum_le_sum (fun j _ => hterm j)
    _ = _ := by rw [Finset.sum_sub_distrib]; rfl

omit [DecidableEq ι] in
/-- Quantitative row overlap gives a Poisson constant `1/γ`. The solution
is centered by the midpoint of its range, as in the paper. -/
theorem boundedPoisson_of_overlap_extrema [Nonempty ι]
    (w : ι → ι → ℝ) (γ : ℝ)
    (hγ : 0 < γ)
    (hsymm : ∀ i j, w i j = w j i)
    (hoverlap : ∀ i k, γ ≤ ∑ j, min (w i j) (w k j)) :
    BoundedPoissonSolvability w (1 / γ) := by
  classical
  have hn : 0 < (Fintype.card ι : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hsum (g : ι → ℝ) :
      (∑ i, augmentedPoissonMap w g i) = (Fintype.card ι : ℝ) * ∑ j, g j := by
    change (∑ i, (weightedLaplacian w g i + ∑ j, g j)) = _
    rw [Finset.sum_add_distrib, symmetric_weightedLaplacian_sum_zero w hsymm,
      zero_add, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have hkernel : ∀ g : ι → ℝ, augmentedPoissonMap w g = 0 → g = 0 := by
    intro g hg
    have hsumg := hsum g
    rw [hg] at hsumg
    simp only [Pi.zero_apply, Finset.sum_const_zero] at hsumg
    have hmean : (∑ i, g i) = 0 := by nlinarith
    have heq (i : ι) : weightedLaplacian w g i = 0 := by
      have hi := congrFun hg i
      change weightedLaplacian w g i + ∑ j, g j = 0 at hi
      simpa only [hmean, add_zero] using hi
    obtain ⟨imax, _, hmax⟩ := Finset.exists_max_image Finset.univ g Finset.univ_nonempty
    obtain ⟨imin, _, hmin⟩ := Finset.exists_min_image Finset.univ g Finset.univ_nonempty
    have hgmax : ∀ i, g i ≤ g imax := fun i => hmax i (Finset.mem_univ i)
    have hgmin : ∀ i, g imin ≤ g i := fun i => hmin i (Finset.mem_univ i)
    have hosc := laplacian_extrema_overlap_bound w g γ imax imin
      (hoverlap imax imin) hgmax hgmin
    rw [heq imax, heq imin] at hosc
    have hconstant : ∀ i, g i = g imin := by
      intro i
      nlinarith [hgmax i, hgmin i]
    have hzero : g imin = 0 := by
      simp only [hconstant, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hmean
      nlinarith
    ext i
    exact (hconstant i).trans hzero
  have hinj : Function.Injective (augmentedPoissonMap w) := by
    intro x y hxy
    apply sub_eq_zero.mp
    exact hkernel (x - y) (by rw [map_sub, hxy, sub_self])
  have hsurj : Function.Surjective (augmentedPoissonMap w) :=
    LinearMap.injective_iff_surjective.mp hinj
  intro f hfmean hfbound
  obtain ⟨g, hg⟩ := hsurj f
  have hsumg := hsum g
  rw [hg, hfmean] at hsumg
  have hmean : (∑ i, g i) = 0 := by nlinarith
  have heq (i : ι) : weightedLaplacian w g i = f i := by
    have hi := congrFun hg i
    change weightedLaplacian w g i + ∑ j, g j = f i at hi
    simpa only [hmean, add_zero] using hi
  obtain ⟨imax, _, hmax⟩ := Finset.exists_max_image Finset.univ g Finset.univ_nonempty
  obtain ⟨imin, _, hmin⟩ := Finset.exists_min_image Finset.univ g Finset.univ_nonempty
  have hgmax : ∀ i, g i ≤ g imax := fun i => hmax i (Finset.mem_univ i)
  have hgmin : ∀ i, g imin ≤ g i := fun i => hmin i (Finset.mem_univ i)
  have hosc := laplacian_extrema_overlap_bound w g γ imax imin
    (hoverlap imax imin) hgmax hgmin
  rw [heq imax, heq imin] at hosc
  have hoscle : g imax - g imin ≤ 2 / γ := by
    apply (le_div_iff₀ hγ).mpr
    nlinarith [(abs_le.mp (hfbound imax)).2, (abs_le.mp (hfbound imin)).1]
  refine ⟨fun i => g i - (g imax + g imin) / 2, ?_, ?_⟩
  · intro i
    convert heq i using 1
    unfold weightedLaplacian
    apply Finset.sum_congr rfl
    intro j _
    congr 1
    ring
  · intro i
    change |g i - (g imax + g imin) / 2| ≤ 1 / γ
    rw [show (2 : ℝ) / γ = 2 * (1 / γ) by ring] at hoscle
    rw [abs_le]
    constructor <;> linarith [hgmax i, hgmin i]

/-- Compatibility interface with a looser constant. The proof itself uses
the direct maximum--minimum comparison and needs no row-mass bound. -/
theorem boundedPoisson_of_overlap [Nonempty ι]
    (w : ι → ι → ℝ) (γ : ℝ)
    (hγ : 0 < γ)
    (hsymm : ∀ i j, w i j = w j i)
    (_hmass : ∀ i, (∑ j, w i j) ≤ 1)
    (hoverlap : ∀ i k, γ ≤ ∑ j, min (w i j) (w k j)) :
    BoundedPoissonSolvability w (2 / γ) := by
  intro f hfmean hfbound
  obtain ⟨g, hg, hbound⟩ := boundedPoisson_of_overlap_extrema w γ hγ hsymm hoverlap
    f hfmean hfbound
  exact ⟨g, hg, fun i => (hbound i).trans
    (div_le_div_of_nonneg_right (by norm_num) hγ.le)⟩

/-- Neighbors joined by an edge at the dense-core threshold `γ / n`. -/
noncomputable def largeNeighbors (w : ι → ι → ℝ) (γ : ℝ) (i : ι) : Finset ι :=
  Finset.univ.filter (fun j => γ / (Fintype.card ι : ℝ) ≤ w i j)

/-- Two subsets each containing at least four fifths of the vertices have
at least half of the vertices in common. -/
theorem dense_neighbor_intersection_half
    (w : ι → ι → ℝ) (γ : ℝ)
    (hdense : ∀ i, 4 * Fintype.card ι ≤ 5 * (largeNeighbors w γ i).card)
    (i k : ι) :
    Fintype.card ι ≤ 2 * ((largeNeighbors w γ i) ∩ (largeNeighbors w γ k)).card := by
  have hu : ((largeNeighbors w γ i) ∪ (largeNeighbors w γ k)).card ≤ Fintype.card ι :=
    Finset.card_le_univ _
  have hc := Finset.card_union_add_card_inter (largeNeighbors w γ i) (largeNeighbors w γ k)
  have hi := hdense i
  have hk := hdense k
  omega

/-- Large-neighbor counts imply the quantitative pairwise row overlap. -/
theorem dense_neighbors_overlap [Nonempty ι]
    (w : ι → ι → ℝ) (γ : ℝ)
    (hγ : 0 < γ) (hw : ∀ i j, 0 ≤ w i j)
    (hdense : ∀ i, 4 * Fintype.card ι ≤ 5 * (largeNeighbors w γ i).card)
    (i k : ι) :
    γ / 2 ≤ ∑ j, min (w i j) (w k j) := by
  let I : Finset ι := largeNeighbors w γ i ∩ largeNeighbors w γ k
  have hc : Fintype.card ι ≤ 2 * I.card := dense_neighbor_intersection_half w γ hdense i k
  have hcR : (Fintype.card ι : ℝ) ≤ 2 * (I.card : ℝ) := by exact_mod_cast hc
  have hn : 0 < (Fintype.card ι : ℝ) := Nat.cast_pos.mpr Fintype.card_pos
  have hfrac : (1 : ℝ) / 2 ≤ (I.card : ℝ) / (Fintype.card ι : ℝ) := by
    apply (div_le_div_iff₀ (by norm_num : (0 : ℝ) < 2) hn).mpr
    nlinarith
  have hscaled : γ / 2 ≤ (I.card : ℝ) * (γ / (Fintype.card ι : ℝ)) := by
    have h := mul_le_mul_of_nonneg_left hfrac (le_of_lt hγ)
    calc
      γ / 2 = γ * ((1 : ℝ) / 2) := by ring
      _ ≤ γ * ((I.card : ℝ) / (Fintype.card ι : ℝ)) := h
      _ = (I.card : ℝ) * (γ / (Fintype.card ι : ℝ)) := by ring
  calc
    γ / 2 ≤ (I.card : ℝ) * (γ / (Fintype.card ι : ℝ)) := hscaled
    _ = ∑ j ∈ I, γ / (Fintype.card ι : ℝ) := by simp [nsmul_eq_mul]
    _ ≤ ∑ j ∈ I, min (w i j) (w k j) := by
      apply Finset.sum_le_sum
      intro j hj
      have hij : j ∈ largeNeighbors w γ i := (Finset.mem_inter.mp hj).1
      have hkj : j ∈ largeNeighbors w γ k := (Finset.mem_inter.mp hj).2
      exact le_min (Finset.mem_filter.mp hij).2 (Finset.mem_filter.mp hkj).2
    _ ≤ ∑ j, min (w i j) (w k j) := by
      apply Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ I)
      intro j _ _
      exact le_min (hw i j) (hw k j)

/-- Dense-core Poisson estimate when every vertex is good. The hypotheses
are explicit: symmetric nonnegative weights, row mass at most one, and at
least four fifths of the vertices joined at weight at least `γ / n`. -/
theorem boundedPoisson_of_dense_neighbors [Nonempty ι]
    (w : ι → ι → ℝ) (γ : ℝ)
    (hγ : 0 < γ) (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i)
    (hmass : ∀ i, (∑ j, w i j) ≤ 1)
    (hdense : ∀ i, 4 * Fintype.card ι ≤ 5 * (largeNeighbors w γ i).card) :
    BoundedPoissonSolvability w (4 / γ) := by
  have hsolve := boundedPoisson_of_overlap w (γ / 2) (div_pos hγ (by norm_num)) hsymm hmass
    (dense_neighbors_overlap w γ hγ hw hdense)
  have hc : (2 : ℝ) / (γ / 2) = 4 / γ := by
    rw [div_div_eq_mul_div]
    norm_num
  rwa [hc] at hsolve

end Paulsen
