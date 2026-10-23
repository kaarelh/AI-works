import NeuralGeneralization.BatchTwoActivationUniformLearning
import NeuralGeneralization.BatchTwoActivationUniformTail

/-!
# All widths and all Gaussian scales for unbounded Lipschitz activations

The theorem here inhabits the manuscript's exact all-width, all-scale
statement. The same sample event works for every eligible width and every
scale in `(0,1]`. The Gaussian layer laws, reconstruction, target mass,
exceptional probability, finite class and polynomial envelopes are all
proved in the imported modules; no analytic conclusion is assumed.
-/
noncomputable section
set_option maxHeartbeats 1800000
set_option maxRecDepth 10000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

/-- Unified unbounded-activation paper, Theorem `uniform-all-scales`, with
its simultaneous quantifier order and actual Gaussian NN posterior. -/
theorem uniform_unbounded_activation_learning : UniformUnboundedActivationLearning := by
  classical
  intro r ℓ hℓ1
  obtain ⟨B,hB1,hB',hB''⟩ := scalarCutoff_uniform_bounds
  let b : ℕ := 1+⌈ℓ⌉₊+⌈B⌉₊
  have hb : 1≤b := by dsimp [b]; omega
  have hℓ : ℓ≤(b:ℝ) := by
    have hh := Nat.le_ceil ℓ
    have hb' : ⌈ℓ⌉₊≤b := by dsimp [b]; omega
    exact hh.trans (by exact_mod_cast hb')
  have hB : B≤(b:ℝ) := by
    have hh := Nat.le_ceil B
    have hb' : ⌈B⌉₊≤b := by dsimp [b]; omega
    exact hh.trans (by exact_mod_cast hb')
  have hℓ0 : 0<ℓ := by linarith
  have hB0 : 0≤B := by linarith
  obtain ⟨A,hA,m,hpoly⟩ := (activationUniformCapacity_polynomial b r).shifted_ceil_real_envelope
  refine ⟨A,hA,m,?_⟩
  intro φ hφ d hd f C hf D ε δ hε hε1 hδ hδ1 n hn
  let S : ℕ := C+⌈Real.log (1/ε)⌉₊
  have hCS : C≤S := Nat.le_add_right _ _
  have hlog0 : 0≤Real.log (1/ε) := by
    apply Real.log_nonneg
    exact (one_le_div hε).mpr hε1.le
  have hlog : Real.log (1/ε)≤(S:ℝ) := by
    have hh := Nat.le_ceil (Real.log (1/ε))
    have hs : ⌈Real.log (1/ε)⌉₊≤S := Nat.le_add_left _ _
    exact hh.trans (by exact_mod_cast hs)
  let F := activationUniformFunctions b d S r φ
  let P : ℝ := activationUniformCapacity b d S r
  have hcount : (F.card:ℝ)≤Real.exp P :=
    activationUniformFunctions_card_le_exp hb hd hφ hℓ0 hℓ
  have hP : P≤MainStatements.polynomialEnvelope A m d C (Real.log (1/ε)) :=
    hpoly d C (Real.log (1/ε)) hlog0
  have hsize : (2/ε)*(P+Real.log (1/δ))≤(n:ℝ) := by
    apply le_trans _ hn
    apply mul_le_mul_of_nonneg_left _ (by positivity : (0:ℝ)≤2/ε)
    linarith
  let T := {p : ℕ×ℝ // C≤p.1 ∧0<p.2 ∧p.2≤1}
  let width : T→ℕ := fun i=>i.val.1
  let μ : ∀i:T,Measure (Weights d (width i) r) :=
    fun i=>activationBandPrior d i.val.1 r i.val.2
  have hpos : ∀i:T,0<functionMass φ (1/2) (μ i) f := by
    intro i
    exact (Real.exp_pos _).trans_le (activationBand_target_mass hd i.property.1 hCS
      hφ hℓ0.le hℓ f hf i.property.2.1 i.property.2.2)
  have htail : ∀i:T,(∑g∈Finset.univ\F,functionMass φ (1/2) (μ i) g)/
      functionMass φ (1/2) (μ i) f≤ε/2 := by
    intro i
    exact activation_uniform_relative_tail hb hd i.property.1 hCS hℓ0 hℓ hB0 hB
      hφ hB' hB'' f hf hε hε1 hlog i.property.2.1 i.property.2.2
  obtain ⟨hden,hlearn⟩ := uniform_prior_family_learning width φ μ D f F hε hε1 hδ
    hcount hpos htail n hsize
  constructor
  · intro N hCN t ht ht1 s
    exact hden ⟨(N,t),hCN,ht,ht1⟩ s
  · apply hlearn.trans (sampleProbability_mono D n _ _ ?_)
    intro s hs N hCN t ht ht1
    exact hs ⟨(N,t),hCN,ht,ht1⟩

end NeuralGeneralization.BatchTwoActivation
