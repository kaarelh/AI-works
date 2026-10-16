import NeuralGeneralization.PowerSeriesPositiveKernel
import NeuralGeneralization.ArcsineHankel

/-! The actual iterated-arcsine coefficients have positive Hankel matrices
at every depth. The proof is entirely real and algebraic, using formal
composition and finite sums of squares rather than singularity transfer. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.IteratedArcsineHankel
open IteratedArcsineSeries HankelCoefficientBounds

def formalSeries (k : ℕ) : PowerSeries ℝ := PowerSeries.mk (coefficient k)

@[simp] theorem coeff_formalSeries (k m : ℕ) : (formalSeries k).coeff m = coefficient k m :=
  PowerSeries.coeff_mk _ _

@[simp] theorem constantCoeff_formalSeries (k : ℕ) : (formalSeries k).constantCoeff = 0 := by
  change coefficient k 0 = 0
  exact coefficient_even _ _ rfl

theorem powerCoefficient_eq_coeff_pow (a : ℕ → ℝ) (p m : ℕ) :
    powerCoefficient a p m = PowerSeries.coeff m ((PowerSeries.mk a)^p) := by
  induction p generalizing m with
  | zero => simp [powerCoefficient]
  | succ p ih =>
    rw [powerCoefficient, pow_succ', PowerSeries.coeff_mul]
    apply Finset.sum_congr rfl
    intro ij hij
    rw [PowerSeries.coeff_mk, ih]

/-- The explicitly defined real coefficient recurrence is precisely formal
composition of the normalized arcsine series with the preceding iterate. -/
theorem formalSeries_succ (k : ℕ) :
    formalSeries (k+1) = (formalSeries 1).subst (formalSeries k) := by
  apply PowerSeries.ext
  intro m
  rw [coeff_formalSeries, PowerSeries.coeff_subst'
    (PowerSeries.HasSubst.of_constantCoeff_zero' (constantCoeff_formalSeries k))]
  have hfinite := PowerSeries.coeff_subst_finite'
    (PowerSeries.HasSubst.of_constantCoeff_zero' (constantCoeff_formalSeries k)) (formalSeries 1) m
  simp only [coeff_formalSeries, Algebra.algebraMap_self, RingHom.id_apply, smul_eq_mul] at hfinite ⊢
  rw [← tsum_eq_finsum (L := .unconditional ℕ) hfinite]
  have hp (p : ℕ) : PowerSeries.coeff m (formalSeries k ^ p) = powerCoefficient (coefficient k) p m :=
    (powerCoefficient_eq_coeff_pow _ _ _).symm
  simp_rw [hp]
  have hezero (n : ℕ) : coefficient 1 (2*n) = 0 := coefficient_even 1 (2*n) (by omega)
  have heven : Summable (fun n => coefficient 1 (2*n) *
      powerCoefficient (coefficient k) (2*n) m) := by
    simpa only [hezero, zero_mul] using
      (summable_zero : Summable (fun _ : ℕ => (0 : ℝ)))
  have hodd : Summable (fun n => coefficient 1 (2*n+1) *
      powerCoefficient (coefficient k) (2*n+1) m) := by
    simpa only [coefficient_one_odd] using mixture_summable k m
  have heq := tsum_even_add_odd
    (f := fun p => coefficient 1 p * powerCoefficient (coefficient k) p m) heven hodd
  simp only [hezero, zero_mul, tsum_zero, zero_add,
    coefficient_one_odd] at heq
  exact heq

/-- All finite coefficient Hankel matrices of the actual normalized
arcsine iterates are positive semidefinite. -/
theorem positiveHankel (k : ℕ) : PositiveHankel (coefficient (k+1)) := by
  induction k with
  | zero => exact first_arcsine_positiveHankel
  | succ k ih =>
    have h := PowerSeriesPositiveKernel.positiveHankel_subst (formalSeries 1) (formalSeries (k+1))
      (by simpa only [coeff_formalSeries] using first_arcsine_positiveHankel)
      (by simpa only [coeff_formalSeries] using ih)
      (constantCoeff_formalSeries (k+1))
    rw [← formalSeries_succ] at h
    simpa only [coeff_formalSeries] using h

/-- The crucial coefficient regularity statement for a real density
argument: actual odd coefficients decrease at every positive depth. -/
theorem odd_antitone (k : ℕ) : Antitone (fun n => coefficient (k+1) (2*n+1)) :=
  (positiveHankel k).odd_antitone (coefficient_nonneg _) (hasSum_coefficient _).summable

/-- The same exact coefficients are also log-convex on odd powers. -/
theorem odd_logconvex (k n : ℕ) :
    coefficient (k+1) (2*(n+1)+1)^2 ≤
      coefficient (k+1) (2*n+1) * coefficient (k+1) (2*(n+2)+1) :=
  (positiveHankel k).odd_logconvex n

end NeuralGeneralization.IteratedArcsineHankel
