import Mathlib.Data.Real.Basic
import Mathlib.RingTheory.PowerSeries.Substitution
import Mathlib.RingTheory.MvPowerSeries.NoZeroDivisors

/-! Formal two-variable divided differences. Their coefficient matrix is
the Hankel matrix used by the real coefficient-regularity argument. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.PowerSeriesDividedDifference
abbrev Biv := MvPowerSeries (Fin 2) ℝ

def index (i j : ℕ) : Fin 2 →₀ ℕ := Finsupp.single 0 i + Finsupp.single 1 j

def dividedDifference (f : PowerSeries ℝ) : Biv :=
  fun e => f.coeff (e 0 + e 1 + 1)

@[simp] theorem index_zero (i j : ℕ) : index i j 0 = i := by simp [index]
@[simp] theorem index_one (i j : ℕ) : index i j 1 = j := by simp [index]

theorem index_eta (e : Fin 2 →₀ ℕ) : index (e 0) (e 1) = e := by
  ext s
  fin_cases s <;> simp [index]

@[simp] theorem coeff_dividedDifference (f : PowerSeries ℝ) (i j : ℕ) :
    MvPowerSeries.coeff (index i j) (dividedDifference f) = f.coeff (i+j+1) := by
  simp only [MvPowerSeries.coeff_apply, dividedDifference, index_zero, index_one]

theorem coeff_X_zero_mul (K : Biv) (i j : ℕ) :
    MvPowerSeries.coeff (index i j) (MvPowerSeries.X 0 * K) =
      if i = 0 then 0 else MvPowerSeries.coeff (index (i-1) j) K := by
  rw [MvPowerSeries.X, MvPowerSeries.coeff_monomial_mul]
  simp only [Finsupp.single_le_iff, index_zero, one_mul]
  by_cases hi : i = 0
  · simp [hi]
  · rw [if_pos (by omega), if_neg hi]
    have he : index i j - Finsupp.single 0 1 = index (i-1) j := by
      ext s
      fin_cases s <;> simp [index]
    rw [he]

theorem coeff_X_one_mul (K : Biv) (i j : ℕ) :
    MvPowerSeries.coeff (index i j) (MvPowerSeries.X 1 * K) =
      if j = 0 then 0 else MvPowerSeries.coeff (index i (j-1)) K := by
  rw [MvPowerSeries.X, MvPowerSeries.coeff_monomial_mul]
  simp only [Finsupp.single_le_iff, index_one, one_mul]
  by_cases hj : j = 0
  · simp [hj]
  · rw [if_pos (by omega), if_neg hj]
    have he : index i j - Finsupp.single 1 1 = index i (j-1) := by
      ext s
      fin_cases s <;> simp [index]
    rw [he]

theorem coeff_subst_X_zero (f : PowerSeries ℝ) (i j : ℕ) :
    MvPowerSeries.coeff (index i j) (f.subst (MvPowerSeries.X 0 : Biv)) =
      if j = 0 then f.coeff i else 0 := by
  rw [PowerSeries.coeff_subst_single]
  simp only [index_zero]
  have he : index i j = Finsupp.single 0 i ↔ j = 0 := by
    constructor
    · intro h
      have := congrArg (fun e : Fin 2 →₀ ℕ => e 1) h
      simpa using this
    · rintro rfl
      simp [index]
  simp only [he]

theorem coeff_subst_X_one (f : PowerSeries ℝ) (i j : ℕ) :
    MvPowerSeries.coeff (index i j) (f.subst (MvPowerSeries.X 1 : Biv)) =
      if i = 0 then f.coeff j else 0 := by
  rw [PowerSeries.coeff_subst_single]
  simp only [index_one]
  have he : index i j = Finsupp.single 1 j ↔ i = 0 := by
    constructor
    · intro h
      have := congrArg (fun e : Fin 2 →₀ ℕ => e 0) h
      simpa using this
    · rintro rfl
      simp [index]
  simp only [he]

/-- Exact formal divided-difference identity, valid for arbitrary real
power series, with no convergence assumptions. -/
theorem sub_X_mul_dividedDifference (f : PowerSeries ℝ) :
    (MvPowerSeries.X 0 - MvPowerSeries.X 1) * dividedDifference f =
      f.subst (MvPowerSeries.X 0 : Biv) - f.subst (MvPowerSeries.X 1 : Biv) := by
  apply MvPowerSeries.ext
  intro e
  rw [← index_eta e, sub_mul, map_sub, map_sub, coeff_X_zero_mul, coeff_X_one_mul,
    coeff_subst_X_zero, coeff_subst_X_one]
  cases hi : e 0 <;> cases hj : e 1 <;> simp [coeff_dividedDifference, Nat.add_comm, Nat.add_left_comm, Nat.add_assoc]


/-- Separate substitution of the same univariate series in both variables. -/
def separate (g : PowerSeries ℝ) (s : Fin 2) : Biv := g.subst (MvPowerSeries.X s)

theorem hasSubst_separate (g : PowerSeries ℝ) (hg : g.constantCoeff = 0) :
    MvPowerSeries.HasSubst (separate g) := by
  apply MvPowerSeries.hasSubst_of_constantCoeff_zero
  intro s
  exact PowerSeries.constantCoeff_subst_eq_zero (by simp) g hg

theorem separate_subst_univariate (f g : PowerSeries ℝ) (hg : g.constantCoeff = 0)
    (s : Fin 2) :
    MvPowerSeries.subst (separate g) (f.subst (MvPowerSeries.X s : Biv)) =
      f.subst (separate g s) := by
  change MvPowerSeries.subst (separate g)
    (MvPowerSeries.subst (fun _ : Unit => (MvPowerSeries.X s : Biv)) f) = _
  rw [MvPowerSeries.subst_comp_subst_apply (PowerSeries.HasSubst.X s).const
    (hasSubst_separate g hg)]
  simp only [MvPowerSeries.subst_X (hasSubst_separate g hg)]
  rfl

/-- The formal divided-difference chain rule. -/
theorem dividedDifference_subst (f g : PowerSeries ℝ) (hg : g.constantCoeff = 0) :
    dividedDifference (f.subst g) =
      MvPowerSeries.subst (separate g) (dividedDifference f) * dividedDifference g := by
  have hX : (MvPowerSeries.X 0 - MvPowerSeries.X 1 : Biv) ≠ 0 := by
    intro heq
    have hcoeff := congrArg (MvPowerSeries.coeff (index 1 0)) heq
    have hne : (Finsupp.single 0 1 : Fin 2 →₀ ℕ) ≠ Finsupp.single 1 1 := by
      intro he
      have hh := congrArg (fun e : Fin 2 →₀ ℕ => e 0) he
      norm_num at hh
    norm_num [map_sub, MvPowerSeries.coeff_X, index, hne] at hcoeff
  apply mul_left_cancel₀ hX
  rw [sub_X_mul_dividedDifference]
  have hmap := congrArg (MvPowerSeries.substAlgHom (hasSubst_separate g hg))
    (sub_X_mul_dividedDifference f)
  simp only [map_mul,map_sub,MvPowerSeries.substAlgHom_apply,
    MvPowerSeries.subst_X (hasSubst_separate g hg),
    separate_subst_univariate f g hg] at hmap
  have h0 := PowerSeries.subst_comp_subst_apply
    (PowerSeries.HasSubst.of_constantCoeff_zero' hg) (show PowerSeries.HasSubst (MvPowerSeries.X (0 : Fin 2) : Biv) from PowerSeries.HasSubst.X 0) f
  have h1 := PowerSeries.subst_comp_subst_apply
    (PowerSeries.HasSubst.of_constantCoeff_zero' hg) (show PowerSeries.HasSubst (MvPowerSeries.X (1 : Fin 2) : Biv) from PowerSeries.HasSubst.X 1) f
  rw [h0,h1]
  change f.subst (separate g 0) - f.subst (separate g 1) = _
  rw [← hmap]
  change (g.subst (MvPowerSeries.X 0 : Biv) - g.subst (MvPowerSeries.X 1 : Biv)) * _ = _
  rw [← sub_X_mul_dividedDifference]
  ring

end NeuralGeneralization.PowerSeriesDividedDifference
