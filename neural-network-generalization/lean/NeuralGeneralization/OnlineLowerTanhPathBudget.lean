import NeuralGeneralization.OnlineLowerTanhPathStrict
import NeuralGeneralization.OnlineLowerTanhResources

/-! # Actual logarithmic rail parameters satisfy the path-order budget -/

noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

theorem constructionBaseline_eventually_ge (K : ℕ) (hK : 1≤K) (L : ℝ) :
    ∀ᶠ k : ℕ in atTop, L≤(constructionBaseline K k : ℝ) := by
  filter_upwards [log_nat_eventually_ge (max 1 L), eventually_ge_atTop 2] with k hlog hk
  have hl : max 1 L≤constructionLog k := hlog.trans (constructionLog_comparison k hk).1
  have h1 : 1≤constructionLog k := (le_max_left _ _).trans hl
  have hL : L≤constructionLog k := (le_max_right _ _).trans hl
  have hKr : (1 : ℝ)≤K := by exact_mod_cast hK
  have hbase := (constructionBaseline_bounds K k).1
  have hm := mul_nonneg (sub_nonneg.mpr hKr) (sq_nonneg (constructionLog k))
  nlinarith

theorem pairDim_ge_path_order (R H k : ℕ) :
    OnlineLowerRelu.Family.prefixDim k+k+1≤pairDim R H k := by
  unfold pairDim OnlineLowerRelu.Family.prefixDim
  rw [OnlineLowerRelu.Family.pairDim_eq]
  omega

/-- Every fixed derivative threshold is met by the actual `log²` rails;
the number of differences remains linear in the path index. -/
theorem construction_path_order_budget (K : ℕ) (hK : 1≤K) (T S : ℝ) (hS : 0<S) :
    ∀ᶠ k : ℕ in atTop,
      T<((pairDim (constructionBaseline K k) (constructionIncrement k) k *
        constructionBaseline K k+1 : ℕ) : ℝ) ∧
      S*(OnlineLowerRelu.Family.prefixDim k+k+1 : ℕ)≤
        (pairDim (constructionBaseline K k) (constructionIncrement k) k : ℝ)*
          constructionBaseline K k+1+constructionIncrement k := by
  filter_upwards [constructionBaseline_eventually_ge K hK (max S (T+1))] with k hk
  let R := constructionBaseline K k
  let H := constructionIncrement k
  have hR : S≤(R : ℝ) := (le_max_left _ _).trans hk
  have hT : T+1≤(R : ℝ) := (le_max_right _ _).trans hk
  have hp : OnlineLowerRelu.Family.prefixDim k+k+1≤pairDim R H k := pairDim_ge_path_order R H k
  have hp1 : 1≤pairDim R H k := by omega
  have hp1r : (1 : ℝ)≤pairDim R H k := by exact_mod_cast hp1
  have hpR : (R : ℝ)≤(pairDim R H k : ℝ)*R := by
    nlinarith [mul_nonneg (by linarith : 0≤(pairDim R H k : ℝ)-1) (Nat.cast_nonneg (α:=ℝ) R)]
  constructor
  · change T<((pairDim R H k*R+1 : ℕ) : ℝ)
    rw [Nat.cast_add, Nat.cast_mul, Nat.cast_one]
    linarith
  · change S*(OnlineLowerRelu.Family.prefixDim k+k+1 : ℕ)≤(pairDim R H k : ℝ)*R+1+H
    have hpr : ((OnlineLowerRelu.Family.prefixDim k+k+1 : ℕ) : ℝ)≤pairDim R H k := by exact_mod_cast hp
    have hm := mul_le_mul hpr hR hS.le (Nat.cast_nonneg (α:=ℝ) (pairDim R H k))
    nlinarith [Nat.cast_nonneg (α:=ℝ) H]

/-- The literal odd-support balanced tanh costs are injective at the
paper's actual logarithmic rails, for every fixed positive rail constant. -/
theorem construction_candidate_injective_eventually (b : ActualGainBranch)
    (K : ℕ) (hK : 1≤K) :
    ∀ᶠ k : ℕ in atTop, 1≤k ∧ ∀hk : 1≤k, ∀endpoint : Bool,
      Function.Injective (fun digits : CandidateDigits k =>
        rectangleEffectiveCost
          (codeBalancedCost (physicalCode (constructionBaseline K k) (constructionIncrement k) k
            (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)))
          (shiftPoint k) (candidatePoint k hk endpoint digits)) := by
  obtain ⟨S,hS,hinj⟩ := exists_candidate_rectangle_injective_threshold b
  filter_upwards [construction_path_order_budget K hK b.threshold S hS,
    eventually_ge_atTop 1] with k hb hk
  refine ⟨hk,?_⟩
  intro hk endpoint
  exact hinj _ _ k _ _ (constructionBaseline_even K k) (constructionIncrement_even k)
    hk hb.1 hb.2 endpoint

theorem construction_candidate_cost_count_eventually (b : ActualGainBranch)
    (K : ℕ) (hK : 1≤K) :
    ∀ᶠ k : ℕ in atTop, 1≤k ∧ ∀hk : 1≤k, ∀endpoint : Bool,
      (Finset.univ.image (fun digits : CandidateDigits k =>
        rectangleEffectiveCost
          (codeBalancedCost (physicalCode (constructionBaseline K k) (constructionIncrement k) k
            (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)))
          (shiftPoint k) (candidatePoint k hk endpoint digits))).card=2^(k-1) := by
  filter_upwards [construction_candidate_injective_eventually b K hK] with k hk
  refine ⟨hk.1,?_⟩
  intro hk' endpoint
  rw [Finset.card_image_of_injective _ (hk.2 hk' endpoint)]
  simp [CandidateDigits]

end NeuralGeneralization.OnlineLowerTanh.Family
