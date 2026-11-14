import NeuralGeneralization.OnlineLowerSoftplusTeacher
import NeuralGeneralization.OnlineLowerSoftplusConcreteStatement
import NeuralGeneralization.ParityNetworkShallow

/-! Exact factor-24 teacher padding for the softplus manuscript theorem. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower OnlineLowerRelu

/-- The physical parity-code target uses the raw width and coefficient bounds
in the softplus theorem, with strict output margin greater than one. -/
theorem softplusConcrete_raw_teacher (k : ℕ) : SoftplusConcreteTeacher k := by
  have hm : 1 ≤ Family.logicalDim k := by rw [Family.logicalDim_eq]; omega
  have h := softplus_parityAnd_bounded_teacher hm
    (physicalBase (Family.size reluFixedRailSize k))
    (fun i => generatedSupport (physicalBase (Family.size reluFixedRailSize k))
      (coordinateGenerator (physicalColumn (Family.size reluFixedRailSize k) (Family.column k))) {i})
  simpa only [SoftplusConcreteTeacher,softplusConcreteTeacherWidth,Nat.cast_mul,Nat.cast_ofNat,
    reluConcreteTarget,reluFamilyTarget,physicalParityTarget,reluConcreteTeacherWidth,
    reluFamilyTeacherWidth,reluConcreteDimension,reluFamilyDimension] using h

/-- Padding changes neither the represented function nor its margin. The
coefficient bound becomes the new width, as required by `BoundedTeacher`. -/
theorem softplusConcrete_bounded_teacher (k : ℕ) :
    BoundedTeacher softplus (reluConcreteTarget k) (softplusConcreteTeacherWidth k) := by
  obtain ⟨w,hw,hb⟩ := softplusConcrete_raw_teacher k
  have hC : 1 ≤ reluConcreteTeacherWidth k := (reluConcrete_teacher_and_circuit k).1.1
  have hCN : reluConcreteTeacherWidth k ≤ softplusConcreteTeacherWidth k := by
    unfold softplusConcreteTeacherWidth
    omega
  obtain ⟨v,hv,hout⟩ := ParityNetwork.exists_padded_bounded
    (Nat.cast_nonneg (softplusConcreteTeacherWidth k)) hCN softplus w hb
  refine ⟨hC.trans hCN,v,?_,hv⟩
  intro x
  rw [hout x]
  exact (hw x).le

end NeuralGeneralization.OnlineLowerSoftplus
