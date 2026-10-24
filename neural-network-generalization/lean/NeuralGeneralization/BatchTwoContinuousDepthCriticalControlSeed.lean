import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlDilution

/-! A genuine width-N Gaussian first-layer seed at bounded normalized cost. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {I J:Type*} [Fintype I] [Fintype J] {N:ℕ}

def shiftedFamilyMean (c:I→ℝ) (s:Fin N→I→ℝ):ℝ:=
  (∑k,gaussianRowMean c (∑i,c i*s k i))/(N:ℝ)

def shiftedFamilyMeanEvent (c:J→I→ℝ) (s:Fin N→I→ℝ) (ε:ℝ):Set (Fin N→I→ℝ):=
  {w|∀j,|rowFamilyAverage (fun k z=>Real.tanh ((∑i,c j i*s k i)+rowLinear (c j) z)) w-
    shiftedFamilyMean (c j) s|<ε}

theorem measurableSet_shiftedFamilyMeanEvent (c:J→I→ℝ) (s:Fin N→I→ℝ) (ε:ℝ):
    MeasurableSet (shiftedFamilyMeanEvent c s ε):=by
  simp only [shiftedFamilyMeanEvent,Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  exact measurableSet_lt (by unfold rowFamilyAverage rowLinear;fun_prop) measurable_const

theorem shiftedFamilyMeanEvent_probability (c:J→I→ℝ) (s:Fin N→I→ℝ)
    {ε:ℝ} (hε:0<ε) (hN:0<N) (hbudget:4*(Fintype.card J:ℝ)≤(N:ℝ)*ε^2):
    (3:ℝ)/4≤(Measure.pi fun _ : Fin N=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
      (shiftedFamilyMeanEvent c s ε):=by
  classical
  let μ:=Measure.pi fun _ : Fin N=>(Measure.pi fun _ : I=>gaussianReal 0 1)
  let E:J→Set (Fin N→I→ℝ):=fun j=>{w|ε≤|rowFamilyAverage
    (fun k z=>Real.tanh ((∑i,c j i*s k i)+rowLinear (c j) z)) w-shiftedFamilyMean (c j) s|}
  have he:(shiftedFamilyMeanEvent c s ε)ᶜ=⋃j,E j:=by
    ext w
    simp only [shiftedFamilyMeanEvent,Set.mem_compl_iff,Set.mem_setOf_eq,Set.mem_iUnion,not_forall,not_lt,E]
  have htail (j:J):μ.real (E j)≤1/((N:ℝ)*ε^2):=
    independent_rowFamily_tail _ (fun k=>shifted_tanh_memLp (c j) (∑i,c j i*s k i))
      (fun k=>shifted_tanh_secondMoment (c j) (∑i,c j i*s k i)) hN hε
  have ht:μ.real (shiftedFamilyMeanEvent c s ε)ᶜ≤(Fintype.card J:ℝ)/((N:ℝ)*ε^2):=by
    rw [he]
    apply (measureReal_iUnion_fintype_le E).trans
    have hh:=Finset.sum_le_sum (fun j (_:j∈Finset.univ)=>htail j)
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one_div] using hh
  rw [probReal_compl_eq_one_sub (measurableSet_shiftedFamilyMeanEvent c s ε)] at ht
  have hb:(Fintype.card J:ℝ)/((N:ℝ)*ε^2)≤(1:ℝ)/4:=by
    apply (div_le_iff₀ (mul_pos (by exact_mod_cast hN) (sq_pos_of_pos hε))).mpr
    linarith
  linarith

/-- The seed event is measured under the original Gaussian matrix, with all
cost coming from literal row shifts. -/
theorem seed_matrix_probability (c:J→I→ℝ) (s:Fin N→I→ℝ) {E:ℝ}
    (hE:0≤E) (hcost:∑k,∑i,(s k i)^2≤E) {ε:ℝ} (hε:0<ε) (hN:0<N)
    (hbudget:4*(Fintype.card J:ℝ)≤(N:ℝ)*ε^2):
    (1:ℝ)/2*Real.exp (-2*E-4)≤
      (Measure.pi fun _ : Fin N=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
        {w|∀j,|rowAverage (fun z=>Real.tanh (rowLinear (c j) z)) w-shiftedFamilyMean (c j) s|<ε}:=by
  have hh:=gaussian_matrix_control_lower s (shiftedFamilyMeanEvent c s ε)
    (measurableSet_shiftedFamilyMeanEvent c s ε) hE hcost
    (shiftedFamilyMeanEvent_probability c s hε hN hbudget)
  have hp (w:Fin N→I→ℝ) (k:Fin N) (j:J):
      (∑i,c j i*s k i)+rowLinear (c j) (fun i=>w k i-s k i)=rowLinear (c j) (w k):=by
    simp only [rowLinear,mul_sub,Finset.sum_sub_distrib]
    ring
  have he:matrixTranslate s (shiftedFamilyMeanEvent c s ε)=
      {w:Fin N→I→ℝ|∀j,|rowAverage (fun z=>Real.tanh (rowLinear (c j) z)) w-
        shiftedFamilyMean (c j) s|<ε}:=by
    ext w
    simp only [matrixTranslate,shiftedFamilyMeanEvent,Set.mem_setOf_eq,rowFamilyAverage,rowAverage,hp]
  rwa [he] at hh

end NeuralGeneralization.BatchTwoContinuousDepthCritical
