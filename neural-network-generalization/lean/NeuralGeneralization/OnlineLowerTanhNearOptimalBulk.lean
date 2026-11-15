import NeuralGeneralization.OnlineLowerTanhNearOptimalConcentration

/-! # An actual large bulk for every near-optimal sequence -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

structure UniformCompetitiveLattice (c:ℝ) where
  aMin:ℝ
  aMax:ℝ
  K:ℝ
  aMin_pos:0<aMin
  aMin_lt_aMax:aMin<aMax
  K_nonneg:0 ≤ K
  localize:∀r:ℕ,3 ≤ r→∀u:Fin (2*r+1)→ℝ,u≠0→
    c*Real.sqrt (incomingEnergy u) ≤ (2*r+1:ℕ)*|parityCorrelation u 0|→
      ∃a∈Icc aMin aMax,∃q:Fin (2*r+1)→ℕ,
        (∀i,Odd (q i)) ∧ (∑i,(|u i|-a*(q i:ℝ))^2) ≤ K

lemma exists_uniform_competitive_lattice (c:ℝ) (hc:0<c):Nonempty (UniformCompetitiveLattice c) := by
  obtain ⟨aMin,aMax,K,haMin,hgap,hK,hloc⟩:=global_odd_lattice_localization c hc
  exact ⟨⟨aMin,aMax,K,haMin,hgap,hK,hloc⟩⟩

namespace UniformCompetitiveLattice
variable {c:ℝ} (D:UniformCompetitiveLattice c)

/-- The residual bound in these actual finite arrays is the same D.K for
every sequence; it is selected before any near-optimal family is given. -/
def data (hc:0<c) (r:ℕ→ℕ) (hr:∀k,3 ≤ r k)
    (u:∀k,Fin (2*r k+1)→ℝ) (hu:∀k,c ≤ intrinsicEfficiency (u k)) :
    MaximizerLatticeData r u := by
  have hex (k:ℕ):∃a∈Icc D.aMin D.aMax,∃q:Fin (2*r k+1)→ℕ,
      (∀i,Odd (q i)) ∧ (∑i,(|u k i|-a*(q i:ℝ))^2) ≤ D.K := by
    have hh:=intrinsicEfficiency_competitive hc (hu k)
    exact D.localize (r k) (hr k) (u k) hh.1 hh.2
  choose a ha q hq hres using hex
  have hE (k:ℕ):incomingEnergy (u k) ≤ (2/c)^2*((2*r k+1:ℕ):ℝ) := by
    have hs:=competitive_scale_upper (r k) (u k) c hc
      (intrinsicEfficiency_competitive hc (hu k)).2
    have hsq:=sq_le_sq₀ (incomingScale_nonneg _) (by positivity : 0 ≤ 2/c) |>.mpr hs
    rw [incomingScale_sq] at hsq
    exact (div_le_iff₀ (by positivity : (0:ℝ)<(2*r k+1:ℕ))).mp hsq
  exact {
    aMin:=D.aMin
    aMax:=D.aMax
    residualBound:=D.K
    momentBound:=(2*(2/c)^2+2*D.K)/D.aMin^2
    aMin_pos:=D.aMin_pos
    aMin_lt_aMax:=D.aMin_lt_aMax
    residualBound_nonneg:=D.K_nonneg
    spacing:=a
    label:=q
    spacing_mem:=ha
    label_odd:=hq
    residual_le:=hres
    moment_le:=fun k=>empiricalSecondMoment_le_of_uniform_residual (by omega) (u k) (q k)
      (a k) D.aMin ((2/c)^2) D.K D.aMin_pos (ha k).1 (hE k) (hres k) }
end UniformCompetitiveLattice

/-- Literal subsequence bulk conclusion of the paper's asymptotic-localization
lemma. The bound K is absolute, chosen before the near-optimal sequence.
Input sign changes are represented explicitly by absolute coordinate values. -/
theorem near_optimal_subsequence_bulk :
    ∃K:ℝ,0 ≤ K ∧ ∀r:ℕ→ℕ,Tendsto r atTop atTop→
      ∀u:∀k,Fin (2*r k+1)→ℝ,
      (∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k))→
      ∃φ:ℕ→ℕ,StrictMono φ ∧ ∃A D:ℕ→ℝ,∃I:∀k,Finset (Fin (2*r (φ k)+1)),
        Tendsto A atTop (𝓝 limitingGain) ∧ Tendsto D atTop (𝓝 0) ∧
        (∀k,0 ≤ D k) ∧
        Tendsto (fun k=>((I k).card:ℝ)/(2*r (φ k)+1:ℕ)) atTop (𝓝 1) ∧
        (∀k i,i∈I k→abs (|u (φ k) i|-A k) ≤ D k) ∧
        (∀k,(∑i∈I k,(|u (φ k) i|-A k)^2) ≤ K) ∧
        Tendsto (fun k=>(∑i∈(I k)ᶜ,(u (φ k) i)^2)/(2*r (φ k)+1:ℕ)) atTop (𝓝 0) := by
  let c:=limitingParityEfficiency/2
  have hc:0<c := by dsimp [c]; positivity [limitingParityEfficiency_pos]
  obtain ⟨D₀⟩:=exists_uniform_competitive_lattice c hc
  refine ⟨D₀.K,D₀.K_nonneg,?_⟩
  intro r hr u hnear
  have hevent:∀ᶠk in atTop,3 ≤ r k ∧ c ≤ intrinsicEfficiency (u k) := by
    filter_upwards [hr.eventually (eventually_ge_atTop 3),hnear c hc] with k hk hk'
    refine ⟨hk,?_⟩
    dsimp [c] at *
    linarith
  obtain ⟨k₀,hk₀⟩:=eventually_atTop.mp hevent
  let τ:ℕ→ℕ:=fun k=>k+k₀
  have hτ:StrictMono τ := by intro i j hij; dsimp [τ]; omega
  let r':ℕ→ℕ:=fun k=>r (τ k)
  let u':∀k,Fin (2*r' k+1)→ℝ:=fun k=>u (τ k)
  have hr':Tendsto r' atTop atTop:=hr.comp hτ.tendsto_atTop
  have hr3:∀k,3 ≤ r' k:=fun k=>(hk₀ (τ k) (by dsimp [τ]; omega)).1
  have hcomp:∀k,c ≤ intrinsicEfficiency (u' k):=fun k=>(hk₀ (τ k) (by dsimp [τ]; omega)).2
  have hn:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u' k):=
    fun ε hε=>hτ.tendsto_atTop.eventually (hnear ε hε)
  let d:=D₀.data hc r' hr3 u' hcomp
  obtain ⟨p,a₀,Q,ψ,hψ,ha,hQ,hp,haL,hQL,hpL⟩:=d.empirical_subsequence
  let O:OptimizerLatticeLimit r' u':=⟨d,ψ,hψ,a₀,Q,p,ha,fun j=>(hp j).1,haL,hQL,hpL⟩
  obtain ⟨g,hg,hgo,hQg,hag,hpg⟩:=O.classified_of_near hr' hn
  let φ:ℕ→ℕ:=fun k=>τ (O.map k)
  let I:∀k,Finset (Fin (2*r (φ k)+1)):=fun k=>(O.latticeSequence hr').bulk {g} k
  let A:ℕ→ℝ:=fun k=>O.data.spacing (O.map k)*g
  let D:ℕ→ℝ:=fun k=>latticeResidualThreshold (2*r (φ k)+1)
  have hfrac:Tendsto (fun k=>((2*r (φ k)+1:ℕ):ℝ)⁻¹*((I k).card:ℝ)) atTop (𝓝 1):=
    O.singleton_bulk_fraction hr' g hpg
  have hout:=complement_energy_fraction_tendsto (fun k=>2*r (φ k)+1) (fun _=>by omega)
    (fun k=>u (φ k)) I limitingGain hfrac (O.rms_concentration_of_near hr' hn)
  refine ⟨φ,hτ.comp O.strictMono,A,D,I,?_,?_,?_,?_,?_,?_,?_⟩
  · simpa only [hag] using O.a_tendsto.mul_const (g:ℝ)
  · exact latticeResidualThreshold_tendsto _ (O.degree_tendsto hr')
  · intro k
    exact (latticeResidualThreshold_pos (by omega)).le
  · simpa only [div_eq_mul_inv,mul_comm] using hfrac
  · exact O.singleton_bulk_close hr' g
  · exact O.singleton_bulk_energy hr' g
  · simpa only [div_eq_mul_inv,mul_comm] using hout

end NeuralGeneralization.OnlineLowerTanh
