import NeuralGeneralization.BatchTwoActivationSharpAuxiliary
import NeuralGeneralization.BatchTwoActivationAuxiliaryCapacity

/-! The manuscript's cubic product-norm VC bound for the actual auxiliary
class, with constant `16`, before conversion from energy by AM–GM. -/
noncomputable section
set_option maxHeartbeats 1800000
set_option maxRecDepth 10000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

theorem auxiliaryOutput_abs_le {d H:ℕ} (W:AuxiliaryNetwork d H) {P R:ℝ} (hP:0≤P)
    (x:Cube d) (hx:‖concreteInput x‖≤R) : |auxiliaryOutput W P x|≤P*R := by
  have hs := auxiliaryFamilyState_sharp_norm_le (fun _:Unit=>W) (fun _:Fin 1=>x) (fun _=>hx) H () 0
  have hh := linearRow_abs_le W.readout W.readout_norm _ hs
  rw [auxiliaryOutput,abs_mul,abs_of_nonneg hP]
  exact mul_le_mul_of_nonneg_left hh hP

theorem shattering_product_scale_lower {d H n:ℕ} (hn:0<n) {P R:ℝ} (hP:0≤P)
    (x:Fin n→Cube d) (hx:∀i,‖concreteInput (x i)‖≤R)
    (hshatter:∀ε:Fin n→Bool,∃W:AuxiliaryNetwork d H,
      ∀i,(1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i)) :
    (1/2:ℝ)≤P*R := by
  obtain ⟨W,hW⟩ := hshatter (fun _=>true)
  have hm := hW ⟨0,hn⟩
  simp only [cubeCoordinateSign,ite_true,one_mul] at hm
  exact hm.trans ((le_abs_self _).trans (auxiliaryOutput_abs_le W hP _ (hx _)))

theorem sharp_capacity_from_moment {H n:ℕ} (hH:0<H) {P R:ℝ} (hP:0<P) (hR:0<R)
    (hPR:(1/2:ℝ)≤P*R)
    (hm : Real.exp ((1/(4*P*R^2))*((n:ℝ)/(2*P)))≤
      Real.exp ((H:ℝ)*(14*R/(1/(12*(H:ℝ)*P))+(1/(4*P*R^2))*((n:ℝ)*(1/(12*(H:ℝ)*P))))+
        (1/(4*P*R^2))*R*Real.sqrt n+(1/(4*P*R^2))^2*(n:ℝ)*R^2/2)) :
    (n:ℝ)≤(16*(H:ℝ)*P*R)^3 := by
  have hHr:(0:ℝ)<H := Nat.cast_pos.mpr hH
  have hH1:(1:ℝ)≤H := by exact_mod_cast hH
  have hsq := Real.sq_sqrt (Nat.cast_nonneg n (α:=ℝ))
  have hsqrt := Real.sqrt_nonneg (n:ℝ)
  have he := Real.exp_le_exp.mp hm
  have hs := mul_le_mul_of_nonneg_right he (by positivity : (0:ℝ)≤96*P^2*R^2)
  have hleft : ((1/(4*P*R^2))*((n:ℝ)/(2*P)))*(96*P^2*R^2)=12*(n:ℝ) := by
    field_simp;ring
  have hright : ((H:ℝ)*(14*R/(1/(12*(H:ℝ)*P))+(1/(4*P*R^2))*((n:ℝ)*(1/(12*(H:ℝ)*P))))+
      (1/(4*P*R^2))*R*Real.sqrt n+(1/(4*P*R^2))^2*(n:ℝ)*R^2/2)*(96*P^2*R^2)=
      16128*(H:ℝ)^2*(P*R)^3+5*(n:ℝ)+24*(P*R)*Real.sqrt n := by
    field_simp;ring
  rw [hleft,hright] at hs
  have hy : 24*(P*R)*Real.sqrt n≤(n:ℝ)+144*(P*R)^2 := by
    nlinarith [sq_nonneg (Real.sqrt n-12*(P*R))]
  have hcube : 0≤(P*R)^3 := by positivity
  have hlow : (P*R)^2≤2*(P*R)^3 := by
    nlinarith [mul_nonneg (sq_nonneg (P*R)) (show 0≤2*(P*R)-1 by linarith)]
  have hHsq:(1:ℝ)≤(H:ℝ)^2 := by nlinarith
  have hHcube : (H:ℝ)^2≤(H:ℝ)^3 := by
    nlinarith [mul_nonneg (sq_nonneg (H:ℝ)) (show 0≤(H:ℝ)-1 by linarith)]
  have hb := mul_le_mul_of_nonneg_right hHsq hcube
  have hb' := mul_le_mul_of_nonneg_right hHcube hcube
  have hh : (n:ℝ)≤4096*(H:ℝ)^3*(P*R)^3 := by nlinarith
  convert hh using 1 <;> ring

def sharpAuxiliaryCapacity (d H:ℕ) (P:ℝ) : ℕ :=
  ⌈(16*(H:ℝ)*P*Real.sqrt ((d:ℝ)+1))^3⌉₊

theorem auxiliary_shattering_sharp_card_le {d H n:ℕ} {P:ℝ} (hH:0<H) (hP:0<P)
    (x:Fin n→Cube d)
    (hshatter:∀ε:Fin n→Bool,∃W:AuxiliaryNetwork d H,
      ∀i,(1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i)) :
    n≤sharpAuxiliaryCapacity d H P := by
  by_cases hn:n=0
  · simp [hn]
  have hn0:0<n := Nat.pos_of_ne_zero hn
  let R := Real.sqrt ((d:ℝ)+1)
  have hR:0<R := Real.sqrt_pos.mpr (by positivity)
  have hHr:(0:ℝ)<H := Nat.cast_pos.mpr hH
  have hH1:(1:ℝ)≤H := by exact_mod_cast hH
  have hx:∀i,‖concreteInput (x i)‖≤R := fun i=>concreteInput_norm_le_sqrt (x i)
  have hPR := shattering_product_scale_lower hn0 hP.le x hx hshatter
  have hη : (0:ℝ)<1/(12*(H:ℝ)*P) := by positivity
  have hηR : 1/(12*(H:ℝ)*P)≤R := by
    apply (div_le_iff₀ (by positivity : (0:ℝ)<12*(H:ℝ)*P)).mpr
    have hh := mul_le_mul_of_nonneg_left hPR (show 0≤(H:ℝ) by positivity)
    nlinarith
  have hm := auxiliary_shattering_sharp_mgf hP hR hη hηR x hx hshatter (1/(4*P*R^2)) (by positivity)
  have hb := sharp_capacity_from_moment hH hP hR hPR hm
  dsimp [R] at hb
  unfold sharpAuxiliaryCapacity
  exact_mod_cast hb.trans (Nat.le_ceil _)

end NeuralGeneralization.BatchTwoActivation
