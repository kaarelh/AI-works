import NeuralGeneralization.OnlineLowerTanhResidualFinite

/-! # Literal data for a finite odd-alphabet residual sequence

The structure records dimensions, incoming weights, and their elementary
moment/frequency hypotheses. Its conclusions are proved from these actual
arrays; no central-limit or approximation premise is included.
-/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

structure ResidualSequence (ι : Type*) [Fintype ι] [DecidableEq ι] where
  N : ℕ → ℕ
  N_pos : ∀ k, 0 < N k
  N_tendsto : Tendsto N atTop atTop
  label : (k : ℕ) → Fin (N k) → ι
  q : ι → ℕ
  q_odd : ∀ i, Odd (q i)
  c : ι → ℤ
  bezout : ∑ i, c i*(q i:ℤ) = 1
  α : ℝ
  Q : ℝ
  lo : ℝ
  hi : ℝ
  K : ℝ
  α_pos : 0 < α
  Q_pos : 0 < Q
  lo_pos : 0 < lo
  K_nonneg : 0 ≤ K
  freq : ∀ k j, α*(N k:ℝ) ≤ ((Finset.univ.filter (fun i => label k i=j)).card:ℝ)
  q_bound : ∀ j, (q j:ℝ) ≤ Q
  A : ℕ → ℝ
  D : ℕ → ℝ
  A₀ : ℝ
  E : ℝ
  A_lo : ∀ k, lo ≤ A k
  A_hi : ∀ k, A k ≤ hi
  A₀_lo : lo ≤ A₀
  A₀_hi : A₀ ≤ hi
  A_tendsto : Tendsto A atTop (𝓝 A₀)
  D_tendsto : Tendsto D atTop (𝓝 0)
  d : (k : ℕ) → Fin (N k) → ℝ
  d_bound : ∀ k i, |d k i| ≤ D k
  orthogonal : ∀ k, ∑ i, (q (label k i):ℝ)*d k i = 0
  energy_tendsto : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E)
  energy_bound : ∀ k, (∑ i, (d k i)^2) ≤ K

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

def alphabet (k : ℕ) : Fin (S.N k) → ℕ := fun i => S.q (S.label k i)
def incoming (k : ℕ) : Fin (S.N k) → ℝ := fun i => S.A k*(S.alphabet k i:ℝ)+S.d k i

lemma q_pos (i : ι) : 0 < S.q i := by rcases S.q_odd i with ⟨a,ha⟩; omega
lemma gain_pos (k : ℕ) : 0 < S.A k := S.lo_pos.trans_le (S.A_lo k)
lemma hi_pos : 0 < S.hi := (S.lo_pos.trans_le S.A₀_lo).trans_le S.A₀_hi
lemma alphabet_pos (k : ℕ) (i : Fin (S.N k)) : 0 < S.alphabet k i := S.q_pos _
lemma alphabet_odd (k : ℕ) (i : Fin (S.N k)) : Odd (S.alphabet k i) := S.q_odd _

lemma cell_error_tendsto {ρ : ℝ} (hρ : 0 < ρ) (hρhi : ρ < Real.pi/(2*S.hi)) (l j : ℕ) :
    Tendsto (fun k => residualCellError (S.alphabet k) (S.d k) (S.A k) ρ l j) atTop (𝓝 0) := by
  exact residual_concrete_cell_L1 S.N S.N_pos S.N_tendsto S.label S.q S.c S.q_odd S.bezout
    S.d S.A S.D S.α_pos S.Q_pos S.lo_pos S.A_lo S.A_hi S.A₀_lo S.A₀_hi S.K_nonneg
    hρ hρhi S.freq S.q_bound S.d_bound S.orthogonal S.A_tendsto S.D_tendsto
    S.energy_tendsto S.energy_bound l j

lemma cell_integrable {ρ : ℝ} (hρ : 0 < ρ) (k l j : ℕ) :
    Integrable (residualCellWindow (fun i => (S.alphabet k i:ℝ)) (S.d k) (S.A k)
      (residualScale (S.A k) (S.alphabet k)) l ρ (residualDerivativeKernel j)) := by
  let T : ℝ := ((l:ℝ)+1)*Real.pi/S.lo
  let M : ℝ := T^j/Real.sinh (Real.pi*ρ/2)
  have hT : 0 < T := by dsimp [T]; positivity [S.lo_pos]
  have hM : 0 ≤ M := by dsimp [M]; positivity
  apply residualCellWindow_integrable (S.label k) S.q S.c S.q_odd S.bezout
    S.α_pos S.Q_pos (S.gain_pos k) S.K_nonneg hT.le hM (S.freq k)
    (fun i => by rw [abs_of_nonneg (Nat.cast_nonneg _)]; exact S.q_bound _)
    (S.d k) (S.energy_bound k)
    (residualScale_identity (S.N_pos k) (S.alphabet k) (S.alphabet_pos k) (S.gain_pos k))
    l (residualDerivativeKernel j) (residualDerivativeKernel_measurable j)
  · intro y hy hρy
    rw [abs_of_pos (hρ.trans_le hρy)]
    exact residualPeak_cell_upper S.lo_pos (S.A_lo k) l hy
  · intro y hy hρy
    exact residualDerivativeKernel_interval_bound j hρ hρy
      (residualPeak_cell_upper S.lo_pos (S.A_lo k) l hy)

lemma incoming_eventually_bounded :
    ∀ᶠ k in atTop, ∀ i, |S.incoming k i| ≤ S.hi*S.Q+1 := by
  filter_upwards [S.D_tendsto.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1))] with k hk i
  have ha : 0 ≤ S.A k*(S.alphabet k i:ℝ) := mul_nonneg (S.gain_pos k).le (Nat.cast_nonneg _)
  have hm := mul_le_mul (S.A_hi k) (S.q_bound (S.label k i))
    (Nat.cast_nonneg (S.alphabet k i)) S.hi_pos.le
  unfold incoming
  apply (abs_add_le _ _).trans
  rw [abs_of_nonneg ha]
  have hd := S.d_bound k i
  dsimp [alphabet] at hm ⊢
  linarith

lemma variance_sqrt_bound (k : ℕ) :
    Real.sqrt (residualVariance (S.alphabet k)) ≤ S.Q*Real.sqrt (S.N k:ℝ) := by
  have hv : residualVariance (S.alphabet k) ≤ (S.N k:ℝ)*S.Q^2 := by
    unfold residualVariance
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i (_ : i ∈ Finset.univ) =>
      (sq_le_sq₀ (Nat.cast_nonneg (S.alphabet k i)) S.Q_pos.le).mpr (S.q_bound (S.label k i)))
    simpa [alphabet] using hh
  have hs := Real.sqrt_le_sqrt hv
  rw [Real.sqrt_mul (by positivity : (0:ℝ) ≤ S.N k), Real.sqrt_sq S.Q_pos.le] at hs
  simpa only [mul_comm] using hs

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
