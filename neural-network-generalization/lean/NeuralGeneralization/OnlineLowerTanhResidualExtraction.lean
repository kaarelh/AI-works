import NeuralGeneralization.OnlineLowerTanhResidualCLT
import Mathlib.Topology.Sequences

/-! # Subsequence extraction for literal residual arrays

This module only organizes eventual elementary bounds and bounded residual
energy. The central-limit conclusion is supplied by the proved residual CLT.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

structure ResidualPresequence (ι : Type*) [Fintype ι] [DecidableEq ι] where
  N : ℕ → ℕ
  N_tendsto : Tendsto N atTop atTop
  label : (k : ℕ) → Fin (N k) → ι
  q : ι → ℕ
  q_odd : ∀ j, Odd (q j)
  c : ι → ℤ
  bezout : ∑ j,c j*(q j:ℤ)=1
  α : ℝ
  Q : ℝ
  K : ℝ
  α_pos : 0 < α
  Q_pos : 0 < Q
  K_nonneg : 0 ≤ K
  freq : ∀ᶠ k in atTop, ∀ j, α*(N k:ℝ) ≤ ((Finset.univ.filter (fun i => label k i=j)).card:ℝ)
  q_bound : ∀ j,(q j:ℝ) ≤ Q
  A : ℕ → ℝ
  D : ℕ → ℝ
  A₀ : ℝ
  A₀_pos : 0 < A₀
  A_tendsto : Tendsto A atTop (𝓝 A₀)
  D_tendsto : Tendsto D atTop (𝓝 0)
  d : (k : ℕ) → Fin (N k) → ℝ
  d_bound : ∀ᶠ k in atTop, ∀ i,|d k i| ≤ D k
  orthogonal : ∀ k,∑ i,(q (label k i):ℝ)*d k i=0
  energy_bound : ∀ k,(∑ i,(d k i)^2) ≤ K

namespace ResidualPresequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (P : ResidualPresequence ι)

def incoming (k : ℕ) : Fin (P.N k) → ℝ :=
  fun i => P.A k*(P.q (P.label k i):ℝ)+P.d k i

structure Refinement (φ : ℕ → ℕ) (E : ℝ) : Prop where
  strictMono : StrictMono φ
  N_pos : ∀ k,0 < P.N (φ k)
  freq : ∀ k j,P.α*(P.N (φ k):ℝ) ≤ ((Finset.univ.filter (fun i => P.label (φ k) i=j)).card:ℝ)
  A_lo : ∀ k,P.A₀/2 ≤ P.A (φ k)
  A_hi : ∀ k,P.A (φ k) ≤ 2*P.A₀
  d_bound : ∀ k i,|P.d (φ k) i| ≤ P.D (φ k)
  energy_tendsto : Tendsto (fun k => ∑ i,(P.d (φ k) i)^2) atTop (𝓝 E)

/-- All elementary bounds hold on a common subsequence, and the bounded
literal residual energy converges there. -/
theorem exists_refinement : ∃ φ : ℕ → ℕ, ∃ E : ℝ, P.Refinement φ E := by
  have hN : ∀ᶠ k in atTop,0 < P.N k :=
    P.N_tendsto.eventually (eventually_gt_atTop 0)
  have hlo : ∀ᶠ k in atTop,P.A₀/2 ≤ P.A k :=
    (P.A_tendsto.eventually (lt_mem_nhds (by linarith [P.A₀_pos]))).mono (fun _ h => h.le)
  have hhi : ∀ᶠ k in atTop,P.A k ≤ 2*P.A₀ :=
    (P.A_tendsto.eventually (gt_mem_nhds (by linarith [P.A₀_pos]))).mono (fun _ h => h.le)
  obtain ⟨k₀,hk₀⟩ := eventually_atTop.mp (hN.and (P.freq.and (hlo.and (hhi.and P.d_bound))))
  have hmem (k : ℕ) : (∑ i,(P.d (k+k₀) i)^2) ∈ Icc (0:ℝ) P.K :=
    ⟨Finset.sum_nonneg (fun _ _ => sq_nonneg _),P.energy_bound _⟩
  obtain ⟨E,hE,ψ,hψ,hconv⟩ := (isCompact_Icc : IsCompact (Icc (0:ℝ) P.K)).tendsto_subseq hmem
  let φ : ℕ → ℕ := fun k => ψ k+k₀
  have hφ : StrictMono φ := fun a b hab => Nat.add_lt_add_right (hψ hab) _
  refine ⟨φ,E,{ strictMono := hφ, N_pos := ?_, freq := ?_, A_lo := ?_, A_hi := ?_, d_bound := ?_, energy_tendsto := hconv }⟩
  · intro k; exact (hk₀ (φ k) (by dsimp [φ]; omega)).1
  · intro k; exact (hk₀ (φ k) (by dsimp [φ]; omega)).2.1
  · intro k; exact (hk₀ (φ k) (by dsimp [φ]; omega)).2.2.1
  · intro k; exact (hk₀ (φ k) (by dsimp [φ]; omega)).2.2.2.1
  · intro k; exact (hk₀ (φ k) (by dsimp [φ]; omega)).2.2.2.2

/-- This constructor retains the exact arrays by definition. In particular
its incoming vector is literally `P.incoming (φ k)`. -/
def toResidualSequence (φ : ℕ → ℕ) (E : ℝ) (h : P.Refinement φ E) : ResidualSequence ι where
  N := fun k => P.N (φ k)
  N_pos := h.N_pos
  N_tendsto := P.N_tendsto.comp h.strictMono.tendsto_atTop
  label := fun k => P.label (φ k)
  q := P.q
  q_odd := P.q_odd
  c := P.c
  bezout := P.bezout
  α := P.α
  Q := P.Q
  lo := P.A₀/2
  hi := 2*P.A₀
  K := P.K
  α_pos := P.α_pos
  Q_pos := P.Q_pos
  lo_pos := by linarith [P.A₀_pos]
  K_nonneg := P.K_nonneg
  freq := h.freq
  q_bound := P.q_bound
  A := fun k => P.A (φ k)
  D := fun k => P.D (φ k)
  A₀ := P.A₀
  E := E
  A_lo := h.A_lo
  A_hi := h.A_hi
  A₀_lo := by linarith [P.A₀_pos]
  A₀_hi := by linarith [P.A₀_pos]
  A_tendsto := P.A_tendsto.comp h.strictMono.tendsto_atTop
  D_tendsto := P.D_tendsto.comp h.strictMono.tendsto_atTop
  d := fun k => P.d (φ k)
  d_bound := h.d_bound
  orthogonal := fun k => P.orthogonal (φ k)
  energy_tendsto := h.energy_tendsto
  energy_bound := fun k => P.energy_bound (φ k)

@[simp] lemma toResidualSequence_incoming (φ : ℕ → ℕ) (E : ℝ) (h : P.Refinement φ E) (k : ℕ) :
    (P.toResidualSequence φ E h).incoming k=P.incoming (φ k) := rfl


/-- The stored compact upper gain bound can be chosen arbitrarily close to
the positive limiting gain, after discarding finitely many terms. -/
theorem exists_refinement_below (H : ℝ) (hH : P.A₀ < H) :
    ∃ φ : ℕ → ℕ, ∃ E : ℝ, ∃ h : P.Refinement φ E, ∀ k,P.A (φ k) ≤ H := by
  obtain ⟨φ,E,hφ⟩ := P.exists_refinement
  have ht := P.A_tendsto.comp hφ.strictMono.tendsto_atTop
  obtain ⟨k₀,hk₀⟩ := eventually_atTop.mp (ht.eventually (gt_mem_nhds hH))
  let ψ : ℕ → ℕ := fun k => φ (k+k₀)
  have hs : StrictMono (fun k : ℕ => k+k₀) := fun _ _ hab => Nat.add_lt_add_right hab _
  have hψ : P.Refinement ψ E := {
    strictMono := hφ.strictMono.comp hs
    N_pos := fun k => hφ.N_pos (k+k₀)
    freq := fun k => hφ.freq (k+k₀)
    A_lo := fun k => hφ.A_lo (k+k₀)
    A_hi := fun k => hφ.A_hi (k+k₀)
    d_bound := fun k => hφ.d_bound (k+k₀)
    energy_tendsto := hφ.energy_tendsto.comp hs.tendsto_atTop }
  exact ⟨ψ,E,hψ,fun k => (hk₀ (k+k₀) (by omega)).le⟩

def toResidualSequenceWithUpper (φ : ℕ → ℕ) (E H : ℝ)
    (h : P.Refinement φ E) (hH : P.A₀ ≤ H) (hupper : ∀ k,P.A (φ k) ≤ H) :
    ResidualSequence ι :=
  { P.toResidualSequence φ E h with hi := H, A_hi := hupper, A₀_hi := hH }

@[simp] lemma toResidualSequenceWithUpper_incoming (φ : ℕ → ℕ) (E H : ℝ)
    (h : P.Refinement φ E) (hH : P.A₀ ≤ H) (hupper : ∀ k,P.A (φ k) ≤ H) (k : ℕ) :
    (P.toResidualSequenceWithUpper φ E H h hH hupper).incoming k=P.incoming (φ k) := rfl

end ResidualPresequence
end NeuralGeneralization.OnlineLowerTanh
