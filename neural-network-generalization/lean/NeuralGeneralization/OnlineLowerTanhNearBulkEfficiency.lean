import NeuralGeneralization.OnlineLowerTanhNearBulk
import NeuralGeneralization.OnlineLowerTanhConditionedEfficiency

/-! # Balanced witness lower bounds in the normalization used by the residual CLT -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma eventual_lower_mul_tendsto (f h : ℕ → ℝ) (L H : ℝ)
    (hH : 0 ≤ H) (hh0 : ∀ᶠ k in atTop,0 ≤ h k) (hh : Tendsto h atTop (𝓝 H))
    (hf : ∀ ε > 0,∀ᶠ k in atTop,L-ε ≤ f k) :
    ∀ ε > 0,∀ᶠ k in atTop,L*H-ε ≤ f k*h k := by
  intro ε hε
  let δ := ε/(2*(H+1))
  have hδ : 0 < δ := by dsimp [δ]; positivity
  have hδeq : δ*(H+1)=ε/2 := by dsimp [δ]; field_simp
  have htarget : L*H-ε < (L-δ)*H := by nlinarith
  filter_upwards [hh0,hf δ hδ,(hh.const_mul (L-δ)).eventually (lt_mem_nhds htarget)] with k hk0 hkf hkt
  exact hkt.le.trans (mul_le_mul_of_nonneg_right hkf hk0)

lemma efficiency_to_scaled_lower
    (N : ℕ → ℕ) (hN : ∀ k,0 < N k) (u : ∀ k,Fin (N k) → ℝ)
    (V : ℕ → ℝ)
    (hV : Tendsto (fun k => V k/(N k:ℝ)) atTop (𝓝 1))
    (hE : Tendsto (fun k => incomingEnergy (u k)/(N k:ℝ)) atTop (𝓝 (limitingGain^2)))
    (hnear : ∀ ε > 0,∀ᶠ k in atTop,limitingParityEfficiency-ε ≤ intrinsicEfficiency (u k)) :
    ∀ ε > 0,∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*scalarF0 limitingGain-ε ≤
        Real.sqrt (V k)*|parityCorrelation (u k) 0| := by
  let f := fun k => intrinsicEfficiency (u k)
  let h := fun k => Real.sqrt (V k/(N k:ℝ))*Real.sqrt (incomingEnergy (u k)/(N k:ℝ))
  have hlim : Tendsto h atTop (𝓝 limitingGain) := by
    have ht := (Real.continuous_sqrt.continuousAt.tendsto.comp hV).mul
      (Real.continuous_sqrt.continuousAt.tendsto.comp hE)
    simpa only [h,Function.comp_apply,Real.sqrt_one,one_mul,Real.sqrt_sq limitingGain_pos.le] using ht
  have hlo := eventual_lower_mul_tendsto f h limitingParityEfficiency limitingGain limitingGain_pos.le
    (Eventually.of_forall (fun k => by dsimp [h]; positivity)) hlim hnear
  have hconst : limitingParityEfficiency*limitingGain=Real.sqrt (2/Real.pi)*scalarF0 limitingGain := by
    unfold limitingParityEfficiency
    exact div_mul_cancel₀ _ limitingGain_pos.ne'
  intro ε hε
  filter_upwards [hlo ε hε,hV.eventually (lt_mem_nhds (by norm_num : (0:ℝ)<1)),
    hE.eventually (lt_mem_nhds (sq_pos_of_pos limitingGain_pos))] with k hk hv he
  have hnR : (0:ℝ)<N k := by exact_mod_cast hN k
  have hVp : 0 < V k := ((div_pos_iff.mp hv).resolve_right (by intro hh; linarith)).1
  have hEp : 0 < incomingEnergy (u k) := ((div_pos_iff.mp he).resolve_right (by intro hh; linarith)).1
  have hid : f k*h k=Real.sqrt (V k)*|parityCorrelation (u k) 0| := by
    dsimp [f,h,intrinsicEfficiency,intrinsicGain]
    rw [Real.sqrt_div hVp.le,Real.sqrt_div hEp.le]
    have hnroot := Real.sqrt_pos.mpr hnR
    have heroot := Real.sqrt_pos.mpr hEp
    field_simp
    rw [Real.sq_sqrt hnR.le]
    ring
  rwa [hconst,hid] at hk

namespace NearBalancedSequence
variable (B : NearBalancedSequence)

lemma scaled_correlation_lower (V : ℕ → ℝ)
    (hV : Tendsto (fun k => V k/(B.N k:ℝ)) atTop (𝓝 1)) :
    ∀ ε > 0,∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*scalarF0 limitingGain-ε ≤
        Real.sqrt (V k)*|parityCorrelation (B.u k) 0| :=
  efficiency_to_scaled_lower B.N B.N_pos B.u V hV B.full_energy B.efficiency_lower

lemma moving_scaled_correlation_lower (V A : ℕ → ℝ)
    (hV : Tendsto (fun k => V k/(B.N k:ℝ)) atTop (𝓝 1))
    (hA : Tendsto A atTop (𝓝 limitingGain)) (hApos : ∀ k,0 < A k) :
    ∀ ε > 0,∀ᶠ k in atTop,
      Real.sqrt (2/Real.pi)*periodicFourierMaximum (A k)-ε ≤
        Real.sqrt (V k)*|parityCorrelation (B.u k) 0| := by
  have ht := (scalarF0_tendsto_of_positive limitingGain_pos hA).const_mul (Real.sqrt (2/Real.pi))
  intro ε hε
  filter_upwards [B.scaled_correlation_lower V hV (ε/2) (by positivity),
    ht.eventually (gt_mem_nhds (by linarith : Real.sqrt (2/Real.pi)*scalarF0 limitingGain <
      Real.sqrt (2/Real.pi)*scalarF0 limitingGain+ε/2))] with k hk htk
  rw [periodicFourierMaximum_eq_scalarF0 (A k) (hApos k)]
  linarith

end NearBalancedSequence
end NeuralGeneralization.OnlineLowerTanh
