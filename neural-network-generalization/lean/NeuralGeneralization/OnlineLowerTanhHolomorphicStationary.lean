import NeuralGeneralization.OnlineLowerTanhHolomorphicAnalytic

noncomputable section
set_option maxHeartbeats 800000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Complex Set
namespace NeuralGeneralization.OnlineLowerTanh

def complexLogisticFirst (j:ℕ) (a:ℂ) : ℂ :=
  (-2*(2*(j:ℂ)+1))*Complex.exp (-2*a*(2*(j:ℂ)+1))/(1+Complex.exp (-2*a*(2*(j:ℂ)+1)))^2

def complexFDerivative (z a:ℂ) : ℂ :=
  -4*∑'j:ℕ,(-1:ℂ)^j*prefactoredRatio j z*complexLogisticFirst j a

def complexStationary (z a:ℂ) : ℂ := a*complexFDerivative z a-complexF z a

def logisticFirstMajorant (j:ℕ) : ℝ := 16*((j:ℝ)+1)*logisticMajorant j

lemma complexLogistic_hasDerivAt (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    HasDerivAt (complexLogistic j) (complexLogisticFirst j a) a := by
  have he : HasDerivAt (fun b:ℂ=>Complex.exp (-2*b*(2*(j:ℂ)+1)))
      ((-2*(2*(j:ℂ)+1))*Complex.exp (-2*a*(2*(j:ℂ)+1))) a := by
    have hlin : HasDerivAt (fun b:ℂ=>-2*b*(2*(j:ℂ)+1)) (-2*(2*(j:ℂ)+1)) a := by
      simpa only [id_eq,mul_one] using ((hasDerivAt_id a).const_mul (-2:ℂ)).mul_const (2*(j:ℂ)+1)
    convert! (Complex.hasDerivAt_exp (-2*a*(2*(j:ℂ)+1))).comp a hlin using 1 <;> ring
  have h:=he.div ((hasDerivAt_const a 1).add he) (complexLogistic_den_ne j ha)
  simp only [Pi.add_apply,Pi.div_apply,zero_add] at h
  convert! h using 1
  unfold complexLogisticFirst
  ring

lemma complexLogisticFirst_bound (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    ‖complexLogisticFirst j a‖≤logisticFirstMajorant j := by
  have hc : ‖(-2:ℂ)*(2*(j:ℂ)+1)‖=2*(2*(j:ℝ)+1) := by
    have he : (-2:ℂ)*(2*(j:ℂ)+1)=((-2*(2*(j:ℝ)+1):ℝ):ℂ) := by push_cast; rfl
    rw [he,Complex.norm_real,Real.norm_eq_abs,abs_mul,abs_of_nonneg (by positivity : 0≤2*(j:ℝ)+1)]
    norm_num
  have hd:=complexLogistic_den_lower j ha
  have he : ‖Complex.exp (-2*a*(2*(j:ℂ)+1))‖≤logisticMajorant j := by
    apply (complexLogistic_exp_bound j ha).trans
    have h2 : Real.exp (-2)≤2 := exp_neg_two_le_half.trans (by norm_num)
    exact mul_le_mul_of_nonneg_right h2 (pow_nonneg (Real.exp_pos _).le j)
  unfold complexLogisticFirst
  rw [norm_div,norm_mul,norm_pow,hc]
  calc
    _ ≤ (2*(2*(j:ℝ)+1)*logisticMajorant j)/(1/4) :=
      div_le_div₀ (by unfold logisticMajorant; positivity)
        (mul_le_mul_of_nonneg_left he (by positivity)) (by norm_num) (by nlinarith)
    _ ≤ logisticFirstMajorant j := by
      unfold logisticFirstMajorant
      have hp:0≤logisticMajorant j := by unfold logisticMajorant; positivity
      nlinarith

lemma logisticFirstMajorant_summable : Summable logisticFirstMajorant := by
  unfold logisticFirstMajorant
  simpa only [pow_one,mul_assoc] using (logisticMajorant_poly_summable 1).mul_left 16

lemma complexLogisticFirst_differentiableAt (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    DifferentiableAt ℂ (complexLogisticFirst j) a := by
  unfold complexLogisticFirst
  apply DifferentiableAt.div
  · fun_prop
  · fun_prop
  · exact pow_ne_zero _ (complexLogistic_den_ne j ha)

lemma complexFDerivative_summable {z a:ℂ} (hz:0≤z.re) (ha:1≤a.re) :
    Summable (fun j:ℕ=>(-1:ℂ)^j*prefactoredRatio j z*complexLogisticFirst j a) := by
  apply logisticFirstMajorant_summable.of_norm_bounded
  intro j
  rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
  calc
    _ ≤ 1*logisticFirstMajorant j :=
      mul_le_mul (prefactoredRatio_norm_le_one j hz) (complexLogisticFirst_bound j ha)
        (norm_nonneg _) (by norm_num)
    _ = _ := one_mul _

lemma complexF_hasDerivAt {z a:ℂ} (hz:0≤z.re) (ha:1<a.re) :
    HasDerivAt (complexF z) (complexFDerivative z a) a := by
  let S : ℂ→ℂ := fun b=>∑'j:ℕ,(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j b
  have hd (j:ℕ) : DifferentiableOn ℂ
      (fun b=>(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j b) {b:ℂ|1<b.re} := by
    intro b hb
    exact ((complexLogistic_hasDerivAt j hb.le).const_mul _).differentiableAt.differentiableWithinAt
  have hb (j:ℕ) (b:ℂ) (hb:1<b.re) :
      ‖(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j b‖≤logisticMajorant j := by
    rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
    calc
      _ ≤ 1*logisticMajorant j :=
        mul_le_mul (prefactoredRatio_norm_le_one j hz) (complexLogistic_bound j hb.le)
          (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _
  have hs:=hasSum_deriv_of_summable_norm logisticMajorant_summable hd
    (isOpen_lt continuous_const Complex.continuous_re) hb ha
  have hterm (j:ℕ) : deriv (fun b=>(-1:ℂ)^j*prefactoredRatio j z*complexLogistic j b) a=
      (-1:ℂ)^j*prefactoredRatio j z*complexLogisticFirst j a :=
    ((complexLogistic_hasDerivAt j ha.le).const_mul _).deriv
  simp_rw [hterm] at hs
  have hSd : DifferentiableAt ℂ S a :=
    (differentiableOn_tsum_of_summable_norm logisticMajorant_summable hd
      (isOpen_lt continuous_const Complex.continuous_re) hb).differentiableAt
      ((isOpen_lt continuous_const Complex.continuous_re).mem_nhds ha)
  have hS := hSd.hasDerivAt
  rw [←hs.tsum_eq] at hS
  unfold complexFDerivative
  convert! (hasDerivAt_const a 1).sub (hS.const_mul 4) using 1 <;>
    first | rfl | ring | (dsimp only [complexF,S,Pi.sub_apply]; ring)

/-- The stationary equation is analytic after analytic substitution of gain. -/
theorem complexStationary_comp_differentiableOn (a:ℂ→ℂ) {U:Set ℂ} (hU:IsOpen U)
    (hz:∀z∈U,0<z.re) (ha:DifferentiableOn ℂ a U) (haRe:∀z∈U,1≤(a z).re) :
    DifferentiableOn ℂ (fun z=>complexStationary z (a z)) U := by
  apply DifferentiableOn.sub _ (complexF_comp_differentiableOn a hU hz ha haRe)
  apply ha.mul
  apply DifferentiableOn.const_mul
  refine differentiableOn_tsum_of_summable_norm logisticFirstMajorant_summable ?_ hU ?_
  · intro j z hzU
    apply DifferentiableWithinAt.mul
    · apply DifferentiableWithinAt.const_mul
      exact prefactoredRatio_differentiableOn j z (hz z hzU) |>.mono (fun w hw=>hz w hw)
    · exact (complexLogisticFirst_differentiableAt j (haRe z hzU)).comp_differentiableWithinAt z (ha z hzU)
  · intro j z hzU
    rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
    calc
      _ ≤ 1*logisticFirstMajorant j :=
        mul_le_mul (prefactoredRatio_norm_le_one j (hz z hzU).le) (complexLogisticFirst_bound j (haRe z hzU))
          (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _

end NeuralGeneralization.OnlineLowerTanh
