import NeuralGeneralization.BatchTwoOnlineReluStability
import NeuralGeneralization.BatchTwoOnlineReluTelescoping

/-! The exact square-root-depth perturbation radius of the online ReLU extension. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthPaper BatchTwoActivation
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem normalizedInput_cube_norm {d : ℕ} (hd : 0<d) (x : Cube d) :
    ‖normalizedInput (fun i=>labelReal (x i))‖≤Real.sqrt 2 := by
  have hdR : (1:ℝ)≤d := by exact_mod_cast hd
  have he : ‖normalizedInput (fun i=>labelReal (x i))‖^2=((d:ℝ)+1)/d := by
    simp only [EuclideanSpace.real_norm_sq_eq,normalizedInput,PiLp.toLp_apply,div_pow,
      Real.sq_sqrt (Nat.cast_nonneg d),← Finset.sum_div,augmentedInput_sq_sum]
    have hl : ∀i:Fin d,(labelReal (x i))^2=1 := by intro i; cases x i <;> norm_num [labelReal]
    simp [hl,add_comm]
  have hh : ((d:ℝ)+1)/d≤2 := (div_le_iff₀ (Nat.cast_pos.mpr hd)).mpr (by linarith)
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ)≤2),Real.sqrt_nonneg 2,
    norm_nonneg (normalizedInput (fun i=>labelReal (x i)))]

theorem normalizedLayerNorm_le_radius {d N r : ℕ} (v : Weights d N r)
    {ρ : ℝ} (hρ : 0≤ρ) (hv : ∑q,(v q)^2≤ρ^2) (i : Fin (r+2)) :
    normalizedLayerNorm v i≤ρ := by
  have hh : (normalizedLayerNorm v i)^2≤ρ^2 := by
    calc
      _ ≤ ∑j,(normalizedLayerNorm v j)^2 := Finset.single_le_sum (fun j _=>sq_nonneg _) (Finset.mem_univ i)
      _ = ∑q,(v q)^2 := normalizedLayerNorm_energy v
      _ ≤ _ := hv
  exact (sq_le_sq₀ (normalizedLayerNorm_nonneg v i) hρ).mp hh

theorem relu_balanced_perturbation {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (u v : Weights d N r) {A ρ : ℝ} (hA : 0≤A) (hρ : 0≤ρ) (hρone : ρ≤1)
    (hu : ∀i,normalizedLayerNorm u i≤A) (hv : ∑q,(v q)^2≤ρ^2) (x : Cube d) :
    |networkOutput relu (unwhiten (u+v)) x-networkOutput relu (unwhiten u) x|≤
      Real.sqrt (2*(r+2:ℝ))*ρ*(A+1)^(r+1) := by
  let y : RealInput d := fun i=>labelReal (x i)
  have hb : 0<A+1 := by linarith
  have hvj (j : ℕ) (hj : j<r+2) : layerNormAt v j≤ρ := by
    rw [layerNormAt, dif_pos hj]
    exact normalizedLayerNorm_le_radius v hρ hv _
  have huj (j : ℕ) (hj : j<r+2) : layerNormAt u j≤A := by
    rw [layerNormAt,dif_pos hj]
    exact hu _
  have hη (j : ℕ) (hj : j<r+2) : 0≤layerNormAt v j := by
    rw [layerNormAt,dif_pos hj]
    exact normalizedLayerNorm_nonneg v _
  have hnu : ∀j<r+2,normalizedNormTrace u y (j+1)≤(A+1)*normalizedNormTrace u y j := by
    intro j hj
    exact (normalizedNormTrace_step hN u y j hj).trans
      (mul_le_mul_of_nonneg_right (by linarith [huj j hj]) (normalizedNormTrace_nonneg u y j))
  have hne : ∀j<r+2,normalizedErrorTrace (u+v) u y (j+1)≤
      (A+1)*normalizedErrorTrace (u+v) u y j+layerNormAt v j*normalizedNormTrace u y j := by
    intro j hj
    apply (normalizedErrorTrace_step hN u v y j hj).trans
    apply add_le_add _ le_rfl
    apply mul_le_mul_of_nonneg_right (by linarith [huj j hj,hvj j hj])
    cases j with
    | zero => exact le_rfl
    | succ j => unfold normalizedErrorTrace; split <;> positivity
  have hsum : ∑j∈Finset.range (r+2),(layerNormAt v j)^2≤ρ^2 := by
    rw [←Fin.sum_univ_eq_sum_range]
    simp only [layerNormAt_fin,normalizedLayerNorm_energy]
    exact hv
  have hh := numerical_square_sum_error (by omega : 0<r+2)
    (normalizedNormTrace u y) (normalizedErrorTrace (u+v) u y) (layerNormAt v)
    (Real.sqrt_nonneg 2) hb hρ hη (normalizedInput_cube_norm hd x) le_rfl hnu hne hsum
  have hout : normalizedErrorTrace (u+v) u y (r+2)=
      |networkOutput relu (unwhiten (u+v)) x-networkOutput relu (unwhiten u) x| := by
    change (if r+1≤r then _ else _)=_
    rw [if_neg (by omega),normalizedOutput_eq_output hd hN,normalizedOutput_eq_output hd hN]
    rfl
  rw [hout] at hh
  convert hh using 1
  rw [Real.sqrt_mul (by norm_num : (0:ℝ)≤2)]
  norm_num only [Nat.cast_add,Nat.cast_ofNat,show r+2-1=r+1 by omega]

def reluPerturbationRadius (r : ℕ) (K : ℝ) : ℝ :=
  min 1 (4*Real.sqrt (2*(r+2:ℝ))*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1))⁻¹

theorem reluPerturbationRadius_pos (r : ℕ) (K : ℝ) : 0<reluPerturbationRadius r K := by
  unfold reluPerturbationRadius
  apply lt_min (by norm_num)
  positivity

theorem reluPerturbationRadius_le_one (r : ℕ) (K : ℝ) : reluPerturbationRadius r K≤1 := min_le_left _ _

theorem reluPerturbationRadius_amplification (r : ℕ) (K : ℝ) :
    Real.sqrt (2*(r+2:ℝ))*reluPerturbationRadius r K*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1)≤1/4 := by
  have hb : 0<4*Real.sqrt (2*(r+2:ℝ))*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1) := by positivity
  have hh := (le_div_iff₀ hb).mp (show reluPerturbationRadius r K≤1/(
    4*Real.sqrt (2*(r+2:ℝ))*(Real.sqrt (K/(r+2:ℝ))+1)^(r+1)) from by simpa only [one_div,reluPerturbationRadius] using (min_le_right (1:ℝ) _))
  nlinarith

end NeuralGeneralization.BatchTwoOnlineReluFinite
