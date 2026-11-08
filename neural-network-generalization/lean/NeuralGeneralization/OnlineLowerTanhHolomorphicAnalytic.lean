import NeuralGeneralization.OnlineLowerTanhHolomorphicSeries
import NeuralGeneralization.OnlineLowerTanhCurvature

noncomputable section
open scoped BigOperators
open Complex Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma hammingRatio_differentiableOn (j:ℕ) :
    DifferentiableOn ℂ (hammingRatio j) {z:ℂ|0<z.re} := by
  unfold hammingRatio
  apply DifferentiableOn.fun_finsetProd
  intro l hl
  apply DifferentiableOn.div
  · fun_prop
  · fun_prop
  · intro z hz
    exact hamming_den_ne_zero z l hz.le

lemma prefactoredRatio_differentiableOn (j:ℕ) :
    DifferentiableOn ℂ (prefactoredRatio j) {z:ℂ|0<z.re} := by
  unfold prefactoredRatio
  apply DifferentiableOn.mul _ (hammingRatio_differentiableOn j)
  apply DifferentiableOn.div
  · fun_prop
  · fun_prop
  · intro z hz he
    have hh:=congrArg Complex.re he
    simp at hh
    linarith [show 0<z.re from hz]

lemma complexLogistic_differentiableAt (j:ℕ) {a:ℂ} (ha:1≤a.re) :
    DifferentiableAt ℂ (complexLogistic j) a := by
  unfold complexLogistic
  apply DifferentiableAt.div
  · fun_prop
  · fun_prop
  · exact complexLogistic_den_ne j ha

/-- Analytic dependence remains available after any analytic choice of gain.
This version supports uniform-contraction construction of the optimizing branch. -/
theorem complexF_comp_differentiableOn (a:ℂ→ℂ) {U:Set ℂ} (hU:IsOpen U)
    (hz:∀z∈U,0<z.re) (ha:DifferentiableOn ℂ a U) (haRe:∀z∈U,1≤(a z).re) :
    DifferentiableOn ℂ (fun z=>complexF z (a z)) U := by
  apply DifferentiableOn.sub (differentiableOn_const 1)
  apply DifferentiableOn.const_mul
  refine differentiableOn_tsum_of_summable_norm logisticMajorant_summable ?_ hU ?_
  · intro j z hzU
    apply DifferentiableWithinAt.mul
    · apply DifferentiableWithinAt.const_mul
      exact prefactoredRatio_differentiableOn j z (hz z hzU) |>.mono (fun w hw=>hz w hw)
    · exact (complexLogistic_differentiableAt j (haRe z hzU)).comp_differentiableWithinAt z (ha z hzU)
  · intro j z hzU
    rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
    calc
      _ ≤ 1*logisticMajorant j :=
        mul_le_mul (prefactoredRatio_norm_le_one j (hz z hzU).le) (complexLogistic_bound j (haRe z hzU))
          (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _

lemma complexF_gain_differentiableOn {z:ℂ} (hz:0≤z.re) :
    DifferentiableOn ℂ (complexF z) {a:ℂ|1<a.re} := by
  apply DifferentiableOn.sub (differentiableOn_const 1)
  apply DifferentiableOn.const_mul
  refine differentiableOn_tsum_of_summable_norm logisticMajorant_summable ?_
    (isOpen_lt continuous_const Complex.continuous_re) ?_
  · intro j a ha
    exact (complexLogistic_differentiableAt j ha.le).const_mul _ |>.differentiableWithinAt
  · intro j a ha
    rw [norm_mul,norm_mul,norm_pow,norm_neg,norm_one,one_pow,one_mul]
    calc
      _ ≤ 1*logisticMajorant j :=
        mul_le_mul (prefactoredRatio_norm_le_one j hz) (complexLogistic_bound j ha.le)
          (norm_nonneg _) (by norm_num)
      _ = _ := one_mul _

lemma complexLogistic_ofReal (j:ℕ) (a:ℝ) :
    complexLogistic j (a:ℂ)=(logisticTail j a:ℂ) := by
  rw [logisticTail_exp]
  unfold complexLogistic
  push_cast
  rfl

lemma complexF0_ofReal (a:ℝ) : complexF0 (a:ℂ)=(scalarF0 a:ℂ) := by
  unfold complexF0 scalarF0 scalarF0Y
  rw [Complex.ofReal_sub,Complex.ofReal_mul,Complex.ofReal_tsum]
  congr 1
  congr 1
  apply tsum_congr
  intro j
  rw [complexLogistic_ofReal]
  simp [logisticTail]

lemma complexF1_ofReal (a:ℝ) : complexF1 (a:ℂ)=(scalarF1 a:ℂ) := by
  unfold complexF1 scalarF1 scalarF1Y
  rw [Complex.ofReal_mul,Complex.ofReal_tsum]
  have he (j:ℕ) : -((-1:ℂ)^j*(prefactoredFirst j:ℂ)*complexLogistic j (a:ℂ))=
      (((-1:ℝ)^j*(1+2*(j:ℝ)*((j:ℝ)+1))*logisticValue j (Real.exp (-2*a)):ℝ):ℂ) := by
    rw [complexLogistic_ofReal]
    unfold prefactoredFirst ratioFirst logisticTail
    push_cast
    ring
  rw [show (-4:ℂ)=4*(-1) by ring,mul_assoc,←tsum_mul_left]
  congr 1
  apply tsum_congr
  intro j
  simpa only [neg_one_mul] using he j

lemma complexF2_ofReal (a:ℝ) : complexF2 (a:ℂ)=(scalarF2 a:ℂ) := by
  unfold complexF2 scalarF2 scalarF2Y
  push_cast
  congr 1
  apply tsum_congr
  intro j
  rw [complexLogistic_ofReal]
  unfold prefactoredSecond ratioSecond ratioFirst logisticTail
  push_cast
  ring

end NeuralGeneralization.OnlineLowerTanh
