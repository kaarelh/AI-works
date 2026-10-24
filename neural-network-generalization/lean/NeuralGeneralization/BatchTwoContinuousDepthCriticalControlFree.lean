import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlRows

/-! Dimension-uniform finite-width probability of a free-layer transition. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {I J:Type*} [Fintype I] [Fintype J]

def freeRowEvent (c:J→I→ℝ) (t:I→ℝ) (ε:ℝ) (M:ℕ):Set (Fin M→I→ℝ):=
  {w| |rowAverage (fun z=>(rowLinear t z)^2) w-1|<ε ∧
    ∀j, |rowAverage (fun z=>(Real.tanh (rowLinear (c j) z))^2) w-
      coolingSecondMoment (∑i,(c j i)^2)|<ε ∧
    |rowAverage (fun z=>rowLinear t z*Real.tanh (rowLinear (c j) z)) w-
      (∑i,t i*c j i)*coolingDerivative (∑i,(c j i)^2)|<ε}

theorem measurableSet_freeRowEvent (c:J→I→ℝ) (t:I→ℝ) (ε:ℝ) (M:ℕ):
    MeasurableSet (freeRowEvent c t ε M):=by
  simp only [freeRowEvent,Set.setOf_and,Set.setOf_forall]
  apply MeasurableSet.inter
  · apply measurableSet_lt _ measurable_const
    unfold rowAverage rowLinear
    fun_prop
  · apply MeasurableSet.iInter
    intro j
    apply MeasurableSet.inter <;> apply measurableSet_lt _ measurable_const <;>
      unfold rowAverage rowLinear <;> fun_prop

/-- The row source may have any dimension. Only the number of tracked input
coordinates enters the failure bound. -/
theorem freeRowEvent_compl_tail [DecidableEq I] (c:J→I→ℝ) (t:I→ℝ)
    (ht:∑i,t i^2=1) {ε:ℝ} (hε:0<ε) {M:ℕ} (hM:0<M):
    (Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
      (freeRowEvent c t ε M)ᶜ≤(64+2*(Fintype.card J:ℝ))/((M:ℝ)*ε^2):=by
  classical
  let μ:=Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)
  let A:Set (Fin M→I→ℝ):={w|ε≤|rowAverage (fun z=>(rowLinear t z)^2) w-1|}
  let B:J→Set (Fin M→I→ℝ):=fun j=>{w|ε≤|rowAverage (fun z=>(Real.tanh (rowLinear (c j) z))^2) w-
    coolingSecondMoment (∑i,(c j i)^2)|}
  let C:J→Set (Fin M→I→ℝ):=fun j=>{w|ε≤|rowAverage (fun z=>rowLinear t z*Real.tanh (rowLinear (c j) z)) w-
    (∑i,t i*c j i)*coolingDerivative (∑i,(c j i)^2)|}
  have hA:μ.real A≤64/((M:ℝ)*ε^2):=by
    have hfour:(∫z:I→ℝ,((rowLinear t z)^2)^2 ∂(Measure.pi fun _ : I=>gaussianReal 0 1))≤64:=by
      simpa only [←pow_mul] using rowLinear_fourth_integral_le t ht
    have hh:=iid_rowAverage_tail _ (rowLinear_square_memLp t) hfour hM hε
    rw [rowLinear_square_integral,ht] at hh
    exact hh
  have hB (j:J):μ.real (B j)≤1/((M:ℝ)*ε^2):=by
    have hh:=iid_rowAverage_tail _ (tanh_square_memLp (c j)) (tanh_square_secondMoment_le (c j)) hM hε
    simpa only [μ,B,rowLinear,gaussian_row_secondMoment] using hh
  have hC (j:J):μ.real (C j)≤1/((M:ℝ)*ε^2):=by
    have hh:=iid_rowAverage_tail _ (rowLinear_mul_tanh_memLp (c j) t)
      (rowLinear_mul_tanh_secondMoment_le (c j) t ht) hM hε
    simpa only [μ,C,rowLinear,gaussian_projected_tanh_zero] using hh
  have hsub:(freeRowEvent c t ε M)ᶜ⊆A∪((⋃j,B j)∪(⋃j,C j)):=by
    intro w hw
    by_contra hn
    have hna:w∉A:=fun hh=>hn (Or.inl hh)
    have hnb:∀j,w∉B j:=fun j hh=>hn (Or.inr (Or.inl (Set.mem_iUnion.mpr ⟨j,hh⟩)))
    have hnc:∀j,w∉C j:=fun j hh=>hn (Or.inr (Or.inr (Set.mem_iUnion.mpr ⟨j,hh⟩)))
    exact hw ⟨lt_of_not_ge hna,fun j=>⟨lt_of_not_ge (hnb j),lt_of_not_ge (hnc j)⟩⟩
  have hb:μ.real (⋃j,B j)≤(Fintype.card J:ℝ)/((M:ℝ)*ε^2):=by
    apply (measureReal_iUnion_fintype_le B).trans
    have hh:=Finset.sum_le_sum (fun j (_:j∈Finset.univ)=>hB j)
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one_div] using hh
  have hc:μ.real (⋃j,C j)≤(Fintype.card J:ℝ)/((M:ℝ)*ε^2):=by
    apply (measureReal_iUnion_fintype_le C).trans
    have hh:=Finset.sum_le_sum (fun j (_:j∈Finset.univ)=>hC j)
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one_div] using hh
  calc
    _≤μ.real (A∪((⋃j,B j)∪(⋃j,C j))):=measureReal_mono hsub
    _≤μ.real A+(μ.real (⋃j,B j)+μ.real (⋃j,C j)):=
      (measureReal_union_le _ _).trans (add_le_add_right (measureReal_union_le _ _) _)
    _≤(64+2*(Fintype.card J:ℝ))/((M:ℝ)*ε^2):=by
      rw [add_div,mul_div_assoc]
      linarith [hA,hb,hc]

theorem freeRowEvent_probability [DecidableEq I] (c:J→I→ℝ) (t:I→ℝ)
    (ht:∑i,t i^2=1) {ε:ℝ} (hε:0<ε) {M:ℕ} (hM:0<M)
    (hbudget:4*(64+2*(Fintype.card J:ℝ))≤(M:ℝ)*ε^2):
    (3:ℝ)/4≤(Measure.pi fun _ : Fin M=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real
      (freeRowEvent c t ε M):=by
  have ht':=freeRowEvent_compl_tail c t ht hε hM
  rw [probReal_compl_eq_one_sub (measurableSet_freeRowEvent c t ε M)] at ht'
  have hb:(64+2*(Fintype.card J:ℝ))/((M:ℝ)*ε^2)≤(1:ℝ)/4:=by
    apply (div_le_iff₀ (mul_pos (by exact_mod_cast hM) (sq_pos_of_pos hε))).mpr
    linarith
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
