import NeuralGeneralization.OnlineLowerFamilyRetainedStability

/-! Literal parameter-distance and full downward-space stability conclusions. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open OnlineLowerGeometry OnlineLowerRelu

theorem retained_neuron_parameter_bound {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ j,0≤w j)
    (J : Finset ι)
    (u v : EuclideanSpace ℝ (Fin (d+1))) (i : ι) (K W : ℝ)
    (hK : 1≤K) (hW : 0≤W) (hwi : w i≤W)
    (hnorm : retainedFourierMass A w (affineRelu u) ≤ ‖u‖)
    (hfull : ‖u-v‖^2 ≤ K*‖u‖*(‖u‖-retainedFourierMass A w (affineRelu u)))
    (hsat : w i*|walshCoefficients (affineRelu v) (A i)|=‖v‖) :
    ∃ v' : EuclideanSpace ℝ (Fin (d+1)),
      (v'=0 ∨ (v'=v ∧ i∈J)) ∧ ‖u-v'‖^2 ≤
      4*K*(W+1)^2*‖u‖*(‖u‖-finiteRetainedMass A w J (affineRelu u)) := by
  let δ := ‖u‖-finiteRetainedMass A w J (affineRelu u)
  have hsub := finiteRetainedMass_le_full A w hw J (affineRelu u)
  have hd : 0≤δ := sub_nonneg.mpr (hsub.trans hnorm)
  have hfull' : ‖u-v‖^2 ≤ K*‖u‖*δ := hfull.trans
    (mul_le_mul_of_nonneg_left (by change ‖u‖-retainedFourierMass A w (affineRelu u) ≤ ‖u‖-finiteRetainedMass A w J (affineRelu u); linarith)
      (mul_nonneg (by linarith) (norm_nonneg u)))
  by_cases hi : i∈J
  · refine ⟨v,Or.inr ⟨rfl,hi⟩,?_⟩
    have hcoef : 1≤4*(W+1)^2 := by nlinarith [sq_nonneg W]
    have hm := mul_le_mul_of_nonneg_right hcoef (mul_nonneg (mul_nonneg (by linarith : 0≤K) (norm_nonneg u)) hd)
    exact hfull'.trans (by nlinarith)
  · have hmiss := omitted_mass_le_difference A w hw J i hi (affineRelu u)
    have hLip := affineRelu_coefficient_lipschitz u v (A i)
    have htri : |walshCoefficients (affineRelu v) (A i)| ≤
        |walshCoefficients (affineRelu u) (A i)|+‖u-v‖ := by
      have h := abs_sub_abs_le_abs_sub (walshCoefficients (affineRelu v) (A i))
        (walshCoefficients (affineRelu u) (A i))
      rw [abs_sub_comm] at h
      linarith
    have hvm : ‖v‖≤δ+W*‖u-v‖ := by
      have hm := mul_le_mul_of_nonneg_left htri (hw i)
      have hwv := mul_le_mul_of_nonneg_right hwi (norm_nonneg (u-v))
      rw [hsat] at hm
      dsimp [δ]
      nlinarith
    have htriangle : ‖u‖ ≤ ‖u-v‖+‖v‖ := by
      simpa only [sub_add_cancel] using norm_add_le (u-v) v
    have hz := omitted_ray_scalar_transfer ‖u‖ δ ‖u-v‖ K W
      (norm_nonneg _) hd (norm_nonneg _) hK hW hfull' (by linarith)
    exact ⟨0,Or.inl rfl,by simpa only [sub_zero] using hz⟩

end NeuralGeneralization.OnlineLower

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerGeometry

theorem affine_atom_retained_parameter_stability (R k : ℕ) (hR : 36≤R) (hEven : Even R)
    (u : Fin (railDimension (size R k)) → ℝ) (bias : ℝ) :
    ∃ (s : Finset (Fin (logicalDim k))) (c : ℝ)
      (v : Fin (railDimension (size R k)) → ℝ),
      0 ≤ c ∧ (∀ i, |v i|=if i∈targetSupport R k s then c else 0) ∧
      bias^2+(∑i,(u i-v i)^2) ≤
        (2^16*(pairDim k : ℝ)^2*(R : ℝ)^4)*Real.sqrt (bias^2+∑i,u i^2)*
          (Real.sqrt (bias^2+∑i,u i^2)-retainedFourierMass (targetSupport R k) (weight R k)
            (fun x=>max (cubeAffine bias u x) 0)) := by
  have hRr : (36 : ℝ)≤R := by exact_mod_cast hR
  have hp : 0<pairDim k := by rw [pairDim_eq]; omega
  have hpr : (1 : ℝ)≤pairDim k := by exact_mod_cast hp
  let F := fun x => max (cubeAffine bias u x) 0
  let U := affineParameter bias u
  have hnorm : retainedFourierMass (fullRailSupport (size R k)) (fullRailCost (size R k)) F ≤ ‖U‖ := by
    rw [affineParameter_norm]
    exact family_full_atom_norm R k hR hEven u bias
  obtain ⟨τ,c,v,hc,hv,hstab⟩ := affine_atom_full_stability R k hR hEven u bias
  let V := affineParameter 0 v
  let K : ℝ := 2^9*(R : ℝ)^2
  let W : ℝ := 7*(pairDim k : ℝ)*R/2
  have hW : 0≤W := by dsimp [W]; positivity
  have hK : 1≤K := by dsimp [K]; nlinarith
  have hcoef : 48*((R : ℝ)+6)≤K := by dsimp [K]; nlinarith
  have hdelta : 0≤‖U‖-retainedFourierMass (fullRailSupport (size R k)) (fullRailCost (size R k)) F :=
    sub_nonneg.mpr hnorm
  have hfull : ‖U-V‖^2≤K*‖U‖*(‖U‖-
      retainedFourierMass (fullRailSupport (size R k)) (fullRailCost (size R k)) (affineRelu U)) := by
    have hm := mul_le_mul_of_nonneg_right hcoef (mul_nonneg (norm_nonneg U) hdelta)
    rw [affineParameter_distance_sq]
    simp only [U,affineParameter_norm,affineParameter_score] at hm ⊢
    exact hstab.trans (by simpa only [F,mul_assoc] using hm)
  have hwi : fullRailCost (size R k) τ≤W := family_full_cost_bound R k hR hEven τ
  have hsat : fullRailCost (size R k) τ*|walshCoefficients (affineRelu V) (fullRailSupport (size R k) τ)|=‖V‖ := by
    have h := even_support_ray_saturation (fullRailSupport (size R k) τ)
      (fullRailSupport_two_le hp (size R k) (family_size_two R k (by omega)) τ)
      (fullRailSupport_even (size R k) (size_even R k hEven) τ) v c hc hv
    simpa [V,affineParameter_score,affineParameter_norm,fullRailCost] using h
  obtain ⟨v',hv',h⟩ := retained_neuron_parameter_bound
    (fullRailSupport (size R k)) (fullRailCost (size R k))
    (fullRailCost_nonneg (size R k)) (retainedTransversals k)
    U V τ K W hK hW hwi hnorm hfull hsat
  rw [retained_mass_image R k (by omega) hEven (affineRelu U)] at h
  have hpoly := subcode_polynomial_constant (pairDim k : ℝ) R W hpr (by linarith) hW le_rfl
  have hδ : 0≤‖U‖-retainedFourierMass (targetSupport R k) (weight R k) (affineRelu U) := by
    rw [affineParameter_norm,affineParameter_score]
    exact sub_nonneg.mpr (affine_atom_retained_norm R k hR hEven u bias)
  have hm := mul_le_mul_of_nonneg_right hpoly (mul_nonneg (norm_nonneg U) hδ)
  have ht := h.trans (by simpa only [K,mul_assoc] using hm)
  rcases hv' with hv0 | ⟨hvv,hτ⟩
  · refine ⟨∅,0,0,le_rfl,?_,?_⟩
    · intro i
      simp
    · rw [hv0,sub_zero,affine_norm_sq] at ht
      simpa only [U,affineParameter_zero,affineParameter_succ,affineParameter_score,
        affineParameter_norm,Pi.zero_apply,sub_zero,mul_assoc] using ht
  · obtain ⟨s,_,hs⟩ := Finset.mem_image.mp hτ
    refine ⟨s,c,v,hc,?_,?_⟩
    · intro i
      simpa only [←hs,←targetSupport_eq_transversal] using hv i
    · rw [hvv] at ht
      rw [affineParameter_distance_sq] at ht
      simpa only [U,affineParameter_score,affineParameter_norm,mul_assoc] using ht


end NeuralGeneralization.OnlineLowerRelu.Family

namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry

/-- All Fourier characters contained in at least one full rail transversal. -/
def fullRailDownwardSupports {p : ℕ} (size : Fin p → Bool → ℕ) :
    Finset (Finset (Fin (railDimension size))) :=
  Finset.univ.filter (fun S => ∃ τ, S ⊆ fullRailSupport size τ)

/-- The parameter witness gives the literal full downward-Fourier-space
function residual, with the stronger coefficient `48 U`. -/
theorem full_rail_projection_stability_of_size {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side,2 ≤ size i side)
    (heven : ∀ i side,Even (size i side))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6*Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2*R)
    (hmin : ∀ i side,R ≤ (size i side : ℝ))
    (hmax : ∀ i side,(size i side : ℝ) ≤ U)
    (hdiff : ∀ i,|(size i true : ℝ)-size i false| ≤ Δ)
    (u : Fin (railDimension size) → ℝ) (bias : ℝ) :
    uniformCubeMean (fun x =>
      (max (cubeAffine bias u x) 0-fourierProject (fullRailDownwardSupports size)
        (fun x=>max (cubeAffine bias u x) 0) x)^2) ≤
      48*U*Real.sqrt (bias^2+∑i,u i^2)*
        (Real.sqrt (bias^2+∑i,u i^2)-
          retainedFourierMass (fullRailSupport size) (fullRailCost size)
            (fun x=>max (cubeAffine bias u x) 0)) := by
  obtain ⟨τ,c,v,_,hv,hstab⟩ := full_rail_stability_of_size hp size htwo heven
    R Δ U hΔ hR hRpos hU hUR hmin hmax hdiff u bias
  have hface : ∀ S,S ∉ fullRailDownwardSupports size →
      walshCoefficients (fun x=>max (cubeAffine 0 v x) 0) S=0 := by
    intro S hS
    apply affine_coefficient_zero_outside (fullRailSupport size τ) v ?_ 0 (fun t=>max t 0) S ?_
    · intro i hi
      have hh := hv i
      rw [if_neg hi] at hh
      exact abs_eq_zero.mp hh
    · intro hsub
      exact hS (Finset.mem_filter.mpr ⟨Finset.mem_univ _,⟨τ,hsub⟩⟩)
  have hcomp := projection_residual_le_comparison (fullRailDownwardSupports size)
    (fun x=>max (cubeAffine bias u x) 0) (fun x=>max (cubeAffine 0 v x) 0) hface
  have hlip := relu_neuron_l2_difference_le bias 0 u v
  simp only [sub_zero] at hlip
  exact (hcomp.trans hlip).trans hstab

/-- The manuscript's displayed `2^9 R^2` full-space residual bound. Its
integer rail hypotheses imply `R≥1`; the theorem otherwise permits real bounds. -/
theorem full_rail_projection_polynomial_stability {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side,2 ≤ size i side)
    (heven : ∀ i side,Even (size i side))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6*Δ ≤ R)
    (hRone : 1 ≤ R) (hU : 2 ≤ U) (hUR : U ≤ 2*R)
    (hmin : ∀ i side,R ≤ (size i side : ℝ))
    (hmax : ∀ i side,(size i side : ℝ) ≤ U)
    (hdiff : ∀ i,|(size i true : ℝ)-size i false| ≤ Δ)
    (u : Fin (railDimension size) → ℝ) (bias : ℝ) :
    uniformCubeMean (fun x =>
      (max (cubeAffine bias u x) 0-fourierProject (fullRailDownwardSupports size)
        (fun x=>max (cubeAffine bias u x) 0) x)^2) ≤
      (2^9*R^2)*Real.sqrt (bias^2+∑i,u i^2)*
        (Real.sqrt (bias^2+∑i,u i^2)-
          retainedFourierMass (fullRailSupport size) (fullRailCost size)
            (fun x=>max (cubeAffine bias u x) 0)) := by
  have h := full_rail_projection_stability_of_size hp size htwo heven R Δ U hΔ hR
    (by linarith) hU hUR hmin hmax hdiff u bias
  have hn := full_rail_norm_of_size hp size htwo heven R Δ hΔ hR hmin hdiff u bias
  have hcoef : 48*U ≤ 2^9*R^2 := by nlinarith
  have hm := mul_le_mul_of_nonneg_right hcoef
    (mul_nonneg (Real.sqrt_nonneg (bias^2+∑i,u i^2)) (sub_nonneg.mpr hn))
  exact h.trans (by simpa only [mul_assoc] using hm)

end NeuralGeneralization.OnlineLowerRelu
