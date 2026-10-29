import CanonicalAnchorNonGaussianControl
import GaussianFieldSourceControl
import PhysicalCanonicalLayerModel

/-! Actual canonical compression retaining separate row entropy budgets.
The same chosen law pays its Gaussian part from raw entropy and its
non-Gaussian part from the proved adjusted physical charge. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

def PhysicalEntropySplitStep {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) (j : ℕ)
    (B C : CanonicalProgramState d) : Prop := by
  classical
  exact PhysicalCanonicalProgramStep P S j B C ∧
    ∃M : CanonicalLayerModel (J:=C.Index) (fun s:S=>t • B.feature s) (physicalLayerCost P j),
      M.nongaussianCost≤physicalAdjustedCost P j ∧∀x,C.feature x=M.value (t • B.feature x)

lemma PhysicalEntropySplitStep.physicalStep {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    {P : ControlledMarginPath d H t f} {S : Finset (Cube d)} {j : ℕ}
    {B C : CanonicalProgramState d} (h : PhysicalEntropySplitStep P S j B C) :
    PhysicalCanonicalProgramStep P S j B C := h.1

/-- Stronger one-step construction, with the actual non-Gaussian budget. -/
theorem physical_entropy_split_step_exists {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) (j : ℕ) (hj : j<H)
    (B : CanonicalProgramState d) (hB : B.physicalAnchorInvariant P S j) :
    ∃C : CanonicalProgramState d,PhysicalEntropySplitStep P S j B C ∧
      C.physicalAnchorInvariant P S (j+1) ∧C.dimension≤B.dimension+S.card+1 := by
  classical
  letI := P.probability j hj
  letI := physicalSourceControl_probability P j hj
  have hsource : klDiv (physicalSourceControl P j) (standardLaw (Cube d⊕Cube d))≠∞ := by
    rw [physicalSourceControl_kl P j hj]
    exact P.finiteKL j hj
  obtain ⟨L,hL,hKL,hcost,hmap,hreplacement,hng⟩ := canonical_anchor_control_nonGaussian
    (scaledFeatureCoefficients t (P.feature j)) (fun x=>t • B.feature x)
    (P.law j) (P.finiteKL j hj) S (by
      intro x hx y hy
      have hh := hB x hx y hy
      rw [scaledFeatureCoefficients_gram,real_inner_smul_left,real_inner_smul_right,hh]
      ring)
    (physicalSourceControl P j) hsource (physicalSourceControl_map P j hj)
  letI := hL
  let C : CanonicalProgramState d :=
    {Index:=CanonicalIndex L hKL (fun u:S=>t • B.feature u)
     feature:=fun x=>canonicalGaussianMap L hKL (fun u:S=>t • B.feature u) (t • B.feature x)}
  obtain ⟨hmom,hdim⟩ := canonical_anchor_step_moments (fun x=>t • B.feature x) (P.law j) S L hKL hmap
  have hngreal : (klDiv L (matchingGaussian L)).toReal≤physicalAdjustedCost P j := by
    have hfinite := (gaussianCovarianceCost_decomposition (physicalSourceControl P j) hsource).1
    exact (ENNReal.toReal_mono hfinite hng).trans (physicalSourceControl_nonGaussian_le_adjusted P j hj)
  refine ⟨C,?_,?_,hdim⟩
  · constructor
    · exact ⟨L,hL,hKL,hcost,hmap,hreplacement,LinearIsometry.id,fun _=>rfl⟩
    · refine ⟨{law:=L,probability:=hL,finiteKL:=hKL,cost_le:=hcost,output:=LinearIsometry.id},hngreal,?_⟩
      intro x
      rfl
  · intro x hx y hy
    exact (hmom x hx y hy).trans (P.recursion j hj x y).symm

/-- Full actual canonical path with the non-Gaussian budget preserved at every
layer, exact anchor blocks, and linear dimension growth. -/
theorem physical_entropy_split_anchor_program {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) :
    ∃states : ℕ→CanonicalProgramState d,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (∀j≤H,(states j).physicalAnchorInvariant P S j) ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      ∀j<H,PhysicalEntropySplitStep P S j (states j) (states (j+1)) := by
  classical
  let initial : CanonicalProgramState d := {Index:=Fin (d+1),feature:=normalizedInputFeature d}
  let State := fun n=>{B:CanonicalProgramState d // n≤H→
    B.physicalAnchorInvariant P S n ∧B.dimension≤d+1+n*(S.card+1)}
  have hstep : ∀n,n<H→∀s:State n,∃s':State (n+1),
      PhysicalEntropySplitStep P S n s.val s'.val := by
    intro n hn s
    have hgood := s.property (Nat.le_of_lt hn)
    obtain ⟨C,hC,hCa,hCd⟩ := physical_entropy_split_step_exists P S n hn s.val hgood.1
    have hdim : C.dimension≤d+1+(n+1)*(S.card+1) := by
      have hb := hgood.2
      simp only [Nat.add_mul,Nat.one_mul]
      omega
    exact ⟨⟨C,fun _=>⟨hCa,hdim⟩⟩,hC⟩
  let step := fun n (s:State n)=>if hn:n<H then Classical.choose (hstep n hn s)
    else (⟨initial,by intro h;omega⟩:State (n+1))
  have step_spec (n:ℕ) (hn:n<H) (s:State n) :
      PhysicalEntropySplitStep P S n s.val (step n s).val := by
    simpa only [step,dif_pos hn] using Classical.choose_spec (hstep n hn s)
  let s0 : State 0 := ⟨initial,by
    intro _
    constructor
    · intro x hx y hy
      exact (P.initial x y).symm
    · simp only [CanonicalProgramState.dimension,initial,Fintype.card_fin,Nat.zero_mul,Nat.add_zero,le_refl]⟩
  let states : (n:ℕ)→State n := fun n=>Nat.rec s0 (fun n s=>step n s) n
  refine ⟨fun n=>(states n).val,?_,?_,?_,?_⟩
  · intro x y
    rfl
  · intro j hj
    exact ((states j).property hj).1
  · intro j hj
    exact ((states j).property hj).2
  · intro j hj
    exact step_spec j hj (states j)

#print axioms physical_entropy_split_anchor_program
end ConditionalNonpolynomial.Analytic
