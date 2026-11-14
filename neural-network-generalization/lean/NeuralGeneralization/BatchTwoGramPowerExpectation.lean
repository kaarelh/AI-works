import NeuralGeneralization.BatchTwoGramPowerBounds

/-! Isotropic sampling contracts the polynomial covariance potential. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix BatchTwoImprovedWeightedSampling
variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

def Isotropic (w : α→ℝ) (v : α→ι→ℝ) : Prop :=
  ∀u : ι→ℝ,mean w (fun x=>(v x ⬝ᵥ u)^2)=∑i,u i^2

theorem mean_powerMoment (w : α→ℝ) (v : α→ι→ℝ) (hiso : Isotropic w v)
    (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (p : ℕ) :
    mean w (fun x=>powerMoment A (v x) p)=Matrix.trace (A^p) := by
  simp_rw [powerMoment_spectral A hA]
  rw [mean_sum,trace_power_spectral A hA]
  apply Finset.sum_congr rfl
  intro i _
  have hc (x : α) : ((star (hA.eigenvectorUnitary : Matrix ι ι ℝ))*ᵥv x) i=
      v x ⬝ᵥ (hA.eigenvectorBasis i) := by
    simp only [Matrix.star_eq_conjTranspose,Matrix.conjTranspose_eq_transpose_of_trivial,
      Matrix.mulVec,hA.eigenvectorUnitary_transpose_apply]
    exact dotProduct_comm _ _
  simp_rw [hc,mul_comm (_^2) (hA.eigenvalues i^p)]
  rw [mean_mul,hiso]
  have hn : (∑j,(hA.eigenvectorBasis i) j^2)=1 := by
    rw [←EuclideanSpace.real_norm_sq_eq,hA.eigenvectorBasis.norm_eq_one,one_pow]
  rw [hn,mul_one]

theorem mean_trace_rankOne_step (w : α→ℝ) (hw : ∀x,0≤w x) (hm : ∑x,w x=1)
    (v : α→ι→ℝ) (hiso : Isotropic w v) {R a : ℝ} (hR : 0≤R) (ha : 0<a)
    (hv : ∀x,(∑i,v x i^2)≤R) (p : ℕ) (A : Matrix ι ι ℝ)
    (hA : QuadraticBounds A (2*(p:ℝ)*R+R) a) :
    mean w (fun x=>Matrix.trace ((A-vecMulVec (v x) (v x))^(p+1)))≤
      (1-3*((p:ℝ)+1)/(4*a))*Matrix.trace (A^(p+1)) := by
  have hs := hA.posSemidef (by positivity)
  have hb := trace_power_upper_shift A hs (fun i=>(hA.eigenvalues i).2) p
  calc
    _ ≤mean w (fun x=>Matrix.trace (A^(p+1))-3*((p:ℝ)+1)/4*powerMoment A (v x) p) := by
      apply mean_mono w hw
      intro x
      convert trace_power_rankOne_bounded A (v x) hR (hv x) p hA using 1 <;> ring
    _ =Matrix.trace (A^(p+1))-3*((p:ℝ)+1)/4*Matrix.trace (A^p) := by
      rw [mean_sub,mean_const w hm,mean_mul,mean_powerMoment w v hiso A hA.1]
    _ ≤_ := by
      apply (le_of_sub_nonneg ?_)
      field_simp
      nlinarith [mul_nonneg (show 0≤3*((p:ℝ)+1)/4 by positivity)
        (sub_nonneg.mpr hb)]

theorem mean_iidWeight_succ (w : α→ℝ) (n : ℕ) (f : (Fin (n+1)→α)→ℝ) :
    mean (iidWeight w (n+1)) f=
      mean w (fun x=>mean (iidWeight w n) (fun s=>f (Fin.cons x s))) := by
  classical
  unfold mean
  rw [←Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (n+1)=>α))]
  simp only [Fintype.sum_prod_type,Fin.consEquiv_apply,iidWeight,Fin.prod_univ_succ,
    Fin.cons_zero,Fin.cons_succ,Finset.mul_sum,mul_assoc]
  rfl

end NeuralGeneralization.BatchTwoGramPower
