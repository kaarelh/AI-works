import CanonicalQueryStep
import CanonicalAnchorProgram

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianFieldTilt

def criticalLayerCost {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (j : ℕ) : ℝ :=
  (klDiv (P.law j) (fieldLaw (fun x i => P.feature j x i))).toReal

def canonicalQueryError {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (δ : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | j+1 => Real.sqrt (8*Real.sqrt (δ j))+
      (1+Real.sqrt (2*criticalLayerCost P j))*canonicalQueryError P δ j

lemma canonicalQueryError_nonneg {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (δ : ℕ → ℝ) (j : ℕ) :
    0≤canonicalQueryError P δ j := by
  induction j with
  | zero => exact le_rfl
  | succ j ih => simp only [canonicalQueryError]; positivity

/-- Exact canonical path construction with genuine query couplings. At each
depth, the approximation retains the anchor block but is not required to
retain the entire original covariance kernel. -/
theorem critical_canonical_query_program {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d)) (δ : ℕ → ℝ)
    (hδ : ∀j<H,0<δ j)
    (hgap : ∀j<H,∀x,coordinateEntropy (P.law j) (fieldLaw (fun x i => P.feature j x i))
        (insert x S)-coordinateEntropy (P.law j) (fieldLaw (fun x i => P.feature j x i)) S≤δ j) :
    ∃states : ℕ → CanonicalProgramState d,
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (∀j≤H,(states j).anchorInvariant P S j) ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      (∀j<H,CanonicalProgramStep P S j (states j) (states (j+1))) ∧
      ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x
        (canonicalQueryError P δ j) := by
  obtain ⟨states,hidx,hzero,hanchor,hdim,hstep⟩ := critical_canonical_anchor_program P S
  refine ⟨states,hzero,hanchor,hdim,hstep,?_⟩
  intro j
  induction j with
  | zero =>
    intro hj x
    apply queryFeatureClose_of_gram_eq
    intro u v
    exact (P.initial u v).trans (hzero u v).symm
  | succ j ih =>
    intro hj x
    have hjlt : j<H := by omega
    letI := P.probability j hjlt
    have hcoeff : scaledFeatureCoefficients 1 (P.feature j)=(fun x i => P.feature j x i) := by
      funext x i
      exact one_mul _
    have hfinite : klDiv (P.law j) (fieldLaw (fun x i => P.feature j x i))≠∞ := by
      have hh := P.finiteKL j hjlt
      rwa [hcoeff] at hh
    exact actual_canonical_query_step (P.feature j) (states j).feature
      (P.feature (j+1)) (states (j+1)).feature (P.law j) hfinite S x
      (canonicalQueryError_nonneg P δ j) (hδ j hjlt) (ih (by omega) x)
      (hgap j hjlt x) (P.recursion j hjlt) ((hstep j hjlt).queryMoments x)

/-- The query approximation loses the exponential of the square-root entropy
sum, not a fixed factor at every layer. -/
theorem canonicalQueryError_bound {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (δ : ℕ → ℝ) (n : ℕ) :
    canonicalQueryError P δ n ≤
      (∑j∈Finset.range n,Real.sqrt (8*Real.sqrt (δ j)))*
      Real.exp (∑j∈Finset.range n,Real.sqrt (2*criticalLayerCost P j)) := by
  induction n with
  | zero => simp [canonicalQueryError]
  | succ n ih =>
    let a := Real.sqrt (8*Real.sqrt (δ n))
    let b := Real.sqrt (2*criticalLayerCost P n)
    let A := ∑j∈Finset.range n,Real.sqrt (8*Real.sqrt (δ j))
    let B := ∑j∈Finset.range n,Real.sqrt (2*criticalLayerCost P j)
    have ha : 0≤a := Real.sqrt_nonneg _
    have hb : 0≤b := Real.sqrt_nonneg _
    have hA : 0≤A := Finset.sum_nonneg fun j _ => Real.sqrt_nonneg _
    have hB : 0≤B := Finset.sum_nonneg fun j _ => Real.sqrt_nonneg _
    have hgain : 1+b≤Real.exp b := by linarith [Real.add_one_le_exp b]
    have hexp : 1≤Real.exp (B+b) := Real.one_le_exp (by positivity)
    have hrec : canonicalQueryError P δ (n+1)=a+(1+b)*canonicalQueryError P δ n := rfl
    rw [hrec,Finset.sum_range_succ,Finset.sum_range_succ]
    change a+(1+b)*canonicalQueryError P δ n≤(A+a)*Real.exp (B+b)
    calc
      _ ≤ a+(1+b)*(A*Real.exp B) :=
        add_le_add le_rfl (mul_le_mul_of_nonneg_left ih (show 0≤1+b by linarith))
      _ ≤ a+Real.exp b*(A*Real.exp B) :=
        add_le_add le_rfl (mul_le_mul_of_nonneg_right hgain (mul_nonneg hA (Real.exp_pos B).le))
      _ ≤ a*Real.exp (B+b)+Real.exp b*(A*Real.exp B) := by
        have hh := mul_le_mul_of_nonneg_left hexp ha
        nlinarith
      _ = (A+a)*Real.exp (B+b) := by rw [Real.exp_add]; ring

#print axioms critical_canonical_query_program
#print axioms canonicalQueryError_bound
end ConditionalNonpolynomial.Analytic
