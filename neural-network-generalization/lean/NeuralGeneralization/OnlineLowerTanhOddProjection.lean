import NeuralGeneralization.OnlineLowerRetainedNeuron
import NeuralGeneralization.OnlineLowerTanhGeometryCarrierDefect
import NeuralGeneralization.Activation

/-! The support-only parameter estimate gives the actual odd-downward
Fourier projection estimate. No balance or fixed activation gain is needed. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

lemma tanh_neuron_l2_difference_le {d:ℕ} (b c:ℝ) (u v:Fin d→ℝ) :
    uniformCubeMean (fun x=>(Real.tanh (cubeAffine b u x)-Real.tanh (cubeAffine c v x))^2)≤
      (b-c)^2+∑i,(u i-v i)^2 := by
  calc
    _ ≤ uniformCubeMean (fun x=>(cubeAffine b u x-cubeAffine c v x)^2) := by
      apply uniformCubeMean_mono
      intro x
      have hh:=tanh_admissible.2 (cubeAffine b u x) (cubeAffine c v x)
      have hs:=mul_self_le_mul_self (abs_nonneg _) hh
      simpa only [←pow_two,sq_abs] using hs
    _ = _ := by simp_rw [cubeAffine_sub]; exact cubeAffine_secondMoment _ _

lemma tanh_walsh_zero_even {d:ℕ} (u:Fin d→ℝ) (S:Finset (Fin d))
    (he:Even S.card) : walshCoefficients (fun x=>Real.tanh (cubeAffine 0 u x)) S=0 := by
  let F:=fun x=>Real.tanh (cubeAffine 0 u x)
  have hn (x:ClippingCube d):F (negateInputs d x)= -F x := by
    dsimp [F,cubeAffine]
    simp only [zero_add,negateInputs,Equiv.coe_fn_mk,cubeCoordinateSign_not,
      mul_neg,Finset.sum_neg_distrib,Real.tanh_neg]
  have hw (x:ClippingCube d):walshCharacter S (negateInputs d x)=
      (-1:ℝ)^S.card*walshCharacter S x := by
    simp [walshCharacter,negateInputs,cubeCoordinateSign_not,Finset.prod_neg]
  have hh:=(negateInputs d).sum_comp (fun x=>F x*walshCharacter S x)
  simp_rw [hn,hw,he.neg_one_pow,one_mul,neg_mul,Finset.sum_neg_distrib] at hh
  have hs:(∑x,F x*walshCharacter S x)=0:=by linarith
  change walshCoefficients F S=0
  unfold walshCoefficients uniformCubeMean
  rw [hs,zero_div]

lemma tanh_walsh_zero_outside {d:ℕ} (u:Fin d→ℝ) (A S:Finset (Fin d))
    (hu:∀i,i∉A→u i=0) (hS:¬S⊆A) :
    walshCoefficients (fun x=>Real.tanh (cubeAffine 0 u x)) S=0 := by
  obtain ⟨i,hiS,hiA⟩:=Finset.not_subset.mp hS
  apply walsh_eq_zero_of_flip_invariant _ S i hiS
  intro x
  rw [cubeAffine_flip_of_zero 0 u i (hu i hiA)]

/-- Any odd activation depending only on one retained support is an allowed
comparison function for the actual orthogonal Fourier projection. -/
lemma tanh_carrier_projection_le_support_energy {p m:ℕ}
    (size:Fin p→Bool→ℕ) (column:Fin p→Finset (Fin m))
    (s:Finset (Fin m)) (bias:ℝ) (u:Fin (carrierDimension size)→ℝ) :
    uniformCubeMean (fun x=>(Real.tanh (cubeAffine bias u x)-
      fourierProject (carrierOddDownwardSupports size column)
        (fun x=>Real.tanh (cubeAffine bias u x)) x)^2)≤
      bias^2+∑i∈(carrierSupport size column s)ᶜ,u i^2 := by
  let A:=carrierSupport size column s
  let v:Fin (carrierDimension size)→ℝ:=fun i=>if i∈A then u i else 0
  have hv:∀i,i∉A→v i=0:=by intro i hi;simp [v,hi]
  have hface:∀S,S∉carrierOddDownwardSupports size column→
      walshCoefficients (fun x=>Real.tanh (cubeAffine 0 v x)) S=0 := by
    intro S hS
    by_cases ho:Odd S.card
    · apply tanh_walsh_zero_outside v A S hv
      intro hsub
      exact hS (Finset.mem_filter.mpr ⟨Finset.mem_univ _,ho,s,hsub⟩)
    · exact tanh_walsh_zero_even v S (Nat.not_odd_iff_even.mp ho)
  have hp:=(projection_residual_le_comparison (carrierOddDownwardSupports size column)
    (fun x=>Real.tanh (cubeAffine bias u x)) (fun x=>Real.tanh (cubeAffine 0 v x)) hface).trans
      (tanh_neuron_l2_difference_le bias 0 u v)
  have he:(∑i,(u i-v i)^2)=∑i∈Aᶜ,u i^2 := by
    simp only [v]
    simp_rw [sub_ite,sub_self,sub_zero,ite_pow,zero_pow (by norm_num : 2≠0)]
    rw [Finset.sum_ite]
    simp only [Finset.sum_const_zero,zero_add]
    congr 1
    ext i
    simp
  simpa only [sub_zero,he] using hp

end NeuralGeneralization.OnlineLowerTanh
