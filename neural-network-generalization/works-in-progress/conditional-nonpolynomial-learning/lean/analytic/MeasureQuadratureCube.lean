import MeasureQuadratureUniform
import NeuralGeneralization.FiniteParameterGrid

/-! Uniform quadrature on an explicit continuous parameter cube. Cardinality
and approximation of the grid are derived, so the sample count grows only
linearly with parameter dimension and logarithmically with mesh precision. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ParameterGrid

abbrev ParameterCube (ι : Type*) (U : ℝ) := {v : ι → ℝ // ∀ i, |v i| ≤ U}

def cubeGridCenter {ι : Type*} (U : ℝ) (hU : 0 ≤ U) (T : ℕ) (hT : 0 < T)
    (q : ι → GridInt T) : ParameterCube ι U :=
  ⟨fun i => U*decode T q i, fun i => by
    rw [abs_mul, abs_of_nonneg hU]
    exact (mul_le_mul_of_nonneg_left (decode_abs_le_one T hT q i) hU).trans_eq (mul_one U)⟩

lemma cubeGrid_cover {ι : Type*} [Fintype ι] (U : ℝ) (hU : 0 < U)
    (T : ℕ) (hT : 0 < T) (v : ParameterCube ι U) :
    ∃ q : ι → GridInt T, dist v (cubeGridCenter U hU.le T hT q) ≤ U/T := by
  obtain ⟨q,hq⟩ := exists_close_grid T hT (fun i => v.val i/U) (fun i => by
    rw [abs_div, abs_of_pos hU]
    exact (div_le_one hU).mpr (v.property i))
  refine ⟨q,?_⟩
  change ‖v.val-(fun i => U*decode T q i)‖ ≤ U/T
  apply (pi_norm_le_iff_of_nonneg (by positivity)).mpr
  intro i
  change |v.val i-U*decode T q i| ≤ U/T
  have hh := mul_le_mul_of_nonneg_left (hq i) hU.le
  have heq : U*|v.val i/U-decode T q i| = |v.val i-U*decode T q i| := by
    calc
      U*|v.val i/U-decode T q i| = |U*(v.val i/U-decode T q i)| := by
        rw [abs_mul, abs_of_pos hU]
      _ = |v.val i-U*decode T q i| := by
        congr 1
        field_simp
  rw [heq] at hh
  simpa only [mul_one_div] using hh

/-- Actual uniform empirical approximation on a continuous cube. No finite-net
or concentration assumption remains: the grid and common nodes are derived.
The norm on parameter vectors is the supremum norm. A Euclidean-Lipschitz
family may use its (at most sqrt(d)-larger) supremum-norm Lipschitz constant. -/
theorem measure_cube_quadrature
    {Ω ι E : Type*} [MeasurableSpace Ω] [Fintype ι]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (U : ℝ) (hU : 0 < U) (T : ℕ) (hT : 0 < T)
    (v : ParameterCube ι U → Ω → E) (hInt : ∀ t, Integrable (v t) μ)
    (J L ε : ℝ) (hJ : 0 < J) (hL : 0 ≤ L) (hε : 0 < ε)
    (hv : ∀ t x, ‖v t x‖ ≤ J)
    (hLip : ∀ t u x, ‖v t x-v u x‖ ≤ L*dist t u)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 256*J^2*(1+(Fintype.card ι:ℝ)*Real.log (2*(T:ℝ)+1)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ t,
      ‖(m:ℝ)⁻¹ • (∑ j, v t (s j)) - ∫ x, v t x ∂μ‖ < ε+2*L*(U/T) := by
  classical
  letI : Nonempty (ι → GridInt T) := ⟨fun _ => ⟨0, by simp⟩⟩
  apply measure_uniform_quadrature μ v hInt J L ε (U/T) hJ hL hε hv hLip
    (cubeGridCenter U hU.le T hT) (cubeGrid_cover U hU T hT) m hm
  simpa only [Fintype.card_fun, gridInt_card, Nat.cast_pow, Nat.cast_add,
    Nat.cast_mul, Nat.cast_ofNat, Nat.cast_one, Real.log_pow] using hbudget

/-- Choosing a sufficiently fine mesh gives the requested uniform accuracy,
with an explicit dimension/log-precision sampling budget. -/
theorem measure_cube_quadrature_accuracy
    {Ω ι E : Type*} [MeasurableSpace Ω] [Fintype ι]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (U : ℝ) (hU : 0 < U) (T : ℕ) (hT : 0 < T)
    (v : ParameterCube ι U → Ω → E) (hInt : ∀ t, Integrable (v t) μ)
    (J L ε : ℝ) (hJ : 0 < J) (hL : 0 ≤ L) (hε : 0 < ε)
    (hv : ∀ t x, ‖v t x‖ ≤ J)
    (hLip : ∀ t u x, ‖v t x-v u x‖ ≤ L*dist t u)
    (m : ℕ) (hm : 0 < m)
    (hmesh : 4*L*U ≤ (T:ℝ)*ε)
    (hbudget : 1024*J^2*(1+(Fintype.card ι:ℝ)*Real.log (2*(T:ℝ)+1)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ t,
      ‖(m:ℝ)⁻¹ • (∑ j, v t (s j)) - ∫ x, v t x ∂μ‖ < ε := by
  obtain ⟨s,hs⟩ := measure_cube_quadrature μ U hU T hT v hInt J L (ε/2)
    hJ hL (by positivity) hv hLip m hm (by nlinarith)
  refine ⟨s,fun t => (hs t).trans_le ?_⟩
  have hTpos : 0 < (T:ℝ) := Nat.cast_pos.mpr hT
  have heq : 2*L*(U/(T:ℝ)) = (2*L*U)/(T:ℝ) := by ring
  rw [heq]
  have hh : (2*L*U)/(T:ℝ) ≤ ε/2 := (div_le_iff₀ hTpos).mpr (by nlinarith)
  linarith

#print axioms measure_cube_quadrature_accuracy
#print axioms measure_cube_quadrature
end ConditionalNonpolynomial.Analytic
