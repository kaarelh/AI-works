import NeuralGeneralization.OnlineLowerGeometrySubcodeStability
import NeuralGeneralization.OnlineLowerReluAbsorption
import NeuralGeneralization.OnlineLowerReluFamilyWeights
import NeuralGeneralization.OnlineLowerGeometryReluCalibration

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open OnlineLowerRelu OnlineLowerGeometry

theorem rail_monomial_dominates (p R:ℝ) (hp:1≤p) (hR:2≤R) :
    2≤p*R ∧ p*R≤p^3*R^5 := by
  have hp0:0≤p:=by linarith
  have hR0:0≤R:=by linarith
  have hp3:p≤p^3:=by simpa only [pow_one] using pow_le_pow_right₀ hp (show 1≤3 by norm_num)
  have hR5:R≤R^5:=by simpa only [pow_one] using pow_le_pow_right₀ (by linarith:1≤R) (show 1≤5 by norm_num)
  exact ⟨by nlinarith,mul_le_mul hp3 hR5 hR0 (by positivity)⟩

theorem rail_score_scale_bound (p R d:ℝ) (hp:1≤p) (hR:2≤R)
    (hd:0≤d) (hdmax:d≤4*p*R) : 2*Real.sqrt d≤4*p*R := by
  have hpr:2≤p*R:=(rail_monomial_dominates p R hp hR).1
  have hs:=Real.sq_sqrt hd
  have hs0:=Real.sqrt_nonneg d
  nlinarith [mul_nonneg (by linarith:0≤p*R-1) (by linarith:0≤p*R)]

/-- Constants in the physical variance estimate, under the sharper
published competitor budget `B ≤ 10 p R`. -/
theorem physical_variance_coefficient_bound (p R κ K:ℝ)
    (hp:1≤p) (hR:2≤R) (hκ:κ≤4*p*R)
    (hK:K≤2^16*p^2*R^4) :
    80*κ+50*K*p*R≤2^22*p^3*R^5 := by
  have hpr:0≤p*R:=by nlinarith
  have hmono: p*R≤p^3*R^5:=(rail_monomial_dominates p R hp hR).2
  have hU:0≤p^3*R^5:=by positivity
  have hKm:=mul_le_mul_of_nonneg_right hK hpr
  calc
    80*κ+50*K*p*R≤320*(p*R)+50*(2^16*p^2*R^4)*(p*R) := by nlinarith
    _ ≤ 320*(p^3*R^5)+50*(2^16*p^2*R^4)*(p*R) := by linarith
    _ = (320+50*2^16)*(p^3*R^5) := by ring
    _ ≤ _ := by nlinarith

/-- The final linear-rounding coefficient is bounded by the exact envelope
used by the prefix-absorption calculation. -/
theorem rounding_coefficient_bound (M p R w₀ β:ℝ)
    (hM:0≤M) (hp:1≤p) (hR:2≤R) (hw:p*R≤w₀)
    (hβ:β≤2^22*p^3*R^5) :
    M*(45/(2*w₀)+6*β)≤2^25*M*p^3*R^5 := by
  have hpr:2≤p*R:=(rail_monomial_dominates p R hp hR).1
  have hmono:p*R≤p^3*R^5:=(rail_monomial_dominates p R hp hR).2
  have hwpos:0<2*w₀:=by linarith
  have hdiv:45/(2*w₀)≤12:=by apply (div_le_iff₀ hwpos).mpr; linarith
  have hU:1≤p^3*R^5:=by linarith
  have hinside:45/(2*w₀)+6*β≤2^25*(p^3*R^5):=by nlinarith
  have hh:=mul_le_mul_of_nonneg_left hinside hM
  nlinarith

theorem family_rounding_coefficient_bound (R:ℝ) (k:ℕ) (hR:2≤R)
    (w₀ β:ℝ) (hw:(Family.pairDim k:ℝ)*R≤w₀)
    (hβ:β≤2^22*(Family.pairDim k:ℝ)^3*R^5) :
    (2:ℝ)^(Family.logicalDim k)*(45/(2*w₀)+6*β)≤reluRoundingEnvelope R k := by
  have hp:(1:ℝ)≤Family.pairDim k := by exact_mod_cast (show 1≤Family.pairDim k by rw [Family.pairDim_eq]; omega)
  have hh:=rounding_coefficient_bound ((2:ℝ)^(Family.logicalDim k)) (Family.pairDim k) R w₀ β
    (by positivity) hp hR hw hβ
  unfold reluRoundingEnvelope
  rw [show (2:ℝ)^(25+Family.logicalDim k)=2^25*2^(Family.logicalDim k) from pow_add _ _ _]
  exact hh

/-- The variance coefficient returned by the actual calibrated-score
lemma is bounded without modifying its exact budget expression. -/
theorem exact_variance_coefficient_le (p R κ K w₀:ℝ)
    (hp:1≤p) (hR:2≤R) (hκ:0≤κ) (hw:p*R≤w₀) :
    8*(κ*(10*p*R))/w₀+5*K*(10*p*R)≤80*κ+50*K*p*R := by
  have hpr:2≤p*R:=(rail_monomial_dominates p R hp hR).1
  have hwpos:0<w₀:=by linarith
  have hratio:8*(κ*(10*p*R))/w₀≤80*κ := by
    apply (div_le_iff₀ hwpos).mpr
    have hm:=mul_le_mul_of_nonneg_left hw (by positivity:0≤80*κ)
    nlinarith
  nlinarith

/-- Direct final envelope for the precise coefficient occurring in the
actual finite-dimensional calibrated-score constraints. -/
theorem family_exact_rounding_coefficient_bound (R:ℝ) (k:ℕ) (hR:2≤R)
    (κ K w₀:ℝ) (hκ0:0≤κ) (hκ:κ≤4*(Family.pairDim k:ℝ)*R)
    (hK:K≤2^16*(Family.pairDim k:ℝ)^2*R^4)
    (hw:(Family.pairDim k:ℝ)*R≤w₀) :
    (2:ℝ)^(Family.logicalDim k)*(45/(2*w₀)+
      6*(8*(κ*(10*(Family.pairDim k:ℝ)*R))/w₀+
        5*K*(10*(Family.pairDim k:ℝ)*R)))≤reluRoundingEnvelope R k := by
  have hp:(1:ℝ)≤Family.pairDim k := by
    exact_mod_cast (show 1≤Family.pairDim k by rw [Family.pairDim_eq]; omega)
  apply family_rounding_coefficient_bound R k hR w₀ _ hw
  exact (exact_variance_coefficient_le (Family.pairDim k) R κ K w₀ hp hR hκ0 hw).trans
    (physical_variance_coefficient_bound (Family.pairDim k) R κ K hp hR hκ hK)

end NeuralGeneralization.OnlineLower

namespace NeuralGeneralization.OnlineLowerRelu.Family
open OnlineLower OnlineLowerGeometry

theorem actual_family_score_scale_bound (R k:ℕ) (hR:2≤R) :
    2*Real.sqrt (railDimension (size R k):ℝ)≤4*(pairDim k:ℝ)*R := by
  have hp:(1:ℝ)≤pairDim k := by exact_mod_cast (show 1≤pairDim k by rw [pairDim_eq]; omega)
  have hRr:(2:ℝ)≤R := by exact_mod_cast hR
  apply rail_score_scale_bound (pairDim k) R (railDimension (size R k)) hp hRr
    (Nat.cast_nonneg _)
  rw [physicalDimension_eq]
  push_cast
  have hprod:=mul_nonneg (Nat.cast_nonneg (pairDim k): (0:ℝ)≤pairDim k)
    (by linarith:0≤(R:ℝ)-2)
  norm_num only [pairDim,prefixDim,pathDim,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat] at hprod ⊢
  nlinarith

/-- The actual calibrated constant is below the sharper `10 p R` budget;
negative nonconstant costs then make every live star cheaper still. -/
theorem calibrationConstant_lt_ten_base (R k:ℕ) (hR:4≤R) (heven:Even R)
    (H:CubeSubgroup (logicalDim k)) (v:ClippingCube (logicalDim k))
    (hv:v∉H.carrier) (hcard:0<(H.differenceAnnihilator v).card) :
    reluCalibrationConstant (weight R k) H v<10*(pairDim k:ℝ)*R := by
  have hR2:2≤R:=by omega
  have hp0:(0:ℝ)<pairDim k:=by exact_mod_cast (show 0<pairDim k by rw [pairDim_eq]; omega)
  have hRr:(4:ℝ)≤R:=by exact_mod_cast hR
  have hmax (s:Finset (Fin (logicalDim k))) : weight R k s≤3*(pairDim k:ℝ)*(R+4) := by
    have hh:=(weight_card_bounds R k hR2 heven s).2
    have hc:((targetSupport R k s).card:ℝ)≤(pairDim k:ℝ)*(R+4):=by
      exact_mod_cast (support_card_bounds R k s).2
    nlinarith
  have hw0:weight R k ∅≤3*(pairDim k:ℝ)*R := by
    have hh:=(weight_card_bounds R k hR2 heven ∅).2
    rw [targetSupport_empty_card] at hh
    convert hh using 1 <;> push_cast <;> ring
  have hwpos:=weight_pos R k hR2 heven ∅
  have hM:(0:ℝ)<Fintype.card (ClippingCube (logicalDim k)):=Nat.cast_pos.mpr Fintype.card_pos
  have hsum:(∑s,weight R k s)/Fintype.card (ClippingCube (logicalDim k))≤
      3*(pairDim k:ℝ)*(R+4) := by
    apply (div_le_iff₀ hM).mpr
    have hh:=Finset.sum_le_sum (fun s (_:s∈Finset.univ)=>hmax s)
    have hcardeq:Fintype.card (Finset (Fin (logicalDim k)))=Fintype.card (ClippingCube (logicalDim k)):=by
      simp [ClippingCube]
    simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,hcardeq,mul_comm] using hh
  rw [reluCalibrationConstant_formula (weight R k) H v hv hcard]
  have hpos:0≤4*weight R k ∅/Fintype.card (ClippingCube (logicalDim k)):=by positivity
  nlinarith [mul_nonneg hp0.le (by linarith:(0:ℝ)≤R-4)]

theorem star_cost_lt_ten_base (R k:ℕ) (hR:4≤R) (heven:Even R)
    (H:CubeSubgroup (logicalDim k)) (v z:ClippingCube (logicalDim k))
    (hv:v∉H.carrier) (hz:cubeTranslation v z∈H.carrier)
    (hcard:0<(H.differenceAnnihilator v).card)
    (hnegative:walshExpansion (weight R k) z≤0) :
    weightedWalshCost (weight R k) (reluStar z)<10*(pairDim k:ℝ)*R := by
  have hM:4≤Fintype.card (ClippingCube (logicalDim k)) := by
    simp only [ClippingCube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin]
    have h:=Nat.pow_le_pow_right (by norm_num:1≤2) (show 2≤logicalDim k by rw [logicalDim_eq]; omega)
    exact (by norm_num : 4≤2^2).trans h
  rw [reluStar_exact_cost (weight R k) H v z hv hz hcard hM]
  have hcost:=calibrationConstant_lt_ten_base R k hR heven H v hv hcard
  have hn:walshExpansion (weight R k) z/Fintype.card (ClippingCube (logicalDim k))≤0:=
    div_nonpos_of_nonpos_of_nonneg hnegative (Nat.cast_nonneg _)
  linarith

end NeuralGeneralization.OnlineLowerRelu.Family
