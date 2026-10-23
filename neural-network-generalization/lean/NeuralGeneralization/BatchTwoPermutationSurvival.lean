import NeuralGeneralization.FiniteSubsetSampling
import Mathlib.Data.Fintype.CardEmbedding
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

/-!
# Survival probabilities under sampling without replacement

The sample is an actual uniform injection, rather than an assumed sequence
of conditional probabilities. This module is a probability ingredient for
the online-mistake theorem; it does not assert a neural learning theorem.
-/

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoPermutation
open SquaredSampling

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- Injections whose values lie in `G` are precisely injections into `G`. -/
def goodEmbeddingEquiv (n : ℕ) (G : Finset X) :
    {s : Fin n ↪ X // ∀ i, s i ∈ G} ≃ (Fin n ↪ G) where
  toFun s := ⟨fun i => ⟨s.val i, s.property i⟩,
    fun i j h => s.val.injective (congrArg Subtype.val h)⟩
  invFun s := ⟨⟨fun i => (s i).val,
    fun i j h => s.injective (Subtype.ext h)⟩, fun i => (s i).property⟩
  left_inv s := by rfl
  right_inv s := by rfl

theorem goodEmbedding_card (n : ℕ) (G : Finset X) :
    Fintype.card {s : Fin n ↪ X // ∀ i, s i ∈ G} = G.card.descFactorial n := by
  rw [Fintype.card_congr (goodEmbeddingEquiv n G), Fintype.card_embedding_eq]
  simp

/-- Exact hypergeometric avoidance probability, including the zero case. -/
theorem embedding_survival_eq (n : ℕ) (G : Finset X) :
    finiteEvent (fun s : Fin n ↪ X => ∀ i, s i ∈ G) =
      (G.card.descFactorial n : ℝ) / (Fintype.card X).descFactorial n := by
  unfold finiteEvent finiteMean
  dsimp only
  have hsum : (∑ s : Fin n ↪ X, if ∀ i, s i ∈ G then (1 : ℝ) else 0) =
      (Fintype.card {s : Fin n ↪ X // ∀ i, s i ∈ G} : ℝ) := by
    rw [Fintype.card_subtype]
    simp
  calc
    _ = (∑ s : Fin n ↪ X, if ∀ i, s i ∈ G then (1 : ℝ) else 0) /
        Fintype.card (Fin n ↪ X) := by
      congr 1
      apply Finset.sum_congr rfl
      intro s _
      by_cases h : ∀ i, s i ∈ G <;> simp [h]
    _ = (Fintype.card {s : Fin n ↪ X // ∀ i, s i ∈ G} : ℝ) /
        Fintype.card (Fin n ↪ X) :=
      congrArg (fun v : ℝ => v / Fintype.card (Fin n ↪ X)) hsum
    _ = _ := by rw [goodEmbedding_card, Fintype.card_embedding_eq, Fintype.card_fin]

/-- Falling-factorial ratios are bounded by the corresponding IID ratio. -/
theorem descFactorial_ratio_le_pow {a b n : ℕ} (hab : a ≤ b) (hnb : n ≤ b) :
    (a.descFactorial n : ℝ) / b.descFactorial n ≤ ((a : ℝ) / b) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hnb' : n ≤ b := by omega
    have hnbstrict : n < b := by omega
    have hb : 0 < b := by omega
    have hbR : (0 : ℝ) < b := by exact_mod_cast hb
    have hbnR : (0 : ℝ) < (b - n : ℕ) := by exact_mod_cast Nat.sub_pos_of_lt hnbstrict
    by_cases hna : n ≤ a
    · have haR : (a : ℝ) ≤ b := by exact_mod_cast hab
      have hnR : (0 : ℝ) ≤ n := Nat.cast_nonneg n
      have hfactor : ((a - n : ℕ) : ℝ) / (b - n : ℕ) ≤ (a : ℝ) / b := by
        apply (div_le_div_iff₀ hbnR hbR).2
        rw [Nat.cast_sub hna, Nat.cast_sub hnb']
        nlinarith
      rw [Nat.descFactorial_succ, Nat.descFactorial_succ, Nat.cast_mul,
        Nat.cast_mul, mul_div_mul_comm, pow_succ']
      exact mul_le_mul hfactor (ih hnb') (by positivity) (by positivity)
    · have hzero : a.descFactorial (n + 1) = 0 :=
        Nat.descFactorial_eq_zero_iff_lt.mpr (by omega)
      rw [hzero, Nat.cast_zero, zero_div]
      positivity

theorem embedding_survival_le_iid (n : ℕ) (G : Finset X)
    (hn : n ≤ Fintype.card X) :
    finiteEvent (fun s : Fin n ↪ X => ∀ i, s i ∈ G) ≤
      ((G.card : ℝ) / Fintype.card X) ^ n := by
  rw [embedding_survival_eq]
  exact descFactorial_ratio_le_pow (Finset.card_le_univ G) hn

/-- Exponential form used in the finite-class union bound. -/
theorem embedding_survival_le_exp (n : ℕ) (G : Finset X)
    (hn : n ≤ Fintype.card X) [Nonempty X] :
    finiteEvent (fun s : Fin n ↪ X => ∀ i, s i ∈ G) ≤
      Real.exp (-(n : ℝ) * (1 - (G.card : ℝ) / Fintype.card X)) := by
  apply (embedding_survival_le_iid n G hn).trans
  have hg : (0 : ℝ) ≤ (G.card : ℝ) / Fintype.card X := by positivity
  have hbase : (G.card : ℝ) / Fintype.card X ≤
      Real.exp (-(1 - (G.card : ℝ) / Fintype.card X)) := by
    have h := Real.add_one_le_exp (-(1 - (G.card : ℝ) / Fintype.card X))
    linarith
  calc
    _ ≤ (Real.exp (-(1 - (G.card : ℝ) / Fintype.card X))) ^ n :=
      pow_le_pow_left₀ hg hbase n
    _ = _ := by rw [← Real.exp_nat_mul]; congr 1; ring

/-- Restricting a uniform permutation to a fixed injection produces the
uniform law on injections. This proves the prefix marginal directly. -/
theorem permutation_embedding_average {n : ℕ} (s : Fin n ↪ X)
    (F : (Fin n ↪ X) → ℝ) :
    finiteMean (fun π : Equiv.Perm X => F (s.trans π.toEmbedding)) =
      finiteMean F := by
  letI : Nonempty (Fin n ↪ X) := ⟨s⟩
  have hsame (t : Fin n ↪ X) :
      finiteMean (fun π : Equiv.Perm X => F (s.trans π.toEmbedding)) =
        finiteMean (fun π : Equiv.Perm X => F (t.trans π.toEmbedding)) := by
    obtain ⟨σ, hσ⟩ := Equiv.Perm.exists_extending_pair s t s.injective t.injective
    have he (π : Equiv.Perm X) : s.trans (π * σ).toEmbedding = t.trans π.toEmbedding := by
      ext i
      exact congrArg π (hσ i)
    have h := finiteMean_equiv (Equiv.mulRight σ)
      (fun π : Equiv.Perm X => F (s.trans π.toEmbedding))
    change finiteMean (fun π : Equiv.Perm X => F (s.trans (π * σ).toEmbedding)) = _ at h
    simp_rw [he] at h
    exact h.symm
  calc
    _ = finiteMean (fun t : Fin n ↪ X =>
        finiteMean (fun π : Equiv.Perm X => F (t.trans π.toEmbedding))) := by
      simp_rw [← hsame]
      rw [finiteMean_const]
    _ = finiteMean (fun π : Equiv.Perm X =>
        finiteMean (fun t : Fin n ↪ X => F (t.trans π.toEmbedding))) :=
      finiteMean_comm _
    _ = _ := by
      have he (π : Equiv.Perm X) :
          finiteMean (fun t : Fin n ↪ X => F (t.trans π.toEmbedding)) = finiteMean F := by
        exact finiteMean_equiv (Equiv.embeddingCongr (Equiv.refl (Fin n)) π) F
      simp_rw [he]
      rw [finiteMean_const]

theorem permutation_prefix_survival_le_exp {n : ℕ} (s : Fin n ↪ X)
    (G : Finset X) [Nonempty X] :
    finiteEvent (fun π : Equiv.Perm X => ∀ i, π (s i) ∈ G) ≤
      Real.exp (-(n : ℝ) * (1 - (G.card : ℝ) / Fintype.card X)) := by
  have he := permutation_embedding_average s
    (fun t : Fin n ↪ X => @ite ℝ (∀ i, t i ∈ G) (Classical.propDecidable _) 1 0)
  have hn : n ≤ Fintype.card X := by
    simpa only [Fintype.card_fin] using Fintype.card_le_of_injective s s.injective
  have h := embedding_survival_le_exp n G hn
  unfold finiteEvent at h ⊢
  exact he.trans_le h

end NeuralGeneralization.BatchTwoPermutation
