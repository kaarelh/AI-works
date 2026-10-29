import ParallelPicardCircuit

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ ι J : Type*} [Fintype ζ] [Fintype ι] [Fintype J]

theorem parallelBlockCircuits_depth (Q N : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N))) (D : ℕ) (hc : ∀j,(cs j).depth≤D) :
    (parallelBlockCircuits Q N Q N cs).depth≤D := by
  apply parallelGridCircuits_depth _ _ _ D
  intro j
  exact (CircuitMap.depth_then _ _).trans (by simpa [projectGridCoordinates] using hc j)

theorem parallelBlockCircuits_size (Q N : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N))) (S : ℕ) (hc : ∀j,(cs j).size≤S) :
    (parallelBlockCircuits Q N Q N cs).size≤(Fintype.card (J×ι)*Fintype.card (ScalarGrid Q N))*S := by
  apply parallelGridCircuits_size _ _ _ S
  intro j
  simpa [projectGridCoordinates] using hc j

theorem residualCarryCircuit_depth (Q N : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N))) (D : ℕ) (hc : ∀j,(cs j).depth≤D) :
    (residualCarryCircuit (ζ:=ζ) Q N cs).depth≤D := by
  apply sumGridCircuits_depth _ _ D
  · simp [projectGridCoordinates]
  · exact (CircuitMap.depth_then _ _).trans
      (by simpa [projectGridCoordinates] using parallelBlockCircuits_depth Q N cs D hc)

theorem residualCarryCircuit_size (Q N : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N))) (S : ℕ) (hc : ∀j,(cs j).size≤S) :
    (residualCarryCircuit (ζ:=ζ) Q N cs).size≤
      (Fintype.card (ζ⊕(J×ι))*Fintype.card (ScalarGrid Q N))*
        ((Fintype.card (J×ι)*Fintype.card (ScalarGrid Q N))*S) := by
  have hh:=sumGridCircuits_size (projectGridCoordinates Q N (Sum.inl : ζ→ζ⊕(J×ι)))
    ((projectGridCoordinates Q N (Sum.inr : J×ι→ζ⊕(J×ι))).then
      (parallelBlockCircuits Q N Q N cs))
  simp only [CircuitMap.size_then,projectGridCoordinates,CircuitMap.rewire_size,zero_add] at hh
  exact hh.trans (Nat.mul_le_mul_left _ (parallelBlockCircuits_size Q N cs S hc))

def coordinateRecodeSize (di Q Ni Q' No : ℕ) : ℕ :=
  let qi:=2*(Q*Ni+1)+1
  let qo:=2*(Q'*No+1)+1
  let W:=(di*qi)*(Q*Ni+1)
  (di*qo)*(qo*((8*W+9)*(2*W+1)+1))

theorem coordinateRecodeSize_bound {κ : Type*} [Fintype κ] (Q Ni Q' No : ℕ) :
    (recodeCoordinates (ι:=κ) Q Ni Q' No).size≤coordinateRecodeSize (Fintype.card κ) Q Ni Q' No := by
  simpa only [coordinateRecodeSize,scalarGrid_card] using recodeCoordinates_size (ι:=κ) Q Ni Q' No

theorem parallelPicardCircuit_depth (Q B N V : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (C : (J×ι)→(ζ⊕(J×ι))→ℝ) (b : (J×ι)→ℝ)
    (D : ℕ) (hc : ∀j,(cs j).depth≤D) :
    (parallelPicardCircuit Q B N V cs C b).depth≤D+10 := by
  exact (CircuitMap.depth_then _ _).trans
    ((Nat.add_le_add ((CircuitMap.depth_then _ _).trans
      (Nat.add_le_add (residualCarryCircuit_depth Q N cs D hc) (affineGridCircuit_depth C b Q N V)))
      (recodeCoordinates_depth Q V Q N)).trans_eq (by omega))

theorem parallelPicardCircuit_size (Q B N V : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (C : (J×ι)→(ζ⊕(J×ι))→ℝ) (b : (J×ι)→ℝ)
    (hC : ∀j i,|C j i|≤(B:ℝ)) (S : ℕ) (hc : ∀j,(cs j).size≤S) :
    (parallelPicardCircuit Q B N V cs C b).size≤
      (Fintype.card (ζ⊕(J×ι))*Fintype.card (ScalarGrid Q N))*
        ((Fintype.card (J×ι)*Fintype.card (ScalarGrid Q N))*S)+
      arithmeticLayerSize (Fintype.card (ζ⊕(J×ι))) (Fintype.card (J×ι)) Q B N V+
      coordinateRecodeSize (Fintype.card (J×ι)) Q V Q N := by
  unfold parallelPicardCircuit
  rw [CircuitMap.size_then,CircuitMap.size_then]
  exact add_le_add (add_le_add (residualCarryCircuit_size Q N cs S hc)
    (affineGridCircuit_size C b Q B N V hC)) (coordinateRecodeSize_bound Q V Q N)

#print axioms parallelPicardCircuit_size
#print axioms parallelPicardCircuit_depth
end ConditionalNonpolynomial.AnalyticLookup
