import NeuralGeneralization.RobustCompressionSourceBankGoodEvent

/-! # A globally valid Gaussian parameter map with an explicit bad-event fallback

The source bank itself remains the actual one on its good event. Off that
measurable event, all coefficients used for the comparison may be zeroed.
This makes global kernel validity honest without pretending that the bad
source sample has a contractive empirical matrix.
-/
noncomputable section
set_option maxHeartbeats 300000
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustCompressionSourceBank
open RobustCompressionReconstruction
variable {A : Type*} [MeasurableSpace A] {X : Type*} [Fintype X]
variable {N m q : ℕ}

/-- The good source-bank event along arbitrary measurable assembly parameters. -/
theorem measurableSet_sourceBankGood_parameter
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (hu : Measurable u) (hh : Measurable h) (hI : Measurable I) (a T : ℝ) :
    MeasurableSet {θ | sourceBankGood (u θ) (h θ) a T (I θ)} := by
  have hf : Measurable (fun θ : A => ((u θ,h θ), I θ)) := (hu.prodMk hh).prodMk hI
  have hs : MeasurableSet {p : ((Fin N → EuclideanSpace ℝ (Fin q)) ×
      (X → Fin N → ℝ)) × (Fin m → Fin N) |
      sourceBankGood p.1.1 p.1.2 a T p.2} := measurableSet_sourceBankGood a T
  simpa only [Set.preimage_setOf_eq] using hs.preimage hf

/-- Zeroing on the very same shared bad event can be used for the matrix,
feature vector, and both means of a comparison parameter package. -/
def zeroOutsideSourceGood {E : Type*} [Zero E]
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (a T : ℝ) (f : A → E) (θ : A) : E := by
  classical
  exact if sourceBankGood (u θ) (h θ) a T (I θ) then f θ else 0

omit [MeasurableSpace A] [Fintype X] in
theorem zeroOutsideSourceGood_of_good {E : Type*} [Zero E]
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (a T : ℝ) (f : A → E) (θ : A)
    (hg : sourceBankGood (u θ) (h θ) a T (I θ)) :
    zeroOutsideSourceGood u h I a T f θ = f θ := by
  simp only [zeroOutsideSourceGood, if_pos hg]

omit [MeasurableSpace A] [Fintype X] in
theorem zeroOutsideSourceGood_of_bad {E : Type*} [Zero E]
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (a T : ℝ) (f : A → E) (θ : A)
    (hg : ¬sourceBankGood (u θ) (h θ) a T (I θ)) :
    zeroOutsideSourceGood u h I a T f θ = 0 := by
  simp only [zeroOutsideSourceGood, if_neg hg]

@[fun_prop] theorem measurable_zeroOutsideSourceGood
    {E : Type*} [Zero E] [MeasurableSpace E]
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (hu : Measurable u) (hh : Measurable h) (hI : Measurable I)
    (a T : ℝ) (f : A → E) (hf : Measurable f) :
    Measurable (zeroOutsideSourceGood u h I a T f) := by
  unfold zeroOutsideSourceGood
  exact hf.ite (measurableSet_sourceBankGood_parameter u h I hu hh hI a T) measurable_const

/-- Actual sampled coefficients on the good event; the zero matrix on bad
samples. This definition is independent of the eventual test input. -/
def totalSourceMatrix
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (a T : ℝ) : A → Fin m → Fin q → ℝ :=
  zeroOutsideSourceGood u h I a T (fun θ => sampledMatrix (u θ) (I θ) a T)

@[fun_prop] theorem measurable_totalSourceMatrix
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (hu : Measurable u) (hh : Measurable h) (hI : Measurable I) (a T : ℝ) :
    Measurable (totalSourceMatrix u h I a T) := by
  have hs : Measurable (fun θ : A => sampledMatrix (u θ) (I θ) a T) := by
    have hcomp := (measurable_sampledMatrix (N := N) (m := m) (q := q) a T).comp
      (show Measurable (fun θ : A => (u θ, I θ)) from hu.prodMk hI)
    simpa only [Function.comp_def] using hcomp
  exact measurable_zeroOutsideSourceGood (E := Fin m → Fin q → ℝ)
    u h I hu hh hI a T (fun θ => sampledMatrix (u θ) (I θ) a T) hs

omit [MeasurableSpace A] [Fintype X] in
theorem totalSourceMatrix_of_good
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    (a T : ℝ) (θ : A) (hg : sourceBankGood (u θ) (h θ) a T (I θ)) :
    totalSourceMatrix u h I a T θ = sampledMatrix (u θ) (I θ) a T :=
  zeroOutsideSourceGood_of_good u h I a T _ θ hg

omit [MeasurableSpace A] [Fintype X] in
/-- Global contraction needed by the Gaussian comparison kernel. The only
source-side hypothesis is the actual population contraction on each assembly
fiber; the empirical bound is obtained from the source-bank good event. -/
theorem totalSourceMatrix_contractive
    (u : A → Fin N → EuclideanSpace ℝ (Fin q))
    (h : A → X → Fin N → ℝ) (I : A → Fin m → Fin N)
    {a T : ℝ} (ha : 0 ≤ a) (hm : 0 < m)
    (hu : ∀ θ v, (∑ i, ⟪u θ i, v⟫^2)/(N : ℝ) ≤ ‖v‖^2) :
    ∀ (θ : A) (v : Fin q → ℝ),
      ∑ i, (Matrix.of (totalSourceMatrix u h I a T θ) *ᵥ v) i^2 ≤ ∑ j, v j^2 := by
  intro θ v
  classical
  by_cases hg : sourceBankGood (u θ) (h θ) a T (I θ)
  · rw [totalSourceMatrix_of_good u h I a T θ hg]
    exact sampledMatrix_contraction (u θ) (I θ) ha hm (hu θ) (good_gram (u θ) (h θ) hg) v
  · have hz : totalSourceMatrix u h I a T θ = 0 :=
      zeroOutsideSourceGood_of_bad u h I a T _ θ hg
    rw [hz]
    simp only [Matrix.of_zero, Matrix.zero_mulVec, Pi.zero_apply, ne_eq, OfNat.ofNat_ne_zero,
      not_false_eq_true, zero_pow, Finset.sum_const_zero]
    exact Finset.sum_nonneg (fun j _ => sq_nonneg _)

end NeuralGeneralization.RobustCompressionSourceBank
