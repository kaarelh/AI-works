import NeuralGeneralization.OnlineLowerTanhResidualCompactUniform

/-! # The finite, compact-uniform residual theorem at every derivative order -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- The literal finite arrays in the residual-CLT statement, with no
asymptotic or approximation field. -/
structure ResidualSample (ι:Type*) [Fintype ι] [DecidableEq ι]
    (q:ι→ℕ) (α lo hi K:ℝ) where
  N : ℕ
  N_pos : 0<N
  label : Fin N→ι
  freq : ∀t,α*(N:ℝ)≤((Finset.univ.filter (fun i=>label i=t)).card:ℝ)
  A : ℝ
  A_lo : lo≤A
  A_hi : A≤hi
  d : Fin N→ℝ
  orthogonal : ∑i,(q (label i):ℝ)*d i=0
  energy_bound : (∑i,(d i)^2)≤K

namespace ResidualSample
variable {ι:Type*} [Fintype ι] [DecidableEq ι]
variable {q:ι→ℕ} {α lo hi K:ℝ} (P:ResidualSample ι q α lo hi K)
def alphabet:Fin P.N→ℕ:=fun i=>q (P.label i)
def incoming:Fin P.N→ℝ:=fun i=>P.A*(P.alphabet i:ℝ)+P.d i

def fullDerivativeError (j:ℕ) (b:ℝ):ℝ:=
  Real.sqrt (residualVariance P.alphabet)*
    |iteratedDeriv j (parityCorrelation P.incoming) b-
      iteratedDeriv j (residualLeading P.alphabet P.d P.A) b|
end ResidualSample

/-- Uniformity is simultaneous in the dimension, alphabet frequencies,
gain in any fixed positive compact interval, residual energy bounded by K,
and every unbounded real external bias. The complete Gaussian-periodic
leading expression is differentiated at any fixed order j. -/
theorem residual_uniform_derivative_estimate
    {ι:Type*} [Fintype ι] [DecidableEq ι]
    (q:ι→ℕ) (c:ι→ℤ) (hq:∀i,Odd (q i)) (hc:∑i,c i*(q i:ℤ)=1)
    {α Q lo hi K:ℝ} (hα:0<α) (hQ:0<Q) (hlo:0<lo) (hK:0≤K)
    (hqQ:∀i,(q i:ℝ)≤Q) (j:ℕ) :
    ∀ε>0,∃N₀:ℕ,∃δ:ℝ,0<δ ∧
      ∀P:ResidualSample ι q α lo hi K,N₀≤P.N→
        (∀i,|P.d i|≤δ)→∀b:ℝ,P.fullDerivativeError j b<ε := by
  intro ε hε
  by_contra hn
  push_neg at hn
  have hbad (k:ℕ):∃P:ResidualSample ι q α lo hi K,
      k+1≤P.N ∧ (∀i,|P.d i|≤((k:ℝ)+1)⁻¹) ∧
        ∃b:ℝ,ε≤P.fullDerivativeError j b := by
    exact hn (k+1) ((k:ℝ)+1)⁻¹ (by positivity)
  choose P hPN hPd b hb using hbad
  have hN:Tendsto (fun k=>(P k).N) atTop atTop :=
    tendsto_atTop_mono (fun k=>(Nat.le_succ k).trans (hPN k)) tendsto_id
  have hD:Tendsto (fun k:ℕ=>((k:ℝ)+1)⁻¹) atTop (𝓝 0) :=
    tendsto_inv_atTop_zero.comp (tendsto_atTop_add_const_right atTop 1 tendsto_natCast_atTop_atTop)
  let S:ResidualCompactSequence ι := {
    N := fun k=>(P k).N
    N_pos := fun k=>(P k).N_pos
    N_tendsto := hN
    label := fun k=>(P k).label
    q := q
    q_odd := hq
    c := c
    bezout := hc
    α := α
    Q := Q
    lo := lo
    hi := hi
    K := K
    α_pos := hα
    Q_pos := hQ
    lo_pos := hlo
    K_nonneg := hK
    freq := fun k=>(P k).freq
    q_bound := hqQ
    A := fun k=>(P k).A
    D := fun k=>((k:ℝ)+1)⁻¹
    A_lo := fun k=>(P k).A_lo
    A_hi := fun k=>(P k).A_hi
    D_tendsto := hD
    d := fun k=>(P k).d
    d_bound := hPd
    orthogonal := fun k=>(P k).orthogonal
    energy_bound := fun k=>(P k).energy_bound }
  obtain ⟨k,hk⟩:=(S.uniform_full_derivatives j ε hε).exists
  have hh:=hk (b k)
  change (P k).fullDerivativeError j (b k)<ε at hh
  exact (not_lt_of_ge (hb k)) hh

end NeuralGeneralization.OnlineLowerTanh
