import NeuralGeneralization.OnlineLowerTanhEmpiricalTruncation
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! # Removing large residual coordinates from a finite lattice alphabet -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualBadMass {n : ℕ} (d : Fin n → ℝ) (ε : ℝ) : ℝ :=
  (n:ℝ)⁻¹*∑ i, if ε < |d i| then 1 else 0

def prunedEmpiricalMass {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (j : ℕ) : ℝ :=
  (n:ℝ)⁻¹*∑ i, if q i=j ∧ |d i|≤ε then 1 else 0

def prunedLatticeIndices {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => q i ∈ S ∧ |d i|≤ε)

lemma residualBadMass_nonneg {n : ℕ} (d : Fin n → ℝ) (ε : ℝ) :
    0 ≤ residualBadMass d ε := by unfold residualBadMass; positivity

lemma residualBadMass_le {n : ℕ} (hn : 0 < n) (d : Fin n → ℝ)
    (ε K : ℝ) (hε : 0 < ε) (hK : (∑ i,(d i)^2) ≤ K) :
    residualBadMass d ε ≤ K/((n:ℝ)*ε^2) := by
  have hraw : ε^2*(∑ i, if ε < |d i| then (1:ℝ) else 0) ≤ ∑ i,(d i)^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    by_cases hi : ε < |d i|
    · simp only [if_pos hi,mul_one]
      nlinarith [sq_abs (d i)]
    · simp only [if_neg hi,mul_zero]
      exact sq_nonneg _
  have hnR : (0:ℝ)<n := by exact_mod_cast hn
  apply (le_div_iff₀ (mul_pos hnR (sq_pos_of_pos hε))).mpr
  unfold residualBadMass
  calc
    _ = ε^2*(∑ i, if ε < |d i| then (1:ℝ) else 0) := by field_simp
    _ ≤ K := hraw.trans hK

lemma prunedEmpiricalMass_le {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (j : ℕ) : prunedEmpiricalMass q d ε j ≤ empiricalMass q j := by
  unfold prunedEmpiricalMass empiricalMass
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Finset.sum_le_sum
  intro i _
  by_cases h : q i=j <;> by_cases hd : |d i|≤ε <;> simp [h,hd]

lemma empirical_pruned_gap_le {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (j : ℕ) :
    empiricalMass q j-prunedEmpiricalMass q d ε j ≤ residualBadMass d ε := by
  unfold prunedEmpiricalMass empiricalMass residualBadMass
  rw [←mul_sub,←Finset.sum_sub_distrib]
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Finset.sum_le_sum
  intro i _
  by_cases h : q i=j <;> by_cases hd : |d i|≤ε
  · simp [h,hd,not_lt.mpr hd]
  · simp [h,hd,lt_of_not_ge hd]
  · simp [h,hd,not_lt.mpr hd]
  · simp [h,hd,lt_of_not_ge hd]

/-- Every retained type has exactly its original limiting frequency. The
normalization is by the original ambient dimension. -/
theorem prunedEmpiricalMass_tendsto
    (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (d : ∀ k, Fin (N k) → ℝ) (ε : ℕ → ℝ) (K : ℝ)
    (hε : ∀ k, 0 < ε k) (hK : ∀ k, (∑ i,(d k i)^2) ≤ K)
    (hsmall : Tendsto (fun k => K/((N k:ℝ)*(ε k)^2)) atTop (𝓝 0))
    (p : ℕ → ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (q k) j) atTop (𝓝 (p j))) (j : ℕ) :
    Tendsto (fun k => prunedEmpiricalMass (q k) (d k) (ε k) j) atTop (𝓝 (p j)) := by
  have hgap : Tendsto (fun k => empiricalMass (q k) j-prunedEmpiricalMass (q k) (d k) (ε k) j)
      atTop (𝓝 0) := by
    apply squeeze_zero (fun k => sub_nonneg.mpr (prunedEmpiricalMass_le _ _ _ _)) _ hsmall
    intro k
    exact (empirical_pruned_gap_le _ _ _ _).trans (residualBadMass_le (hN k) (d k) (ε k) K (hε k) (hK k))
  have hh := (hp j).sub hgap
  simpa only [sub_sub_cancel,sub_zero] using hh

lemma prunedLattice_card {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) :
    (n:ℝ)⁻¹*(prunedLatticeIndices q d ε S).card = ∑ j ∈ S, prunedEmpiricalMass q d ε j := by
  unfold prunedEmpiricalMass
  rw [←Finset.mul_sum,Finset.sum_comm]
  congr 1
  have hcard : ((prunedLatticeIndices q d ε S).card:ℝ)=
      ∑ i : Fin n, if q i∈S ∧ |d i|≤ε then (1:ℝ) else 0 := by
    simp [prunedLatticeIndices]
  rw [hcard]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hd : |d i|≤ε <;> simp [hd,eq_comm]

lemma prunedLattice_moment {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (ε : ℝ) (S : Finset ℕ) :
    (n:ℝ)⁻¹*(∑ i ∈ prunedLatticeIndices q d ε S,(q i:ℝ)^2) =
      ∑ j ∈ S, prunedEmpiricalMass q d ε j*(j:ℝ)^2 := by
  unfold prunedEmpiricalMass
  simp_rw [mul_assoc,Finset.sum_mul]
  rw [←Finset.mul_sum,Finset.sum_comm]
  congr 1
  rw [prunedLatticeIndices,Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hd : |d i|≤ε
  · simp only [hd,and_true]
    simp [eq_comm]
  · simp [hd]

end NeuralGeneralization.OnlineLowerTanh
