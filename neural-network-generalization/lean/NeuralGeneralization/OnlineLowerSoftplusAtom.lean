import NeuralGeneralization.OnlineLowerSoftplusAtomFamilyPotential

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open OnlineLowerRelu OnlineLower OnlineLowerGeometry

lemma softplus_neuron_l2_difference {d : ℕ} (bias : ℝ) (u v : Fin d→ℝ) :
    uniformCubeMean (fun x => (softplus (cubeAffine bias u x)-softplus (cubeAffine bias v x))^2) ≤
      ∑i,(u i-v i)^2 := by
  calc
    _ ≤ uniformCubeMean (fun x => (cubeAffine bias u x-cubeAffine bias v x)^2) := by
      apply uniformCubeMean_mono
      intro x
      have h := mul_self_le_mul_self (abs_nonneg _) (softplus_abs_sub_le
        (cubeAffine bias u x) (cubeAffine bias v x))
      simpa only [← pow_two,sq_abs] using h
    _ = _ := by simp_rw [cubeAffine_sub]; rw [cubeAffine_secondMoment];simp

namespace Family
open OnlineLowerRelu.Family

lemma softplus_mass_le_potential (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) (bias : ℝ) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x=>softplus (cubeAffine bias u x)) ≤ retainedPotential R k u := by
  apply Finset.sum_le_sum
  intro s _
  have hc := degreeIndex_card R k (by omega) heven s
  have hs : 2≤(targetSupport R k s).card := by omega
  have hc' : (targetSupport R k s).card=2*(degreeIndex R k s+1) := by omega
  exact mul_le_mul_of_nonneg_left (softplus_walsh_abs_le_potential _ hs hc' bias u)
    (weight_pos R k (by omega) heven s).le

/-- The sharp softplus atom inequality, with no bias in the right-hand norm. -/
theorem affine_softplus_retained_norm_physical (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) (bias : ℝ) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x=>softplus (cubeAffine bias u x)) ≤ Real.sqrt (∑i,u i^2) :=
  (softplus_mass_le_potential R k hR heven u bias).trans
    ((retainedPotential_le_full R k (by omega) heven u).trans (fullPotential_norm R k hR heven u))

theorem affine_softplus_retained_norm (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) (bias : ℝ) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x=>softplus (cubeAffine bias u x)) ≤ Real.sqrt (bias^2+∑i,u i^2) :=
  (affine_softplus_retained_norm_physical R k hR heven u bias).trans
    (Real.sqrt_le_sqrt (le_add_of_nonneg_left (sq_nonneg bias)))

lemma retained_softplus_face (R k : ℕ) (τ : Finset (Fin (pairDim k)))
    (hτ : τ∈retainedTransversals k) (bias c : ℝ)
    (v : Fin (railDimension (size R k))→ℝ)
    (hv : ∀i,|v i|=if i∈fullRailSupport (size R k) τ then c else 0)
    (S : Finset (Fin (railDimension (size R k))))
    (hS : S∉railDownwardSupports (size R k) (column k)) :
    walshCoefficients (fun x=>softplus (cubeAffine bias v x)) S=0 := by
  obtain ⟨s,_,rfl⟩ := Finset.mem_image.mp hτ
  apply affine_coefficient_zero_outside (targetSupport R k s) v ?_ bias softplus S ?_
  · intro i hi
    have hh := hv i
    rw [← targetSupport_eq_transversal,if_neg hi] at hh
    exact abs_eq_zero.mp hh
  · intro hsub
    apply hS
    simp only [railDownwardSupports,Finset.mem_filter,Finset.mem_univ,true_and]
    exact ⟨s,hsub⟩

/-- The softplus atom's downward projection defect has the same constant
as the ReLU retained-code estimate; the arbitrary bias is kept fixed. -/
theorem affine_softplus_retained_stability_physical
    (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) (bias : ℝ) :
    uniformCubeMean (fun x =>
      (softplus (cubeAffine bias u x)-fourierProject (railDownwardSupports (size R k) (column k))
        (fun x=>softplus (cubeAffine bias u x)) x)^2) ≤
      (2^16*(pairDim k:ℝ)^2*(R:ℝ)^4)*Real.sqrt (∑i,u i^2)*
        (Real.sqrt (∑i,u i^2)-retainedFourierMass (targetSupport R k) (weight R k)
          (fun x=>softplus (cubeAffine bias u x))) := by
  let ρ := Real.sqrt (∑i,u i^2)
  let δ := ρ-retainedPotential R k u
  let K : ℝ := 2^9*(R:ℝ)^2
  let W : ℝ := 7*(pairDim k:ℝ)*R/2
  let F := fun x=>softplus (cubeAffine bias u x)
  let D := railDownwardSupports (size R k) (column k)
  have hRr : (36:ℝ)≤R := by exact_mod_cast hR
  have hp : 0<pairDim k := by rw [pairDim_eq];omega
  have hpr : (1:ℝ)≤pairDim k := by exact_mod_cast hp
  have hρ : 0≤ρ := Real.sqrt_nonneg _
  have hK : 1≤K := by dsimp [K];nlinarith
  have hW : 0≤W := by dsimp [W];positivity
  have hδ : 0≤δ := sub_nonneg.mpr
    ((retainedPotential_le_full R k (by omega) heven u).trans (fullPotential_norm R k hR heven u))
  have hsub := retainedPotential_le_full R k (by omega) heven u
  have hnorm := fullPotential_norm R k hR heven u
  obtain ⟨τ,c,v,hc,hv,hstab⟩ := fullPotential_stability R k hR heven u
  let U := affineParameter 0 u
  let V := affineParameter 0 v
  have hUn : ‖U‖=ρ := by simp [U,affineParameter_norm,ρ]
  have hdist : ‖U-V‖^2=∑i,(u i-v i)^2 := by
    simp [U,V,affineParameter_distance_sq]
  have hfull : ‖U-V‖^2≤K*ρ*δ := by
    rw [hdist]
    have hcoef : 48*((R:ℝ)+6)≤K := by dsimp [K];nlinarith
    have hδfull : 0≤ρ-fullPotential (size R k) u := sub_nonneg.mpr hnorm
    calc
      _ ≤ 48*((R:ℝ)+6)*ρ*(ρ-fullPotential (size R k) u) := hstab
      _ ≤ K*ρ*(ρ-fullPotential (size R k) u) := by
        nlinarith [mul_nonneg hρ hδfull]
      _ ≤ K*ρ*δ := mul_le_mul_of_nonneg_left (by dsimp [δ];linarith)
        (mul_nonneg (by linarith) hρ)
  have hbound : uniformCubeMean (fun x=>(F x-fourierProject D F x)^2) ≤
      4*K*(W+1)^2*ρ*δ := by
    by_cases hτ : τ∈retainedTransversals k
    · have hface := retained_softplus_face R k τ hτ bias c v hv
      have hh := (projection_residual_le_comparison D F
        (fun x=>softplus (cubeAffine bias v x)) hface).trans
          (softplus_neuron_l2_difference bias u v)
      rw [← hdist] at hh
      have hcoef : 1≤4*(W+1)^2 := by nlinarith [sq_nonneg W]
      have hm := mul_le_mul_of_nonneg_right hcoef
        (mul_nonneg (mul_nonneg (by linarith : 0≤K) hρ) hδ)
      exact hh.trans (hfull.trans (by nlinarith))
    · have hmiss : fullRailCost (size R k) τ*supportFourierPotential
          (fullRailSupport (size R k) τ) u ≤
          fullPotential (size R k) u-retainedPotential R k u := by
        rw [← retainedPotential_image R k (by omega) heven u]
        have hh := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ (insert τ (retainedTransversals k)))
          (f:=fun t=>fullRailCost (size R k) t*supportFourierPotential (fullRailSupport (size R k) t) u)
          (fun t _ _=>mul_nonneg (fullRailCost_nonneg _ _) (supportFourierPotential_nonneg _ _))
        rw [Finset.sum_insert hτ] at hh
        exact (le_sub_iff_add_le).mpr hh
      have hcdeg := fullRailSupport_even (size R k) (size_even R k heven) τ
      obtain ⟨r,hr⟩ := hcdeg
      have htwo := fullRailSupport_two_le hp (size R k) (family_size_two R k (by omega)) τ
      have hc' : (fullRailSupport (size R k) τ).card=2*r := by omega
      have hrel := relu_walsh_abs_le_potential (fullRailSupport (size R k) τ) htwo hc' 0 u
      have hsat : fullRailCost (size R k) τ*|walshCoefficients (affineRelu V)
          (fullRailSupport (size R k) τ)|=‖V‖ := by
        have hh := even_support_ray_saturation (fullRailSupport (size R k) τ) htwo
          ⟨r,hr⟩ v c hc hv
        simpa [V,affineParameter_score,affineParameter_norm,fullRailCost] using hh
      have hlip := affineRelu_coefficient_lipschitz U V (fullRailSupport (size R k) τ)
      have htri : |walshCoefficients (affineRelu V) (fullRailSupport (size R k) τ)| ≤
          supportFourierPotential (fullRailSupport (size R k) τ) u+‖U-V‖ := by
        have hh := abs_sub_abs_le_abs_sub
          (walshCoefficients (affineRelu V) (fullRailSupport (size R k) τ))
          (walshCoefficients (affineRelu U) (fullRailSupport (size R k) τ))
        rw [abs_sub_comm] at hh
        have hrel' : |walshCoefficients (affineRelu U) (fullRailSupport (size R k) τ)| ≤
            supportFourierPotential (fullRailSupport (size R k) τ) u := by
          simpa [U,affineParameter_score] using hrel
        linarith
      have hwi : fullRailCost (size R k) τ≤W := family_full_cost_bound R k hR heven τ
      have hvnorm : ‖V‖≤δ+W*‖U-V‖ := by
        have hm := mul_le_mul_of_nonneg_left htri (fullRailCost_nonneg (size R k) τ)
        rw [hsat] at hm
        have hwv := mul_le_mul_of_nonneg_right hwi (norm_nonneg (U-V))
        dsimp [δ]
        nlinarith
      have htriangle : ρ≤‖U-V‖+‖V‖ := by
        rw [← hUn]
        simpa only [sub_add_cancel] using norm_add_le (U-V) V
      have hz := omitted_ray_scalar_transfer ρ δ ‖U-V‖ K W hρ hδ (norm_nonneg _) hK hW
        hfull (by linarith)
      have hzero : ∀ S,S∉D → walshCoefficients (fun x=>softplus (cubeAffine bias (fun _=>0) x)) S=0 := by
        intro S hS
        apply affine_coefficient_zero_outside (targetSupport R k ∅) (fun _=>0)
          (fun _ _=>rfl) bias softplus S
        intro hs
        apply hS
        simp only [D,railDownwardSupports,Finset.mem_filter,Finset.mem_univ,true_and]
        exact ⟨∅,hs⟩
      have hh := (projection_residual_le_comparison D F
        (fun x=>softplus (cubeAffine bias (fun _=>0) x)) hzero).trans
          (softplus_neuron_l2_difference bias u (fun _=>0))
      have hρsq : ρ^2=∑i,u i^2 := Real.sq_sqrt (Finset.sum_nonneg (fun _ _=>sq_nonneg _))
      simp only [sub_zero] at hh
      rw [← hρsq] at hh
      exact hh.trans hz
  have hpoly := subcode_polynomial_constant (pairDim k:ℝ) R W hpr (by linarith) hW le_rfl
  have hQ := softplus_mass_le_potential R k hR heven u bias
  have hKpoly : 0≤(2^16*(pairDim k:ℝ)^2*(R:ℝ)^4) := by positivity
  calc
    _ ≤ 4*K*(W+1)^2*ρ*δ := hbound
    _ ≤ (2^16*(pairDim k:ℝ)^2*(R:ℝ)^4)*ρ*δ := by
      have hh := mul_le_mul_of_nonneg_right hpoly (mul_nonneg hρ hδ)
      simpa only [K,mul_assoc] using hh
    _ ≤ _ := mul_le_mul_of_nonneg_left (by dsimp [δ];linarith) (mul_nonneg hKpoly hρ)

/-- The augmented Euclidean norm version used by the actual network budget. -/
theorem affine_softplus_retained_stability (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k))→ℝ) (bias : ℝ) :
    uniformCubeMean (fun x =>
      (softplus (cubeAffine bias u x)-fourierProject (railDownwardSupports (size R k) (column k))
        (fun x=>softplus (cubeAffine bias u x)) x)^2) ≤
      (2^16*(pairDim k:ℝ)^2*(R:ℝ)^4)*Real.sqrt (bias^2+∑i,u i^2)*
        (Real.sqrt (bias^2+∑i,u i^2)-retainedFourierMass (targetSupport R k) (weight R k)
          (fun x=>softplus (cubeAffine bias u x))) := by
  have h := affine_softplus_retained_stability_physical R k hR heven u bias
  have hr := Real.sqrt_le_sqrt (le_add_of_nonneg_left (sq_nonneg bias) :
    (∑i,u i^2) ≤ bias^2+∑i,u i^2)
  have hδ := sub_nonneg.mpr (affine_softplus_retained_norm_physical R k hR heven u bias)
  have hK : 0≤(2^16*(pairDim k:ℝ)^2*(R:ℝ)^4) := by positivity
  apply h.trans
  exact mul_le_mul
    (mul_le_mul_of_nonneg_left hr hK) (sub_le_sub_right hr _)
    hδ (mul_nonneg hK (Real.sqrt_nonneg _))

theorem actual_softplus_row_retained_norm (R k : ℕ) (hR : 36≤R) (heven : Even R)
    {N : ℕ} (w : ConcreteModel.Weights (railDimension (size R k)) N 0) (j : Fin N) :
    retainedFourierMass (targetSupport R k) (weight R k)
      (fun x=>ConcreteModel.firstHidden softplus w x j) ≤ incomingEuclideanNorm w j := by
  simpa only [firstHidden_eq_cubeAffine,incomingEuclideanNorm_eq_sqrt] using
    affine_softplus_retained_norm R k hR heven (incomingPhysical w j) (incomingBias w j)

theorem actual_softplus_row_retained_stability (R k : ℕ) (hR : 36≤R) (heven : Even R)
    {N : ℕ} (w : ConcreteModel.Weights (railDimension (size R k)) N 0) (j : Fin N) :
    uniformCubeMean (fun x =>
      (ConcreteModel.firstHidden softplus w x j-
        fourierProject (railDownwardSupports (size R k) (column k))
          (fun x=>ConcreteModel.firstHidden softplus w x j) x)^2) ≤
      (2^16*(pairDim k:ℝ)^2*(R:ℝ)^4)*incomingEuclideanNorm w j*
        (incomingEuclideanNorm w j-retainedFourierMass (targetSupport R k) (weight R k)
          (fun x=>ConcreteModel.firstHidden softplus w x j)) := by
  simpa only [firstHidden_eq_cubeAffine,incomingEuclideanNorm_eq_sqrt] using
    affine_softplus_retained_stability R k hR heven (incomingPhysical w j) (incomingBias w j)

end Family
end NeuralGeneralization.OnlineLowerSoftplus
