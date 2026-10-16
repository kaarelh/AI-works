import NeuralGeneralization.Network
import NeuralGeneralization.ReadoutDual
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Readout duality for the actual finite neural-network model

This instantiates the geometric dual lemma on the final activation vectors
of `ConcreteModel.Network`. In particular the energy is the model's weighted
squared norm and the covariance is its empirical activation Gram matrix.
-/

noncomputable section

open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

/-- The empirical covariance across neurons on the full Boolean cube. -/
def finalCovariance {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x y : Cube d) : ℝ :=
  (∑ j, finalHidden φ w x j * finalHidden φ w y j) / (N : ℝ)

theorem readout_energy_le_weightedSquaredNorm {d N r : ℕ} (w : Weights d N r) :
    (N : ℝ) * (∑ j, w (Sum.inr (Sum.inr j)) ^ 2) ≤ weightedSquaredNorm w := by
  have hfirst : 0 ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2) :=
    mul_nonneg (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _))
      (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)
  have hhidden : 0 ≤ ∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2 :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ =>
      Finset.sum_nonneg fun _ _ => sq_nonneg _
  unfold weightedSquaredNorm
  linarith

/-- Every network with the full strict half-margin and bounded model energy
admits the bounded signed dual readout used in the compression proof. -/
theorem exists_finalCovariance_dual {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (w : Weights d N r) (f : BooleanFunction d) {K : ℝ}
    (hmargin : w ∈ marginEvent φ (1 / 2) f)
    (henergy : weightedSquaredNorm w ≤ K) :
    ∃ beta : Cube d → ℝ, (∑ x, |beta x|) ≤ 2 * K ∧
      ∀ x, (1 / 2 : ℝ) ≤ labelReal (f x) * ∑ y, beta y * finalCovariance φ w x y := by
  let h : Cube d → EuclideanSpace ℝ (Fin N) :=
    fun x => WithLp.toLp 2 (finalHidden φ w x)
  let u : EuclideanSpace ℝ (Fin N) :=
    WithLp.toLp 2 (fun j => w (Sum.inr (Sum.inr j)))
  have hreadout (x : Cube d) : inner ℝ (h x) u = networkOutput φ w x := by
    simp [h, u, PiLp.inner_apply, RCLike.inner_apply, networkOutput]
  have hgram (x y : Cube d) : inner ℝ (h x) (h y) =
      ∑ j, finalHidden φ w x j * finalHidden φ w y j := by
    simp [h, PiLp.inner_apply, mul_comm]
  have hunorm : ‖u‖ ^ 2 = ∑ j, w (Sum.inr (Sum.inr j)) ^ 2 := by
    simpa [u] using EuclideanSpace.real_norm_sq_eq u
  have hE : (N : ℝ) * ‖u‖ ^ 2 ≤ K := by
    rw [hunorm]
    exact (readout_energy_le_weightedSquaredNorm w).trans henergy
  have hm (x : Cube d) : (1 / 2 : ℝ) ≤ labelReal (f x) * inner ℝ (h x) u := by
    rw [hreadout]
    exact (hmargin x).le
  obtain ⟨beta, hbeta, hpred⟩ := ReadoutDual.exists_normalized_gram_dual
    h (fun x => labelReal (f x)) u (scale := (N : ℝ)) (energy := K)
    (by exact_mod_cast hN)
    (fun x => abs_labelReal (f x)) hm hE
  refine ⟨beta, hbeta, ?_⟩
  intro x
  have hi := hpred x
  simp only [hgram] at hi
  simpa only [finalCovariance, ← mul_div_assoc, ← Finset.sum_div] using hi

end NeuralGeneralization.ConcreteModel

end
