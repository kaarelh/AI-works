import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlMatrix

/-! Actual shifted Gaussian layers reproduce their population feature means
with finite-width probability bounded below at the expected quadratic cost. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {I J:Type*} [Fintype I] [Fintype J]

def shiftedMeanEvent (c:J→I→ℝ) (m:J→ℝ) (ε:ℝ) (M:ℕ):Set (Fin M→I→ℝ):=
  {w|∀j,|rowAverage (fun z=>Real.tanh (m j+rowLinear (c j) z)) w-gaussianRowMean (c j) (m j)|<ε}

theorem measurableSet_shiftedMeanEvent (c:J→I→ℝ) (m:J→ℝ) (ε:ℝ) (M:ℕ):
    MeasurableSet (shiftedMeanEvent c m ε M):=by
  simp only [shiftedMeanEvent,Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  apply measurableSet_lt _ measurable_const
  unfold rowAverage rowLinear
  fun_prop

theorem shifted_tanh_memLp (c:I→ℝ) (m:ℝ):
    MemLp (fun z:I→ℝ=>Real.tanh (m+rowLinear c z)) 2 (Measure.pi fun _ : I=>gaussianReal 0 1):=by
  apply (memLp_const (1:ℝ)).mono'
    ((show Measurable _ by unfold rowLinear;fun_prop).aestronglyMeasurable)
  filter_upwards [] with z
  exact (Real.abs_tanh_lt_one _).le

theorem shifted_tanh_secondMoment (c:I→ℝ) (m:ℝ):
    (∫z:I→ℝ,(Real.tanh (m+rowLinear c z))^2 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤1:=by
  have hh:=integral_mono (shifted_tanh_memLp c m).integrable_sq (integrable_const (1:ℝ))
    (fun z=>((sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one _)).le)
  simpa using hh

theorem shiftedMeanEvent_probability (c:J→I→ℝ) (m:J→ℝ) {ε:ℝ} (hε:0<ε) {M:ℕ} (hM:0<M)
    (hbudget:4*(Fintype.card J:ℝ)≤(M:ℝ)*ε^2):
    (3:ℝ)/4≤(Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
      (shiftedMeanEvent c m ε M):=by
  classical
  let μ:=Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)
  let E:J→Set (Fin M→I→ℝ):=fun j=>{w|ε≤|rowAverage
    (fun z=>Real.tanh (m j+rowLinear (c j) z)) w-gaussianRowMean (c j) (m j)|}
  have he:(shiftedMeanEvent c m ε M)ᶜ=⋃j,E j:=by
    ext w
    simp only [shiftedMeanEvent,Set.mem_compl_iff,Set.mem_setOf_eq,Set.mem_iUnion,not_forall,not_lt,E]
  have htail (j:J):μ.real (E j)≤1/((M:ℝ)*ε^2):=
    iid_rowAverage_tail _ (shifted_tanh_memLp (c j) (m j)) (shifted_tanh_secondMoment (c j) (m j)) hM hε
  have ht:μ.real (shiftedMeanEvent c m ε M)ᶜ≤(Fintype.card J:ℝ)/((M:ℝ)*ε^2):=by
    rw [he]
    apply (measureReal_iUnion_fintype_le E).trans
    have hh:=Finset.sum_le_sum (fun j (_:j∈Finset.univ)=>htail j)
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one_div] using hh
  rw [probReal_compl_eq_one_sub (measurableSet_shiftedMeanEvent c m ε M)] at ht
  have hb:(Fintype.card J:ℝ)/((M:ℝ)*ε^2)≤(1:ℝ)/4:=by
    apply (div_le_iff₀ (mul_pos (by exact_mod_cast hM) (sq_pos_of_pos hε))).mpr
    linarith
  linarith

/-- Under the original, unshifted Gaussian matrix law, the next layer can
follow the controlled population mean at quadratic rate M*a^2. -/
theorem amplification_matrix_probability (c:J→I→ℝ) (t:I→ℝ) (ht:∑i,t i^2=1)
    (a:ℝ) {ε:ℝ} (hε:0<ε) {M:ℕ} (hM:0<M)
    (hbudget:4*(Fintype.card J:ℝ)≤(M:ℝ)*ε^2):
    (1:ℝ)/2*Real.exp (-2*(M:ℝ)*a^2-4)≤
      (Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
        {w|∀j,|rowAverage (fun z=>Real.tanh (rowLinear (c j) z)) w-
          gaussianRowMean (c j) (a*(∑i,t i*c j i))|<ε}:=by
  let m:J→ℝ:=fun j=>a*(∑i,t i*c j i)
  let shift:Fin M→I→ℝ:=fun _ i=>a*t i
  have hh:=gaussian_matrix_control_lower shift (shiftedMeanEvent c m ε M)
    (measurableSet_shiftedMeanEvent c m ε M) (E:=(M:ℝ)*a^2) (by positivity)
    (by simpa only [shift,Fintype.card_fin] using (constant_matrix_control_cost (K:=Fin M) t ht a).le)
    (shiftedMeanEvent_probability c m hε hM hbudget)
  have hp (w:Fin M→I→ℝ) (k:Fin M) (j:J):
      m j+rowLinear (c j) (fun i=>w k i-shift k i)=rowLinear (c j) (w k):=by
    simp only [m,shift,rowLinear,mul_sub,Finset.sum_sub_distrib]
    have he:(∑i,c j i*(a*t i))=a*(∑i,t i*c j i):=by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [he]
    ring
  have he:matrixTranslate shift (shiftedMeanEvent c m ε M)=
      {w:Fin M→I→ℝ|∀j,|rowAverage (fun z=>Real.tanh (rowLinear (c j) z)) w-
        gaussianRowMean (c j) (a*(∑i,t i*c j i))|<ε}:=by
    ext w
    simp only [matrixTranslate,shiftedMeanEvent,Set.mem_setOf_eq,rowAverage,hp,m]
  rw [he] at hh
  convert hh using 1 <;> congr 2 <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthCritical
