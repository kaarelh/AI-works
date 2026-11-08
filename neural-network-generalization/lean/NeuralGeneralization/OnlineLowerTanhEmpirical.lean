import NeuralGeneralization.OnlineLowerTanhLocalization
import Mathlib.Topology.Sequences
import Mathlib.Topology.Algebra.InfiniteSum.Real

/-! # Empirical odd-lattice laws with second-moment control

These are literal frequencies of the positive odd integer indices
produced by global localization. Escaped second moment is kept separate
from convergence of the empirical probability law.
-/
noncomputable section
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def empiricalMass {n : ℕ} (q : Fin n → ℕ) (j : ℕ) : ℝ :=
  (n:ℝ)⁻¹ * ∑i, if q i=j then 1 else 0

def empiricalSecondMoment {n : ℕ} (q : Fin n → ℕ) : ℝ :=
  (n:ℝ)⁻¹ * ∑i, (q i:ℝ)^2

theorem empiricalMass_nonneg {n : ℕ} (q : Fin n → ℕ) (j : ℕ) :
    0≤empiricalMass q j := by unfold empiricalMass; positivity

theorem empiricalMass_le_one {n : ℕ} (hn : 0<n) (q : Fin n → ℕ) (j : ℕ) :
    empiricalMass q j≤1 := by
  have hs : (∑i : Fin n, if q i=j then (1:ℝ) else 0)≤n := by
    calc
      _ ≤ ∑_i : Fin n,(1:ℝ) := Finset.sum_le_sum (fun i _ => by split_ifs <;> norm_num)
      _ = _ := by simp
  unfold empiricalMass
  have h := mul_le_mul_of_nonneg_left hs (show 0≤(n:ℝ)⁻¹ by positivity)
  simpa only [inv_mul_cancel₀ (by positivity : (n:ℝ)≠0)] using h

theorem empiricalMass_range {n : ℕ} (q : Fin n → ℕ) (J : ℕ) :
    (∑j∈Finset.range J,empiricalMass q j) =
      (n:ℝ)⁻¹ * ∑i, if q i<J then 1 else 0 := by
  unfold empiricalMass
  rw [←Finset.mul_sum,Finset.sum_comm]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  simp [eq_comm]

theorem empiricalMass_range_le_one {n : ℕ} (hn : 0<n) (q : Fin n → ℕ) (J : ℕ) :
    (∑j∈Finset.range J,empiricalMass q j)≤1 := by
  rw [empiricalMass_range]
  have hs : (∑i : Fin n, if q i<J then (1:ℝ) else 0)≤n := by
    calc
      _ ≤ ∑_i : Fin n,(1:ℝ) := Finset.sum_le_sum (fun i _ => by split_ifs <;> norm_num)
      _ = _ := by simp
  have h := mul_le_mul_of_nonneg_left hs (show 0≤(n:ℝ)⁻¹ by positivity)
  simpa only [inv_mul_cancel₀ (by positivity : (n:ℝ)≠0)] using h

/-- An explicit uniform tightness estimate from the actual second moment. -/
theorem empiricalMass_tail_bound {n : ℕ} (hn : 0<n) (q : Fin n → ℕ)
    (J : ℕ) (hJ : 0<J) :
    1-(∑j∈Finset.range J,empiricalMass q j)≤empiricalSecondMoment q/(J:ℝ)^2 := by
  have hpartition : (∑i : Fin n,if q i<J then (1:ℝ) else 0) +
      (∑i : Fin n,if J≤q i then (1:ℝ) else 0)=n := by
    rw [←Finset.sum_add_distrib]
    have hpoint (i : Fin n) : (if q i<J then (1:ℝ) else 0)+(if J≤q i then (1:ℝ) else 0)=1 := by
      split_ifs <;> norm_num at * <;> omega
    simp_rw [hpoint]
    simp
  have hmoment : (J:ℝ)^2*(∑i : Fin n,if J≤q i then (1:ℝ) else 0)≤∑i,(q i:ℝ)^2 := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    by_cases h : J≤q i
    · simp only [if_pos h,mul_one]
      exact pow_le_pow_left₀ (Nat.cast_nonneg J) (by exact_mod_cast h) 2
    · simp [h]
  have hnorm := mul_le_mul_of_nonneg_left hmoment (show 0≤(n:ℝ)⁻¹ by positivity)
  rw [empiricalMass_range]
  unfold empiricalSecondMoment
  apply (le_div_iff₀ (sq_pos_of_pos (show (0:ℝ)<J by positivity))).mpr
  have hpartition' := congrArg (fun x : ℝ => (n:ℝ)⁻¹*x) hpartition
  rw [inv_mul_cancel₀ (by positivity : (n:ℝ)≠0)] at hpartition'
  nlinarith only [hnorm,hpartition']

/-- Empirical profiles always have a pointwise convergent subsequence.
The mass-one property is established separately using tightness. -/
theorem empiricalMass_subsequence (N : ℕ → ℕ) (hN : ∀k,0<N k)
    (q : ∀k,Fin (N k) → ℕ) :
    ∃p : ℕ → ℝ,(∀j,p j∈Icc (0:ℝ) 1) ∧
      ∃φ : ℕ → ℕ,StrictMono φ ∧
        ∀j,Tendsto (fun k=>empiricalMass (q (φ k)) j) atTop (𝓝 (p j)) := by
  have hc : IsCompact (Set.pi Set.univ (fun _ : ℕ => Icc (0:ℝ) 1)) := by
    convert (isCompact_pi_infinite (fun _ : ℕ => isCompact_Icc (a := (0:ℝ)) (b := 1))) using 1
    ext x
    simp [Set.pi]
  have hm (k : ℕ) : empiricalMass (q k)∈Set.pi Set.univ (fun _ : ℕ => Icc (0:ℝ) 1) := by
    intro j _
    exact ⟨empiricalMass_nonneg _ _,empiricalMass_le_one (hN k) _ _⟩
  obtain ⟨p,hp,φ,hφ,hconv⟩ := hc.tendsto_subseq hm
  refine ⟨p,fun j=>hp j (Set.mem_univ j),φ,hφ,?_⟩
  intro j
  exact ((continuous_apply j).tendsto p).comp hconv

end NeuralGeneralization.OnlineLowerTanh
