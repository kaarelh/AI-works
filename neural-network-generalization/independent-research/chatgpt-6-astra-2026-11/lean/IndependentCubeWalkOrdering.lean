import Mathlib

/-!
Per-vertex coordinate-flip walk counts and their same-parity ordering.
On 0 ≤ r ≤ q, `cubeWalk q m r` is the standard radial recurrence for
length-m walks from zero to a specified weight-r vertex of the q-cube.
Values outside that range are irrelevant: the boundary coefficient is zero.
The identification with Walsh eigenvalues is an analytic/combinatorial step
in the manuscript, rather than a claim of complete kernel formalization.
-/
namespace IndependentResearch

def cubeWalk (q : ℕ) : ℕ → ℕ → ℕ
  | 0, r => if r = 0 then 1 else 0
  | m + 1, r => r * cubeWalk q m (r - 1) + (q - r) * cubeWalk q m (r + 1)

theorem cube_walk_same_parity_order (q m r : ℕ) (hr : r + 2 ≤ q) :
    cubeWalk q m (r + 2) ≤ cubeWalk q m r := by
  induction m generalizing r with
  | zero => simp [cubeWalk]
  | succ m ih =>
    cases r with
    | zero =>
      by_cases hq : 3 ≤ q
      · have h := ih 1 (by omega)
        have he : q = (q - 2) + 2 := by omega
        simp only [cubeWalk, Nat.zero_mul, Nat.sub_zero, Nat.zero_add,
          Nat.reduceAdd, Nat.reduceSub]
        nlinarith
      · have he : q = 2 := by omega
        subst q
        simp [cubeWalk]
    | succ r =>
      have hl := ih r (by omega)
      have he : q - (r + 1) = (q - (r + 3)) + 2 := by omega
      have hu : (q - (r + 3)) * cubeWalk q m (r + 4) ≤
          (q - (r + 3)) * cubeWalk q m (r + 2) := by
        by_cases hb : r + 4 ≤ q
        · have h := ih (r + 2) (by omega)
          simpa only [Nat.add_assoc, Nat.reduceAdd] using
            Nat.mul_le_mul_left (q - (r + 3)) h
        · have hz : q - (r + 3) = 0 := by omega
          simp [hz]
      have hsub : r + 3 - 1 = r + 2 := by omega
      simp only [cubeWalk, Nat.add_assoc, Nat.reduceAdd, Nat.add_sub_cancel, hsub]
      nlinarith

theorem cube_walk_same_parity_strict (q m r : ℕ) (hq : 3 ≤ q)
    (hr : r + 2 ≤ q) (hreached : ∃ k : ℕ, m = r + 2 * k) :
    cubeWalk q m (r + 2) < cubeWalk q m r := by
  induction m generalizing r with
  | zero =>
    obtain ⟨k, hk⟩ := hreached
    have : r = 0 := by omega
    subst r
    simp [cubeWalk]
  | succ m ih =>
    cases r with
    | zero =>
      obtain ⟨k, hk⟩ := hreached
      have hs := ih 1 (by omega) ⟨k - 1, by omega⟩
      have he : q = (q - 2) + 2 := by omega
      simp only [cubeWalk, Nat.zero_mul, Nat.sub_zero, Nat.zero_add,
        Nat.reduceAdd, Nat.reduceSub]
      nlinarith
    | succ r =>
      obtain ⟨k, hk⟩ := hreached
      have hl := ih r (by omega) ⟨k, by omega⟩
      have he : q - (r + 1) = (q - (r + 3)) + 2 := by omega
      have hu : (q - (r + 3)) * cubeWalk q m (r + 4) ≤
          (q - (r + 3)) * cubeWalk q m (r + 2) := by
        by_cases hb : r + 4 ≤ q
        · have h := cube_walk_same_parity_order q m (r + 2) (by omega)
          simpa only [Nat.add_assoc, Nat.reduceAdd] using
            Nat.mul_le_mul_left (q - (r + 3)) h
        · have hz : q - (r + 3) = 0 := by omega
          simp [hz]
      have hsub : r + 3 - 1 = r + 2 := by omega
      simp only [cubeWalk, Nat.add_assoc, Nat.reduceAdd, Nat.add_sub_cancel, hsub]
      nlinarith

theorem cube_walk_consecutive_pair_sums (q m p : ℕ) (hp : p + 2 ≤ q) :
    cubeWalk q m (p + 1) + cubeWalk q m (p + 2) ≤
      cubeWalk q m p + cubeWalk q m (p + 1) := by
  have h := cube_walk_same_parity_order q m p hp
  omega

end IndependentResearch
