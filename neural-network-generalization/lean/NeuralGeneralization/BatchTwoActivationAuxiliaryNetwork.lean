import NeuralGeneralization.BatchTwoActivationPolynomialCapacity

/-!
# A common class of heterogeneous auxiliary networks

This class allows a different globally 1-Lipschitz zero-at-zero activation at
every neuron and layer. All widths vary freely. Its capacity therefore applies
to the normalized tail atoms as well as the bounded bulk features; it makes no
claim that the learner itself changes activations.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

abbrev auxiliaryWidth (d : ℕ) (w : ℕ→ℕ) : ℕ→ℕ
  | 0 => d+1
  | s+1 => w s

structure AuxiliaryNetwork (d H : ℕ) where
  width : ℕ→ℕ
  width_pos : ∀s, 0<width s
  activation : ∀s, Fin (auxiliaryWidth d width (s+1))→UnitActivation
  rows : ∀s, Fin (auxiliaryWidth d width (s+1))→
    EuclideanSpace ℝ (Fin (auxiliaryWidth d width s))
  row_energy : ∀s, (∑ j, ‖rows s j‖^2)≤1
  readout : EuclideanSpace ℝ (Fin (auxiliaryWidth d width H))
  readout_norm : ‖readout‖≤1

def auxiliaryFamilyState {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d) :
    ∀s p, Fin n→EuclideanSpace ℝ (Fin (auxiliaryWidth d (W p).width s)) :=
  matrixFamilyState (fun s p => auxiliaryWidth d (W p).width s)
    (fun s p => (W p).activation s) (fun s p => (W p).rows s)
    (fun _ i => concreteInput (x i))

def auxiliaryOutput {d H : ℕ} (W : AuxiliaryNetwork d H) (P : ℝ) (x : Cube d) : ℝ :=
  P*⟪W.readout, auxiliaryFamilyState (fun _ : Unit => W) (fun _ : Fin 1 => x) H () 0⟫

theorem auxiliaryFamilyState_pointwise {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d) (p : U) (i : Fin n) (s : ℕ) :
    auxiliaryFamilyState W x s p i=
      auxiliaryFamilyState (fun _ : Unit => W p) (fun _ : Fin 1 => x i) s () 0 := by
  induction s with
  | zero => rfl
  | succ s ih =>
    apply PiLp.ext
    intro j
    change ((W p).activation s j).val ⟪(W p).rows s j,auxiliaryFamilyState W x s p i⟫=_
    rw [ih]
    rfl

theorem auxiliaryFamilyState_norm_le {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d) (s : ℕ) :
    ∀p i, ‖auxiliaryFamilyState W x s p i‖≤(d:ℝ)+1 := by
  apply matrixFamilyState_norm_le
    (fun s p => auxiliaryWidth d (W p).width s) ?_ _ _ _
    (fun s p => (W p).row_energy s) (fun _ i => concreteInput_norm_le (x i)) s
  intro s p
  cases s with
  | zero => simp only [auxiliaryWidth]; omega
  | succ s => exact (W p).width_pos s

theorem auxiliaryFamilyState_mgf {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d)
    {q : ℕ} (hq : 0<q) (a : ℝ) (ha : 0≤a) (s : ℕ) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (auxiliaryFamilyState W x s) ε))≤
      (activationPeelingFactor n q ((d:ℝ)+1) a)^s *
        (2*((d:ℝ)+1)*Real.exp (a^2*((d:ℝ)+1)*n/2)) := by
  have hdim : ∀s p, 0<auxiliaryWidth d (W p).width s := by
    intro s p
    cases s with
    | zero => simp only [auxiliaryWidth]; omega
    | succ s => exact (W p).width_pos s
  have h := matrixFamilyState_mgf hq (fun s p => auxiliaryWidth d (W p).width s)
    hdim (fun s p => (W p).activation s) (fun s p => (W p).rows s)
    (fun _ i => concreteInput (x i)) (fun s p => (W p).row_energy s)
    (by positivity : (0:ℝ)<(d:ℝ)+1) (fun _ i => concreteInput_norm_le (x i)) a ha s
  have he (ε : Fin n→Bool) : dependentVectorProcess
      (fun (_ : U) i => concreteInput (x i)) ε=
      ‖∑ i, cubeCoordinateSign (ε i) • concreteInput (x i)‖ := by
    simp only [dependentVectorProcess,processSup,Set.range_const,csSup_singleton]
  change finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
    (auxiliaryFamilyState W x s) ε))≤
    (activationPeelingFactor n q ((d:ℝ)+1) a)^s *
      finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
        (fun (_ : U) i => concreteInput (x i)) ε)) at h
  simp_rw [he] at h
  have hi := input_vector_sign_mgf n (fun i => concreteInput (x i))
    (fun i j => concreteInput_abs_le (x i) j) a ha
  simp only [Fintype.card_fin,Nat.cast_add,Nat.cast_one] at hi
  exact h.trans (mul_le_mul_of_nonneg_left hi
    (pow_nonneg (activationPeelingFactor_nonneg _ _ _ _) _))

theorem auxiliary_shattering_mgf {d H n : ℕ} {P : ℝ} (hP : 0<P)
    (x : Fin n→Cube d)
    (hshatter : ∀ε : Fin n→Bool, ∃W : AuxiliaryNetwork d H,
      ∀i, (1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i))
    {q : ℕ} (hq : 0<q) (a : ℝ) (ha : 0≤a) :
    Real.exp (a*((n:ℝ)/(2*P)))≤
      (activationPeelingFactor n q ((d:ℝ)+1) a)^H *
        (2*((d:ℝ)+1)*Real.exp (a^2*((d:ℝ)+1)*n/2)) := by
  classical
  choose W hW using hshatter
  let Z := auxiliaryFamilyState W x H
  have hZ := auxiliaryFamilyState_norm_le W x H
  have hlo (ε : Fin n→Bool) : (n:ℝ)/(2*P)≤dependentVectorProcess Z ε := by
    have hs : (n:ℝ)/2≤∑ i, cubeCoordinateSign (ε i)*auxiliaryOutput (W ε) P (x i) := by
      calc
        _ = ∑ _i : Fin n, (1/2:ℝ) := by simp; ring
        _ ≤ _ := Finset.sum_le_sum (fun i _ => hW ε i)
    have hid : (∑ i, cubeCoordinateSign (ε i)*auxiliaryOutput (W ε) P (x i))=
        P*⟪(W ε).readout,∑ i, cubeCoordinateSign (ε i) • Z ε i⟫ := by
      simp only [inner_sum,real_inner_smul_right,Finset.mul_sum,auxiliaryOutput]
      apply Finset.sum_congr rfl
      intro i _
      rw [show Z ε i=auxiliaryFamilyState (fun _ : Unit => W ε)
        (fun _ : Fin 1 => x i) H () 0 from auxiliaryFamilyState_pointwise W x ε i H]
      ring
    rw [hid] at hs
    have hh := linearRow_abs_le (W ε).readout (W ε).readout_norm
      (∑ i, cubeCoordinateSign (ε i) • Z ε i)
      (norm_le_dependentVectorProcess Z hZ ε ε)
    have he : (n:ℝ)/2≤P*dependentVectorProcess Z ε :=
      hs.trans (mul_le_mul_of_nonneg_left ((le_abs_self _).trans hh) hP.le)
    apply (div_le_iff₀ (mul_pos (by norm_num) hP)).mpr
    linarith
  have h := finiteMean_mono (fun ε => Real.exp_le_exp.mpr
    (mul_le_mul_of_nonneg_left (hlo ε) ha))
  rw [finiteMean_const] at h
  exact h.trans (auxiliaryFamilyState_mgf W x hq a ha H)

end NeuralGeneralization.BatchTwoActivation
