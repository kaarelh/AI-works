import NeuralGeneralization.BatchTwoNonGaussianEvenSmallBall
import NeuralGeneralization.BatchTwoNonGaussianCylinderTailBudget

/-! Uniform target-cylinder probabilities with logarithmic radius cost. Clone
groups are either singletons or even; interval collisions handle all even
sizes, avoiding any radius-dependent minimum width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

def admissibleGroup (k : ℕ) : Prop := k=1 ∨ ∃ m : ℕ, 0<m ∧ k=m+m

def radiusCap (ν : CoordinateLaw) : ℝ :=
  min 1 (min (coordinateBallConstant ν) (1/(8*(collisionRadius ν+1))))

theorem radiusCap_pos (ν : CoordinateLaw) : 0 < radiusCap ν := by
  have hc := coordinateBallConstant_pos ν
  have hr := collisionRadius_pos ν
  unfold radiusCap
  positivity

theorem radiusCap_le_one (ν : CoordinateLaw) : radiusCap ν ≤ 1 := min_le_left _ _

theorem admissibleGroup_small_ball (ν : CoordinateLaw) {k : ℕ} (hk : admissibleGroup k)
    {η : ℝ} (hη : 0 < η) (hcap : η ≤ radiusCap ν) :
    η^2/1024 ≤ (Measure.pi fun _ : Fin k => ν.law).real
      {z | |normalizedSum k z| ≤ η} := by
  have hη1 := hcap.trans (radiusCap_le_one ν)
  have ha : η ≤ coordinateBallConstant ν := hcap.trans ((min_le_right _ _).trans (min_le_left _ _))
  have hc : η ≤ 1/(8*(collisionRadius ν+1)) := hcap.trans ((min_le_right _ _).trans (min_le_right _ _))
  rcases hk with rfl | ⟨m,hm,rfl⟩
  · have hmap := (measurePreserving_eval (fun _ : Fin 1 => ν.law) 0).map_eq
    have he : (Measure.pi fun _ : Fin 1 => ν.law).real {z | |normalizedSum 1 z| ≤ η}=
        ν.law.real (Icc (-η) η) := by
      have hh := congrArg (fun μ : Measure ℝ => μ.real (Icc (-η) η)) hmap
      rw [Measure.real,Measure.map_apply (measurable_pi_apply _) measurableSet_Icc] at hh
      change ((Measure.pi fun _ : Fin 1 => ν.law) {z | -η ≤ z 0 ∧ z 0 ≤ η}).toReal=
        ν.law.real (Icc (-η) η) at hh
      simpa only [Measure.real,normalizedSum,Fin.sum_univ_one,Nat.cast_one,Real.sqrt_one,div_one,
        abs_le] using hh
    rw [he]
    apply le_trans _ (coordinate_small_ball ν hη.le hη1)
    nlinarith [mul_le_mul_of_nonneg_right ha hη.le,sq_nonneg η]
  · apply le_trans _ (even_normalized_sum_small_ball ν hm hη hη1)
    have h := mul_le_mul_of_nonneg_left hc hη.le
    have he : η*(1/(8*(collisionRadius ν+1)))=η/(8*(collisionRadius ν+1)) := by ring
    rw [he] at h
    nlinarith [sq_nonneg η]

theorem matrixNoiseCylinder_exp_lower (ν : CoordinateLaw) {C k p N : ℕ}
    (hN : 0<N) (hk : admissibleGroup k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {η b : ℝ} (hη : 0<η) (hcap : η ≤ radiusCap ν) (hb : 0≤b)
    (htail : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*(η^2/1024)^(C*N)) :
    Real.exp (-(N : ℝ)*matrixCylinderCost C η) ≤
      (Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixNoiseCylinder e η b) := by
  let μ := Measure.pi fun _ : Fin N × Fin N => ν.law
  have hg : (η^2/1024)^(C*N) ≤ μ.real (matrixGroupEvent e η) := by
    rw [matrixGroupEvent_probability]
    exact pow_le_pow_left₀ (by positivity) (admissibleGroup_small_ball ν hk hη hcap) _
  have ht := matrixActionEvent_tail ν N hb
  have hm := le_measureReal_sdiff (μ := μ) (s₁ := matrixGroupEvent e η)
    (s₂ := (matrixActionEvent N b)ᶜ) (measure_ne_top _ _)
  have he : matrixGroupEvent e η \ (matrixActionEvent N b)ᶜ=matrixNoiseCylinder e η b := by
    ext z
    simp [matrixNoiseCylinder]
  rw [he] at hm
  rw [matrixCylinderCost_exp C N hη]
  have hp : (1/2 : ℝ)^N ≤ 1/2 := by
    exact (pow_le_pow_of_le_one (by norm_num : (0 : ℝ) ≤ 1/2) (by norm_num : (1/2 : ℝ) ≤ 1)
      (by omega : 1≤N)).trans_eq (pow_one _)
  have hm' := mul_le_mul_of_nonneg_left hp (pow_nonneg (by positivity : 0≤η^2/1024) (C*N))
  linarith

theorem noiseCylinder_exp_lower (ν : CoordinateLaw) {C k p N : ℕ} (d r : ℕ)
    (hN : 0<N) (hk : admissibleGroup k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {η b : ℝ} (hη : 0<η) (hcap : η ≤ radiusCap ν) (hb : 0≤b)
    (htail : 2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (1/2)*(η^2/1024)^(C*N)) :
    Real.exp (-(N : ℝ)*networkCylinderCost ν d C r η) ≤
      (rawPrior ν d N r).real (noiseCylinder d e η b r) := by
  have hs := coordinate_small_ball ν hη.le (hcap.trans (radiusCap_le_one ν))
  have hm := matrixNoiseCylinder_exp_lower ν hN hk e hη hcap hb htail
  rw [←scalarCylinderCost_exp ν hη] at hs
  rw [noiseCylinder_probability]
  have hp := mul_le_mul (pow_le_pow_left₀ (Real.exp_nonneg _) hs (N*(d+2)))
    (pow_le_pow_left₀ (Real.exp_nonneg _) hm r) (pow_nonneg (Real.exp_nonneg _) r)
    (pow_nonneg ENNReal.toReal_nonneg _)
  have he : Real.exp (-(N : ℝ)*networkCylinderCost ν d C r η)=
      (Real.exp (-scalarCylinderCost ν η))^(N*(d+2))*
        (Real.exp (-(N : ℝ)*matrixCylinderCost C η))^r := by
    rw [←Real.exp_nat_mul,←Real.exp_nat_mul,←Real.exp_add]
    congr 1
    unfold networkCylinderCost
    push_cast
    ring
  exact he.le.trans hp

/-- Every learner width admits useful clone groups with at most a factor-two
energy overhead. No tolerance-dependent width split is needed. -/
theorem exists_admissible_clone_group {C N : ℕ} (hC : 0<C) (hCN : C≤N) :
    ∃ k : ℕ, 0<k ∧ admissibleGroup k ∧ C*k≤N ∧ N≤2*C*k := by
  by_cases hlarge : 2*C≤N
  · let m := N/(2*C)
    have hm : 0<m := Nat.div_pos hlarge (by omega)
    have hsplit : N%(2*C)+(2*C)*m=N := Nat.mod_add_div N (2*C)
    have hmod : N%(2*C)<2*C := Nat.mod_lt _ (by omega)
    refine ⟨m+m,by omega,Or.inr ⟨m,hm,rfl⟩,?_,?_⟩
    · calc
        C*(m+m)=2*C*m := by ring
        _ ≤ N := by omega
    · have hh : 2*C ≤ 2*C*m := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left (2*C) hm
      calc
        N ≤ 2*C*m+2*C := by omega
        _ ≤ 2*C*m+2*C*m := Nat.add_le_add_left hh _
        _ = 2*C*(m+m) := by ring
  · refine ⟨1,by omega,Or.inl rfl,?_,?_⟩ <;> omega

end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
