import NeuralGeneralization.BatchTwoNonGaussianAllWidthCylinder

/-! Closed all-width target mass under the original non-Gaussian coordinate law.
No group-size, projection-independence, or concentration premise remains. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel CompressionSampling

def targetMassCost (ν : CoordinateLaw) (d C r : ℕ) : ℝ :=
  ν.upperCurvature/2*cylinderTeacherCost d r C+
    allWidthNoiseCost ν d C r (cylinderTeacherCost d r C)

theorem targetMassCost_nonneg (ν : CoordinateLaw) (d C r : ℕ) :
    0 ≤ targetMassCost ν d C r := by
  exact add_nonneg (mul_nonneg (div_nonneg ν.upperCurvature_pos.le (by norm_num))
    (cylinderTeacherCost_nonneg d r C))
    (allWidthNoiseCost_nonneg ν d C r (cylinderTeacherCost_nonneg d r C))

theorem smallPrior_target_mass_all_width (ν : CoordinateLaw) {d C N r : ℕ}
    (hd : 0 < d) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) Real.tanh f C) (hCN : C ≤ N)
    {σ : ℝ} (hσ : 0 < σ) (hscale : (N : ℝ)*σ^2 ≤ 1) :
    Real.exp (-targetMassCost ν d C r/σ^2) ≤
      functionMass Real.tanh (1/2) (smallPrior ν d N r σ) f := by
  classical
  obtain ⟨hC1,w,hmargin,hbound⟩ := hf
  have hC : 0 < C := hC1
  have hN : 0 < N := hC.trans_le hCN
  let k := N/C
  let p := N%C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hp : p < C := Nat.mod_lt N hC
  have hsplit : C*k+p=N := by simpa [Nat.add_comm] using Nat.mod_add_div N C
  have hbelow : C*k ≤ N := by omega
  have habove : N ≤ 2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N :=
    Fintype.equivOfCardEq (by simpa using hsplit)
  let K := cylinderTeacherCost d r C
  let b := cylinderNoiseBound ν d r C K
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  let v := clonedWeights e (rescaleReadout 3 w)
  have hK : 0 ≤ K := cylinderTeacherCost_nonneg d r C
  have hb : 0 ≤ b := (cylinderNoiseBound_pos ν d r C hK).le
  have hv : weightedSquaredNorm v ≤ K := by
    have h1 := weightedSquaredNorm_cloned_le hC hk hbelow habove e (rescaleReadout 3 w)
    have h2 := rescaleReadout_cost_le (by norm_num : (1 : ℝ) ≤ 3) w
    have h3 := weightedSquaredNorm_bounded_teacher hC w hbound
    dsimp [v,K,cylinderTeacherCost]
    nlinarith
  have hm : v ∈ marginEvent Real.tanh (3/2) f := by
    intro x
    dsimp [v]
    rw [networkOutput_cloned hk,rescaleReadout_output]
    have h := hmargin x
    nlinarith
  have ht := smallPrior_translated_event_mass ν hd hN hσ
    (noiseCylinder d e ρ b r) (marginEvent Real.tanh (1/2) f)
    (measurable_noiseCylinder d e ρ b r) (noiseCylinder_neg d e ρ b r)
    (isOpen_marginEvent (by fun_prop : Continuous Real.tanh) (1/2) f).measurableSet
    v (fun z hz => cylinder_margin_transfer Real.tanh f _ _ hm
      (noiseCylinder_output_error hd hN hk e (rescaleReadout 3 w) hK hb hσ.le hscale hv z hz))
  have hn := noiseCylinder_allWidth_exp_lower ν d r hC hk hp hsplit e hK
  have henergy : Real.exp (-(ν.upperCurvature/2*K/σ^2)) ≤
      Real.exp (-(ν.upperCurvature/2*weightedSquaredNorm v/σ^2)) := by
    apply Real.exp_le_exp.mpr
    exact neg_le_neg (div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_left hv (div_nonneg ν.upperCurvature_pos.le (by norm_num))) (sq_nonneg σ))
  have hprod := mul_le_mul hn henergy (Real.exp_nonneg _) measureReal_nonneg
  apply le_trans _ (hprod.trans ht)
  rw [←Real.exp_add]
  apply Real.exp_le_exp.mpr
  have hNle : (N : ℝ) ≤ 1/σ^2 := (le_div_iff₀ (sq_pos_of_pos hσ)).mpr hscale
  have hcost := mul_le_mul_of_nonneg_right hNle (allWidthNoiseCost_nonneg ν d C r hK)
  change -(ν.upperCurvature/2*K+allWidthNoiseCost ν d C r K)/σ^2 ≤ _
  ring_nf at hcost ⊢
  linarith

end NeuralGeneralization.BatchTwoNonGaussian
