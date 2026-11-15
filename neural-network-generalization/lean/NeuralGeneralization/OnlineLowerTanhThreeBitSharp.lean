import NeuralGeneralization.OnlineLowerTanhThreeBitStationary
import NeuralGeneralization.OnlineLowerTanhEqualityAffine

/-! The exact unrestricted three-bit tanh gain, including every equality case. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators Topology Classical
open Set
namespace NeuralGeneralization.OnlineLowerTanh

noncomputable def threeBitGain : ℝ := exists_threeBit_balanced_maximizer.choose
lemma threeBitGain_pos : 0<threeBitGain := exists_threeBit_balanced_maximizer.choose_spec.1
lemma threeBitGain_maximal : IsIntrinsicMaximizer (fun _:Fin 3=>threeBitGain) :=
  exists_threeBit_balanced_maximizer.choose_spec.2

def threeBitSharpGain : ℝ := threeBitQ threeBitGain/(Real.sqrt 3*threeBitGain)
def threeBitSharpWeight : ℝ := 1/threeBitSharpGain

lemma intrinsicGain_three_constant (a:ℝ) (ha:0<a) :
    intrinsicGain (fun _:Fin 3=>a)=threeBitQ a/(Real.sqrt 3*a) := by
  have he:(fun _:Fin 3=>a)=![a,a,a]:=by funext i;fin_cases i <;> rfl
  rw [he,intrinsicGain,parityCorrelation_three_balanced,abs_neg,
    abs_of_pos (threeBitQ_pos ha),incomingEnergy_three,
    show a^2+a^2+a^2=3*a^2 by ring,
    Real.sqrt_mul (by norm_num : (0:ℝ)≤3),Real.sqrt_sq_eq_abs,abs_of_pos ha]

lemma threeBitSharpGain_pos : 0<threeBitSharpGain := by
  unfold threeBitSharpGain
  exact div_pos (threeBitQ_pos threeBitGain_pos) (by positivity [threeBitGain_pos])
lemma threeBitSharpWeight_pos : 0<threeBitSharpWeight := by
  exact one_div_pos.mpr threeBitSharpGain_pos

lemma threeBitGain_unique_of_global (a:ℝ) (ha:0<a)
    (hm:IsIntrinsicMaximizer (fun _:Fin 3=>a)) : a=threeBitGain :=
  threeBitStationary_positive_root_unique ha threeBitGain_pos
    (threeBit_balanced_global_stationary a ha hm)
    (threeBit_balanced_global_stationary threeBitGain threeBitGain_pos threeBitGain_maximal)

/-- The paper's scalar function has exactly one positive global maximizing gain. -/
theorem threeBitGain_unique_scalar_max :
    0<threeBitGain ∧ ∀a:ℝ,0<a →
      threeBitQ a/a≤threeBitQ threeBitGain/threeBitGain ∧
      (threeBitQ a/a=threeBitQ threeBitGain/threeBitGain ↔ a=threeBitGain) := by
  refine ⟨threeBitGain_pos,?_⟩
  intro a ha
  have hbound:∀b:ℝ,0<b → threeBitQ b/b≤threeBitQ threeBitGain/threeBitGain:=by
    intro b hb
    have hm:=threeBitGain_maximal (fun _:Fin 3=>b)
    rw [intrinsicGain_three_constant b hb,intrinsicGain_three_constant threeBitGain threeBitGain_pos] at hm
    have h3:0<Real.sqrt 3:=by positivity
    have hh:=(div_le_div_iff₀ (mul_pos h3 hb) (mul_pos h3 threeBitGain_pos)).mp hm
    apply (div_le_div_iff₀ hb threeBitGain_pos).mpr
    apply (mul_le_mul_iff_right₀ h3).mp
    nlinarith only [hh]
  refine ⟨hbound a ha,?_⟩
  constructor
  · intro he
    have hm:IsIntrinsicMaximizer (fun _:Fin 3=>a):=by
      intro u
      have hu:=threeBitGain_maximal u
      have hg:intrinsicGain (fun _:Fin 3=>a)=intrinsicGain (fun _:Fin 3=>threeBitGain):=by
        rw [intrinsicGain_three_constant a ha,intrinsicGain_three_constant threeBitGain threeBitGain_pos]
        have he':=(div_eq_div_iff ha.ne' threeBitGain_pos.ne').mp he
        apply (div_eq_div_iff (by positivity [ha]) (by positivity [threeBitGain_pos])).mpr
        calc
          _ = Real.sqrt 3*(threeBitQ a*threeBitGain) := by ring
          _ = Real.sqrt 3*(threeBitQ threeBitGain*a) := by rw [he']
          _ = _ := by ring
      rwa [hg]
    exact threeBitGain_unique_of_global a ha hm
  · rintro rfl;rfl

/-- Exact intrinsic gain and all equality cases, at degree three without a
large-degree assumption. -/
theorem threeBit_intrinsic_gain_bound_and_equality (u:Fin 3→ℝ) :
    intrinsicGain u≤threeBitSharpGain ∧
      (intrinsicGain u=threeBitSharpGain ↔ ∀i,|u i|=threeBitGain) := by
  have hg:intrinsicGain (fun _:Fin 3=>threeBitGain)=threeBitSharpGain:=
    intrinsicGain_three_constant threeBitGain threeBitGain_pos
  have hbound:∀v:Fin 3→ℝ,intrinsicGain v≤threeBitSharpGain:=by
    intro v;rw [←hg];exact threeBitGain_maximal v
  refine ⟨hbound u,?_⟩
  constructor
  · intro he
    have hm:IsIntrinsicMaximizer u:=fun v=>by rw [he];exact hbound v
    obtain ⟨a,ha,heq⟩:=threeBit_maximizer_balanced u hm
    have hfun:(fun i=>|u i|)=(fun _:Fin 3=>a):=funext heq
    have hma:=IsIntrinsicMaximizer_abs_weights u hm
    rw [hfun] at hma
    rw [←threeBitGain_unique_of_global a ha hma]
    exact heq
  · intro he
    have hfun:(fun i=>|u i|)=(fun _:Fin 3=>threeBitGain):=funext he
    rw [←intrinsicGain_abs_weights u,hfun,hg]

lemma threeBit_intrinsicParityBound : IntrinsicParityBound 3 threeBitSharpWeight := by
  intro u
  by_cases hz:u=0
  · subst u;simp [parityCorrelation,incomingLinear,incomingEnergy]
  have hs:0<Real.sqrt (incomingEnergy u):=Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hz)
  have hb:=(div_le_iff₀ hs).mp (threeBit_intrinsic_gain_bound_and_equality u).1
  unfold threeBitSharpWeight
  rw [one_div_mul_eq_div]
  apply (div_le_iff₀ threeBitSharpGain_pos).mpr
  nlinarith only [hb]

/-- The sharp inequality for any affine tanh neuron and any three selected
Boolean coordinates. Nonzero equality forces zero bias, no irrelevant weights,
and the unique balanced magnitude on the selected coordinates. -/
theorem threeBit_sharp_affine_equality {d:ℕ} (A:Finset (Fin d)) (hcard:A.card=3)
    (u:Fin d→ℝ) (b:ℝ) :
    let r:=Real.sqrt (b^2+incomingEnergy u)
    let q:=threeBitSharpWeight*|walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) A|
    q≤r ∧ (0<r → q=r → b=0 ∧ (∀i,i∉A → u i=0) ∧
      ∀i∈A,|u i|=threeBitGain) := by
  have hodd:Odd A.card:=by rw [hcard];decide
  have hsharp:IntrinsicParityBound A.card threeBitSharpWeight:=by
    rw [hcard];exact threeBit_intrinsicParityBound
  have hbound:=intrinsicParityBound_physical_support A hodd threeBitSharpWeight
    threeBitSharpWeight_pos.le hsharp u b
  dsimp only at hbound ⊢
  refine ⟨hbound.1,?_⟩
  intro hr heq
  have hzero:b^2+(∑i∈Aᶜ,(u i)^2)=0:=by
    rw [heq,sub_self,mul_zero] at hbound
    have hs:0≤∑i∈Aᶜ,(u i)^2:=Finset.sum_nonneg (fun i _=>sq_nonneg _)
    nlinarith [hbound.2,sq_nonneg b]
  have hb:b=0:=by
    have hs:0≤∑i∈Aᶜ,(u i)^2:=Finset.sum_nonneg (fun i _=>sq_nonneg _)
    nlinarith [sq_nonneg b]
  have hout:∀i,i∉A → u i=0:=by
    intro i hi
    have hh:(u i)^2≤∑j∈Aᶜ,(u j)^2:=
      Finset.single_le_sum (fun j _=>sq_nonneg _) (Finset.mem_compl.mpr hi)
    nlinarith [sq_nonneg (u i),sq_nonneg b]
  refine ⟨hb,hout,?_⟩
  have hE:=incomingEnergy_eq_selected_of_outside_zero A u hout
  have hcoeff:=tanh_walshCoefficient_eq_selected_of_outside_zero A u hout
  simp only [hb,zero_pow (by norm_num : (2:ℕ)≠0),zero_add,hE,hcoeff] at hr heq
  have hgain:intrinsicGain (subsetWeights A u)=threeBitSharpGain:=by
    unfold intrinsicGain
    apply (div_eq_iff hr.ne').mpr
    unfold threeBitSharpWeight at heq
    rw [one_div_mul_eq_div] at heq
    have hh:=(div_eq_iff threeBitSharpGain_pos.ne').mp heq
    nlinarith only [hh]
  have hvalues:∀j:Fin A.card,|subsetWeights A u j|=threeBitGain:=by
    have hall:∀n:ℕ,n=3 → ∀v:Fin n→ℝ,intrinsicGain v=threeBitSharpGain →
        ∀j,|v j|=threeBitGain:=by
      intro n hn;subst n;intro v hv;exact (threeBit_intrinsic_gain_bound_and_equality v).2.mp hv
    exact hall A.card hcard (subsetWeights A u) hgain
  intro i hi
  have hh:=hvalues (A.equivFin ⟨i,hi⟩)
  simpa only [subsetWeights,Equiv.symm_apply_apply] using hh


/-- The complete affine equality equivalence, at every nonzero incoming norm. -/
theorem threeBit_sharp_affine_iff {d:ℕ} (A:Finset (Fin d)) (hcard:A.card=3)
    (u:Fin d→ℝ) (b:ℝ) (hr:0<Real.sqrt (b^2+incomingEnergy u)) :
    threeBitSharpWeight*|walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) A|=
      Real.sqrt (b^2+incomingEnergy u) ↔
      b=0 ∧ (∀i,i∉A → u i=0) ∧ ∀i∈A,|u i|=threeBitGain := by
  constructor
  · exact (threeBit_sharp_affine_equality A hcard u b).2 hr
  · rintro ⟨rfl,hout,hvalues⟩
    have hE:=incomingEnergy_eq_selected_of_outside_zero A u hout
    have hc:=tanh_walshCoefficient_eq_selected_of_outside_zero A u hout
    simp only [zero_pow (by norm_num : (2:ℕ)≠0),zero_add,hE,hc] at hr ⊢
    have hs:∀j:Fin A.card,|subsetWeights A u j|=threeBitGain:=by
      intro j
      exact hvalues (A.equivFin.symm j).val (A.equivFin.symm j).property
    have hall:∀n:ℕ,n=3 → ∀v:Fin n→ℝ,(∀j,|v j|=threeBitGain) →
        intrinsicGain v=threeBitSharpGain:=by
      intro n hn;subst n;intro v hv
      exact (threeBit_intrinsic_gain_bound_and_equality v).2.mpr hv
    have hg:=hall A.card hcard (subsetWeights A u) hs
    have he:|parityCorrelation (subsetWeights A u) 0|=
        threeBitSharpGain*Real.sqrt (incomingEnergy (subsetWeights A u)):=
      (div_eq_iff hr.ne').mp hg
    rw [he]
    unfold threeBitSharpWeight
    field_simp [threeBitSharpGain_pos.ne']

/-- The unweighted version of the paper's sharp affine inequality. -/
theorem threeBit_global_affine_bound {d:ℕ} (A:Finset (Fin d)) (hcard:A.card=3)
    (u:Fin d→ℝ) (b:ℝ) :
    |walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) A|≤
      threeBitSharpGain*Real.sqrt (b^2+incomingEnergy u) := by
  have hh:=(threeBit_sharp_affine_equality A hcard u b).1
  unfold threeBitSharpWeight at hh
  rw [one_div_mul_eq_div] at hh
  have h:=(div_le_iff₀ threeBitSharpGain_pos).mp hh
  simpa only [mul_comm] using h

end NeuralGeneralization.OnlineLowerTanh
