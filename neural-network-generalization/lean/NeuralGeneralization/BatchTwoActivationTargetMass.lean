import NeuralGeneralization.BatchTwoActivationCylinderGeometry
import NeuralGeneralization.BatchTwoActivationTeacherStates
import NeuralGeneralization.RobustTargetProbability

/-! Actual Gaussian target mass for arbitrary zero-at-zero Lipschitz activations,
at every learner width and every scale at least as strong as mean field. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling BatchTwoMerging
variable {d C N r k p : ℕ}

def activationTeacherEnergy (d C r : ℕ) : ℝ :=
  18*((d:ℝ)*(d+1)*C^2+(r+1)*C^4)

def activationOutputFactor (d C r : ℕ) (ℓ : ℝ) : ℝ :=
  generalCylinderOutputFactor d r ℓ (teacherStateBound d C r ℓ)
    (activationTeacherEnergy d C r) (C+1) (16*((r:ℝ)+1))

def activationCylinderRadius (d C r : ℕ) (ℓ : ℝ) : ℝ :=
  1/(4*(activationOutputFactor d C r ℓ+1))

def activationTargetCost (d C r : ℕ) (ℓ : ℝ) : ℝ :=
  robustCylinderCost d r (activationTeacherEnergy d C r) (C+1)
    (activationCylinderRadius d C r ℓ)

/-- A literal polynomial in d and C at fixed r and ℓ. In particular no
learner width, logarithm, reciprocal, or ceiling occurs in this bound. -/
def activationTargetPolynomial (d C r : ℕ) (ℓ : ℝ) : ℝ :=
  activationTeacherEnergy d C r+((d:ℝ)+2+(r:ℝ)*(C+1))*
    (1+2*Real.sqrt (2*Real.pi)*(activationOutputFactor d C r ℓ+1))+1

theorem activationOutputFactor_nonneg (d C r : ℕ) (ℓ : ℝ) :
    0≤activationOutputFactor d C r ℓ := by
  unfold activationOutputFactor generalCylinderOutputFactor generalCylinderInputFactor
    generalCylinderAmplification activationTeacherEnergy cylinderInputFactor
  positivity

theorem activationCylinderRadius_bounds (d C r : ℕ) (ℓ : ℝ) :
    0<activationCylinderRadius d C r ℓ ∧ activationCylinderRadius d C r ℓ≤1 ∧
      (activationCylinderRadius d C r ℓ)^2*activationOutputFactor d C r ℓ≤1/16 := by
  have hF := activationOutputFactor_nonneg d C r ℓ
  have hp : 0<4*(activationOutputFactor d C r ℓ+1) := by positivity
  refine ⟨one_div_pos.mpr hp, ?_, ?_⟩
  · unfold activationCylinderRadius
    apply (div_le_iff₀ hp).mpr
    linarith
  · unfold activationCylinderRadius
    rw [div_pow]
    norm_num only [one_pow]
    rw [div_mul_eq_mul_div,one_mul]
    apply (div_le_iff₀ (sq_pos_of_pos hp)).mpr
    nlinarith [sq_nonneg (activationOutputFactor d C r ℓ)]

theorem activationTargetCost_le_polynomial (d C r : ℕ) (ℓ : ℝ) :
    activationTargetCost d C r ℓ≤activationTargetPolynomial d C r ℓ := by
  obtain ⟨hρ,hρ1,_⟩ := activationCylinderRadius_bounds d C r ℓ
  have hρsq : (activationCylinderRadius d C r ℓ)^2≤1 := by nlinarith
  have hF := activationOutputFactor_nonneg d C r ℓ
  have hden : 4*(activationOutputFactor d C r ℓ+1)≠0 := by positivity
  have heq : Real.sqrt (2*Real.pi)/(2*activationCylinderRadius d C r ℓ)=
      2*Real.sqrt (2*Real.pi)*(activationOutputFactor d C r ℓ+1) := by
    unfold activationCylinderRadius
    field_simp
    <;> ring
  unfold activationTargetCost activationTargetPolynomial robustCylinderCost
  rw [heq]
  gcongr

theorem exists_adapted_activation_clone (hk : 0<k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (φ : ℝ→ℝ) (w : Weights d C r) :
    ∃(b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N)),
    J.card≤C+1 ∧
    (∀s i j,j∉J→basisCoordinates b
      (fun a=>clonedWeights e w (Sum.inr (Sum.inl (s,i,a)))) j=0) ∧
    (∀(x : Cube d) (ss : List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep φ (clonedWeights e w))
        (firstHidden φ (clonedWeights e w) x)) j=0) := by
  let S := cloneSubspace e
  let u : (Fin N→ℝ)≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) :=
    (WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map u.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card≤C+1 := by
    rw [hJ]
    change Module.finrank ℝ (S.map u.toLinearMap)≤C+1
    rw [LinearEquiv.finrank_map_eq]
    exact cloneSubspace_finrank_le e
  have hsupport (z : Fin N→ℝ) (hz : z∈S) : ∀j,j∉J→basisCoordinates b z j=0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [← hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨b,J,hcard,
    fun s i=>hsupport _ (cloned_internalRow_mem_cloneSubspace e w s i),
    fun x ss=>hsupport _ (hiddenFold_cloned_mem_cloneSubspace hk φ e w x ss)⟩

theorem activation_target_mass_cloned (hd : 0<d) (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) {φ : ℝ→ℝ} {ℓ : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (w : Weights d C r) (hw : boundedWeights C w) (f : BooleanFunction d)
    (hf : w∈marginEvent φ (1/2) f) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-activationTargetCost d C r ℓ/σ^2)≤
      (smallPrior d N r σ).real (marginEvent φ (1/2) f) := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  let v := clonedWeights e (rescaleReadout 3 w)
  have hcost : weightedSquaredNorm v≤activationTeacherEnergy d C r := by
    have h1 := weightedSquaredNorm_cloned_le hC hk hbelow habove e (rescaleReadout 3 w)
    have h2 := rescaleReadout_cost_le (by norm_num : (1:ℝ)≤3) w
    have h3 := weightedSquaredNorm_bounded_teacher hC w hw
    unfold activationTeacherEnergy
    dsimp [v]
    nlinarith
  obtain ⟨b,J,hJ,hrows,hhidden⟩ := exists_adapted_activation_clone hk e φ (rescaleReadout 3 w)
  have hJ' : (J.card:ℝ)≤(C:ℝ)+1 := by exact_mod_cast hJ
  obtain ⟨hρ,hρ1,herr⟩ := activationCylinderRadius_bounds d C r ℓ
  have hmass := robustCoordinateCylinder_mass hd hN v b J hρ hσ hscale hJ' hcost
  apply hmass.trans
  apply measureReal_mono _ (measure_ne_top _ _)
  intro z hz x
  have hgeom := activation_cylinder_error hd hN hφ hℓ (teacherStateBound_ge_one d C r hℓ)
    v z b J (by unfold activationTeacherEnergy; positivity) (by positivity : (0:ℝ)≤C+1)
    hρ.le hρ1 hσ.le hscale hJ' hcost hrows hhidden
    (fun x ss i hlen => cloned_teacher_hidden_bound hC hk hφ hℓ e w hw 3 x ss i hlen) hz x
  have hs : (networkOutput φ z x-networkOutput φ v x)^2≤1/16 := hgeom.trans herr
  have he : |networkOutput φ z x-networkOutput φ v x|≤1/4 := by
    have hh : (networkOutput φ z x-networkOutput φ v x)^2≤((1:ℝ)/4)^2 := by norm_num at hs ⊢; exact hs
    exact (sq_le_sq₀ (abs_nonneg _) (by norm_num)).mp (by simpa only [sq_abs] using hh)
  have hvout : networkOutput φ v x=3*networkOutput φ w x := by
    dsimp [v]
    rw [networkOutput_cloned hk,rescaleReadout_output]
  have hlabel : |labelReal (f x)*(networkOutput φ z x-networkOutput φ v x)|≤1/4 := by
    simpa only [abs_mul,abs_labelReal,one_mul] using he
  have hlower := (abs_le.mp hlabel).1
  rw [hvout] at hlower
  have hfx := hf x
  change (1:ℝ)/2<labelReal (f x)*networkOutput φ z x
  nlinarith

theorem activation_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    {φ : ℝ→ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (w : Weights d C r) (hw : boundedWeights C w) (f : BooleanFunction d)
    (hf : w∈marginEvent φ (1/2) f) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-activationTargetCost d C r ℓ/σ^2)≤
      (smallPrior d N r σ).real (marginEvent φ (1/2) f) := by
  classical
  let k := N/C
  have hk : 0<k := Nat.div_pos hCN hC
  have hmod : N%C<C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k≤N := by omega
  have hCk : C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N≤2*C*k := by nlinarith
  let e : ((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  exact activation_target_mass_cloned hd hC hk hbelow habove e hφ hℓ w hw f hf hσ hscale

/-- Polynomial-cost target cylinder, with the same constant at every width
and every Gaussian scale Nσ²≤1. -/
theorem activation_target_polynomial_mass (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    {φ : ℝ→ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ)
    (w : Weights d C r) (hw : boundedWeights C w) (f : BooleanFunction d)
    (hf : w∈marginEvent φ (1/2) f) {σ : ℝ} (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-activationTargetPolynomial d C r ℓ/σ^2)≤
      (smallPrior d N r σ).real (marginEvent φ (1/2) f) := by
  apply (Real.exp_le_exp.mpr ?_).trans
    (activation_target_mass_all_widths hd hC hCN hφ hℓ w hw f hf hσ hscale)
  exact div_le_div_of_nonneg_right (neg_le_neg (activationTargetCost_le_polynomial d C r ℓ)) (sq_nonneg σ)

end NeuralGeneralization.BatchTwoActivation
