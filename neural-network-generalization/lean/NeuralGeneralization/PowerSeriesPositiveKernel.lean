import NeuralGeneralization.PowerSeriesDividedDifference
import NeuralGeneralization.HankelCoefficientBounds
import Mathlib.Analysis.Matrix.Order

/-! Positivity of finite coefficient matrices of bivariate formal series.
Finite sum-of-squares approximations prove closure under multiplication
and separate zero-constant substitution. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.PowerSeriesPositiveKernel
open PowerSeriesDividedDifference

/-- Positivity at every finite coefficient truncation. -/
def PositiveKernel (K : Biv) : Prop :=
  ∀ N : ℕ, Matrix.PosSemidef (fun i j : Fin N => MvPowerSeries.coeff (index i.val j.val) K)

def AgreeBelow (N : ℕ) (K L : Biv) : Prop :=
  ∀ e : Fin 2 →₀ ℕ, e 0 < N → e 1 < N → MvPowerSeries.coeff e K = MvPowerSeries.coeff e L

theorem coeff_separated_mul (f g : PowerSeries ℝ) (e : Fin 2 →₀ ℕ) :
    MvPowerSeries.coeff e (f.subst (MvPowerSeries.X 0 : Biv) *
      g.subst (MvPowerSeries.X 1 : Biv)) = f.coeff (e 0) * g.coeff (e 1) := by
  rw [MvPowerSeries.coeff_mul, Finset.sum_eq_single
    (Finsupp.single 0 (e 0), Finsupp.single 1 (e 1))]
  · simp [PowerSeries.coeff_subst_single]
  · intro b hb hb'
    by_contra hmul
    obtain ⟨h0,h1⟩ := ne_zero_and_ne_zero_of_mul hmul
    simp only [PowerSeries.coeff_subst_single, ne_eq, ite_eq_right_iff,
      not_forall, exists_prop] at h0 h1
    apply hb'
    rw [Prod.ext_iff, ← Finset.mem_antidiagonal.mp hb, h0.1, h1.1]
    simp
  · intro he
    exact (he (Finset.mem_antidiagonal.mpr (index_eta e))).elim

def sumSquares {I : Type*} [Fintype I] (f : I → PowerSeries ℝ) : Biv :=
  ∑ i, (f i).subst (MvPowerSeries.X 0 : Biv) * (f i).subst (MvPowerSeries.X 1 : Biv)

theorem coeff_sumSquares {I : Type*} [Fintype I] (f : I → PowerSeries ℝ)
    (e : Fin 2 →₀ ℕ) :
    MvPowerSeries.coeff e (sumSquares f) = ∑ i, (f i).coeff (e 0) * (f i).coeff (e 1) := by
  simp only [sumSquares, map_sum, coeff_separated_mul]

theorem positive_sumSquares {I : Type*} [Fintype I] (f : I → PowerSeries ℝ) :
    PositiveKernel (sumSquares f) := by
  intro N
  let A : Matrix (Fin N) I ℝ := fun i j => (f j).coeff i.val
  have h := Matrix.posSemidef_self_mul_conjTranspose A
  convert h using 1
  ext i j
  simp [Matrix.mul_apply, Matrix.conjTranspose_apply, A, coeff_sumSquares]

theorem PositiveKernel.of_agreeBelow {K : Biv}
    (h : ∀ N, ∃ L : Biv, PositiveKernel L ∧ AgreeBelow N K L) : PositiveKernel K := by
  intro N
  obtain ⟨L,hL,he⟩ := h N
  convert hL N using 1
  ext i j
  exact he (index i.val j.val) (by simpa using i.isLt) (by simpa using j.isLt)

/-- Finite positive blocks have finite sums-of-squares series
approximations with exactly the same coefficient block. -/
theorem PositiveKernel.exists_sumSquares {K : Biv} (hK : PositiveKernel K) (N : ℕ) :
    ∃ f : Fin N → PowerSeries ℝ, AgreeBelow N K (sumSquares f) := by
  classical
  obtain ⟨A,hA⟩ := CovarianceFactor.exists_gram_factor _ (hK N)
  let f : Fin N → PowerSeries ℝ := fun j => PowerSeries.mk
    (fun n => if h : n < N then A ⟨n,h⟩ j else 0)
  refine ⟨f, ?_⟩
  intro e h0 h1
  rw [coeff_sumSquares]
  simp only [f, PowerSeries.coeff_mk, dif_pos h0, dif_pos h1]
  have h := hA (⟨e 0,h0⟩ : Fin N) (⟨e 1,h1⟩ : Fin N)
  simpa only [GaussianAngularPrice.gram, index_eta] using h.symm

theorem AgreeBelow.mul {N : ℕ} {K K' L L' : Biv}
    (hK : AgreeBelow N K K') (hL : AgreeBelow N L L') :
    AgreeBelow N (K*L) (K'*L') := by
  intro e h0 h1
  simp only [MvPowerSeries.coeff_mul]
  apply Finset.sum_congr rfl
  intro pq hpq
  have he := Finset.mem_antidiagonal.mp hpq
  have he0 := congrArg (fun e : Fin 2 →₀ ℕ => e 0) he
  have he1 := congrArg (fun e : Fin 2 →₀ ℕ => e 1) he
  simp only [Finsupp.add_apply] at he0 he1
  rw [hK pq.1 (by omega) (by omega), hL pq.2 (by omega) (by omega)]

theorem sumSquares_mul {I J : Type*} [Fintype I] [Fintype J]
    (f : I → PowerSeries ℝ) (g : J → PowerSeries ℝ) :
    sumSquares f * sumSquares g = sumSquares (fun ij : I × J => f ij.1 * g ij.2) := by
  simp only [sumSquares, Fintype.sum_prod_type, Finset.sum_mul_sum,
    PowerSeries.subst_mul (PowerSeries.HasSubst.X (0 : Fin 2)),
    PowerSeries.subst_mul (PowerSeries.HasSubst.X (1 : Fin 2))]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- Coefficient positivity is preserved by formal multiplication. -/
theorem PositiveKernel.mul {K L : Biv} (hK : PositiveKernel K) (hL : PositiveKernel L) :
    PositiveKernel (K*L) := by
  apply PositiveKernel.of_agreeBelow
  intro N
  obtain ⟨f,hf⟩ := hK.exists_sumSquares N
  obtain ⟨g,hg⟩ := hL.exists_sumSquares N
  refine ⟨sumSquares (fun ij : Fin N × Fin N => f ij.1 * g ij.2), positive_sumSquares _, ?_⟩
  rw [← sumSquares_mul]
  exact hf.mul hg


private theorem coeff_separate_monomial (g : PowerSeries ℝ) (e d : Fin 2 →₀ ℕ) :
    MvPowerSeries.coeff e (d.prod (fun s n => separate g s ^ n)) =
      (g ^ d 0).coeff (e 0) * (g ^ d 1).coeff (e 1) := by
  rw [Finsupp.prod_fintype _ _ (fun s => pow_zero _)]
  rw [Fin.prod_univ_two]
  change MvPowerSeries.coeff e
    ((g.subst (MvPowerSeries.X 0 : Biv)) ^ d 0 *
     (g.subst (MvPowerSeries.X 1 : Biv)) ^ d 1) = _
  rw [← PowerSeries.subst_pow (PowerSeries.HasSubst.X (0 : Fin 2)),
    ← PowerSeries.subst_pow (PowerSeries.HasSubst.X (1 : Fin 2)), coeff_separated_mul]

private theorem coeff_pow_vanish (g : PowerSeries ℝ) (hg : g.constantCoeff = 0)
    {m n : ℕ} (hmn : m < n) : (g^n).coeff m = 0 := by
  apply PowerSeries.coeff_of_lt_order
  exact lt_of_lt_of_le (by exact_mod_cast hmn)
    (PowerSeries.le_order_pow_of_constantCoeff_eq_zero n hg)

/-- A zero constant term prevents coefficients above the truncation from
contributing to a coefficient below it after separate substitution. -/
theorem AgreeBelow.subst {N : ℕ} {K L : Biv} (h : AgreeBelow N K L)
    (g : PowerSeries ℝ) (hg : g.constantCoeff = 0) :
    AgreeBelow N (MvPowerSeries.subst (separate g) K)
      (MvPowerSeries.subst (separate g) L) := by
  intro e he0 he1
  rw [MvPowerSeries.coeff_subst (hasSubst_separate g hg),
    MvPowerSeries.coeff_subst (hasSubst_separate g hg)]
  apply finsum_congr
  intro d
  by_cases hd0 : d 0 < N
  · by_cases hd1 : d 1 < N
    · rw [h d hd0 hd1]
    · rw [coeff_separate_monomial, coeff_pow_vanish g hg (by omega : e 1 < d 1)]
      simp
  · rw [coeff_separate_monomial, coeff_pow_vanish g hg (by omega : e 0 < d 0)]
    simp

theorem subst_sumSquares {I : Type*} [Fintype I] (f : I → PowerSeries ℝ)
    (g : PowerSeries ℝ) (hg : g.constantCoeff = 0) :
    MvPowerSeries.subst (separate g) (sumSquares f) =
      sumSquares (fun i => (f i).subst g) := by
  rw [sumSquares, ← MvPowerSeries.substAlgHom_apply (hasSubst_separate g hg), map_sum]
  unfold sumSquares
  apply Finset.sum_congr rfl
  intro i hi
  rw [map_mul]
  simp only [MvPowerSeries.substAlgHom_apply, separate_subst_univariate _ g hg]
  have h0 := PowerSeries.subst_comp_subst_apply
    (PowerSeries.HasSubst.of_constantCoeff_zero' hg)
    (show PowerSeries.HasSubst (MvPowerSeries.X (0 : Fin 2) : Biv) from PowerSeries.HasSubst.X 0) (f i)
  have h1 := PowerSeries.subst_comp_subst_apply
    (PowerSeries.HasSubst.of_constantCoeff_zero' hg)
    (show PowerSeries.HasSubst (MvPowerSeries.X (1 : Fin 2) : Biv) from PowerSeries.HasSubst.X 1) (f i)
  rw [h0,h1]
  rfl

/-- Positive finite coefficient matrices are preserved by separate formal
substitution of a univariate series with zero constant coefficient. -/
theorem PositiveKernel.subst {K : Biv} (hK : PositiveKernel K)
    (g : PowerSeries ℝ) (hg : g.constantCoeff = 0) :
    PositiveKernel (MvPowerSeries.subst (separate g) K) := by
  apply PositiveKernel.of_agreeBelow
  intro N
  obtain ⟨f,hf⟩ := hK.exists_sumSquares N
  refine ⟨sumSquares (fun i => (f i).subst g), positive_sumSquares _, ?_⟩
  rw [← subst_sumSquares f g hg]
  exact hf.subst g hg

/-- Purely algebraic preservation of positive coefficient Hankel matrices
under zero-constant composition. This replaces analytic Pick theory. -/
theorem positiveHankel_subst (f g : PowerSeries ℝ)
    (hf : HankelCoefficientBounds.PositiveHankel (fun n => f.coeff n))
    (hg : HankelCoefficientBounds.PositiveHankel (fun n => g.coeff n))
    (hg0 : g.constantCoeff = 0) :
    HankelCoefficientBounds.PositiveHankel (fun n => PowerSeries.coeff n (f.subst g)) := by
  have hf' : PositiveKernel (dividedDifference f) := by
    intro N
    simpa only [coeff_dividedDifference] using hf N
  have hg' : PositiveKernel (dividedDifference g) := by
    intro N
    simpa only [coeff_dividedDifference] using hg N
  have h := (hf'.subst g hg0).mul hg'
  rw [← dividedDifference_subst f g hg0] at h
  intro N
  simpa only [coeff_dividedDifference] using h N

end NeuralGeneralization.PowerSeriesPositiveKernel
