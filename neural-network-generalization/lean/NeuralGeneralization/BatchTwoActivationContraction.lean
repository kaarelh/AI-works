import NeuralGeneralization.FiniteProcessMax
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

/-!
# Convex contraction for finite activation classes

This is a proof component for the unified unbounded-activation manuscript.
It does not assert the manuscript's Bayesian learning theorem.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoActivation

open SquaredSampling

/-- A symmetric pair on a real interval is dominated by its endpoints for
every convex function. -/
theorem convex_pair_le_endpoints (G : ℝ → ℝ)
    (hG : ConvexOn ℝ Set.univ G) {a c d : ℝ} (hda : d ≤ a) (hac : a ≤ c) :
    G a + G (c + d - a) ≤ G c + G d := by
  by_cases hcd : c = d
  · have ha : a = d := by linarith
    simp [hcd, ha]
  have hdc : 0 < c - d := sub_pos.mpr (lt_of_le_of_ne (hda.trans hac) (Ne.symm hcd))
  let θ : ℝ := (a - d) / (c - d)
  have hθ : 0 ≤ θ := div_nonneg (by linarith) hdc.le
  have hθ1 : θ ≤ 1 := (div_le_one hdc).2 (by linarith)
  have h1θ : 0 ≤ 1 - θ := by linarith
  have hfirst : θ * c + (1 - θ) * d = a := by
    dsimp [θ]
    field_simp
    <;> ring
  have hsecond : (1 - θ) * c + θ * d = c + d - a := by
    dsimp [θ]
    field_simp
    <;> ring
  have h₁ := hG.2 (Set.mem_univ c) (Set.mem_univ d) hθ h1θ (by ring : θ + (1-θ) = 1)
  have h₂ := hG.2 (Set.mem_univ c) (Set.mem_univ d) h1θ hθ (by ring : (1-θ) + θ = 1)
  simp only [smul_eq_mul, hfirst, hsecond] at h₁ h₂
  linarith

/-- Two-point weak majorization implies the convex-monotone comparison
needed in the one-coordinate Rademacher contraction argument. -/
theorem convex_monotone_pair (G : ℝ → ℝ) (hG : ConvexOn ℝ Set.univ G)
    (hmono : Monotone G) {a b c d : ℝ}
    (ha : a ≤ max c d) (hb : b ≤ max c d) (hsum : a + b ≤ c + d) :
    G a + G b ≤ G c + G d := by
  have ordered (c d : ℝ) (hdc : d ≤ c) (ha : a ≤ c) (hb : b ≤ c)
      (hs : a + b ≤ c + d) : G a + G b ≤ G c + G d := by
    by_cases had : a ≤ d
    · have h₁ := hmono had
      have h₂ := hmono hb
      linarith
    · have hb' : b ≤ c + d - a := by linarith
      have h₁ := hmono hb'
      have h₂ := convex_pair_le_endpoints G hG (le_of_not_ge had) ha
      linarith
  rcases le_total d c with h | h
  · exact ordered c d h (by simpa [max_eq_left h] using ha)
      (by simpa [max_eq_left h] using hb) hsum
  · have hs : a + b ≤ d + c := by linarith
    simpa [add_comm] using ordered d c h
      (by simpa [max_eq_right h] using ha)
      (by simpa [max_eq_right h] using hb) hs

/-- The literal maximum of a nonempty finite real family. -/
def finiteMax {ι : Type*} [Fintype ι] [Nonempty ι] (f : ι → ℝ) : ℝ :=
  f (Classical.choose (Finite.exists_max f))

theorem le_finiteMax {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → ℝ) (i : ι) : f i ≤ finiteMax f :=
  Classical.choose_spec (Finite.exists_max f) i

theorem finiteMax_le {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → ℝ) {b : ℝ} (h : ∀ i, f i ≤ b) : finiteMax f ≤ b :=
  h _

theorem exists_finiteMax {ι : Type*} [Fintype ι] [Nonempty ι]
    (f : ι → ℝ) : ∃ i, finiteMax f = f i :=
  ⟨_, rfl⟩

/-- One actual sign-coordinate contraction, before averaging the other
coordinates. The function class and its coordinate values are arbitrary. -/
theorem finite_coordinate_convex_contraction {ι : Type*} [Fintype ι] [Nonempty ι]
    (G : ℝ → ℝ) (hG : ConvexOn ℝ Set.univ G) (hmono : Monotone G)
    (φ : ℝ → ℝ) (hzero : φ 0 = 0)
    (hLip : ∀ x y, |φ x - φ y| ≤ |x-y|) (a t : ι → ℝ) :
    G (finiteMax (fun i => a i + φ (t i))) +
        G (finiteMax (fun i => a i - φ (t i))) ≤
      G (finiteMax (fun i => a i + t i)) +
        G (finiteMax (fun i => a i - t i)) := by
  let c := finiteMax (fun i => a i + t i)
  let d := finiteMax (fun i => a i - t i)
  have hpoint (i : ι) : a i + |t i| ≤ max c d := by
    have hp : a i + t i ≤ c := le_finiteMax (fun i => a i + t i) i
    have hm : a i - t i ≤ d := le_finiteMax (fun i => a i - t i) i
    rcases le_total 0 (t i) with hi | hi
    · rw [abs_of_nonneg hi]
      exact hp.trans (le_max_left _ _)
    · rw [abs_of_nonpos hi]
      have : a i + -t i = a i - t i := by ring
      rw [this]
      exact hm.trans (le_max_right _ _)
  have habs (i : ι) : |φ (t i)| ≤ |t i| := by
    simpa only [hzero, sub_zero] using hLip (t i) 0
  have hp : finiteMax (fun i => a i + φ (t i)) ≤ max c d := by
    apply finiteMax_le
    intro i
    have := hpoint i
    have := habs i
    linarith [le_abs_self (φ (t i))]
  have hm : finiteMax (fun i => a i - φ (t i)) ≤ max c d := by
    apply finiteMax_le
    intro i
    have := hpoint i
    have := habs i
    linarith [neg_le_abs (φ (t i))]
  have hsum : finiteMax (fun i => a i + φ (t i)) +
      finiteMax (fun i => a i - φ (t i)) ≤ c + d := by
    obtain ⟨i, hi⟩ := exists_finiteMax (fun i => a i + φ (t i))
    obtain ⟨j, hj⟩ := exists_finiteMax (fun i => a i - φ (t i))
    rw [hi, hj]
    have hdiff := (le_abs_self (φ (t i) - φ (t j))).trans (hLip (t i) (t j))
    rcases le_total (t j) (t i) with ht | ht
    · rw [abs_of_nonneg (sub_nonneg.mpr ht)] at hdiff
      have hi' : a i + t i ≤ c := le_finiteMax (fun i => a i + t i) i
      have hj' : a j - t j ≤ d := le_finiteMax (fun i => a i - t i) j
      linarith
    · rw [abs_of_nonpos (sub_nonpos.mpr ht)] at hdiff
      have hi' : a i - t i ≤ d := le_finiteMax (fun i => a i - t i) i
      have hj' : a j + t j ≤ c := le_finiteMax (fun i => a i + t i) j
      linarith
  exact convex_monotone_pair G hG hmono hp hm hsum

/-- The exact finite product decomposition of the uniform sign law. -/
theorem finiteMean_sign_succ {n : ℕ} (F : (Fin (n+1) → Bool) → ℝ) :
    finiteMean F = finiteMean (fun b : Bool =>
      finiteMean (fun ε : Fin n → Bool => F (Fin.cons b ε))) := by
  let e : (Bool × (Fin n → Bool)) ≃ (Fin (n+1) → Bool) :=
    { toFun := fun p => Fin.cons p.1 p.2
      invFun := fun ε => (ε 0, fun i => ε i.succ)
      left_inv := by intro p; cases p; rfl
      right_inv := by
        intro ε
        funext i
        refine Fin.cases ?_ (fun j => ?_) i <;> rfl }
  rw [← finiteMean_equiv e F, finiteMean_prod]
  rfl

/-- Finite-class convex contraction under the actual uniform Rademacher
law, allowing a different scalar contraction at every observation. -/
theorem finite_rademacher_convex_contraction {ι : Type*} [Fintype ι] [Nonempty ι]
    (G : ℝ → ℝ) (hG : ConvexOn ℝ Set.univ G) (hmono : Monotone G)
    (n : ℕ) (φ : Fin n → ℝ → ℝ) (hzero : ∀ k, φ k 0 = 0)
    (hLip : ∀ k x y, |φ k x - φ k y| ≤ |x-y|)
    (a : ι → ℝ) (t : ι → Fin n → ℝ) :
    finiteMean (fun ε : Fin n → Bool =>
      G (finiteMax (fun i => a i + ∑ k, cubeCoordinateSign (ε k) * φ k (t i k)))) ≤
    finiteMean (fun ε : Fin n → Bool =>
      G (finiteMax (fun i => a i + ∑ k, cubeCoordinateSign (ε k) * t i k))) := by
  induction n generalizing a with
  | zero => simp
  | succ n ih =>
    rw [finiteMean_sign_succ, finiteMean_sign_succ]
    simp only [Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ]
    let tail : (Fin n → Bool) → ι → ℝ := fun ε i =>
      ∑ k, cubeCoordinateSign (ε k) * t i k.succ
    have htail := finiteMean_mono (fun b : Bool =>
      ih (fun k => φ k.succ) (fun k => hzero k.succ)
        (fun k => hLip k.succ)
        (fun i => a i + cubeCoordinateSign b * φ 0 (t i 0))
        (fun i k => t i k.succ))
    simp only [add_assoc] at htail
    apply htail.trans
    rw [finiteMean_comm, finiteMean_comm (fun (b : Bool) (ε : Fin n → Bool) =>
      G (finiteMax (fun i => a i + (cubeCoordinateSign b * t i 0 + tail ε i))))]
    apply finiteMean_mono
    intro ε
    have hc := finite_coordinate_convex_contraction G hG hmono (φ 0)
      (hzero 0) (hLip 0) (fun i => a i + tail ε i) (fun i => t i 0)
    change finiteMean (fun b : Bool =>
      G (finiteMax (fun i => a i + (cubeCoordinateSign b * φ 0 (t i 0) + tail ε i)))) ≤
      finiteMean (fun b : Bool =>
      G (finiteMax (fun i => a i + (cubeCoordinateSign b * t i 0 + tail ε i))))
    have rearrange (u : ℝ) (i : ι) : a i + (u + tail ε i) = (a i + tail ε i) + u := by ring
    simp only [finiteMean, Fintype.sum_bool, cubeCoordinateSign,
      Bool.false_eq_true, ↓reduceIte, neg_one_mul, one_mul]
    simp only [rearrange, ← sub_eq_add_neg]
    change (_ + _) / 2 ≤ (_ + _) / 2
    exact div_le_div_of_nonneg_right (by linarith [hc]) (by norm_num)

end NeuralGeneralization.BatchTwoActivation
