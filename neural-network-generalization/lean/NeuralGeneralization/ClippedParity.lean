import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-!
# The finite Markov clipping inequality

This module proves the exact finite averaging inequality behind the
clipped-parity argument. It is not a formalization of the exponential
sample lower bound, whose sampling, spectral and limiting arguments are
separate dependencies.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators

/-- The symmetric clipping function, with scale `b`. For `b > 0` this
is the usual truncation of `t / b` to the interval `[-1, 1]`. -/
def symmetricClip (b t : ℝ) : ℝ := (|t + b| - |t - b|) / (2 * b)

theorem symmetricClip_eq_max_min (b t : ℝ) (hb : 0 < b) :
    symmetricClip b t = max (-1) (min 1 (t / b)) := by
  unfold symmetricClip
  by_cases hlow : t ≤ -b
  · have hplus : t + b ≤ 0 := by linarith
    have hminus : t - b ≤ 0 := by linarith
    rw [abs_of_nonpos hplus, abs_of_nonpos hminus]
    have hdiv : t / b ≤ -1 := (div_le_iff₀ hb).2 (by linarith)
    rw [min_eq_right (by linarith : t / b ≤ 1), max_eq_left hdiv]
    field_simp [ne_of_gt hb]
    ring
  · by_cases hhigh : b ≤ t
    · have hplus : 0 ≤ t + b := by linarith
      have hminus : 0 ≤ t - b := by linarith
      rw [abs_of_nonneg hplus, abs_of_nonneg hminus]
      have hdiv : 1 ≤ t / b := (le_div_iff₀ hb).2 (by linarith)
      rw [min_eq_left hdiv, max_eq_right (by norm_num : (-1 : ℝ) ≤ 1)]
      field_simp [ne_of_gt hb]
      ring
    · have hplus : 0 ≤ t + b := by linarith
      have hminus : t - b ≤ 0 := by linarith
      have hlo : -1 ≤ t / b := (le_div_iff₀ hb).2 (by linarith)
      have hhi : t / b ≤ 1 := (div_le_iff₀ hb).2 (by linarith)
      rw [abs_of_nonneg hplus, abs_of_nonpos hminus,
        min_eq_right hhi, max_eq_right hlo]
      field_simp [ne_of_gt hb]
      ring

theorem symmetricClip_neg (b t : ℝ) :
    symmetricClip b (-t) = -symmetricClip b t := by
  unfold symmetricClip
  have h₁ : -t + b = -(t - b) := by ring
  have h₂ : -t - b = -(t + b) := by ring
  rw [h₁, h₂, abs_neg, abs_neg]
  ring

theorem symmetricClip_mul_sign (b t s : ℝ) (hs : s = 1 ∨ s = -1) :
    symmetricClip b (s * t) = s * symmetricClip b t := by
  rcases hs with rfl | rfl
  · simp
  · simp [symmetricClip_neg]

theorem symmetricClip_lipschitz (b u v : ℝ) (hb : 0 < b) :
    |symmetricClip b u - symmetricClip b v| ≤ |u - v| / b := by
  have hp : |(|u + b| - |v + b|)| ≤ |u - v| := by
    simpa only [add_sub_add_right_eq_sub] using abs_abs_sub_abs_le_abs_sub (u + b) (v + b)
  have hm : |(|u - b| - |v - b|)| ≤ |u - v| := by
    simpa only [sub_sub_sub_cancel_right] using abs_abs_sub_abs_le_abs_sub (u - b) (v - b)
  have hnum : |(|u + b| - |u - b|) - (|v + b| - |v - b|)| ≤ 2 * |u - v| := by
    have hid : (|u + b| - |u - b|) - (|v + b| - |v - b|) =
        (|u + b| - |v + b|) - (|u - b| - |v - b|) := by ring
    rw [hid]
    exact (abs_sub _ _).trans (by linarith)
  unfold symmetricClip
  rw [← sub_div, abs_div, abs_of_pos (by positivity : 0 < 2 * b)]
  calc
    _ ≤ (2 * |u - v|) / (2 * b) :=
      div_le_div_of_nonneg_right hnum (by positivity)
    _ = |u - v| / b := by field_simp [ne_of_gt hb]

def binarySign (t : ℝ) : ℝ := if 0 ≤ t then 1 else -1

theorem symmetricClip_eq_binarySign (b t : ℝ) (hb : 0 < b) (ht : b ≤ |t|) :
    symmetricClip b t = binarySign t := by
  rw [symmetricClip_eq_max_min b t hb]
  by_cases hzero : 0 ≤ t
  · have htb : b ≤ t := by simpa [abs_of_nonneg hzero] using ht
    have hdiv : 1 ≤ t / b := (le_div_iff₀ hb).2 (by linarith)
    simp [binarySign, hzero, min_eq_left hdiv]
  · have htb : t ≤ -b := by
      rw [abs_of_nonpos (le_of_not_ge hzero)] at ht
      linarith
    have hdiv : t / b ≤ -1 := (div_le_iff₀ hb).2 (by linarith)
    rw [min_eq_right (by linarith : t / b ≤ 1), max_eq_left hdiv]
    simp [binarySign, hzero]

section FiniteMarkov

variable {α : Type*} [Fintype α]

/-- A finite transition matrix preserves counting measure when each row
and each column sums to one. No symmetry assumption is needed. -/
structure DoublyStochastic (T : α → α → ℝ) : Prop where
  nonneg : ∀ x y, 0 ≤ T x y
  row_sum : ∀ x, ∑ y, T x y = 1
  col_sum : ∀ y, ∑ x, T x y = 1

def markovAverage (T : α → α → ℝ) (q : α → ℝ) (x : α) : ℝ :=
  ∑ y, T x y * q y

theorem sum_abs_markov_shift_le (T : α → α → ℝ)
    (hT : DoublyStochastic T) (q : α → ℝ) (b : ℝ) :
    (∑ x, |markovAverage T q x + b|) ≤ ∑ x, |q x + b| := by
  have hrow (x : α) : markovAverage T q x + b =
      ∑ y, T x y * (q y + b) := by
    simp [markovAverage, mul_add, Finset.sum_add_distrib,
      ← Finset.sum_mul, hT.row_sum]
  calc
    (∑ x, |markovAverage T q x + b|)
        ≤ ∑ x, ∑ y, T x y * |q y + b| := by
          apply Finset.sum_le_sum
          intro x hx
          rw [hrow]
          calc
            |∑ y, T x y * (q y + b)|
                ≤ ∑ y, |T x y * (q y + b)| := Finset.abs_sum_le_sum_abs _ _
            _ = ∑ y, T x y * |q y + b| := by
              apply Finset.sum_congr rfl
              intro y hy
              rw [abs_mul, abs_of_nonneg (hT.nonneg x y)]
    _ = ∑ y, |q y + b| := by
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro y hy
      rw [← Finset.sum_mul, hT.col_sum, one_mul]

/-- Exact finite clipping inequality. `markovAverage T q + q` measures
how far averaging is from reversing the sign of `q`. -/
theorem sum_symmetricClip_le_markov_defect (T : α → α → ℝ)
    (hT : DoublyStochastic T) (q : α → ℝ) (b : ℝ) (hb : 0 < b) :
    |∑ x, symmetricClip b (q x)| ≤
      (∑ x, |markovAverage T q x + q x|) / (2 * b) := by
  have hone (c : ℝ) :
      (∑ x, |q x - c|) ≤ (∑ x, |q x + c|) +
        ∑ x, |markovAverage T q x + q x| := by
    calc
      (∑ x, |q x - c|)
          ≤ ∑ x, (|markovAverage T q x + c| +
              |markovAverage T q x + q x|) := by
            apply Finset.sum_le_sum
            intro x hx
            have hid : q x - c =
                (markovAverage T q x + q x) - (markovAverage T q x + c) := by ring
            rw [hid]
            exact (abs_sub _ _).trans_eq (add_comm _ _)
      _ = (∑ x, |markovAverage T q x + c|) +
          ∑ x, |markovAverage T q x + q x| := Finset.sum_add_distrib
      _ ≤ (∑ x, |q x + c|) +
          ∑ x, |markovAverage T q x + q x| :=
        add_le_add_left (sum_abs_markov_shift_le T hT q c) _
  have hminus := hone b
  have hplus := hone (-b)
  simp only [sub_neg_eq_add, ← sub_eq_add_neg] at hplus
  have habs : |(∑ x, |q x + b|) - (∑ x, |q x - b|)| ≤
      ∑ x, |markovAverage T q x + q x| := by
    apply abs_le.mpr
    constructor <;> linarith
  have hden : 0 < 2 * b := by positivity
  simp only [symmetricClip, ← Finset.sum_div, Finset.sum_sub_distrib,
    abs_div, abs_of_pos hden]
  exact div_le_div_of_nonneg_right habs hden.le

/-- Bipartite averaging: the sign function reverses along every
transition of positive weight. -/
theorem markovAverage_sign_mul (T : α → α → ℝ) (f P : α → ℝ)
    (hf : ∀ x y, T x y ≠ 0 → f y = -f x) (x : α) :
    markovAverage T (fun y => f y * P y) x =
      -f x * markovAverage T P x := by
  unfold markovAverage
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro y hy
  dsimp only
  by_cases hzero : T x y = 0
  · simp [hzero]
  · rw [hf x y hzero]
    ring

/-- The clipped parity estimate on an arbitrary finite bipartite Markov
chain preserving the uniform measure. This applies to the cube's
uniform one-coordinate flip chain with its full parity sign. -/
theorem sum_parity_symmetricClip_le (T : α → α → ℝ)
    (hT : DoublyStochastic T) (f P : α → ℝ)
    (hsign : ∀ x, f x = 1 ∨ f x = -1)
    (hflip : ∀ x y, T x y ≠ 0 → f y = -f x)
    (b : ℝ) (hb : 0 < b) :
    |∑ x, f x * symmetricClip b (P x)| ≤
      (∑ x, |P x - markovAverage T P x|) / (2 * b) := by
  have hclip : (∑ x, symmetricClip b (f x * P x)) =
      ∑ x, f x * symmetricClip b (P x) := by
    apply Finset.sum_congr rfl
    intro x hx
    exact symmetricClip_mul_sign b (P x) (f x) (hsign x)
  have hdefect : (∑ x, |markovAverage T (fun y => f y * P y) x + f x * P x|) =
      ∑ x, |P x - markovAverage T P x| := by
    apply Finset.sum_congr rfl
    intro x hx
    rw [markovAverage_sign_mul T f P hflip x]
    have hid : -f x * markovAverage T P x + f x * P x =
        f x * (P x - markovAverage T P x) := by ring
    rw [hid, abs_mul]
    rcases hsign x with h | h <;> simp [h]
  have h := sum_symmetricClip_le_markov_defect T hT (fun x => f x * P x) b hb
  rw [hclip, hdefect] at h
  exact h

/-- For the cube, `d` is its dimension and this is the usual discrete
Laplacian, with Fourier eigenvalue equal to the character's degree. -/
def markovLaplacian (d : ℝ) (T : α → α → ℝ) (P : α → ℝ) (x : α) : ℝ :=
  (d / 2) * (P x - markovAverage T P x)

theorem sum_parity_symmetricClip_le_laplacian (T : α → α → ℝ)
    (hT : DoublyStochastic T) (f P : α → ℝ)
    (hsign : ∀ x, f x = 1 ∨ f x = -1)
    (hflip : ∀ x y, T x y ≠ 0 → f y = -f x)
    (b d : ℝ) (hb : 0 < b) (hd : 0 < d) :
    |∑ x, f x * symmetricClip b (P x)| ≤
      (∑ x, |markovLaplacian d T P x|) / (b * d) := by
  have hsum : (∑ x, |markovLaplacian d T P x|) =
      (d / 2) * ∑ x, |P x - markovAverage T P x| := by
    simp only [markovLaplacian, abs_mul, abs_of_pos (div_pos hd (by norm_num : (0 : ℝ) < 2))]
    rw [Finset.mul_sum]
  rw [hsum]
  have heq : ((d / 2) * ∑ x, |P x - markovAverage T P x|) / (b * d) =
      (∑ x, |P x - markovAverage T P x|) / (2 * b) := by
    field_simp [ne_of_gt hb, ne_of_gt hd]
  rw [heq]
  exact sum_parity_symmetricClip_le T hT f P hsign hflip b hb

end FiniteMarkov

section PermutationChains

variable {α ι : Type*} [Fintype α] [Fintype ι]

/-- Uniformly choose one of a finite family of permutations. -/
noncomputable def permutationKernel (e : ι → α ≃ α) (x y : α) : ℝ := by
  classical
  exact (∑ i, if e i x = y then (1 : ℝ) else 0) / Fintype.card ι

theorem markovAverage_permutationKernel (e : ι → α ≃ α) (P : α → ℝ) (x : α) :
    markovAverage (permutationKernel e) P x =
      (∑ i, P (e i x)) / Fintype.card ι := by
  classical
  unfold markovAverage permutationKernel
  simp_rw [div_mul_eq_mul_div, Finset.sum_mul]
  rw [← Finset.sum_div, Finset.sum_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  simp [ite_mul]

theorem permutationKernel_doublyStochastic (e : ι → α ≃ α)
    (hcard : (Fintype.card ι : ℝ) ≠ 0) :
    DoublyStochastic (permutationKernel e) := by
  classical
  constructor
  · intro x y
    apply div_nonneg
    · exact Finset.sum_nonneg (fun i hi => by split_ifs <;> norm_num)
    · exact Nat.cast_nonneg _
  · intro x
    simp only [permutationKernel, ← Finset.sum_div]
    rw [Finset.sum_comm]
    simp [hcard]
  · intro y
    simp only [permutationKernel, ← Finset.sum_div]
    rw [Finset.sum_comm]
    have he (i : ι) : (∑ x, if e i x = y then (1 : ℝ) else 0) = 1 := by
      rw [(e i).sum_comp (fun x => if x = y then (1 : ℝ) else 0)]
      simp
    simp only [he, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
    exact div_self hcard

omit [Fintype α] in
theorem permutationKernel_bipartite (e : ι → α ≃ α) (f : α → ℝ)
    (hflip : ∀ i x, f (e i x) = -f x) :
    ∀ x y, permutationKernel e x y ≠ 0 → f y = -f x := by
  classical
  intro x y hxy
  by_cases hex : ∃ i, e i x = y
  · obtain ⟨i, rfl⟩ := hex
    exact hflip i x
  · have hnone (i : ι) : e i x ≠ y := fun h => hex ⟨i, h⟩
    simp [permutationKernel, hnone] at hxy

end PermutationChains

section Cube

abbrev ClippingCube (d : ℕ) := Fin d → Bool

def cubeCoordinateSign (b : Bool) : ℝ := if b then 1 else -1

theorem cubeCoordinateSign_not (b : Bool) :
    cubeCoordinateSign (!b) = -cubeCoordinateSign b := by
  cases b <;> norm_num [cubeCoordinateSign]

def cubeFlip {d : ℕ} (i : Fin d) : ClippingCube d ≃ ClippingCube d where
  toFun x := Function.update x i (!(x i))
  invFun x := Function.update x i (!(x i))
  left_inv x := by
    funext j
    by_cases h : j = i
    · subst j
      simp
    · simp [Function.update_of_ne h]
  right_inv x := by
    funext j
    by_cases h : j = i
    · subst j
      simp
    · simp [Function.update_of_ne h]

def fullParity {d : ℕ} (x : ClippingCube d) : ℝ :=
  ∏ i, cubeCoordinateSign (x i)

theorem fullParity_sign {d : ℕ} (x : ClippingCube d) :
    fullParity x = 1 ∨ fullParity x = -1 := by
  have hsign (s : Finset (Fin d)) :
      (∏ i ∈ s, cubeCoordinateSign (x i)) = 1 ∨
        (∏ i ∈ s, cubeCoordinateSign (x i)) = -1 := by
    induction s using Finset.induction_on with
    | empty => simp
    | @insert i s hi ih =>
        rw [Finset.prod_insert hi]
        cases hx : x i <;> rcases ih with h | h <;>
          rw [h] <;> simp [cubeCoordinateSign]
  exact hsign Finset.univ

theorem fullParity_cubeFlip {d : ℕ} (i : Fin d) (x : ClippingCube d) :
    fullParity (cubeFlip i x) = -fullParity x := by
  have hrest : (∏ j ∈ Finset.univ.erase i, cubeCoordinateSign (cubeFlip i x j)) =
      ∏ j ∈ Finset.univ.erase i, cubeCoordinateSign (x j) := by
    apply Finset.prod_congr rfl
    intro j hj
    have hji : j ≠ i := (Finset.mem_erase.mp hj).1
    simp [cubeFlip, Function.update_of_ne hji]
  have hprod (z : ClippingCube d) : fullParity z =
      cubeCoordinateSign (z i) *
        ∏ j ∈ Finset.univ.erase i, cubeCoordinateSign (z j) := by
    exact (Finset.mul_prod_erase Finset.univ
      (fun j => cubeCoordinateSign (z j)) (Finset.mem_univ i)).symm
  rw [hprod (cubeFlip i x), hrest, hprod x]
  simp only [cubeFlip, Equiv.coe_fn_mk, Function.update_self]
  rw [cubeCoordinateSign_not]
  ring

/-- The usual discrete cube Laplacian, without normalization by dimension. -/
def cubeLaplacian {d : ℕ} (P : ClippingCube d → ℝ) (x : ClippingCube d) : ℝ :=
  (∑ i, (P x - P (cubeFlip i x))) / 2

theorem markovLaplacian_cube_eq {d : ℕ} (hd : 0 < d)
    (P : ClippingCube d → ℝ) (x : ClippingCube d) :
    markovLaplacian d (permutationKernel cubeFlip) P x = cubeLaplacian P x := by
  have hdreal : (d : ℝ) ≠ 0 := ne_of_gt (Nat.cast_pos.mpr hd)
  unfold markovLaplacian cubeLaplacian
  rw [markovAverage_permutationKernel]
  simp only [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  field_simp [hdreal]

/-- Exact cube specialization of the clipped Laplacian estimate.
The sums can equivalently be divided by `2^d` to obtain expectations. -/
theorem cube_clipped_parity_laplacian_bound {d : ℕ} (hd : 0 < d)
    (P : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) :
    |∑ x, fullParity x * symmetricClip b (P x)| ≤
      (∑ x, |cubeLaplacian P x|) / (b * d) := by
  have hdreal : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have h := sum_parity_symmetricClip_le_laplacian
    (permutationKernel cubeFlip)
    (permutationKernel_doublyStochastic cubeFlip (by simpa using ne_of_gt hdreal))
    fullParity P fullParity_sign
    (permutationKernel_bipartite cubeFlip fullParity fullParity_cubeFlip)
    b d hb hdreal
  simpa only [markovLaplacian_cube_eq hd] using h

/-- The perturbation form used for a globally separated output field.
The right-hand residual is an exact `L¹` bound; replacing it by `L²`
is a separate elementary norm comparison. -/
theorem cube_margin_parity_laplacian_bound {d : ℕ} (hd : 0 < d)
    (P z : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b)
    (hmargin : ∀ x, b ≤ |z x|) :
    |∑ x, fullParity x * binarySign (z x)| ≤
      (∑ x, |cubeLaplacian P x|) / (b * d) + (∑ x, |z x - P x|) / b := by
  let A : ClippingCube d → ℝ := fun x => fullParity x * binarySign (z x)
  let B : ClippingCube d → ℝ := fun x => fullParity x * symmetricClip b (P x)
  have hp (x : ClippingCube d) : |A x - B x| ≤ |z x - P x| / b := by
    dsimp [A, B]
    rw [← symmetricClip_eq_binarySign b (z x) hb (hmargin x), ← mul_sub, abs_mul]
    have hfabs : |fullParity x| = 1 := by
      rcases fullParity_sign x with h | h <;> simp [h]
    rw [hfabs, one_mul]
    exact symmetricClip_lipschitz b (z x) (P x) hb
  have hs : |(∑ x, A x) - ∑ x, B x| ≤ (∑ x, |z x - P x|) / b := by
    rw [← Finset.sum_sub_distrib]
    calc
      |∑ x, (A x - B x)| ≤ ∑ x, |A x - B x| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ x, |z x - P x| / b := Finset.sum_le_sum (fun x hx => hp x)
      _ = (∑ x, |z x - P x|) / b := (Finset.sum_div _ _ _).symm
  have hbase := cube_clipped_parity_laplacian_bound hd P b hb
  change |∑ x, A x| ≤ _
  calc
    |∑ x, A x| = |(∑ x, B x) + ((∑ x, A x) - ∑ x, B x)| := by congr 1; ring
    _ ≤ |∑ x, B x| + |(∑ x, A x) - ∑ x, B x| := abs_add_le _ _
    _ ≤ (∑ x, |cubeLaplacian P x|) / (b * d) + (∑ x, |z x - P x|) / b :=
      add_le_add hbase hs

def uniformCubeMean {d : ℕ} (P : ClippingCube d → ℝ) : ℝ :=
  (∑ x, P x) / Fintype.card (ClippingCube d)

/-- The paper's inequality in uniform-expectation notation. -/
theorem cube_clipped_parity_mean_bound {d : ℕ} (hd : 0 < d)
    (P : ClippingCube d → ℝ) (b : ℝ) (hb : 0 < b) :
    |uniformCubeMean (fun x => fullParity x * symmetricClip b (P x))| ≤
      uniformCubeMean (fun x => |cubeLaplacian P x|) / (b * d) := by
  have h := div_le_div_of_nonneg_right
    (cube_clipped_parity_laplacian_bound hd P b hb)
    (Nat.cast_nonneg (Fintype.card (ClippingCube d)) :
      (0 : ℝ) ≤ Fintype.card (ClippingCube d))
  have hc : (0 : ℝ) ≤ Fintype.card (ClippingCube d) := Nat.cast_nonneg _
  simpa only [uniformCubeMean, abs_div, abs_of_nonneg hc,
    div_div, mul_comm] using h

end Cube

end NeuralGeneralization
