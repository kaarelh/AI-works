import NeuralGeneralization.ParitySquaredBalance
import Mathlib.Data.Fintype.EquivFin
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# Finite empirical-process symmetrization

The observations and signs have their literal finite uniform distributions;
the function class may be infinite or uncountable. Boundedness is used only
to justify real suprema. No symmetrization or chaining theorem is assumed.
-/

noncomputable section

namespace NeuralGeneralization.SquaredSampling

open scoped BigOperators

variable {U α β : Type*}

def finiteMean [Fintype α] (f : α → ℝ) : ℝ :=
  (∑ x, f x) / Fintype.card α

lemma finiteMean_mono [Fintype α] {f g : α → ℝ} (h : ∀ x, f x ≤ g x) :
    finiteMean f ≤ finiteMean g :=
  div_le_div_of_nonneg_right (Finset.sum_le_sum (fun x _ => h x)) (Nat.cast_nonneg _)

lemma finiteMean_nonneg [Fintype α] {f : α → ℝ} (h : ∀ x, 0 ≤ f x) :
    0 ≤ finiteMean f :=
  div_nonneg (Finset.sum_nonneg (fun x _ => h x)) (Nat.cast_nonneg _)

@[simp] lemma finiteMean_const [Fintype α] [Nonempty α] (c : ℝ) :
    finiteMean (fun _ : α => c) = c := by simp [finiteMean]

lemma finiteMean_add [Fintype α] (f g : α → ℝ) :
    finiteMean (fun x => f x + g x) = finiteMean f + finiteMean g := by
  simp [finiteMean, Finset.sum_add_distrib, add_div]

lemma finiteMean_sub [Fintype α] (f g : α → ℝ) :
    finiteMean (fun x => f x - g x) = finiteMean f - finiteMean g := by
  simp [finiteMean, Finset.sum_sub_distrib, sub_div]

lemma finiteMean_mul [Fintype α] (c : ℝ) (f : α → ℝ) :
    finiteMean (fun x => c * f x) = c * finiteMean f := by
  simp [finiteMean, ← Finset.mul_sum, mul_div_assoc]

lemma abs_finiteMean_le [Fintype α] (f : α → ℝ) :
    |finiteMean f| ≤ finiteMean (fun x => |f x|) := by
  unfold finiteMean
  rw [abs_div, abs_of_nonneg (Nat.cast_nonneg (Fintype.card α) : (0 : ℝ) ≤ Fintype.card α)]
  exact div_le_div_of_nonneg_right (Finset.abs_sum_le_sum_abs _ _) (Nat.cast_nonneg _)

lemma finiteMean_equiv [Fintype α] [Fintype β] (e : α ≃ β) (f : β → ℝ) :
    finiteMean (fun x => f (e x)) = finiteMean f := by
  unfold finiteMean
  rw [e.sum_comp, Fintype.card_congr e]

lemma finiteMean_prod [Fintype α] [Fintype β] (f : α × β → ℝ) :
    finiteMean f = finiteMean (fun x => finiteMean (fun y => f (x,y))) := by
  unfold finiteMean
  rw [Fintype.sum_prod_type, Fintype.card_prod, Nat.cast_mul]
  simp only [← Finset.sum_div, div_div]
  rw [mul_comm]

lemma finiteMean_comm [Fintype α] [Fintype β] (f : α → β → ℝ) :
    finiteMean (fun x => finiteMean (fun y => f x y)) =
      finiteMean (fun y => finiteMean (fun x => f x y)) := by
  unfold finiteMean
  simp only [← Finset.sum_div, div_div]
  rw [Finset.sum_comm, mul_comm]

lemma finiteMean_sum {ι : Type*} [Fintype ι] [Fintype α] (f : ι → α → ℝ) :
    finiteMean (fun x => ∑ i, f i x) = ∑ i, finiteMean (f i) := by
  unfold finiteMean
  rw [Finset.sum_comm, Finset.sum_div]

lemma finiteMean_pi_prod {ι : Type*} [Fintype ι] [DecidableEq ι] [Fintype α] (f : ι → α → ℝ) :
    finiteMean (fun s : ι → α => ∏ i, f i (s i)) = ∏ i, finiteMean (f i) := by
  unfold finiteMean
  rw [← Fintype.prod_sum, Finset.prod_div_distrib]
  simp only [Fintype.card_fun, Nat.cast_pow, Finset.prod_const, Finset.card_univ]

lemma finiteMean_pi_eval {ι : Type*} [Fintype ι] [DecidableEq ι] [Fintype α] [Nonempty α]
    (i : ι) (f : α → ℝ) :
    finiteMean (fun s : ι → α => f (s i)) = finiteMean f := by
  classical
  have h := finiteMean_pi_prod (fun j : ι => fun x : α => if j = i then f x else 1)
  have hprod (s : ι → α) : (∏ j, if j = i then f (s j) else (1 : ℝ)) = f (s i) := by simp
  have hmean (j : ι) : finiteMean (fun x : α => if j = i then f x else 1) =
      if j = i then finiteMean f else 1 := by
    by_cases hji : j = i <;> simp [hji]
  simp_rw [hprod, hmean] at h
  simpa using h

/-- The actual supremum of the absolute process over an arbitrary class. -/
def envelope (f : U → ℝ) : ℝ := sSup (Set.range (fun u => |f u|))

lemma le_envelope (f : U → ℝ) {B : ℝ} (hB : ∀ u, |f u| ≤ B) (u : U) :
    |f u| ≤ envelope f := by
  apply le_csSup
  · exact ⟨B, by rintro _ ⟨u, rfl⟩; exact hB u⟩
  · exact ⟨u, rfl⟩

lemma envelope_le [Nonempty U] (f : U → ℝ) {B : ℝ} (hB : ∀ u, |f u| ≤ B) :
    envelope f ≤ B := by
  apply csSup_le (Set.range_nonempty _)
  rintro _ ⟨u, rfl⟩
  exact hB u

lemma envelope_nonneg [Nonempty U] (f : U → ℝ) {B : ℝ} (hB : ∀ u, |f u| ≤ B) :
    0 ≤ envelope f := by
  obtain ⟨u⟩ := ‹Nonempty U›
  exact (abs_nonneg _).trans (le_envelope f hB u)

lemma envelope_sub_le [Nonempty U] (f g : U → ℝ) {B C : ℝ}
    (hf : ∀ u, |f u| ≤ B) (hg : ∀ u, |g u| ≤ C) :
    envelope (fun u => f u - g u) ≤ envelope f + envelope g := by
  apply envelope_le
  intro u
  exact (abs_sub _ _).trans (add_le_add (le_envelope f hf u) (le_envelope g hg u))

/-- Jensen's step with a literal independent ghost observation. -/
theorem finite_ghost_symmetrization [Fintype α] [Nonempty α] [Nonempty U]
    (X : α → U → ℝ) {B : ℝ} (hX : ∀ x u, |X x u| ≤ B) :
    finiteMean (fun x => envelope (fun u => X x u - finiteMean (fun y => X y u))) ≤
      finiteMean (fun x => finiteMean (fun y => envelope (fun u => X x u - X y u))) := by
  apply finiteMean_mono
  intro x
  apply envelope_le
  intro u
  have hrewrite : X x u - finiteMean (fun y => X y u) =
      finiteMean (fun y => X x u - X y u) := by
    rw [finiteMean_sub, finiteMean_const]
  rw [hrewrite]
  apply (abs_finiteMean_le _).trans
  apply finiteMean_mono
  intro y
  exact le_envelope (fun v => X x v - X y v)
    (fun v => (abs_sub _ _).trans (add_le_add (hX x v) (hX y v))) u

/-- Exact IID sample totals, before division by the sample size. -/
def sampleTotal {n : ℕ} (F : U → α → ℝ) (s : Fin n → α) (u : U) : ℝ :=
  ∑ i, F u (s i)

/-- Uniform independent signs are represented by the full Boolean cube. -/
def signedTotal {n : ℕ} (F : U → α → ℝ) (ε : Fin n → Bool)
    (s : Fin n → α) (u : U) : ℝ :=
  ∑ i, cubeCoordinateSign (ε i) * F u (s i)

lemma sampleTotal_abs_le {n : ℕ} (F : U → α → ℝ) {B : ℝ}
    (hF : ∀ u x, |F u x| ≤ B) (s : Fin n → α) (u : U) :
    |sampleTotal F s u| ≤ (n : ℝ) * B := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ _i : Fin n, B := Finset.sum_le_sum (fun i _ => hF u (s i))
    _ = _ := by simp

lemma signedTotal_abs_le {n : ℕ} (F : U → α → ℝ) {B : ℝ}
    (hF : ∀ u x, |F u x| ≤ B) (ε : Fin n → Bool) (s : Fin n → α) (u : U) :
    |signedTotal F ε s u| ≤ (n : ℝ) * B := by
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  calc
    _ ≤ ∑ _i : Fin n, B := by
      apply Finset.sum_le_sum
      intro i _
      have hsign : |cubeCoordinateSign (ε i)| = 1 := by cases ε i <;> norm_num [cubeCoordinateSign]
      rw [abs_mul, hsign, one_mul]
      exact hF u (s i)
    _ = _ := by simp

/-- Swap each independent sample/ghost coordinate whose sign is negative. -/
def signSwap {n : ℕ} (ε : Fin n → Bool) :
    ((Fin n → α) × (Fin n → α)) ≃ ((Fin n → α) × (Fin n → α)) where
  toFun p := (fun i => if ε i then p.1 i else p.2 i,
              fun i => if ε i then p.2 i else p.1 i)
  invFun p := (fun i => if ε i then p.1 i else p.2 i,
              fun i => if ε i then p.2 i else p.1 i)
  left_inv p := by
    apply Prod.ext <;> funext i <;> cases h : ε i <;> simp [h]
  right_inv p := by
    apply Prod.ext <;> funext i <;> cases h : ε i <;> simp [h]

lemma sampleTotal_signSwap {n : ℕ} (F : U → α → ℝ) (ε : Fin n → Bool)
    (p : (Fin n → α) × (Fin n → α)) (u : U) :
    sampleTotal F (signSwap ε p).1 u - sampleTotal F (signSwap ε p).2 u =
      signedTotal F ε p.1 u - signedTotal F ε p.2 u := by
  unfold sampleTotal signedTotal
  rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases h : ε i <;> simp [signSwap, h, cubeCoordinateSign]
  ring

/-- Exact Rademacher symmetrization for any uniformly bounded, potentially
uncountable function class on a finite domain. Both IID observations and
Rademacher signs use their actual uniform product laws. -/
theorem finite_rademacher_symmetrization [Fintype α] [Nonempty α] [Nonempty U]
    (n : ℕ) (F : U → α → ℝ) {B : ℝ} (hF : ∀ u x, |F u x| ≤ B) :
    finiteMean (fun s : Fin n → α =>
      envelope (fun u => sampleTotal F s u -
        finiteMean (fun t : Fin n → α => sampleTotal F t u))) ≤
      2 * finiteMean (fun ε : Fin n → Bool =>
        finiteMean (fun s : Fin n → α => envelope (signedTotal F ε s))) := by
  have hghost := finite_ghost_symmetrization (sampleTotal (n := n) F) (sampleTotal_abs_le F hF)
  have hsigned (ε : Fin n → Bool) :
      finiteMean (fun s : Fin n → α => finiteMean (fun t : Fin n → α =>
        envelope (fun u => sampleTotal F s u - sampleTotal F t u))) ≤
      2 * finiteMean (fun s : Fin n → α => envelope (signedTotal F ε s)) := by
    rw [← finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
      envelope (fun u => sampleTotal F p.1 u - sampleTotal F p.2 u))]
    rw [← finiteMean_equiv (signSwap ε) (fun p : (Fin n → α) × (Fin n → α) =>
      envelope (fun u => sampleTotal F p.1 u - sampleTotal F p.2 u))]
    simp_rw [sampleTotal_signSwap]
    have hsub (p : (Fin n → α) × (Fin n → α)) :=
      envelope_sub_le (signedTotal F ε p.1) (signedTotal F ε p.2)
        (signedTotal_abs_le F hF ε p.1) (signedTotal_abs_le F hF ε p.2)
    apply (finiteMean_mono hsub).trans_eq
    have hleft : finiteMean (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedTotal F ε p.1)) =
        finiteMean (fun s : Fin n → α => envelope (signedTotal F ε s)) := by
      rw [finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedTotal F ε p.1))]
      simp
    have hright : finiteMean (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedTotal F ε p.2)) =
        finiteMean (fun s : Fin n → α => envelope (signedTotal F ε s)) := by
      rw [finiteMean_prod (fun p : (Fin n → α) × (Fin n → α) =>
        envelope (signedTotal F ε p.2))]
      simp
    rw [finiteMean_add, hleft, hright]
    ring
  have havg := finiteMean_mono hsigned
  rw [finiteMean_const, finiteMean_mul] at havg
  exact hghost.trans havg


lemma finiteMean_sampleTotal [Fintype α] [Nonempty α] (n : ℕ)
    (F : U → α → ℝ) (u : U) :
    finiteMean (fun s : Fin n → α => sampleTotal F s u) =
      (n : ℝ) * finiteMean (F u) := by
  unfold sampleTotal
  rw [finiteMean_sum]
  simp_rw [finiteMean_pi_eval]
  simp

/-- The same symmetrization theorem centered at the literal population mean,
with no remaining ghost-sample expectation in its statement. -/
theorem finite_rademacher_symmetrization_centered [Fintype α] [Nonempty α] [Nonempty U]
    (n : ℕ) (F : U → α → ℝ) {B : ℝ} (hF : ∀ u x, |F u x| ≤ B) :
    finiteMean (fun s : Fin n → α =>
      envelope (fun u => sampleTotal F s u - (n : ℝ) * finiteMean (F u))) ≤
      2 * finiteMean (fun ε : Fin n → Bool =>
        finiteMean (fun s : Fin n → α => envelope (signedTotal F ε s))) := by
  simpa only [finiteMean_sampleTotal] using finite_rademacher_symmetrization n F hF

end NeuralGeneralization.SquaredSampling
