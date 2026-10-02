import Paulsen.Linear.BlockBarrier

/-!
# Helper for `Paulsen.Paper.Toolbox`: `lem:core` (ii) with the paper's `R = √b/λ`.

This is `Paulsen.Linear.block_barrier` with the sup bound replaced by
`‖y‖_∞ ≤ ‖y‖₂` and `λ‖y‖₂² ≤ ⟨y, 1_B⟩ ≤ √b ‖y‖₂`.
-/

namespace Paulsen.Paper.ToolboxAux

open scoped BigOperators
open Paulsen Paulsen.Linear

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The block barrier with `‖y‖_∞ ≤ √|B| / λ`. -/
theorem block_barrier_sqrt [Nonempty ι] {w : ι → ι → ℝ} (hw : ∀ i j, 0 ≤ w i j)
    (hsymm : ∀ i j, w i j = w j i)
    (B : Finset ι) {l : ℝ} (hl : 0 < l)
    (hgap : ∀ x : ι → ℝ, (∀ j, j ∉ B → x j = 0) →
      l * ∑ i, x i ^ 2 ≤ ∑ i, x i * weightedLaplacian w x i) :
    ∃ y : ι → ℝ, (∀ j, 0 ≤ y j) ∧ (∀ j, j ∉ B → y j = 0) ∧
      (∀ j, y j ≤ Real.sqrt (B.card : ℝ) / l) ∧
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
  -- the total mass identity `yᵀ L y = ⟨y, 1_B⟩`
  have hmass : (∑ i, y i * weightedLaplacian w y i) = ∑ i ∈ B, y i := by
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => i ∈ B)]
    have h2 : ∑ i ∈ Finset.univ.filter (fun i => i ∉ B), y i * weightedLaplacian w y i = 0 := by
      apply Finset.sum_eq_zero; intro i hi
      rw [hyoff i (Finset.mem_filter.mp hi).2, zero_mul]
    rw [h2, add_zero, Finset.filter_mem_eq_inter, Finset.univ_inter]
    apply Finset.sum_congr rfl; intro i hi; rw [hyon i hi, mul_one]
  -- sup bound: `‖y‖_∞ ≤ ‖y‖₂ ≤ √b / λ`
  set N := Real.sqrt (∑ i, y i ^ 2) with hN
  have hN0 : 0 ≤ N := Real.sqrt_nonneg _
  have hNsq : N ^ 2 = ∑ i, y i ^ 2 := Real.sq_sqrt (Finset.sum_nonneg fun i _ => sq_nonneg _)
  have hCS : (∑ i ∈ B, y i) ≤ Real.sqrt (B.card : ℝ) * N := by
    have h := Real.sum_mul_le_sqrt_mul_sqrt B (fun _ => (1 : ℝ)) y
    simp only [one_mul, one_pow, Finset.sum_const, nsmul_eq_mul, mul_one] at h
    refine h.trans (mul_le_mul_of_nonneg_left ?_ (Real.sqrt_nonneg _))
    apply Real.sqrt_le_sqrt
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ B)
      (fun i _ _ => sq_nonneg _)
  have hgy := hgap y hyoff
  rw [hmass, ← hNsq] at hgy
  have hNbound : N ≤ Real.sqrt (B.card : ℝ) / l := by
    rw [le_div_iff₀ hl]
    by_cases hz : N = 0
    · rw [hz, zero_mul]; exact Real.sqrt_nonneg _
    · have hpos : 0 < N := lt_of_le_of_ne hN0 (Ne.symm hz)
      have : l * N ^ 2 ≤ Real.sqrt (B.card : ℝ) * N := hgy.trans hCS
      nlinarith
  have hyN : ∀ j, y j ≤ N := by
    intro j
    rw [hN]
    calc y j ≤ |y j| := le_abs_self _
      _ = Real.sqrt (y j ^ 2) := (Real.sqrt_sq_eq_abs _).symm
      _ ≤ Real.sqrt (∑ i, y i ^ 2) := Real.sqrt_le_sqrt
          (Finset.single_le_sum (fun i _ => sq_nonneg (y i)) (Finset.mem_univ j))
  refine ⟨y, hy0, hyoff, fun j => (hyN j).trans hNbound,
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

end Paulsen.Paper.ToolboxAux
