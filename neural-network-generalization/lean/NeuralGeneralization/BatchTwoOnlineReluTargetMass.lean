import NeuralGeneralization.BatchTwoOnlineReluTeacherCenter
import NeuralGeneralization.BatchTwoOnlineReluGaussianBox

/-! Literal finite-variance target mass for every enlarged ReLU margin teacher. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem centeredBox_subset_margin {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (u : Weights d N r) {K : ℝ} (hu : ∀i,normalizedLayerNorm u i≤Real.sqrt (K/(r+2:ℝ)))
    (f : BooleanFunction d) (hm : ∀x,(1:ℝ)<labelReal (f x)*networkOutput relu (unwhiten u) x) :
    centeredBox u (reluPerturbationRadius r K)⊆whitenedMarginEvent relu (1/2) f := by
  letI : NeZero N := ⟨hN.ne'⟩
  intro z hz x
  have hρ := reluPerturbationRadius_pos r K
  have hv : ∑q,((z-u) q)^2≤(reluPerturbationRadius r K)^2 :=
    centeredBox_sq_dist_le u hρ hz
  have he := relu_balanced_perturbation hd hN u (z-u) (Real.sqrt_nonneg _) hρ.le
    (reluPerturbationRadius_le_one r K) hu hv x
  rw [add_sub_cancel] at he
  have he' := he.trans (reluPerturbationRadius_amplification r K)
  have hl : |labelReal (f x)|=1 := by cases f x <;> norm_num [labelReal]
  have hs : |labelReal (f x)*(networkOutput relu (unwhiten z) x-networkOutput relu (unwhiten u) x)|≤1/4 := by
    rw [abs_mul,hl,one_mul]
    exact he'
  have hh := (abs_le.mp hs).1
  have hx := hm x
  change (1/2:ℝ)<labelReal (f x)*networkOutput relu (unwhiten z) x
  nlinarith

def reluTeacherMassBudget (d r : ℕ) (P : ℝ) : ℝ :=
  gaussianBoxBudget (reluTeacherEnergy d r P) ((d:ℝ)+(r+2:ℝ))
    (reluPerturbationRadius r (reluTeacherEnergy d r P))

theorem relu_finite_variance_target_mass {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) {σ : ℝ} (hσ : 0<σ)
    (hdim : (Fintype.card (WeightIndex d N r):ℝ)*σ^2≤(d:ℝ)+(r+2:ℝ)) :
    Real.exp (-reluTeacherMassBudget d r (physicalProduct hC relu_zeroLipschitz w)/σ^2)≤
      functionMass relu (1/2) (smallPrior d N r σ) f := by
  have hN : 0<N := hC.trans_le hCN
  letI : NeZero N := ⟨hN.ne'⟩
  let K := reluTeacherEnergy d r (physicalProduct hC relu_zeroLipschitz w)
  let ρ := reluPerturbationRadius r K
  have hK : 0<K := reluTeacherEnergy_pos hd (physical_relu_product_pos hC w (margin_teacher_nonzero w f hw))
  have hρ : 0<ρ := reluPerturbationRadius_pos r K
  obtain ⟨u,hu,hl,hm⟩ := exists_relu_teacher_center hd hC hCN w f hw
  have hv : (σ^2).toNNReal≠0 := ne_of_gt (Real.toNNReal_pos.mpr (sq_pos_of_pos hσ))
  have hb := gaussian_centeredBox_mass_lower hK.le (show 0<(d:ℝ)+(r+2:ℝ) by positivity)
    hρ u hu.le (σ^2).toNNReal hv (by simpa only [Real.coe_toNNReal _ (sq_nonneg σ)] using hdim)
  have hsub := centeredBox_subset_margin hd hN u (fun i=>(hl i).le) f hm
  have hm' := measureReal_mono (μ:=Measure.pi fun _i:WeightIndex d N r=>gaussianReal 0 (σ^2).toNNReal)
    hsub (measure_ne_top _ _)
  unfold functionMass
  rw [smallPrior_marginEvent_eq_isotropic hd hN (show Continuous relu from continuous_const.max continuous_id) (1/2) f hσ]
  apply le_trans ?_ hm'
  simpa only [Real.coe_toNNReal _ (sq_nonneg σ),reluTeacherMassBudget,K,ρ] using hb

end NeuralGeneralization.BatchTwoOnlineReluFinite
