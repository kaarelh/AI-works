import NeuralGeneralization.BatchTwoOnlineReluNormalization

/-! Exact physical layer rescaling for the no-internal-bias ReLU model. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def rescaleReluLayers {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (w : Weights d N r) : Weights d N r
  | .inl (i,j)=>b (.inr true)*w (.inl (i,j))
  | .inr (.inl (s,i,j))=>b (.inl s)*w (.inr (.inl (s,i,j)))
  | .inr (.inr i)=>b (.inr false)*w (.inr (.inr i))

theorem rescaleReluLayers_energy {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (w : Weights d N r)
    (i : Fin r⊕Bool) : weightedLayerEnergy (rescaleReluLayers b w) i=
      (b i)^2*weightedLayerEnergy w i := by
  rcases i with s | b'
  · simp only [weightedLayerEnergy,rescaleReluLayers,mul_pow,←Finset.mul_sum]
  · cases b' <;> simp only [weightedLayerEnergy,rescaleReluLayers,mul_pow,←Finset.mul_sum] <;> ring

theorem rescaleReluLayers_first {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (hb : ∀i,0≤b i)
    (w : Weights d N r) (x : Cube d) :
    firstHidden relu (rescaleReluLayers b w) x=
      fun i=>b (.inr true)*firstHidden relu w x i := by
  funext i
  simp only [firstHidden,rescaleReluLayers,mul_assoc,←Finset.mul_sum,
    relu_mul_nonneg (hb (.inr true))]

theorem rescaleReluLayers_step {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (hb : ∀i,0≤b i)
    (w : Weights d N r) (h : Fin N→ℝ) {c : ℝ} (hc : 0≤c) (s : Fin r) :
    hiddenStep relu (rescaleReluLayers b w) (fun i=>c*h i) s=
      fun i=>(b (.inl s)*c)*hiddenStep relu w h s i := by
  funext i
  unfold hiddenStep
  simp only [rescaleReluLayers]
  have he : (∑j,b (.inl s)*w (.inr (.inl (s,i,j)))*(c*h j))=
      (b (.inl s)*c)*(∑j,w (.inr (.inl (s,i,j)))*h j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he,relu_mul_nonneg (mul_nonneg (hb _) hc)]

theorem rescaleReluLayers_fold {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (hb : ∀i,0≤b i)
    (w : Weights d N r) (ss : List (Fin r)) (h : Fin N→ℝ) {c : ℝ} (hc : 0≤c) :
    ss.foldl (hiddenStep relu (rescaleReluLayers b w)) (fun i=>c*h i)=
      fun i=>(c*(ss.map (fun s=>b (.inl s))).prod)*ss.foldl (hiddenStep relu w) h i := by
  induction ss generalizing h c with
  | nil=>simp
  | cons s ss ih=>
    rw [List.foldl_cons,rescaleReluLayers_step b hb w h hc s,
      ih _ (mul_nonneg (hb _) hc)]
    simp only [List.map_cons,List.prod_cons,List.foldl_cons]
    funext i
    ring

theorem rescaleReluLayers_output {d N r : ℕ} (b : Fin r⊕Bool→ℝ) (hb : ∀i,0≤b i)
    (w : Weights d N r) (x : Cube d) :
    networkOutput relu (rescaleReluLayers b w) x=(∏i,b i)*networkOutput relu w x := by
  unfold networkOutput finalHidden
  rw [rescaleReluLayers_first b hb w x,
    rescaleReluLayers_fold b hb w _ _ (hb (.inr true))]
  simp only [rescaleReluLayers,←Fin.prod_univ_def,Fintype.prod_sum_type,Fintype.prod_bool]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

end NeuralGeneralization.BatchTwoActivation
