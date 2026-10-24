import NeuralGeneralization.BatchTwoNonGaussianCylinderTailBudget

/-! Small-width cylinder bounds from original coordinate boxes. Their dimension
cost is harmless below the explicitly polynomial clone-group threshold. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel Compression

def coordinateCube (d N r : ℕ) (δ : ℝ) : Set (Weights d N r) :=
  Set.pi Set.univ (fun _ => Icc (-δ) δ)

theorem coordinateCube_probability (ν : CoordinateLaw) (d N r : ℕ) (δ : ℝ) :
    (rawPrior ν d N r).real (coordinateCube d N r δ)=
      (ν.law.real (Icc (-δ) δ))^(N*(d+2)+r*N*N) := by
  rw [coordinateCube,rawPrior,Measure.real,Measure.pi_pi,Finset.prod_const,
    Finset.card_univ,ENNReal.toReal_pow]
  congr 1
  simp [WeightIndex,Fintype.card_sum,Fintype.card_prod]
  ring

theorem matrixNoiseCylinder_of_coordinates {C k p N : ℕ} (hN : 0 < N) (hk : 0 < k)
    (hkN : k ≤ N) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {ρ b : ℝ} (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hb : 1 ≤ b)
    (z : Fin N × Fin N → ℝ) (hz : ∀ ij, |z ij| ≤ ρ/((N : ℝ)+1)) :
    z ∈ matrixNoiseCylinder e ρ b := by
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hNk : (k : ℝ) ≤ N := by exact_mod_cast hkN
  have hN1 : (0 : ℝ) < (N : ℝ)+1 := by positivity
  have hδ : 0 ≤ ρ/((N : ℝ)+1) := div_nonneg hρ hN1.le
  constructor
  · intro i a
    have hs : |∑ j : Fin k, z (i,e (.inl (a,j)))| ≤ (k : ℝ)*(ρ/((N : ℝ)+1)) := by
      calc
        _ ≤ ∑ j : Fin k, |z (i,e (.inl (a,j)))| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _ : Fin k, ρ/((N : ℝ)+1) := Finset.sum_le_sum (fun j _ => hz _)
        _ = _ := by simp
    have hkR : 0 < (k : ℝ) := Nat.cast_pos.mpr hk
    have hspos := Real.sqrt_pos.mpr hkR
    have hs2 := Real.sq_sqrt hkR.le
    have hroot : Real.sqrt (k : ℝ) ≤ (N : ℝ)+1 := by nlinarith [sq_nonneg (Real.sqrt (k : ℝ)-(N : ℝ))]
    change |(∑ j : Fin k, z (i,e (.inl (a,j))))/Real.sqrt k| ≤ ρ
    rw [abs_div,abs_of_pos hspos]
    apply (div_le_iff₀ hspos).mpr
    apply hs.trans
    have hm := mul_le_mul_of_nonneg_left hroot hδ
    have hδN : (ρ/((N : ℝ)+1))*((N : ℝ)+1)=ρ := div_mul_cancel₀ _ hN1.ne'
    nlinarith
  · intro v
    have hen : (∑ i, ∑ j, z (i,j)^2) ≤ (N : ℝ)^2*(ρ/((N : ℝ)+1))^2 := by
      calc
        _ ≤ ∑ _ : Fin N, ∑ _ : Fin N, (ρ/((N : ℝ)+1))^2 := by
          apply Finset.sum_le_sum
          intro i _
          apply Finset.sum_le_sum
          intro j _
          simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) hδ).mpr (hz (i,j))
        _ = _ := by simp; ring
    have hNd : (N : ℝ)*(ρ/((N : ℝ)+1)) ≤ 1 := by
      have hm := mul_le_mul_of_nonneg_right (show (N : ℝ) ≤ (N : ℝ)+1 by linarith) hδ
      have he : ((N : ℝ)+1)*(ρ/((N : ℝ)+1))=ρ := mul_div_cancel₀ _ hN1.ne'
      rw [he] at hm
      exact hm.trans hρ1
    have hcoef : (N : ℝ)^2*(ρ/((N : ℝ)+1))^2 ≤ (b*Real.sqrt N)^2 := by
      have hs2 := Real.sq_sqrt (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
      have hleft : (N : ℝ)^2*(ρ/((N : ℝ)+1))^2 ≤ 1 := by nlinarith [mul_nonneg (Nat.cast_nonneg N : (0 : ℝ) ≤ N) hδ]
      rw [mul_pow,hs2]
      nlinarith [sq_nonneg b,mul_nonneg (show 0 ≤ b^2-1 by nlinarith) (show (0 : ℝ) ≤ N-1 by linarith)]
    exact (matrix_action_squaredSum_le (fun i j => z (i,j)) v).trans
      (mul_le_mul_of_nonneg_right (hen.trans hcoef) (Finset.sum_nonneg (fun _ _ => sq_nonneg _)))

theorem coordinateCube_subset_noiseCylinder {C k p N : ℕ} (d r : ℕ)
    (hN : 0 < N) (hk : 0 < k) (hkN : k ≤ N)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {ρ b : ℝ} (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hb : 1 ≤ b) :
    coordinateCube d N r (ρ/((N : ℝ)+1)) ⊆ noiseCylinder d e ρ b r := by
  intro z hz
  have hz' : ∀ q, |z q| ≤ ρ/((N : ℝ)+1) := fun q => abs_le.mpr (hz q (mem_univ _))
  have hδ : ρ/((N : ℝ)+1) ≤ ρ := div_le_self hρ (by linarith [Nat.cast_nonneg N (α := ℝ)])
  apply (noiseCylinder_iff d e ρ b r z).mpr
  refine ⟨fun i j => (hz' _).trans hδ,fun i => (hz' _).trans hδ,fun s => ?_⟩
  exact matrixNoiseCylinder_of_coordinates hN hk hkN e hρ hρ1 hb _ (fun ij => hz' _)

theorem exp_neg_reciprocal_le {q : ℝ} (hq : 0 < q) : Real.exp (-1/q) ≤ q := by
  have hl := Real.log_le_sub_one_of_pos (one_div_pos.mpr hq)
  rw [one_div,Real.log_inv] at hl
  have ht : -1/q ≤ Real.log q := by rw [neg_div,one_div]; linarith
  calc
    _ ≤ Real.exp (Real.log q) := Real.exp_le_exp.mpr ht
    _ = q := Real.exp_log hq

def smallWidthCylinderCost (ν : CoordinateLaw) (d r : ℕ) (T ρ : ℝ) : ℝ :=
  ((d : ℝ)+2+(r : ℝ)*T)*(T+1)/(coordinateBallConstant ν*ρ)

theorem noiseCylinder_smallWidth_exp_lower (ν : CoordinateLaw) {C k p N : ℕ} (d r : ℕ)
    (hN : 0 < N) (hk : 0 < k) (hkN : k ≤ N)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    {ρ b T : ℝ} (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) (hb : 1 ≤ b) (hNT : (N : ℝ) ≤ T) :
    Real.exp (-(N : ℝ)*smallWidthCylinderCost ν d r T ρ) ≤
      (rawPrior ν d N r).real (noiseCylinder d e ρ b r) := by
  let δ := ρ/((N : ℝ)+1)
  have hδ : 0 < δ := div_pos hρ (by positivity)
  have hδ1 : δ ≤ 1 := (div_le_self hρ.le (by linarith [Nat.cast_nonneg N (α := ℝ)])).trans hρ1
  have ha := coordinateBallConstant_pos ν
  have ht := (exp_neg_reciprocal_le (mul_pos ha hδ)).trans (coordinate_small_ball ν hδ.le hδ1)
  have hp := pow_le_pow_left₀ (Real.exp_nonneg _) ht (N*(d+2)+r*N*N)
  rw [←Real.exp_nat_mul] at hp
  have hm := measureReal_mono (μ := rawPrior ν d N r)
    (coordinateCube_subset_noiseCylinder d r hN hk hkN e hρ.le hρ1 hb)
  rw [coordinateCube_probability] at hm
  apply le_trans _ (hp.trans hm)
  apply Real.exp_le_exp.mpr
  have hN0 : (0 : ℝ) ≤ N := Nat.cast_nonneg N
  have hT0 : 0 ≤ T := hN0.trans hNT
  have hpcount : ((N*(d+2)+r*N*N : ℕ) : ℝ) ≤ (N : ℝ)*((d : ℝ)+2+(r : ℝ)*T) := by
    push_cast
    nlinarith [mul_le_mul_of_nonneg_left hNT (show (0 : ℝ) ≤ r*N by positivity)]
  have hrecip : 1/(coordinateBallConstant ν*δ) ≤ (T+1)/(coordinateBallConstant ν*ρ) := by
    dsimp [δ]
    rw [show 1/(coordinateBallConstant ν*(ρ/((N : ℝ)+1)))=
      ((N : ℝ)+1)/(coordinateBallConstant ν*ρ) by field_simp]
    exact div_le_div_of_nonneg_right (by linarith) (mul_nonneg ha.le hρ.le)
  have hbnd := mul_le_mul hpcount hrecip (by positivity)
    (show 0 ≤ (N : ℝ)*((d : ℝ)+2+(r : ℝ)*T) by positivity)
  unfold smallWidthCylinderCost
  ring_nf at hbnd ⊢
  linarith

end NeuralGeneralization.BatchTwoNonGaussian
