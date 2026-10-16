import NeuralGeneralization.GaussianReadout
import NeuralGeneralization.GaussianMarginGeometry
import Mathlib.Analysis.Matrix.Order
import Mathlib.Analysis.SpecialFunctions.ContinuousFunctionalCalculus.Rpow.Isometric

/-! Canonical covariance factors, their actual Gaussian readout laws, and
continuity in the ordinary finite coefficient topology. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators NNReal MatrixOrder
namespace NeuralGeneralization.GaussianCovarianceFactor
variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

def canonicalFeatures (Q : Matrix X X ℝ) (i x : X) : ℝ := (CFC.sqrt Q) x i

def canonicalMatrix (Q : Matrix X X ℝ) (x i : X) : ℝ := (CFC.sqrt Q) x i

theorem sqrt_symmetric (Q : Matrix X X ℝ) (x y : X) :
    (CFC.sqrt Q) x y = (CFC.sqrt Q) y x := by
  have h := ((Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg Q)).isHermitian).apply y x
  simpa only [star_trivial] using h

theorem gram_canonicalFeatures (Q : Matrix X X ℝ) (hQ : Q.PosSemidef) (x y : X) :
    GaussianReadout.gram (canonicalFeatures Q) x y = Q x y := by
  have hs := congrArg (fun M : Matrix X X ℝ => M x y) (CFC.sqrt_mul_sqrt_self Q hQ.nonneg)
  change (∑ i, (CFC.sqrt Q) x i * (CFC.sqrt Q) y i) = _
  rw [← hs, Matrix.mul_apply]
  apply Finset.sum_congr rfl
  intro i _
  rw [sqrt_symmetric Q y i]

def normalizedGram (H : I → X → ℝ) (N : ℝ) : Matrix X X ℝ :=
  fun x y => GaussianReadout.gram H x y / N

theorem normalizedGram_posSemidef (H : I → X → ℝ) {N : ℝ} (hN : 0 ≤ N) :
    (normalizedGram H N).PosSemidef := by
  let M : Matrix X I ℝ := Matrix.of (fun x i => H i x)
  have heq : normalizedGram H N = N⁻¹ • (M * M.conjTranspose) := by
    ext x y
    simp only [normalizedGram, GaussianReadout.gram, Matrix.smul_apply, smul_eq_mul,
      Matrix.mul_apply, Matrix.conjTranspose_apply, star_trivial, M, Matrix.of_apply]
    ring
  rw [heq]
  exact (Matrix.posSemidef_self_mul_conjTranspose M).smul (inv_nonneg.mpr hN)

/-- Exact equality of the original N-wide readout with the fixed-dimensional
canonical Gaussian readout. No nonsingularity assumption is made. -/
theorem law_eq_canonical (H : I → X → ℝ) (N : ℕ) (hN : 0 < N) (v : ℝ≥0) :
    (Measure.pi fun _ : I => gaussianReal 0 v).map (GaussianReadout.readout H) =
      (Measure.pi fun _ : X => gaussianReal 0 ((N : ℝ≥0)*v)).map
        (GaussianReadout.readout (canonicalFeatures (normalizedGram H N))) := by
  apply GaussianReadout.law_eq_of_gram_eq
  intro x y
  rw [gram_canonicalFeatures _ (normalizedGram_posSemidef H (by positivity))]
  simp only [normalizedGram, NNReal.coe_mul, NNReal.coe_natCast]
  have hNr : (N : ℝ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hN)
  field_simp

open scoped Matrix.Norms.L2Operator in
theorem continuousOn_sqrt :
    ContinuousOn (fun Q : Matrix X X ℝ => CFC.sqrt Q) {Q | Q.PosSemidef} := by
  simpa only [Matrix.nonneg_iff_posSemidef] using
    (CFC.continuousOn_sqrt (A := Matrix X X ℝ))

open scoped Matrix.Norms.Elementwise in
/-- The metric in this statement is the ordinary coefficient-array metric.
The operator norm scope is confined to the proof of topological continuity. -/
theorem sqrt_close_of_entries_close (K : Matrix X X ℝ) (hK : K.PosSemidef)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ Q : Matrix X X ℝ, Q.PosSemidef →
      (∀ x y, |Q x y-K x y| < δ) → dist (canonicalMatrix Q) (canonicalMatrix K) < ε := by
  have hc : ContinuousOn canonicalMatrix {Q : Matrix X X ℝ | Q.PosSemidef} := by
    have he : Continuous (fun M : Matrix X X ℝ => fun x i => M x i) := by fun_prop
    exact he.comp_continuousOn (continuousOn_sqrt (X := X))
  obtain ⟨δ,hδ,hnear⟩ := Metric.continuousWithinAt_iff.mp
    (hc K hK) ε hε
  refine ⟨δ,hδ,fun Q hQ hentry => hnear hQ ?_⟩
  apply (dist_pi_lt_iff hδ).2
  intro x
  apply (dist_pi_lt_iff hδ).2
  intro y
  simpa only [Real.dist_eq] using hentry x y

theorem canonicalFeatures_close_of_entries_close (K : Matrix X X ℝ) (hK : K.PosSemidef)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ Q : Matrix X X ℝ, Q.PosSemidef →
      (∀ x y, |Q x y-K x y| < δ) →
        dist (canonicalFeatures Q) (canonicalFeatures K) < ε := by
  obtain ⟨δ,hδ,hnear⟩ := sqrt_close_of_entries_close K hK hε
  refine ⟨δ,hδ,fun Q hQ hentry => ?_⟩
  have hn := hnear Q hQ hentry
  apply (dist_pi_lt_iff hε).2
  intro i
  apply (dist_pi_lt_iff hε).2
  intro x
  exact (dist_pi_lt_iff hε).1 ((dist_pi_lt_iff hε).1 hn x) i

theorem sqrt_surjective (K : Matrix X X ℝ) (hK : K.PosDef) :
    Function.Surjective (Matrix.mulVec (CFC.sqrt K)) :=
  Matrix.mulVec_surjective_iff_isUnit.mpr ((CFC.isUnit_sqrt_iff K hK.posSemidef.nonneg).mpr hK.isUnit)

theorem sqrt_margin_nonempty (K : Matrix X X ℝ) (hK : K.PosDef) (a : ℝ) :
    (GaussianMarginGeometry.linearMargin (canonicalMatrix K) a).Nonempty := by
  obtain ⟨z,hz⟩ := sqrt_surjective K hK (fun _ => a+1)
  refine ⟨z,fun x => ?_⟩
  have hx := congrFun hz x
  change a < ∑ i, (CFC.sqrt K) x i*z i
  change (∑ i, (CFC.sqrt K) x i*z i) = a+1 at hx
  linarith

end NeuralGeneralization.GaussianCovarianceFactor
end
