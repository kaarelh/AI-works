import NeuralGeneralization.NeuralKernelSpectrum
import Mathlib.Analysis.Normed.Ring.InfiniteSum
import Mathlib.Topology.Algebra.InfiniteSum.Real

/-! Concrete Maclaurin coefficients of every actual iterated arcsine link.
They are defined by finite Cauchy products and a nonnegative mixture, rather
than by an assumed scalar coefficient comparison. -/
noncomputable section
set_option maxHeartbeats 400000
open scoped BigOperators
namespace NeuralGeneralization.IteratedArcsineSeries

/-- Coefficients of an ordinary natural power of a series. -/
def powerCoefficient (a : ℕ → ℝ) : ℕ → ℕ → ℝ
  | 0, m => if m = 0 then 1 else 0
  | p + 1, m => ∑ ij ∈ Finset.antidiagonal m, a ij.1 * powerCoefficient a p ij.2

theorem powerCoefficient_nonneg {a : ℕ → ℝ} (ha : ∀ m, 0 ≤ a m) (p m : ℕ) :
    0 ≤ powerCoefficient a p m := by
  induction p generalizing m with
  | zero => simp only [powerCoefficient]; split_ifs <;> norm_num
  | succ p ih => exact Finset.sum_nonneg (fun ij hij => mul_nonneg (ha _) (ih _))

theorem hasSum_powerCoefficient {a : ℕ → ℝ} (ha : ∀ m, 0 ≤ a m)
    {x y : ℝ} (hx : 0 ≤ x) (h : HasSum (fun m => a m * x ^ m) y) (p : ℕ) :
    HasSum (fun m => powerCoefficient a p m * x ^ m) (y ^ p) := by
  induction p with
  | zero =>
    have hzero : (fun m => powerCoefficient a 0 m * x ^ m) = (fun m : ℕ => if m = 0 then (1 : ℝ) else 0) := by
      ext m
      by_cases hm : m = 0 <;> simp only [powerCoefficient, hm, if_true, if_false, zero_mul, pow_zero, mul_one]
    rw [hzero, pow_zero]
    exact hasSum_ite_eq (0 : ℕ) (1 : ℝ)
  | succ p ih =>
    have hprod := h.summable.mul_of_nonneg ih.summable
      (fun m => mul_nonneg (ha m) (pow_nonneg hx m))
      (fun m => mul_nonneg (powerCoefficient_nonneg ha p m) (pow_nonneg hx m))
    have hs := summable_sum_mul_antidiagonal_of_summable_mul (A := ℕ)
      (f := fun m => a m * x ^ m) (g := fun m => powerCoefficient a p m * x ^ m) hprod
    have heq := Summable.tsum_mul_tsum_eq_tsum_sum_antidiagonal (A := ℕ)
      (f := fun m => a m * x ^ m) (g := fun m => powerCoefficient a p m * x ^ m)
      h.summable ih.summable hprod
    rw [h.tsum_eq, ih.tsum_eq] at heq
    have hterm (m : ℕ) :
        (∑ ij ∈ Finset.antidiagonal m, (a ij.1 * x ^ ij.1) *
          (powerCoefficient a p ij.2 * x ^ ij.2)) =
        powerCoefficient a (p+1) m * x ^ m := by
      rw [powerCoefficient, Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro ij hij
      have hm := Finset.mem_antidiagonal.mp hij
      rw [← hm, pow_add]
      ring
    simp_rw [hterm] at hs heq
    have hvalue : (∑' m, powerCoefficient a (p+1) m * x ^ m) = y ^ (p+1) := by
      rw [← heq, pow_succ, mul_comm]
    rw [← hvalue]
    exact hs.hasSum

theorem hasSum_powerCoefficient_one {a : ℕ → ℝ} (ha : ∀ m, 0 ≤ a m)
    (h : HasSum a 1) (p : ℕ) : HasSum (powerCoefficient a p) 1 := by
  convert hasSum_powerCoefficient ha (by norm_num : (0 : ℝ) ≤ 1) (by simpa using h) p using 1 <;> simp

/-- The actual coefficients, indexed by their full power. -/
def coefficient : ℕ → ℕ → ℝ
  | 0, m => if m = 1 then 1 else 0
  | k+1, m => ∑' n, arcsineLinkCoefficient n * powerCoefficient (coefficient k) (2*n+1) m

theorem coefficient_nonneg (k m : ℕ) : 0 ≤ coefficient k m := by
  induction k generalizing m with
  | zero => simp only [coefficient]; split_ifs <;> norm_num
  | succ k ih => exact tsum_nonneg (fun n => mul_nonneg (arcsineLinkCoefficient_pos n).le
      (powerCoefficient_nonneg ih _ _))

theorem hasSum_coefficient (k : ℕ) : HasSum (coefficient k) 1 := by
  induction k with
  | zero => exact hasSum_ite_eq (1 : ℕ) (1 : ℝ)
  | succ k ih =>
    let f : ℕ × ℕ → ℝ := fun nm => arcsineLinkCoefficient nm.1 *
      powerCoefficient (coefficient k) (2*nm.1+1) nm.2
    have hfnonneg : 0 ≤ f := fun nm => mul_nonneg (arcsineLinkCoefficient_pos _).le
      (powerCoefficient_nonneg (coefficient_nonneg k) _ _)
    have hrow (n : ℕ) : HasSum (fun m => f (n,m)) (arcsineLinkCoefficient n) := by
      simpa [f] using (hasSum_powerCoefficient_one (coefficient_nonneg k) ih (2*n+1)).mul_left
        (arcsineLinkCoefficient n)
    have hsum : Summable f := (summable_prod_of_nonneg hfnonneg).mpr
      ⟨fun n => (hrow n).summable, by simpa only [(hrow _).tsum_eq] using
        hasSum_arcsineLinkCoefficient.summable⟩
    have htotal : HasSum f 1 := by
      have heq := (hsum.hasSum.prod_fiberwise hrow).unique hasSum_arcsineLinkCoefficient
      simpa only [heq] using hsum.hasSum
    have hswap : HasSum (fun mn : ℕ × ℕ => f (mn.2,mn.1)) 1 :=
      (Equiv.hasSum_iff (f := f) (Equiv.prodComm ℕ ℕ)).mpr htotal
    exact hswap.prod_fiberwise (fun m => (hsum.prod_symm.prod_factor m).hasSum)


/-- The concrete coefficients sum to the actual iterated link throughout
its nonnegative closed domain, including the singular endpoint. -/
theorem hasSum_iteratedArcsine_nonneg (k : ℕ) {x : ℝ} (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    HasSum (fun m => coefficient k m * x ^ m) (iteratedArcsine k x) := by
  induction k with
  | zero =>
    have hzero : (fun m => coefficient 0 m * x ^ m) = (fun m : ℕ => if m = 1 then x else 0) := by
      ext m
      by_cases hm : m = 1
      · subst m; simp only [coefficient, if_true, one_mul, pow_one]
      · simp only [coefficient, hm, if_false, zero_mul]
    rw [hzero]
    exact hasSum_ite_eq (1 : ℕ) x
  | succ k ih =>
    let f : ℕ × ℕ → ℝ := fun nm => arcsineLinkCoefficient nm.1 *
      (powerCoefficient (coefficient k) (2*nm.1+1) nm.2 * x ^ nm.2)
    have hfnonneg : 0 ≤ f := fun nm => mul_nonneg (arcsineLinkCoefficient_pos _).le
      (mul_nonneg (powerCoefficient_nonneg (coefficient_nonneg k) _ _) (pow_nonneg hx _))
    have hrow (n : ℕ) : HasSum (fun m => f (n,m))
        (arcsineLinkCoefficient n * (iteratedArcsine k x)^(2*n+1)) := by
      simpa [f] using (hasSum_powerCoefficient (coefficient_nonneg k) hx ih (2*n+1)).mul_left
        (arcsineLinkCoefficient n)
    have houter := hasSum_arcsineLink_closed (abs_iteratedArcsine_le_one
      (show |x| ≤ 1 by rwa [abs_of_nonneg hx]) k)
    have hsum : Summable f := (summable_prod_of_nonneg hfnonneg).mpr
      ⟨fun n => (hrow n).summable, by simpa only [(hrow _).tsum_eq] using houter.summable⟩
    have htotal : HasSum f (iteratedArcsine (k+1) x) := by
      have heq := (hsum.hasSum.prod_fiberwise hrow).unique houter
      simpa only [heq, iteratedArcsine] using hsum.hasSum
    have hswap : HasSum (fun mn : ℕ × ℕ => f (mn.2,mn.1)) (iteratedArcsine (k+1) x) :=
      (Equiv.hasSum_iff (f := f) (Equiv.prodComm ℕ ℕ)).mpr htotal
    have hout := hswap.prod_fiberwise (fun m => (hsum.prod_symm.prod_factor m).hasSum)
    have hfun : (fun m => coefficient (k+1) m * x ^ m) =
        (fun m => ∑' n, f (m,n).swap) := by
      ext m
      simp only [coefficient, f, Prod.swap_prod_mk]
      rw [← tsum_mul_right]
      congr 1
      ext n
      ring
    rw [hfun]
    exact hout

/-- Odd input series have the expected parity under every natural power. -/
theorem powerCoefficient_zero_of_parity {a : ℕ → ℝ}
    (ha : ∀ m, m % 2 = 0 → a m = 0) (p m : ℕ) (h : m % 2 ≠ p % 2) :
    powerCoefficient a p m = 0 := by
  induction p generalizing m with
  | zero =>
    have hm : m ≠ 0 := by omega
    simp [powerCoefficient, hm]
  | succ p ih =>
    apply Finset.sum_eq_zero
    intro ij hij
    have hm := Finset.mem_antidiagonal.mp hij
    by_cases hi : ij.1 % 2 = 0
    · rw [ha _ hi, zero_mul]
    · have hj : ij.2 % 2 ≠ p % 2 := by omega
      rw [ih _ hj, mul_zero]

/-- All even coefficients vanish at every depth. -/
theorem coefficient_even (k m : ℕ) (hm : m % 2 = 0) : coefficient k m = 0 := by
  induction k generalizing m with
  | zero =>
    have hne : m ≠ 1 := by omega
    simp [coefficient, hne]
  | succ k ih =>
    have hz : (fun n => arcsineLinkCoefficient n *
        powerCoefficient (coefficient k) (2*n+1) m) = (fun _ : ℕ => (0 : ℝ)) := by
      ext n
      rw [powerCoefficient_zero_of_parity ih (2*n+1) m (by omega), mul_zero]
    simp only [coefficient, hz, tsum_zero]

/-- The actual scalar iterates are odd. -/
theorem iteratedArcsine_neg (k : ℕ) (x : ℝ) : iteratedArcsine k (-x) = -iteratedArcsine k x := by
  induction k with
  | zero => rfl
  | succ k ih => simp [iteratedArcsine, ih, arcsineLink, Real.arcsin_neg]

/-- The full closed-interval Maclaurin series for every actual scalar
iterate; no coefficient-regularity hypothesis is assumed. -/
theorem hasSum_iteratedArcsine (k : ℕ) {x : ℝ} (hx : |x| ≤ 1) :
    HasSum (fun m => coefficient k m * x ^ m) (iteratedArcsine k x) := by
  by_cases hx0 : 0 ≤ x
  · exact hasSum_iteratedArcsine_nonneg k hx0 (abs_le.mp hx).2
  · have hxneg : 0 ≤ -x := by linarith
    have h := (hasSum_iteratedArcsine_nonneg k hxneg (by linarith [(abs_le.mp hx).1])).neg
    rw [iteratedArcsine_neg, neg_neg] at h
    have hfun : (fun m => coefficient k m * x ^ m) =
        (fun m => -(coefficient k m * (-x) ^ m)) := by
      ext m
      by_cases hm : m % 2 = 0
      · simp [coefficient_even k m hm]
      · have hmod : m % 2 = 1 := by omega
        have ho : Odd m := Nat.odd_iff.mpr hmod
        rw [ho.neg_pow]
        ring
    rw [hfun]
    exact h


@[simp] theorem powerCoefficient_one (a : ℕ → ℝ) (m : ℕ) : powerCoefficient a 1 m = a m := by
  rw [powerCoefficient]
  rw [Finset.sum_eq_single (m,0)]
  · simp [powerCoefficient]
  · intro ij hij hne
    have hj : ij.2 ≠ 0 := by
      intro hj
      have hm := Finset.mem_antidiagonal.mp hij
      apply hne
      ext <;> simp_all
    simp [powerCoefficient, hj]
  · simp

@[simp] theorem powerCoefficient_unit (p m : ℕ) :
    powerCoefficient (coefficient 0) p m = if m = p then 1 else 0 := by
  induction p generalizing m with
  | zero => rfl
  | succ p ih =>
    rw [powerCoefficient]
    cases m with
    | zero => simp [coefficient]
    | succ m =>
      rw [Finset.sum_eq_single (1,m)]
      · rw [show coefficient 0 1 = 1 by simp [coefficient], one_mul, ih]
        simp
      · intro ij hij hne
        have hi : ij.1 ≠ 1 := by
          intro hi
          have hm := Finset.mem_antidiagonal.mp hij
          apply hne
          ext <;> simp_all <;> omega
        simp [coefficient, hi]
      · simp [Finset.mem_antidiagonal, Nat.add_comm]

/-- The new all-depth definition agrees exactly with the established
first-layer coefficient formula. -/
theorem coefficient_one_odd (n : ℕ) : coefficient 1 (2*n+1) = arcsineLinkCoefficient n := by
  change (∑' m, arcsineLinkCoefficient m * powerCoefficient (coefficient 0) (2*m+1) (2*n+1)) = _
  simp_rw [powerCoefficient_unit]
  rw [tsum_eq_single n]
  · simp
  · intro m hm
    have hne : 2*n+1 ≠ 2*m+1 := by omega
    simp [hne, Ne.symm hm]

theorem mixture_summable (k m : ℕ) : Summable (fun n => arcsineLinkCoefficient n *
    powerCoefficient (coefficient k) (2*n+1) m) := by
  apply Summable.of_nonneg_of_le
    (fun n => mul_nonneg (arcsineLinkCoefficient_pos n).le
      (powerCoefficient_nonneg (coefficient_nonneg k) _ _)) _ hasSum_arcsineLinkCoefficient.summable
  intro n
  have hp : powerCoefficient (coefficient k) (2*n+1) m ≤ 1 := by
    simpa only [(hasSum_powerCoefficient_one (coefficient_nonneg k) (hasSum_coefficient k) (2*n+1)).tsum_eq]
      using (hasSum_powerCoefficient_one (coefficient_nonneg k) (hasSum_coefficient k)
        (2*n+1)).summable.le_tsum m (fun j hj => powerCoefficient_nonneg (coefficient_nonneg k) _ _)
  simpa using mul_le_mul_of_nonneg_left hp (arcsineLinkCoefficient_pos n).le

theorem coefficient_succ_lower (k m : ℕ) :
    (2/Real.pi) * coefficient k m ≤ coefficient (k+1) m := by
  have h := (mixture_summable k m).le_tsum 0 (fun n hn =>
    mul_nonneg (arcsineLinkCoefficient_pos n).le (powerCoefficient_nonneg (coefficient_nonneg k) _ _))
  simpa only [coefficient, mul_zero, zero_add, powerCoefficient_one, arcsineLinkCoefficient_zero]
    using h

/-- Every odd Maclaurin coefficient is strictly positive at positive depth. -/
theorem coefficient_odd_pos (k n : ℕ) : 0 < coefficient (k+1) (2*n+1) := by
  induction k with
  | zero => simpa [coefficient_one_odd] using arcsineLinkCoefficient_pos n
  | succ k ih =>
    have hpos : 0 < (2 / Real.pi : ℝ) := div_pos (by norm_num) Real.pi_pos
    exact (mul_pos hpos ih).trans_le (coefficient_succ_lower (k+1) (2*n+1))

end NeuralGeneralization.IteratedArcsineSeries
