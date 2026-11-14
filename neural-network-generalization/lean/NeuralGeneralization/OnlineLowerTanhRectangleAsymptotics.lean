import NeuralGeneralization.OnlineLowerTanhPathStrict
import NeuralGeneralization.OnlineLowerTanhPrefixPositive
import NeuralGeneralization.OnlineLowerTanhOptimizedGain

/-! A stronger finite threshold and its growing-family rectangle-cost corollary. -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower

/-- Linear in k; this threshold is weaker than n/(m log n)→∞. -/
def rectangleOrderSize (k:ℕ):ℕ:=
  OnlineLowerRelu.Family.pairDim k+OnlineLowerRelu.Family.prefixDim k+k+2

/-- Literal scalar rectangle costs of the optimized tanh prior. The physical
Fourier identification is `candidate_rectangle_codeBalancedCost_eq`. -/
def optimizedRectangleCost (k:ℕ) (hk:1≤k) (n H:ℝ) (endpoint:Bool)
    (digits:Fin (k-1)→Bool):ℝ:=
  -FamilyCost.candidateCost k hk (n+H) (optimizedRealCost actualGainBranch) endpoint digits

theorem optimized_rectangle_finite_order :
    ∃S:ℝ,0<S ∧ ∀k:ℕ,∀hk:1≤k,∀n H:ℝ,0≤H →
      S*(rectangleOrderSize k:ℝ)≤n → ∀endpoint:Bool,
      (∀digits:Fin (k-1)→Bool,optimizedRectangleCost k hk n H endpoint digits<0) ∧
      Function.Injective (optimizedRectangleCost k hk n H endpoint) ∧
      (∀xs ys:Fin (k-1)→Bool,digitLexLt (List.ofFn xs) (List.ofFn ys) →
        optimizedRectangleCost k hk n H endpoint ys<optimizedRectangleCost k hk n H endpoint xs) := by
  obtain ⟨S₁,hS₁,hpos⟩:=optimizedRealCost_old_prefix_positive actualGainBranch
  obtain ⟨S₂,hS₂,horder⟩:=optimizedRealCost_prefixed_strict actualGainBranch
  refine ⟨max S₁ S₂,lt_of_lt_of_le hS₁ (le_max_left _ _),?_⟩
  intro k hk n H hH hn endpoint
  have hsize₁:(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤rectangleOrderSize k:=by
    unfold rectangleOrderSize;omega
  have hsize₂:(OnlineLowerRelu.Family.prefixDim k+(k-1)+2:ℕ)≤rectangleOrderSize k:=by
    unfold rectangleOrderSize;omega
  have hnp:S₁*(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤n+H:=by
    have hh:=mul_le_mul (le_max_left S₁ S₂) (show ((OnlineLowerRelu.Family.pairDim k+1:ℕ):ℝ)≤rectangleOrderSize k by exact_mod_cast hsize₁)
      (by positivity) (lt_of_lt_of_le hS₁ (le_max_left _ _)).le
    linarith
  have hno:S₂*(OnlineLowerRelu.Family.prefixDim k+(k-1)+2:ℕ)≤n+H:=by
    have hh:=mul_le_mul (le_max_right S₁ S₂) (show ((OnlineLowerRelu.Family.prefixDim k+(k-1)+2:ℕ):ℝ)≤rectangleOrderSize k by exact_mod_cast hsize₂)
      (by positivity) (lt_of_lt_of_le hS₂ (le_max_right _ _)).le
    linarith
  have hord (xs ys:Fin (k-1)→Bool) (hlex:digitLexLt (List.ofFn xs) (List.ofFn ys)) :
      optimizedRectangleCost k hk n H endpoint ys<optimizedRectangleCost k hk n H endpoint xs:=by
    unfold optimizedRectangleCost
    rw [neg_lt_neg_iff,FamilyCost.candidateCost_eq_prefixed,FamilyCost.candidateCost_eq_prefixed]
    exact horder _ (by unfold OnlineLowerRelu.Family.prefixDim;omega) endpoint _ _ (by simp)
      _ (by simpa using hno) hlex
  refine ⟨?_,?_,hord⟩
  · intro digits
    exact neg_neg_of_pos (hpos k (n+H) hnp (FamilyCost.candidatePathSupport k hk endpoint digits))
  · intro xs ys he
    by_contra hne
    have hlist:List.ofFn xs≠List.ofFn ys:=fun hh=>hne (List.ofFn_injective hh)
    rcases digitLexLt_or_reverse (by simp : (List.ofFn xs).length=(List.ofFn ys).length) hlist with h | h
    · exact (hord xs ys h).ne he.symm
    · exact (hord ys xs h).ne he

/-- Arbitrarily growing baselines/increments; no upper bound H≤C n is needed. -/
theorem optimized_rectangle_growing_order (n H:ℕ→ℝ) (hH:∀k,0≤H k)
    (hn:Tendsto (fun k=>n k/(rectangleOrderSize k:ℝ)) atTop atTop) :
    ∀ᶠk in atTop,∃hk:1≤k,∀endpoint:Bool,
      (∀digits:Fin (k-1)→Bool,optimizedRectangleCost k hk (n k) (H k) endpoint digits<0) ∧
      Function.Injective (optimizedRectangleCost k hk (n k) (H k) endpoint) ∧
      (∀xs ys:Fin (k-1)→Bool,digitLexLt (List.ofFn xs) (List.ofFn ys) →
        optimizedRectangleCost k hk (n k) (H k) endpoint ys<optimizedRectangleCost k hk (n k) (H k) endpoint xs) ∧
      Fintype.card (Fin (k-1)→Bool)=2^(k-1) := by
  obtain ⟨S,hS,horder⟩:=optimized_rectangle_finite_order
  filter_upwards [hn.eventually (eventually_ge_atTop S),eventually_ge_atTop (1:ℕ)] with k hkS hk
  have hp:(0:ℝ)<rectangleOrderSize k:=by
    exact_mod_cast (show 0<rectangleOrderSize k by unfold rectangleOrderSize;omega)
  have hnk:S*(rectangleOrderSize k:ℝ)≤n k:=(le_div_iff₀ hp).mp hkS
  refine ⟨hk,?_⟩
  intro endpoint
  have hh:=horder k hk (n k) (H k) (hH k) hnk endpoint
  exact ⟨hh.1,hh.2.1,hh.2.2,by simp⟩
lemma paper_baseline_growth_implies_rectangle_growth (n:ℕ→ℝ)
    (hn:Tendsto n atTop atTop)
    (hg:Tendsto (fun k=>n k/(((6*k+6:ℕ):ℝ)*Real.log (n k))) atTop atTop) :
    Tendsto (fun k=>n k/(rectangleOrderSize k:ℝ)) atTop atTop := by
  apply tendsto_atTop.mpr
  intro B
  have hM:0<max B 1:=lt_of_lt_of_le (by norm_num) (le_max_right _ _)
  filter_upwards [hg.eventually (eventually_ge_atTop (3*max B 1)),
    hn.eventually (eventually_ge_atTop (Real.exp 1))] with k hk hnk
  have hn0:0<n k:=(Real.exp_pos 1).trans_le hnk
  have hlog:1≤Real.log (n k):=by
    have hh:=Real.log_le_log (Real.exp_pos 1) hnk
    simpa only [Real.log_exp] using hh
  have hm:(0:ℝ)<(6*k+6:ℕ):=by positivity
  have hd:(0:ℝ)<rectangleOrderSize k:=by
    exact_mod_cast (show 0<rectangleOrderSize k by unfold rectangleOrderSize;omega)
  have hdim:(rectangleOrderSize k:ℝ)≤3*((6*k+6:ℕ):ℝ):=by
    exact_mod_cast (show rectangleOrderSize k≤3*(6*k+6) by
      unfold rectangleOrderSize
      rw [OnlineLowerRelu.Family.pairDim_eq]
      unfold OnlineLowerRelu.Family.prefixDim
      omega)
  have hprod:(3*max B 1)*(((6*k+6:ℕ):ℝ)*Real.log (n k))≤n k:=
    (le_div_iff₀ (mul_pos hm (by linarith))).mp hk
  apply (le_div_iff₀ hd).mpr
  have hA:=mul_le_mul_of_nonneg_left hdim hM.le
  have hB:=mul_le_mul_of_nonneg_left (le_max_left B 1) hd.le
  have hC:=mul_le_mul_of_nonneg_left hlog (show 0≤(3*max B 1)*((6*k+6:ℕ):ℝ) by positivity)
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
