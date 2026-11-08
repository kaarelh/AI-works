import NeuralGeneralization.OnlineLowerTanhOptimizer
import NeuralGeneralization.OnlineLowerTanhEmpiricalTruncation

/-! # Concrete lattice and empirical data for sequences of actual maximizers

All data below are extracted from the actual finite-cube optimization problem.
The structures contain no sharp parity inequality or central-limit assumption.
-/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma IsIntrinsicMaximizer_energy_bound (r : ℕ) (u : Fin (2*r+1) → ℝ)
    (hu : IsIntrinsicMaximizer u) : incomingEnergy u ≤ 64*(2*r+1:ℕ) := by
  have hc := (IsIntrinsicMaximizer_competitive r u hu).2
  have hs := competitive_scale_upper r u (1/4) (by norm_num) hc
  norm_num at hs
  have hsq : incomingScale u ^ 2 ≤ 64 := by
    nlinarith [incomingScale_nonneg u]
  rw [incomingScale_sq] at hsq
  exact (div_le_iff₀ (by positivity : (0:ℝ)<(2*r+1:ℕ))).mp hsq

/-- Uniform actual lattice approximants before passage to any subsequence. -/
structure MaximizerLatticeData (r : ℕ → ℕ) (u : ∀ k, Fin (2*r k+1) → ℝ) where
  aMin : ℝ
  aMax : ℝ
  residualBound : ℝ
  momentBound : ℝ
  aMin_pos : 0 < aMin
  aMin_lt_aMax : aMin < aMax
  residualBound_nonneg : 0 ≤ residualBound
  spacing : ℕ → ℝ
  label : ∀ k, Fin (2*r k+1) → ℕ
  spacing_mem : ∀ k, spacing k ∈ Icc aMin aMax
  label_odd : ∀ k i, Odd (label k i)
  residual_le : ∀ k, (∑ i, (|u k i|-spacing k*(label k i:ℝ))^2) ≤ residualBound
  moment_le : ∀ k, empiricalSecondMoment (label k) ≤ momentBound

/-- The inverse-lattice theorem applies uniformly to every actual maximizing
sequence of odd degrees at least seven. -/
theorem maximizer_lattice_data (r : ℕ → ℕ) (hr : ∀ k, 3 ≤ r k)
    (u : ∀ k, Fin (2*r k+1) → ℝ) (hu : ∀ k, IsIntrinsicMaximizer (u k)) :
    Nonempty (MaximizerLatticeData r u) := by
  obtain ⟨aMin,aMax,K,haMin,hgap,hK,hloc⟩ :=
    global_odd_lattice_localization (1/4) (by norm_num)
  have hex (k : ℕ) : ∃ a ∈ Icc aMin aMax, ∃ q : Fin (2*r k+1) → ℕ,
      (∀ i, Odd (q i)) ∧ (∑ i, (|u k i|-a*(q i:ℝ))^2) ≤ K := by
    have hc := IsIntrinsicMaximizer_competitive (r k) (u k) (hu k)
    exact hloc (r k) (hr k) (u k) hc.1 hc.2
  choose a ha q hq hres using hex
  refine ⟨{
    aMin := aMin
    aMax := aMax
    residualBound := K
    momentBound := (128+2*K)/aMin^2
    aMin_pos := haMin
    aMin_lt_aMax := hgap
    residualBound_nonneg := hK
    spacing := a
    label := q
    spacing_mem := ha
    label_odd := hq
    residual_le := hres
    moment_le := ?_ }⟩
  intro k
  convert empiricalSecondMoment_le_of_uniform_residual (by omega) (u k) (q k)
    (a k) aMin 64 K haMin (ha k).1
    (IsIntrinsicMaximizer_energy_bound (r k) (u k) (hu k)) (hres k) using 1 <;> norm_num

/-- A common subsequence carries spacing, total moment, and every empirical
frequency. Escape of second moment has not been discarded. -/
theorem MaximizerLatticeData.empirical_subsequence
    {r : ℕ → ℕ} {u : ∀ k, Fin (2*r k+1) → ℝ} (d : MaximizerLatticeData r u) :
    ∃ p : ℕ → ℝ, ∃ a₀ Q : ℝ, ∃ φ : ℕ → ℕ,
      StrictMono φ ∧ a₀ ∈ Icc d.aMin d.aMax ∧ Q ∈ Icc 0 d.momentBound ∧
      (∀ j, p j ∈ Icc (0:ℝ) 1) ∧
      Tendsto (fun k => d.spacing (φ k)) atTop (𝓝 a₀) ∧
      Tendsto (fun k => empiricalSecondMoment (d.label (φ k))) atTop (𝓝 Q) ∧
      ∀ j, Tendsto (fun k => empiricalMass (d.label (φ k)) j) atTop (𝓝 (p j)) :=
  empirical_spacing_moment_subsequence (fun k => 2*r k+1) (fun _ => by omega)
    d.label d.spacing d.aMin d.aMax d.momentBound d.spacing_mem d.moment_le

/-- The limiting odd law and its stable gcd are consequences of actual
empirical convergence, with the possible escaped second moment explicit. -/
theorem MaximizerLatticeData.limit_classification
    {r : ℕ → ℕ} {u : ∀ k, Fin (2*r k+1) → ℝ} (d : MaximizerLatticeData r u)
    (φ : ℕ → ℕ) (p : ℕ → ℝ) (Q : ℝ)
    (hp : ∀ j, Tendsto (fun k => empiricalMass (d.label (φ k)) j) atTop (𝓝 (p j)))
    (hQ : Tendsto (fun k => empiricalSecondMoment (d.label (φ k))) atTop (𝓝 Q)) :
    ∃ g J₀ : ℕ, 0 < g ∧ Odd g ∧ HasSum p 1 ∧
      supportPrefixGcd p J₀ = g ∧
      (∀ J, J₀ ≤ J → supportPrefixGcd p J = g) ∧
      (∀ j, 0 < p j → g ∣ j) ∧
      Summable (fun j => p j*(j:ℝ)^2) ∧
      (g:ℝ)^2 ≤ ∑' j, p j*(j:ℝ)^2 ∧
      0 ≤ Q-∑' j, p j*(j:ℝ)^2 ∧
      ((∑' j, p j*(j:ℝ)^2) = (g:ℝ)^2 → p = fun j => if j=g then 1 else 0) := by
  apply empiricalLimit_gcd_classification (fun k => 2*r (φ k)+1)
    (fun _ => by omega) (fun k => d.label (φ k)) p Q hp hQ
  intro k i
  have ho := d.label_odd (φ k) i
  exact ⟨Nat.pos_of_ne_zero (by intro he; simpa [he] using ho),ho⟩

end NeuralGeneralization.OnlineLowerTanh
