import VolterraGridInitialization

noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace VolterraGridSystem
variable {ζ ι : Type} [Fintype ζ] [Fintype ι] {H : ℕ}

def programGridSizeBudget (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) (j : Fin (H+1)) : ℕ :=
  let A:=P j
  let Qp:=A.mesh (B j) (M.stateRange+1) (M.tolerance η)
  coordinateRecodeSize (Fintype.card ι) (M.mesh η) M.stateRange Qp (M.stateRange+1)+
    A.sizeBudget Qp (B j) (M.stateRange+1)+
    coordinateRecodeSize (Fintype.card ι) Qp (A.outputRange (B j) (M.stateRange+1)) (M.mesh η) M.stateRange

lemma programGrid_size (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) (η : ℝ) (j : Fin (H+1)) :
    (M.programGrid P B η j).size≤M.programGridSizeBudget P B η j :=
  uniformProgramGrid_size (P j) (B j) (M.stateRange+1) (M.mesh η) M.stateRange (hB j) (M.tolerance η)

lemma programStep_size (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) (η : ℝ) :
    (M.programStep P B η).size≤
      (Fintype.card M.InputIndex*Fintype.card (ScalarGrid (M.mesh η) M.stateRange))*
      ((Fintype.card M.StateIndex*Fintype.card (ScalarGrid (M.mesh η) M.stateRange))*
        (∑j:Fin (H+1),M.programGridSizeBudget P B η j))+
      arithmeticLayerSize (Fintype.card M.InputIndex) (Fintype.card M.StateIndex) (M.mesh η) 1 M.stateRange M.affineRange+
      coordinateRecodeSize (Fintype.card M.StateIndex) (M.mesh η) M.affineRange (M.mesh η) M.stateRange := by
  apply parallelPicardCircuit_size _ _ _ _ _ _ _
    (by simpa only [Nat.cast_one] using M.coefficients_bound)
  intro j
  exact (M.programGrid_size P B hB η j).trans
    (Finset.single_le_sum (fun _ _=>Nat.zero_le _) (Finset.mem_univ j))

#print axioms programStep_size
end VolterraGridSystem
end ConditionalNonpolynomial.AnalyticLookup
