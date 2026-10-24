import NeuralGeneralization.BatchTwoContinuousPairMomentsModel
import NeuralGeneralization.NetworkReadout

/-! Actual hidden/readout product splitting for the small Gaussian scale. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuous.PairMoments
open ConcreteModel NetworkReadout

variable {d N r : ℕ}

def smallHiddenPrior (d N r : ℕ) (σ : ℝ) : Measure (HiddenIndex d N r→ℝ) :=
  Measure.pi (fun i : HiddenIndex d N r=>gaussianReal 0
    (smallVariance d N r σ ((Equiv.sumAssoc _ _ _) (.inl i))).toNNReal)

def smallReadoutPrior (N : ℕ) (σ : ℝ) : Measure (Fin N→ℝ) :=
  Measure.pi (fun _=>gaussianReal 0 (σ^2/N).toNNReal)

instance smallHiddenPrior_probability (d N r : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (smallHiddenPrior d N r σ) := by unfold smallHiddenPrior; infer_instance
instance smallReadoutPrior_probability (N : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (smallReadoutPrior N σ) := by unfold smallReadoutPrior; infer_instance

theorem smallPrior_weightSplit (d N r : ℕ) (σ : ℝ) :
    MeasurePreserving (weightSplit d N r) (smallPrior d N r σ)
      ((smallHiddenPrior d N r σ).prod (smallReadoutPrior N σ)) := by
  let μ : WeightIndex d N r→Measure ℝ:=fun i=>gaussianReal 0 (smallVariance d N r σ i).toNNReal
  have h1:=measurePreserving_piCongrLeft (α:=fun _ : WeightIndex d N r=>ℝ) μ
    (Equiv.sumAssoc (Fin N×Fin (d+1)) (Fin r×Fin N×Fin N) (Fin N))
  have h2:=measurePreserving_sumPiEquivProdPi_symm
    (fun i=>μ (Equiv.sumAssoc (Fin N×Fin (d+1)) (Fin r×Fin N×Fin N) (Fin N) i))
  have hs : MeasurePreserving (weightSplit d N r).symm
      ((smallHiddenPrior d N r σ).prod (smallReadoutPrior N σ)) (smallPrior d N r σ):=h1.comp h2
  exact MeasurePreserving.symm (weightSplit d N r).symm hs

@[simp] theorem hiddenDistanceSq_assemble (h : HiddenIndex d N r→ℝ) (a : Fin N→ℝ)
    (x y : RealInput d) : hiddenDistanceSq (assemble h a) x y=hiddenDistanceSq (assemble h 0) x y := rfl

theorem output_pair_assemble (h : HiddenIndex d N r→ℝ) (a : Fin N→ℝ) (x y : RealInput d) :
    output Real.tanh (assemble h a) x-output Real.tanh (assemble h a) y=
      ∑j,(BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) x j-
        BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) y j)*a j := by
  have hh : ∀z,BatchTwoContinuous.finalHidden Real.tanh (assemble h a) z=
      BatchTwoContinuous.finalHidden Real.tanh (assemble h 0) z := fun _=>rfl
  simp only [output,hh,assemble,sub_mul,mul_sub,Finset.sum_sub_distrib,mul_comm]

theorem hidden_moment_split (σ : ℝ) (x y : RealInput d) (p : ℕ) :
    (∫⁻h,ENNReal.ofReal (hiddenDistanceSq (assemble h 0) x y)^p ∂smallHiddenPrior d N r σ)=
      ∫⁻w,ENNReal.ofReal (hiddenDistanceSq w x y)^p ∂smallPrior d N r σ := by
  have hm : Measurable (fun w : Weights d N r=>ENNReal.ofReal (hiddenDistanceSq w x y)^p) :=
    ((measurable_hiddenDistanceSq x y).ennreal_ofReal).pow_const p
  have hs:=MeasurePreserving.symm (weightSplit d N r) (smallPrior_weightSplit d N r σ)
  rw [←hs.map_eq,lintegral_map hm hs.measurable]
  have hf : Measurable (fun z : (HiddenIndex d N r→ℝ)×(Fin N→ℝ)=>
      ENNReal.ofReal (hiddenDistanceSq ((weightSplit d N r).symm z) x y)^p) := hm.comp hs.measurable
  rw [lintegral_prod _ hf.aemeasurable]
  simp only [weightSplit_symm,hiddenDistanceSq_assemble,lintegral_const,measure_univ,mul_one]

end NeuralGeneralization.BatchTwoContinuous.PairMoments
