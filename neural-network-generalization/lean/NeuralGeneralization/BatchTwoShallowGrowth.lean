import NeuralGeneralization.BatchTwoShallowVoteLoss

/-! The growth bound on arbitrary sampled positions, including repetitions.
This is the sharper-dimension ingredient, not the whole-cube cardinality bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoShallow
open ConcreteModel
open Classical

def sampledHalfspace {d r : ℕ} (sample : Fin r → Cube d) (h : Halfspace d) :
    {A : Finset (Fin r) // A ∈ halfspacePatterns (fun i => inputVector (sample i))} :=
  ⟨Finset.univ.filter (fun i => sample i ∈ h.val), by
    apply Finset.mem_filter.mpr
    obtain ⟨b, hb⟩ := (Finset.mem_filter.mp h.property).2
    exact ⟨Finset.mem_univ _, b, fun i => by simpa using hb (sample i)⟩⟩

def votePattern {d r m : ℕ} (f : BooleanFunction d) (B : ℝ)
    (sample : Fin r → Cube d) (a : Fin m → Halfspace d) : Finset (Fin r) :=
  Finset.univ.filter (fun i => labelReal (f (sample i))*vote B m a (sample i) ≤ 3/8)

def restrictedVotePattern {d r m : ℕ} (f : BooleanFunction d) (B : ℝ)
    (sample : Fin r → Cube d)
    (a : Fin m → {A : Finset (Fin r) // A ∈ halfspacePatterns (fun i => inputVector (sample i))}) :
    Finset (Fin r) :=
  Finset.univ.filter (fun i => labelReal (f (sample i)) *
    (B/m * ∑ j, if i ∈ (a j).val then (1 : ℝ) else -1) ≤ 3/8)

theorem votePattern_eq_restricted {d r m : ℕ} (f : BooleanFunction d) (B : ℝ)
    (sample : Fin r → Cube d) (a : Fin m → Halfspace d) :
    votePattern f B sample a =
      restrictedVotePattern f B sample (fun j => sampledHalfspace sample (a j)) := by
  simp [votePattern, restrictedVotePattern, vote, sampledHalfspace, halfspaceValue,
    div_mul_eq_mul_div]

theorem vote_growth_bound {d r m : ℕ} (f : BooleanFunction d) (B : ℝ)
    (sample : Fin r → Cube d) :
    (Finset.univ.image (votePattern f B sample (m := m))).card ≤ (r+1)^((d+1)*m) := by
  let P := {A : Finset (Fin r) // A ∈ halfspacePatterns (fun i => inputVector (sample i))}
  have hs : Finset.univ.image (votePattern f B sample (m := m)) ⊆
      Finset.univ.image (restrictedVotePattern f B sample (m := m)) := by
    intro A hA
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.mp hA
    exact Finset.mem_image.mpr ⟨fun j => sampledHalfspace sample (a j),
      Finset.mem_univ _, (votePattern_eq_restricted f B sample a).symm⟩
  calc
    _ ≤ (Finset.univ.image (restrictedVotePattern f B sample (m := m))).card :=
      Finset.card_le_card hs
    _ ≤ Fintype.card (Fin m → P) := Finset.card_image_le
    _ = (halfspacePatterns (fun i => inputVector (sample i))).card^m := by
      simp [P]
    _ ≤ ((r+1)^(d+1))^m := Nat.pow_le_pow_left (by
      simpa using halfspace_card_le (fun i => inputVector (sample i))) m
    _ = _ := (pow_mul _ _ _).symm

theorem vote_growth_bound_exp {d r m : ℕ} (hr : 0 < r)
    (f : BooleanFunction d) (B : ℝ) (sample : Fin r → Cube d) :
    ((Finset.univ.image (votePattern f B sample (m := m))).card : ℝ) ≤
      Real.exp (((m : ℝ)*(d+1))*Real.log (Real.exp 1*r)) := by
  have hrR : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have hb : (r : ℝ)+1 ≤ Real.exp 1*r := by
    have he : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp (1 : ℝ)]
    nlinarith
  calc
    _ ≤ ((r : ℝ)+1)^((d+1)*m) := by exact_mod_cast vote_growth_bound f B sample
    _ ≤ (Real.exp 1*r)^((d+1)*m) := pow_le_pow_left₀ (by positivity) hb _
    _ = (Real.exp (Real.log (Real.exp 1*r)))^((d+1)*m) := by
      rw [Real.exp_log (by positivity : 0 < Real.exp 1*(r : ℝ))]
    _ = _ := by
      rw [← Real.exp_nat_mul]
      congr 1
      push_cast
      ring

end NeuralGeneralization.BatchTwoShallow
