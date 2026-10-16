import NeuralGeneralization.RankOneLocalPacking
import Mathlib.Topology.Order.Compact

/-! Actual convex-hull energy minima for rank-one chaining. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {U : Type*} [DecidableEq U]

def indexedHull (p : U → Fin D → ℝ) (S : Finset U) : Set (Fin D → ℝ) :=
  convexHull ℝ (p '' (S : Set U))

lemma indexedHull_mono (p : U → Fin D → ℝ) {S T : Finset U} (h : S ⊆ T) :
    indexedHull p S ⊆ indexedHull p T :=
  convexHull_mono (Set.image_mono h)

lemma indexedHull_nonempty (p : U → Fin D → ℝ) {S : Finset U} (h : S.Nonempty) :
    (indexedHull p S).Nonempty := by
  obtain ⟨x, hx⟩ := h
  exact ⟨p x, subset_convexHull ℝ _ ⟨x, hx, rfl⟩⟩

lemma indexedHull_compact (p : U → Fin D → ℝ) (S : Finset U) :
    IsCompact (indexedHull p S) :=
  ((Finset.finite_toSet S).image p).isCompact_convexHull ℝ

lemma continuous_rankOneEnergy (a : Fin m → Fin D → ℝ) : Continuous (rankOneEnergy a) := by
  unfold rankOneEnergy linearEvaluation
  fun_prop

lemma exists_rankOneEnergy_minimizer (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (S : Finset U) (hS : S.Nonempty) :
    ∃ z ∈ indexedHull p S, ∀ y ∈ indexedHull p S, rankOneEnergy a z ≤ rankOneEnergy a y := by
  exact (indexedHull_compact p S).exists_isMinOn (indexedHull_nonempty p hS)
    (continuous_rankOneEnergy a).continuousOn

def energyMinimizer (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (S : Finset U) : Fin D → ℝ :=
  if h : S.Nonempty then (exists_rankOneEnergy_minimizer a p S h).choose else 0

def energyMinimum (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (S : Finset U) : ℝ :=
  rankOneEnergy a (energyMinimizer a p S)

lemma energyMinimizer_mem (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (S : Finset U) (hS : S.Nonempty) : energyMinimizer a p S ∈ indexedHull p S := by
  simp only [energyMinimizer, dif_pos hS]
  exact (exists_rankOneEnergy_minimizer a p S hS).choose_spec.1

lemma energyMinimum_le (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (S : Finset U) (hS : S.Nonempty) (y : Fin D → ℝ) (hy : y ∈ indexedHull p S) :
    energyMinimum a p S ≤ rankOneEnergy a y := by
  simp only [energyMinimum, energyMinimizer, dif_pos hS]
  exact (exists_rankOneEnergy_minimizer a p S hS).choose_spec.2 y hy

lemma energyMinimum_antitone (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    {S T : Finset U} (hS : S.Nonempty) (h : S ⊆ T) :
    energyMinimum a p T ≤ energyMinimum a p S :=
  energyMinimum_le a p T (hS.mono h) _ (indexedHull_mono p h (energyMinimizer_mem a p S hS))

lemma energyMinimum_nonneg (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (S : Finset U) :
    0 ≤ energyMinimum a p S := rankOneEnergy_nonneg a _

lemma square_two_point_convex (x y s t : ℝ) (hs : 0 ≤ s) (ht : 0 ≤ t) (hst : s+t=1) :
    (s*x+t*y)^2 ≤ s*x^2+t*y^2 := by
  have h := weighted_square_jensen (fun i : Fin 2 => if i=0 then s else t)
    (fun i : Fin 2 => if i=0 then x else y)
    (fun i => by split_ifs <;> assumption)
    (by simpa [Fin.sum_univ_two] using hst)
  simpa [Fin.sum_univ_two] using h

lemma linearEvaluation_convexCombination (a u v : Fin D → ℝ) (s t : ℝ) :
    linearEvaluation a (s • u+t • v) = s*linearEvaluation a u+t*linearEvaluation a v := by
  simp only [linearEvaluation, Pi.add_apply, Pi.smul_apply, smul_eq_mul, mul_add,
    Finset.sum_add_distrib, Finset.mul_sum]
  congr 1 <;> apply Finset.sum_congr rfl <;> intros <;> ring

lemma convex_rowEnergy_sublevel (a : Fin m → Fin D → ℝ) (R : ℝ) :
    Convex ℝ {u | (∑ i, linearEvaluation (a i) u^2) ≤ R} := by
  intro u hu v hv s t hs ht hst
  change (∑ i, linearEvaluation (a i) (s • u+t • v)^2) ≤ R
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    square_two_point_convex (linearEvaluation (a i) u) (linearEvaluation (a i) v) s t hs ht hst)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at h
  simp_rw [linearEvaluation_convexCombination]
  have hh := add_le_add (mul_le_mul_of_nonneg_left hu hs) (mul_le_mul_of_nonneg_left hv ht)
  rw [← add_mul, hst, one_mul] at hh
  exact h.trans hh

lemma convex_euclideanEnergy_sublevel (R : ℝ) :
    Convex ℝ {u : Fin D → ℝ | (∑ i, u i^2) ≤ R} := by
  intro u hu v hv s t hs ht hst
  have h := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    square_two_point_convex (u i) (v i) s t hs ht hst)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at h
  change (∑ i, (s*u i+t*v i)^2) ≤ R
  have hh := add_le_add (mul_le_mul_of_nonneg_left hu hs) (mul_le_mul_of_nonneg_left hv ht)
  rw [← add_mul, hst, one_mul] at hh
  exact h.trans hh

lemma indexedHull_rowEnergy_le (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (S : Finset U) (R : ℝ) (hbound : ∀ x ∈ S, (∑ i, linearEvaluation (a i) (p x)^2) ≤ R)
    {z : Fin D → ℝ} (hz : z ∈ indexedHull p S) :
    (∑ i, linearEvaluation (a i) z^2) ≤ R := by
  apply convexHull_min _ (convex_rowEnergy_sublevel a R) hz
  rintro _ ⟨x, hx, rfl⟩
  exact hbound x hx

lemma indexedHull_euclideanEnergy_le (p : U → Fin D → ℝ) (S : Finset U) (R : ℝ)
    (hbound : ∀ x ∈ S, (∑ i, p x i^2) ≤ R)
    {z : Fin D → ℝ} (hz : z ∈ indexedHull p S) : (∑ i, z i^2) ≤ R := by
  apply convexHull_min _ (convex_euclideanEnergy_sublevel R) hz
  rintro _ ⟨x, hx, rfl⟩
  exact hbound x hx

/-- Convex-hull minimizers remain in the same exact rank-one ball. -/
lemma energyMinimizer_in_ball (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    (S : Finset U) (hS : S.Nonempty) (x : Fin D → ℝ) (r : ℝ) (hr : 0 ≤ r)
    (hball : ∀ y ∈ S, rankOneDistance a x (p y) ≤ r) :
    rankOneDistance a x (energyMinimizer a p S) ≤ r := by
  have hz := energyMinimizer_mem a p S hS
  have hs : rankOneMetricSquared a x (energyMinimizer a p S) ≤ r^2 := by
    apply convexHull_min _ (convex_rankOneMetricSquared_sublevel a x (r^2)) hz
    rintro _ ⟨y, hy, rfl⟩
    change rankOneMetricSquared a x (p y) ≤ r^2
    rw [← rankOneDistance_sq]
    exact pow_le_pow_left₀ (rankOneDistance_nonneg a x (p y)) (hball y hy) 2
  rw [← rankOneDistance_sq] at hs
  exact (sq_le_sq₀ (rankOneDistance_nonneg a x _) hr).mp hs

/-- The actual energy gap controls distance from a child minimizer to
its parent's minimizer. -/
lemma energyMinimizer_gap (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ)
    {S T : Finset U} (hS : S.Nonempty) (hST : S ⊆ T) :
    rankOneEnergy a (fun j => energyMinimizer a p S j-energyMinimizer a p T j) ≤
      2*(energyMinimum a p S-energyMinimum a p T) := by
  apply rankOneEnergy_minimizer_gap
  apply energyMinimum_le a p T (hS.mono hST)
  have hmid := (convex_convexHull ℝ (p '' (T : Set U))).midpoint_mem
    (indexedHull_mono p hST (energyMinimizer_mem a p S hS))
    (energyMinimizer_mem a p T (hS.mono hST))
  have heq : (fun j => (energyMinimizer a p S j+energyMinimizer a p T j)/2) =
      midpoint ℝ (energyMinimizer a p S) (energyMinimizer a p T) := by
    rw [midpoint_eq_smul_add]
    ext j
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul, invOf_eq_inv]
    ring
  rw [heq]
  exact hmid

end NeuralGeneralization.SquaredSampling
