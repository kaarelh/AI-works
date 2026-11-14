import NeuralGeneralization.OnlineLowerReluMain

/-! Exact function-prior invariance under positive shallow ReLU layer balancing. -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.OnlineLowerRelu
open ConcreteModel OnlineLower

/-- Independent layer-isotropic Gaussians with arbitrary two positive variances. -/
def twoLayerVariance (d N : ℕ) (α β σ : ℝ) : WeightIndex d N 0 → ℝ
  | Sum.inl _ => α*σ^2
  | Sum.inr (Sum.inl (s,_,_)) => Fin.elim0 s
  | Sum.inr (Sum.inr _) => β*σ^2

def twoLayerPrior (d N : ℕ) (α β σ : ℝ) : Measure (Weights d N 0) :=
  productGaussian d N 0 (twoLayerVariance d N α β σ)

def layerScale {d N : ℕ} (a b : ℝ) (w : Weights d N 0) : Weights d N 0
  | Sum.inl ij => a*w (Sum.inl ij)
  | Sum.inr (Sum.inl (s,_,_)) => Fin.elim0 s
  | Sum.inr (Sum.inr j) => b*w (Sum.inr (Sum.inr j))

@[fun_prop] theorem measurable_layerScale {d N : ℕ} (a b : ℝ) :
    Measurable (layerScale (d:=d) (N:=N) a b) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ij | (⟨s,_,_⟩ | j)
  · exact measurable_const.mul (measurable_pi_apply _)
  · exact Fin.elim0 s
  · exact measurable_const.mul (measurable_pi_apply _)

theorem layerScale_output {d N : ℕ} (a b : ℝ) (ha : 0 ≤ a)
    (w : Weights d N 0) (x : Cube d) :
    networkOutput relu (layerScale a b w) x = (a*b)*networkOutput relu w x := by
  simp only [networkOutput,finalHidden,List.finRange_zero,List.foldl_nil,firstHidden]
  simp only [layerScale]
  simp_rw [mul_assoc,←Finset.mul_sum]
  have hr (t : ℝ) : relu (a*t)=a*relu t := by
    unfold relu
    rw [mul_max_of_nonneg _ _ ha,mul_zero]
  simp_rw [hr]
  simp_rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- Both layer scales act on one common isotropic Gaussian draw. -/
theorem isotropic_map_layerScale {d N : ℕ} (a b σ : ℝ) :
    (productGaussian d N 0 (fun _=>σ^2)).map (layerScale a b) =
      twoLayerPrior d N (a^2) (b^2) σ := by
  let factor : WeightIndex d N 0 → ℝ
    | Sum.inl _ => a
    | Sum.inr (Sum.inl (s,_,_)) => Fin.elim0 s
    | Sum.inr (Sum.inr _) => b
  have he : layerScale (d:=d) (N:=N) a b = fun w i=>factor i*w i := by
    funext w i
    rcases i with ij | (⟨s,_,_⟩ | j)
    · rfl
    · exact Fin.elim0 s
    · rfl
  rw [he,productGaussian,Measure.pi_map_pi
    (f := fun (i : WeightIndex d N 0) (x : ℝ) => factor i*x)
    (fun i=>(measurable_const.mul measurable_id : Measurable (fun x:ℝ=>factor i*x)).aemeasurable)]
  unfold twoLayerPrior productGaussian
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero]
  apply congrArg (gaussianReal 0)
  apply NNReal.eq
  rcases i with ij | (⟨s,_,_⟩ | j)
  · simp only [factor,twoLayerVariance,NNReal.coe_mul,NNReal.coe_mk,
      Real.coe_toNNReal (σ^2) (sq_nonneg σ),
      Real.coe_toNNReal (a^2*σ^2) (mul_nonneg (sq_nonneg a) (sq_nonneg σ))]
  · exact Fin.elim0 s
  · simp only [factor,twoLayerVariance,NNReal.coe_mul,NNReal.coe_mk,
      Real.coe_toNNReal (σ^2) (sq_nonneg σ),
      Real.coe_toNNReal (b^2*σ^2) (mul_nonneg (sq_nonneg b) (sq_nonneg σ))]

/-- Positive layer variances with equal product induce exactly the same
prior on ReLU functions, including their absolute output scale. -/
theorem twoLayer_functionMass_eq {d N : ℕ} (α β α' β' : ℝ)
    (hα : 0 < α) (hβ : 0 < β) (hα' : 0 < α') (hβ' : 0 < β')
    (hprod : α*β=α'*β') (σ a : ℝ) (g : BooleanFunction d) :
    functionMass relu a (twoLayerPrior d N α β σ) g =
      functionMass relu a (twoLayerPrior d N α' β' σ) g := by
  have hs : Real.sqrt α*Real.sqrt β=Real.sqrt α'*Real.sqrt β' := by
    rw [←Real.sqrt_mul hα.le,←Real.sqrt_mul hα'.le,hprod]
  have hm := isotropic_map_layerScale (d:=d) (N:=N) (Real.sqrt α) (Real.sqrt β) σ
  have hm' := isotropic_map_layerScale (d:=d) (N:=N) (Real.sqrt α') (Real.sqrt β') σ
  rw [Real.sq_sqrt hα.le,Real.sq_sqrt hβ.le] at hm
  rw [Real.sq_sqrt hα'.le,Real.sq_sqrt hβ'.le] at hm'
  unfold functionMass
  rw [←hm,←hm',Measure.map_apply (measurable_layerScale _ _)
    (isOpen_marginEvent (show Continuous relu from continuous_const.max continuous_id) a g).measurableSet,
    Measure.map_apply (measurable_layerScale _ _)
    (isOpen_marginEvent (show Continuous relu from continuous_const.max continuous_id) a g).measurableSet]
  congr 2
  ext w
  simp only [Set.mem_preimage,marginEvent,Set.mem_setOf_eq]
  simp_rw [layerScale_output _ _ (Real.sqrt_nonneg _),hs]

/-- The common small-scale reparameterization depends only on the product
of the two layer variances, not on width. -/
def layerScaleFactor (d : ℕ) (α β : ℝ) : ℝ := Real.sqrt (Real.sqrt ((d:ℝ)*α*β))

theorem layerScaleFactor_pos {d : ℕ} (hd : 0 < d) {α β : ℝ}
    (hα : 0 < α) (hβ : 0 < β) : 0 < layerScaleFactor d α β :=
  Real.sqrt_pos.mpr (Real.sqrt_pos.mpr (mul_pos (mul_pos (Nat.cast_pos.mpr hd) hα) hβ))

theorem twoLayer_functionMass_eq_smallPrior {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (α β : ℝ) (hα : 0 < α) (hβ : 0 < β) (σ a : ℝ) (g : BooleanFunction d) :
    functionMass relu a (twoLayerPrior d N α β σ) g =
      functionMass relu a (smallPrior d N 0 (layerScaleFactor d α β*σ)) g := by
  let q := layerScaleFactor d α β
  have hq : 0 < q := layerScaleFactor_pos hd hα hβ
  have hdr : (0:ℝ) < d := Nat.cast_pos.mpr hd
  have hNr : (0:ℝ) < N := Nat.cast_pos.mpr hN
  have hq4 : q^2*q^2=(d:ℝ)*α*β := by
    dsimp [q,layerScaleFactor]
    rw [Real.sq_sqrt (Real.sqrt_nonneg _),←pow_two,Real.sq_sqrt (by positivity)]
  have hprod : α*β=((N:ℝ)/d*q^2)*(q^2/N) := by
    field_simp
    nlinarith [hq4]
  have he : twoLayerPrior d N ((N:ℝ)/d*q^2) (q^2/N) σ = smallPrior d N 0 (q*σ) := by
    unfold twoLayerPrior smallPrior
    congr 1
    funext i
    rcases i with ij | (⟨s,_,_⟩ | j)
    · simp only [twoLayerVariance,smallVariance,mul_pow];ring
    · exact Fin.elim0 s
    · simp only [twoLayerVariance,smallVariance,mul_pow];ring
  rw [←he]
  exact twoLayer_functionMass_eq α β _ _ hα hβ (by positivity) (by positivity) hprod σ a g

end NeuralGeneralization.OnlineLowerRelu
