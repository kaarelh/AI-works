import TwoBallGeometry
import Mathlib.Topology.MetricSpace.Lipschitz

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch

/-- A set has a finite closed-ball cover with an explicit cardinality bound. -/
def FiniteBallCover {X : Type*} [PseudoMetricSpace X]
    (S : Set X) (N : ℕ) (r : ℝ) : Prop :=
  ∃ C : Finset X, C.card ≤ N ∧ ∀ x ∈ S, ∃ c ∈ C, dist x c ≤ r

lemma finiteBallCover_closedBall {X : Type*} [PseudoMetricSpace X] (z : X) (r : ℝ) :
    FiniteBallCover (Metric.closedBall z r) 1 r := by
  classical
  exact ⟨{z}, by simp, fun x hx ↦ ⟨z, by simp, hx⟩⟩

lemma FiniteBallCover.image_lipschitz {X Y : Type*} [PseudoMetricSpace X]
    [PseudoMetricSpace Y] {S : Set X} {N : ℕ} {r : ℝ}
    (hS : FiniteBallCover S N r) {K : NNReal} {f : X → Y} (hf : LipschitzWith K f) :
    FiniteBallCover (f '' S) N (K * r) := by
  classical
  obtain ⟨C, hCcard, hC⟩ := hS
  refine ⟨C.image f, Finset.card_image_le.trans hCcard, ?_⟩
  rintro y ⟨x, hx, rfl⟩
  obtain ⟨c, hc, hxc⟩ := hC x hx
  refine ⟨f c, Finset.mem_image_of_mem f hc, ?_⟩
  exact (hf.dist_le_mul x c).trans (mul_le_mul_of_nonneg_left hxc K.coe_nonneg)

lemma FiniteBallCover.mono {X : Type*} [PseudoMetricSpace X]
    {S T : Set X} {N : ℕ} {r : ℝ} (hT : FiniteBallCover T N r) (hST : S ⊆ T) :
    FiniteBallCover S N r := by
  obtain ⟨C, hCcard, hC⟩ := hT
  exact ⟨C, hCcard, fun x hx ↦ hC x (hST hx)⟩

/-- A unit-margin point agrees in sign with the output at any center within r,
provided r times the suffix Lipschitz constant is strictly less than one.
There is no margin assumption at the center. -/
theorem unit_margin_sign_center {X : Type*} [PseudoMetricSpace X]
    {f : X → ℝ} {T : NNReal} (hf : LipschitzWith T f)
    {x c : X} {r : ℝ} (hx : dist x c ≤ r) (hmargin : 1 ≤ |f x|)
    (hsmall : r * (T : ℝ) < 1) : (0 ≤ f x ↔ 0 ≤ f c) := by
  have hd : |f x - f c| < 1 := by
    rw [← Real.dist_eq]
    exact (hf.dist_le_mul x c).trans_lt
      ((mul_le_mul_of_nonneg_left hx T.coe_nonneg).trans_lt (by nlinarith [hsmall]))
  constructor
  · intro hfx
    rw [abs_of_nonneg hfx] at hmargin
    have := le_abs_self (f x - f c)
    linarith
  · intro hfc
    by_contra hfx
    rw [abs_of_neg (lt_of_not_ge hfx)] at hmargin
    have := neg_le_abs (f x - f c)
    linarith

/-- Every cluster of a sufficiently fine finite cover is monochromatic for a
Lipschitz real output with unit margin on the covered set. -/
theorem FiniteBallCover.monochromatic {X : Type*} [PseudoMetricSpace X]
    {S : Set X} {N : ℕ} {r : ℝ} (hS : FiniteBallCover S N r)
    {f : X → ℝ} {T : NNReal} (hf : LipschitzWith T f)
    (hmargin : ∀ x ∈ S, 1 ≤ |f x|) (hsmall : r * (T : ℝ) < 1) :
    ∃ C : Finset X, C.card ≤ N ∧
      (∀ x ∈ S, ∃ c ∈ C, dist x c ≤ r) ∧
      (∀ c ∈ C, ∀ x ∈ S, dist x c ≤ r → (0 ≤ f x ↔ 0 ≤ f c)) ∧
      (∀ c ∈ C, ∀ x ∈ S, ∀ y ∈ S, dist x c ≤ r → dist y c ≤ r →
        (0 ≤ f x ↔ 0 ≤ f y)) := by
  obtain ⟨C, hCcard, hC⟩ := hS
  refine ⟨C, hCcard, hC, ?_, ?_⟩
  · intro c _ x hx hxc
    exact unit_margin_sign_center hf hxc (hmargin x hx) hsmall
  · intro c _ x hx y hy hxc hyc
    exact (unit_margin_sign_center hf hxc (hmargin x hx) hsmall).trans
      (unit_margin_sign_center hf hyc (hmargin y hy) hsmall).symm

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [FiniteDimensional ℝ F]

/-- Each input ball produces at most two output balls; taking their finite union
multiplies the number of balls by at most two. -/
theorem FiniteBallCover.image_linear {S : Set E} {N : ℕ} {r : ℝ}
    (hS : FiniteBallCover S N r) (hr : 0 ≤ r) (A : E →ₗ[ℝ] F) :
    FiniteBallCover (A '' S) (N * 2) (r * frobeniusNorm A / Real.sqrt 2) := by
  classical
  obtain ⟨C, hCcard, hC⟩ := hS
  choose D hDcard hD using fun z : E ↦ two_ball_frobenius_cover_finset A z r hr
  refine ⟨C.biUnion D, ?_, ?_⟩
  · exact (Finset.card_biUnion_le_card_mul C D 2 (fun z _ ↦ hDcard z)).trans
      (Nat.mul_le_mul_right 2 hCcard)
  · rintro y ⟨x, hx, rfl⟩
    obtain ⟨c, hc, hxc⟩ := hC x hx
    obtain ⟨d, hd, hxd⟩ := hD c (A x) ⟨x, hxc, rfl⟩
    exact ⟨d, Finset.mem_biUnion.mpr ⟨c, hc, hd⟩, hxd⟩

/-- An affine layer followed by an arbitrary whole-vector 1-Lipschitz map.
This is a geometric statement, with no assertion about coordinatewise activations. -/
theorem FiniteBallCover.image_layer {S : Set E} {N : ℕ} {r : ℝ}
    (hS : FiniteBallCover S N r) (hr : 0 ≤ r) (A : E →ₗ[ℝ] F)
    (b : F) (σ : F → F) (hσ : LipschitzWith 1 σ) :
    FiniteBallCover ((fun x ↦ σ (A x + b)) '' S) (N * 2)
      (r * frobeniusNorm A / Real.sqrt 2) := by
  have hf : LipschitzWith 1 (fun y : F ↦ σ (y + b)) := by
    apply LipschitzWith.of_dist_le_mul
    intro x y
    simpa only [NNReal.coe_one, one_mul, dist_add_right] using hσ.dist_le_mul (x + b) (y + b)
  have h := (hS.image_linear hr A).image_lipschitz hf
  simpa only [NNReal.coe_one, one_mul, Set.image_image, Function.comp_def] using h

section Iteration

variable {H : ℕ → Type*} [∀ n, NormedAddCommGroup (H n)]
  [∀ n, InnerProductSpace ℝ (H n)] [∀ n, FiniteDimensional ℝ (H n)]

/-- A network with genuinely varying finite-dimensional layer spaces. -/
def layerIter (A : ∀ n, H n →ₗ[ℝ] H (n + 1)) (b : ∀ n, H (n + 1))
    (σ : ∀ n, H (n + 1) → H (n + 1)) : (n : ℕ) → H 0 → H n
  | 0, x => x
  | n + 1, x => σ n (A n (layerIter A b σ n x) + b n)

noncomputable def networkCoverRadius (A : ∀ n, H n →ₗ[ℝ] H (n + 1))
    (R : ℝ) : ℕ → ℝ
  | 0 => R
  | n + 1 => networkCoverRadius A R n * frobeniusNorm (A n) / Real.sqrt 2

lemma networkCoverRadius_nonneg (A : ∀ n, H n →ₗ[ℝ] H (n + 1))
    (R : ℝ) (hR : 0 ≤ R) (n : ℕ) : 0 ≤ networkCoverRadius A R n := by
  induction n with
  | zero => exact hR
  | succ n ih =>
    dsimp [networkCoverRadius]
    exact div_nonneg (mul_nonneg ih (Real.sqrt_nonneg _)) (Real.sqrt_nonneg _)

lemma networkCoverRadius_eq (A : ∀ n, H n →ₗ[ℝ] H (n + 1)) (R : ℝ) (n : ℕ) :
    networkCoverRadius A R n =
      R * (∏ i ∈ Finset.range n, frobeniusNorm (A i)) / (Real.sqrt 2) ^ n := by
  induction n with
  | zero => simp [networkCoverRadius]
  | succ n ih =>
    rw [networkCoverRadius, ih, Finset.prod_range_succ, pow_succ]
    ring

/-- After n affine and 1-Lipschitz layers, the image of a radius-R input ball
is covered by at most 2^n balls. Its radius has a factor 1/sqrt(2) per layer. -/
theorem network_finite_ball_cover (A : ∀ n, H n →ₗ[ℝ] H (n + 1))
    (b : ∀ n, H (n + 1)) (σ : ∀ n, H (n + 1) → H (n + 1))
    (hσ : ∀ n, LipschitzWith 1 (σ n)) (z : H 0) (R : ℝ) (hR : 0 ≤ R)
    (n : ℕ) :
    FiniteBallCover (layerIter A b σ n '' Metric.closedBall z R) (2 ^ n)
      (R * (∏ i ∈ Finset.range n, frobeniusNorm (A i)) / (Real.sqrt 2) ^ n) := by
  rw [← networkCoverRadius_eq]
  induction n with
  | zero => simpa only [layerIter, pow_zero, networkCoverRadius, Set.image_id']
      using finiteBallCover_closedBall z R
  | succ n ih =>
    have h := ih.image_layer (networkCoverRadius_nonneg A R hR n) (A n) (b n) (σ n) (hσ n)
    simpa only [networkCoverRadius, pow_succ, Set.image_image, Function.comp_def, layerIter] using h

/-- A discrete or continuous subset of the input ball inherits a finite family
of monochromatic hidden-space clusters whenever radius times suffix Lipschitz
constant is less than one. This theorem makes no circuit-complexity claim. -/
theorem network_monochromatic_cover (A : ∀ n, H n →ₗ[ℝ] H (n + 1))
    (b : ∀ n, H (n + 1)) (σ : ∀ n, H (n + 1) → H (n + 1))
    (hσ : ∀ n, LipschitzWith 1 (σ n)) (z : H 0) (R : ℝ) (hR : 0 ≤ R)
    (n : ℕ) (S : Set (H 0)) (hS : S ⊆ Metric.closedBall z R)
    (f : H n → ℝ) (T : NNReal) (hf : LipschitzWith T f)
    (hmargin : ∀ x ∈ S, 1 ≤ |f (layerIter A b σ n x)|)
    (hsmall : (R * (∏ i ∈ Finset.range n, frobeniusNorm (A i)) /
      (Real.sqrt 2) ^ n) * (T : ℝ) < 1) :
    ∃ C : Finset (H n), C.card ≤ 2 ^ n ∧
      (∀ x ∈ S, ∃ c ∈ C, dist (layerIter A b σ n x) c ≤
        R * (∏ i ∈ Finset.range n, frobeniusNorm (A i)) / (Real.sqrt 2) ^ n) ∧
      (∀ c ∈ C, ∀ x ∈ S,
        dist (layerIter A b σ n x) c ≤
          R * (∏ i ∈ Finset.range n, frobeniusNorm (A i)) / (Real.sqrt 2) ^ n →
        (0 ≤ f (layerIter A b σ n x) ↔ 0 ≤ f c)) := by
  have hcover := (network_finite_ball_cover A b σ hσ z R hR n).mono (Set.image_mono hS)
  have himageMargin : ∀ y ∈ layerIter A b σ n '' S, 1 ≤ |f y| := by
    rintro y ⟨x, hx, rfl⟩
    exact hmargin x hx
  obtain ⟨C, hCcard, hC, hsign, _⟩ := hcover.monochromatic hf himageMargin hsmall
  exact ⟨C, hCcard, fun x hx ↦ hC _ ⟨x, hx, rfl⟩,
    fun c hc x hx ↦ hsign c hc _ ⟨x, hx, rfl⟩⟩

end Iteration

#print axioms network_finite_ball_cover
#print axioms network_monochromatic_cover

end BooleanDepthResearch
