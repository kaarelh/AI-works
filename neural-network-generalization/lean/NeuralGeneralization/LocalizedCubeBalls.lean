import NeuralGeneralization.LocalizedFamilyCounting
import NeuralGeneralization.BatchTwoNeuralConversePointFeatures

/-! Exact finite descriptions for arbitrary-radius Euclidean balls centered
on the Boolean cube, including unused slots in a union of at most k balls. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel BatchTwoNeuralConverse
open Classical

def cubeDistanceSq {d : ℕ} (a x : Cube d) : ℝ :=
  ∑ i,(labelReal (x i)-labelReal (a i))^2

def cubeBall {d : ℕ} (a : Cube d) (radius : ℝ) : Set (Cube d) :=
  {x | Real.sqrt (cubeDistanceSq a x) ≤ radius}

lemma cubeDistanceSq_eq_shell {d : ℕ} (a x : Cube d) :
    cubeDistanceSq a x = 4*(hammingShell a x:ℝ) := by
  have he (i : Fin d) : (labelReal (x i)-labelReal (a i))^2 =
      4*(if x i ≠ a i then (1:ℝ) else 0) := by
    cases ha : a i <;> cases hx : x i <;> norm_num [ha,hx,labelReal]
  unfold cubeDistanceSq
  simp_rw [he,← Finset.mul_sum,← Finset.sum_filter]
  simp [hammingShell]

abbrev BallCode (d : ℕ) := Cube d × Fin (d+2)

def decodedBall {d : ℕ} (code : BallCode d) : Set (Cube d) :=
  {x | hammingShell code.1 x < code.2.val}

/-- A fixed center has d+2 inclusion choices, with cutoff zero denoting an
unused/empty ball. Arbitrary real radii create no additional subsets. -/
theorem cubeBall_representable {d : ℕ} (a : Cube d) (radius : ℝ) :
    ∃ cutoff : Fin (d+2),cubeBall a radius = decodedBall (a,cutoff) := by
  by_cases hr : 0 ≤ radius
  · let cut := min (d+1) (⌊radius^2/4⌋₊+1)
    have hcut : cut < d+2 := (min_le_left _ _).trans_lt (by omega)
    refine ⟨⟨cut,hcut⟩,?_⟩
    ext x
    have hsq : 0 ≤ radius^2/4 := by positivity
    have hx := hammingShell_le a x
    simp only [cubeBall,decodedBall,Set.mem_setOf_eq,Real.sqrt_le_iff,hr,true_and,cubeDistanceSq_eq_shell]
    change 4*(hammingShell a x:ℝ) ≤ radius^2 ↔ hammingShell a x < min (d+1) (⌊radius^2/4⌋₊+1)
    rw [lt_min_iff]
    have hn : hammingShell a x < d+1 := by omega
    simp only [hn,true_and,Nat.lt_succ_iff]
    rw [Nat.le_floor_iff hsq]
    constructor <;> intro hh <;> linarith
  · refine ⟨0,?_⟩
    ext x
    simp only [cubeBall,decodedBall,Set.mem_setOf_eq,Fin.val_zero,Nat.not_lt_zero,iff_false]
    exact not_le_of_gt ((lt_of_not_ge hr).trans_le (Real.sqrt_nonneg _))

def decodedException {d k : ℕ} (code : Fin k → BallCode d) : Finset (Cube d) :=
  Finset.univ.filter (fun x => ∀ i,x ∉ decodedBall (code i))

def ballExceptionFamily (d k : ℕ) : Finset (Finset (Cube d)) :=
  Finset.univ.image (decodedException (d := d) (k := k))

/-- Every complement of at most k actual Euclidean balls is in the fixed
finite family. An absent slot is represented by `none`. -/
theorem cube_ball_union_exception_mem {d k : ℕ} (balls : Fin k → Option (Cube d × ℝ)) :
    (Finset.univ.filter (fun x => ∀ i,match balls i with
      | none => True
      | some ar => x ∉ cubeBall ar.1 ar.2)) ∈ ballExceptionFamily d k := by
  have hrepr (i : Fin k) : ∃ code : BallCode d,∀ x,
      (match balls i with | none => True | some ar => x ∉ cubeBall ar.1 ar.2) ↔ x ∉ decodedBall code := by
    cases hi : balls i with
    | none => exact ⟨(fun _ => false,0),fun x => by simp [decodedBall]⟩
    | some ar =>
      obtain ⟨cut,hcut⟩ := cubeBall_representable ar.1 ar.2
      exact ⟨(ar.1,cut),fun x => by simp only [hcut]⟩
  choose code hc using hrepr
  apply Finset.mem_image.mpr
  refine ⟨code,Finset.mem_univ _,?_⟩
  ext x
  simp only [decodedException,Finset.mem_filter,Finset.mem_univ,true_and]
  exact forall_congr' (fun i => (hc i x).symm)

theorem cube_ball_exception_card (d k : ℕ) :
    (ballExceptionFamily d k).card ≤ (2^d*(d+2))^k := by
  have hh := Finset.card_image_le (s := Finset.univ)
    (f := decodedException (d := d) (k := k))
  simpa [ballExceptionFamily,BallCode,Cube] using hh

/-- The manuscript's logarithmic description bound for posterior-chosen
centers and radii, with no dependence on neural-network width. -/
theorem cube_ball_exception_log_card (d k : ℕ) :
    Real.log ((ballExceptionFamily d k).card:ℝ) ≤
      (k:ℝ)*((d:ℝ)*Real.log 2+Real.log ((d:ℝ)+2)) := by
  have hcard := cube_ball_exception_card d k
  by_cases hz : (ballExceptionFamily d k).card = 0
  · simp only [hz,Nat.cast_zero,Real.log_zero]
    apply mul_nonneg (Nat.cast_nonneg _)
    apply add_nonneg
    · positivity
    · exact Real.log_nonneg (by have := Nat.cast_nonneg (α := ℝ) d; linarith)
  · have hp : (0:ℝ) < (ballExceptionFamily d k).card := by exact_mod_cast Nat.pos_of_ne_zero hz
    have hb : ((ballExceptionFamily d k).card:ℝ) ≤ ((2:ℝ)^d*((d:ℝ)+2))^k := by exact_mod_cast hcard
    have hh := Real.log_le_log hp hb
    rw [Real.log_pow,Real.log_mul (by positivity) (by positivity),Real.log_pow] at hh
    exact hh

/-- With at least one ball slot the family contains the empty exception set,
so the global target cylinder is among the admissible possibilities. -/
theorem empty_mem_ballExceptionFamily (d : ℕ) {k : ℕ} (hk : 0 < k) :
    ∅ ∈ ballExceptionFamily d k := by
  let code : Fin k → BallCode d := fun _ => (fun _ => false,⟨d+1,by omega⟩)
  apply Finset.mem_image.mpr
  refine ⟨code,Finset.mem_univ _,?_⟩
  apply Finset.eq_empty_iff_forall_notMem.mpr
  intro x hx
  have hh := (Finset.mem_filter.mp hx).2 (⟨0,hk⟩ : Fin k)
  apply hh
  change hammingShell (fun _ => false) x < d+1
  exact Nat.lt_succ_of_le (hammingShell_le _ _)

end NeuralGeneralization.RobustLocalized
