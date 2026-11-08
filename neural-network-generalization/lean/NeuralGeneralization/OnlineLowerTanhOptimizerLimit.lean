import NeuralGeneralization.OnlineLowerTanhLatticeClassification
import NeuralGeneralization.OnlineLowerTanhLatticeEnergy

/-! # Actual maximizing sequences have a single limiting harmonic and no escape -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

structure OptimizerLatticeLimit (r : ℕ → ℕ) (u : ∀ k,Fin (2*r k+1) → ℝ) where
  data : MaximizerLatticeData r u
  map : ℕ → ℕ
  strictMono : StrictMono map
  a₀ : ℝ
  Q : ℝ
  p : ℕ → ℝ
  a₀_mem : a₀ ∈ Icc data.aMin data.aMax
  p_nonneg : ∀ j,0 ≤ p j
  a_tendsto : Tendsto (fun k => data.spacing (map k)) atTop (𝓝 a₀)
  moment_tendsto : Tendsto (fun k => empiricalSecondMoment (data.label (map k))) atTop (𝓝 Q)
  frequency_tendsto : ∀ j,Tendsto (fun k => empiricalMass (data.label (map k)) j) atTop (𝓝 (p j))

theorem exists_optimizer_lattice_limit (r : ℕ → ℕ) (hr : ∀ k,3 ≤ r k)
    (u : ∀ k,Fin (2*r k+1) → ℝ) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    Nonempty (OptimizerLatticeLimit r u) := by
  obtain ⟨d⟩ := maximizer_lattice_data r hr u hu
  obtain ⟨p,a₀,Q,φ,hφ,ha,hQ,hp,haL,hQL,hpL⟩ := d.empirical_subsequence
  exact ⟨⟨d,φ,hφ,a₀,Q,p,ha,fun j => (hp j).1,haL,hQL,hpL⟩⟩

namespace OptimizerLatticeLimit
variable {r : ℕ → ℕ} {u : ∀ k,Fin (2*r k+1) → ℝ} (O : OptimizerLatticeLimit r u)

lemma a₀_pos : 0 < O.a₀ := O.data.aMin_pos.trans_le O.a₀_mem.1

lemma degree_tendsto (hr : Tendsto r atTop atTop) :
    Tendsto (fun k => 2*r (O.map k)+1) atTop atTop := by
  have hlin : StrictMono (fun n : ℕ => 2*n+1) := by
    intro a b hab
    dsimp only
    omega
  exact hlin.tendsto_atTop.comp (hr.comp O.strictMono.tendsto_atTop)

def latticeSequence (hr : Tendsto r atTop atTop) : LatticeSequence where
  N := fun k => 2*r (O.map k)+1
  N_pos := fun _ => by omega
  N_tendsto := O.degree_tendsto hr
  u := fun k => u (O.map k)
  q := fun k => O.data.label (O.map k)
  a := fun k => O.data.spacing (O.map k)
  a₀ := O.a₀
  a₀_pos := O.a₀_pos
  a_tendsto := O.a_tendsto
  K := O.data.residualBound
  K_nonneg := O.data.residualBound_nonneg
  residual_bound := fun k => O.data.residual_le (O.map k)
  p := O.p
  p_nonneg := O.p_nonneg
  frequency_tendsto := O.frequency_tendsto

lemma normalized_energy_tendsto (hr : Tendsto r atTop atTop) :
    Tendsto (fun k => incomingEnergy (u (O.map k))/(2*r (O.map k)+1:ℕ)) atTop
      (𝓝 (O.a₀^2*O.Q)) :=
  normalized_lattice_energy_tendsto (fun k => 2*r (O.map k)+1) (fun _ => by omega)
    (O.degree_tendsto hr) (fun k => u (O.map k)) (fun k => O.data.label (O.map k))
    (fun k => O.data.spacing (O.map k)) O.a₀ O.Q O.data.residualBound
    (fun k => (O.data.aMin_pos.trans_le (O.data.spacing_mem (O.map k)).1).le)
    (fun k => O.data.residual_le (O.map k)) O.a_tendsto O.moment_tendsto

lemma efficiency_lower (hr : Tendsto r atTop atTop) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ (O.latticeSequence hr).efficiency k := by
  have h := maximizer_efficiency_eventual_lower (fun k => r (O.map k))
    (hr.comp O.strictMono.tendsto_atTop) (fun k => u (O.map k)) (fun k => hu (O.map k))
  intro ε hε
  filter_upwards [h ε hε] with k hk
  change limitingParityEfficiency-ε ≤ (2*r (O.map k)+1:ℕ)*
    |parityCorrelation (u (O.map k)) 0|/Real.sqrt (incomingEnergy (u (O.map k)))
  simpa only [intrinsicEfficiency,intrinsicGain,mul_div_assoc] using hk

/-- The possible unbounded integer alphabet and escaped moment are both
eliminated by actual finite-prefix conditioning inequalities. -/
theorem classified (hr : Tendsto r atTop atTop) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    ∃ g : ℕ,0 < g ∧ Odd g ∧ O.Q=(g:ℝ)^2 ∧ O.a₀*g=limitingGain ∧
      O.p=(fun j => if j=g then 1 else 0) := by
  obtain ⟨g,J₀,hg,hgOdd,hsum,hG,hstable,hdiv,hmoment,hlower,hescape,hequality⟩ :=
    O.data.limit_classification O.map O.p O.Q O.frequency_tendsto O.moment_tendsto
  have hsupport := empiricalLimit_positive_odd_support
    (fun k => 2*r (O.map k)+1) (fun _ => by omega) (fun k => O.data.label (O.map k))
    O.p O.Q O.frequency_tendsto O.moment_tendsto
    (fun k i => by
      have ho := O.data.label_odd (O.map k) i
      exact ⟨Nat.pos_of_ne_zero (by intro he; simpa [he] using ho),ho⟩)
  have h := (O.latticeSequence hr).empirical_classification O.Q (O.normalized_energy_tendsto hr)
    (O.efficiency_lower hr hu) hsum hmoment g J₀ hg (fun j hj => (hsupport j hj).2)
    hdiv hstable (sub_nonneg.mp hescape)
  exact ⟨g,hg,hgOdd,h.2.1,h.2.2.2.1,h.2.2.2.2⟩

lemma actual_energy_limit (hr : Tendsto r atTop atTop) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    Tendsto (fun k => incomingEnergy (u (O.map k))/(2*r (O.map k)+1:ℕ)) atTop
      (𝓝 (limitingGain^2)) := by
  obtain ⟨g,hg,hgo,hQ,ha,hp⟩ := O.classified hr hu
  have h := O.normalized_energy_tendsto hr
  have he : O.a₀^2*O.Q=limitingGain^2 := by rw [hQ,←mul_pow,ha]
  rwa [he] at h

end OptimizerLatticeLimit
end NeuralGeneralization.OnlineLowerTanh
