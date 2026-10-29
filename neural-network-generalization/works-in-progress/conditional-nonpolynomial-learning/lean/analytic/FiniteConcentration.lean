import Mathlib.Analysis.SpecialFunctions.Trigonometric.Series
import Mathlib.Analysis.Convex.SpecificFunctions.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.NormNum

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch
namespace FiniteProbability

variable {I : Type*} [Fintype I]

/-- Finite weighted expectation. -/
def avg (p f : I → ℝ) : ℝ := ∑ i, p i * f i

lemma avg_const (p : I → ℝ) (hp : ∑ i, p i = 1) (c : ℝ) :
    avg p (fun _ ↦ c) = c := by simp [avg, ← Finset.sum_mul, hp]

lemma avg_mono (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) {f g : I → ℝ}
    (h : ∀ i, f i ≤ g i) : avg p f ≤ avg p g :=
  Finset.sum_le_sum fun i _ ↦ mul_le_mul_of_nonneg_left (h i) (hp0 i)

lemma avg_add (p f g : I → ℝ) : avg p (fun i ↦ f i + g i) = avg p f + avg p g := by
  simp [avg, mul_add, Finset.sum_add_distrib]

lemma avg_sub (p f g : I → ℝ) : avg p (fun i ↦ f i - g i) = avg p f - avg p g := by
  simp [avg, mul_sub, Finset.sum_sub_distrib]

lemma avg_mul_const (p f : I → ℝ) (c : ℝ) :
    avg p (fun i ↦ f i * c) = avg p f * c := by simp [avg, Finset.sum_mul, mul_assoc]

lemma avg_const_mul (p f : I → ℝ) (c : ℝ) :
    avg p (fun i ↦ c * f i) = c * avg p f := by
  simp only [avg, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

lemma abs_avg_le (p f : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) :
    |avg p f| ≤ avg p (fun i ↦ |f i|) := by
  calc
    |avg p f| ≤ ∑ i, |p i * f i| := Finset.abs_sum_le_sum_abs _ _
    _ = avg p (fun i ↦ |f i|) := by simp [avg, abs_mul, abs_of_nonneg, hp0]

/-- A finite-distribution exponential-moment bound. This deliberately uses a
loose constant, permitting an elementary proof from convexity and cosh. -/
theorem avg_exp_le_of_centered_bounded (p f : I → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1) (hf0 : avg p f = 0)
    (c : ℝ) (hc : 0 ≤ c) (hf : ∀ i, |f i| ≤ c) (t : ℝ) :
    avg p (fun i ↦ Real.exp (t * f i)) ≤ Real.exp (t ^ 2 * c ^ 2 / 2) := by
  rcases eq_or_lt_of_le hc with rfl | hc
  · have hz : ∀ i, f i = 0 := fun i ↦ abs_eq_zero.mp (le_antisymm (hf i) (abs_nonneg _))
    simp [hz, avg_const p hp]
  have hpoint (i : I) :
      Real.exp (t * f i) ≤
        ((c - f i) / (2 * c)) * Real.exp (-t * c) +
        ((c + f i) / (2 * c)) * Real.exp (t * c) := by
    have hlo := (abs_le.mp (hf i)).1
    have hhi := (abs_le.mp (hf i)).2
    have ha : 0 ≤ (c - f i) / (2 * c) := div_nonneg (by linarith) (by positivity)
    have hb : 0 ≤ (c + f i) / (2 * c) := div_nonneg (by linarith) (by positivity)
    have hab : (c - f i) / (2 * c) + (c + f i) / (2 * c) = 1 := by
      field_simp
      ring
    have harg : ((c - f i) / (2 * c)) * (-t * c) +
        ((c + f i) / (2 * c)) * (t * c) = t * f i := by
      field_simp
      ring
    have h := convexOn_exp.2 (Set.mem_univ (-t * c)) (Set.mem_univ (t * c)) ha hb hab
    simpa only [smul_eq_mul, harg] using h
  apply (avg_mono p hp0 hpoint).trans
  have hminus : avg p (fun i ↦ (c - f i) / (2 * c)) = 1 / 2 := by
    simp_rw [div_eq_mul_inv]
    rw [avg_mul_const, avg_sub, avg_const p hp, hf0]
    field_simp
    ring
  have hplus : avg p (fun i ↦ (c + f i) / (2 * c)) = 1 / 2 := by
    simp_rw [div_eq_mul_inv]
    rw [avg_mul_const, avg_add, avg_const p hp, hf0]
    field_simp
    ring
  rw [avg_add, avg_mul_const, avg_mul_const, hminus, hplus]
  calc
    1 / 2 * Real.exp (-t * c) + 1 / 2 * Real.exp (t * c) = Real.cosh (t * c) := by
      rw [show -t * c = -(t * c) by ring, Real.cosh_eq]
      ring
    _ ≤ Real.exp ((t * c) ^ 2 / 2) := Real.cosh_le_exp_half_sq _
    _ = Real.exp (t ^ 2 * c ^ 2 / 2) := by rw [mul_pow]

lemma abs_sub_avg_le (p f : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (c : ℝ) (hf : ∀ i j, |f i - f j| ≤ c) (i : I) : |f i - avg p f| ≤ c := by
  calc
    |f i - avg p f| = |avg p (fun j ↦ f i - f j)| := by rw [avg_sub, avg_const p hp]
    _ ≤ avg p (fun j ↦ |f i - f j|) := abs_avg_le _ _ hp0
    _ ≤ avg p (fun _ ↦ c) := avg_mono _ hp0 (hf i)
    _ = c := avg_const p hp c

theorem avg_exp_sub_avg_le (p f : I → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (c : ℝ) (hc : 0 ≤ c) (hf : ∀ i j, |f i - f j| ≤ c) (t : ℝ) :
    avg p (fun i ↦ Real.exp (t * (f i - avg p f))) ≤
      Real.exp (t ^ 2 * c ^ 2 / 2) := by
  apply avg_exp_le_of_centered_bounded p (fun i ↦ f i - avg p f) hp0 hp _ c hc _ t
  · rw [avg_sub, avg_const p hp, sub_self]
  · exact abs_sub_avg_le p f hp0 hp c hf

/-- Expectation on m independent draws from a finite distribution. The recursive
finite-sum definition makes independence explicit without conditional measures. -/
def sampleAvg (p : I → ℝ) : (m : ℕ) → ((Fin m → I) → ℝ) → ℝ
  | 0, f => f Fin.elim0
  | m + 1, f => sampleAvg p m (fun s ↦ avg p (fun i ↦ f (Fin.cons i s)))

lemma sampleAvg_const (p : I → ℝ) (hp : ∑ i, p i = 1) (m : ℕ) (c : ℝ) :
    sampleAvg p m (fun _ ↦ c) = c := by
  induction m with
  | zero => rfl
  | succ m ih => simpa only [sampleAvg, avg_const p hp] using ih

lemma sampleAvg_mono (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (m : ℕ)
    {f g : (Fin m → I) → ℝ} (h : ∀ s, f s ≤ g s) : sampleAvg p m f ≤ sampleAvg p m g := by
  induction m with
  | zero => exact h Fin.elim0
  | succ m ih => exact ih (fun s ↦ avg_mono p hp0 (fun i ↦ h (Fin.cons i s)))

lemma sampleAvg_add (p : I → ℝ) (m : ℕ) (f g : (Fin m → I) → ℝ) :
    sampleAvg p m (fun s ↦ f s + g s) = sampleAvg p m f + sampleAvg p m g := by
  induction m with
  | zero => rfl
  | succ m ih => simpa only [sampleAvg, avg_add] using ih _ _

lemma sampleAvg_mul_const (p : I → ℝ) (m : ℕ) (f : (Fin m → I) → ℝ) (c : ℝ) :
    sampleAvg p m (fun s ↦ f s * c) = sampleAvg p m f * c := by
  induction m with
  | zero => rfl
  | succ m ih => simpa only [sampleAvg, avg_mul_const] using ih _

lemma sampleAvg_const_mul (p : I → ℝ) (m : ℕ) (f : (Fin m → I) → ℝ) (c : ℝ) :
    sampleAvg p m (fun s ↦ c * f s) = c * sampleAvg p m f := by
  simpa only [mul_comm c] using sampleAvg_mul_const p m f c


lemma sampleAvg_sub (p : I → ℝ) (m : ℕ) (f g : (Fin m → I) → ℝ) :
    sampleAvg p m (fun s ↦ f s - g s) = sampleAvg p m f - sampleAvg p m g := by
  induction m with
  | zero => rfl
  | succ m ih => simpa only [sampleAvg, avg_sub] using ih _ _

lemma sampleAvg_finset_sum {K : Type*} (p : I → ℝ) (m : ℕ)
    (T : Finset K) (f : K → (Fin m → I) → ℝ) :
    sampleAvg p m (fun s ↦ ∑ k ∈ T, f k s) = ∑ k ∈ T, sampleAvg p m (f k) := by
  classical
  induction T using Finset.induction_on with
  | empty =>
    induction m with
    | zero => simp [sampleAvg]
    | succ m ih => simpa [sampleAvg, avg] using ih
  | @insert k T hk ih => simp [hk, sampleAvg_add, ih]

lemma sampleAvg_nonneg (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (m : ℕ) (f : (Fin m → I) → ℝ) (hf : ∀ s, 0 ≤ f s) :
    0 ≤ sampleAvg p m f := by
  simpa only [sampleAvg_const p hp] using sampleAvg_mono p hp0 m hf

lemma sq_sampleAvg_le (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (m : ℕ) (f : (Fin m → I) → ℝ) :
    (sampleAvg p m f) ^ 2 ≤ sampleAvg p m (fun s ↦ f s ^ 2) := by
  have hnonneg := sampleAvg_nonneg p hp0 hp m
    (fun s ↦ (f s - sampleAvg p m f) ^ 2) (fun s ↦ sq_nonneg _)
  have heq (s : Fin m → I) : (f s - sampleAvg p m f) ^ 2 =
      f s ^ 2 - 2 * sampleAvg p m f * f s + (sampleAvg p m f) ^ 2 := by ring
  simp_rw [heq] at hnonneg
  rw [sampleAvg_add, sampleAvg_sub, sampleAvg_const_mul, sampleAvg_const p hp] at hnonneg
  nlinarith

/-- The value changes by at most c when any single sample coordinate is changed. -/
def BoundedDifferences : (m : ℕ) → ((Fin m → I) → ℝ) → ℝ → Prop
  | 0, _, _ => True
  | m + 1, f, c =>
      (∀ s i j, |f (Fin.cons i s) - f (Fin.cons j s)| ≤ c) ∧
      ∀ i, BoundedDifferences m (fun s ↦ f (Fin.cons i s)) c

lemma boundedDifferences_avg (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (m : ℕ) (f : I → (Fin m → I) → ℝ) (c : ℝ)
    (hf : ∀ i, BoundedDifferences m (f i) c) :
    BoundedDifferences m (fun s ↦ avg p (fun i ↦ f i s)) c := by
  induction m with
  | zero => trivial
  | succ m ih =>
    constructor
    · intro s a b
      rw [← avg_sub]
      apply (abs_avg_le p _ hp0).trans
      exact (avg_mono p hp0 (fun i ↦ (hf i).1 s a b)).trans_eq (avg_const p hp c)
    · intro a
      exact ih (fun i s ↦ f i (Fin.cons a s)) (fun i ↦ (hf i).2 a)

/-- Finite bounded-differences exponential bound, with a deliberately loose
constant. This is a genuine concentration estimate, not a concentration hypothesis. -/
theorem sampleAvg_exp_sub_avg_le (p : I → ℝ)
    (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1) (m : ℕ)
    (f : (Fin m → I) → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hf : BoundedDifferences m f c) (t : ℝ) :
    sampleAvg p m (fun s ↦ Real.exp (t * (f s - sampleAvg p m f))) ≤
      Real.exp (t ^ 2 * (m : ℝ) * c ^ 2 / 2) := by
  induction m with
  | zero => simp [sampleAvg]
  | succ m ih =>
    let g : (Fin m → I) → ℝ := fun s ↦ avg p (fun i ↦ f (Fin.cons i s))
    have hg : BoundedDifferences m g c := boundedDifferences_avg p hp0 hp m _ c hf.2
    have hpoint (s : Fin m → I) :
        avg p (fun i ↦ Real.exp (t * (f (Fin.cons i s) - sampleAvg p m g))) ≤
          Real.exp (t ^ 2 * c ^ 2 / 2) * Real.exp (t * (g s - sampleAvg p m g)) := by
      have heq (i : I) : t * (f (Fin.cons i s) - sampleAvg p m g) =
          t * (f (Fin.cons i s) - g s) + t * (g s - sampleAvg p m g) := by ring
      simp_rw [heq, Real.exp_add]
      rw [avg_mul_const]
      exact mul_le_mul_of_nonneg_right
        (avg_exp_sub_avg_le p (fun i ↦ f (Fin.cons i s)) hp0 hp c hc (hf.1 s) t)
        (Real.exp_nonneg _)
    change sampleAvg p m (fun s ↦ avg p
      (fun i ↦ Real.exp (t * (f (Fin.cons i s) - sampleAvg p m g)))) ≤ _
    apply (sampleAvg_mono p hp0 m hpoint).trans
    rw [sampleAvg_const_mul]
    calc
      _ ≤ Real.exp (t ^ 2 * c ^ 2 / 2) * Real.exp (t ^ 2 * (m : ℝ) * c ^ 2 / 2) :=
        mul_le_mul_of_nonneg_left (ih g hg) (Real.exp_nonneg _)
      _ = Real.exp (t ^ 2 * ((m + 1 : ℕ) : ℝ) * c ^ 2 / 2) := by
        rw [← Real.exp_add]
        congr 1
        push_cast
        ring

/-- Simultaneous finite-family extraction from the proved bounded-differences
estimate. There is no independence or concentration conclusion in the hypotheses. -/
theorem exists_sample_all_lt {K : Type*} [Fintype K]
    (p : I → ℝ) (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (m : ℕ) (f : K → (Fin m → I) → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hf : ∀ k, BoundedDifferences m (f k) c) (t u : ℝ) (ht : 0 ≤ t)
    (hgap : (Fintype.card K : ℝ) * Real.exp (t ^ 2 * (m : ℝ) * c ^ 2 / 2) <
      Real.exp (t * u)) :
    ∃ s : Fin m → I, ∀ k, f k s < sampleAvg p m (f k) + u := by
  classical
  by_contra h
  push Not at h
  let G : (Fin m → I) → ℝ := fun s ↦
    ∑ k, Real.exp (t * (f k s - sampleAvg p m (f k)))
  have hlo : Real.exp (t * u) ≤ sampleAvg p m G := by
    rw [← sampleAvg_const p hp m (Real.exp (t * u))]
    apply sampleAvg_mono p hp0
    intro s
    obtain ⟨k, hk⟩ := h s
    apply (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (by linarith : u ≤
      f k s - sampleAvg p m (f k)) ht)).trans
    dsimp [G]
    exact Finset.single_le_sum
      (f := fun j : K ↦ Real.exp (t * (f j s - sampleAvg p m (f j))))
      (fun j _ ↦ Real.exp_nonneg _) (Finset.mem_univ k)
  have hhi : sampleAvg p m G ≤
      (Fintype.card K : ℝ) * Real.exp (t ^ 2 * (m : ℝ) * c ^ 2 / 2) := by
    dsimp [G]
    rw [sampleAvg_finset_sum]
    calc
      _ ≤ ∑ _ : K, Real.exp (t ^ 2 * (m : ℝ) * c ^ 2 / 2) :=
        Finset.sum_le_sum fun k _ ↦ sampleAvg_exp_sub_avg_le p hp0 hp m (f k) c hc (hf k) t
      _ = _ := by simp
  linarith

#print axioms sampleAvg_exp_sub_avg_le
#print axioms exists_sample_all_lt

end FiniteProbability
end BooleanDepthResearch
