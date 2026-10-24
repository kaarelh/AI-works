import NeuralGeneralization.BatchTwoActivationSharpPeeling
import NeuralGeneralization.BatchTwoActivationSharpInputMoment
import NeuralGeneralization.BatchTwoActivationAuxiliaryNetwork

/-! Optimized exponential moment for actual normalized auxiliary networks. -/
noncomputable section
set_option maxHeartbeats 1200000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

theorem concreteInput_norm_le_sqrt (x : Cube d) : ‖concreteInput x‖≤Real.sqrt ((d:ℝ)+1) := by
  have hs : ‖concreteInput x‖^2≤(d:ℝ)+1 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    calc
      _≤∑_i:Fin (d+1),(1:ℝ) := by
        apply Finset.sum_le_sum
        intro i _
        simpa only [sq_abs,one_pow] using pow_le_pow_left₀ (abs_nonneg _) (concreteInput_abs_le x i) 2
      _=_ := by simp
  nlinarith [Real.sq_sqrt (by positivity : (0:ℝ)≤(d:ℝ)+1),Real.sqrt_nonneg ((d:ℝ)+1),norm_nonneg (concreteInput x)]

theorem auxiliaryFamilyState_sharp_norm_le {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d) {R:ℝ}
    (hx : ∀i,‖concreteInput (x i)‖≤R) (s : ℕ) :
    ∀p i,‖auxiliaryFamilyState W x s p i‖≤R := by
  apply matrixFamilyState_norm_le (fun s p=>auxiliaryWidth d (W p).width s) ?_ _ _ _
    (fun s p=>(W p).row_energy s) (fun _ i=>hx i) s
  intro s p
  cases s with
  | zero => simp only [auxiliaryWidth];omega
  | succ s => exact (W p).width_pos s

theorem auxiliaryFamilyState_sharp_mgf {U : Type*} [Nonempty U] {d H n : ℕ}
    (W : U→AuxiliaryNetwork d H) (x : Fin n→Cube d)
    {R η : ℝ} (hR:0<R) (hη:0<η) (hηR:η≤R)
    (hx:∀i,‖concreteInput (x i)‖≤R) (a:ℝ) (ha:0≤a) (s:ℕ) :
    finiteMean (fun ε:Fin n→Bool=>Real.exp (a*dependentVectorProcess (auxiliaryFamilyState W x s) ε))≤
      Real.exp ((s:ℝ)*(14*R/η+a*((n:ℝ)*η))+a*R*Real.sqrt n+a^2*(n:ℝ)*R^2/2) := by
  have hdim : ∀s p,0<auxiliaryWidth d (W p).width s := by
    intro s p
    cases s with
    | zero => simp only [auxiliaryWidth];omega
    | succ s => exact (W p).width_pos s
  have hh := normalizedFamilyState_sharp_mgf (fun s p=>auxiliaryWidth d (W p).width s) hdim
    (matrixRowActivation (fun s p=>auxiliaryWidth d (W p).width s)
      (fun s p=>(W p).activation s) (fun s p=>(W p).rows s))
    (fun s p j=>‖(W p).rows s j‖) (fun s p j=>unitDirection ((W p).rows s j))
    (fun _ i=>concreteInput (x i)) (fun s p=>(W p).row_energy s)
    (fun _ _ _=>norm_unitDirection_le _) hR hη hηR (fun _ i=>hx i) a ha s
  rw [←matrixFamilyState_eq_normalized] at hh
  change finiteMean (fun ε:Fin n→Bool=>Real.exp (a*dependentVectorProcess (auxiliaryFamilyState W x s) ε))≤_ at hh
  have he (ε:Fin n→Bool) : dependentVectorProcess (fun (_:U) i=>concreteInput (x i)) ε=
      ‖∑i,cubeCoordinateSign (ε i)•concreteInput (x i)‖ := by
    simp only [dependentVectorProcess,processSup,Set.range_const,csSup_singleton]
  simp_rw [he] at hh
  have hi := sharp_input_vector_sign_mgf n (fun i=>concreteInput (x i)) hR.le hx ha
  apply (hh.trans (mul_le_mul_of_nonneg_left hi (Real.exp_pos _).le)).trans_eq
  rw [←Real.exp_add]
  congr 1
  ring

theorem auxiliary_shattering_sharp_mgf {d H n:ℕ} {P R η:ℝ} (hP:0<P)
    (hR:0<R) (hη:0<η) (hηR:η≤R) (x:Fin n→Cube d)
    (hx:∀i,‖concreteInput (x i)‖≤R)
    (hshatter:∀ε:Fin n→Bool,∃W:AuxiliaryNetwork d H,
      ∀i,(1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i))
    (a:ℝ) (ha:0≤a) :
    Real.exp (a*((n:ℝ)/(2*P)))≤
      Real.exp ((H:ℝ)*(14*R/η+a*((n:ℝ)*η))+a*R*Real.sqrt n+a^2*(n:ℝ)*R^2/2) := by
  classical
  choose W hW using hshatter
  let Z := auxiliaryFamilyState W x H
  have hZ := auxiliaryFamilyState_sharp_norm_le W x hx H
  have hlo (ε:Fin n→Bool) : (n:ℝ)/(2*P)≤dependentVectorProcess Z ε := by
    have hs : (n:ℝ)/2≤∑i,cubeCoordinateSign (ε i)*auxiliaryOutput (W ε) P (x i) := by
      calc
        _=∑_i:Fin n,(1/2:ℝ) := by simp;ring
        _≤_ := Finset.sum_le_sum (fun i _=>hW ε i)
    have hid : (∑i,cubeCoordinateSign (ε i)*auxiliaryOutput (W ε) P (x i))=
        P*⟪(W ε).readout,∑i,cubeCoordinateSign (ε i)•Z ε i⟫ := by
      simp only [inner_sum,real_inner_smul_right,Finset.mul_sum,auxiliaryOutput]
      apply Finset.sum_congr rfl
      intro i _
      rw [show Z ε i=auxiliaryFamilyState (fun _:Unit=>W ε) (fun _:Fin 1=>x i) H () 0 from
        auxiliaryFamilyState_pointwise W x ε i H]
      ring
    rw [hid] at hs
    have he := linearRow_abs_le (W ε).readout (W ε).readout_norm
      (∑i,cubeCoordinateSign (ε i)•Z ε i) (norm_le_dependentVectorProcess Z hZ ε ε)
    have hle := hs.trans (mul_le_mul_of_nonneg_left ((le_abs_self _).trans he) hP.le)
    apply (div_le_iff₀ (mul_pos (by norm_num) hP)).mpr
    linarith
  have hh := finiteMean_mono (fun ε=>Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (hlo ε) ha))
  rw [finiteMean_const] at hh
  exact hh.trans (auxiliaryFamilyState_sharp_mgf W x hR hη hηR hx a ha H)

end NeuralGeneralization.BatchTwoActivation
