import NeuralGeneralization.RobustCompressionLayerParametersTotalization
import NeuralGeneralization.RobustEntropySelectedHObservation

/-! # Concrete source-bank comparison for the selected Gaussian query

The source rows, active coordinates, and all tested feature vectors below are
literal maps of the selected message and the original activation field. The
identities include all normalization factors and the zero residual branch.
-/
noncomputable section
set_option maxHeartbeats 600000
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustCompressionSelectedBank
open RobustEntropy RobustGaussianGeometry RobustCompressionClipping
open RobustCompressionLayerParameters RobustCompressionSourceBank
open RobustCompressionLayerGaussian ConcreteModel
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    {N M m q : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]

abbrev SelectedBankState (A Y : Type*) (N m q : ℕ) :=
  ((A × Y) × (Fin N → EuclideanSpace ℝ (Fin q))) × (Fin m → Fin N)

/-- The actual selected source bank with its original active coordinates and
one common sampled index bank. In particular it has no singled-out test input. -/
def selectedBankData (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h) :
    BankLayerData (SelectedBankState A Y N m q) (Fin M) N m q where
  source := fun θ => sourceRows (selectedMessageBasis (q := q) b J θ.1.1)
  active := fun θ => θ.1.2
  indices := Prod.snd
  feature := fun θ => h θ.1.1.1
  source_measurable := measurable_sourceRows.comp
    ((measurable_selectedMessageBasis b hb J hJ).comp (by fun_prop))
  active_measurable := by fun_prop
  indices_measurable := measurable_snd
  feature_measurable := hh.comp (by fun_prop)

namespace SelectedBank
variable (b : A → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    (h : A → Fin M → Fin N → ℝ) (hh : Measurable h)

/-- The literal empirical source covariance is contractive, on every message. -/
theorem population_contractive (hN : 0 < N) (θ : SelectedBankState A Y N m q)
    (v : EuclideanSpace ℝ (Fin q)) :
    (∑ i, ⟪(selectedBankData (m := m) (q := q) b hb J hJ h hh).source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2 :=
  sourceRows_quadratic_le _ hN v

theorem population_trace (hN : 0 < N) (θ : SelectedBankState A Y N m q) :
    (∑ i, ‖(selectedBankData (m := m) (q := q) b hb J hJ h hh).source θ i‖^2)/(N : ℝ) ≤ q :=
  sourceRows_trace_le _ hN

theorem idealFeature_eq (hN : 0 < N)
    (hbh : ∀ a i, b a i = normalizedFeature (h a i))
    (i : Fin M) (θ : SelectedBankState A Y N m q) :
    (selectedBankData (m := m) (q := q) b hb J hJ h hh).idealFeature i θ =
      activeCoordinateVector (selectedMessageBasis (q := q) b J θ.1.1) (b θ.1.1.1 i) := by
  rw [hbh]
  exact sourceRows_feature_eq_coordinates _ _ hN

theorem residual_norm_le_one (hN : 0 < N)
    (hbh : ∀ a i, b a i = normalizedFeature (h a i))
    (hbound : ∀ a i j, |h a i j| ≤ 1)
    (i : Fin M) (a : A × Y) :
    ‖queryResidual (selectedMessageBasis (q := q) b J a) (b a.1 i)‖ ≤ 1 := by
  rw [hbh]
  exact source_feature_residual_norm_le_one _ _ hN (hbound a.1 i)

theorem idealVariance_sqrt [NeZero N]
    (hbh : ∀ a i, b a i = normalizedFeature (h a i))
    {t : ℝ} (ht : 0 ≤ t) (a T BH : ℝ) (i : Fin M)
    (θ : SelectedBankState A Y N m q) (j : Fin N) :
    Real.sqrt (((selectedBankData (m := m) (q := q) b hb J hJ h hh).parameters a t T BH i).idealVariance θ j : ℝ) =
      t * ‖queryResidual (selectedMessageBasis (q := q) b J θ.1.1) (b θ.1.1.1 i)‖ := by
  rw [(selectedBankData (m := m) (q := q) b hb J hJ h hh).idealVariance_eq a t T BH i θ
    (population_contractive b hb J hJ h hh (NeZero.pos N) θ) j, hbh]
  exact sqrt_source_feature_variance _ _ (NeZero.pos N) ht

/-- Exact original preactivation from the selected q-coordinate observation,
with the un-clipped active vector on the original side of the comparison. -/
theorem original_preactivation [NeZero N]
    (hbh : ∀ a i, b a i = normalizedFeature (h a i))
    {t : ℝ} (ht : 0 ≤ t) (a T BH : ℝ) (i : Fin M)
    (p : A × Y) (hcard : (J p).card ≤ q)
    (g : Fin N → EuclideanSpace ℝ (Fin N)) (z : Fin N → ℝ) (I : Fin m → Fin N) (j : Fin N) :
    let o := selectedHObservation (q := q) b J t i (p,(g,z))
    let θ : SelectedBankState A Y N m q := ((p,o.1),I)
    ⟪(selectedBankData (m := m) (q := q) b hb J hJ h hh).active θ j,
       (selectedBankData (m := m) (q := q) b hb J hJ h hh).idealFeature i θ⟫ +
      Real.sqrt (((selectedBankData (m := m) (q := q) b hb J hJ h hh).parameters a t T BH i).idealVariance θ j : ℝ)
        * o.2 j = t * ⟪b p.1 i,g j⟫ := by
  dsimp only
  rw [idealFeature_eq b hb J hJ h hh (NeZero.pos N) hbh,
    idealVariance_sqrt b hb J hJ h hh hbh ht]
  exact selectedHObservation_evaluation b J p hcard t i g z j

/-- Global totalized covariance contraction is proved from the actual selected
basis. Bad banks remain separately absorbing in the canonical construction. -/
theorem totalized_contractive [NeZero N] [NeZero m]
    {a t T BH : ℝ} (ha : 0 ≤ a) (i : Fin M) :
    ((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).Contractive :=
  (selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters_contractive ha i
    (population_contractive b hb J hJ h hh (NeZero.pos N))

/-- The literal good-bank mean and variance errors also hold for the globally
contractive package; the means are unchanged everywhere and the covariance
agrees on the actual success event. -/
theorem totalized_error_bounds [NeZero N] [NeZero m]
    {a t T BH : ℝ} (ha : 0 ≤ a) (hT : 0 < T) (hBH : 0 ≤ BH)
    (hbound : ∀ a i j, |h a i j| ≤ 1) (i : Fin M)
    (θ : SelectedBankState A Y N m q)
    (hg : sourceBankGood ((selectedBankData (m := m) (q := q) b hb J hJ h hh).source θ)
      ((selectedBankData (m := m) (q := q) b hb J hJ h hh).feature θ) a T θ.2) :
    (∀ j, (((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).idealMean θ j -
      ((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).finiteMean θ j)^2 ≤
      BH^2*((q : ℝ)/T+2*a)^2) ∧
    (∀ j, |(((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).idealVariance θ j : ℝ) -
      ((selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters a t T BH i).finiteVariance θ j| ≤
      t^2*(a+2*((q : ℝ)/T+2*a))) := by
  obtain ⟨hm,hv⟩ := (selectedBankData (m := m) (q := q) b hb J hJ h hh).parameters_error_bounds
    ha hT hBH i θ (hbound θ.1.1.1)
    (population_contractive b hb J hJ h hh (NeZero.pos N) θ)
    (population_trace b hb J hJ h hh (NeZero.pos N) θ) hg
  refine ⟨hm,?_⟩
  intro j
  rw [(selectedBankData (m := m) (q := q) b hb J hJ h hh).totalizedParameters_finiteVariance_of_good
    a t T BH i θ hg]
  exact hv j

end SelectedBank
end NeuralGeneralization.RobustCompressionSelectedBank
