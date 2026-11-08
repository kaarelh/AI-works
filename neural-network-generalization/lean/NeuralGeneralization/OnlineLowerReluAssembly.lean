import NeuralGeneralization.OnlineLowerReluFamily
import NeuralGeneralization.OnlineLowerResourceRates
import NeuralGeneralization.OnlineLowerGapBridge
import NeuralGeneralization.OnlineLowerReluSynthesis

/-!
# Assembly of the concrete ReLU family's resources and online conclusion

This module proves resource and model reductions with an explicit
concrete energy-gap premise. `OnlineLowerReluMain` discharges that premise
using the analytic and geometric construction and proves the unconditional
main existence theorem.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

abbrev reluFamilyDimension (R k : ℕ) : ℕ := railDimension (Family.size R k)
abbrev reluFamilyTeacherWidth (R k : ℕ) : ℕ :=
  teacherWidth (reluFamilyDimension R k) (Family.logicalDim k)
abbrev reluFamilyTarget (R k : ℕ) : BooleanFunction (reluFamilyDimension R k) :=
  physicalParityTarget (physicalBase (Family.size R k))
    (physicalColumn (Family.size R k) (Family.column k))

theorem binary_family_exponential_count (k : ℕ) (hk : 2 ≤ k) :
    Real.exp ((Real.log 2 / 2) * (k : ℝ)) ≤ ((2 : ℕ) ^ (k - 1) : ℝ) := by
  have hlog : 0 < Real.log (2 : ℝ) := Real.log_pos (by norm_num)
  have hkR : (2 : ℝ) ≤ k := by exact_mod_cast hk
  have hcast : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
    rw [Nat.cast_sub (by omega), Nat.cast_one]
  calc
    _ ≤ Real.exp (((k - 1 : ℕ) : ℝ) * Real.log 2) := by
      apply Real.exp_le_exp.mpr
      rw [hcast]
      nlinarith
    _ = _ := by rw [Real.exp_nat_mul, Real.exp_log (by norm_num)]; norm_cast

/-- The literal fixed-rail construction has all of the manuscript's
teacher, circuit, and joint resource bounds, independently of the online
energy argument. -/
theorem reluFamily_resource_bounds (R k : ℕ) (hR : 0 < R) (hk : 1 ≤ k) :
    0 < reluFamilyDimension R k ∧
    1 ≤ reluFamilyTeacherWidth R k ∧
    k ≤ reluFamilyDimension R k ∧
    reluFamilyDimension R k ≤ (24 * R + 48) * k ∧
    reluFamilyTeacherWidth R k ≤ 600 * (4 * R + 9) * k ^ 2 ∧
    BoundedTeacher relu (reluFamilyTarget R k) (reluFamilyTeacherWidth R k) ∧
    HasCircuitAtMost (reluFamilyTarget R k) (22 * reluFamilyDimension R k) := by
  obtain ⟨hteacher, hcircuit, _⟩ := Family.target_resources R k hR
  have hdEq : reluFamilyDimension R k = (8 * k + 4) * (2 * R + 4) := by
    exact (Family.physicalDimension_eq R k).trans (by rw [Family.pairDim_eq])
  have hd : 0 < reluFamilyDimension R k := by rw [hdEq]; positivity
  have hkl : k ≤ reluFamilyDimension R k := by rw [hdEq]; nlinarith
  have hdu : reluFamilyDimension R k ≤ (24 * R + 48) * k := by
    rw [hdEq]
    nlinarith
  refine ⟨hd, hteacher.1, hkl, hdu, Family.teacherWidth_quadratic_k R k hk,
    hteacher, ?_⟩
  obtain ⟨c, hc, he⟩ := hcircuit
  exact ⟨c, hc.trans (by change 17 * reluFamilyDimension R k + 5 ≤ _; omega), he⟩

/-- Once the concrete family's actual posterior failure has been proved,
all resource constants and the exponential count are supplied here. No
resource hypothesis is left implicit. This is an assembly implication,
not the uninstantiated main existence claim. -/
theorem relu_square_root_resources_of_concrete_family
    (R k₀ : ℕ) (hR : 0 < R)
    (hfamily : ∀ k : ℕ, k₀ ≤ k → 2 ≤ k →
      ∃ π : InputOrder (reluFamilyDimension R k),
      ∃ J : Finset (Fin (Fintype.card (Cube (reluFamilyDimension R k)))),
        2 ^ (k - 1) ≤ J.card ∧
        AllLargeWidthsFail relu (reluFamilyTarget R k) (reluFamilyTeacherWidth R k) π J) :
    ReLUSquareRootStatement := by
  let K := 600 * (4 * R + 9) + (24 * R + 48) + 22
  have hK : 0 < K := by dsimp [K]; omega
  have hK1 : 1 ≤ K := by omega
  have hKu : 24 * R + 48 ≤ K := by dsimp [K]; omega
  have hKC : 600 * (4 * R + 9) ≤ K := by dsimp [K]; omega
  have hKcircuit : 22 ≤ K := by dsimp [K]; omega
  refine ⟨K, hK, Real.log 2 / 2, div_pos (Real.log_pos (by norm_num)) (by norm_num),
    max k₀ 2, by omega, ?_⟩
  intro k hk
  have hk₀ : k₀ ≤ k := (le_max_left _ _).trans hk
  have hk2 : 2 ≤ k := (le_max_right _ _).trans hk
  obtain ⟨π, J, hcount, hfail⟩ := hfamily k hk₀ hk2
  obtain ⟨hd, hC, hdl, hdu, hCu, hteacher, hcircuit⟩ :=
    reluFamily_resource_bounds R k hR (by omega)
  refine ⟨reluFamilyDimension R k, reluFamilyTeacherWidth R k, reluFamilyTarget R k,
    π, J, hd, hC, ?_, ?_, hCu.trans (Nat.mul_le_mul_right _ hKC),
    hteacher, ?_, ?_, hfail⟩
  · simpa only [pow_one] using hdl.trans (Nat.le_mul_of_pos_left _ hK)
  · simpa only [pow_one] using hdu.trans (Nat.mul_le_mul_right _ hKu)
  · obtain ⟨c, hc, he⟩ := hcircuit
    exact ⟨c, hc.trans (Nat.mul_le_mul_right _ hKcircuit), he⟩
  · exact (binary_family_exponential_count k hk2).trans (by exact_mod_cast hcount)

/-- The model-level width-exponent conclusion follows from the concrete
family as soon as its energy construction is instantiated. -/
theorem relu_square_root_width_rate_of_concrete_family
    (R k₀ : ℕ) (hR : 0 < R)
    (hfamily : ∀ k : ℕ, k₀ ≤ k → 2 ≤ k →
      ∃ π : InputOrder (reluFamilyDimension R k),
      ∃ J : Finset (Fin (Fintype.card (Cube (reluFamilyDimension R k)))),
        2 ^ (k - 1) ≤ J.card ∧
        AllLargeWidthsFail relu (reluFamilyTarget R k) (reluFamilyTeacherWidth R k) π J) :
    WidthExponentLowerBound relu (1 / 2) := by
  exact polynomial_quadratic_resources_imply_square_root relu 1
    (relu_square_root_resources_of_concrete_family R k₀ hR hfamily)

end NeuralGeneralization.OnlineLower
