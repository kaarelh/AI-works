import NeuralGeneralization.BatchTwoActivationFullNetworkEventsModel

/-! Exact product laws for the actual physical network's standardized layers. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularFields CompressionSampling FiniteDifferential
open RobustCompressionBlockMoments NetworkLayerSplit TowerNetwork

variable {d N r : ℕ}

def activationMatrixPrior (N : ℕ) (σ : ℝ) : Measure (Fin N × Fin N → ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 (σ^2).toNNReal)

instance activationMatrixPrior_probability (N : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (activationMatrixPrior N σ) := by
  unfold activationMatrixPrior
  infer_instance

theorem activationSmallVariance_indexJoin (d N r : ℕ) (σ : ℝ)
    (i : WeightIndex d N r ⊕ (Fin N × Fin N)) :
    smallVariance d N (r+1) σ (indexJoin d N r i)=
      Sum.elim (smallVariance d N r σ) (fun _=>σ^2) i := by
  rcases i with (ij | (⟨s,i,j⟩ | j)) | ⟨i,j⟩ <;> rfl

theorem activationSmallPrior_split (d N r : ℕ) (σ : ℝ) :
    MeasurePreserving (split d N r) (smallPrior d N (r+1) σ)
      ((smallPrior d N r σ).prod (activationMatrixPrior N σ)) := by
  let μ : WeightIndex d N (r+1) → Measure ℝ :=
    fun i=>gaussianReal 0 (smallVariance d N (r+1) σ i).toNNReal
  have h1:=measurePreserving_piCongrLeft (α:=fun _ : WeightIndex d N (r+1)=>ℝ)
    μ (indexJoin d N r)
  have h2:=measurePreserving_sumPiEquivProdPi_symm (fun i=>μ (indexJoin d N r i))
  have h:=h1.comp h2
  have hs : MeasurePreserving (split d N r).symm
      ((smallPrior d N r σ).prod (activationMatrixPrior N σ)) (smallPrior d N (r+1) σ) := by
    convert h using 1
    · rfl
    · simp only [μ,activationSmallVariance_indexJoin,Sum.elim_inl,Sum.elim_inr]
      rfl
    · rfl
  exact MeasurePreserving.symm (split d N r).symm hs

theorem activationStandardCurry_law (a n : ℕ) :
    (Measure.pi (fun _ : Fin a × Fin n=>gaussianReal 0 1)).map
      (fun z i j=>z (i,j))=iidSamples (standardLaw (Fin n)) a := by
  have hp:=LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin a) (_ : Fin n)=>gaussianReal 0 1)
  exact (MeasurePreserving.symm (MeasurableEquiv.curry (Fin a) (Fin n) ℝ).symm hp).map_eq

theorem activationInputRows_law (hd : 0<d) (hN : 0<N) {σ : ℝ} (hσ : 0<σ) :
    (smallPrior d N r σ).map (activationInputRows σ)=
      iidSamples (standardLaw (Fin (d+1))) N := by
  change (smallPrior d N r σ).map
    ((fun z : Fin N × Fin (d+1)→ℝ=>fun i j=>z (i,j)) ∘
      (fun w j=>standardizedWeights σ w (.inl j)))=_
  have hm : Measurable (fun w : Weights d N r=>fun j : Fin N × Fin (d+1)=>standardizedWeights σ w (.inl j)) :=
    measurable_pi_lambda _ (fun j=>(measurable_pi_apply (.inl j)).comp (measurable_standardizedWeights σ))
  rw [←Measure.map_map (by fun_prop) hm,first_standardized_law hd hN hσ]
  exact activationStandardCurry_law N (d+1)

def activationMatrixRows (σ : ℝ) (a : Fin N × Fin N →ℝ) (i j : Fin N) : ℝ := a (i,j)/σ

@[fun_prop] theorem measurable_activationMatrixRows (σ : ℝ) :
    Measurable (activationMatrixRows (N:=N) σ) := by unfold activationMatrixRows; fun_prop

theorem activationMatrixRows_law {σ : ℝ} (hσ : 0<σ) :
    (activationMatrixPrior N σ).map (activationMatrixRows σ)=
      iidSamples (standardLaw (Fin N)) N := by
  have hscale : Measurable (fun a : Fin N × Fin N→ℝ=>fun j=>a j/σ) := by fun_prop
  change (activationMatrixPrior N σ).map
    ((fun z : Fin N × Fin N→ℝ=>fun i j=>z (i,j)) ∘
      (fun a : Fin N × Fin N→ℝ=>fun j=>a j/σ))=_
  rw [←Measure.map_map (by fun_prop) hscale]
  have hh : (activationMatrixPrior N σ).map (fun a j=>a j/σ)=
      Measure.pi (fun _ : Fin N × Fin N=>gaussianReal 0 1) := by
    rw [activationMatrixPrior,Measure.pi_map_pi (f:=fun (_ : Fin N × Fin N) (z : ℝ)=>z/σ)
      (fun _=>(measurable_id.div_const σ).aemeasurable)]
    congr 1
    funext j
    rw [gaussianReal_map_div_const,zero_div]
    congr 1
    apply NNReal.coe_injective
    simp only [NNReal.coe_div,Real.coe_toNNReal _ (sq_nonneg σ),NNReal.coe_mk,NNReal.coe_one]
    exact div_self (sq_pos_of_pos hσ).ne'
  rw [hh]
  exact activationStandardCurry_law N N

end NeuralGeneralization.BatchTwoActivation
