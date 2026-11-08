import NeuralGeneralization.OnlineLowerTanhPairVariation
import NeuralGeneralization.OnlineLowerTanhHamming
import NeuralGeneralization.TanhSaturation

/-! Exact localized-kernel representation of a biased equal-weight tanh neuron. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu

def bulkKernel (a x:ℝ) : ℝ := (Real.tanh (x+a)-Real.tanh (x-a))/2
def equalBulk (n:ℕ) (a b:ℝ) : ℝ := parityCorrelation (fun _:Fin n=>a) b

lemma bulkKernel_even (a x:ℝ) : bulkKernel a (-x)=bulkKernel a x := by
  unfold bulkKernel
  rw [show -x+a=-(x-a) by ring,show -x-a=-(x+a) by ring,
    Real.tanh_neg,Real.tanh_neg]
  ring

lemma bulkKernel_pos (a x:ℝ) (ha:0<a) : 0<bulkKernel a x := by
  have ht : StrictMono Real.tanh := strictMono_of_hasDerivAt_pos
    ConcreteModel.hasDerivAt_tanh (fun x=>by positivity)
  have hh:=ht (show x-a<x+a by linarith)
  unfold bulkKernel
  linarith

lemma bulkKernel_le_one (a x:ℝ) : bulkKernel a x≤1 := by
  have h1:=Real.tanh_lt_one (x+a)
  have h2:=Real.neg_one_lt_tanh (x-a)
  unfold bulkKernel
  linarith

lemma bulkKernel_tail (a x:ℝ) (ha:0<a) :
    |bulkKernel a x|≤Real.exp (2*a)*Real.exp (-2*|x|) := by
  have hpos (x:ℝ) : bulkKernel a x≤Real.exp (-2*(x-a)) := by
    have ht:=Real.tanh_lt_one (x+a)
    have he:=Real.exp_pos (2*(x-a))
    have hh : (1:ℝ)/(Real.exp (2*(x-a))+1)≤(Real.exp (2*(x-a)))⁻¹ := by
      rw [←one_div]
      exact div_le_div_of_nonneg_left (by norm_num) he (by linarith)
    rw [←Real.exp_neg] at hh
    unfold bulkKernel
    rw [TanhSaturation.tanh_exp_formula (x-a)]
    rw [show -(2*(x-a))=-2*(x-a) by ring] at hh
    simp only [div_eq_mul_inv] at *
    linarith
  rw [abs_of_pos (bulkKernel_pos a x ha)]
  by_cases hx:0≤x
  · rw [abs_of_nonneg hx]
    have he : Real.exp (-2*(x-a))=Real.exp (2*a)*Real.exp (-2*x) := by
      rw [←Real.exp_add]; congr 1; ring
    exact (hpos x).trans_eq he
  · have hx':x≤0 := le_of_not_ge hx
    rw [abs_of_nonpos hx',←bulkKernel_even a x]
    have he : Real.exp (-2*(-x-a))=Real.exp (2*a)*Real.exp (-2*(-x)) := by
      rw [←Real.exp_add]; congr 1; ring
    exact (hpos (-x)).trans_eq he

/-- One finite difference turns the unbounded-support sigmoid into an
exponentially localized positive kernel. -/
theorem equalBulk_localized (n:ℕ) (a b:ℝ) :
    equalBulk (n+1) a b=ridgeParity (bulkKernel a) (fun _:Fin n=>a) b := by
  unfold equalBulk
  rw [←ridgeParity_tanh,ridgeParity_succ]
  rfl

theorem ridgeParity_constant_hamming (f:ℝ→ℝ) (n:ℕ) (a b:ℝ) :
    ridgeParity f (fun _:Fin n=>a) b=
      (1:ℝ)/2^n*∑j∈Finset.range (n+1),(-1:ℝ)^j*(n.choose j:ℝ)*f (b+a*((n:ℝ)-2*j)) := by
  unfold ridgeParity cubeMean
  rw [←Equiv.sum_comp (negativeSetEquiv n).symm]
  have hp (S:Finset (Fin n)) :
      paritySign ((negativeSetEquiv n).symm S)=(-1:ℝ)^S.card :=
    negativeSet_full_parity n S
  have hs (S:Finset (Fin n)) :
      incomingLinear (fun _:Fin n=>a) ((negativeSetEquiv n).symm S)=a*((n:ℝ)-2*S.card) := by
    rw [incomingLinear_constant]
    have hh:=negativeSet_sum_signs n S
    exact congrArg (fun x=>a*x) hh
  simp_rw [hp,hs]
  rw [subset_parity_sum_eq_alternatingBinomial n (fun j=>f (b+a*((n:ℝ)-2*j)))]
  simp only [alternatingBinomial,Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,
    Nat.cast_pow,Nat.cast_ofNat,one_div]

/-- The exact binomial-kernel representation, valid in both parity classes
and for every bias, before any asymptotic estimate. -/
theorem equalBulk_binomial_kernel (n:ℕ) (a b:ℝ) :
    equalBulk (n+1) a b=
      (1:ℝ)/2^n*∑j∈Finset.range (n+1),(-1:ℝ)^j*(n.choose j:ℝ)*
        bulkKernel a (b+a*((n:ℝ)-2*j)) := by
  rw [equalBulk_localized,ridgeParity_constant_hamming]

end NeuralGeneralization.OnlineLowerTanh
