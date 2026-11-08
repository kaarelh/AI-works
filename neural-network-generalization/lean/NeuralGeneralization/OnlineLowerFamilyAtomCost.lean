import NeuralGeneralization.OnlineLowerReluFamily
import NeuralGeneralization.OnlineLowerCostRailBridge
import NeuralGeneralization.OnlineLowerGammaCost

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerBernstein

def targetSupport (R k:ℕ) (s:Finset (Fin (logicalDim k))) : Finset (Fin (railDimension (size R k))) :=
  generatedSupport (physicalBase (size R k))
    (coordinateGenerator (physicalColumn (size R k) (column k))) s

theorem support_card_eq_columnDegree (R k:ℕ) (s:Finset (Fin (logicalDim k))) :
    ((targetSupport R k s).card:ℝ)=
      columnDegree ((pairDim k*R:ℕ):ℝ) (column k) (fun j=>(increment k j:ℝ)) (negativeBitsCube s) := by
  rw [targetSupport,support_card,columnDegree_railOrientation]
  push_cast
  rfl

theorem targetSupport_even (R k:ℕ) (hR:Even R) (s:Finset (Fin (logicalDim k))) :
    Even (targetSupport R k s).card :=
  physical_generatedSupport_even _ _ _ (size_even R k hR)

theorem targetSupport_card_ge_two (R k:ℕ) (hR:2≤R) (s:Finset (Fin (logicalDim k))) :
    2≤(targetSupport R k s).card := by
  have h := (support_card_bounds R k s).1
  have hp : 1≤pairDim k := by rw [pairDim_eq]; omega
  change 2≤(generatedSupport _ _ _).card
  nlinarith

/-- The scalar Gamma cost used to order candidates is exactly the inverse
balanced ReLU coefficient of the actual physical support. -/
theorem actual_atom_cost (R k:ℕ) (hR:2≤R) (heven:Even R)
    (s:Finset (Fin (logicalDim k))) :
    gammaCost (columnDegree ((pairDim k*R:ℕ):ℝ) (column k)
      (fun j=>(increment k j:ℝ)) (negativeBitsCube s)) =
      Real.sqrt (targetSupport R k s).card /
        ((Nat.choose ((targetSupport R k s).card-2)
          (((targetSupport R k s).card-2)/2):ℝ)/(2:ℝ)^((targetSupport R k s).card-1)) := by
  rw [←support_card_eq_columnDegree]
  exact gammaCost_nat_even (targetSupport_card_ge_two R k hR s) (targetSupport_even R k heven s)

end NeuralGeneralization.OnlineLowerRelu.Family
