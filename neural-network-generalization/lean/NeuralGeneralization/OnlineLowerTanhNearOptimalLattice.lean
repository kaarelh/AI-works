import NeuralGeneralization.OnlineLowerTanhNearBulk

/-! # Lattice classification for near-optimal, not necessarily maximizing, atoms -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

lemma intrinsicEfficiency_competitive {r:ℕ} {u:Fin (2*r+1)→ℝ}
    {c:ℝ} (hc:0<c) (he:c ≤ intrinsicEfficiency u) :
    u≠0 ∧ c*Real.sqrt (incomingEnergy u) ≤ (2*r+1:ℕ)*|parityCorrelation u 0| := by
  have hu:u≠0 := by
    intro hu
    simpa [hu,intrinsicEfficiency] using hc.trans_le he
  refine ⟨hu,?_⟩
  have hs:=Real.sqrt_pos.mpr (incomingEnergy_pos_of_ne_zero u hu)
  have he' : c ≤ ((2*r+1:ℕ):ℝ)*|parityCorrelation u 0|/Real.sqrt (incomingEnergy u) := by
    simpa only [intrinsicEfficiency,intrinsicGain,mul_div_assoc] using he
  exact (le_div_iff₀ hs).mp he'

/-- The same literal lattice data exist for every uniformly competitive
family; exact optimization is not a hypothesis. -/
theorem competitive_lattice_data (r:ℕ→ℕ) (hr:∀k,3 ≤ r k)
    (u:∀k,Fin (2*r k+1)→ℝ) (c:ℝ) (hc:0<c)
    (hu:∀k,c ≤ intrinsicEfficiency (u k)) : Nonempty (MaximizerLatticeData r u) := by
  obtain ⟨aMin,aMax,K,haMin,hgap,hK,hloc⟩ := global_odd_lattice_localization c hc
  have hex (k:ℕ):∃a∈Icc aMin aMax,∃q:Fin (2*r k+1)→ℕ,
      (∀i,Odd (q i)) ∧ (∑i,(|u k i|-a*(q i:ℝ))^2) ≤ K := by
    have hh:=intrinsicEfficiency_competitive hc (hu k)
    exact hloc (r k) (hr k) (u k) hh.1 hh.2
  choose a ha q hq hres using hex
  have hE (k:ℕ):incomingEnergy (u k) ≤ (2/c)^2*((2*r k+1:ℕ):ℝ) := by
    have hs:=competitive_scale_upper (r k) (u k) c hc
      (intrinsicEfficiency_competitive hc (hu k)).2
    have hsq:=sq_le_sq₀ (incomingScale_nonneg _) (by positivity : 0 ≤ 2/c) |>.mpr hs
    rw [incomingScale_sq] at hsq
    exact (div_le_iff₀ (by positivity : (0:ℝ)<(2*r k+1:ℕ))).mp hsq
  refine ⟨{
    aMin:=aMin
    aMax:=aMax
    residualBound:=K
    momentBound:=(2*(2/c)^2+2*K)/aMin^2
    aMin_pos:=haMin
    aMin_lt_aMax:=hgap
    residualBound_nonneg:=hK
    spacing:=a
    label:=q
    spacing_mem:=ha
    label_odd:=hq
    residual_le:=hres
    moment_le:=?_ }⟩
  intro k
  exact empiricalSecondMoment_le_of_uniform_residual (by omega) (u k) (q k)
    (a k) aMin ((2/c)^2) K haMin (ha k).1 (hE k) (hres k)

theorem exists_competitive_lattice_limit (r:ℕ→ℕ) (hr:∀k,3 ≤ r k)
    (u:∀k,Fin (2*r k+1)→ℝ) (c:ℝ) (hc:0<c)
    (hu:∀k,c ≤ intrinsicEfficiency (u k)) : Nonempty (OptimizerLatticeLimit r u) := by
  obtain ⟨d⟩:=competitive_lattice_data r hr u c hc hu
  obtain ⟨p,a₀,Q,φ,hφ,ha,hQ,hp,haL,hQL,hpL⟩:=d.empirical_subsequence
  exact ⟨⟨d,φ,hφ,a₀,Q,p,ha,fun j=>(hp j).1,haL,hQL,hpL⟩⟩

namespace OptimizerLatticeLimit
variable {r:ℕ→ℕ} {u:∀k,Fin (2*r k+1)→ℝ} (O:OptimizerLatticeLimit r u)

theorem classified_of_near (hr:Tendsto r atTop atTop)
    (hnear:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    ∃g:ℕ,0<g ∧ Odd g ∧ O.Q=(g:ℝ)^2 ∧ O.a₀*g=limitingGain ∧
      O.p=(fun j=>if j=g then 1 else 0) := by
  obtain ⟨g,J₀,hg,hgOdd,hsum,hG,hstable,hdiv,hmoment,hlower,hescape,hequality⟩:=
    O.data.limit_classification O.map O.p O.Q O.frequency_tendsto O.moment_tendsto
  have hsupport:=empiricalLimit_positive_odd_support
    (fun k=>2*r (O.map k)+1) (fun _=>by omega) (fun k=>O.data.label (O.map k))
    O.p O.Q O.frequency_tendsto O.moment_tendsto (fun k i=>by
      have ho:=O.data.label_odd (O.map k) i
      exact ⟨Nat.pos_of_ne_zero (by intro he; simpa [he] using ho),ho⟩)
  have hlow:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ (O.latticeSequence hr).efficiency k := by
    intro ε hε
    have h:=O.strictMono.tendsto_atTop.eventually (hnear ε hε)
    filter_upwards [h] with k hk
    change limitingParityEfficiency-ε ≤ (2*r (O.map k)+1:ℕ)*
      |parityCorrelation (u (O.map k)) 0|/Real.sqrt (incomingEnergy (u (O.map k)))
    simpa only [intrinsicEfficiency,intrinsicGain,mul_div_assoc] using hk
  have h:=(O.latticeSequence hr).empirical_classification O.Q (O.normalized_energy_tendsto hr)
    hlow hsum hmoment g J₀ hg (fun j hj=>(hsupport j hj).2) hdiv hstable (sub_nonneg.mp hescape)
  exact ⟨g,hg,hgOdd,h.2.1,h.2.2.2.1,h.2.2.2.2⟩

lemma energy_limit_of_near (hr:Tendsto r atTop atTop)
    (hnear:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    Tendsto (fun k=>incomingEnergy (u (O.map k))/(2*r (O.map k)+1:ℕ)) atTop
      (𝓝 (limitingGain^2)) := by
  obtain ⟨g,hg,hgo,hQ,ha,hp⟩:=O.classified_of_near hr hnear
  have h:=O.normalized_energy_tendsto hr
  have he:O.a₀^2*O.Q=limitingGain^2 := by rw [hQ,←mul_pow,ha]
  rwa [he] at h

lemma rms_concentration_of_near (hr:Tendsto r atTop atTop)
    (hnear:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    Tendsto (fun k=>((2*r (O.map k)+1:ℕ):ℝ)⁻¹*
      (∑i,(|u (O.map k) i|-limitingGain)^2)) atTop (𝓝 0) := by
  obtain ⟨g,hg,hgOdd,hQ,ha,hp⟩:=O.classified_of_near hr hnear
  have hm:Tendsto (fun k=>empiricalSecondMoment (O.data.label (O.map k))) atTop (𝓝 ((g:ℝ)^2)) :=
    hQ ▸ O.moment_tendsto
  have hf:Tendsto (fun k=>empiricalMass (O.data.label (O.map k)) g) atTop (𝓝 1) := by
    simpa [hp] using O.frequency_tendsto g
  have h:=incoming_common_variance_tendsto (fun k=>2*r (O.map k)+1) (fun _=>by omega)
    (O.degree_tendsto hr) (fun k=>u (O.map k)) (fun k=>O.data.label (O.map k))
    (fun k=>O.data.spacing (O.map k)) O.a₀ O.data.residualBound g O.a_tendsto
    (fun k=>O.data.residual_le (O.map k)) hm hf
  rwa [ha] at h
end OptimizerLatticeLimit
end NeuralGeneralization.OnlineLowerTanh
