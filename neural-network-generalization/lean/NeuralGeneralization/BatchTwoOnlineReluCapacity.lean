import NeuralGeneralization.BatchTwoOnlineReluPeeling

/-! The literal quadratic product-norm shattering bound for ReLU. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 800000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

theorem relu_shattering_mgf {d H n:ℕ} {P R:ℝ} (hP:0<P)
    (hR:0<R) (x:Fin n→Cube d)
    (hx:∀i,‖concreteInput (x i)‖≤R)
    (hshatter:∀ε:Fin n→Bool,∃W:AuxiliaryNetwork d H, IsReluAuxiliary W ∧
      ∀i,(1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i))
    (a:ℝ) (ha:0≤a) :
    Real.exp (a*((n:ℝ)/(2*P)))≤
      Real.exp ((H:ℝ)*Real.log 2+a*R*Real.sqrt n+a^2*(n:ℝ)*R^2/2) := by
  classical
  choose W hrelu hW using hshatter
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
  exact hh.trans (relu_auxiliaryFamilyState_mgf W hrelu x hR.le hx a ha H)


def reluDepthFactor (H : ℕ) : ℝ := 1+Real.sqrt (2*(H:ℝ)*Real.log 2)
def reluProductCapacity (d H : ℕ) (P : ℝ) : ℕ :=
  ⌈4*((d:ℝ)+1)*P^2*(reluDepthFactor H)^2⌉₊

theorem relu_capacity_from_moments {H n : ℕ} (hH : 0<H) (hn : 0<n)
    {P R : ℝ} (hP : 0<P) (hR : 0<R)
    (hm : ∀a:ℝ,0≤a→Real.exp (a*((n:ℝ)/(2*P)))≤
      Real.exp ((H:ℝ)*Real.log 2+a*R*Real.sqrt n+a^2*(n:ℝ)*R^2/2)) :
    (n:ℝ)≤4*R^2*P^2*(reluDepthFactor H)^2 := by
  let s := Real.sqrt (n:ℝ)
  let b := Real.sqrt (2*(H:ℝ)*Real.log 2)
  have hs : 0<s := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hn)
  have hb : 0<b := Real.sqrt_pos.mpr
    (mul_pos (mul_pos (by norm_num) (Nat.cast_pos.mpr hH)) (Real.log_pos (by norm_num)))
  have hs2 : s^2=(n:ℝ) := Real.sq_sqrt (Nat.cast_nonneg n)
  have hb2 : b^2=2*(H:ℝ)*Real.log 2 := Real.sq_sqrt
    (mul_nonneg (by positivity) (Real.log_nonneg (by norm_num)))
  let a := b/(R*s)
  have ha : 0≤a := by dsimp [a]; positivity
  have he := Real.exp_le_exp.mp (hm a ha)
  change a*((n:ℝ)/(2*P))≤(H:ℝ)*Real.log 2+a*R*s+a^2*(n:ℝ)*R^2/2 at he
  have hh := mul_le_mul_of_nonneg_right he (show 0≤2*P*R*s by positivity)
  have hleft : (a*((n:ℝ)/(2*P)))*(2*P*R*s)=b*s^2 := by
    rw [←hs2]
    dsimp [a]
    field_simp
  have hright : ((H:ℝ)*Real.log 2+a*R*s+a^2*(n:ℝ)*R^2/2)*(2*P*R*s)=
      (b*s)*(2*P*R*(1+b)) := by
    rw [←hs2, show (H:ℝ)*Real.log 2=b^2/2 by linarith]
    dsimp [a]
    field_simp
    ring
  rw [hleft,hright] at hh
  have hsbound : s≤2*P*R*(1+b) := by
    apply (mul_le_mul_iff_right₀ (mul_pos hb hs)).mp
    convert hh using 1 <;> ring
  have hsq := pow_le_pow_left₀ hs.le hsbound 2
  rw [hs2] at hsq
  calc
    (n:ℝ) ≤ (2*P*R*(1+b))^2 := hsq
    _ = 4*R^2*P^2*(reluDepthFactor H)^2 := by
      change (2*P*R*(1+b))^2 = 4*R^2*P^2*(1+b)^2
      ring

theorem relu_shattering_card_le {d H n : ℕ} (hH : 0<H) {P : ℝ} (hP : 0<P)
    (x : Fin n→Cube d)
    (hshatter : ∀ε:Fin n→Bool,∃W:AuxiliaryNetwork d H,IsReluAuxiliary W ∧
      ∀i,(1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i)) :
    n≤reluProductCapacity d H P := by
  by_cases hn:n=0
  · simp [hn]
  have hR : 0<Real.sqrt ((d:ℝ)+1) := Real.sqrt_pos.mpr (by positivity)
  have hb := relu_capacity_from_moments hH (Nat.pos_of_ne_zero hn) hP hR
    (fun a ha => relu_shattering_mgf hP hR x (fun i=>concreteInput_norm_le_sqrt (x i)) hshatter a ha)
  rw [Real.sq_sqrt (by positivity)] at hb
  unfold reluProductCapacity
  exact_mod_cast hb.trans (Nat.le_ceil _)

end NeuralGeneralization.BatchTwoActivation
