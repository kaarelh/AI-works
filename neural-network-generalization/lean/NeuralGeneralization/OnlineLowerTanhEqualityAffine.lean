import NeuralGeneralization.OnlineLowerTanhEqualityIntrinsic
import NeuralGeneralization.OnlineLowerTanhSharpSupport

/-! # The full eventual affine single-parity theorem, including equality -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh

lemma subsetWeights_zero_of_outside_zero {d:ℕ} (A:Finset (Fin d)) (u:Fin d→ℝ)
    (hout:∀i,i∉A → u i=0) : subsetWeights Aᶜ u=0 := by
  funext j
  exact hout _ (Finset.mem_compl.mp (Aᶜ.equivFin.symm j).property)

lemma tanh_walshCoefficient_eq_selected_of_outside_zero {d:ℕ}
    (A:Finset (Fin d)) (u:Fin d→ℝ) (hout:∀i,i∉A → u i=0) :
    walshCoefficients (fun x=>Real.tanh (incomingLinear u x)) A=
      parityCorrelation (subsetWeights A u) 0 := by
  have hh:=tanh_walshCoefficient_eq_conditioned A u 0
  rw [subsetWeights_zero_of_outside_zero A u hout] at hh
  simpa [conditionedParityCorrelation,incomingLinear,cubeMean_const] using hh

lemma incomingEnergy_eq_selected_of_outside_zero {d:ℕ}
    (A:Finset (Fin d)) (u:Fin d→ℝ) (hout:∀i,i∉A → u i=0) :
    incomingEnergy u=incomingEnergy (subsetWeights A u) := by
  have hh:=incomingEnergy_partition A u
  rw [subsetWeights_zero_of_outside_zero A u hout] at hh
  simpa [incomingEnergy] using hh.symm

/-- Every sufficiently large selected odd parity has the exact sharp affine
bound. At a nonzero equality the bias and outside coordinates vanish and all
selected magnitudes equal the unique actual balanced optimizing gain. -/
theorem exists_sharp_affine_equality_threshold :
    ∃n₀:ℕ,∀d:ℕ,∀A:Finset (Fin d),n₀≤A.card → Odd A.card →
      ∀u:Fin d→ℝ,∀b:ℝ,
      let w:=balancedCost (A.card/2)
      let r:=Real.sqrt (b^2+incomingEnergy u)
      let q:=w*|walshCoefficients (fun x=>Real.tanh (b+incomingLinear u x)) A|
      q≤r ∧ (0<r → q=r → b=0 ∧ (∀i,i∉A → u i=0) ∧
        ∀i∈A,|u i|=balancedGain (A.card/2)) := by
  obtain ⟨N₁,hsharp⟩:=exists_sharp_affine_support_threshold
  obtain ⟨N₂,hclass⟩:=exists_intrinsic_gain_equality_threshold
  refine ⟨max N₁ N₂,?_⟩
  intro d A hN hodd u b
  have hbound:=hsharp d A ((le_max_left _ _).trans hN) hodd u b
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
  have hgain:intrinsicGain (subsetWeights A u)=1/balancedCost (A.card/2):=by
    unfold intrinsicGain
    apply (div_eq_div_iff hr.ne' (balancedCost_pos _).ne').mpr
    simpa only [one_mul,mul_comm] using heq
  have hvalues:=((hclass A.card ((le_max_right _ _).trans hN) hodd (subsetWeights A u)).2).mp hgain
  intro i hi
  have hh:=hvalues (A.equivFin ⟨i,hi⟩)
  simpa only [subsetWeights,Equiv.symm_apply_apply] using hh

end NeuralGeneralization.OnlineLowerTanh
