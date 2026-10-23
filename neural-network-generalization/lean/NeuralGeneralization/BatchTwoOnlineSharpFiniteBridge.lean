import NeuralGeneralization.BatchTwoOnlineSharpPowerThreshold

/-! Statistical assembly with the exact finite-scale K,T,h,J formulas.
The target-mass input is explicit here; a neural cylinder theorem must
supply it before this bridge is a standalone network corollary. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel BatchTwoOnline MeasureTheory

def onlineEnergy (d r : ℕ) (A : ℝ) : ℝ :=
  4*A+8*Real.log (((r:ℝ)+2)*(Fintype.card (Cube d):ℝ))

theorem onlineEnergy_ge_four (d r : ℕ) {A : ℝ} (hA : 1≤A) : 4≤onlineEnergy d r A := by
  have hm:1≤(Fintype.card (Cube d):ℝ):=by exact_mod_cast Fintype.card_pos
  have hr:0≤(r:ℝ):=Nat.cast_nonneg _
  have hl:0≤Real.log (((r:ℝ)+2)*(Fintype.card (Cube d):ℝ)):=Real.log_nonneg (by nlinarith)
  unfold onlineEnergy
  linarith

theorem online_tail_ratio {d r : ℕ} {A mass tail speed : ℝ}
    (htail : tail≤((r:ℝ)+2)*Real.exp (-(onlineEnergy d r A)*speed/8))
    (hmass : Real.exp (-A*speed/2)≤mass) (hspeed : 1≤speed) :
    tail/mass≤1/(Fintype.card (Cube d):ℝ) := by
  have hm:1≤(Fintype.card (Cube d):ℝ):=by exact_mod_cast Fintype.card_pos
  apply exponential_tail_ratio_prefactor_le tail mass ((r:ℝ)+2) (A/2)
    (onlineEnergy d r A/8) speed (1/Fintype.card (Cube d))
    (by convert htail using 1 <;> congr 2 <;> ring)
    (by convert hmass using 1 <;> congr 1 <;> ring)
    (by linarith [Nat.cast_nonneg r (α:=ℝ)]) hspeed (by positivity)
    (by exact (div_le_one (by positivity)).mpr hm)
  have he:((r:ℝ)+2)/(1/(Fintype.card (Cube d):ℝ))=((r:ℝ)+2)*(Fintype.card (Cube d):ℝ):=by simp
  rw [he]
  unfold onlineEnergy
  linarith

theorem aboveMeanField_large_online_of_mass {d C N r : ℕ} {A γ : ℝ}
    (hd : 1≤d) (hN : 0<N) (hA : 1≤A) (hγ : 1<γ)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hTN : powerWidthThreshold d C r (onlineEnergy d r A) γ≤N)
    (hmass : Real.exp (-A*(N:ℝ)^γ/2)≤functionMass φ (1/2) (powerPrior d N r γ) f) :
    NetworkOnlineBounds φ (1/2) (powerPrior d N r γ) f
      (normCapacity d r (((r:ℝ)+5)*onlineEnergy d r A)) := by
  have hK:1≤onlineEnergy d r A:=by linarith [onlineEnergy_ge_four d r hA]
  obtain ⟨_,hf,hm⟩:=powerWidthThreshold_conditions hγ hTN
  have htail:=powerPrior_normFunctions_tail hd hN hK φ hφ hf hm
  have hratio:=online_tail_ratio htail hmass (one_le_width_power hN hγ.le)
  have hpos:0<functionMass φ (1/2) (powerPrior d N r γ) f:=(Real.exp_pos _).trans_le hmass
  apply network_online_of_randomOrder hd φ (1/2) _ f _ (normCapacity_nonneg _ _ _) hpos
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg φ (1/2) _) _ f
    (fun _=>rfl) hpos (normFunctions d r φ (((r:ℝ)+5)*onlineEnergy d r A)) _ _
    (normCapacity_nonneg _ _ _) (by positivity) (normFunctions_card (by positivity) φ hφ) hratio

theorem aboveMeanField_small_prior_cost {d C N r : ℕ} {A γ : ℝ}
    (hN : 0<N) (hA : 1≤A) (hγ : 1<γ)
    (φ : ℝ→ℝ) (f : BooleanFunction d)
    (hNT : N≤powerWidthThreshold d C r (onlineEnergy d r A) γ)
    (hmass : Real.exp (-A*(N:ℝ)^γ/2)≤functionMass φ (1/2) (powerPrior d N r γ) f) :
    -Real.log (functionMass φ (1/2) (powerPrior d N r γ) f)≤
      A*(powerWidthThreshold d C r (onlineEnergy d r A) γ:ℝ)^γ/2 := by
  have hh:=Real.log_le_log (Real.exp_pos _) hmass
  rw [Real.log_exp] at hh
  have hp:((N:ℝ)^γ)≤(powerWidthThreshold d C r (onlineEnergy d r A) γ:ℝ)^γ:=
    Real.rpow_le_rpow (Nat.cast_nonneg _) (by exact_mod_cast hNT) (by linarith)
  have hh':=mul_le_mul_of_nonneg_left hp (show 0≤A by linarith)
  linarith

theorem aboveMeanField_small_total_of_mass {d C N r : ℕ} {A γ : ℝ}
    (hN : 0<N) (hA : 1≤A) (hγ : 1<γ)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hNT : N≤powerWidthThreshold d C r (onlineEnergy d r A) γ)
    (hmass : Real.exp (-A*(N:ℝ)^γ/2)≤functionMass φ (1/2) (powerPrior d N r γ) f)
    (query : ℕ→Cube d) :
    totalError (functionMass φ (1/2) (powerPrior d N r γ)) (fun g x=>g x=f x) query≤
      ENNReal.ofReal (A*(powerWidthThreshold d C r (onlineEnergy d r A) γ:ℝ)^γ/2) := by
  apply (network_totalError_le_prior_cost (admissibleActivation_continuous hφ)
    (1/2) (by norm_num) _ f ((Real.exp_pos _).trans_le hmass) query).trans
  exact ENNReal.ofReal_le_ofReal (aboveMeanField_small_prior_cost hN hA hγ φ f hNT hmass)

end NeuralGeneralization.BatchTwoOnlineSharp
