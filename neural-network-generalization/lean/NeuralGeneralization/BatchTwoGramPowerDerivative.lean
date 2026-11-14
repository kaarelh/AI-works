import NeuralGeneralization.BatchTwoGramPowerMoments
import Mathlib.Analysis.Calculus.MeanValue

/-! Exact derivatives of finite matrix-power potentials under rank-one subtraction. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Matrix Matrix.Norms.Operator
namespace NeuralGeneralization.BatchTwoGramPower
open Matrix
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def quadraticLinear (u : ι→ℝ) : Matrix ι ι ℝ →ₗ[ℝ] ℝ where
  toFun A := u ⬝ᵥ (A *ᵥ u)
  map_add' A B := by simp [Matrix.add_mulVec,dotProduct_add]
  map_smul' c A := by simp [Matrix.smul_mulVec,dotProduct_smul]

theorem quadratic_rankOne (A : Matrix ι ι ℝ) (u : ι→ℝ) (j k : ℕ) :
    quadraticLinear u (A^j*vecMulVec u u*A^k)=powerMoment A u j*powerMoment A u k := by
  change u ⬝ᵥ ((A^j*vecMulVec u u*A^k) *ᵥ u)=_
  rw [←Matrix.mulVec_mulVec,←Matrix.mulVec_mulVec,Matrix.vecMulVec_mulVec,
    Matrix.mulVec_smul,dotProduct_smul]
  unfold powerMoment
  simp only [op_smul_eq_smul,smul_eq_mul]
  ring

theorem trace_rankOne (A : Matrix ι ι ℝ) (u : ι→ℝ) (j k : ℕ) :
    Matrix.trace (A^j*vecMulVec u u*A^k)=powerMoment A u (j+k) := by
  rw [Matrix.trace_mul_cycle,←pow_add,Matrix.trace_mul_comm,
    Matrix.vecMulVec_mul,Matrix.trace_vecMulVec]
  unfold powerMoment
  rw [Matrix.dotProduct_mulVec,dotProduct_comm,Nat.add_comm]

def rankOnePath (A : Matrix ι ι ℝ) (u : ι→ℝ) (t : ℝ) : Matrix ι ι ℝ := A-t • vecMulVec u u

theorem hasDerivAt_rankOnePath (A : Matrix ι ι ℝ) (u : ι→ℝ) (t : ℝ) :
    HasDerivAt (rankOnePath A u) (-vecMulVec u u) t := by
  simpa only [rankOnePath,Pi.sub_apply,id_eq,zero_sub,one_smul] using!
    (hasDerivAt_const t A).sub ((hasDerivAt_id t).smul_const (vecMulVec u u))

theorem hasDerivAt_powerMoment_path (A : Matrix ι ι ℝ) (u : ι→ℝ) (p : ℕ) (t : ℝ) :
    HasDerivAt (fun s=>powerMoment (rankOnePath A u s) u p)
      (-(∑j∈Finset.range p,powerMoment (rankOnePath A u t) u (p-1-j)*
        powerMoment (rankOnePath A u t) u j)) t := by
  have hh := (quadraticLinear u).toContinuousLinearMap.hasFDerivAt.comp_hasDerivAt t
    ((hasDerivAt_rankOnePath A u t).fun_pow' p)
  change HasDerivAt (fun s=>powerMoment (rankOnePath A u s) u p)
    (quadraticLinear u (∑j∈Finset.range p,rankOnePath A u t^(p.pred-j)*
      (-vecMulVec u u)*rankOnePath A u t^j)) t at hh
  simpa only [Nat.pred_eq_sub_one,map_sum,mul_neg,neg_mul,map_neg,
    quadratic_rankOne,Finset.sum_neg_distrib] using hh

theorem hasDerivAt_trace_power_path (A : Matrix ι ι ℝ) (u : ι→ℝ) (p : ℕ) (t : ℝ) :
    HasDerivAt (fun s=>Matrix.trace (rankOnePath A u s^p))
      (-(p:ℝ)*powerMoment (rankOnePath A u t) u (p-1)) t := by
  have hh := (Matrix.traceLinearMap ι ℝ ℝ).toContinuousLinearMap.hasFDerivAt.comp_hasDerivAt t
    ((hasDerivAt_rankOnePath A u t).fun_pow' p)
  change HasDerivAt (fun s=>Matrix.trace (rankOnePath A u s^p))
    (Matrix.trace (∑j∈Finset.range p,rankOnePath A u t^(p.pred-j)*
      (-vecMulVec u u)*rankOnePath A u t^j)) t at hh
  have he : Matrix.trace (∑j∈Finset.range p,rankOnePath A u t^(p.pred-j)*
      (-vecMulVec u u)*rankOnePath A u t^j)=-(p:ℝ)*powerMoment (rankOnePath A u t) u (p-1) := by
    simp only [Matrix.trace_sum,mul_neg,neg_mul,Matrix.trace_neg,trace_rankOne]
    have ht : (∑j∈Finset.range p,-powerMoment (rankOnePath A u t) u (p.pred-j+j))=
        ∑_j∈Finset.range p,-powerMoment (rankOnePath A u t) u (p-1) := by
      apply Finset.sum_congr rfl
      intro j hj
      have hj' := Finset.mem_range.mp hj
      rw [show p.pred-j+j=p-1 by simp only [Nat.pred_eq_sub_one]; omega]
    rw [ht]
    simp
  rwa [he] at hh

end NeuralGeneralization.BatchTwoGramPower
