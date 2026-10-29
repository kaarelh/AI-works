import AffineGridCircuit
import Mathlib.Analysis.InnerProductSpace.PiL2

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ : Type*} [Fintype ι] [Fintype κ]

def linearCoefficients (T : EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ κ) (j : κ) (i : ι) : ℝ :=
  T (EuclideanSpace.basisFun ι ℝ i) j

theorem linearCoefficients_bound (T : EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ κ)
    (j : κ) (i : ι) : |linearCoefficients T j i|≤‖T‖ := by
  have hh := (PiLp.norm_apply_le (T (EuclideanSpace.basisFun ι ℝ i)) j).trans
    (T.le_opNorm (EuclideanSpace.basisFun ι ℝ i))
  simpa only [linearCoefficients,Real.norm_eq_abs,(EuclideanSpace.basisFun ι ℝ).norm_eq_one,mul_one] using hh

theorem linearCoefficients_eval (T : EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ κ)
    (x : EuclideanSpace ℝ ι) (j : κ) : (∑i,linearCoefficients T j i*x i)=T x j := by
  have hx : (∑i,x i • EuclideanSpace.basisFun ι ℝ i)=x := by
    simpa only [EuclideanSpace.basisFun_repr] using (EuclideanSpace.basisFun ι ℝ).sum_repr x
  have hh := congrArg (fun v:EuclideanSpace ℝ κ=>v j) (congrArg T hx)
  simpa only [map_sum,map_smul,WithLp.ofLp_sum,Finset.sum_apply,PiLp.smul_apply,smul_eq_mul,linearCoefficients,mul_comm] using hh

#print axioms linearCoefficients_eval
#print axioms linearCoefficients_bound
end ConditionalNonpolynomial.AnalyticLookup
