import NeuralGeneralization.OnlineLowerTanhNearOptimalLattice

/-! # Uniform concentration of every asymptotically optimal tanh atom -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.OnlineLowerTanh

def nearOptimalRMS {n:ℕ} (u:Fin n→ℝ):ℝ:=
  (n:ℝ)⁻¹*(∑i,(|u i|-limitingGain)^2)
def nearOptimalDefect {n:ℕ} (u:Fin n→ℝ):ℝ:=
  nearOptimalRMS u+|incomingEnergy u/(n:ℝ)-limitingGain^2|

lemma nearOptimalRMS_nonneg {n:ℕ} (u:Fin n→ℝ):0 ≤ nearOptimalRMS u := by
  unfold nearOptimalRMS
  positivity
lemma nearOptimalDefect_nonneg {n:ℕ} (u:Fin n→ℝ):0 ≤ nearOptimalDefect u :=
  add_nonneg (nearOptimalRMS_nonneg _) (abs_nonneg _)

lemma OptimizerLatticeLimit.defect_tendsto_of_near
    {r:ℕ→ℕ} {u:∀k,Fin (2*r k+1)→ℝ} (O:OptimizerLatticeLimit r u)
    (hr:Tendsto r atTop atTop)
    (hnear:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    Tendsto (fun k=>nearOptimalDefect (u (O.map k))) atTop (𝓝 0) := by
  have hrms:=O.rms_concentration_of_near hr hnear
  have hE:=((O.energy_limit_of_near hr hnear).sub_const (limitingGain^2)).abs
  have h:=hrms.add hE
  simpa only [sub_self,abs_zero,add_zero,nearOptimalDefect,nearOptimalRMS] using h

/-- A compactness statement with finite ε/δ quantifiers. Every sufficiently
high odd-degree atom whose efficiency is sufficiently close to the optimal
limit has small full RMS defect and the correct total energy. -/
theorem near_optimal_uniform_concentration :
    ∀ε:ℝ,0<ε→∃r₀:ℕ,∃δ:ℝ,0<δ ∧
      ∀r:ℕ,r₀ ≤ r→∀u:Fin (2*r+1)→ℝ,
        limitingParityEfficiency-δ ≤ intrinsicEfficiency u→nearOptimalDefect u<ε := by
  intro ε hε
  by_contra hn
  push_neg at hn
  let c:=limitingParityEfficiency/2
  have hc:0<c := by dsimp [c]; positivity [limitingParityEfficiency_pos]
  have hbad (k:ℕ):∃r:ℕ,k+3 ≤ r ∧ ∃u:Fin (2*r+1)→ℝ,
      limitingParityEfficiency-min c ((k:ℝ)+1)⁻¹ ≤ intrinsicEfficiency u ∧
        ε ≤ nearOptimalDefect u := by
    exact hn (k+3) (min c ((k:ℝ)+1)⁻¹) (by positivity)
  choose r hr u hu hbad using hbad
  have hr3:∀k,3 ≤ r k := by intro k; have :=hr k; omega
  have hrinf:Tendsto r atTop atTop :=
    tendsto_atTop_mono (fun k=>(by have :=hr k; omega : k ≤ r k)) tendsto_id
  have hcomp:∀k,c ≤ intrinsicEfficiency (u k) := by
    intro k
    have hh:=min_le_left c ((k:ℝ)+1)⁻¹
    have hu':=hu k
    dsimp [c] at *
    linarith
  have hsmall:Tendsto (fun k:ℕ=>((k:ℝ)+1)⁻¹) atTop (𝓝 0) :=
    tendsto_inv_atTop_zero.comp
      (tendsto_atTop_add_const_right atTop 1 tendsto_natCast_atTop_atTop)
  have hnear:∀δ>0,∀ᶠk in atTop,limitingParityEfficiency-δ ≤ intrinsicEfficiency (u k) := by
    intro δ hδ
    filter_upwards [hsmall.eventually (gt_mem_nhds hδ)] with k hk
    have hh:=min_le_right c ((k:ℝ)+1)⁻¹
    have hu':=hu k
    linarith
  obtain ⟨O⟩:=exists_competitive_lattice_limit r hr3 u c hc hcomp
  have hlim:=O.defect_tendsto_of_near hrinf hnear
  obtain ⟨k,hk⟩:=(hlim.eventually (gt_mem_nhds hε)).exists
  exact (not_lt_of_ge (hbad (O.map k))) hk

/-- The paper's near-optimal-sequence assertion, in the stronger full-RMS
form and with the energy convergence explicit. No exact maximizer is assumed. -/
theorem near_optimal_sequence_concentration
    (r:ℕ→ℕ) (hr:Tendsto r atTop atTop) (u:∀k,Fin (2*r k+1)→ℝ)
    (hnear:∀ε>0,∀ᶠk in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    Tendsto (fun k=>nearOptimalRMS (u k)) atTop (𝓝 0) ∧
    Tendsto (fun k=>incomingEnergy (u k)/(2*r k+1:ℕ)) atTop (𝓝 (limitingGain^2)) := by
  have hdef:Tendsto (fun k=>nearOptimalDefect (u k)) atTop (𝓝 0) := by
    rw [Metric.tendsto_atTop]
    intro ε hε
    obtain ⟨r₀,δ,hδ,hh⟩:=near_optimal_uniform_concentration ε hε
    obtain ⟨k₀,hk₀⟩:=eventually_atTop.mp
      ((hr.eventually (eventually_ge_atTop r₀)).and (hnear δ hδ))
    refine ⟨k₀,?_⟩
    intro k hk
    simpa [Real.dist_eq,abs_of_nonneg (nearOptimalDefect_nonneg _)] using
      hh (r k) (hk₀ k hk).1 (u k) (hk₀ k hk).2
  constructor
  · apply squeeze_zero (fun k=>nearOptimalRMS_nonneg _) _ hdef
    intro k
    exact le_add_of_nonneg_right (abs_nonneg _)
  · rw [Metric.tendsto_atTop]
    intro ε hε
    obtain ⟨k₀,hk₀⟩:=eventually_atTop.mp (hdef.eventually (gt_mem_nhds hε))
    refine ⟨k₀,?_⟩
    intro k hk
    have hh:|incomingEnergy (u k)/(2*r k+1:ℕ)-limitingGain^2| ≤ nearOptimalDefect (u k) :=
      le_add_of_nonneg_left (nearOptimalRMS_nonneg _)
    simpa only [Real.dist_eq] using hh.trans_lt (hk₀ k hk)

/-- The fraction of coordinates outside any fixed ε-neighborhood tends to
zero, after applying input sign changes to make the coordinates nonnegative. -/
theorem near_optimal_empirical_concentration
    (r:ℕ→ℕ) (hr:Tendsto r atTop atTop) (u:∀k,Fin (2*r k+1)→ℝ)
    (hnear:∀δ>0,∀ᶠk in atTop,limitingParityEfficiency-δ ≤ intrinsicEfficiency (u k))
    (ε:ℝ) (hε:0<ε) :
    Tendsto (fun k=>((Finset.univ.filter (fun i=>ε < abs (|u k i|-limitingGain))).card:ℝ)/
      (2*r k+1:ℕ)) atTop (𝓝 0) := by
  have hlim:=(near_optimal_sequence_concentration r hr u hnear).1.div_const (ε^2)
  simp only [zero_div] at hlim
  apply squeeze_zero (fun k=>by positivity) _ hlim
  intro k
  let A:=Finset.univ.filter (fun i=>ε < abs (|u k i|-limitingGain))
  have hA:(A.card:ℝ)*ε^2 ≤ ∑i,(|u k i|-limitingGain)^2 := by
    calc
      _ = ∑i∈A,ε^2 := by simp
      _ ≤ ∑i∈A,(|u k i|-limitingGain)^2 := Finset.sum_le_sum (fun i hi=>by
        have hh:ε < abs (|u k i|-limitingGain):=(Finset.mem_filter.mp hi).2
        nlinarith [sq_abs (|u k i|-limitingGain)])
      _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun i _ _=>sq_nonneg _)
  have hn:(0:ℝ)<(2*r k+1:ℕ) := by positivity
  rw [le_div_iff₀ (sq_pos_of_pos hε)]
  change ((A.card:ℝ)/(2*r k+1:ℕ))*ε^2 ≤ _
  unfold nearOptimalRMS
  convert! mul_le_mul_of_nonneg_left hA (inv_pos.mpr hn).le using 1 <;> ring

end NeuralGeneralization.OnlineLowerTanh
