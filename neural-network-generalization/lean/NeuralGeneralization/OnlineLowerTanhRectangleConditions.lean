import NeuralGeneralization.OnlineLowerTanhPairedBudget
import NeuralGeneralization.OnlineLowerTanhDominanceParameters
import NeuralGeneralization.OnlineLowerTanhPathDistinguishedBudget

/-! Actual rectangle cost conditions for every fixed logarithmic rail constant. -/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

/-- All scalar hypotheses of the common rectangle dual hold for the actual
optimized odd-parity costs, with the paper's literal integer construction. -/
theorem construction_rectangle_cost_conditions_eventually (b:ActualGainBranch)
    (K:ℕ) (hK:1≤K) :
    ∀ᶠk:ℕ in atTop,
      RectangleCostConditions
        (codeBalancedCost (physicalCode (constructionBaseline K k) (constructionIncrement k) k
          (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k))) (shiftPoint k) := by
  obtain ⟨S,U,hS,hU,hbranch,hpair⟩:=codeBalancedCost_paired_budget b
  obtain ⟨Umin,hUmin,hbmin,hmin⟩:=exists_scalarSupportWeight_min_threshold b
  filter_upwards [construction_dominance_parameters K hK 4096 S
      (max U (max Umin (12*optimizedCostCurvature))) (by norm_num) hS,
    construction_distinguished_bounds_eventually b K hK,
    construction_distinguished_scale_eventually b K hK] with k hparams hdist hscale
  dsimp only at hparams hdist hscale ⊢
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  let C:=physicalCode R H k (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)
  let w:=codeBalancedCost C
  let n:ℝ:=(pairDim R H k:ℝ)*R+1
  let d:ℝ:=dimension R H k
  let old:ℝ:=4*OnlineLowerRelu.Family.pairDim k
  let W:=rectangleWeightTransform w (shiftPoint k)
  have hn:0<n:=by dsimp [n];positivity
  have hd:0<d:=by dsimp [d,R,H]; exact_mod_cast (constructionDimension_pos K k)
  have hH:0<(H:ℝ):=Nat.cast_pos.mpr (constructionIncrement_pos k)
  have hold:0≤old:=by positivity
  have hUn:U≤n:=(le_max_left _ _).trans hparams.1
  have hUminn:Umin≤n:=(le_max_left _ _).trans ((le_max_right _ _).trans hparams.1)
  have hCbase:12*optimizedCostCurvature≤n:=(le_max_right _ _).trans ((le_max_right _ _).trans hparams.1)
  have hP:rectanglePairedTotal w (shiftPoint k)≤
      (3*optimizedCostCurvature/(4*n^3))*(old*(old+2*H)):=
    hpair R H k _ _ (constructionBaseline_even K k) (constructionIncrement_even k)
      hUn hparams.2.1
  have hpaired:rectanglePairedTotal w (shiftPoint k)≤W/4:=
    paired_budget_absorbed optimizedCostCurvature n d H old W _ optimizedCostCurvature_pos
      hn hd hH hold hparams.2.2.1 hparams.2.2.2.2.2 hP hdist.1
  have hsmall:W≤(1:ℝ)/16:=by
    apply hdist.2.1.trans
    apply (div_le_iff₀ (by positivity : 0<4*n^3)).mpr
    have hs:(H:ℝ)^2≤n^2:=pow_le_pow_left₀ hH.le hparams.2.2.2.2.1 2
    have hC:=optimizedCostCurvature_pos
    have ha:=mul_le_mul_of_nonneg_left hs (show 0≤12*optimizedCostCurvature by positivity)
    have hb:=mul_le_mul_of_nonneg_right hCbase (sq_nonneg n)
    nlinarith only [ha,hb]
  refine ⟨logicalCube_card_ge_sixtyfour k,codeBalancedCost_pos C ∅,?_,
    hdist.2.2.1,?_,hpaired,hscale⟩
  · intro s
    have he:=codeBalancedCost_eq_scalarSupportWeight b R H k
      (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)
      (constructionBaseline_even K k) (constructionIncrement_even k)
      (by simpa only [n,Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hbranch.trans_le hUn)
    change codeBalancedCost C ∅≤codeBalancedCost C s
    rw [he]
    exact hmin R H k (by simpa only [n,Nat.cast_add,Nat.cast_mul,Nat.cast_one] using hUminn) s
  · have hw:1≤w ∅:=balancedCost_ge_one _
    exact hsmall.trans (by linarith)

end NeuralGeneralization.OnlineLowerTanh.Family
