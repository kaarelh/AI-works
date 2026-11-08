import NeuralGeneralization.OnlineLowerTanhNearBulkResidual
import NeuralGeneralization.OnlineLowerTanhPhaseAbsorption

/-! Quantitative normalization of near-optimal actual parity coefficients. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma lower_defect_tendsto (f:ℕ→ℝ) (L:ℝ)
    (h:∀ε>0,∀ᶠk in atTop,L-ε≤f k) :
    Tendsto (fun k=>max 0 (L-f k)) atTop (𝓝 0) := by
  apply tendsto_order.2
  constructor
  · intro a ha
    exact Eventually.of_forall (fun k=>ha.trans_le (le_max_left _ _))
  · intro a ha
    filter_upwards [h (a/2) (by linarith)] with k hk
    exact max_lt ha (by linarith)

/-- A limiting lower efficiency and a matching upper peak force the
actual peak deficit to vanish; only an explicit approximation error is used. -/
lemma normalized_peak_deficit_tendsto (P t e A H:ℕ→ℝ) (P₀ t₀ L:ℝ)
    (hP:Tendsto P atTop (𝓝 P₀)) (ht:Tendsto t atTop (𝓝 t₀))
    (he:∀ε>0,∀ᶠk in atTop,L-ε≤e k) (hmatch:t₀*L=P₀)
    (ht0:∀ᶠk in atTop,0≤t k) (hA:∀ᶠk in atTop,A k=t k*e k)
    (happrox:Tendsto (fun k=>abs (A k-abs (H k))) atTop (𝓝 0))
    (hcap:∀ᶠk in atTop,|H k|≤P k) :
    Tendsto (fun k=>P k-|H k|) atTop (𝓝 0) := by
  have hd:=lower_defect_tendsto e L he
  have hlim:= (hP.sub (ht.mul ((tendsto_const_nhds : Tendsto (fun _:ℕ=>L) atTop (𝓝 L)).sub hd))).add happrox
  simp only [sub_zero,hmatch,sub_self,zero_add] at hlim
  apply squeeze_zero' (hcap.mono fun k hk=>sub_nonneg.mpr hk) _ hlim
  filter_upwards [ht0,hA] with k htk hAk
  have hdef:L-max 0 (L-e k)≤e k:=by linarith [le_max_right (0:ℝ) (L-e k)]
  have hm:=mul_le_mul_of_nonneg_left hdef htk
  have hab: A k-|H k|≤abs (A k-abs (H k)):=le_abs_self _
  rw [hAk] at hab ⊢
  linarith

namespace NearBalancedSequence
variable (B:NearBalancedSequence)

def bulkEfficiencyFactor (k:ℕ) : ℝ :=
  Real.sqrt (incomingEnergy (B.u k)/(B.N k:ℝ))*
    Real.sqrt ((B.N k:ℝ)⁻¹*((B.bulk k).card:ℝ))/Real.sqrt (2/Real.pi)

lemma bulkEfficiencyFactor_nonneg (k:ℕ) : 0≤B.bulkEfficiencyFactor k := by
  unfold bulkEfficiencyFactor
  positivity

lemma bulkEfficiencyFactor_tendsto :
    Tendsto B.bulkEfficiencyFactor atTop (𝓝 (limitingGain/Real.sqrt (2/Real.pi))) := by
  have hh:=(B.full_energy.sqrt.mul B.bulk_fraction.sqrt).div_const (Real.sqrt (2/Real.pi))
  change Tendsto (fun k=>Real.sqrt (incomingEnergy (B.u k)/(B.N k:ℝ))*Real.sqrt ((B.N k:ℝ)⁻¹*((B.bulk k).card:ℝ))/Real.sqrt (2/Real.pi)) atTop _
  simpa only [Real.sqrt_sq limitingGain_pos.le,Real.sqrt_one,mul_one] using hh

lemma bulkEfficiencyFactor_identity (k:ℕ) (hE:0 < incomingEnergy (B.u k)) :
    B.bulkEfficiencyFactor k*intrinsicEfficiency (B.u k)=
      Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|/Real.sqrt (2/Real.pi) := by
  have hn:0<(B.N k:ℝ):=by exact_mod_cast B.N_pos k
  have hnS:0<Real.sqrt (B.N k:ℝ):=Real.sqrt_pos.mpr hn
  have heS:0<Real.sqrt (incomingEnergy (B.u k)):=Real.sqrt_pos.mpr hE
  have hc:0<Real.sqrt (2/Real.pi):=by positivity
  unfold bulkEfficiencyFactor intrinsicEfficiency intrinsicGain
  rw [Real.sqrt_div (incomingEnergy_nonneg _),
    show (B.N k:ℝ)⁻¹*((B.bulk k).card:ℝ)=((B.bulk k).card:ℝ)/(B.N k:ℝ) by ring,
    Real.sqrt_div (Nat.cast_nonneg _)]
  field_simp
  rw [Real.sq_sqrt hn.le]
  ring

lemma bulkEfficiencyFactor_identity_eventually :
    ∀ᶠk in atTop,B.bulkEfficiencyFactor k*intrinsicEfficiency (B.u k)=
      Real.sqrt ((B.bulk k).card:ℝ)*|parityCorrelation (B.u k) 0|/Real.sqrt (2/Real.pi) := by
  have hpos:=B.full_energy.eventually (eventually_gt_nhds (sq_pos_of_pos limitingGain_pos))
  filter_upwards [hpos] with k hk
  apply B.bulkEfficiencyFactor_identity
  exact (div_pos_iff.mp hk).resolve_right (fun h=>(Nat.cast_nonneg (α:=ℝ) (B.N k)).not_gt h.2) |>.1

lemma bulkEfficiencyFactor_limit_match :
    (limitingGain/Real.sqrt (2/Real.pi))*limitingParityEfficiency=scalarF0 limitingGain := by
  unfold limitingParityEfficiency
  field_simp [limitingGain_pos.ne', (show Real.sqrt (2/Real.pi)≠0 by positivity)]

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
