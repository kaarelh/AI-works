import NeuralGeneralization.OnlineLowerRetainedNeuron
import NeuralGeneralization.OnlineLowerFamilyNorm
import NeuralGeneralization.OnlineLowerFamilyStability
import NeuralGeneralization.OnlineLowerReluRaySaturation

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerGeometry

def retainedTransversals (k : ℕ) : Finset (Finset (Fin (pairDim k))) :=
  Finset.univ.image (transversalIndex k)

theorem retained_mass_image (R k : ℕ) (hR : 2≤R) (hEven : Even R)
    (F : ClippingCube (railDimension (size R k)) → ℝ) :
    finiteRetainedMass (fullRailSupport (size R k)) (fullRailCost (size R k))
      (retainedTransversals k) F = retainedFourierMass (targetSupport R k) (weight R k) F := by
  unfold finiteRetainedMass retainedTransversals retainedFourierMass
  rw [Finset.sum_image]
  · apply Finset.sum_congr rfl
    intro s _
    rw [targetSupport_eq_transversal, weight_eq_transversalCost R k hR hEven]
  · intro a _ b _ hab
    exact transversalIndex_injective R k (by omega) hab

def affineParameter {d : ℕ} (bias : ℝ) (u : Fin d → ℝ) : EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (Fin.cases bias u)

@[simp] theorem affineParameter_zero {d : ℕ} (bias : ℝ) (u : Fin d → ℝ) :
    affineParameter bias u 0 = bias := by simp [affineParameter]

@[simp] theorem affineParameter_succ {d : ℕ} (bias : ℝ) (u : Fin d → ℝ) (i : Fin d) :
    affineParameter bias u i.succ = u i := by simp [affineParameter]

theorem affineParameter_norm {d : ℕ} (bias : ℝ) (u : Fin d → ℝ) :
    ‖affineParameter bias u‖ = Real.sqrt (bias^2+∑ i,u i^2) := by
  rw [← Real.sqrt_sq (norm_nonneg _), affine_norm_sq]
  simp

theorem affineParameter_distance_sq {d : ℕ} (bias : ℝ) (u v : Fin d → ℝ) :
    ‖affineParameter bias u-affineParameter 0 v‖^2 = bias^2+∑ i,(u i-v i)^2 := by
  rw [affine_norm_sq]
  simp [affineParameter]

theorem affineParameter_score {d : ℕ} (bias : ℝ) (u : Fin d → ℝ) :
    affineRelu (affineParameter bias u) = (fun x => max (cubeAffine bias u x) 0) := by
  funext x
  simp [affineRelu]

theorem retained_ray_face (R k : ℕ) (τ : Finset (Fin (pairDim k)))
    (hτ : τ∈retainedTransversals k)
    (v : Fin (railDimension (size R k)) → ℝ) (c : ℝ)
    (hv : ∀ i,|v i|=if i∈fullRailSupport (size R k) τ then c else 0)
    (S : Finset (Fin (railDimension (size R k))))
    (hS : S∉railDownwardSupports (size R k) (column k)) :
    walshCoefficients (affineRelu (affineParameter 0 v)) S=0 := by
  obtain ⟨s,_,rfl⟩ := Finset.mem_image.mp hτ
  rw [affineParameter_score]
  apply affine_coefficient_zero_outside (targetSupport R k s) v ?_ 0 (fun z => max z 0) S ?_
  · intro i hi
    have hx := hv i
    rw [← targetSupport_eq_transversal,if_neg hi] at hx
    exact abs_eq_zero.mp hx
  · intro hsub
    apply hS
    simp only [railDownwardSupports,Finset.mem_filter,Finset.mem_univ,true_and]
    exact ⟨s,hsub⟩


theorem family_size_two (R k : ℕ) (hR : 2≤R) : ∀ i side,2≤size R k i side := by
  intro i side
  cases side <;> simp only [size_false,size_true] <;> omega

theorem family_size_min (R k : ℕ) : ∀ i side,(R : ℝ)≤size R k i side := by
  intro i side
  cases side
  · rfl
  · simp only [size_true,Nat.cast_add]
    exact le_add_of_nonneg_right (Nat.cast_nonneg _)

theorem family_size_max (R k : ℕ) : ∀ i side,(size R k i side : ℝ)≤(R : ℝ)+6 := by
  intro i side
  cases side
  · simp only [size_false]; linarith
  · simp only [size_true,Nat.cast_add]
    have h : (increment k i : ℝ)≤6 := by exact_mod_cast (increment_bounds k i).2
    linarith

theorem family_size_difference (R k : ℕ) : ∀ i,|(size R k i true : ℝ)-size R k i false|≤6 := by
  intro i
  simp only [size_true,size_false,Nat.cast_add,add_sub_cancel_left,
    abs_of_nonneg (Nat.cast_nonneg (α := ℝ) (increment k i))]
  exact_mod_cast (increment_bounds k i).2

theorem family_full_atom_norm (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (u : Fin (railDimension (size R k)) → ℝ) (bias : ℝ) :
    retainedFourierMass (fullRailSupport (size R k)) (fullRailCost (size R k))
      (fun x => max (cubeAffine bias u x) 0) ≤ Real.sqrt (bias^2+∑ i,u i^2) := by
  exact full_rail_norm_of_size (by rw [pairDim_eq]; omega) (size R k)
    (family_size_two R k (by omega)) (size_even R k heven) (R : ℝ) 6 (by norm_num)
    (by exact_mod_cast hR) (family_size_min R k) (family_size_difference R k) u bias

theorem family_full_cost_bound (R k : ℕ) (hR : 36≤R) (heven : Even R)
    (τ : Finset (Fin (pairDim k))) : fullRailCost (size R k) τ≤7*(pairDim k : ℝ)*R/2 := by
  have hp : 0<pairDim k := by rw [pairDim_eq]; omega
  have h1 := fullRailCost_le_three_card hp (size R k)
    (family_size_two R k (by omega)) (size_even R k heven) τ
  have h2 := fullRailSupport_card_le (size R k) ((R : ℝ)+6) (family_size_max R k) τ
  have hRr : (36 : ℝ)≤R := by exact_mod_cast hR
  have h3 := mul_le_mul_of_nonneg_left hRr (Nat.cast_nonneg (α := ℝ) (pairDim k))
  nlinarith


/-- Unconditional polynomial stability for the concrete retained logical code. -/
theorem affine_atom_retained_stability (R k : ℕ) (hR : 36≤R) (hEven : Even R)
    (u : Fin (railDimension (size R k)) → ℝ) (bias : ℝ) :
    uniformCubeMean (fun x =>
      (max (cubeAffine bias u x) 0-fourierProject (railDownwardSupports (size R k) (column k))
        (fun x => max (cubeAffine bias u x) 0) x)^2) ≤
      (2^16*(pairDim k : ℝ)^2*(R : ℝ)^4)*Real.sqrt (bias^2+∑ i,u i^2)*
        (Real.sqrt (bias^2+∑ i,u i^2)-retainedFourierMass (targetSupport R k) (weight R k)
          (fun x => max (cubeAffine bias u x) 0)) := by
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
  have h := retained_neuron_projection_bound (fullRailSupport (size R k)) (fullRailCost (size R k))
    (fullRailCost_nonneg (size R k)) (retainedTransversals k)
    (railDownwardSupports (size R k) (column k)) U V τ K W hK hW hwi hnorm hfull hsat
    (fun hτ => retained_ray_face R k τ hτ v c hv)
  rw [retained_mass_image R k (by omega) hEven (affineRelu U)] at h
  have hpoly := subcode_polynomial_constant (pairDim k : ℝ) R W hpr (by linarith) hW le_rfl
  have hδ : 0≤‖U‖-retainedFourierMass (targetSupport R k) (weight R k) (affineRelu U) := by
    rw [affineParameter_norm,affineParameter_score]
    exact sub_nonneg.mpr (affine_atom_retained_norm R k hR hEven u bias)
  have hm := mul_le_mul_of_nonneg_right hpoly (mul_nonneg (norm_nonneg U) hδ)
  have ht := h.trans (by simpa only [K,mul_assoc] using hm)
  simpa only [U,affineParameter_score,affineParameter_norm,mul_assoc] using ht

/-- Literal firstHidden row in the exact finite Gaussian network. -/
theorem actual_row_retained_stability (R k : ℕ) (hR : 36≤R) (hEven : Even R)
    {N : ℕ} (w : ConcreteModel.Weights (railDimension (size R k)) N 0) (j : Fin N) :
    uniformCubeMean (fun x =>
      (ConcreteModel.firstHidden (fun z : ℝ => max 0 z) w x j-
        fourierProject (railDownwardSupports (size R k) (column k))
          (fun x => ConcreteModel.firstHidden (fun z : ℝ => max 0 z) w x j) x)^2) ≤
      (2^16*(pairDim k : ℝ)^2*(R : ℝ)^4)*incomingEuclideanNorm w j*
        (incomingEuclideanNorm w j-retainedFourierMass (targetSupport R k) (weight R k)
          (fun x => ConcreteModel.firstHidden (fun z : ℝ => max 0 z) w x j)) := by
  simpa only [firstHidden_eq_cubeAffine,max_comm,incomingEuclideanNorm_eq_sqrt] using
    affine_atom_retained_stability R k hR hEven (incomingPhysical w j) (incomingBias w j)

end NeuralGeneralization.OnlineLowerRelu.Family


