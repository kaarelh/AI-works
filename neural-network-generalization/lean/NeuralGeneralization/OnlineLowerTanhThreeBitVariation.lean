import NeuralGeneralization.OnlineLowerTanhCoverageVariation
import NeuralGeneralization.OnlineLowerTanhThreeBitSharp
import NeuralGeneralization.OnlineLowerTanhSynthesis
import NeuralGeneralization.OnlineLowerCostSigns

/-! Literal finite-representation variation norm for three-bit parity. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLower OnlineLowerGeometry

/-- Sum of absolute readouts times the Euclidean norm of all affine inputs. -/
def tanhFiniteVariationCost {d q:ℕ} (a:Fin q→Fin (d+1)→ℝ) (c:Fin q→ℝ) : ℝ :=
  ∑j,|c j| * Real.sqrt (∑i,a j i^2)

lemma atomicWeightedCost_eq_tanhVariationCost {d q:ℕ}
    (a:Fin q→Fin (d+1)→ℝ) (c:Fin q→ℝ) :
    atomicWeightedCost a c=2*Real.sqrt (d:ℝ)*tanhFiniteVariationCost a c := by
  unfold atomicWeightedCost tanhFiniteVariationCost incomingAtomCost
  simp_rw [Real.sqrt_mul (Nat.cast_nonneg d)]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma threeBit_atomOutput_eq_affine {d:ℕ} (a:Fin (d+1)→ℝ) :
    atomOutput Real.tanh a=(fun x=>Real.tanh (a 0+incomingLinear (fun i=>a i.succ) x)) := by
  funext x
  unfold atomOutput incomingLinear
  rw [Fin.sum_univ_succ]
  simp only [inputVector,Fin.cases_zero,Fin.cases_succ,mul_one]

lemma threeBit_coefficient_le_finiteVariationCost {d q:ℕ}
    (S:Finset (Fin d)) (hcard:S.card=3)
    (a:Fin q→Fin (d+1)→ℝ) (c:Fin q→ℝ) :
    threeBitSharpWeight*|walshCoefficients (atomicScore Real.tanh a c) S|≤
      tanhFiniteVariationCost a c := by
  have hatom (j:Fin q) :
      threeBitSharpWeight*|walshCoefficients (atomOutput Real.tanh (a j)) S|≤
        Real.sqrt (∑i,a j i^2) := by
    rw [threeBit_atomOutput_eq_affine,Fin.sum_univ_succ]
    exact (threeBit_sharp_affine_equality S hcard (fun i=>a j i.succ) (a j 0)).1
  change threeBitSharpWeight*|walshCoefficients (fun x=>∑j,c j*atomOutput Real.tanh (a j) x) S|≤_
  rw [coefficient_finset_sum]
  simp_rw [coefficient_const_mul]
  calc
    _ ≤ threeBitSharpWeight*(∑j,|c j*walshCoefficients (atomOutput Real.tanh (a j)) S|) :=
      mul_le_mul_of_nonneg_left (Finset.abs_sum_le_sum_abs _ _) threeBitSharpWeight_pos.le
    _ = ∑j,|c j| * (threeBitSharpWeight*|walshCoefficients (atomOutput Real.tanh (a j)) S|) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      rw [abs_mul]
      ring
    _ ≤ tanhFiniteVariationCost a c := Finset.sum_le_sum (fun j _=>
      mul_le_mul_of_nonneg_left (hatom j) (abs_nonneg _))

lemma threeBit_support_coefficient {d:ℕ} (S:Finset (Fin d)) (hcard:S.card=3) :
    walshCoefficients (atomOutput Real.tanh (supportIncoming S threeBitGain)) S=
      -threeBitQ threeBitGain := by
  rw [support_tanh_walsh_eq_parity,hcard]
  have he:(fun _:Fin 3=>threeBitGain)=![threeBitGain,threeBitGain,threeBitGain]:=by
    funext i;fin_cases i <;> rfl
  rw [he,parityCorrelation_three_balanced]

lemma threeBit_support_orbit_cost {d:ℕ} (S:Finset (Fin d)) (hcard:S.card=3) :
    2*Real.sqrt (incomingAtomCost (supportIncoming S threeBitGain))/
      |walshCoefficients (atomOutput Real.tanh (supportIncoming S threeBitGain)) S|=
      2*Real.sqrt (d:ℝ)*threeBitSharpWeight := by
  rw [threeBit_support_coefficient S hcard,abs_neg,abs_of_pos (threeBitQ_pos threeBitGain_pos),
    supportIncoming_cost,hcard]
  push_cast
  rw [Real.sqrt_mul (mul_nonneg (Nat.cast_nonneg _) (by norm_num)),
    Real.sqrt_mul (Nat.cast_nonneg _),Real.sqrt_sq_eq_abs,abs_of_pos threeBitGain_pos]
  unfold threeBitSharpWeight threeBitSharpGain
  field_simp

/-- A literal finite network attains the sharp three-bit variation cost. -/
theorem threeBit_variation_attained {d:ℕ} (S:Finset (Fin d)) (hcard:S.card=3) :
    ∃(q:ℕ)(a:Fin q→Fin (d+1)→ℝ)(c:Fin q→ℝ),
      (∀x,atomicScore Real.tanh a c x=walshCharacter S x) ∧
      tanhFiniteVariationCost a c=threeBitSharpWeight := by
  have hd:0<d:=by
    have hh:=Finset.card_le_univ S
    simp only [Fintype.card_fin,hcard] at hh
    omega
  have hq:walshCoefficients (atomOutput Real.tanh (supportIncoming S threeBitGain)) S≠0:=by
    rw [threeBit_support_coefficient S hcard]
    exact neg_ne_zero.mpr (threeBitQ_pos threeBitGain_pos).ne'
  have ha:0 < incomingAtomCost (supportIncoming S threeBitGain):=by
    rw [supportIncoming_cost,hcard]
    positivity [threeBitGain_pos]
  obtain ⟨a,c,ha,hc,hscore,hcost⟩:=finite_orbit_synthesis Real.tanh
    (fun _:Fin 1=>S) (fun _=>supportIncoming S threeBitGain) (fun _=>1)
    (fun _=>hq) (fun _=>ha) (fun _=>by norm_num)
  refine ⟨_,a,c,?_,?_⟩
  · intro x
    simpa using hscore x
  · have hcost':atomicWeightedCost a c=2*Real.sqrt (d:ℝ)*threeBitSharpWeight:=by
      have hh:=hcost
      simp only [Fin.sum_univ_one,abs_one,mul_one] at hh
      exact hh.trans (threeBit_support_orbit_cost S hcard)
    rw [atomicWeightedCost_eq_tanhVariationCost] at hcost'
    exact (mul_left_cancel₀ (by positivity : 2*Real.sqrt (d:ℝ)≠0)) hcost'

/-- The unrestricted variation infimum of any three-bit parity is exactly the
reciprocal of its sharp affine tanh gain, and is attained by a finite orbit. -/
theorem threeBit_variation_eq {d:ℕ} (S:Finset (Fin d)) (hcard:S.card=3) :
    tanhVariation (walshCharacter S)=threeBitSharpWeight := by
  have hlower (B:ℝ) (hB:B∈tanhVariationCosts (walshCharacter S)) : threeBitSharpWeight≤B := by
    obtain ⟨q,a,c,hscore,rfl⟩:=hB
    have h:=threeBit_coefficient_le_finiteVariationCost S hcard a c
    have he:atomicScore Real.tanh a c=walshCharacter S:=funext hscore
    rw [he,walshCoefficients_character] at h
    simpa [tanhFiniteVariationCost, OnlineLowerRelu.finiteVariationCost] using h
  obtain ⟨q,a,c,hscore,hcost⟩:=threeBit_variation_attained S hcard
  apply IsLeast.csInf_eq
  exact ⟨⟨q,a,c,hscore,hcost.symm⟩,hlower⟩

end NeuralGeneralization.OnlineLowerTanh
