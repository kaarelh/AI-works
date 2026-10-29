import GaussianRegressionGeometry

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

theorem directionSplit_dot_general (u h : I→ℝ) (z : ℝ) (ξ : I→ℝ) :
    (∑i,h i*directionSplit u z ξ i)=
      z*(∑i,u i*h i)+(∑i,h i*ξ i)-(∑i,u i*ξ i)*(∑i,u i*h i) := by
  unfold directionSplit
  have he (i:I) : h i*(z*u i+ξ i-u i*(∑j,u j*ξ j))=
      z*(u i*h i)+h i*ξ i-(∑j,u j*ξ j)*(u i*h i) := by ring
  simp_rw [he]
  rw [Finset.sum_sub_distrib,Finset.sum_add_distrib,←Finset.mul_sum,←Finset.mul_sum]

theorem directionSplit_unit_dot_general (u : I→ℝ) (hu : ∑i,u i^2=1) (z : ℝ) (ξ : I→ℝ) :
    (∑i,u i*directionSplit u z ξ i)=z := by
  rw [directionSplit_dot_general]
  have hh : (∑i,u i*u i)=1 := by simpa only [pow_two] using hu
  rw [hh]
  ring

theorem directionSplit_anchor_preserved (A : X→I→ℝ) (S : Finset X)
    (u : I→ℝ) (horth : ∀s:S,∑i,u i*A s i=0) (z : ℝ) (ξ : I→ℝ) :
    maskCoordinates S (fieldLinear A (directionSplit u z ξ))=
      maskCoordinates S (fieldLinear A ξ) := by
  funext y
  by_cases hy : y∈S
  · simp only [maskCoordinates,hy,if_true,fieldLinear_apply]
    rw [directionSplit_dot_general,horth ⟨y,hy⟩]
    ring
  · simp [maskCoordinates,hy]

theorem gaussian_anchor_normalized_innovation {X I : Type*}
    [Fintype X] [DecidableEq X] [Fintype I]
    (A : X→I→ℝ) (S : Finset X) (x : X) (c : S→ℝ)
    (horth : ∀s:S,∑i,anchorRegressionResidual A S x c i*A s i=0)
    {σ : ℝ} (hσ : 0<σ)
    (hvariance : σ^2=∑i,(anchorRegressionResidual A S x c i)^2) :
    ((fieldLaw A).map (coordinatePair S x)).map
      (fun p=> (p.1,(p.2-anchorRegressionMean S c p.1)/σ))=
      ((fieldLaw A).map (coordinatePair S x)).fst.prod (gaussianReal 0 1) := by
  classical
  let e := anchorRegressionResidual A S x c
  let u : I→ℝ := fun i=>e i/σ
  let anchors : (I→ℝ)→(X→ℝ) := fun ξ=>maskCoordinates S (fieldLinear A ξ)
  let T : (I→ℝ)→(X→ℝ)×ℝ := fun ξ=>
    (anchors ξ,(fieldLinear A ξ x-anchorRegressionMean S c (anchors ξ))/σ)
  let split : ℝ×(I→ℝ)→I→ℝ := fun p=>directionSplit u p.1 p.2
  have hanchors : Measurable anchors := (measurable_maskCoordinates S).comp (fieldLinear A).continuous.measurable
  have hT : Measurable T := by dsimp [T]; fun_prop
  have hsplit : Measurable split := by
    change Measurable (fun p : ℝ×(I→ℝ)=>fun i=>p.1*u i+p.2 i-u i*(∑j,u j*p.2 j))
    fun_prop
  have hu : (∑i,u i^2)=1 := by
    dsimp [u]
    simp_rw [div_pow]
    rw [←Finset.sum_div,←hvariance]
    exact div_self (pow_ne_zero _ hσ.ne')
  have huorth (s:S) : (∑i,u i*A s i)=0 := by
    dsimp [u]
    have heq : (∑i,e i/σ*A s i)=(∑i,e i*A s i)/σ := by
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [heq,horth]
    simp
  have hcompose : T ∘ split=(fun p : ℝ×(I→ℝ)=>(anchors p.2,p.1)) := by
    funext p
    apply Prod.ext
    · exact directionSplit_anchor_preserved A S u huorth p.1 p.2
    · change (fieldLinear A (directionSplit u p.1 p.2) x-
        anchorRegressionMean S c (maskCoordinates S (fieldLinear A (directionSplit u p.1 p.2))))/σ=p.1
      rw [anchorRegression_residual_identity]
      have heq : (∑i,e i*directionSplit u p.1 p.2 i)/σ=
          ∑i,u i*directionSplit u p.1 p.2 i := by
        rw [Finset.sum_div]
        apply Finset.sum_congr rfl
        intro i _
        dsimp [u]
        ring
      exact heq.trans (directionSplit_unit_dot_general u hu p.1 p.2)
  have hproduct : ((gaussianReal 0 1).prod (standardLaw I)).map
      (fun p : ℝ×(I→ℝ)=>(anchors p.2,p.1))=
      ((standardLaw I).map anchors).prod (gaussianReal 0 1) := by
    have hm := Measure.map_prod_map (standardLaw I) (gaussianReal 0 1) hanchors measurable_id
    rw [Measure.map_id] at hm
    rw [hm,←Measure.prod_swap (μ:=gaussianReal 0 1) (ν:=standardLaw I),
      Measure.map_map (hanchors.prodMap measurable_id) measurable_swap]
    rfl
  have hbase : (standardLaw I).map T=
      ((standardLaw I).map anchors).prod (gaussianReal 0 1) := by
    have hsref : ((gaussianReal 0 1).prod (standardLaw I)).map split=standardLaw I :=
      directionSplit_product_map u hu
    calc
      _ = (((gaussianReal 0 1).prod (standardLaw I)).map split).map T :=
        congrArg (fun μ=>μ.map T) hsref.symm
      _ = _ := by
        rw [Measure.map_map hT hsplit,hcompose]
        exact hproduct
  rw [coordinatePair_fst]
  unfold fieldLaw
  rw [Measure.map_map (by fun_prop) (measurable_coordinatePair S x),
    Measure.map_map (by fun_prop) (fieldLinear A).continuous.measurable,
    Measure.map_map (measurable_maskCoordinates S) (fieldLinear A).continuous.measurable]
  exact hbase

#print axioms gaussian_anchor_normalized_innovation
end ConditionalNonpolynomial.Analytic
