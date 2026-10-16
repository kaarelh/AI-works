import NeuralGeneralization.FiniteSubsetSampling
import NeuralGeneralization.FiniteIndependentMoments

/-! Exact finite IID collision bound, including both orders of each pair. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable
variable {V : Type*} [Fintype V] [Nonempty V] [DecidableEq V] {n : ℕ}

lemma iid_pair_collision_mean (i j : Fin n) (hij : i≠j) :
    finiteMean (fun s : Fin n → V => if s i=s j then (1:ℝ) else 0)=1/(Fintype.card V:ℝ) := by
  have he (s : Fin n → V) : (if s i=s j then (1:ℝ) else 0)=
      ∑ v : V, (if s i=v then (1:ℝ) else 0)*(if s j=v then 1 else 0) := by
    simp only [ite_mul, zero_mul, Finset.sum_ite_eq', Finset.mem_univ, if_true, one_mul]
    by_cases h : s i=s j
    · simp [h]
    · simp [h, Ne.symm h]
  simp_rw [he]
  rw [finiteMean_sum]
  have hp (v : V) : finiteMean (fun s : Fin n → V =>
      (if s i=v then (1:ℝ) else 0)*(if s j=v then 1 else 0)) = (1/(Fintype.card V:ℝ))^2 := by
    rw [finiteMean_pi_mul_eval i j hij (fun x : V => if x=v then (1:ℝ) else 0)
      (fun x : V => if x=v then (1:ℝ) else 0)]
    simp [finiteMean, pow_two]
  simp_rw [hp]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

def orderedCollisionPairs (s : Fin n → V) : Finset (Fin n × Fin n) :=
  Finset.univ.filter (fun ij => ij.1≠ij.2 ∧ s ij.1=s ij.2)

lemma orderedCollisionPairs_card (s : Fin n → V) :
    ((orderedCollisionPairs s).card:ℝ)=
      ∑ i : Fin n, ∑ j : Fin n, if i≠j ∧ s i=s j then (1:ℝ) else 0 := by
  simp only [orderedCollisionPairs, Finset.card_filter]
  push_cast
  rw [Fintype.sum_prod_type]

lemma orderedCollisionPairs_two_le (s : Fin n → V) (hs : ¬ Function.Injective s) :
    2 ≤ (orderedCollisionPairs s).card := by
  unfold Function.Injective at hs
  push Not at hs
  obtain ⟨i,j,he,hne⟩ := hs
  apply Nat.succ_le_iff.mpr
  apply Finset.one_lt_card.mpr
  refine ⟨(i,j), ?_, (j,i), ?_, ?_⟩
  · simp [orderedCollisionPairs, hne, he]
  · simp [orderedCollisionPairs, Ne.symm hne, he.symm]
  · intro hh
    exact hne (congrArg Prod.fst hh)

lemma orderedCollisionPairs_mean (hn : 0<n) :
    finiteMean (fun s : Fin n → V => ((orderedCollisionPairs s).card:ℝ)) =
      (n:ℝ)*((n:ℝ)-1)/(Fintype.card V:ℝ) := by
  simp_rw [orderedCollisionPairs_card]
  rw [finiteMean_sum]
  simp_rw [finiteMean_sum]
  have hp (i j : Fin n) : finiteMean (fun s : Fin n → V =>
      if i≠j ∧ s i=s j then (1:ℝ) else 0)=
        if i=j then 0 else 1/(Fintype.card V:ℝ) := by
    by_cases hij : i=j
    · simp [hij]
    · have hh := iid_pair_collision_mean (V := V) i j hij
      simpa [hij] using hh
  simp_rw [hp]
  have hsum (i : Fin n) : (∑ j : Fin n, if i=j then (0:ℝ) else 1/(Fintype.card V:ℝ)) =
      ((n:ℝ)-1)/(Fintype.card V:ℝ) := by
    have hfull : (∑ j : Fin n, (1/(Fintype.card V:ℝ))) =
        (∑ j : Fin n, if i=j then (0:ℝ) else 1/(Fintype.card V:ℝ))+1/(Fintype.card V:ℝ) := by
      have he (j : Fin n) : (1/(Fintype.card V:ℝ)) =
          (if i=j then (0:ℝ) else 1/(Fintype.card V:ℝ))+(if i=j then 1/(Fintype.card V:ℝ) else 0) := by
        split_ifs <;> ring
      conv_lhs => arg 2; ext j; rw [he j]
      rw [Finset.sum_add_distrib]
      simp
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at hfull
    rw [mul_one_div] at hfull
    rw [sub_div]
    linarith only [hfull]
  simp_rw [hsum]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  ring

/-- The exact classical birthday upper bound for literal uniform IID
sampling on an arbitrary finite nonempty set. -/
theorem iid_collision_probability (hn : 0<n) :
    finiteEvent (fun s : Fin n → V => ¬ Function.Injective s) ≤
      (n:ℝ)*((n:ℝ)-1)/(2*(Fintype.card V:ℝ)) := by
  have hp (s : Fin n → V) :
      2*(if ¬ Function.Injective s then (1:ℝ) else 0) ≤ ((orderedCollisionPairs s).card:ℝ) := by
    by_cases hs : Function.Injective s
    · rw [if_neg (not_not_intro hs), mul_zero]
      positivity
    · rw [if_pos hs]
      have hh := orderedCollisionPairs_two_le s hs
      norm_num only [mul_one]
      exact_mod_cast hh
  have hh := finiteMean_mono hp
  rw [finiteMean_mul, orderedCollisionPairs_mean hn] at hh
  have he : finiteMean (fun s : Fin n → V => if ¬ Function.Injective s then (1:ℝ) else 0)=
      finiteEvent (fun s : Fin n → V => ¬ Function.Injective s) := by
    unfold finiteEvent
    congr 1
    funext s
    by_cases hs : Function.Injective s <;> simp [hs]
  rw [he] at hh
  have hM : (0:ℝ)<Fintype.card V := by positivity
  apply (le_div_iff₀ (by positivity : 0<2*(Fintype.card V:ℝ))).2
  have hmul := (le_div_iff₀ hM).mp hh
  nlinarith only [hmul]

end NeuralGeneralization.SquaredSampling
