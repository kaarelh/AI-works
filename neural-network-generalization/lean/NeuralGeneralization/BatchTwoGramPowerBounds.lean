import NeuralGeneralization.BatchTwoGramPowerDescent

/-! Rayleigh bounds and trace powers for finite real covariance matrices. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def QuadraticBounds (A : Matrix ι ι ℝ) (b a : ℝ) : Prop :=
  A.IsHermitian ∧ ∀u : ι→ℝ,
    b*(∑i,u i^2)≤powerMoment A u 1 ∧ powerMoment A u 1≤a*(∑i,u i^2)

theorem QuadraticBounds.eigenvalues {A : Matrix ι ι ℝ} {b a : ℝ} (h : QuadraticBounds A b a) (i : ι) :
    b≤h.1.eigenvalues i ∧ h.1.eigenvalues i≤a := by
  have hh := h.2 (h.1.eigenvectorBasis i)
  have hn : (∑j,(h.1.eigenvectorBasis i) j^2)=1 := by
    rw [←EuclideanSpace.real_norm_sq_eq,h.1.eigenvectorBasis.norm_eq_one,one_pow]
  have he : powerMoment A (h.1.eigenvectorBasis i) 1=h.1.eigenvalues i := by
    simpa only [powerMoment,pow_one,star_trivial,RCLike.re_to_real] using (h.1.eigenvalues_eq i).symm
  rw [hn,mul_one,mul_one,he] at hh
  exact hh

theorem QuadraticBounds.posSemidef {A : Matrix ι ι ℝ} {b a : ℝ}
    (h : QuadraticBounds A b a) (hb : 0≤b) : A.PosSemidef := by
  apply Matrix.PosSemidef.of_dotProduct_mulVec_nonneg h.1
  intro u
  have hh := (h.2 u).1
  simp only [powerMoment,pow_one] at hh
  simpa only [star_trivial] using (mul_nonneg hb (Finset.sum_nonneg fun _ _=>sq_nonneg _)).trans hh

theorem powerMoment_rankOnePath (A : Matrix ι ι ℝ) (v u : ι→ℝ) (t : ℝ) :
    powerMoment (rankOnePath A v t) u 1=powerMoment A u 1-t*(v ⬝ᵥ u)^2 := by
  simp only [powerMoment,pow_one,rankOnePath,Matrix.sub_mulVec,Matrix.smul_mulVec,
    Matrix.vecMulVec_mulVec,dotProduct_sub,dotProduct_smul,op_smul_eq_smul,smul_eq_mul]
  rw [dotProduct_comm u v]
  ring

theorem QuadraticBounds.rankOnePath {A : Matrix ι ι ℝ} {b a R : ℝ}
    (h : QuadraticBounds A b a) (v : ι→ℝ) (hv : (∑i,v i^2)≤R)
    {t : ℝ} (ht : t∈Set.Icc (0:ℝ) 1) : QuadraticBounds (rankOnePath A v t) (b-R) a := by
  have hsym : (vecMulVec v v : Matrix ι ι ℝ).IsHermitian := by
    ext i j
    simp [Matrix.conjTranspose,Matrix.vecMulVec,mul_comm]
  refine ⟨h.1.sub (hsym.smul (by rw [isSelfAdjoint_iff]; rfl : IsSelfAdjoint t)),?_⟩
  intro u
  rw [powerMoment_rankOnePath]
  have hu : 0≤∑i,u i^2 := Finset.sum_nonneg fun _ _=>sq_nonneg _
  have hcs : (v ⬝ᵥ u)^2≤R*(∑i,u i^2) :=
    (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v u).trans (mul_le_mul_of_nonneg_right hv hu)
  have ht0 := mul_nonneg ht.1 (sq_nonneg (v ⬝ᵥ u))
  have ht1 := mul_le_mul_of_nonneg_right ht.2 (sq_nonneg (v ⬝ᵥ u))
  constructor <;> nlinarith [(h.2 u).1,(h.2 u).2]

theorem trace_power_spectral (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (p : ℕ) :
    Matrix.trace (A^p)=∑i,hA.eigenvalues i^p := by
  have hp : A^p=Unitary.conjStarAlgAut ℝ _ hA.eigenvectorUnitary
      (Matrix.diagonal (fun i=>hA.eigenvalues i^p)) := by
    calc
      A^p=(Unitary.conjStarAlgAut ℝ _ hA.eigenvectorUnitary
        (Matrix.diagonal (RCLike.ofReal ∘ hA.eigenvalues)))^p := congrArg (fun M=>M^p) hA.spectral_theorem
      _ = _ := by rw [←map_pow,Matrix.diagonal_pow]; rfl
  rw [hp,Unitary.conjStarAlgAut_apply,Matrix.trace_mul_cycle,Unitary.coe_star_mul_self,one_mul,Matrix.trace_diagonal]

theorem trace_power_nonneg (A : Matrix ι ι ℝ) (hA : A.PosSemidef) (p : ℕ) :
    0≤Matrix.trace (A^p) := by
  rw [trace_power_spectral A hA.1]
  exact Finset.sum_nonneg fun i _=>pow_nonneg (hA.eigenvalues_nonneg i) p

theorem trace_power_upper_shift (A : Matrix ι ι ℝ) (hA : A.PosSemidef) {a : ℝ}
    (ha : ∀i,hA.1.eigenvalues i≤a) (p : ℕ) :
    Matrix.trace (A^(p+1))≤a*Matrix.trace (A^p) := by
  simp_rw [trace_power_spectral A hA.1]
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  rw [pow_succ]
  exact (mul_le_mul_of_nonneg_left (ha i) (pow_nonneg (hA.eigenvalues_nonneg i) p)).trans_eq (mul_comm _ _)

theorem trace_power_rankOne_bounded (A : Matrix ι ι ℝ) (v : ι→ℝ) {R a : ℝ}
    (hR : 0≤R) (hv : (∑i,v i^2)≤R) (p : ℕ)
    (hA : QuadraticBounds A (2*(p:ℝ)*R+R) a) :
    Matrix.trace ((A-vecMulVec v v)^(p+1))≤Matrix.trace (A^(p+1))-
      3*((p:ℝ)+1)*powerMoment A v p/4 := by
  have hp (t : ℝ) (ht : t∈Set.Icc (0:ℝ) 1) :
      QuadraticBounds (rankOnePath A v t) (2*(p:ℝ)*R) a := by
    simpa only [add_sub_cancel_right] using hA.rankOnePath v hv ht
  have hs (t : ℝ) (ht : t∈Set.Icc (0:ℝ) 1) := (hp t ht).posSemidef (by positivity)
  exact trace_power_rankOne_step A v hv p hs (fun t ht i=>(hp t ht).eigenvalues i |>.1)

end NeuralGeneralization.BatchTwoGramPower
