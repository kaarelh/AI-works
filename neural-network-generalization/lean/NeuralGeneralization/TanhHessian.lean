import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.FiniteDifferential
import Mathlib.Analysis.Calculus.FDeriv.Mul
import Mathlib.Analysis.Calculus.FDeriv.Add

/-!
# Actual coordinate derivatives and dimension-free entrywise bounds

The four Hessian terms are retained even when the two observable indices
coincide. Consequently the global l1 bounds apply to diagonal entries too.
-/

noncomputable section
namespace NeuralGeneralization.TanhDifferential
open NeuralGeneralization.FiniteDifferential
open scoped BigOperators
variable {I : Type*} [Fintype I] [DecidableEq I]

def coordinateIndicator (p i : I) : ℝ := if i = p then 1 else 0

omit [Fintype I] in
@[simp] theorem coordinateIndicator_nonneg (p i : I) : 0 ≤ coordinateIndicator p i := by
  unfold coordinateIndicator
  split_ifs <;> norm_num

omit [Fintype I] in
@[simp] theorem abs_coordinateIndicator (p i : I) : |coordinateIndicator p i| = coordinateIndicator p i :=
  abs_of_nonneg (coordinateIndicator_nonneg p i)

@[simp] theorem sum_coordinateIndicator (p : I) : (∑ i, coordinateIndicator p i) = 1 := by
  simp [coordinateIndicator]

def coordinateProductGradient (φ φ' ψ ψ' : ℝ → ℝ) (p q : I) (z : I → ℝ) (i : I) : ℝ :=
  coordinateIndicator p i * (φ' (z p) * ψ (z q)) +
    coordinateIndicator q i * (φ (z p) * ψ' (z q))

theorem gradientLinear_coordinateProduct (φ φ' ψ ψ' : ℝ → ℝ)
    (p q : I) (z : I → ℝ) :
    gradientLinear (coordinateProductGradient φ φ' ψ ψ' p q z) =
      (φ' (z p) * ψ (z q)) • ContinuousLinearMap.proj p +
      (φ (z p) * ψ' (z q)) • ContinuousLinearMap.proj q := by
  ext v
  simp [gradientLinear_apply, coordinateProductGradient, coordinateIndicator,
    add_mul, Finset.sum_add_distrib, ite_mul]

theorem hasFDerivAt_coordinateProduct (φ φ' ψ ψ' : ℝ → ℝ)
    (hφ : ∀ x, HasDerivAt φ (φ' x) x) (hψ : ∀ x, HasDerivAt ψ (ψ' x) x)
    (p q : I) (z : I → ℝ) :
    HasFDerivAt (fun y => φ (y p) * ψ (y q))
      (gradientLinear (coordinateProductGradient φ φ' ψ ψ' p q z)) z := by
  have hp := (hφ (z p)).comp_hasFDerivAt z (ContinuousLinearMap.proj p : (I → ℝ) →L[ℝ] ℝ).hasFDerivAt
  have hq := (hψ (z q)).comp_hasFDerivAt z (ContinuousLinearMap.proj q : (I → ℝ) →L[ℝ] ℝ).hasFDerivAt
  apply (hp.mul hq).congr_fderiv
  rw [gradientLinear_coordinateProduct]
  ext v
  simp only [add_apply, smul_apply,
    ContinuousLinearMap.proj_apply, smul_eq_mul, Function.comp_apply]
  ring

def pairValue (φ : ℝ → ℝ) (p q : I) (z : I → ℝ) : ℝ := φ (z p) * φ (z q)

def pairGradient (φ φ' : ℝ → ℝ) (p q : I) (z : I → ℝ) : I → ℝ :=
  coordinateProductGradient φ φ' φ φ' p q z

def pairHessian (φ φ' φ'' : ℝ → ℝ) (p q : I) (z : I → ℝ) (i j : I) : ℝ :=
  coordinateIndicator p i *
      (coordinateIndicator p j * (φ'' (z p) * φ (z q)) +
       coordinateIndicator q j * (φ' (z p) * φ' (z q))) +
  coordinateIndicator q i *
      (coordinateIndicator p j * (φ' (z p) * φ' (z q)) +
       coordinateIndicator q j * (φ (z p) * φ'' (z q)))

theorem hasFDerivAt_pairValue (φ φ' : ℝ → ℝ)
    (hφ : ∀ x, HasDerivAt φ (φ' x) x) (p q : I) (z : I → ℝ) :
    HasFDerivAt (pairValue φ p q) (gradientLinear (pairGradient φ φ' p q z)) z :=
  hasFDerivAt_coordinateProduct φ φ' φ φ' hφ hφ p q z

theorem hasFDerivAt_pairGradient (φ φ' φ'' : ℝ → ℝ)
    (hφ : ∀ x, HasDerivAt φ (φ' x) x) (hφ' : ∀ x, HasDerivAt φ' (φ'' x) x)
    (p q : I) (z : I → ℝ) (i : I) :
    HasFDerivAt (fun y => pairGradient φ φ' p q y i)
      (gradientLinear (pairHessian φ φ' φ'' p q z i)) z := by
  have hp := (hasFDerivAt_coordinateProduct φ' φ'' φ φ' hφ' hφ p q z).const_mul
    (coordinateIndicator p i)
  have hq := (hasFDerivAt_coordinateProduct φ φ' φ' φ'' hφ hφ' p q z).const_mul
    (coordinateIndicator q i)
  apply (hp.add hq).congr_fderiv
  ext v
  simp only [gradientLinear_apply, add_apply, smul_apply,
    smul_eq_mul, pairHessian, coordinateProductGradient]
  simp_rw [Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j hj
  ring

omit [Fintype I] [DecidableEq I] in
theorem abs_pairValue_le_one (φ : ℝ → ℝ) (hφ : ∀ x, |φ x| ≤ 1)
    (p q : I) (z : I → ℝ) : |pairValue φ p q z| ≤ 1 := by
  unfold pairValue
  rw [abs_mul]
  exact (mul_le_mul (hφ _) (hφ _) (abs_nonneg _) (by norm_num)).trans_eq (one_mul 1)

theorem pairGradient_l1_le_two (φ φ' : ℝ → ℝ)
    (hφ : ∀ x, |φ x| ≤ 1) (hφ' : ∀ x, |φ' x| ≤ 1)
    (p q : I) (z : I → ℝ) : (∑ i, |pairGradient φ φ' p q z i|) ≤ 2 := by
  have hp : |φ' (z p) * φ (z q)| ≤ 1 := by
    rw [abs_mul]
    simpa using mul_le_mul (hφ' _) (hφ _) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  have hq : |φ (z p) * φ' (z q)| ≤ 1 := by
    rw [abs_mul]
    simpa using mul_le_mul (hφ _) (hφ' _) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  calc
    _ ≤ ∑ i, (coordinateIndicator p i * |φ' (z p) * φ (z q)| +
        coordinateIndicator q i * |φ (z p) * φ' (z q)|) := by
      apply Finset.sum_le_sum
      intro i hi
      unfold pairGradient coordinateProductGradient
      simpa only [abs_mul, abs_coordinateIndicator] using abs_add_le
        (coordinateIndicator p i * (φ' (z p) * φ (z q)))
        (coordinateIndicator q i * (φ (z p) * φ' (z q)))
    _ = |φ' (z p) * φ (z q)| + |φ (z p) * φ' (z q)| := by
      rw [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.sum_mul]
      simp
    _ ≤ 2 := by linarith

theorem pairHessian_l1_le_six (φ φ' φ'' : ℝ → ℝ)
    (hφ : ∀ x, |φ x| ≤ 1) (hφ' : ∀ x, |φ' x| ≤ 1) (hφ'' : ∀ x, |φ'' x| ≤ 2)
    (p q : I) (z : I → ℝ) : (∑ i, ∑ j, |pairHessian φ φ' φ'' p q z i j|) ≤ 6 := by
  have hp : |φ'' (z p) * φ (z q)| ≤ 2 := by
    rw [abs_mul]
    simpa using mul_le_mul (hφ'' _) (hφ _) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 2)
  have hm : |φ' (z p) * φ' (z q)| ≤ 1 := by
    rw [abs_mul]
    simpa using mul_le_mul (hφ' _) (hφ' _) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  have hq : |φ (z p) * φ'' (z q)| ≤ 2 := by
    rw [abs_mul]
    simpa using mul_le_mul (hφ _) (hφ'' _) (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
  have hpoint (i j : I) : |pairHessian φ φ' φ'' p q z i j| ≤
      coordinateIndicator p i * (coordinateIndicator p j * 2 + coordinateIndicator q j) +
      coordinateIndicator q i * (coordinateIndicator p j + coordinateIndicator q j * 2) := by
    unfold pairHessian
    calc
      _ ≤ |coordinateIndicator p i *
          (coordinateIndicator p j * (φ'' (z p) * φ (z q)) +
            coordinateIndicator q j * (φ' (z p) * φ' (z q)))| +
          |coordinateIndicator q i *
          (coordinateIndicator p j * (φ' (z p) * φ' (z q)) +
            coordinateIndicator q j * (φ (z p) * φ'' (z q)))| := abs_add_le _ _
      _ ≤ _ := by
        simp only [abs_mul, abs_coordinateIndicator]
        apply add_le_add
        · apply mul_le_mul_of_nonneg_left _ (coordinateIndicator_nonneg p i)
          have h := abs_add_le
            (coordinateIndicator p j * (φ'' (z p) * φ (z q)))
            (coordinateIndicator q j * (φ' (z p) * φ' (z q)))
          simp only [abs_mul, abs_coordinateIndicator] at h
          have h1 := mul_le_mul_of_nonneg_left hp (coordinateIndicator_nonneg p j)
          have h2 := mul_le_mul_of_nonneg_left hm (coordinateIndicator_nonneg q j)
          simp only [abs_mul] at h1 h2
          linarith
        · apply mul_le_mul_of_nonneg_left _ (coordinateIndicator_nonneg q i)
          have h := abs_add_le
            (coordinateIndicator p j * (φ' (z p) * φ' (z q)))
            (coordinateIndicator q j * (φ (z p) * φ'' (z q)))
          simp only [abs_mul, abs_coordinateIndicator] at h
          have h1 := mul_le_mul_of_nonneg_left hm (coordinateIndicator_nonneg p j)
          have h2 := mul_le_mul_of_nonneg_left hq (coordinateIndicator_nonneg q j)
          simp only [abs_mul] at h1 h2
          linarith
  calc
    _ ≤ ∑ i, ∑ j,
        (coordinateIndicator p i * (coordinateIndicator p j * 2 + coordinateIndicator q j) +
        coordinateIndicator q i * (coordinateIndicator p j + coordinateIndicator q j * 2)) :=
      Finset.sum_le_sum (fun i hi => Finset.sum_le_sum (fun j hj => hpoint i j))
    _ = 6 := by
      simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.sum_mul]
      norm_num [Finset.sum_add_distrib, ← Finset.sum_mul]

/-- Actual matrix entrywise l1 mass. Ordered pairs include diagonal entries. -/
def couplingMass (Γ : I → I → ℝ) : ℝ := ∑ e : I × I, |Γ e.1 e.2|

def potentialValue (φ : ℝ → ℝ) (Γ : I → I → ℝ) (z : I → ℝ) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairValue φ e.1 e.2 z

def potentialGradient (φ φ' : ℝ → ℝ) (Γ : I → I → ℝ) (z : I → ℝ) (i : I) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairGradient φ φ' e.1 e.2 z i

def potentialHessian (φ φ' φ'' : ℝ → ℝ) (Γ : I → I → ℝ) (z : I → ℝ) (i j : I) : ℝ :=
  ∑ e : I × I, Γ e.1 e.2 * pairHessian φ φ' φ'' e.1 e.2 z i j

omit [DecidableEq I] in
theorem couplingMass_eq_double_sum (Γ : I → I → ℝ) :
    couplingMass Γ = ∑ p, ∑ q, |Γ p q| := by
  simp [couplingMass, Fintype.sum_prod_type]

omit [DecidableEq I] in
theorem potentialValue_eq_double_sum (φ : ℝ → ℝ) (Γ : I → I → ℝ) (z : I → ℝ) :
    potentialValue φ Γ z = ∑ p, ∑ q, Γ p q * φ (z p) * φ (z q) := by
  simp only [potentialValue, Fintype.sum_prod_type, pairValue]
  apply Finset.sum_congr rfl
  intro p hp
  apply Finset.sum_congr rfl
  intro q hq
  ring

omit [DecidableEq I] in
theorem gradientLinear_sum_fun {K : Type*} (A : Finset K) (g : K → I → ℝ) :
    gradientLinear (fun i => ∑ k ∈ A, g k i) = ∑ k ∈ A, gradientLinear (g k) := by
  have he : (fun i => ∑ k ∈ A, g k i) = ∑ k ∈ A, g k := by
    funext i
    simp
  rw [he, gradientLinear_sum]

omit [DecidableEq I] in
theorem gradientLinear_const_mul_fun (a : ℝ) (g : I → ℝ) :
    gradientLinear (fun i => a * g i) = a • gradientLinear g :=
  gradientLinear_smul a g

theorem hasFDerivAt_potentialValue (φ φ' : ℝ → ℝ)
    (hφ : ∀ x, HasDerivAt φ (φ' x) x) (Γ : I → I → ℝ) (z : I → ℝ) :
    HasFDerivAt (potentialValue φ Γ) (gradientLinear (potentialGradient φ φ' Γ z)) z := by
  unfold potentialValue potentialGradient
  rw [gradientLinear_sum_fun]
  simp_rw [gradientLinear_const_mul_fun]
  exact (HasFDerivAt.fun_sum (u := Finset.univ)
    (fun (e : I × I) he => (hasFDerivAt_pairValue φ φ' hφ e.1 e.2 z).const_mul (Γ e.1 e.2)))

theorem hasFDerivAt_potentialGradient (φ φ' φ'' : ℝ → ℝ)
    (hφ : ∀ x, HasDerivAt φ (φ' x) x) (hφ' : ∀ x, HasDerivAt φ' (φ'' x) x)
    (Γ : I → I → ℝ) (z : I → ℝ) (i : I) :
    HasFDerivAt (fun y => potentialGradient φ φ' Γ y i)
      (gradientLinear (potentialHessian φ φ' φ'' Γ z i)) z := by
  unfold potentialGradient potentialHessian
  rw [gradientLinear_sum_fun]
  simp_rw [gradientLinear_const_mul_fun]
  exact (HasFDerivAt.fun_sum (u := Finset.univ)
    (fun (e : I × I) he =>
      (hasFDerivAt_pairGradient φ φ' φ'' hφ hφ' e.1 e.2 z i).const_mul (Γ e.1 e.2)))

/-- Finite weighted sums of vectors obey the entrywise l1 triangle bound. -/
theorem sum_abs_weighted_sum_le {K J : Type*} [Fintype K] [Fintype J]
    (c : K → ℝ) (v : K → J → ℝ) :
    (∑ j, |∑ k, c k * v k j|) ≤ ∑ k, |c k| * ∑ j, |v k j| := by
  calc
    _ ≤ ∑ j, ∑ k, |c k| * |v k j| := by
      apply Finset.sum_le_sum
      intro j hj
      simpa only [abs_mul] using Finset.abs_sum_le_sum_abs (fun k => c k * v k j) Finset.univ
    _ = _ := by rw [Finset.sum_comm]; simp only [Finset.mul_sum]

omit [DecidableEq I] in
theorem abs_potentialValue_le_mass (φ : ℝ → ℝ) (hφ : ∀ x, |φ x| ≤ 1)
    (Γ : I → I → ℝ) (z : I → ℝ) : |potentialValue φ Γ z| ≤ couplingMass Γ := by
  unfold potentialValue couplingMass
  calc
    _ ≤ ∑ e : I × I, |Γ e.1 e.2 * pairValue φ e.1 e.2 z| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ _ := by
      apply Finset.sum_le_sum
      intro e he
      rw [abs_mul]
      simpa using mul_le_mul_of_nonneg_left (abs_pairValue_le_one φ hφ e.1 e.2 z)
        (abs_nonneg (Γ e.1 e.2))

theorem potentialGradient_l1_le_mass (φ φ' : ℝ → ℝ)
    (hφ : ∀ x, |φ x| ≤ 1) (hφ' : ∀ x, |φ' x| ≤ 1)
    (Γ : I → I → ℝ) (z : I → ℝ) :
    (∑ i, |potentialGradient φ φ' Γ z i|) ≤ 2 * couplingMass Γ := by
  calc
    _ ≤ ∑ e : I × I, |Γ e.1 e.2| * ∑ i, |pairGradient φ φ' e.1 e.2 z i| :=
      sum_abs_weighted_sum_le (fun e : I × I => Γ e.1 e.2)
        (fun e i => pairGradient φ φ' e.1 e.2 z i)
    _ ≤ ∑ e : I × I, |Γ e.1 e.2| * 2 :=
      Finset.sum_le_sum (fun e he => mul_le_mul_of_nonneg_left
        (pairGradient_l1_le_two φ φ' hφ hφ' e.1 e.2 z) (abs_nonneg _))
    _ = _ := by rw [← Finset.sum_mul]; exact mul_comm _ _

theorem potentialHessian_l1_le_mass (φ φ' φ'' : ℝ → ℝ)
    (hφ : ∀ x, |φ x| ≤ 1) (hφ' : ∀ x, |φ' x| ≤ 1) (hφ'' : ∀ x, |φ'' x| ≤ 2)
    (Γ : I → I → ℝ) (z : I → ℝ) :
    (∑ i, ∑ j, |potentialHessian φ φ' φ'' Γ z i j|) ≤ 6 * couplingMass Γ := by
  have h := sum_abs_weighted_sum_le (fun e : I × I => Γ e.1 e.2)
    (fun e a : I × I => pairHessian φ φ' φ'' e.1 e.2 z a.1 a.2)
  simp only [Fintype.sum_prod_type] at h
  change (∑ i, ∑ j, |∑ p, ∑ q, Γ p q * pairHessian φ φ' φ'' p q z i j|) ≤ _ at h
  calc
    _ ≤ ∑ e : I × I, |Γ e.1 e.2| * ∑ i, ∑ j, |pairHessian φ φ' φ'' e.1 e.2 z i j| := by
      simpa only [potentialHessian, Fintype.sum_prod_type] using h
    _ ≤ ∑ e : I × I, |Γ e.1 e.2| * 6 :=
      Finset.sum_le_sum (fun e he => mul_le_mul_of_nonneg_left
        (pairHessian_l1_le_six φ φ' φ'' hφ hφ' hφ'' e.1 e.2 z) (abs_nonneg _))
    _ = _ := by rw [← Finset.sum_mul]; exact mul_comm _ _

/-- True first and second Frechet derivatives of the actual tanh pair. -/
theorem tanhPair_derivatives (p q : I) (z : I → ℝ) :
    HasFDerivAt (pairValue Real.tanh p q)
      (gradientLinear (pairGradient Real.tanh tanhFirst p q z)) z ∧
    ∀ i, HasFDerivAt (fun y => pairGradient Real.tanh tanhFirst p q y i)
      (gradientLinear (pairHessian Real.tanh tanhFirst tanhSecond p q z i)) z :=
  ⟨hasFDerivAt_pairValue _ _ hasDerivAt_tanh_first p q z,
   fun i => hasFDerivAt_pairGradient _ _ _ hasDerivAt_tanh_first hasDerivAt_tanhFirst p q z i⟩

/-- Dimension-free global observable bounds, including repeated indices. -/
theorem tanhPair_bounds (p q : I) (z : I → ℝ) :
    |pairValue Real.tanh p q z| ≤ 1 ∧
    (∑ i, |pairGradient Real.tanh tanhFirst p q z i|) ≤ 2 ∧
    (∑ i, ∑ j, |pairHessian Real.tanh tanhFirst tanhSecond p q z i j|) ≤ 6 :=
  ⟨abs_pairValue_le_one _ (fun x => (Real.abs_tanh_lt_one x).le) p q z,
   pairGradient_l1_le_two _ _ (fun x => (Real.abs_tanh_lt_one x).le) abs_tanhFirst_le_one p q z,
   pairHessian_l1_le_six _ _ _ (fun x => (Real.abs_tanh_lt_one x).le)
     abs_tanhFirst_le_one abs_tanhSecond_le_two p q z⟩

theorem tanhPotential_derivatives (Γ : I → I → ℝ) (z : I → ℝ) :
    HasFDerivAt (potentialValue Real.tanh Γ)
      (gradientLinear (potentialGradient Real.tanh tanhFirst Γ z)) z ∧
    ∀ i, HasFDerivAt (fun y => potentialGradient Real.tanh tanhFirst Γ y i)
      (gradientLinear (potentialHessian Real.tanh tanhFirst tanhSecond Γ z i)) z :=
  ⟨hasFDerivAt_potentialValue _ _ hasDerivAt_tanh_first Γ z,
   fun i => hasFDerivAt_potentialGradient _ _ _ hasDerivAt_tanh_first hasDerivAt_tanhFirst Γ z i⟩

/-- The actual quadratic tanh tilt satisfies the advertised global bounds. -/
theorem tanhPotential_bounds (Γ : I → I → ℝ) (g : ℝ) (hΓ : couplingMass Γ ≤ g)
    (z : I → ℝ) :
    |potentialValue Real.tanh Γ z| ≤ g ∧
    (∑ i, |potentialGradient Real.tanh tanhFirst Γ z i|) ≤ 2 * g ∧
    (∑ i, ∑ j, |potentialHessian Real.tanh tanhFirst tanhSecond Γ z i j|) ≤ 6 * g := by
  constructor
  · exact (abs_potentialValue_le_mass _ (fun x => (Real.abs_tanh_lt_one x).le) Γ z).trans hΓ
  constructor
  · exact (potentialGradient_l1_le_mass _ _ (fun x => (Real.abs_tanh_lt_one x).le)
      abs_tanhFirst_le_one Γ z).trans (mul_le_mul_of_nonneg_left hΓ (by norm_num))
  · exact (potentialHessian_l1_le_mass _ _ _ (fun x => (Real.abs_tanh_lt_one x).le)
      abs_tanhFirst_le_one abs_tanhSecond_le_two Γ z).trans
      (mul_le_mul_of_nonneg_left hΓ (by norm_num))

omit [Fintype I] [DecidableEq I] in
@[fun_prop] theorem continuous_tanhPairValue (p q : I) : Continuous (pairValue Real.tanh p q) := by
  unfold pairValue
  fun_prop

omit [Fintype I] in
@[fun_prop] theorem continuous_tanhPairGradient (p q i : I) :
    Continuous (fun z => pairGradient Real.tanh tanhFirst p q z i) := by
  unfold pairGradient coordinateProductGradient
  fun_prop

omit [Fintype I] in
@[fun_prop] theorem continuous_tanhPairHessian (p q i j : I) :
    Continuous (fun z => pairHessian Real.tanh tanhFirst tanhSecond p q z i j) := by
  unfold pairHessian
  fun_prop

omit [DecidableEq I] in
@[fun_prop] theorem continuous_tanhPotentialValue (Γ : I → I → ℝ) :
    Continuous (potentialValue Real.tanh Γ) := by
  unfold potentialValue
  fun_prop

@[fun_prop] theorem continuous_tanhPotentialGradient (Γ : I → I → ℝ) (i : I) :
    Continuous (fun z => potentialGradient Real.tanh tanhFirst Γ z i) := by
  unfold potentialGradient
  fun_prop

@[fun_prop] theorem continuous_tanhPotentialHessian (Γ : I → I → ℝ) (i j : I) :
    Continuous (fun z => potentialHessian Real.tanh tanhFirst tanhSecond Γ z i j) := by
  unfold potentialHessian
  fun_prop

end NeuralGeneralization.TanhDifferential
