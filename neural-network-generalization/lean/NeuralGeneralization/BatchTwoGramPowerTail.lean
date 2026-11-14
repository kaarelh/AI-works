import NeuralGeneralization.BatchTwoGramPowerProcess

/-! A trace-power upper bound for the literal bad empirical Gram event. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix BatchTwoImprovedWeightedSampling Classical
variable {ι α : Type*} [Fintype ι] [DecidableEq ι] [Fintype α]

theorem exists_eigenvalue_gt (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (u : ι→ℝ) (hu : (∑i,u i^2)=1) {b : ℝ} (hb : b<powerMoment A u 1) :
    ∃i,b<hA.eigenvalues i := by
  by_contra h
  push Not at h
  have hn := powerMoment_spectral A hA u 0
  simp only [powerMoment_zero,pow_zero,mul_one,hu] at hn
  have hh : powerMoment A u 1≤b := by
    rw [powerMoment_spectral A hA]
    simp only [pow_one]
    calc
      _ ≤∑i,((star (hA.eigenvectorUnitary : Matrix ι ι ℝ))*ᵥu) i^2*b :=
        Finset.sum_le_sum fun i _=>mul_le_mul_of_nonneg_left (h i) (sq_nonneg _)
      _ =b := by rw [←Finset.sum_mul,←hn,one_mul]
  exact (not_lt_of_ge hh) hb

theorem trace_power_ge_of_unit (A : Matrix ι ι ℝ) (hA : A.PosSemidef)
    (u : ι→ℝ) (hu : (∑i,u i^2)=1) {b : ℝ} (hb : 0≤b)
    (hlarge : b<powerMoment A u 1) (p : ℕ) : b^p≤Matrix.trace (A^p) := by
  obtain ⟨i,hi⟩ := exists_eigenvalue_gt A hA.1 u hu hlarge
  rw [trace_power_spectral A hA.1]
  exact (pow_le_pow_left₀ hb hi.le p).trans
    (Finset.single_le_sum (fun j _=>pow_nonneg (hA.eigenvalues_nonneg j) p) (Finset.mem_univ i))

theorem powerMoment_sampleBarrier (a : ℝ) (v : α→ι→ℝ) {n : ℕ}
    (s : Fin n→α) (u : ι→ℝ) :
    powerMoment (sampleBarrier a v s) u 1=a*(∑i,u i^2)-∑i,(v (s i) ⬝ᵥu)^2 := by
  simp only [powerMoment,pow_one,sampleBarrier,Matrix.sub_mulVec,Matrix.smul_mulVec,
    Matrix.one_mulVec,Matrix.sum_mulVec,dotProduct_sub,dotProduct_smul,dotProduct_sum,
    Matrix.vecMulVec_mulVec,op_smul_eq_smul,smul_eq_mul]
  congr 1
  · congr 1
    simp [dotProduct,pow_two]
  · apply Finset.sum_congr rfl
    intro i _
    rw [dotProduct_comm u (v (s i))]
    ring

theorem weighted_badGram_power_probability (w : α→ℝ) (hw : ∀x,0≤w x)
    (hm : ∑x,w x=1) {D : ℕ} (v : α→Fin D→ℝ) (hiso : Isotropic w v)
    {R a : ℝ} (hR : 0≤R) (ha : 0<a) (hv : ∀x,(∑i,v x i^2)≤R)
    (p n : ℕ) (hc : 0≤1-3*((p:ℝ)+1)/(4*a))
    (hbudget : (2*(p:ℝ)+(n:ℝ))*R≤a) (hlower : 0<a-(n:ℝ)/2) :
    mean (iidWeight w n) (fun s=>if badGram v s then (1:ℝ) else 0)≤
      ((1-3*((p:ℝ)+1)/(4*a))^n*((D:ℝ)*a^(p+1)))/(a-(n:ℝ)/2)^(p+1) := by
  classical
  have hpoint (s : Fin n→α) :
      (a-(n:ℝ)/2)^(p+1)*(if badGram v s then (1:ℝ) else 0)≤
        Matrix.trace ((sampleBarrier a v s)^(p+1)) := by
    have hb0 : 0≤a-(n:ℝ)*R := by nlinarith [mul_nonneg (Nat.cast_nonneg p) hR]
    have hs := (sampleBarrier_bounds a v hv n s).posSemidef hb0
    by_cases h : badGram v s
    · simp only [if_pos h,mul_one]
      obtain ⟨u,hu,huv⟩ := h
      apply trace_power_ge_of_unit _ hs u hu hlower.le _ (p+1)
      rw [powerMoment_sampleBarrier,hu,mul_one]
      change (∑i,(v (s i) ⬝ᵥu)^2)<(n:ℝ)/2 at huv
      linarith
    · simp only [if_neg h,mul_zero]
      exact trace_power_nonneg _ hs _
  have he := mean_mono (iidWeight w n) (iidWeight_nonneg w hw n) hpoint
  rw [mean_mul] at he
  have hh := he.trans (mean_trace_sampleBarrier w hw hm v hiso hR ha hv p n hc hbudget)
  exact (le_div_iff₀ (pow_pos hlower _)).mpr (by simpa only [mul_comm,Fintype.card_fin] using hh)

end NeuralGeneralization.BatchTwoGramPower
