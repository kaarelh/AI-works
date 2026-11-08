import NeuralGeneralization.OnlineLowerTanhPeriodicPhase
import NeuralGeneralization.OnlineLowerTanhPhase
import NeuralGeneralization.OnlineLowerTanhPeakLocalization

/-! Exact absorption of odd lattice phases and quantitative residual stability. -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

lemma odd_spin_shift (T:ℝ→ℝ) (a:ℝ) (hT:Function.Antiperiodic T (2*a))
    {r:ℤ} (hr:Odd r) {e:ℝ} (he:e=1 ∨ e= -1) (B:ℝ) :
    e*T (B+a*(r:ℝ)*e)=T (B+a*(r:ℝ)) := by
  rcases he with rfl|rfl
  · simp
  · obtain ⟨z,hz⟩:=hr
    have hh:=hT.int_odd_mul_antiperiodic z (B-a*(r:ℝ))
    have hrR:(r:ℝ)=2*(z:ℝ)+1:=by exact_mod_cast hz
    have heq:(B-a*(r:ℝ))+(z:ℝ)*(2*(2*a))+2*a=B+a*(r:ℝ):=by rw [hrR];ring
    rw [←add_assoc,heq] at hh
    simpa only [mul_neg_one,neg_one_mul,←sub_eq_add_neg] using hh.symm

lemma odd_spin_sum {ι:Type*} [DecidableEq ι] (T:ℝ→ℝ) (a:ℝ)
    (hT:Function.Antiperiodic T (2*a)) (s:Finset ι) (r:ι→ℤ) (e:ι→ℝ)
    (hr:∀i∈s,Odd (r i)) (he:∀i∈s,e i=1 ∨ e i= -1) (B:ℝ) :
    (∏i∈s,e i)*T (B+a*∑i∈s,(r i:ℝ)*e i)=T (B+a*∑i∈s,(r i:ℝ)) := by
  induction s using Finset.induction_on generalizing B with
  | empty => simp
  | @insert i s hi ih =>
    simp only [Finset.prod_insert hi,Finset.sum_insert hi]
    have hri:=hr i (Finset.mem_insert_self _ _)
    have hei:=he i (Finset.mem_insert_self _ _)
    have hrs:∀j∈s,Odd (r j):=fun j hj=>hr j (Finset.mem_insert_of_mem hj)
    have hes:∀j∈s,e j=1 ∨ e j= -1:=fun j hj=>he j (Finset.mem_insert_of_mem hj)
    calc
      _ = e i*((∏j∈s,e j)*T ((B+a*(r i:ℝ)*e i)+a*∑j∈s,(r j:ℝ)*e j)) := by
        rw [show B+a*((r i:ℝ)*e i+∑j∈s,(r j:ℝ)*e j) =
          (B+a*(r i:ℝ)*e i)+a*∑j∈s,(r j:ℝ)*e j by ring]
        ring
      _ = e i*T ((B+a*(r i:ℝ)*e i)+a*∑j∈s,(r j:ℝ)) := by rw [ih hrs hes]
      _ = e i*T ((B+a*∑j∈s,(r j:ℝ))+a*(r i:ℝ)*e i) := by congr 2;ring
      _ = T ((B+a*∑j∈s,(r j:ℝ))+a*(r i:ℝ)) := odd_spin_shift T a hT hri hei _
      _ = _ := by congr 1;ring

lemma odd_sum_with_offset {d η:ℕ} (hη:Odd (η+d)) (r:Fin d→ℤ) (hr:∀i,Odd (r i)) :
    Odd ((η:ℤ)+∑i,r i) := by
  choose z hz using hr
  obtain ⟨q,hq⟩:=hη
  refine ⟨(q:ℤ)+∑i,z i,?_⟩
  have he:∑i,r i=2*∑i,z i+(d:ℤ):=by
    simp_rw [hz]
    simp [Finset.sum_add_distrib,Finset.mul_sum]
  have hqZ:(η:ℤ)+(d:ℤ)=2*(q:ℤ)+1:=by exact_mod_cast hq
  rw [he]
  omega

lemma odd_base_phase (T:ℝ→ℝ) (a:ℝ) (hT:Function.Antiperiodic T (2*a))
    {r:ℤ} (hr:Odd r) : ∃s:ℝ,|s|=1 ∧ ∀B:ℝ,T ((r:ℝ)*a+B)=s*T (a+B) := by
  obtain ⟨q,hq⟩:=hr
  let s:ℝ:=((q.negOnePow:ℤ):ℝ)
  have hs:|s|=1:=by
    rcases Int.even_or_odd' q with ⟨j,rfl|rfl⟩ <;>
      simp [s,Int.negOnePow_two_mul,Int.negOnePow_two_mul_add_one]
  refine ⟨s,hs,?_⟩
  intro B
  have hh:=hT.add_int_mul_eq (x:=a+B) q
  have hrR:(r:ℝ)=2*(q:ℝ)+1:=by exact_mod_cast hq
  convert hh using 1
  rw [hrR]
  ring

/-- The parity character is absorbed exactly by the odd integer parts.
Only a single constant sign remains, independent of the external cube point. -/
theorem periodic_odd_phase_absorption {d η:ℕ} {a:ℝ} (ha:0<a)
    (hη:Odd (η+d)) (r:Fin d→ℤ) (hr:∀i,Odd (r i)) (u:Fin d→ℝ) :
    ∃s:ℝ,|s|=1 ∧ ∀x:Cube d,
      paritySign x*periodicFourierResponse a ((η:ℝ)*a+
        incomingLinear (fun i=>a*(r i:ℝ)+u i) x)=
      s*periodicFourierResponse a (a+incomingLinear u x) := by
  have hT:Function.Antiperiodic (periodicFourierResponse a) (2*a):=
    periodicFourierResponse_antiperiod ha
  obtain ⟨s,hs,hbase⟩:=odd_base_phase _ a hT (odd_sum_with_offset hη r hr)
  refine ⟨s,hs,?_⟩
  intro x
  have he:∀i∈(Finset.univ:Finset (Fin d)),labelReal (x i)=1 ∨ labelReal (x i)= -1:=by
    intro i _
    cases x i <;> simp [labelReal]
  have hh:=odd_spin_sum _ a hT Finset.univ r (fun i=>labelReal (x i))
    (fun i _=>hr i) he ((η:ℝ)*a+incomingLinear u x)
  have hin:incomingLinear (fun i=>a*(r i:ℝ)+u i) x=
      a*(∑i,(r i:ℝ)*labelReal (x i))+incomingLinear u x:=by
    simp only [incomingLinear,add_mul,Finset.sum_add_distrib,Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [hin]
  have hsum:(((η:ℤ)+∑i,r i:ℤ):ℝ)*a+incomingLinear u x=
      ((η:ℝ)*a+incomingLinear u x)+a*∑i,(r i:ℝ):=by push_cast;ring
  rw [←hbase,hsum]
  convert hh using 1
  unfold paritySign
  congr 2
  ring

def oddPhaseResidual {d:ℕ} (a:ℝ) (u:Fin d→ℝ) (i:Fin d) : ℝ :=
  a*phaseError true (u i/a)

lemma oddPhaseResidual_abs {d:ℕ} {a:ℝ} (ha:0<a) (u:Fin d→ℝ) (i:Fin d) :
    |oddPhaseResidual a u i|≤a := by
  unfold oddPhaseResidual
  rw [abs_mul,abs_of_pos ha]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left (phaseError_abs_le_one true (u i/a)) ha.le

lemma oddPhaseResidual_decompose {d:ℕ} {a:ℝ} (ha:0<a) (u:Fin d→ℝ) (i:Fin d) :
    u i=a*(phaseInteger true (u i/a):ℝ)+oddPhaseResidual a u i := by
  unfold oddPhaseResidual phaseError
  field_simp
  ring

/-- Quantitative phase stability for the literal external parity average,
with residuals defined by nearest odd lattice rounding. -/
theorem periodic_external_phase_stability {d η:ℕ} {a:ℝ} (ha:1≤a) (ha2:a≤2)
    (hη:Odd (η+d)) (u:Fin d→ℝ) :
    periodicPeakFloor/1600*min (incomingEnergy (oddPhaseResidual a u)) 1 ≤
      periodicFourierMaximum a-|uniformCubeMean (fun x=>paritySign x*
        periodicFourierResponse a ((η:ℝ)*a+incomingLinear u x))| := by
  have ha0:0<a:=by linarith
  obtain ⟨s,hs,hpoint⟩:=periodic_odd_phase_absorption ha0 hη
    (fun i=>phaseInteger true (u i/a)) (fun i=>phaseInteger_odd _) (oddPhaseResidual a u)
  have hid:(fun i=>a*(phaseInteger true (u i/a):ℝ)+oddPhaseResidual a u i)=u:=by
    funext i
    exact (oddPhaseResidual_decompose ha0 u i).symm
  rw [hid] at hpoint
  have hmean:uniformCubeMean (fun x=>paritySign x*
      periodicFourierResponse a ((η:ℝ)*a+incomingLinear u x))=
      s*uniformCubeMean (fun x=>periodicFourierResponse a (a+incomingLinear (oddPhaseResidual a u) x)):=by
    simp only [uniformCubeMean,hpoint,←Finset.mul_sum]
    ring
  rw [hmean,abs_mul,hs,one_mul]
  have hh:=periodic_cube_phase_stability ha0 ha2 (oddPhaseResidual a u) (oddPhaseResidual_abs ha0 u)
  have hf:=periodicCoefficient_zero_floor ha ha2
  have hmin:0≤min (incomingEnergy (oddPhaseResidual a u)) 1:=by
    apply le_min
    · exact Finset.sum_nonneg (fun i _=>sq_nonneg _)
    · norm_num
  apply le_trans _ hh
  exact mul_le_mul_of_nonneg_right (div_le_div_of_nonneg_right hf (by norm_num)) hmin

lemma tendsto_zero_of_truncated_bound {E D:ℕ→ℝ} {c:ℝ}
    (hc:0<c) (hE:∀k,0≤E k) (hbound:∀k,c*min (E k) 1≤D k)
    (hD:Tendsto D atTop (𝓝 0)) : Tendsto E atTop (𝓝 0) := by
  have hsmall:∀ᶠ k in atTop,D k<c:=hD.eventually (eventually_lt_nhds hc)
  have hu:∀ᶠ k in atTop,E k≤D k/c:=by
    filter_upwards [hsmall] with k hk
    have hm:min (E k) 1<1:=by nlinarith [hbound k]
    have hEk:E k<1:=(min_lt_iff.mp hm).resolve_right (lt_irrefl _)
    have hb:=hbound k
    rw [min_eq_left hEk.le] at hb
    exact (le_div_iff₀ hc).mpr (by nlinarith [hb])
  have hdiv:=hD.div_const c
  simp only [zero_div] at hdiv
  exact squeeze_zero' (Eventually.of_forall hE) hu hdiv

/-- The full squared distance to the nearest odd lattice tends to zero,
even when the number of external coordinates grows without a bound. -/
theorem periodic_external_residual_tendsto (d η:ℕ→ℕ) (a:ℕ→ℝ)
    (u:(k:ℕ)→Fin (d k)→ℝ) (ha:∀k,1≤a k) (ha2:∀k,a k≤2)
    (hη:∀k,Odd (η k+d k))
    (hdeficit:Tendsto (fun k=>periodicFourierMaximum (a k)-
      |uniformCubeMean (fun x=>paritySign x*periodicFourierResponse (a k)
        ((η k:ℝ)*a k+incomingLinear (u k) x))|) atTop (𝓝 0)) :
    Tendsto (fun k=>incomingEnergy (oddPhaseResidual (a k) (u k))) atTop (𝓝 0) := by
  exact tendsto_zero_of_truncated_bound (by positivity [periodicPeakFloor_pos])
    (fun k=>Finset.sum_nonneg (fun i _=>sq_nonneg _))
    (fun k=>periodic_external_phase_stability (ha k) (ha2 k) (hη k) (u k)) hdeficit

lemma oddPhaseResidual_sq_le_energy {d:ℕ} (a:ℝ) (u:Fin d→ℝ) (i:Fin d) :
    (oddPhaseResidual a u i)^2 ≤ incomingEnergy (oddPhaseResidual a u) :=
  Finset.single_le_sum (fun j _=>sq_nonneg _) (Finset.mem_univ i)

lemma residual_energy_tendsto_uniform (d:ℕ→ℕ) (a:ℕ→ℝ) (u:(k:ℕ)→Fin (d k)→ℝ)
    (h:Tendsto (fun k=>incomingEnergy (oddPhaseResidual (a k) (u k))) atTop (𝓝 0)) :
    ∀ε>0,∀ᶠ k in atTop,∀i,|oddPhaseResidual (a k) (u k) i|<ε := by
  intro ε hε
  have hh:=h.eventually (eventually_lt_nhds (sq_pos_of_pos hε))
  filter_upwards [hh] with k hk i
  have hs:=oddPhaseResidual_sq_le_energy (a k) (u k) i
  have habs:=sq_abs (oddPhaseResidual (a k) (u k) i)
  nlinarith [abs_nonneg (oddPhaseResidual (a k) (u k) i)]

lemma oddPhaseResidual_outlier_lower {d:ℕ} {a ε:ℝ} (ha:1≤a) (hε:0<ε) (hε1:ε≤1)
    (u:Fin d→ℝ) (i:Fin d) (hu:0≤u i) (hfar:ε≤|u i-a|)
    (hsmall:|oddPhaseResidual a u i|<ε) : 3*a-ε<u i := by
  have ha0:0<a:=by linarith
  let r:=phaseInteger true (u i/a)
  have hr:Odd r:=phaseInteger_odd _
  have hdec:=oddPhaseResidual_decompose ha0 u i
  change u i=a*(r:ℝ)+oddPhaseResidual a u i at hdec
  have hs:=abs_lt.mp hsmall
  have hrpos:1≤r:=by
    by_contra hn
    have hrneg:r≤ -1:=by obtain ⟨z,hz⟩:=hr;omega
    have hrR:(r:ℝ)≤ -1:=by exact_mod_cast hrneg
    have hm:=mul_le_mul_of_nonneg_left hrR ha0.le
    nlinarith
  have hrne:r≠1:=by
    intro he
    rw [he,Int.cast_one,mul_one] at hdec
    have he':u i-a=oddPhaseResidual a u i:=by linarith
    rw [he'] at hfar
    linarith
  have hr3:3≤r:=by obtain ⟨z,hz⟩:=hr;omega
  have hrR:(3:ℝ)≤r:=by exact_mod_cast hr3
  have hm:=mul_le_mul_of_nonneg_left hrR ha0.le
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
