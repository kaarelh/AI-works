import PhysicalShortInitializerNumerics

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def readoutGridBudget (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index) : ℕ :=
  ⌈normalizingScale M.linearGain H*‖c‖⌉₊+1
 def readoutGridRange (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index) : ℕ :=
  M.readoutGridBudget c+Fintype.card M.PicardStateIndex*(M.readoutGridBudget c+1)*(M.gridStateRange+1)
 def selectedReadoutGrid (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index) (η : ℝ) :=
  (projectGridCoordinates (M.gridMesh η) M.gridStateRange (Sum.inr : M.PicardStateIndex→M.PicardInputIndex)).then
    (affineGridCircuit (fun _:Unit=>M.readoutCoefficient c) (fun _=>0)
      (M.gridMesh η) M.gridStateRange (M.readoutGridRange c))

 theorem readoutGridBudget_bound (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index) :
    ∀i,|M.readoutCoefficient c i|≤(M.readoutGridBudget c:ℝ) := by
  intro i
  apply (M.readoutCoefficient_bound c i).trans
  have hh:=Nat.le_ceil (normalizingScale M.linearGain H*‖c‖)
  unfold readoutGridBudget
  push_cast
  linarith

 theorem grid_readout_error (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) :
    2*((Fintype.card M.PicardStateIndex:ℝ)*((M.gridStateRange:ℝ)+1)+1)/(2*(M.gridMesh η:ℝ))≤η/2 := by
  have hcard : Fintype.card M.PicardStateIndex≤Fintype.card M.PicardInputIndex := by
    simp only [PicardInputIndex,Fintype.card_sum]
    omega
  have hb:=picard_weight_base (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) M.gridStateRange (Fintype.card M.PicardStateIndex) hcard
  have hnum : Fintype.card M.PicardStateIndex*(M.gridStateRange+1)+1≤
      (Fintype.card M.PicardStateIndex+1)*(Fintype.card M.PicardStateIndex*(M.gridStateRange+1)+2) := by
    have hh:=Nat.le_mul_of_pos_left (Fintype.card M.PicardStateIndex*(M.gridStateRange+1)+2)
      (show 0<Fintype.card M.PicardStateIndex+1 by omega)
    omega
  have hbr : ((Fintype.card M.PicardStateIndex:ℝ)*((M.gridStateRange:ℝ)+1)+1)≤
      (picardRoundingWeight (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
        (canonicalAmbientDimension states H) M.gridStateRange:ℝ) := by exact_mod_cast hnum.trans hb
  have hh:=picard_weight_rounding hη hbr
  change _/(2*(M.gridMesh η:ℝ))≤_ at hh
  calc
    _ = 2*(((Fintype.card M.PicardStateIndex:ℝ)*((M.gridStateRange:ℝ)+1)+1)/(2*(M.gridMesh η:ℝ))) := by ring
    _ ≤ 2*(η/4) := mul_le_mul_of_nonneg_left hh (by norm_num)
    _ = η/2 := by ring

 theorem selectedReadoutGrid_eval (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index)
    (η : ℝ) (hη : 0<η) (a : Fin (d+1)→ScalarCode (M.gridMesh η) M.gridStateRange)
    (u : M.PicardStateIndex→ScalarCode (M.gridMesh η) M.gridStateRange) :
    ∃b:Unit→ScalarCode (M.gridMesh η) (M.readoutGridRange c),
      (M.selectedReadoutGrid c η).eval (encodeCoordinateState (M.gridMesh η) M.gridStateRange (Sum.elim a u))=
        encodeCoordinateState (M.gridMesh η) (M.readoutGridRange c) b ∧
      |M.scalarReadout c (decodeCoordinates (M.gridMesh η) M.gridStateRange u)-
        scalarDecode (M.gridMesh η) (M.readoutGridRange c) (b ())|≤η/2 := by
  have hh:=affineGridCircuit_approximates (fun _:Unit=>M.readoutCoefficient c) (fun _=>0)
    (M.gridMesh η) (M.readoutGridBudget c) M.gridStateRange (M.readoutGridRange c)
    (M.gridMesh_pos η) (fun _=>M.readoutGridBudget_bound c) (fun _=>by simp) (le_refl _)
  obtain ⟨b,hb,he⟩:=hh u
  refine ⟨b,?_,?_⟩
  · unfold selectedReadoutGrid
    rw [CircuitMap.eval_then,projectGridCoordinates_eval]
    exact hb
  · have hcoord:=(PiLp.norm_apply_le (affineRealMap (fun _:Unit=>M.readoutCoefficient c) (fun _=>0)
      (decodeCoordinates (M.gridMesh η) M.gridStateRange u)-decodeCoordinates (M.gridMesh η) (M.readoutGridRange c) b) ()).trans he
    change |(0+∑i,M.readoutCoefficient c i*decodeCoordinates (M.gridMesh η) M.gridStateRange u i)-
      scalarDecode (M.gridMesh η) (M.readoutGridRange c) (b ())|≤_ at hcoord
    rw [zero_add,M.readoutCoefficient_eval,← M.scalarReadout_eval] at hcoord
    apply hcoord.trans
    convert M.grid_readout_error hη using 1
    all_goals try rfl
    all_goals simp only [PicardStateIndex,Fintype.card_prod,Fintype.card_fin,Fintype.card_unit,Nat.cast_one]
    all_goals ring

 theorem selectedReadoutGrid_depth (M : FiniteCanonicalDynamics P S states) (c : EuclideanSpace ℝ (states H).Index) (η : ℝ) :
    (M.selectedReadoutGrid c η).depth≤5 := by
  apply (CircuitMap.depth_then _ _).trans
  have hp : (projectGridCoordinates (M.gridMesh η) M.gridStateRange (Sum.inr : M.PicardStateIndex→M.PicardInputIndex)).depth=0 :=
    CircuitMap.rewire_depth _
  rw [hp,zero_add]
  exact affineGridCircuit_depth _ _ _ _ _

#print axioms selectedReadoutGrid_eval
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
