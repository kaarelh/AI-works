import Paulsen.Linear.Core
import Mathlib.LinearAlgebra.FiniteDimensional.Basic

/-!
# An exceptional barrier from a spectral gap on a block

If the Laplacian energy of every function supported on `B` is at least
`λ` times its squared norm, then the Dirichlet problem `L y = 1` on `B`,
`y = 0` off `B`, has a solution with `0 ≤ y ≤ |B| / λ`, and every vertex
outside `B` sees `∑ⱼ wᵢⱼ yⱼ ≤ |B|`.
-/

namespace Paulsen.Linear

open scoped BigOperators
open Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
set_option linter.unusedSectionVars false

/-- The Dirichlet operator: Laplacian on `B`, identity off `B`. -/
noncomputable def dirichletMap (w : ι → ι → ℝ) (B : Finset ι) :
    (ι → ℝ) →ₗ[ℝ] (ι → ℝ) where
  toFun y i := if i ∈ B then weightedLaplacian w y i else y i
  map_add' y z := by
    funext i
    simp only [Pi.add_apply]
    split_ifs
    · unfold weightedLaplacian
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl; intro j _; simp only [Pi.add_apply]; ring
    · rfl
  map_smul' c y := by
    funext i
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    split_ifs
    · unfold weightedLaplacian
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl; intro j _; simp only [Pi.smul_apply, smul_eq_mul]; ring
    · rfl

theorem energy_eq_sum_on_support (w : ι → ι → ℝ) (B : Finset ι) (x : ι → ℝ)
    (hx : ∀ j, j ∉ B → x j = 0) :
    (∑ i, x i * weightedLaplacian w x i) =
      ∑ i, x i * (dirichletMap w B x i) := by
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : i ∈ B
  · simp [dirichletMap, hi]
  · simp [hx i hi]

/-- The block barrier. -/
theorem block_barrier [Nonempty ι] {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i)
    (B : Finset ι) {l : ℝ} (hl : 0 < l)
    (hgap : ∀ x : ι → ℝ, (∀ j, j ∉ B → x j = 0) →
      l * ∑ i, x i ^ 2 ≤ ∑ i, x i * weightedLaplacian w x i) :
    ∃ y : ι → ℝ, (∀ j, 0 ≤ y j) ∧ (∀ j, j ∉ B → y j = 0) ∧
      (∀ j, y j ≤ (B.card : ℝ) / l) ∧
      (∀ i, i ∈ B → 1 ≤ weightedLaplacian w y i) ∧
      (∀ i, i ∉ B → ∑ j, w i j * y j ≤ (B.card : ℝ)) := by
  classical
  -- injectivity, hence surjectivity, of the Dirichlet map
  have hinj : Function.Injective (dirichletMap w B) := by
    rw [← LinearMap.ker_eq_bot, LinearMap.ker_eq_bot']
    intro x hx
    have hoff : ∀ j, j ∉ B → x j = 0 := by
      intro j hj
      have := congrFun hx j
      simpa [dirichletMap, hj] using this
    have he := hgap x hoff
    rw [energy_eq_sum_on_support w B x hoff, hx] at he
    simp only [Pi.zero_apply, mul_zero, Finset.sum_const_zero] at he
    have hsq : ∑ i, x i ^ 2 = 0 := by
      have := Finset.sum_nonneg (fun i (_ : i ∈ Finset.univ) => sq_nonneg (x i))
      nlinarith
    funext j
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (x i))).mp hsq j
      (Finset.mem_univ j)
    simpa using this
  have hsurj : Function.Surjective (dirichletMap w B) :=
    LinearMap.injective_iff_surjective.mp hinj
  obtain ⟨y, hy⟩ := hsurj (fun i => if i ∈ B then 1 else 0)
  have hyoff : ∀ j, j ∉ B → y j = 0 := by
    intro j hj
    have := congrFun hy j
    simpa [dirichletMap, hj] using this
  have hyon : ∀ i, i ∈ B → weightedLaplacian w y i = 1 := by
    intro i hi
    have := congrFun hy i
    simpa [dirichletMap, hi] using this
  -- nonnegativity via the minimum principle
  have hy0 : ∀ j, 0 ≤ y j := by
    obtain ⟨k, _, hk⟩ := Finset.exists_min_image Finset.univ y Finset.univ_nonempty
    · intro j
      by_contra hneg
      push Not at hneg
      have hkneg : y k < 0 := lt_of_le_of_lt (hk j (Finset.mem_univ j)) hneg
      have hkB : k ∈ B := by
        by_contra hkB; rw [hyoff k hkB] at hkneg; exact lt_irrefl _ hkneg
      have hlap : weightedLaplacian w y k ≤ 0 := by
        unfold weightedLaplacian
        apply Finset.sum_nonpos
        intro j _
        exact mul_nonpos_of_nonneg_of_nonpos (hw k j)
          (sub_nonpos.mpr (hk j (Finset.mem_univ j)))
      rw [hyon k hkB] at hlap
      linarith
  -- the total mass identity
  have hmass : (∑ i, y i * weightedLaplacian w y i) = ∑ i ∈ B, y i := by
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => i ∈ B)]
    have h2 : ∑ i ∈ Finset.univ.filter (fun i => i ∉ B), y i * weightedLaplacian w y i = 0 := by
      apply Finset.sum_eq_zero; intro i hi
      rw [hyoff i (Finset.mem_filter.mp hi).2, zero_mul]
    rw [h2, add_zero, Finset.filter_mem_eq_inter, Finset.univ_inter]
    apply Finset.sum_congr rfl; intro i hi; rw [hyon i hi, mul_one]
  -- sup bound
  obtain ⟨k, _, hk⟩ := Finset.exists_max_image Finset.univ y Finset.univ_nonempty
  have hmaxsq : y k ^ 2 ≤ ∑ i, y i ^ 2 :=
    Finset.single_le_sum (fun i _ => sq_nonneg (y i)) (Finset.mem_univ k)
  have hBsum : (∑ i ∈ B, y i) ≤ (B.card : ℝ) * y k := by
    calc (∑ i ∈ B, y i) ≤ ∑ _i ∈ B, y k :=
          Finset.sum_le_sum (fun i _ => hk i (Finset.mem_univ i))
      _ = (B.card : ℝ) * y k := by rw [Finset.sum_const, nsmul_eq_mul]
  have hgy := hgap y hyoff
  rw [hmass] at hgy
  have hyk0 := hy0 k
  have hsup : y k ≤ (B.card : ℝ) / l := by
    rw [le_div_iff₀ hl]
    by_cases hz : y k = 0
    · rw [hz, zero_mul]; exact Nat.cast_nonneg _
    · have hpos : 0 < y k := lt_of_le_of_ne hyk0 (Ne.symm hz)
      have : l * y k ^ 2 ≤ (B.card : ℝ) * y k := by nlinarith
      nlinarith
  refine ⟨y, hy0, hyoff, fun j => (hk j (Finset.mem_univ j)).trans hsup,
    fun i hi => (hyon i hi).ge, ?_⟩
  -- the flux bound
  intro i₀ hi₀
  have hflux : (∑ j ∈ B, weightedLaplacian w y j) =
      ∑ j ∈ B, y j * ∑ i ∈ Finset.univ.filter (fun i => i ∉ B), w j i := by
    have hsplit : ∀ j, weightedLaplacian w y j =
        (∑ i ∈ B, w j i * (y j - y i)) +
          y j * ∑ i ∈ Finset.univ.filter (fun i => i ∉ B), w j i := by
      intro j
      unfold weightedLaplacian
      rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => i ∈ B),
        Finset.filter_mem_eq_inter, Finset.univ_inter, Finset.mul_sum]
      congr 1
      apply Finset.sum_congr rfl; intro i hi
      rw [hyoff i (Finset.mem_filter.mp hi).2]; ring
    simp_rw [hsplit]
    rw [Finset.sum_add_distrib]
    have hanti : (∑ j ∈ B, ∑ i ∈ B, w j i * (y j - y i)) = 0 := by
      have h1 : (∑ j ∈ B, ∑ i ∈ B, w j i * (y j - y i)) =
          ∑ j ∈ B, ∑ i ∈ B, w i j * (y i - y j) := by
        rw [Finset.sum_comm]
      have h2 : (∑ j ∈ B, ∑ i ∈ B, w i j * (y i - y j)) =
          -(∑ j ∈ B, ∑ i ∈ B, w j i * (y j - y i)) := by
        rw [← Finset.sum_neg_distrib]
        apply Finset.sum_congr rfl; intro j _
        rw [← Finset.sum_neg_distrib]
        apply Finset.sum_congr rfl; intro i _
        rw [hsymm i j]; ring
      linarith
    rw [hanti, zero_add]
  have hb : (∑ j ∈ B, weightedLaplacian w y j) = (B.card : ℝ) := by
    rw [Finset.sum_congr rfl hyon]; simp
  have hlhs : (∑ j, w i₀ j * y j) = ∑ j ∈ B, w i₀ j * y j := by
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun j => j ∈ B)]
    have h2 : ∑ j ∈ Finset.univ.filter (fun j => j ∉ B), w i₀ j * y j = 0 := by
      apply Finset.sum_eq_zero; intro j hj
      rw [hyoff j (Finset.mem_filter.mp hj).2, mul_zero]
    rw [h2, add_zero, Finset.filter_mem_eq_inter, Finset.univ_inter]
  rw [hlhs, ← hb, hflux]
  apply Finset.sum_le_sum
  intro j _
  rw [mul_comm (w i₀ j), hsymm i₀ j]
  apply mul_le_mul_of_nonneg_left _ (hy0 j)
  exact Finset.single_le_sum (f := fun i => w j i) (fun i _ => hw j i)
    (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi₀⟩)

end Paulsen.Linear
