import NeuralGeneralization.ConcreteReadoutDual
import NeuralGeneralization.TowerCompression

/-! The mean-field readout uses only its own energy, not the much larger
sum of all internal Gaussian squares. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.MeanFieldReadout
open ConcreteModel

theorem exists_unit_margin_dual {d N r : ℕ} (hN : 0 < N)
    (w : Weights d N r) (f : BooleanFunction d) {K : ℝ}
    (hmargin : w ∈ marginEvent Real.tanh (1 / 2) f)
    (henergy : (N : ℝ) * (∑ i, w (.inr (.inr i)) ^ 2) ≤ K) :
    ∃ β : Cube d → ℝ, (∑ x, |β x|) ≤ 4 * K ∧
      ∀ x, (1 : ℝ) ≤ labelReal (f x) * ∑ y, β y * finalCovariance Real.tanh w x y := by
  let h : Cube d → EuclideanSpace ℝ (Fin N) :=
    fun x => WithLp.toLp 2 (finalHidden Real.tanh w x)
  let u : EuclideanSpace ℝ (Fin N) :=
    WithLp.toLp 2 (fun j => w (.inr (.inr j)))
  have hreadout (x : Cube d) : inner ℝ (h x) u = networkOutput Real.tanh w x := by
    simp [h, u, PiLp.inner_apply, RCLike.inner_apply, networkOutput]
  have hgram (x y : Cube d) : inner ℝ (h x) (h y) =
      ∑ j, finalHidden Real.tanh w x j * finalHidden Real.tanh w y j := by
    simp [h, PiLp.inner_apply, mul_comm]
  have hunorm : ‖u‖ ^ 2 = ∑ j, w (.inr (.inr j)) ^ 2 := by
    simpa [u] using EuclideanSpace.real_norm_sq_eq u
  obtain ⟨β, hβ, hpred⟩ := ReadoutDual.exists_normalized_gram_dual h
    (fun x => labelReal (f x)) u (scale := (N : ℝ)) (energy := K)
    (by exact_mod_cast hN) (fun x => abs_labelReal (f x))
    (fun x => by rw [hreadout]; exact (hmargin x).le)
    (by simpa only [hunorm] using henergy)
  refine ⟨fun x => 2 * β x, ?_, ?_⟩
  · simp only [abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2), ← Finset.mul_sum]
    linarith
  · intro x
    have hi := hpred x
    simp only [hgram] at hi
    have hhalf : (1 / 2 : ℝ) ≤ labelReal (f x) * ∑ y, β y * finalCovariance Real.tanh w x y := by
      simpa only [finalCovariance, ← mul_div_assoc, ← Finset.sum_div] using hi
    have heq : labelReal (f x) * (∑ y, (2 * β y) * finalCovariance Real.tanh w x y) =
        2 * (labelReal (f x) * ∑ y, β y * finalCovariance Real.tanh w x y) := by
      simp only [mul_assoc, ← Finset.mul_sum]
      ring
    rw [heq]
    linarith

/-- Transporting the bounded dual readout across a 1/(32K) covariance error
retains at least 7/8 signed margin. -/
theorem transported_margin {d : ℕ} (Q Q' : Cube d → Cube d → ℝ)
    (β : Cube d → ℝ) (f : BooleanFunction d) {K : ℝ} (hK : 0 < K)
    (hβ : (∑ x, |β x|) ≤ 4 * K)
    (hmargin : ∀ x, (1 : ℝ) ≤ labelReal (f x) * ∑ y, β y * Q x y)
    (hcov : ∀ x y, |Q x y - Q' x y| ≤ 1 / (32 * K)) :
    ∀ x, (7 / 8 : ℝ) ≤ labelReal (f x) * ∑ y, β y * Q' x y := by
  intro x
  have herr := TowerCompression.covariance_action_difference_bound Q Q' β
    (by positivity : (0 : ℝ) ≤ 1 / (32 * K)) hβ hcov x
  have heq : 4 * K * (1 / (32 * K)) = (1 : ℝ) / 8 := by field_simp; norm_num
  rw [heq] at herr
  have hsigned : |labelReal (f x) * ((∑ y, β y * Q x y) - ∑ y, β y * Q' x y)| ≤ 1 / 8 := by
    simpa only [abs_mul, abs_labelReal, one_mul] using herr
  have hh := (abs_le.mp hsigned).2
  have hm := hmargin x
  nlinarith

end NeuralGeneralization.MeanFieldReadout
