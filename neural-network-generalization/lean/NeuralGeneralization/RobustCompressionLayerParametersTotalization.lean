import NeuralGeneralization.RobustCompressionLayerParameters
import NeuralGeneralization.RobustCompressionSourceBankTotalization

/-! # A globally contractive comparison package with literal good-bank parameters

Only the coefficient covariance matrix is totalized. The actual feature and
mean maps remain unchanged; bad source samples must be sent to the common
absorbing abort state by the final construction. We do not claim equality of
unaborted bad-sample coefficient laws.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionLayerParameters.BankLayerData
open RobustCompressionLayerGaussian RobustCompressionSourceBank
open RobustCompressionReconstruction
variable {A X : Type*} [MeasurableSpace A] [Fintype X] {N m q : ℕ}

/-- Change only sourceMatrix to its measurable zero fallback on bad banks. -/
def totalizedParameters (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) :
    GaussianLayerParameters A N m q :=
  { b.parameters a t T BH x with
    sourceMatrix := totalSourceMatrix b.source b.feature b.indices a T
    sourceMatrix_measurable := measurable_totalSourceMatrix b.source b.feature b.indices
      b.source_measurable b.feature_measurable b.indices_measurable a T }

/-- Global contraction follows from the actual source-population quadratic
bound, with no false requirement that every empirical bank be good. -/
theorem totalizedParameters_contractive [NeZero m]
    (b : BankLayerData A X N m q) {a t T BH : ℝ} (ha : 0 ≤ a) (x : X)
    (hu : ∀ θ v, (∑ i, ⟪b.source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2) :
    (b.totalizedParameters a t T BH x).Contractive :=
  totalSourceMatrix_contractive b.source b.feature b.indices ha (NeZero.pos m) hu

/-- The totalized package retains the literal matrix on each good bank. -/
theorem totalizedParameters_sourceMatrix_of_good
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) (θ : A)
    (hg : sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    (b.totalizedParameters a t T BH x).sourceMatrix θ =
      (b.parameters a t T BH x).sourceMatrix θ :=
  totalSourceMatrix_of_good b.source b.feature b.indices a T θ hg

/-- Equality of the complete parameter packages on any domain on which all
banks are good (for example the good-event subtype). -/
theorem totalizedParameters_eq_of_all_good
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X)
    (hg : ∀ θ, sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    b.totalizedParameters a t T BH x = b.parameters a t T BH x := by
  have hm : totalSourceMatrix b.source b.feature b.indices a T =
      fun θ => sampledMatrix (b.source θ) (b.indices θ) a T := by
    funext θ
    exact totalSourceMatrix_of_good b.source b.feature b.indices a T θ (hg θ)
  unfold totalizedParameters
  simp only [hm]
  rfl

/-- Means, feature vectors and scale are identical even outside the good event. -/
theorem totalizedParameters_idealObservable
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) :
    (b.totalizedParameters a t T BH x).idealObservable =
      (b.parameters a t T BH x).idealObservable := rfl

theorem totalizedParameters_finiteObservable
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) :
    (b.totalizedParameters a t T BH x).finiteObservable =
      (b.parameters a t T BH x).finiteObservable := rfl

theorem totalizedParameters_clippedFiniteObservable
    (b : BankLayerData A X N m q) (a t T BH BG : ℝ) (x : X) :
    (b.totalizedParameters a t T BH x).clippedFiniteObservable BG =
      (b.parameters a t T BH x).clippedFiniteObservable BG := rfl

/-- The finite comparison variance agrees on good samples. -/
theorem totalizedParameters_finiteVariance_of_good
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) (θ : A)
    (hg : sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    (b.totalizedParameters a t T BH x).finiteVariance θ =
      (b.parameters a t T BH x).finiteVariance θ := by
  funext i
  unfold GaussianLayerParameters.finiteVariance
  rw [totalizedParameters_sourceMatrix_of_good b a t T BH x θ hg]
  rfl

/-- Exact agreement of the complete residual coefficient-row law on good
samples, which the final common absorbing-state map retains. -/
theorem totalizedParameters_coefficientKernel_of_good
    (b : BankLayerData A X N m q) (a t T BH : ℝ) (x : X) (θ : A)
    (hg : sourceBankGood (b.source θ) (b.feature θ) a T (b.indices θ)) :
    (b.totalizedParameters a t T BH x).coefficientKernel θ =
      (b.parameters a t T BH x).coefficientKernel θ := by
  unfold GaussianLayerParameters.coefficientKernel
  rw [residualRowsKernel_apply, residualRowsKernel_apply,
    totalizedParameters_sourceMatrix_of_good b a t T BH x θ hg]

end NeuralGeneralization.RobustCompressionLayerParameters.BankLayerData
