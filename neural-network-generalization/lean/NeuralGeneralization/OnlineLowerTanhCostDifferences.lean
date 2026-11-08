import NeuralGeneralization.OnlineLowerTanhCostSigns
import NeuralGeneralization.OnlineLowerMixedDifference

/-! Positive decreasing mixed differences of the literal optimized tanh cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma realPart_iteratedDeriv_hasDerivAt {f:ℂ→ℂ} {U:Set ℂ}
    (hU:IsOpen U) (hf:DifferentiableOn ℂ f U) (j:ℕ) (u:ℝ) (hu:(u:ℂ)∈U) :
    HasDerivAt (iteratedDeriv j (fun x:ℝ=>(f (x:ℂ)).re))
      (iteratedDeriv (j+1) (fun x:ℝ=>(f (x:ℂ)).re) u) u := by
  have he:iteratedDeriv j (fun x:ℝ=>(f (x:ℂ)).re) =ᶠ[𝓝 u]
      (fun x:ℝ=>(iteratedDeriv j f (x:ℂ)).re) := by
    filter_upwards [((hU.preimage Complex.continuous_ofReal).mem_nhds hu)] with x hx
    exact iteratedDeriv_realPart hU hf j x hx
  have hd:=((holomorphic_iteratedDeriv_differentiableOn hU hf j).differentiableAt
    (hU.mem_nhds hu)).hasDerivAt.real_of_complex
  rw [iteratedDeriv_realPart hU hf (j+1) u hu,iteratedDeriv_succ]
  exact hd.congr_of_eventuallyEq he

/-- Every derivative used in the finite-difference mean value formula is a
literal derivative of the actual real optimized cost. -/
theorem optimizedRealCost_derivative_family (b:ActualGainBranch) :
    ∃T:ℝ,0<T ∧ ∀j:ℕ,∀x:ℝ,T<x →
      HasDerivAt (iteratedDeriv j (optimizedRealCost b))
        (iteratedDeriv (j+1) (optimizedRealCost b) x) x := by
  obtain ⟨T,K,hT,hK,hb,ha,hE⟩:=holomorphicOptimizedCost_uniform_expansion b
  refine ⟨T,by linarith,?_⟩
  intro j x hx
  apply realPart_iteratedDeriv_hasDerivAt
    ((isOpen_lt continuous_const Complex.continuous_re).inter
      (isOpen_lt continuous_const continuous_norm)) ha j x
  have hx0:0<x := by linarith
  exact ⟨hx0,by simpa only [Set.mem_setOf_eq, Complex.norm_real,Real.norm_eq_abs,abs_of_pos hx0] using hx⟩

/-- One threshold linear in the largest derivative order gives the actual
positive decreasing mixed differences and their quantitative power bounds. -/
theorem optimizedRealCost_mixed_differences (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀hs:List ℝ,(∀h∈hs,0<h) → 2≤hs.length →
      (∀x:ℝ,S*(hs.length+1:ℕ)≤x →
        0<mixedBackwardDifference hs (optimizedRealCost b) x ∧
        hs.prod*((optimizedCostCurvature/2)*(hs.length.factorial:ℝ)/
          (x+hs.sum)^(hs.length+1))≤mixedBackwardDifference hs (optimizedRealCost b) x ∧
        mixedBackwardDifference hs (optimizedRealCost b) x≤
          hs.prod*((3*optimizedCostCurvature/2)*(hs.length.factorial:ℝ)/x^(hs.length+1))) ∧
      AntitoneOn (mixedBackwardDifference hs (optimizedRealCost b))
        (Ici (S*(hs.length+1:ℕ))) := by
  obtain ⟨T,hT,hder⟩:=optimizedRealCost_derivative_family b
  obtain ⟨S₀,hS₀,hbounds⟩:=optimizedRealCost_alternating_derivatives b
  let S:=max S₀ (T+1)
  have hS:0<S := hS₀.trans_le (le_max_left _ _)
  have hSS:S₀≤S := le_max_left _ _
  have hTS:T<S := lt_of_lt_of_le (by linarith) (le_max_right _ _)
  refine ⟨S,hS,?_⟩
  intro hs hsteps hlen
  let F:ℕ→ℝ→ℝ:=fun j=>iteratedDeriv j (optimizedRealCost b)
  let base:=S*(hs.length+1:ℕ)
  have hbT:T<base := by
    have hn:(1:ℝ)≤(hs.length+1:ℕ) := by exact_mod_cast (show 1≤hs.length+1 by omega)
    dsimp [base]
    nlinarith
  have hb0:0<base := hT.trans hbT
  have hdall:∀j:ℕ,∀t:ℝ,base≤t → HasDerivAt (F j) (F (j+1) t) t :=
    fun j t ht=>hder j t (hbT.trans_le ht)
  have horder (j:ℕ) (hj:j≤hs.length+1) (t:ℝ) (ht:base≤t) : S₀*(j:ℝ)≤t := by
    have hjR:(j:ℝ)≤(hs.length+1:ℕ) := by exact_mod_cast hj
    have hh:=mul_le_mul hSS hjR (Nat.cast_nonneg _) hS.le
    exact hh.trans ht
  have hsign (j:ℕ) (hj:2≤j) (hjmax:j≤hs.length+1) (t:ℝ) (ht:base≤t) :
      0<(-1:ℝ)^j*F j t := by
    have hh:=(hbounds j hj t (horder j hjmax t ht)).1
    have ht0:0<t := hb0.trans_le ht
    have hC:=optimizedCostCurvature_pos
    exact lt_of_lt_of_le (by positivity) hh
  constructor
  · intro x hx
    have hxp:0<x := hb0.trans_le hx
    have hp:=mixedBackwardDifference_pos hs F base x hsteps hx
      (fun j _ t ht=>hdall j t ht) (fun t ht=>hsign hs.length hlen (by omega) t ht)
    have hC:=optimizedCostCurvature_pos
    have hquant:=mixedBackwardDifference_inverse_power_bounds hs F base x
      ((optimizedCostCurvature/2)*(hs.length.factorial:ℝ))
      ((3*optimizedCostCurvature/2)*(hs.length.factorial:ℝ)) (hs.length+1)
      hsteps hx hxp (by positivity) (by positivity) (fun j _ t ht=>hdall j t ht)
      (fun t ht=>(hbounds hs.length hlen t (horder hs.length (by omega) t (hx.trans ht))).1)
      (fun t ht=>(hbounds hs.length hlen t (horder hs.length (by omega) t (hx.trans ht))).2)
    exact ⟨hp,hquant.1,hquant.2⟩
  · exact mixedBackwardDifference_antitone hs F base hsteps (fun j _ t ht=>hdall j t ht)
      (fun t ht=>hsign (hs.length+1) (by omega) le_rfl t ht)

end NeuralGeneralization.OnlineLowerTanh
