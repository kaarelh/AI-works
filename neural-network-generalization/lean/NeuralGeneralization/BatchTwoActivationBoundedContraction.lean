import NeuralGeneralization.BatchTwoActivationContraction

/-!
# Convex contraction for arbitrary bounded classes

The class index need not be countable or finite. Only the sign probability
space is finite, so all expectations below are literal finite averages.
This discharges the separability/supremum issue in the contraction step of
the unbounded-activation paper, rather than postulating that step.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoActivation
open SquaredSampling

def processSup {U : Type*} (f : U → ℝ) : ℝ := sSup (Set.range f)

theorem processSup_le {U : Type*} [Nonempty U] (f : U → ℝ) {B : ℝ}
    (h : ∀ u, f u ≤ B) : processSup f ≤ B := by
  apply csSup_le (Set.range_nonempty _)
  rintro _ ⟨u, rfl⟩
  exact h u

theorem le_processSup {U : Type*} (f : U → ℝ) {B : ℝ}
    (h : ∀ u, f u ≤ B) (u : U) : f u ≤ processSup f := by
  apply le_csSup
  · exact ⟨B, by rintro _ ⟨u, rfl⟩; exact h u⟩
  · exact ⟨u, rfl⟩

theorem processSup_add_le {U : Type*} [Nonempty U] (f g : U → ℝ) {B : ℝ}
    (h : ∀ u v, f u + g v ≤ B) : processSup f + processSup g ≤ B := by
  have hg (u : U) : processSup g ≤ B - f u :=
    processSup_le g (fun v => by linarith [h u v])
  have hf : processSup f ≤ B - processSup g :=
    processSup_le f (fun u => by linarith [hg u])
  linarith

/-- The one-coordinate convex contraction inequality for an arbitrary
bounded function class. No maximum-attainment assumption is used. -/
theorem bounded_coordinate_convex_contraction {U : Type*} [Nonempty U]
    (G : ℝ → ℝ) (hG : ConvexOn ℝ Set.univ G) (hmono : Monotone G)
    (φ : ℝ → ℝ) (hzero : φ 0 = 0)
    (hLip : ∀ x y, |φ x - φ y| ≤ |x-y|) (a t : U → ℝ)
    {A B : ℝ} (ha : ∀ u, a u ≤ A) (ht : ∀ u, |t u| ≤ B) :
    G (processSup (fun u => a u + φ (t u))) +
        G (processSup (fun u => a u - φ (t u))) ≤
      G (processSup (fun u => a u + t u)) +
        G (processSup (fun u => a u - t u)) := by
  let c := processSup (fun u => a u + t u)
  let d := processSup (fun u => a u - t u)
  have hc (u : U) : a u + t u ≤ c := by
    apply le_processSup (fun u => a u + t u) (B := A+B)
    intro v
    linarith [ha v, ht v, le_abs_self (t v)]
  have hd (u : U) : a u - t u ≤ d := by
    apply le_processSup (fun u => a u - t u) (B := A+B)
    intro v
    linarith [ha v, ht v, neg_le_abs (t v)]
  have hpoint (u : U) : a u + |t u| ≤ max c d := by
    rcases le_total 0 (t u) with h | h
    · rw [abs_of_nonneg h]
      exact (hc u).trans (le_max_left _ _)
    · rw [abs_of_nonpos h]
      have := (hd u).trans (le_max_right c d)
      linarith
  have habs (u : U) : |φ (t u)| ≤ |t u| := by
    simpa only [hzero, sub_zero] using hLip (t u) 0
  have hp : processSup (fun u => a u + φ (t u)) ≤ max c d := by
    apply processSup_le
    intro u
    linarith [hpoint u, habs u, le_abs_self (φ (t u))]
  have hm : processSup (fun u => a u - φ (t u)) ≤ max c d := by
    apply processSup_le
    intro u
    linarith [hpoint u, habs u, neg_le_abs (φ (t u))]
  have hsum : processSup (fun u => a u + φ (t u)) +
      processSup (fun u => a u - φ (t u)) ≤ c+d := by
    apply processSup_add_le
    intro u v
    have hdiff := (le_abs_self (φ (t u) - φ (t v))).trans (hLip (t u) (t v))
    rcases le_total (t v) (t u) with h | h
    · rw [abs_of_nonneg (sub_nonneg.mpr h)] at hdiff
      linarith [hc u, hd v]
    · rw [abs_of_nonpos (sub_nonpos.mpr h)] at hdiff
      linarith [hd u, hc v]
  exact convex_monotone_pair G hG hmono hp hm hsum

theorem signed_sum_abs_le {n : ℕ} (t : Fin n → ℝ) {B : ℝ}
    (ht : ∀ k, |t k| ≤ B) (ε : Fin n → Bool) :
    |∑ k, cubeCoordinateSign (ε k) * t k| ≤ (n : ℝ) * B := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ _k : Fin n, B := by
      apply Finset.sum_le_sum
      intro k _
      have hs : |cubeCoordinateSign (ε k)| = 1 := by
        cases ε k <;> norm_num [cubeCoordinateSign]
      simpa only [abs_mul, hs, one_mul] using ht k
    _ = _ := by simp

/-- Full convex contraction for an arbitrary uniformly bounded array
class and the actual independent uniform signs. -/
theorem bounded_rademacher_convex_contraction {U : Type*} [Nonempty U]
    (G : ℝ → ℝ) (hG : ConvexOn ℝ Set.univ G) (hmono : Monotone G)
    (n : ℕ) (φ : Fin n → ℝ → ℝ) (hzero : ∀ k, φ k 0 = 0)
    (hLip : ∀ k x y, |φ k x - φ k y| ≤ |x-y|)
    (a : U → ℝ) (t : U → Fin n → ℝ) {A B : ℝ}
    (ha : ∀ u, a u ≤ A) (ht : ∀ u k, |t u k| ≤ B) :
    finiteMean (fun ε : Fin n → Bool =>
      G (processSup (fun u => a u + ∑ k, cubeCoordinateSign (ε k) * φ k (t u k)))) ≤
    finiteMean (fun ε : Fin n → Bool =>
      G (processSup (fun u => a u + ∑ k, cubeCoordinateSign (ε k) * t u k))) := by
  induction n generalizing a A with
  | zero => simp
  | succ n ih =>
    rw [finiteMean_sign_succ, finiteMean_sign_succ]
    simp only [Fin.sum_univ_succ, Fin.cons_zero, Fin.cons_succ]
    let tail : (Fin n → Bool) → U → ℝ := fun ε u =>
      ∑ k, cubeCoordinateSign (ε k) * t u k.succ
    have hab (b : Bool) (u : U) :
        a u + cubeCoordinateSign b * φ 0 (t u 0) ≤ A+B := by
      have hf : |φ 0 (t u 0)| ≤ B := by
        have h := hLip 0 (t u 0) 0
        simp only [hzero, sub_zero] at h
        exact h.trans (ht u 0)
      cases b <;> simp only [cubeCoordinateSign, Bool.false_eq_true,
        ↓reduceIte, neg_one_mul, one_mul] <;>
        linarith [ha u, le_abs_self (φ 0 (t u 0)), neg_le_abs (φ 0 (t u 0))]
    have htail := finiteMean_mono (fun b : Bool =>
      ih (fun k => φ k.succ) (fun k => hzero k.succ)
        (fun k => hLip k.succ)
        (fun u => a u + cubeCoordinateSign b * φ 0 (t u 0))
        (fun u k => t u k.succ) (hab b) (fun u k => ht u k.succ))
    simp only [add_assoc] at htail
    apply htail.trans
    rw [finiteMean_comm, finiteMean_comm (fun (b : Bool) (ε : Fin n → Bool) =>
      G (processSup (fun u => a u + (cubeCoordinateSign b * t u 0 + tail ε u))))]
    apply finiteMean_mono
    intro ε
    have htailbound (u : U) : a u + tail ε u ≤ A + (n : ℝ) * B := by
      have h := signed_sum_abs_le (fun k => t u k.succ) (fun k => ht u k.succ) ε
      change |tail ε u| ≤ _ at h
      linarith [ha u, le_abs_self (tail ε u)]
    have hc := bounded_coordinate_convex_contraction G hG hmono (φ 0)
      (hzero 0) (hLip 0) (fun u => a u + tail ε u) (fun u => t u 0)
      htailbound (fun u => ht u 0)
    change finiteMean (fun b : Bool =>
      G (processSup (fun u => a u + (cubeCoordinateSign b * φ 0 (t u 0) + tail ε u)))) ≤
      finiteMean (fun b : Bool =>
      G (processSup (fun u => a u + (cubeCoordinateSign b * t u 0 + tail ε u))))
    have rearrange (v : ℝ) (u : U) : a u + (v + tail ε u) = (a u + tail ε u) + v := by ring
    simp only [finiteMean, Fintype.sum_bool, cubeCoordinateSign,
      Bool.false_eq_true, ↓reduceIte, neg_one_mul, one_mul]
    simp only [rearrange, ← sub_eq_add_neg]
    change (_ + _) / 2 ≤ (_ + _) / 2
    exact div_le_div_of_nonneg_right (by linarith [hc]) (by norm_num)

theorem envelope_eq_max_processSup {U : Type*} [Nonempty U]
    (f : U → ℝ) {B : ℝ} (hf : ∀ u, |f u| ≤ B) :
    envelope f = max (processSup f) (processSup (fun u => -f u)) := by
  apply le_antisymm
  · apply envelope_le
    intro u
    have hp := le_processSup f (fun v => (le_abs_self (f v)).trans (hf v)) u
    have hm := le_processSup (fun v => -f v)
      (fun v => (neg_le_abs (f v)).trans (hf v)) u
    rw [abs_le]
    constructor
    · have := hm.trans (le_max_right (processSup f) _)
      linarith
    · exact hp.trans (le_max_left _ _)
  · apply max_le
    · apply processSup_le
      intro u
      exact (le_abs_self (f u)).trans (le_envelope f hf u)
    · apply processSup_le
      intro u
      exact (neg_le_abs (f u)).trans (le_envelope f hf u)

theorem convexOn_exp_mul (a : ℝ) :
    ConvexOn ℝ Set.univ (fun x : ℝ => Real.exp (a*x)) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ p q hp hq hpq
  have h := convexOn_exp.2 (Set.mem_univ (a*x)) (Set.mem_univ (a*y)) hp hq hpq
  simp only [smul_eq_mul] at h ⊢
  convert h using 1 <;> congr 1 <;> ring

/-- Exponential Rademacher contraction with an absolute supremum. This is
the factor-two peeling inequality used at each hidden layer in both papers. -/
theorem bounded_rademacher_exp_contraction {U : Type*} [Nonempty U]
    (n : ℕ) (φ : Fin n → ℝ → ℝ) (hzero : ∀ k, φ k 0 = 0)
    (hLip : ∀ k x y, |φ k x - φ k y| ≤ |x-y|)
    (t : U → Fin n → ℝ) {B : ℝ} (ht : ∀ u k, |t u k| ≤ B)
    (a : ℝ) (ha : 0 ≤ a) :
    finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * envelope (fun u => ∑ k, cubeCoordinateSign (ε k) * φ k (t u k)))) ≤
    2 * finiteMean (fun ε : Fin n → Bool =>
      Real.exp (a * envelope (fun u => ∑ k, cubeCoordinateSign (ε k) * t u k))) := by
  let F : (Fin n → Bool) → U → ℝ := fun ε u =>
    ∑ k, cubeCoordinateSign (ε k) * φ k (t u k)
  let X : (Fin n → Bool) → U → ℝ := fun ε u =>
    ∑ k, cubeCoordinateSign (ε k) * t u k
  have hφbound (u : U) (k : Fin n) : |φ k (t u k)| ≤ B := by
    have h := hLip k (t u k) 0
    simp only [hzero, sub_zero] at h
    exact h.trans (ht u k)
  have hF (ε : Fin n → Bool) (u : U) : |F ε u| ≤ (n : ℝ)*B :=
    signed_sum_abs_le _ (hφbound u) ε
  have hX (ε : Fin n → Bool) (u : U) : |X ε u| ≤ (n : ℝ)*B :=
    signed_sum_abs_le _ (ht u) ε
  have hGmono : Monotone (fun x : ℝ => Real.exp (a*x)) := by
    intro x y hxy
    exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left hxy ha)
  have hp := bounded_rademacher_convex_contraction
    (fun x => Real.exp (a*x)) (convexOn_exp_mul a) hGmono n φ hzero hLip
    (fun _ : U => 0) t (A := 0) (fun _ => le_rfl) ht
  simp only [zero_add] at hp
  have hnegzero (k : Fin n) : -φ k 0 = 0 := by rw [hzero k, neg_zero]
  have hnegLip (k : Fin n) (x y : ℝ) : |-φ k x - -φ k y| ≤ |x-y| := by
    simpa only [neg_sub_neg, abs_sub_comm] using hLip k x y
  have hm := bounded_rademacher_convex_contraction
    (fun x => Real.exp (a*x)) (convexOn_exp_mul a) hGmono n
    (fun k x => -φ k x) hnegzero hnegLip (fun _ : U => 0) t
    (A := 0) (fun _ => le_rfl) ht
  simp only [zero_add, mul_neg, Finset.sum_neg_distrib] at hm
  have hpoint (ε : Fin n → Bool) :
      Real.exp (a * envelope (F ε)) ≤
        Real.exp (a * processSup (F ε)) + Real.exp (a * processSup (fun u => -F ε u)) := by
    rw [envelope_eq_max_processSup (F ε) (hF ε)]
    rcases le_total (processSup (fun u => -F ε u)) (processSup (F ε)) with h | h
    · rw [max_eq_left h]
      exact le_add_of_nonneg_right (Real.exp_pos _).le
    · rw [max_eq_right h]
      exact le_add_of_nonneg_left (Real.exp_pos _).le
  have hmax := finiteMean_mono hpoint
  rw [finiteMean_add] at hmax
  have hlinear := finiteMean_mono (fun ε : Fin n → Bool => hGmono
    (processSup_le (X ε) (fun u =>
      (le_abs_self (X ε u)).trans (le_envelope (X ε) (hX ε) u))))
  change finiteMean (fun ε => Real.exp (a * processSup (F ε))) ≤
    finiteMean (fun ε => Real.exp (a * processSup (X ε))) at hp
  change finiteMean (fun ε => Real.exp (a * processSup (fun u => -F ε u))) ≤
    finiteMean (fun ε => Real.exp (a * processSup (X ε))) at hm
  change finiteMean (fun ε => Real.exp (a * processSup (X ε))) ≤
    finiteMean (fun ε => Real.exp (a * envelope (X ε))) at hlinear
  change finiteMean (fun ε => Real.exp (a * envelope (F ε))) ≤
    2 * finiteMean (fun ε => Real.exp (a * envelope (X ε)))
  linarith

end NeuralGeneralization.BatchTwoActivation
