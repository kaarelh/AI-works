import NeuralGeneralization.LocalizedBumpSpectrum
import NeuralGeneralization.Model

/-! # Global strict-margin interpolation by actual localized cube bumps -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
variable {d n : ℕ}

def centerSum (s : Fin n → ClippingCube d) (T : Finset (Fin n)) (x : ClippingCube d) : ℝ :=
  ∑ i ∈ T, bump (s i) x

def comparator (A : ℝ) (s : Fin n → ClippingCube d) (T : Finset (Fin n))
    (x : ClippingCube d) : ℝ := 2*A*(1-2*centerSum s T x)

lemma centerSum_nonneg (s : Fin n → ClippingCube d) (T : Finset (Fin n)) (x : ClippingCube d) :
    0 ≤ centerSum s T x := Finset.sum_nonneg fun i _ => bump_nonneg (s i) x

lemma centerSum_ge_one (s : Fin n → ClippingCube d) (T : Finset (Fin n))
    {i : Fin n} (hi : i ∈ T) : 1 ≤ centerSum s T (s i) := by
  have hh := Finset.single_le_sum (fun j (_ : j ∈ T) => bump_nonneg (s j) (s i)) hi
  simpa only [bump_self, centerSum] using hh

lemma bump_le_one_fifth_of_ne {z x : ClippingCube d} (hx : x ≠ z) : bump z x ≤ 1/5 := by
  have hdist : 1 ≤ hammingDist x z := Nat.one_le_iff_ne_zero.mpr (hammingDist_ne_zero.mpr hx)
  have hp := pow_le_pow_of_le_one (by norm_num : (0:ℝ) ≤ 1/5) (by norm_num : (1/5:ℝ) ≤ 1) hdist
  exact (bump_le_distance z x).trans (by simpa only [pow_one] using hp)

/-- Separated centers leave at most one nearby bump at any point. -/
theorem centerSum_le_off_centers (s : Fin n → ClippingCube d) (T : Finset (Fin n))
    (R : ℕ) (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (x : ClippingCube d) (hoff : ∀ i ∈ T, x ≠ s i) :
    centerSum s T x ≤ 1/5+(n:ℝ)*(1/5:ℝ)^R := by
  classical
  have hcard : (T.card : ℝ) ≤ n := by exact_mod_cast (show T.card ≤ n by simpa using Finset.card_le_univ T)
  have hfar (j : Fin n) (hj : R ≤ hammingDist x (s j)) : bump (s j) x ≤ (1/5:ℝ)^R :=
    (bump_le_distance _ _).trans
      (pow_le_pow_of_le_one (by norm_num) (by norm_num) hj)
  by_cases hex : ∃ i ∈ T, hammingDist x (s i) < R
  · obtain ⟨i,hi,hnear⟩ := hex
    have hother (j : Fin n) (hj : j ∈ T.erase i) : R ≤ hammingDist x (s j) := by
      have hji := (Finset.mem_erase.mp hj).1
      have htri := hammingDist_triangle (s i) x (s j)
      rw [hammingDist_comm (s i) x] at htri
      have hs := hsep i j hji.symm
      omega
    have hsum : (∑ j ∈ T.erase i, bump (s j) x) ≤ (n:ℝ)*(1/5:ℝ)^R := by
      calc
        _ ≤ ∑ _j ∈ T.erase i, (1/5:ℝ)^R := Finset.sum_le_sum fun j hj => hfar j (hother j hj)
        _ = ((T.erase i).card:ℝ)*(1/5:ℝ)^R := by simp
        _ ≤ _ := mul_le_mul_of_nonneg_right
          (by exact_mod_cast (show (T.erase i).card ≤ n by simpa using Finset.card_le_univ (T.erase i))) (by positivity)
    have hself := bump_le_one_fifth_of_ne (hoff i hi)
    unfold centerSum
    rw [← Finset.add_sum_erase T (fun j => bump (s j) x) hi]
    linarith
  · have hfarall (i : Fin n) (hi : i ∈ T) : R ≤ hammingDist x (s i) := by
      by_contra hh
      exact hex ⟨i,hi,lt_of_not_ge hh⟩
    have hh : centerSum s T x ≤ (n:ℝ)*(1/5:ℝ)^R := by
      calc
        _ ≤ ∑ _i ∈ T, (1/5:ℝ)^R := Finset.sum_le_sum fun i hi => hfar i (hfarall i hi)
        _ = (T.card:ℝ)*(1/5:ℝ)^R := by simp
        _ ≤ _ := mul_le_mul_of_nonneg_right hcard (by positivity)
    linarith

/-- Every input has strict margin, not merely the training inputs. -/
theorem comparator_global_margin (A : ℝ) (hA : 0 < A)
    (s : Fin n → ClippingCube d) (T : Finset (Fin n)) (R : ℕ)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) (x : ClippingCube d) :
    A < |comparator A s T x| := by
  classical
  by_cases hex : ∃ i ∈ T, x=s i
  · obtain ⟨i,hi,rfl⟩ := hex
    have hs := centerSum_ge_one s T hi
    have hc : comparator A s T (s i) < -A := by unfold comparator; nlinarith
    exact lt_of_lt_of_le (by linarith : A < -comparator A s T (s i)) (neg_le_abs _)
  · have hoff : ∀ i ∈ T, x ≠ s i := fun i hi hx => hex ⟨i,hi,hx⟩
    have hs := centerSum_le_off_centers s T R hsep x hoff
    have hc : A < comparator A s T x := by unfold comparator; nlinarith
    exact hc.trans_le (le_abs_self _)

/-- The same global comparator realizes every labeling of separated samples. -/
theorem comparator_training_margin (A : ℝ) (hA : 0 < A)
    (s : Fin n → ClippingCube d) (y : Fin n → Bool) (R : ℕ) (hR : 0 < R)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) (i : Fin n) :
    A < ConcreteModel.labelReal (y i)*
      comparator A s (Finset.univ.filter (fun j => y j=false)) (s i) := by
  classical
  let T := Finset.univ.filter (fun j => y j=false)
  have hinj : Function.Injective s := by
    intro i j hij
    by_contra hne
    have hh := hsep i j hne
    rw [hij, hammingDist_self] at hh
    omega
  cases hy : y i
  · have hi : i ∈ T := by simp [T, hy]
    have hs := centerSum_ge_one s T hi
    change A < ConcreteModel.labelReal false*comparator A s T (s i)
    simp only [ConcreteModel.labelReal, Bool.false_eq_true, if_false]
    unfold comparator
    nlinarith
  · have hoff : ∀ j ∈ T, s i ≠ s j := by
      intro j hj hij
      have hji := hinj hij
      have hyj : y j=false := (Finset.mem_filter.mp hj).2
      subst j
      simp [hy] at hyj
    have hs := centerSum_le_off_centers s T R hsep (s i) hoff
    change A < ConcreteModel.labelReal true*comparator A s T (s i)
    simp only [ConcreteModel.labelReal, if_true, one_mul]
    unfold comparator
    nlinarith

end NeuralGeneralization.LocalizedCubeBump
