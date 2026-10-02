import Paulsen.Paper.Toolbox

/-!
# Paper blueprint, Section 3: bounded rank, Hamilton–Moitra (`sections/bounded.tex`)
-/

namespace Paulsen.Paper

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- `lem:HM`.

TeX: "Let $1\le d\le n$, let $X\in\R^{n\times d}$ have $\norm{x_i}^2=a$ for all $i$,
and let $\eta=\opn{X^TX-I}$. There is an ENP frame $W$ with
$\fro{X-W}^2\le\eta d(d-1)$."

Encoding: `IsNearlyParseval η X` means `η ≥ ‖XᵀX - I‖_op` (equivalent). -/
theorem lem_HM {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) (X : Frame n d) (hX : IsEqualNorm X)
    {η : ℝ} (hη : IsNearlyParseval η X) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance X W ≤ η * (d : ℝ) * ((d : ℝ) - 1) := by
  exact equalRow_quadratic_correction (by omega) hdn X η hX hη

/-- `cor:exist` (first sentence).

TeX: "For all $1\le d\le n$ an ENP frame exists." -/
theorem cor_exist {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) :
    ∃ W : Frame n d, IsEqualNormParseval W := by
  -- `lem:HM` applied to `x_i = √a e_1`
  have hn : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  let e₁ : Fin d := ⟨0, by omega⟩
  let X : Frame n d := fun _ j => if j = e₁ then Real.sqrt ((d : ℝ) / n) else 0
  have ha : 0 ≤ (d : ℝ) / n := by positivity
  have hX : IsEqualNorm X := by
    intro i
    simp only [rowNormSq, X, ite_pow, Real.sq_sqrt ha]
    simp
  have hη : IsNearlyParseval (d : ℝ) X := by
    intro x
    have hE : frameEnergy X x = (d : ℝ) * x e₁ ^ 2 := by
      simp only [frameEnergy, X, ite_mul, zero_mul, Finset.sum_ite_eq', Finset.mem_univ,
        if_true, mul_pow, Real.sq_sqrt ha, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
        nsmul_eq_mul]
      field_simp
    have hx1 : x e₁ ^ 2 ≤ vectorNormSq x :=
      Finset.single_le_sum (f := fun j => x j ^ 2) (fun j _ => sq_nonneg _) (Finset.mem_univ e₁)
    have hx0 := vectorNormSq_nonneg x
    rw [hE]
    constructor <;> nlinarith [sq_nonneg (x e₁)]
  obtain ⟨W, hW, -⟩ := lem_HM hd hdn X hX hη
  exact ⟨W, hW⟩

/-- `cor:exist` (second sentence).

TeX: "Consequently every equal-norm $X\in\R^{n\times d}$ is within
$\fro{X-W}^2\le2\fro X^2+2\fro W^2=4d$ of an ENP frame $W$." -/
theorem cor_exist_trivial {n d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n) (X : Frame n d)
    (hX : IsEqualNorm X) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance X W ≤ 2 * frobSq X + 2 * frobSq W ∧
      2 * frobSq X + 2 * frobSq W = 4 * (d : ℝ) := by
  obtain ⟨W, hW⟩ := cor_exist (n := n) hd hdn
  have hn : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hXf : frobSq X = (d : ℝ) := by
    show ∑ i, rowNormSq X i = (d : ℝ)
    simp only [hX _, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have hWf : frobSq W = (d : ℝ) := hW.1.total_rowNormSq
  refine ⟨W, hW, sqDistance_le_twice_energy X W, ?_⟩
  rw [hXf, hWf]; ring

end

end Paulsen.Paper
