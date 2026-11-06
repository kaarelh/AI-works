import NeuralGeneralization.DepthNormBallNetwork

/-! Embed the relevant coordinates into an arbitrary specified subset of the input. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel

def liftInput {q d N r : ℕ} (e : Fin q ↪ Fin d) (w : Weights q N r) : Weights d N r
  | Sum.inl (i,j) => Fin.cases (w (Sum.inl (i,0)))
      (fun k => ∑ a, if e a=k then w (Sum.inl (i,a.succ)) else 0) j
  | Sum.inr j => w (Sum.inr j)

lemma injection_sum {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β] (e : α ↪ β)
    (a : α → ℝ) (F : ℝ → ℝ) (hF : F 0=0) :
    (∑ j, F (∑ i, if e i=j then a i else 0)) = ∑ i,F (a i) := by
  have hout (j : β) (hj : j ∉ Finset.univ.image e) :
      F (∑ i, if e i=j then a i else 0)=0 := by
    have hne (i : α) : e i≠j := by
      intro h
      exact hj (Finset.mem_image.mpr ⟨i,Finset.mem_univ _,h⟩)
    simpa only [hne,ite_false,Finset.sum_const_zero] using hF
  rw [← Finset.sum_subset (Finset.subset_univ (Finset.univ.image e)) (fun j _ hj => hout j hj)]
  rw [Finset.sum_image (fun i _ k _ h => e.injective h)]
  apply Finset.sum_congr rfl
  intro i _
  simp [e.injective.eq_iff]

lemma liftInput_first_preactivation {q d N r : ℕ} (e : Fin q ↪ Fin d)
    (w : Weights q N r) (x : Cube d) (i : Fin N) :
    (∑ j, liftInput e w (Sum.inl (i,j))*inputVector x j) =
      ∑ j, w (Sum.inl (i,j))*inputVector (x ∘ e) j := by
  rw [Fin.sum_univ_succ,Fin.sum_univ_succ]
  simp only [liftInput,Fin.cases_zero,Fin.cases_succ,inputVector,mul_one,Finset.sum_mul]
  congr 1
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  simp

lemma liftInput_first_sq {q d N r : ℕ} (e : Fin q ↪ Fin d)
    (w : Weights q N r) :
    (∑ i, ∑ j, (liftInput e w (Sum.inl (i,j)))^2) =
      ∑ i, ∑ j, (w (Sum.inl (i,j)))^2 := by
  apply Finset.sum_congr rfl
  intro i _
  rw [Fin.sum_univ_succ,Fin.sum_univ_succ]
  simp only [liftInput,Fin.cases_zero,Fin.cases_succ]
  congr 1
  simpa only using! injection_sum e (fun a => w (Sum.inl (i,a.succ))) (fun z => z^2) (by norm_num)

lemma liftInput_firstHidden {q d N r : ℕ} (e : Fin q ↪ Fin d)
    (φ : ℝ → ℝ) (w : Weights q N r) (x : Cube d) :
    firstHidden φ (liftInput e w) x=firstHidden φ w (x ∘ e) := by
  funext i
  unfold firstHidden
  rw [liftInput_first_preactivation]

lemma liftInput_hiddenStep {q d N r : ℕ} (e : Fin q ↪ Fin d)
    (φ : ℝ → ℝ) (w : Weights q N r) :
    hiddenStep φ (liftInput e w)=hiddenStep φ w := rfl

lemma liftInput_networkOutput {q d N r : ℕ} (e : Fin q ↪ Fin d)
    (φ : ℝ → ℝ) (w : Weights q N r) (x : Cube d) :
    networkOutput φ (liftInput e w) x=networkOutput φ w (x ∘ e) := by
  simp only [networkOutput,finalHidden,liftInput_firstHidden,liftInput_hiddenStep,liftInput]

lemma liftInput_norm {q d N r : ℕ} (e : Fin q ↪ Fin d) (w : Weights q N r) :
    weightedSquaredNorm (liftInput e w) =
      (d:ℝ)/N*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)+
      (∑ s,∑ i,∑ j,(w (Sum.inr (Sum.inl (s,i,j))))^2)+
      (N:ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2) := by
  unfold weightedSquaredNorm
  rw [liftInput_first_sq]
  rfl

end NeuralGeneralization.DepthNormBall
