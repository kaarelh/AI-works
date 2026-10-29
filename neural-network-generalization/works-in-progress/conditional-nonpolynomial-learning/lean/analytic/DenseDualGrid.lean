import NeuralGeneralization.ActualBoundedDual
import NeuralGeneralization.EmpiricalDualTests
import NeuralGeneralization.FiniteParameterGrid
import Mathlib.MeasureTheory.Integral.Bochner.Set

/-! Dense parameter grids for the actual bounded dual. This replaces the sparse
quadratic-loss grid by a grid whose logarithmic cardinality is logarithmic in
inverse covariance tolerance. All exponential-family expectations are genuine
integrals under the given probability measure. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BoundedDual NeuralGeneralization.BoundedTilt
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.DualCertificate
open NeuralGeneralization.CompressionSampling
variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable (μ : Measure Ω) [IsProbabilityMeasure μ]

lemma potential_sub (T : ι → Ω → ℝ) (v w : ι → ℝ) (x : Ω) :
    potential T v x - potential T w x = potential T (v-w) x := by
  simp only [potential, pairing, Pi.sub_apply, sub_mul, Finset.sum_sub_distrib]

lemma log_partition_le_add (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (v w : ι → ℝ) :
    Real.log (partition μ (potential T v)) ≤
      Real.log (partition μ (potential T w)) + entryL1 (v-w) := by
  have hV := measurable_potential T hT v
  have hW := measurable_potential T hT w
  have hvb := potential_bound T hbound v
  have hwb := potential_bound T hbound w
  have hle : partition μ (potential T v) ≤
      Real.exp (entryL1 (v-w)) * partition μ (potential T w) := by
    simp only [partition]
    rw [← integral_const_mul]
    apply integral_mono (integrable_exp_of_bounded μ _ hV hvb)
      ((integrable_exp_of_bounded μ _ hW hwb).const_mul _)
    intro x
    dsimp only
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    have hp := (le_abs_self (potential T (v-w) x)).trans
      (potential_bound T hbound (v-w) x)
    rw [← potential_sub] at hp
    linarith
  have hlog := Real.log_le_log (partition_pos μ _ hV hvb) hle
  rw [Real.log_mul (Real.exp_pos _).ne' (partition_pos μ _ hW hwb).ne',
    Real.log_exp] at hlog
  simpa [add_comm] using hlog

lemma objective_le_add_l1 (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (q v w : ι → ℝ)
    (hq : ∀ i, |q i| ≤ 1) :
    objective μ T q v ≤ objective μ T q w + 2*entryL1 (v-w) := by
  have hlin : pairing v q - pairing w q ≤ entryL1 (v-w) := by
    rw [← pairing_sub_left]
    unfold pairing entryL1
    apply Finset.sum_le_sum
    intro i hi
    simp only [Pi.sub_apply]
    calc
      (v i-w i)*q i ≤ |(v i-w i)*q i| := le_abs_self _
      _ = |v i-w i| * |q i| := abs_mul _ _
      _ ≤ |v i-w i| := by
        simpa only [mul_one] using mul_le_mul_of_nonneg_left (hq i) (abs_nonneg (v i-w i))
  have hlog := log_partition_le_add μ T hT hbound w v
  have hl1 : entryL1 (w-v)=entryL1 (v-w) := by
    simp only [entryL1, Pi.sub_apply, abs_sub_comm]
  rw [hl1] at hlog
  unfold objective
  linarith

/-- Dense grid parameters. The rounded parameter need not stay inside the
l1 ball: fixed exponential tests have expectation one at every parameter. -/
def denseParameter (G : ℝ) (M : ℕ) (u : ι → NeuralGeneralization.ParameterGrid.GridInt M) : ι → ℝ :=
  fun i => G * NeuralGeneralization.ParameterGrid.decode M u i

lemma exists_dense_close {G : ℝ} (hG : 0 < G) {M : ℕ} (hM : 0 < M)
    (v : ι → ℝ) (hv : entryL1 v ≤ G) :
    ∃ u : ι → NeuralGeneralization.ParameterGrid.GridInt M,
      entryL1 (v-denseParameter G M u) ≤ (Fintype.card ι : ℝ)*G/M := by
  have hvi (i : ι) : |v i| ≤ G :=
    (Finset.single_le_sum (fun j _ => abs_nonneg (v j)) (Finset.mem_univ i)).trans hv
  obtain ⟨u,hu⟩ := NeuralGeneralization.ParameterGrid.exists_close_grid M hM (fun i => v i/G)
    (fun i => by rw [abs_div, abs_of_pos hG]; exact (div_le_one hG).mpr (hvi i))
  refine ⟨u,?_⟩
  have hcoord (i : ι) : |v i-denseParameter G M u i| ≤ G/M := by
    have h := mul_le_mul_of_nonneg_left (hu i) hG.le
    have hid : G*|v i/G-NeuralGeneralization.ParameterGrid.decode M u i| = |v i-denseParameter G M u i| := by
      calc
        G*|v i/G-NeuralGeneralization.ParameterGrid.decode M u i| =
          |G*(v i/G-NeuralGeneralization.ParameterGrid.decode M u i)| := by
            rw [abs_mul, abs_of_pos hG]
        _ = |v i-denseParameter G M u i| := by
          congr 1
          unfold denseParameter
          field_simp
    rw [hid] at h
    simpa only [mul_one_div] using h
  calc
    entryL1 (v-denseParameter G M u) ≤ ∑ _i : ι, G/M :=
      Finset.sum_le_sum (fun i _ => hcoord i)
    _ = (Fintype.card ι : ℝ)*G/M := by simp; ring

abbrev DenseIndex (ι : Type*) (M : ℕ) := ι → NeuralGeneralization.ParameterGrid.GridInt M

def denseSum (T : ι → Ω → ℝ) (G : ℝ) (M N : ℕ) (q : ι → ℝ) : ℝ :=
  ∑ u : DenseIndex ι M, Real.exp ((N:ℝ) * objective μ T q (denseParameter G M u))

def denseCost (T : ι → Ω → ℝ) (G : ℝ) (M N : ℕ) (q : ι → ℝ) : ℝ :=
  Real.log (denseSum μ T G M N q) / N + 2*(Fintype.card ι:ℝ)*G/M

lemma denseSum_pos (T : ι → Ω → ℝ) (G : ℝ) (M N : ℕ) (q : ι → ℝ) :
    0 < denseSum μ T G M N q := by
  classical
  let u : DenseIndex ι M := fun _ => ⟨0, by simp⟩
  exact (Real.exp_pos _).trans_le (Finset.single_le_sum
    (fun v _ => (Real.exp_pos ((N:ℝ)*objective μ T q (denseParameter G M v))).le)
    (Finset.mem_univ u))

lemma objective_le_denseCost (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    {M N : ℕ} (hM : 0 < M) (hN : 0 < N) (q : ι → ℝ)
    (hq : ∀ i, |q i| ≤ 1) (v : ι → ℝ) (hv : entryL1 v ≤ G) :
    objective μ T q v ≤ denseCost μ T G M N q := by
  classical
  obtain ⟨u,hu⟩ := exists_dense_close hG hM v hv
  have hobj := objective_le_add_l1 μ T hT hbound q v (denseParameter G M u) hq
  have hsingle : Real.exp ((N:ℝ)*objective μ T q (denseParameter G M u)) ≤
      denseSum μ T G M N q := Finset.single_le_sum
        (fun v _ => (Real.exp_pos ((N:ℝ)*objective μ T q (denseParameter G M v))).le)
        (Finset.mem_univ u)
  have hlog := Real.log_le_log (Real.exp_pos _) hsingle
  rw [Real.log_exp] at hlog
  have hNr : (0:ℝ) < N := by exact_mod_cast hN
  have hdiv : objective μ T q (denseParameter G M u) ≤
      Real.log (denseSum μ T G M N q) / N := by
    apply (le_div_iff₀ hNr).mpr
    simpa [mul_comm] using hlog
  unfold denseCost
  calc
    objective μ T q v ≤ objective μ T q (denseParameter G M u) +
        2*entryL1 (v-denseParameter G M u) := hobj
    _ ≤ Real.log (denseSum μ T G M N q)/N +
        2*((Fintype.card ι:ℝ)*G/M) :=
      add_le_add hdiv (mul_le_mul_of_nonneg_left hu (by norm_num))
    _ = _ := by ring

/-- An actual tilted probability law, with entropy and moment error controlled
by the dense finite-test statistic. No optimizer is assumed. -/
theorem exists_tilt_of_denseCost (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {G : ℝ} (hG : 0 < G)
    {M N : ℕ} (hM : 0 < M) (hN : 0 < N) (q : ι → ℝ)
    (hq : ∀ i, |q i| ≤ 1) :
    ∃ star : ι → ℝ, entryL1 star ≤ G ∧
      entropy μ T star ≤ denseCost μ T G M N q ∧
      maxAbs (q-mean μ T star) ≤ denseCost μ T G M N q/G := by
  exact exists_bounded_dual_lift_of_rate_bound μ T hT hbound q hG
    (objective_le_denseCost μ T hT hbound hG hM hN q hq)

lemma exp_denseCost (T : ι → Ω → ℝ) (G : ℝ) (M : ℕ) {N : ℕ}
    (hN : 0 < N) (q : ι → ℝ) :
    Real.exp ((N:ℝ)*denseCost μ T G M N q) =
      Real.exp ((N:ℝ)*(2*(Fintype.card ι:ℝ)*G/M))*denseSum μ T G M N q := by
  have hNr : (N:ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  unfold denseCost
  rw [mul_add, mul_div_cancel₀ _ hNr, Real.exp_add,
    Real.exp_log (denseSum_pos μ T G M N q), mul_comm]

lemma integrable_exp_denseCost (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (G : ℝ) (M : ℕ) {N : ℕ}
    (hN : 0 < N) :
    Integrable (fun a : Fin N → Ω => Real.exp ((N:ℝ)*denseCost μ T G M N (empirical T a)))
      (iidSamples μ N) := by
  simp_rw [exp_denseCost μ T G M hN]
  apply Integrable.const_mul
  exact integrable_finsetSum _ (fun u _ =>
    integrable_exp_objective μ T hT hbound hN (denseParameter G M u))

/-- Exact exponential moment, uniform in the underlying probability law.
The logarithm of the overhead is k*log(2M+1)+2NkG/M. -/
theorem integral_exp_denseCost (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (G : ℝ) (M : ℕ) {N : ℕ}
    (hN : 0 < N) :
    (∫ a : Fin N → Ω, Real.exp ((N:ℝ)*denseCost μ T G M N (empirical T a))
      ∂iidSamples μ N) = Real.exp ((N:ℝ)*(2*(Fintype.card ι:ℝ)*G/M))*
        (((2*M+1)^(Fintype.card ι):ℕ):ℝ) := by
  simp_rw [exp_denseCost μ T G M hN]
  rw [integral_const_mul]
  congr 1
  unfold denseSum
  rw [integral_finsetSum]
  · simp only [integral_exp_objective_eq_one μ T hT hbound hN,
      Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
    rw [Fintype.card_fun, NeuralGeneralization.ParameterGrid.gridInt_card]
  · intro u _
    exact integrable_exp_objective μ T hT hbound hN (denseParameter G M u)

#print axioms integral_exp_denseCost
#print axioms exists_tilt_of_denseCost
#print axioms objective_le_add_l1
#print axioms exists_dense_close
end ConditionalNonpolynomial.Analytic
