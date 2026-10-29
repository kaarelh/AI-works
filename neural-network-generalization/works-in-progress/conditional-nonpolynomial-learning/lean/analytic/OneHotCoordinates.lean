import OneHotAffine
import Mathlib.Logic.Equiv.Fin.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-! Separate one-hot encoding for each scalar coordinate. The state uses d*q
wires, not q^d wires. Integer affine forms compile exactly on this encoding. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup

def oneHotState {d q : ℕ} (a : Fin d → Fin q) : Input (d*q) :=
  fun j => decide (a (finProdFinEquiv.symm j).1 = (finProdFinEquiv.symm j).2)

def coordinateTerms {d q : ℕ} (c : Fin d → ℤ) (values : Fin q → ℤ) :
    List (Fin (d*q) × ℤ) :=
  List.ofFn fun j => (j, c (finProdFinEquiv.symm j).1*values (finProdFinEquiv.symm j).2)

theorem coordinateTerms_eval {d q : ℕ} (c : Fin d → ℤ) (values : Fin q → ℤ)
    (a : Fin d → Fin q) :
    integerValue (coordinateTerms c values) (oneHotState a) = ∑ i, c i*values (a i) := by
  simp only [integerValue, coordinateTerms, List.map_ofFn, List.sum_ofFn]
  rw [← Equiv.sum_comp finProdFinEquiv]
  simp only [oneHotState, Equiv.symm_apply_apply, decide_eq_true_eq]
  rw [Fintype.sum_prod_type]
  have hdiv (z : Fin d × Fin q) : (finProdFinEquiv z).divNat = z.1 :=
    congrArg Prod.fst (finProdFinEquiv.symm_apply_apply z)
  have hmod (z : Fin d × Fin q) : (finProdFinEquiv z).modNat = z.2 :=
    congrArg Prod.snd (finProdFinEquiv.symm_apply_apply z)
  simp [hdiv, hmod]

theorem coordinateTerms_weight {d q : ℕ} (c : Fin d → ℤ) (values : Fin q → ℤ)
    (B V : ℕ) (hc : ∀ i, (c i).natAbs ≤ B) (hv : ∀ j, (values j).natAbs ≤ V) :
    integerWeight (coordinateTerms c values) ≤ (d*q)*(B*V) := by
  simp only [integerWeight, coordinateTerms, List.map_ofFn, List.sum_ofFn]
  calc
    _ ≤ ∑ _j : Fin (d*q), B*V := Finset.sum_le_sum fun j _ => by
      change (c (finProdFinEquiv.symm j).1*values (finProdFinEquiv.symm j).2).natAbs ≤ B*V
      rw [Int.natAbs_mul]
      exact Nat.mul_le_mul (hc _) (hv _)
    _ = (d*q)*(B*V) := by simp

/-- Exact lookup after a rounded-coordinate affine form, represented by an
actual constant-depth, polynomial-size threshold DAG. -/
def oneHotCoordinateTable {d q r : ℕ} (c : Fin d → ℤ) (values : Fin q → ℤ)
    (table : ℤ → Fin r) : CircuitMap (d*q) r :=
  oneHotAffine (coordinateTerms c values) table

@[simp] theorem oneHotCoordinateTable_eval {d q r : ℕ} (c : Fin d → ℤ)
    (values : Fin q → ℤ) (table : ℤ → Fin r) (a : Fin d → Fin q) (j : Fin r) :
    (oneHotCoordinateTable c values table).eval (oneHotState a) j =
      decide (table (∑ i, c i*values (a i))=j) := by
  simp [oneHotCoordinateTable, coordinateTerms_eval]

theorem oneHotCoordinateTable_depth {d q r : ℕ} (c : Fin d → ℤ)
    (values : Fin q → ℤ) (table : ℤ → Fin r) :
    (oneHotCoordinateTable c values table).depth ≤ 5 := oneHotAffine_depth _ _

theorem oneHotCoordinateTable_size {d q r : ℕ} (c : Fin d → ℤ)
    (values : Fin q → ℤ) (table : ℤ → Fin r)
    (B V : ℕ) (hc : ∀ i, (c i).natAbs ≤ B) (hv : ∀ j, (values j).natAbs ≤ V) :
    (oneHotCoordinateTable c values table).size ≤
      r*((8*((d*q)*(B*V))+9)*(2*((d*q)*(B*V))+1)+1) := by
  have h0 := oneHotAffine_size (coordinateTerms c values) table
  have hW := coordinateTerms_weight c values B V hc hv
  have hm := Nat.mul_le_mul
    (Nat.add_le_add_right (Nat.mul_le_mul_left 8 hW) 9)
    (Nat.add_le_add_right (Nat.mul_le_mul_left 2 hW) 1)
  exact h0.trans (Nat.mul_le_mul_left r (Nat.add_le_add_right hm 1))

#print axioms coordinateTerms_eval
#print axioms oneHotCoordinateTable_eval
#print axioms oneHotCoordinateTable_size
#print axioms oneHotCoordinateTable_depth
end ConditionalNonpolynomial.AnalyticLookup
