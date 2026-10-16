import NeuralGeneralization.GaussianDualLayer
import NeuralGeneralization.LayerGramConcentration

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianDualMatrix
open ConcreteModel GaussianDualLayer GaussianAngularPrice GaussianFieldTilt CompressionSampling
variable {d N : ℕ} {J R : Type*} [Fintype J] [Fintype R]

def badMatrix (A : Cube d → J → ℝ) (H : Cube d → R → ℝ) (N : ℕ) (G K : ℝ) :
    Set (Fin N × R → ℝ) := {w | (fun i j => w (i,j)) ∈ rawBadRows A H N G K}

theorem measurableSet_badMatrix (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    (N : ℕ) (G K : ℝ) : MeasurableSet (badMatrix A H N G K) :=
  (rawBadRows_measurable A H N G K).preimage (by fun_prop)

theorem badMatrix_tail (hd : 0 < d) (A : Cube d → J → ℝ) (H : Cube d → R → ℝ)
    (v : ℝ≥0) (hcov : ∀ x y, (v : ℝ) * gram H x y = gram A x y)
    {N s : ℕ} (hN : 0 < N) (hs : 0 < s) {G : ℝ} (hG : 0 < G) (K : ℝ) :
    (Measure.pi (fun _ : Fin N × R => gaussianReal 0 v)).real (badMatrix A H N G K) ≤
      Real.exp (4 * (d : ℝ) * (s : ℝ) -
        (N : ℝ) * (K - G ^ 2 / (2 * (s : ℝ)))) := by
  have hp := LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin N) (_ : R) => gaussianReal 0 v)
  rw [← hp.map_eq, Measure.real, Measure.map_apply hp.measurable (measurableSet_badMatrix A H N G K)]
  exact rawBadRows_tail hd A H v hcov hN hs hG K

theorem gram_div_sqrt (H : Cube d → R → ℝ) {m : ℝ} (hm : 0 ≤ m) (x y : Cube d) :
    gram (fun x j => H x j / Real.sqrt m) x y = gram H x y / m := by
  unfold gram
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j hj
  rw [div_mul_div_comm, ← sq, Real.sq_sqrt hm]

end NeuralGeneralization.GaussianDualMatrix
end
