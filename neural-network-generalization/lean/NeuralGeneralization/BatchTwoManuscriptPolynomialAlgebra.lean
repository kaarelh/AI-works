import NeuralGeneralization.BatchTwoManuscriptResources

/-! Universal real-valued polynomial bounds for the literal compression parameters. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptResources

structure PolynomialHypotheses (AK AR AF : ℝ) (p : Input) (S : ℝ) : Prop where
  size : 2≤S
  dimension : (p.dimension:ℝ)≤S
  depth : (p.depth:ℝ)≤S
  energy : p.energy≤AK*S^3
  radius : p.radius⁻¹≤AR*S^3
  failure : p.failure⁻¹≤AF*S

def PolynomialGrowth (AK AR AF : ℝ) (f : Input→ℝ) (n : ℕ) : Prop :=
  ∃a : ℝ,0<a ∧ ∀p S,PolynomialHypotheses AK AR AF p S→|f p|≤a*S^n

namespace PolynomialGrowth
variable {AK AR AF : ℝ}

theorem const (x : ℝ) : PolynomialGrowth AK AR AF (fun _=>x) 0 := by
  refine ⟨|x|+1,by positivity,?_⟩
  intro p S h
  simp only [pow_zero,mul_one]
  linarith

theorem dimension : PolynomialGrowth AK AR AF (fun p=>(p.dimension:ℝ)) 1 := by
  refine ⟨1,by norm_num,?_⟩
  intro p S h
  simpa only [pow_one,one_mul,abs_of_nonneg (Nat.cast_nonneg p.dimension : (0:ℝ)≤p.dimension)] using h.dimension

theorem depth : PolynomialGrowth AK AR AF (fun p=>(p.depth:ℝ)) 1 := by
  refine ⟨1,by norm_num,?_⟩
  intro p S h
  simpa only [pow_one,one_mul,abs_of_nonneg (Nat.cast_nonneg p.depth : (0:ℝ)≤p.depth)] using h.depth

theorem energy (hA : 0<AK) : PolynomialGrowth AK AR AF Input.energy 3 :=
  ⟨AK,hA,fun p S h=>by rw [abs_of_nonneg (energy_pos p).le]; exact h.energy⟩

theorem radius (hA : 0<AR) : PolynomialGrowth AK AR AF (fun p=>p.radius⁻¹) 3 :=
  ⟨AR,hA,fun p S h=>by rw [abs_of_nonneg (inv_nonneg.mpr p.radius_pos.le)]; exact h.radius⟩

theorem failure (hA : 0<AF) : PolynomialGrowth AK AR AF (fun p=>p.failure⁻¹) 1 :=
  ⟨AF,hA,fun p S h=>by rw [abs_of_nonneg (inv_nonneg.mpr p.failure_pos.le),pow_one]; exact h.failure⟩

theorem mono {f : Input→ℝ} {a b : ℕ} (hf : PolynomialGrowth AK AR AF f a) (hab : a≤b) :
    PolynomialGrowth AK AR AF f b := by
  obtain ⟨k,hk,hf⟩ := hf
  exact ⟨k,hk,fun p S h=>(hf p S h).trans
    (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ (by linarith [h.size]) hab) hk.le)⟩

theorem add {f g : Input→ℝ} {n : ℕ}
    (hf : PolynomialGrowth AK AR AF f n) (hg : PolynomialGrowth AK AR AF g n) :
    PolynomialGrowth AK AR AF (fun p=>f p+g p) n := by
  obtain ⟨a,ha,hf⟩ := hf
  obtain ⟨b,hb,hg⟩ := hg
  refine ⟨a+b,by positivity,?_⟩
  intro p S h
  exact (abs_add_le _ _).trans ((add_le_add (hf p S h) (hg p S h)).trans_eq (by ring))

theorem mul {f g : Input→ℝ} {a b : ℕ}
    (hf : PolynomialGrowth AK AR AF f a) (hg : PolynomialGrowth AK AR AF g b) :
    PolynomialGrowth AK AR AF (fun p=>f p*g p) (a+b) := by
  obtain ⟨k,hk,hf⟩ := hf
  obtain ⟨l,hl,hg⟩ := hg
  refine ⟨k*l,by positivity,?_⟩
  intro p S h
  have hS : 0≤S := by linarith [h.size]
  rw [abs_mul]
  exact (mul_le_mul (hf p S h) (hg p S h) (abs_nonneg _) (by positivity)).trans_eq (by rw [pow_add]; ring)

theorem const_mul {f : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f n) (x : ℝ) :
    PolynomialGrowth AK AR AF (fun p=>x*f p) n := by simpa using (const x).mul hf

theorem pow {f : Input→ℝ} {a : ℕ} (hf : PolynomialGrowth AK AR AF f a) (n : ℕ) :
    PolynomialGrowth AK AR AF (fun p=>f p^n) (a*n) := by
  induction n with
  | zero => simpa using const 1
  | succ n ih => simpa only [pow_succ,Nat.mul_succ] using ih.mul hf

theorem congr {f g : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f n)
    (hfg : ∀p,f p=g p) : PolynomialGrowth AK AR AF g n := by
  obtain ⟨a,ha,hf⟩ := hf
  exact ⟨a,ha,fun p S h=>by rw [←hfg]; exact hf p S h⟩

theorem nonnegative_le {f g : Input→ℝ} {n : ℕ} (hg : PolynomialGrowth AK AR AF g n)
    (hf : ∀p,0≤f p) (hfg : ∀p,f p≤g p) : PolynomialGrowth AK AR AF f n := by
  obtain ⟨a,ha,hg⟩ := hg
  exact ⟨a,ha,fun p S h=>by rw [abs_of_nonneg (hf p)]; exact (hfg p).trans ((le_abs_self _).trans (hg p S h))⟩

theorem max_growth {f g : Input→ℝ} {n : ℕ}
    (hf : PolynomialGrowth AK AR AF f n) (hg : PolynomialGrowth AK AR AF g n) :
    PolynomialGrowth AK AR AF (fun p=>max (f p) (g p)) n := by
  obtain ⟨a,ha,hf⟩ := hf
  obtain ⟨b,hb,hg⟩ := hg
  refine ⟨a+b,by positivity,?_⟩
  intro p S h
  have hh : |max (f p) (g p)|≤|f p|+|g p| := by
    rcases le_total (f p) (g p) with hh|hh
    · rw [max_eq_right hh]; linarith [abs_nonneg (f p)]
    · rw [max_eq_left hh]; linarith [abs_nonneg (g p)]
  nlinarith [hf p S h,hg p S h]

theorem ceil {f : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f n) :
    PolynomialGrowth AK AR AF (fun p=>(⌈f p⌉₊:ℝ)) n := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨a+1,by positivity,?_⟩
  intro p S h
  have hh : (⌈f p⌉₊:ℝ)≤|f p|+1 := by
    by_cases hp : 0≤f p
    · rw [abs_of_nonneg hp]; exact (Nat.ceil_lt_add_one hp).le
    · rw [Nat.ceil_eq_zero.mpr (le_of_not_ge hp)]; simp only [Nat.cast_zero]; positivity
  rw [abs_of_nonneg (Nat.cast_nonneg _)]
  nlinarith [hf p S h,one_le_pow₀ (show 1≤S by linarith [h.size]) (n:=n)]

theorem divide_ge_one {f g : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f n)
    (hg : ∀p,1≤g p) : PolynomialGrowth AK AR AF (fun p=>f p/g p) n := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨a,ha,?_⟩
  intro p S h
  rw [abs_div,abs_of_nonneg ((by norm_num : (0:ℝ)≤1).trans (hg p))]
  exact (div_le_self (abs_nonneg _) (hg p)).trans (hf p S h)

theorem sqrt_even {f : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f (2*n)) :
    PolynomialGrowth AK AR AF (fun p=>Real.sqrt (f p)) n := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨Real.sqrt a,by positivity,?_⟩
  intro p S h
  have hS : 0≤S := by linarith [h.size]
  rw [abs_of_nonneg (Real.sqrt_nonneg _)]
  apply Real.sqrt_le_iff.mpr
  refine ⟨by positivity,?_⟩
  have hh := (le_abs_self _).trans (hf p S h)
  rw [mul_pow,Real.sq_sqrt ha.le,←pow_mul]
  simpa only [Nat.mul_comm] using hh

theorem log {f : Input→ℝ} {n : ℕ} (hf : PolynomialGrowth AK AR AF f n)
    (hf1 : ∀p,1≤f p) : PolynomialGrowth AK AR AF (fun p=>Real.log (f p)) 1 := by
  obtain ⟨a,ha,hf⟩ := hf
  refine ⟨|Real.log a|+(n:ℝ)+1,by positivity,?_⟩
  intro p S h
  have hS : 1≤S := by linarith [h.size]
  have hS0 : 0<S := by linarith
  have hfp : 0<f p := lt_of_lt_of_le zero_lt_one (hf1 p)
  have hh := Real.log_le_log hfp ((le_abs_self _).trans (hf p S h))
  rw [Real.log_mul ha.ne' (pow_pos hS0 _).ne',Real.log_pow] at hh
  have hl := Real.log_le_sub_one_of_pos hS0
  have hmul := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg n : (0:ℝ)≤n)
  have habs := mul_le_mul_of_nonneg_left hS (abs_nonneg (Real.log a))
  rw [abs_of_nonneg (Real.log_nonneg (hf1 p)),pow_one]
  nlinarith [le_abs_self (Real.log a)]

end PolynomialGrowth
end NeuralGeneralization.BatchTwoManuscriptResources
