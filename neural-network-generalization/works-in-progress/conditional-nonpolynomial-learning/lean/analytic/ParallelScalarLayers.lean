import OneHotCoordinates

/-! Parallel scalar lookup stages, preserving separate coordinate one-hot
codes and polynomial resources for the full state. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

def parallelMaps {d m q : ℕ} (cs : Fin m → CircuitMap d q) : CircuitMap d (m*q) :=
  CircuitMap.ofCircuits fun z => (cs (finProdFinEquiv.symm z).1).select (finProdFinEquiv.symm z).2

@[simp] theorem parallelMaps_eval {d m q : ℕ} (cs : Fin m → CircuitMap d q)
    (x : Input d) (z : Fin (m*q)) :
    (parallelMaps cs).eval x z =
      (cs (finProdFinEquiv.symm z).1).eval x (finProdFinEquiv.symm z).2 := by
  simp [parallelMaps]

theorem parallelMaps_oneHot {d m q : ℕ} (cs : Fin m → CircuitMap d q)
    (x : Input d) (a : Fin m → Fin q)
    (h : ∀ j i, (cs j).eval x i = decide (a j=i)) :
    (parallelMaps cs).eval x = oneHotState a := by
  funext z
  exact (parallelMaps_eval cs x z).trans (h _ _)

theorem parallelMaps_size {d m q : ℕ} (cs : Fin m → CircuitMap d q)
    (S : ℕ) (h : ∀ j, (cs j).size ≤ S) :
    (parallelMaps cs).size ≤ (m*q)*S := by
  apply CircuitMap.size_ofCircuits_le
  intro z
  exact h (finProdFinEquiv.symm z).1

theorem parallelMaps_depth {d m q : ℕ} (cs : Fin m → CircuitMap d q)
    (D : ℕ) (h : ∀ j, (cs j).depth ≤ D) :
    (parallelMaps cs).depth ≤ D := by
  apply CircuitMap.depth_ofCircuits_le
  intro z
  exact h (finProdFinEquiv.symm z).1

/-- A complete scalar-grid arithmetic layer: any number of integer affine
forms, followed by arbitrary coordinatewise finite scalar tables. -/
def oneHotLayer {d m q r : ℕ} (c : Fin m → Fin d → ℤ) (values : Fin q → ℤ)
    (tables : Fin m → ℤ → Fin r) : CircuitMap (d*q) (m*r) :=
  parallelMaps fun j => oneHotCoordinateTable (c j) values (tables j)

@[simp] theorem oneHotLayer_eval {d m q r : ℕ} (c : Fin m → Fin d → ℤ)
    (values : Fin q → ℤ) (tables : Fin m → ℤ → Fin r) (a : Fin d → Fin q) :
    (oneHotLayer c values tables).eval (oneHotState a) =
      oneHotState (fun j => tables j (∑ i, c j i*values (a i))) := by
  apply parallelMaps_oneHot
  intro j i
  exact oneHotCoordinateTable_eval _ _ _ _ _

theorem oneHotLayer_depth {d m q r : ℕ} (c : Fin m → Fin d → ℤ)
    (values : Fin q → ℤ) (tables : Fin m → ℤ → Fin r) :
    (oneHotLayer c values tables).depth ≤ 5 :=
  parallelMaps_depth _ 5 (fun j => oneHotCoordinateTable_depth _ _ _)

theorem oneHotLayer_size {d m q r : ℕ} (c : Fin m → Fin d → ℤ)
    (values : Fin q → ℤ) (tables : Fin m → ℤ → Fin r)
    (B V : ℕ) (hc : ∀ j i, (c j i).natAbs ≤ B) (hv : ∀ i, (values i).natAbs ≤ V) :
    let W := (d*q)*(B*V)
    (oneHotLayer c values tables).size ≤ (m*r)*(r*((8*W+9)*(2*W+1)+1)) := by
  exact parallelMaps_size _ _ (fun j => oneHotCoordinateTable_size _ _ _ B V (hc j) hv)

#print axioms oneHotLayer_eval
#print axioms oneHotLayer_size
#print axioms oneHotLayer_depth
end ConditionalNonpolynomial.AnalyticLookup
