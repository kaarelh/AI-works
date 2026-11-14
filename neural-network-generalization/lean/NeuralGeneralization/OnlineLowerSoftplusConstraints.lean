import NeuralGeneralization.OnlineLowerReluConstraintBridge
import NeuralGeneralization.OnlineLowerSoftplusCompact
import NeuralGeneralization.OnlineLowerOffsetOutputBound
import NeuralGeneralization.OnlineLowerSoftplusBasic

/-! # Activation-independent membership in the calibrated score constraints -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower OnlineLowerRelu OnlineLowerGeometry

theorem actual_mem_score_constraints {p m N : ℕ}
    (φ : ℝ → ℝ) (size : Fin p → Bool → ℕ) (column : Fin p → Finset (Fin m))
    (hsize : ∀ i b, 0 < size i b) (hd : 0 < railDimension size)
    (C : WalshCodeMap (railDimension size) m)
    (hsupport : ∀ s, C.support s = generatedSupport (physicalBase size)
      (coordinateGenerator (physicalColumn size column)) s)
    (weight : Finset (Fin m) → ℝ) (H : CubeSubgroup m) (v : ClippingCube m)
    (live : ClippingCube m → Prop)
    (hv : v ∉ H.carrier) (hcard : 2 ≤ (H.differenceAnnihilator v).card)
    (hw0 : 0 < weight ∅) (hw : ∀ s, weight ∅ ≤ weight s)
    (hsum : 6*weight ∅ ≤ ∑ s,weight s)
    (hcostsign : ∀ z,z ≠ cubeOne m → walshExpansion weight z ≤ 0)
    (hdetect : ∀ i,logicalColumnPoint column i ∉ H.carrier)
    (net : Weights (railDimension size) N 0) (K Bcap Hcap : ℝ)
    (hK : 0 ≤ K) (hHcap : 0 ≤ Hcap) (hBcap10 : Bcap ≤ 10*weight ∅)
    (hscore : ∀ x,|networkOutput φ net x| ≤ Hcap)
    (hmargin : ∀ x,(1:ℝ)/2 ≤ |networkOutput φ net x|)
    (hcal : ∀ x,cubeTranslation v (C.syndrome x) ∉ H.carrier →
      (1:ℝ)/2 ≤ (if C.syndrome x = cubeOne m then 1 else -1)*
        (C.base x*networkOutput φ net x))
    (hremoved : ∀ z,¬live z → reluLiveMass H v (C.logicalProjection (networkOutput φ net)) z ≤ 0)
    (hcap : weightedSquaredNorm net ≤ (2*Real.sqrt (railDimension size:ℝ))*Bcap)
    (hcost : weightedWalshCost weight (C.logicalProjection (networkOutput φ net)) ≤ networkVariationBudget net)
    (hdownward : uniformCubeMean (fun x => (networkOutput φ net x -
      fourierProject (railDownwardSupports size column) (networkOutput φ net) x)^2) ≤
        K*networkVariationBudget net*(networkVariationBudget net-
          weightedWalshCost weight (C.logicalProjection (networkOutput φ net)))) :
    (weightedSquaredNorm net,networkOutput φ net) ∈
      C.reluScoreConstraints weight H v live (2*Real.sqrt (railDimension size:ℝ))
        (8*Hcap/weight ∅+5*K*Bcap) := by
  let scale : ℝ := 2*Real.sqrt (railDimension size:ℝ)
  have hs : 0 < scale := mul_pos (by norm_num) (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd))
  have hB : 0 ≤ networkVariationBudget net := div_nonneg (weightedSquaredNorm_nonneg net) hs.le
  have hbudget : networkVariationBudget net ≤ Bcap := by
    apply (div_le_iff₀ hs).mpr
    simpa only [mul_comm] using hcap
  have hvariance := relu_variance_budget_of_downward_deficit size column hsize C hsupport
    weight H v hv hcard hw0 hw hsum hcostsign hdetect (networkOutput φ net)
    (networkVariationBudget net) Hcap K Bcap hB hHcap hK hscore hcal hcost hbudget hdownward
  refine ⟨hmargin,hcal,hcost,?_,hremoved,hvariance⟩
  apply (div_le_iff₀ hw0).mpr
  exact hbudget.trans hBcap10

lemma softplus_growth_one (t : ℝ) : |softplus t| ≤ |t|+1 := by
  have hl : Real.log 2 ≤ 1 := by
    have := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    linarith
  have hh := softplus_growth t
  linarith

lemma softplus_output_le_twice_cap {d N : ℕ} (hd : 0<d) (hN : 0<N)
    (net : Weights d N 0) (cap : ℝ) (hcap : 1≤cap)
    (hw : weightedSquaredNorm net≤cap) (x : Cube d) :
    |networkOutput softplus net x|≤2*cap := by
  have hh := networkOutput_abs_le_offset_cap hd hN softplus 1 (by norm_num)
    softplus_growth_one net cap hw x
  have hsq : Real.sqrt cap ≤ cap := by
    have hpos := Real.sqrt_nonneg cap
    have he := Real.sq_sqrt (by linarith : 0≤cap)
    nlinarith
  simp only [one_mul] at hh
  exact hh.trans (by linarith : cap+Real.sqrt cap≤2*cap)

end NeuralGeneralization.OnlineLowerSoftplus
