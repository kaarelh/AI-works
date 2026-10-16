import NeuralGeneralization.GaussianRate
import Mathlib.Topology.MetricSpace.ProperSpace

/-!
# Stability of finite Gaussian margin-event energies

The lower and upper geometric estimates are uniform over small perturbations
of a finite linear map. Boundary feasibility is handled by positive scaling,
so no minimizer or strict-complementarity assumption is needed.
-/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.GaussianMarginGeometry
open GaussianRate
variable {I J : Type*} [Fintype I] [Fintype J]

def linearMargin (P : J → I → ℝ) (a : ℝ) : Set (I → ℝ) :=
  {z | ∀ j, a < ∑ i, P j i * z i}

theorem isOpen_linearMargin (P : J → I → ℝ) (a : ℝ) : IsOpen (linearMargin P a) := by
  have he : linearMargin P a = ⋂ j, {z | a < ∑ i, P j i * z i} := by
    ext z
    simp only [linearMargin, Set.mem_setOf_eq, Set.mem_iInter]
  rw [he]
  apply isOpen_iInter_of_finite
  intro j
  exact isOpen_lt continuous_const (by fun_prop)

@[fun_prop] theorem continuous_squareSum : Continuous (squareSum (ι := I)) := by
  unfold squareSum
  fun_prop

omit [Fintype J] in
/-- A point on the closed positive-margin boundary has no less energy than
the infimum over the strict margin event. -/
theorem closed_margin_energy_lower (P : J → I → ℝ) {a : ℝ} (ha : 0 < a)
    (z : I → ℝ) (hz : ∀ j, a ≤ ∑ i, P j i * z i) :
    squareInf (linearMargin P a) ≤ squareSum z := by
  let s : ℕ → ℝ := fun n => 1 + 1 / ((n : ℝ) + 1)
  have hs : Tendsto s atTop (𝓝 (1 : ℝ)) := by
    simpa only [add_zero] using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_add 1
  have hlim : Tendsto (fun n => squareSum (fun i => s n * z i)) atTop (𝓝 (squareSum z)) := by
    apply continuous_squareSum.continuousAt.tendsto.comp
    apply tendsto_pi_nhds.mpr
    intro i
    simpa only [one_mul] using hs.mul_const (z i)
  apply ge_of_tendsto hlim
  apply Eventually.of_forall
  intro n
  apply squareInf_le
  intro j
  have hspos : 1 < s n := by
    dsimp [s]
    linarith [show 0 < 1 / ((n : ℝ) + 1) by positivity]
  have hid : (∑ i, P j i * (s n * z i)) = s n * ∑ i, P j i * z i := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  change a < ∑ i, P j i * (s n * z i)
  rw [hid]
  have hj := hz j
  nlinarith

/-- Uniform lower energy outside a strict sublevel of the limiting margin
energy. This is the compactness step for the Gaussian rate upper bound. -/
theorem uniform_margin_energy_lower (P : J → I → ℝ) {a b : ℝ} (ha : 0 < a)
    (hb : b < squareInf (linearMargin P a)) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ Q : J → I → ℝ, dist Q P < δ →
      ∀ z ∈ linearMargin Q a, b ≤ squareSum z := by
  by_contra hnot
  push Not at hnot
  choose Q hQ z hz henergy using
    fun n : ℕ => hnot (1 / ((n : ℝ) + 1)) (by positivity)
  have hbpos : 0 < b := (squareSum_nonneg (z 0)).trans_lt (henergy 0)
  have hQlim : Tendsto Q atTop (𝓝 P) := by
    apply tendsto_iff_dist_tendsto_zero.mpr
    exact squeeze_zero (fun _ => dist_nonneg) (fun n => (hQ n).le)
      tendsto_one_div_add_atTop_nhds_zero_nat
  have hzbound (n : ℕ) : z n ∈ Metric.closedBall (0 : I → ℝ) (Real.sqrt b) := by
    rw [Metric.mem_closedBall, dist_zero_right]
    apply (pi_norm_le_iff_of_nonneg (Real.sqrt_nonneg b)).mpr
    intro i
    have hi : z n i ^ 2 ≤ squareSum (z n) :=
      Finset.single_le_sum (fun j _ => sq_nonneg (z n j)) (Finset.mem_univ i)
    have hsqrt := Real.sq_sqrt hbpos.le
    rw [Real.norm_eq_abs]
    nlinarith [sq_abs (z n i), Real.sqrt_nonneg b, abs_nonneg (z n i), henergy n]
  obtain ⟨z₀, _, f, hf, hzf⟩ := (isCompact_closedBall (0 : I → ℝ) (Real.sqrt b)).tendsto_subseq hzbound
  have hQf := hQlim.comp hf.tendsto_atTop
  have hclosed : ∀ j, a ≤ ∑ i, P j i * z₀ i := by
    intro j
    have hlim : Tendsto (fun n => ∑ i, Q (f n) j i * z (f n) i) atTop
        (𝓝 (∑ i, P j i * z₀ i)) := by
      apply tendsto_finsetSum
      intro i hi
      exact (((continuous_apply i).comp (continuous_apply j)).tendsto P |>.comp hQf).mul
        ((continuous_apply i).tendsto z₀ |>.comp hzf)
    apply ge_of_tendsto hlim
    exact Eventually.of_forall (fun n => (hz (f n) j).le)
  have hlow := closed_margin_energy_lower P ha z₀ hclosed
  have hupp : squareSum z₀ ≤ b := by
    apply le_of_tendsto (continuous_squareSum.continuousAt.tendsto.comp hzf)
    exact Eventually.of_forall (fun n => (henergy (f n)).le)
  linarith

/-- A single positive-radius rectangle remains inside every sufficiently
nearby strict-margin event, with nearly optimal limiting energy. -/
theorem uniform_margin_rectangle (P : J → I → ℝ) (a : ℝ)
    (hne : (linearMargin P a).Nonempty) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∃ z : I → ℝ, ∃ r : ℝ, 0 < r ∧
      (∀ Q : J → I → ℝ, dist Q P < δ →
        (Set.pi Set.univ fun i => Set.Icc (z i - r) (z i + r)) ⊆ linearMargin Q a) ∧
      (∑ i, (|z i| + r) ^ 2) < squareInf (linearMargin P a) + ε := by
  obtain ⟨e, ⟨z, hz, rfl⟩, he⟩ :=
    exists_lt_of_csInf_lt (hne.image squareSum)
      (show sInf (squareSum '' linearMargin P a) < squareInf (linearMargin P a) + ε by
        unfold squareInf
        linarith)
  let U : Set ((J → I → ℝ) × (I → ℝ)) := {p | ∀ j, a < ∑ i, p.1 j i * p.2 i}
  have hU : IsOpen U := by
    have hu : U = ⋂ j, {p | a < ∑ i, p.1 j i * p.2 i} := by
      ext p
      simp only [U, Set.mem_setOf_eq, Set.mem_iInter]
    rw [hu]
    apply isOpen_iInter_of_finite
    intro j
    exact isOpen_lt continuous_const (by fun_prop)
  obtain ⟨δ, hδ, hball⟩ := Metric.isOpen_iff.mp hU (P,z) hz
  obtain ⟨r, hr, hrect, henergy⟩ := exists_rectangle_near_center Metric.isOpen_ball z
    (Metric.mem_ball_self hδ) _ he
  refine ⟨δ, hδ, z, r, hr, ?_, henergy⟩
  intro Q hQ v hv
  change (Q,v) ∈ U
  apply hball
  have hvball := hrect hv
  change dist (Q,v) (P,z) < δ
  rw [Prod.dist_eq]
  exact max_lt hQ hvball

end NeuralGeneralization.GaussianMarginGeometry
