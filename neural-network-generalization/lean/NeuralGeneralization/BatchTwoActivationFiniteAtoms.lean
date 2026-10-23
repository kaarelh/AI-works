import NeuralGeneralization.BatchTwoActivationMixtureSampling
import NeuralGeneralization.BatchTwoActivationSourceTransport
import NeuralGeneralization.BatchTwoActivationStatements

/-! Stable finite auxiliary-neuron realization of covariance tail atoms.
The selected activations are exactly original atom activations or zero. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
variable {I J E : Type*} [Fintype I] [DecidableEq I] [Fintype J] [DecidableEq J]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

theorem source_observation_bound (a : I→E) (u : E) {R : ℝ}
    (ha : ∀i,‖a i‖≤R) (hu : ‖u‖≤1) (i : I) : |inner ℝ (a i) u|≤R := by
  calc
    _ ≤ ‖a i‖*‖u‖ := abs_real_inner_le_norm _ _
    _ ≤ ‖a i‖*1 := mul_le_mul_of_nonneg_left hu (norm_nonneg _)
    _ ≤ R := by simpa using ha i

theorem scalar_outer_perturbation {x x' y y' B δ : ℝ}
    (hB : 0≤B) (hδ : 0≤δ) (hx : |x|≤B) (hy : |y|≤B)
    (he₁ : |x'-x|≤δ) (he₂ : |y'-y|≤δ) : |x'*y'-x*y|≤δ*(2*B+δ) := by
  have hy' : |y'|≤B+δ := by
    have ht := abs_sub_le y' y 0
    simp only [sub_zero] at ht
    linarith
  have heq : x'*y'-x*y=(x'-x)*y'+x*(y'-y) := by ring
  rw [heq]
  apply (abs_add_le _ _).trans
  rw [abs_mul,abs_mul]
  have h₁ := mul_le_mul he₁ hy' (abs_nonneg _) hδ
  have h₂ := mul_le_mul hx he₂ (abs_nonneg _) hB
  nlinarith

def optionActivation (ψ : J→ℝ→ℝ) : Option J→ℝ→ℝ
  | none => fun _=>0
  | some j => ψ j

def optionCoefficient (β : J→I→ℝ) : Option J→I→ℝ
  | none => 0
  | some j => β j

theorem exists_stable_finite_atoms (a : I→E) (u : J→E) (ψ : J→ℝ→ℝ)
    {ℓ A R ε η : ℝ} (hℓ : 0<ℓ) (hA : 0<A) (hR : 0<R) (hε : 0≤ε) (hη : 0<η)
    (ha : ∀i,‖a i‖≤R) (hu : ∀j,‖u j‖≤1)
    (hψ : ∀j,zeroLipschitzActivation ℓ (ψ j))
    (c : J→ℝ) (hc : ∀j,0≤c j) (hcs : (∑j,c j)≤A)
    {N : ℕ} (hN : 0<N)
    (hbudget : 2*(Fintype.card I:ℝ)^2*Real.exp (-(N:ℝ)*((ε/A)/(ℓ*R)^2)^2/2)<1) :
    ∃(ξ:Fin N→ℝ→ℝ) (β:Fin N→I→ℝ),
      (∀k,zeroLipschitzActivation ℓ (ξ k)) ∧ (∀k,(∑i,|β k i|)≤1/(4*η)) ∧
      ∀Q':I→I→ℝ, (∀i j,|Q' i j-sourceGram a i j|≤η^2) → ∀p q,
        |(A/(N:ℝ))*(∑k,ξ k (∑i,β k i*Q' p i)*ξ k (∑i,β k i*Q' q i))-
          (∑j,c j*ψ j (inner ℝ (a p) (u j))*ψ j (inner ℝ (a q) (u j)))|<
          ε+A*(5*ℓ*η/4)*(2*ℓ*R+5*ℓ*η/4) := by
  classical
  letI : MeasurableSpace (Option J) := ⊤
  letI : MeasurableSingletonClass (Option J) := ⟨fun _=>MeasurableSpace.measurableSet_top⟩
  have hex (j : J) := exists_stable_source_certificate a (u j) (hu j) hη
  choose β hβ hn htransport using hex
  let h : J→I→ℝ := fun j i=>ψ j (inner ℝ (a i) (u j))
  have hb : ∀j i,|h j i|≤ℓ*R := fun j i=>
    (activation_abs_le (hψ j) _).trans
      (mul_le_mul_of_nonneg_left (source_observation_bound a (u j) ha (hu j) i) hℓ.le)
  obtain ⟨w,hw⟩ := exists_mixture_covariance_sample c hA (mul_pos hℓ hR) hc hcs h hb hN hε hbudget
  let ξ : Fin N→ℝ→ℝ := fun k=>optionActivation ψ (w k)
  let β' : Fin N→I→ℝ := fun k=>optionCoefficient β (w k)
  have hclass (k : Fin N) : zeroLipschitzActivation ℓ (ξ k) := by
    dsimp [ξ]
    cases hwk : w k with
    | none => exact ⟨rfl,fun x y=>by simp only [optionActivation,sub_self,abs_zero]; positivity⟩
    | some j => exact hψ j
  have hbeta (k : Fin N) : (∑i,|β' k i|)≤1/(4*η) := by
    dsimp [β']
    cases hwk : w k with
    | none => simp only [optionCoefficient,Pi.zero_apply,abs_zero,Finset.sum_const_zero]; positivity
    | some j => exact hβ j
  refine ⟨ξ,β',hclass,hbeta,?_⟩
  intro Q' hQ p q
  have hpoint (k : Fin N) (i : I) :
      |ξ k (∑j,β' k j*Q' i j)-mixtureFeature h (w k) i|≤5*ℓ*η/4 := by
    dsimp [ξ,β']
    cases hwk : w k with
    | none => simp only [optionCoefficient,Pi.zero_apply,zero_mul,Finset.sum_const_zero,
        optionActivation,mixtureFeature,sub_self,abs_zero]; positivity
    | some j =>
      have he := htransport j Q' (η^2) (sq_nonneg η) hQ i
      have he' : |(∑k,β j k*Q' i k)-inner ℝ (a i) (u j)|≤5*η/4 := by
        apply he.trans_eq
        field_simp
        ring
      have hh := (hψ j).2 (∑k,β j k*Q' i k) (inner ℝ (a i) (u j))
      change |ψ j (∑k,β j k*Q' i k)-ψ j (inner ℝ (a i) (u j))|≤_
      nlinarith [mul_le_mul_of_nonneg_left he' hℓ.le]
  have hold (k : Fin N) (i : I) : |mixtureFeature h (w k) i|≤ℓ*R := by
    cases hwk : w k with
    | none => simp only [mixtureFeature,Pi.zero_apply,abs_zero]; positivity
    | some j => exact hb j i
  have hout (k : Fin N) :
      |ξ k (∑i,β' k i*Q' p i)*ξ k (∑i,β' k i*Q' q i)-
        mixtureFeature h (w k) p*mixtureFeature h (w k) q|≤(5*ℓ*η/4)*(2*ℓ*R+5*ℓ*η/4) := by
    simpa only [mul_assoc] using scalar_outer_perturbation (by positivity) (by positivity) (hold k p) (hold k q) (hpoint k p) (hpoint k q)
  have hscaled :
      |(A/(N:ℝ))*(∑k,ξ k (∑i,β' k i*Q' p i)*ξ k (∑i,β' k i*Q' q i))-
        (A/(N:ℝ))*(∑k,mixtureFeature h (w k) p*mixtureFeature h (w k) q)|≤
        A*(5*ℓ*η/4)*(2*ℓ*R+5*ℓ*η/4) := by
    rw [←mul_sub,abs_mul,abs_of_nonneg (div_nonneg hA.le (Nat.cast_nonneg N)),←Finset.sum_sub_distrib]
    have ht := (Finset.abs_sum_le_sum_abs _ Finset.univ).trans (Finset.sum_le_sum (fun k _=>hout k))
    have hm := mul_le_mul_of_nonneg_left ht (div_nonneg hA.le (Nat.cast_nonneg N))
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at hm
    apply hm.trans_eq
    have hNr : (N:ℝ)≠0 := Nat.cast_ne_zero.mpr hN.ne'
    field_simp
  have hs := hw p q
  have ht := abs_sub_le ((A/(N:ℝ))*(∑k,ξ k (∑i,β' k i*Q' p i)*ξ k (∑i,β' k i*Q' q i)))
    ((A/(N:ℝ))*(∑k,mixtureFeature h (w k) p*mixtureFeature h (w k) q))
    (∑j,c j*h j p*h j q)
  change |(A/(N:ℝ))*(∑k,ξ k (∑i,β' k i*Q' p i)*ξ k (∑i,β' k i*Q' q i))-
    (∑j,c j*h j p*h j q)|<_
  linarith

end NeuralGeneralization.BatchTwoActivation
