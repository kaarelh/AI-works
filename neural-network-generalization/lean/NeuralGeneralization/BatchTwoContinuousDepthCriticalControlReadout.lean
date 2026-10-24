import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlMean

/-! The critical readout can attain a controlled projected feature at width
rate proportional to the squared readout amplitude. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open GaussianTranslatePacking
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
variable {J:Type*} [Fintype J] {N:ℕ}

theorem critical_readout_control_probability (hN:0<N) (H:J→Fin N→ℝ) (T:Fin N→ℝ)
    (hH:∀j,∑i,(H j i)^2≤(N:ℝ)) (hT:∑i,(T i)^2=(N:ℝ)) (a:ℝ)
    {ε:ℝ} (hε:0<ε)
    (hbudget:2*(Fintype.card J:ℝ)*Real.exp (-(N:ℝ)*ε^2/2)≤1/4):
    (1:ℝ)/2*Real.exp (-2*(N:ℝ)*a^2-4)≤
      (Measure.pi fun _ : Fin N=>gaussianReal 0 1).real
        {z|∀j,|(∑i,z i*H j i)/(N:ℝ)-a*((∑i,T i*H j i)/(N:ℝ))|<ε}:=by
  classical
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  let B:Set (Fin N→ℝ):={z|∀j,|(∑i,z i*H j i)/(N:ℝ)|<ε}
  have hB:MeasurableSet B:=by
    simp only [B,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro j
    exact measurableSet_lt (by fun_prop) measurable_const
  have ht (j:J):(Measure.pi fun _ : Fin N=>gaussianReal 0 1).real
      {z|ε≤|(∑i,z i*H j i)/(N:ℝ)|}≤2*Real.exp (-(N:ℝ)*ε^2/2):=by
    have hh:=GaussianTail.gaussian_linear_form_abs_tail (fun _ : Fin N=>(1:ℝ≥0))
      (fun i=>H j i/(N:ℝ)) (1/(N:ℝ)) ε (by positivity) hε.le (by
        simp only [NNReal.coe_one,mul_one,div_pow,←Finset.sum_div]
        apply (div_le_iff₀ (sq_pos_of_pos hn)).mpr
        have he:1/(N:ℝ)*(N:ℝ)^2=(N:ℝ):=by field_simp
        rw [he]
        exact hH j)
    have hp (z:Fin N→ℝ):(∑i,H j i/(N:ℝ)*z i)=(∑i,z i*H j i)/(N:ℝ):=by
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro i _
      ring
    have he:-ε^2/(2*(1/(N:ℝ)))=-(N:ℝ)*ε^2/2:=by field_simp
    simpa only [hp,he] using hh
  have hprob:(3:ℝ)/4≤(standardGaussian (I:=Fin N)).real B:=by
    have he:Bᶜ=⋃j,{z:Fin N→ℝ|ε≤|(∑i,z i*H j i)/(N:ℝ)|}:=by
      ext z
      simp [B]
    have hh:(standardGaussian (I:=Fin N)).real Bᶜ≤1/4:=by
      rw [he]
      apply (measureReal_iUnion_fintype_le _).trans
      have hh:=Finset.sum_le_sum (fun j (_:j∈Finset.univ)=>ht j)
      have hh':(∑j,(standardGaussian (I:=Fin N)).real
          {z|ε≤|(∑i,z i*H j i)/(N:ℝ)|})≤
          2*(Fintype.card J:ℝ)*Real.exp (-(N:ℝ)*ε^2/2):=by
        simpa only [standardGaussian,Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_left_comm,mul_assoc] using hh
      exact hh'.trans hbudget
    rw [probReal_compl_eq_one_sub hB] at hh
    linarith
  have hcost:(∑i,(a*T i)^2)≤(N:ℝ)*a^2:=by
    simp only [mul_pow,←Finset.mul_sum,hT]
    exact le_of_eq (mul_comm _ _)
  have hh:=gaussian_control_translate_lower (fun i=>a*T i) B hB
    (E:=(N:ℝ)*a^2) (by positivity) hcost hprob
  have he:translateSet (fun i=>a*T i) B=
      {z:Fin N→ℝ|∀j,|(∑i,z i*H j i)/(N:ℝ)-a*((∑i,T i*H j i)/(N:ℝ))|<ε}:=by
    ext z
    have hp (j:J):(∑i,(z i-a*T i)*H j i)/(N:ℝ)=
        (∑i,z i*H j i)/(N:ℝ)-a*((∑i,T i*H j i)/(N:ℝ)):=by
      simp only [sub_mul,Finset.sum_sub_distrib,mul_assoc,←Finset.mul_sum]
      ring
    simp only [translateSet,B,Set.mem_setOf_eq,Pi.sub_apply,hp]
  rw [he] at hh
  convert hh using 1 <;> congr 2 <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthCritical
