import NeuralGeneralization.BatchTwoActivationPolynomialStep

/-! Zero padding of reconstructed layers to a common finite width. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation

 theorem pad_weighted_layer {I J X : Type*} [Fintype I] [Fintype J]
    (F : ℕ) (hF : Fintype.card I≤F) {ℓ V Wb Hb : ℝ}
    (ψ : I → ℝ → ℝ) (W : I → J → ℝ) (v : I → ℝ) (h : J → X → ℝ)
    (hℓ : 0≤ℓ) (hV : 0≤V) (hWb : 0≤Wb) (hHb : 0≤Hb)
    (hψ : ∀i,zeroLipschitzActivation ℓ (ψ i))
    (hv : ∀i,0≤v i ∧ v i≤V) (hW : ∀i j,|W i j|≤Wb)
    (hh : ∀i x,|ψ i (∑j,W i j*h j x)|≤Hb) :
    ∃(ψ' : Fin F → ℝ → ℝ) (W' : Fin F → J → ℝ) (v' : Fin F → ℝ),
      (∀i,zeroLipschitzActivation ℓ (ψ' i)) ∧
      (∀i,0≤v' i ∧ v' i≤V) ∧ (∀i j,|W' i j|≤Wb) ∧
      (∀i x,|ψ' i (∑j,W' i j*h j x)|≤Hb) ∧
      ∀x y,weightedFeatureGram (fun i x => ψ' i (∑j,W' i j*h j x)) v' x y=
        weightedFeatureGram (fun i x => ψ i (∑j,W i j*h j x)) v x y := by
  classical
  let e : Fin F ≃ I ⊕ Fin (F-Fintype.card I) := Fintype.equivOfCardEq (by
    simp only [Fintype.card_fin,Fintype.card_sum]
    omega)
  let ψ' := fun i => Sum.elim ψ (fun _ _ => (0:ℝ)) (e i)
  let W' := fun i => Sum.elim W (fun _ _ => (0:ℝ)) (e i)
  let v' := fun i => Sum.elim v (fun _ => (0:ℝ)) (e i)
  refine ⟨ψ',W',v',?_,?_,?_,?_,?_⟩
  · intro i
    cases he : e i with
    | inl j => simpa only [ψ',he,Sum.elim_inl] using hψ j
    | inr j =>
      simp only [ψ',he,Sum.elim_inr,zeroLipschitzActivation]
      exact ⟨trivial,fun x y => by simpa only [sub_self,abs_zero] using mul_nonneg hℓ (abs_nonneg (x-y))⟩
  · intro i
    cases he : e i with
    | inl j => simpa only [v',he,Sum.elim_inl] using hv j
    | inr j => simpa only [v',he,Sum.elim_inr] using And.intro (le_refl (0:ℝ)) hV
  · intro i j
    cases he : e i with
    | inl k => simpa only [W',he,Sum.elim_inl] using hW k j
    | inr k => simpa only [W',he,Sum.elim_inr,abs_zero] using hWb
  · intro i x
    cases he : e i with
    | inl j => simpa only [ψ',W',he,Sum.elim_inl] using hh j x
    | inr j => simpa only [ψ',he,Sum.elim_inr,abs_zero] using hHb
  · intro x y
    unfold weightedFeatureGram
    rw [Fintype.sum_equiv e (fun i => v' i*ψ' i (∑j,W' i j*h j x)*ψ' i (∑j,W' i j*h j y))
      (fun i => Sum.elim v (fun _ => 0) i*
        Sum.elim ψ (fun _ _ => 0) i (∑j,Sum.elim W (fun _ _ => 0) i j*h j x)*
        Sum.elim ψ (fun _ _ => 0) i (∑j,Sum.elim W (fun _ _ => 0) i j*h j y)) (fun _ => rfl)]
    simp only [Fintype.sum_sum_type,Sum.elim_inl,Sum.elim_inr,zero_mul,Finset.sum_const_zero,add_zero]

end NeuralGeneralization.BatchTwoActivation
