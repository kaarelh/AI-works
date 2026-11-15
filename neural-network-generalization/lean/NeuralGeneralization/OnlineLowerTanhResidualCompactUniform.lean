import NeuralGeneralization.OnlineLowerTanhResidualEnvelopeCorrection
import Mathlib.Topology.Sequences

/-! # Compact-family residual asymptotics without convergent gains or energies -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

structure ResidualCompactSequence (ι:Type*) [Fintype ι] [DecidableEq ι] where
  N : ℕ→ℕ
  N_pos : ∀ k,0<N k
  N_tendsto : Tendsto N atTop atTop
  label : (k:ℕ)→Fin (N k)→ι
  q : ι→ℕ
  q_odd : ∀i,Odd (q i)
  c : ι→ℤ
  bezout : ∑i,c i*(q i:ℤ)=1
  α : ℝ
  Q : ℝ
  lo : ℝ
  hi : ℝ
  K : ℝ
  α_pos : 0<α
  Q_pos : 0<Q
  lo_pos : 0<lo
  K_nonneg : 0≤K
  freq : ∀ k t,α*(N k:ℝ)≤((Finset.univ.filter (fun i=>label k i=t)).card:ℝ)
  q_bound : ∀i,(q i:ℝ)≤Q
  A : ℕ→ℝ
  D : ℕ→ℝ
  A_lo : ∀k,lo≤A k
  A_hi : ∀k,A k≤hi
  D_tendsto : Tendsto D atTop (𝓝 0)
  d : (k:ℕ)→Fin (N k)→ℝ
  d_bound : ∀k i,|d k i|≤D k
  orthogonal : ∀k,∑i,(q (label k i):ℝ)*d k i=0
  energy_bound : ∀k,(∑i,(d k i)^2)≤K

namespace ResidualCompactSequence
variable {ι:Type*} [Fintype ι] [DecidableEq ι] (P:ResidualCompactSequence ι)
def alphabet (k:ℕ):Fin (P.N k)→ℕ:=fun i=>P.q (P.label k i)
def incoming (k:ℕ):Fin (P.N k)→ℝ:=fun i=>P.A k*(P.alphabet k i:ℝ)+P.d k i

def fullDerivativeError (j k:ℕ) (b:ℝ):ℝ:=
  Real.sqrt (residualVariance (P.alphabet k))*
    |iteratedDeriv j (parityCorrelation (P.incoming k)) b-
      iteratedDeriv j (residualLeading (P.alphabet k) (P.d k) (P.A k)) b|

/-- Gains and residual energies need only stay in the displayed compact
sets. No convergence of either parameter is required. -/
theorem uniform_full_derivatives (j:ℕ) :
    ∀ ε>0,∀ᶠk in atTop,∀b:ℝ,P.fullDerivativeError j k b<ε := by
  intro ε hε
  by_contra hbad
  have hcounter : ∀K:ℕ,∃k:ℕ,K≤k ∧ ∃b:ℝ,ε≤P.fullDerivativeError j k b := by
    simpa only [eventually_atTop,not_exists,not_forall,not_lt,exists_prop] using hbad
  choose φ hφ b hb using hcounter
  have hφt:Tendsto φ atTop atTop:=tendsto_atTop_mono hφ tendsto_id
  have hA (k:ℕ):P.A (φ k)∈Icc P.lo P.hi:=⟨P.A_lo _,P.A_hi _⟩
  obtain ⟨a₀,ha₀,ψ,hψ,hAt⟩:=
    (isCompact_Icc:IsCompact (Icc P.lo P.hi)).tendsto_subseq hA
  have hE (k:ℕ):(∑i,(P.d (φ (ψ k)) i)^2)∈Icc (0:ℝ) P.K:=
    ⟨Finset.sum_nonneg (fun _ _=>sq_nonneg _),P.energy_bound _⟩
  obtain ⟨E,hE,θ,hθ,hEt⟩:=
    (isCompact_Icc:IsCompact (Icc (0:ℝ) P.K)).tendsto_subseq hE
  let ρ:ℕ→ℕ:=fun k=>φ (ψ (θ k))
  have hρ:Tendsto ρ atTop atTop:=hφt.comp (hψ.tendsto_atTop.comp hθ.tendsto_atTop)
  let S:ResidualSequence ι := {
    N := fun k=>P.N (ρ k)
    N_pos := fun k=>P.N_pos _
    N_tendsto := P.N_tendsto.comp hρ
    label := fun k=>P.label (ρ k)
    q := P.q
    q_odd := P.q_odd
    c := P.c
    bezout := P.bezout
    α := P.α
    Q := P.Q
    lo := P.lo
    hi := P.hi
    K := P.K
    α_pos := P.α_pos
    Q_pos := P.Q_pos
    lo_pos := P.lo_pos
    K_nonneg := P.K_nonneg
    freq := fun k=>P.freq (ρ k)
    q_bound := P.q_bound
    A := fun k=>P.A (ρ k)
    D := fun k=>P.D (ρ k)
    A₀ := a₀
    E := E
    A_lo := fun k=>P.A_lo _
    A_hi := fun k=>P.A_hi _
    A₀_lo := ha₀.1
    A₀_hi := ha₀.2
    A_tendsto := hAt.comp hθ.tendsto_atTop
    D_tendsto := P.D_tendsto.comp hρ
    d := fun k=>P.d (ρ k)
    d_bound := fun k=>P.d_bound _
    orthogonal := fun k=>P.orthogonal _
    energy_tendsto := hEt
    energy_bound := fun k=>P.energy_bound _ }
  obtain ⟨k,hk⟩:=(S.uniform_residual_full_derivatives j ε hε).exists
  have hh:=hk (b (ψ (θ k)))
  have hn:=hb (ψ (θ k))
  change P.fullDerivativeError j (φ (ψ (θ k))) (b (ψ (θ k)))<ε at hh
  exact (not_lt_of_ge hn) hh

end ResidualCompactSequence
end NeuralGeneralization.OnlineLowerTanh
