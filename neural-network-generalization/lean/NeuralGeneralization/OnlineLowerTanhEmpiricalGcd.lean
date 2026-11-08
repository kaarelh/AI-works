import NeuralGeneralization.OnlineLowerTanhEmpiricalLimit
import Mathlib.Algebra.GCDMonoid.Finset
import Mathlib.Data.Int.GCD

/-! # Finite gcd extraction for the limit empirical odd alphabet -/

noncomputable section
open scoped BigOperators Topology Classical
open Filter Set

namespace NeuralGeneralization.OnlineLowerTanh

def positiveSupportPrefix (p : ℕ → ℝ) (J : ℕ) : Finset ℕ :=
  (Finset.range J).filter (fun j => 0 < p j)

def supportPrefixGcd (p : ℕ → ℝ) (J : ℕ) : ℕ :=
  (positiveSupportPrefix p J).gcd id

lemma positiveSupportPrefix_mono (p : ℕ → ℝ) {J K : ℕ} (hJK : J ≤ K) :
    positiveSupportPrefix p J ⊆ positiveSupportPrefix p K := by
  intro j hj
  simp only [positiveSupportPrefix, Finset.mem_filter, Finset.mem_range] at hj ⊢
  exact ⟨lt_of_lt_of_le hj.1 hJK, hj.2⟩

lemma supportPrefixGcd_dvd (p : ℕ → ℝ) {J K : ℕ} (hJK : J ≤ K) :
    supportPrefixGcd p K ∣ supportPrefixGcd p J :=
  Finset.gcd_mono (positiveSupportPrefix_mono p hJK)

/-- The gcd of the positive support is realized by a finite prefix and
stabilizes exactly; there is no passage from an infinite formal gcd. -/
theorem exists_stable_support_gcd (p : ℕ → ℝ)
    (hne : ∃ j, 0 < p j) (hpositive : ∀ j, 0 < p j → 0 < j) :
    ∃ g J₀ : ℕ, 0 < g ∧ supportPrefixGcd p J₀ = g ∧
      (∀ J, J₀ ≤ J → supportPrefixGcd p J = g) ∧
      (∀ j, 0 < p j → g ∣ j) := by
  obtain ⟨j₀, hp₀⟩ := hne
  have hj₀ := hpositive j₀ hp₀
  have hmem : j₀ ∈ positiveSupportPrefix p (j₀ + 1) := by
    simp [positiveSupportPrefix, hp₀]
  have hnonzero : supportPrefixGcd p (j₀ + 1) ≠ 0 := by
    intro hz
    have hh := Finset.gcd_eq_zero_iff.mp hz j₀ hmem
    exact (Nat.ne_of_gt hj₀) hh
  have hex : ∃ g : ℕ, 0 < g ∧ ∃ J, supportPrefixGcd p J = g :=
    ⟨_, Nat.pos_of_ne_zero hnonzero, j₀ + 1, rfl⟩
  let g := Nat.find hex
  obtain ⟨hg, J₀, hJ₀⟩ := Nat.find_spec hex
  change 0 < g at hg
  change supportPrefixGcd p J₀ = g at hJ₀
  have hstable (J : ℕ) (hJ : J₀ ≤ J) : supportPrefixGcd p J = g := by
    have hdiv : supportPrefixGcd p J ∣ g := by
      rw [← hJ₀]
      exact supportPrefixGcd_dvd p hJ
    have hpos := Nat.pos_of_dvd_of_pos hdiv hg
    have hlow : g ≤ supportPrefixGcd p J := Nat.find_min' hex ⟨hpos, J, rfl⟩
    exact Nat.le_antisymm (Nat.le_of_dvd hg hdiv) hlow
  refine ⟨g, J₀, hg, hJ₀, hstable, ?_⟩
  intro j hpj
  let J := max J₀ (j + 1)
  have hjmem : j ∈ positiveSupportPrefix p J := by
    simp only [positiveSupportPrefix, Finset.mem_filter, Finset.mem_range]
    exact ⟨lt_of_lt_of_le (Nat.lt_succ_self j) (le_max_right _ _), hpj⟩
  have hdiv := Finset.gcd_dvd (f := id) hjmem
  change supportPrefixGcd p J ∣ j at hdiv
  rw [hstable J (le_max_left _ _)] at hdiv
  exact hdiv

lemma support_gcd_odd (p : ℕ → ℝ) (g : ℕ) (hne : ∃ j, 0 < p j)
    (hodd : ∀ j, 0 < p j → Odd j) (hdiv : ∀ j, 0 < p j → g ∣ j) : Odd g := by
  obtain ⟨j, hj⟩ := hne
  apply Nat.not_even_iff_odd.mp
  intro he
  exact (hodd j hj).not_two_dvd_nat (he.two_dvd.trans (hdiv j hj))

lemma positive_support_nonempty_of_hasSum_one (p : ℕ → ℝ) (hpos : ∀ j, 0 ≤ p j)
    (hsum : HasSum p 1) : ∃ j, 0 < p j := by
  by_contra hnone
  have hz : p = fun _ => 0 := by
    funext j
    exact le_antisymm (le_of_not_gt (fun hh => hnone ⟨j, hh⟩)) (hpos j)
  rw [hz] at hsum
  have hh := hsum.tsum_eq
  simp at hh

/-- Every finite gcd has literal integer Bezout coefficients. -/
theorem finite_gcd_bezout (s : Finset ℕ) (f : ℕ → ℕ) :
    ∃ c : ℕ → ℤ, ∑ j ∈ s, c j * (f j : ℤ) = ((s.gcd f : ℕ) : ℤ) := by
  induction s using Finset.induction_on with
  | empty => exact ⟨fun _ => 0, by simp⟩
  | @insert a s ha ih =>
    obtain ⟨c, hc⟩ := ih
    let A := Nat.gcdA (f a) (s.gcd f)
    let B := Nat.gcdB (f a) (s.gcd f)
    refine ⟨fun j => if j = a then A else B * c j, ?_⟩
    rw [Finset.sum_insert ha, Finset.gcd_insert]
    simp only [if_true]
    have hsum : (∑ j ∈ s, (if j = a then A else B * c j) * (f j : ℤ)) =
        B * ∑ j ∈ s, c j * (f j : ℤ) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j hj
      rw [if_neg (show j ≠ a from fun h => ha (h ▸ hj))]
      ring
    rw [hsum, hc]
    have hh := Nat.gcd_eq_gcd_ab (f a) (s.gcd f)
    change A * (f a : ℤ) + B * ((s.gcd f : ℕ) : ℤ) = (Nat.gcd (f a) (s.gcd f) : ℤ)
    dsimp [A, B]
    linarith

/-- Normalizing a nonzero finite support gcd produces the explicit
Bezout vector required by the global common-peak coercivity lemma. -/
theorem normalized_prefix_bezout (p : ℕ → ℝ) (J g : ℕ)
    (hg : 0 < g) (hG : supportPrefixGcd p J = g) :
    ∃ c : ℕ → ℤ, ∑ j ∈ positiveSupportPrefix p J, c j * ((j / g : ℕ) : ℤ) = 1 := by
  have hne : (positiveSupportPrefix p J).Nonempty := by
    by_contra hn
    have he := Finset.not_nonempty_iff_eq_empty.mp hn
    have hh : supportPrefixGcd p J = 0 := by simp [supportPrefixGcd, he]
    omega
  obtain ⟨j, hj⟩ := hne
  have hG0 : (positiveSupportPrefix p J).gcd id ≠ 0 := by
    change supportPrefixGcd p J ≠ 0
    omega
  obtain ⟨j, hj, hj0⟩ : ∃ j ∈ positiveSupportPrefix p J, j ≠ 0 := by
    by_contra hnone
    apply hG0
    apply Finset.gcd_eq_zero_iff.mpr
    intro j hj
    by_contra hj0
    exact hnone ⟨j, hj, hj0⟩
  have hquot : (positiveSupportPrefix p J).gcd (fun j => j / g) = 1 := by
    have hh := Finset.gcd_div_id_eq_one hj hj0
    change (positiveSupportPrefix p J).gcd (fun j => j / supportPrefixGcd p J) = 1 at hh
    rwa [hG] at hh
  obtain ⟨c, hc⟩ := finite_gcd_bezout (positiveSupportPrefix p J) (fun j => j / g)
  refine ⟨c, ?_⟩
  simpa only [hquot, Nat.cast_one] using hc

end NeuralGeneralization.OnlineLowerTanh
