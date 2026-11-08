import NeuralGeneralization.OnlineLowerTanhPathPrefix
import NeuralGeneralization.OnlineLowerTanhCostDifferences
import NeuralGeneralization.OnlineLowerTanhPathActualCost
import NeuralGeneralization.OnlineLowerFamilyCostGeometry
import Mathlib.Analysis.SpecificLimits.Normed

/-! Uniform high-prefix bounds for every logical live fiber. -/
noncomputable section
open scoped BigOperators Classical
open Set Filter
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerGeometry

lemma walshCoefficient_abs_le_uniform {m:ℕ} (g:ClippingCube m→ℝ)
    (T:Finset (Fin m)) (B:ℝ) (hB:∀x,|g x|≤B) : |walshCoefficients g T|≤B := by
  have hc:(0:ℝ)<Fintype.card (ClippingCube m):=Nat.cast_pos.mpr Fintype.card_pos
  unfold walshCoefficients uniformCubeMean
  rw [abs_div,abs_of_pos hc]
  apply (div_le_iff₀ hc).mpr
  calc
    _≤∑x:ClippingCube m,|g x*walshCharacter T x|:=Finset.abs_sum_le_sum_abs _ _
    _≤∑x:ClippingCube m,B:=by
      apply Finset.sum_le_sum
      intro x _
      simpa only [abs_mul,abs_walshCharacter,mul_one] using hB x
    _=B*(Fintype.card (ClippingCube m):ℝ):=by simp [mul_comm]

/-- Exact prefix cancellation holds for every path support, not just the
selected candidate points. -/
theorem scalarCost_prefix_difference (k:ℕ) (n:ℝ) (cost:ℝ→ℝ)
    (T:Finset (Fin (OnlineLowerRelu.Family.pathDim k))) :
    FamilyCost.scalarCost k n cost T=
      walshCoefficients (fun z=>mixedBackwardDifference
        (List.replicate (OnlineLowerRelu.Family.prefixDim k) 4) cost
          (fixedPathDegree n (2*k) z)) T/(2:ℝ)^(OnlineLowerRelu.Family.prefixDim k) := by
  rw [FamilyCost.scalarCost_split]
  rw [prefix_sum_eq_difference (OnlineLowerRelu.Family.prefixDim k)
    (fun x=>walshCoefficients (fun z=>cost (fixedPathDegree x (2*k) z)) T) n,
    walshCoefficients_mixedDifference]
  congr 2
  funext z
  have he:(fun x=>cost (fixedPathDegree x (2*k) z))=
      scalarShift (fixedPathDegree 0 (2*k) z) cost:=by
    funext x
    exact congrArg cost (fixedPathDegree_baseline x (2*k) z)
  rw [he]
  conv_rhs => rw [fixedPathDegree_baseline]
  exact congrFun (scalarShift_mixedBackwardDifference (fixedPathDegree 0 (2*k) z)
    (List.replicate (OnlineLowerRelu.Family.prefixDim k) 4) cost).symm n

def tanhPrefixEnvelope (P:ℕ) (n:ℝ) : ℝ :=
  (3*optimizedCostCurvature/2)*(2:ℝ)^P*(P.factorial:ℝ)/n^(P+1)

lemma tanhPrefixEnvelope_pos (P:ℕ) {n:ℝ} (hn:0<n) :0<tanhPrefixEnvelope P n:=by
  unfold tanhPrefixEnvelope
  positivity [optimizedCostCurvature_pos]

/-- Uniform scalar envelope on all paths with the compulsory prefix. -/
theorem optimizedRealCost_prefix_envelope (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀k:ℕ,∀n:ℝ,
      S*(OnlineLowerRelu.Family.prefixDim k+1:ℕ)≤n→
      ∀T:Finset (Fin (OnlineLowerRelu.Family.pathDim k)),
      |FamilyCost.scalarCost k n (optimizedRealCost b) T|≤
        tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) n := by
  obtain ⟨S,hS,hd⟩:=optimizedRealCost_mixed_differences b
  refine ⟨S,hS,?_⟩
  intro k n hn T
  let P:=OnlineLowerRelu.Family.prefixDim k
  have hP:2≤P:=by dsimp [P,OnlineLowerRelu.Family.prefixDim];omega
  have hsteps:∀h∈List.replicate P (4:ℝ),0<h:=by simp
  obtain ⟨hbound,hmono⟩:=hd (List.replicate P 4) hsteps (by simpa using hP)
  have hn0:0<n:=lt_of_lt_of_le (mul_pos hS (by positivity)) hn
  have hn':S*((List.replicate P (4:ℝ)).length+1:ℕ)≤n:=by simpa only [List.length_replicate] using hn
  obtain ⟨hpos,hlo,hup⟩:=hbound n hn'
  have huniform:∀z:ClippingCube (OnlineLowerRelu.Family.pathDim k),
      |mixedBackwardDifference (List.replicate P 4) (optimizedRealCost b)
        (fixedPathDegree n (2*k) z)|≤
          (4:ℝ)^P*((3*optimizedCostCurvature/2)*(P.factorial:ℝ)/n^(P+1)):=by
    intro z
    have hdeg:=fixedPathDegree_ge n (2*k) z
    have hp:=(hbound _ (hn'.trans hdeg)).1
    rw [abs_of_pos hp]
    have hh:=(hmono hn' (hn'.trans hdeg) hdeg).trans hup
    simpa only [List.length_replicate,List.prod_replicate] using hh
  have hw:=walshCoefficient_abs_le_uniform _ T _ huniform
  rw [scalarCost_prefix_difference,abs_div,abs_of_pos (by positivity : 0<(2:ℝ)^P)]
  have hh:=div_le_div_of_nonneg_right hw (by positivity : 0≤(2:ℝ)^P)
  apply hh.trans_eq
  unfold tanhPrefixEnvelope
  have hp4:(4:ℝ)^P=(2:ℝ)^P*(2:ℝ)^P:=by rw [←mul_pow];norm_num
  rw [hp4]
  field_simp
  <;> ring

namespace Family

lemma livePoint_eq_extend (k:ℕ) (endpoint:Bool) (z:ClippingCube (logicalDim k))
    (hz:cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier) :
    z=extendPoint k (oldPoint k z) false := by
  obtain ⟨hold,h0,h1⟩:=(mem_liveCoset k endpoint z).mp hz
  have hd:distinguishedPoint k z=(fun _:Fin 2=>false):=by
    funext i
    fin_cases i
    · exact h0
    · exact h1
  have he:=joinPoint_parts k z
  rw [hd] at he
  exact he.symm

/-- Every point of the actual live affine coset has the same compulsory
prefix; its effective rectangle cost has the literal old path transform. -/
theorem live_rectangle_scalarSupportWeight_eq (R H k:ℕ) (cost:ℝ→ℝ)
    (endpoint:Bool) (z:ClippingCube (logicalDim k))
    (hz:cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier) :
    rectangleEffectiveCost (scalarSupportWeight R H k cost) (shiftPoint k) z=
      -FamilyCost.scalarCost k ((pairDim R H k:ℝ)*R+1+H) cost
        (OnlineLowerRelu.Family.pathSupportOfPoint k (oldPoint k z)) := by
  have hold:=((mem_liveCoset k endpoint z).mp hz).1
  have hp:∀i:Fin (OnlineLowerRelu.Family.prefixDim k),
      oldPoint k z (OnlineLowerRelu.Family.logicalIndex k (.inl i))=false:=
    OnlineLowerRelu.Family.calibration_prefix_bits k endpoint (oldPoint k z) hold
  have he:=OnlineLowerRelu.Family.prefix_point_representation k (oldPoint k z) hp
  have hh:=rectangle_scalarSupportWeight_eq R H k cost
    (joinedSyndromeSupport (OnlineLowerRelu.Family.prefixDim k) (OnlineLowerRelu.Family.pathDim k)
      (OnlineLowerRelu.Family.pathSupportOfPoint k (oldPoint k z)))
  rw [he,←livePoint_eq_extend k endpoint z hz] at hh
  exact hh

/-- Actual neural weights obey the same all-live-point envelope. -/
theorem codeBalancedCost_live_envelope (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀R H k:ℕ,∀hR:0<R,∀hH:0<H,Even R→Even H→
      b.threshold<((pairDim R H k*R+1:ℕ):ℝ)→
      S*(OnlineLowerRelu.Family.prefixDim k+1:ℕ)≤(pairDim R H k:ℝ)*R+1+H→
      ∀endpoint:Bool,∀z:ClippingCube (logicalDim k),
      cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier→
      |rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) z|≤
        tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) ((pairDim R H k:ℝ)*R+1+H) := by
  obtain ⟨S,hS,hbound⟩:=optimizedRealCost_prefix_envelope b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hRe hHe hbase hn endpoint z hz
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe hbase,
    live_rectangle_scalarSupportWeight_eq R H k _ endpoint z hz,abs_neg]
  exact hbound k _ hn _

end Family

lemma tanhPrefixEnvelope_le_geometric (P:ℕ) {n:ℝ} (hn:0<n) :
    tanhPrefixEnvelope P n≤(3*optimizedCostCurvature/(2*n))*(2*(P:ℝ)/n)^P := by
  have hf:(P.factorial:ℝ)≤(P:ℝ)^P:=by exact_mod_cast Nat.factorial_le_pow P
  have hC:=optimizedCostCurvature_pos
  unfold tanhPrefixEnvelope
  calc
    _≤(3*optimizedCostCurvature/2)*(2:ℝ)^P*(P:ℝ)^P/n^(P+1):=by gcongr
    _=(3*optimizedCostCurvature/(2*n))*(2*(P:ℝ)/n)^P:=by
      rw [div_pow,mul_pow,pow_succ]
      field_simp
      <;> ring

lemma tanhPrefixEnvelope_le_rail_ratio (P:ℕ) {n R:ℝ} (hn:0<n) (hR:0<R)
    (hbase:R*(P:ℝ)≤n) :
    tanhPrefixEnvelope P n≤(3*optimizedCostCurvature/(2*n))*(2/R)^P := by
  have hr:2*(P:ℝ)/n≤2/R:=by
    apply (div_le_div_iff₀ hn hR).mpr
    nlinarith
  exact (tanhPrefixEnvelope_le_geometric P hn).trans
    (mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hr P)
      (by positivity [optimizedCostCurvature_pos]))

namespace Family
lemma prefixDim_le_pairDim (R H k:ℕ) :
    OnlineLowerRelu.Family.prefixDim k≤pairDim R H k := by
  unfold pairDim
  rw [OnlineLowerRelu.Family.pairDim_eq]
  unfold OnlineLowerRelu.Family.prefixDim
  omega

lemma tanhPrefixEnvelope_family_geometric (R H k:ℕ) (hR:0<R) :
    tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) ((pairDim R H k:ℝ)*R+1+H)≤
      (3*optimizedCostCurvature/(2*((pairDim R H k:ℝ)*R+1+H)))*
        (2/(R:ℝ))^(OnlineLowerRelu.Family.prefixDim k) := by
  have hRR:(0:ℝ)<R:=by exact_mod_cast hR
  have hpp:(OnlineLowerRelu.Family.prefixDim k:ℝ)≤pairDim R H k:=by
    exact_mod_cast prefixDim_le_pairDim R H k
  apply tanhPrefixEnvelope_le_rail_ratio _ (by positivity) hRR
  have hh:=mul_le_mul_of_nonneg_left hpp hRR.le
  nlinarith [Nat.cast_nonneg (α:=ℝ) H]
end Family


lemma prefix_logical_geometric_identity (k:ℕ) :
    (2:ℝ)^(6*k+6)*(1/8:ℝ)^(4*k+3)=(1/8:ℝ)*(1/64:ℝ)^k := by
  calc
    _=((2:ℝ)^6*(1/8:ℝ)^4)^k*((2:ℝ)^6*(1/8:ℝ)^3):=by
      simp only [pow_add,pow_mul,mul_pow]
      ring
    _=_:=by norm_num;ring

/-- At baseline rail length sixteen, the complete logical-cube factor is
already dominated by a fixed geometric decay. Larger rails only help. -/
theorem tanhPrefixEnvelope_logical_scaled (k:ℕ) {n R:ℝ} (hn:1≤n) (hR:16≤R)
    (hbase:R*(OnlineLowerRelu.Family.prefixDim k:ℝ)≤n) :
    (2:ℝ)^(6*k+6)*tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) n≤
      (3*optimizedCostCurvature/16)*(1/64:ℝ)^k := by
  have hn0:0<n:=by linarith
  have hR0:0<R:=by linarith
  have hE:=tanhPrefixEnvelope_le_rail_ratio (OnlineLowerRelu.Family.prefixDim k) hn0 hR0 hbase
  have hfrac:3*optimizedCostCurvature/(2*n)≤3*optimizedCostCurvature/2:=by
    apply div_le_div_of_nonneg_left (by positivity [optimizedCostCurvature_pos]) (by norm_num)
    linarith
  have hratio:2/R≤(1/8:ℝ):=by
    apply (div_le_iff₀ hR0).mpr
    linarith
  have hpow:=pow_le_pow_left₀ (by positivity : (0:ℝ)≤2/R) hratio (OnlineLowerRelu.Family.prefixDim k)
  have hmul:=mul_le_mul hfrac hpow (by positivity) (by positivity [optimizedCostCurvature_pos])
  have hh:=mul_le_mul_of_nonneg_left (hE.trans hmul) (by positivity : (0:ℝ)≤2^(6*k+6))
  calc
    _≤(2:ℝ)^(6*k+6)*((3*optimizedCostCurvature/2)*(1/8:ℝ)^(OnlineLowerRelu.Family.prefixDim k)):=hh
    _=(3*optimizedCostCurvature/2)*((2:ℝ)^(6*k+6)*(1/8:ℝ)^(4*k+3)):=by
      unfold OnlineLowerRelu.Family.prefixDim
      ring
    _=_:=by rw [prefix_logical_geometric_identity];ring


lemma prefix_polynomial_geometric_tendsto (q:ℕ) :
    Tendsto (fun k:ℕ=>((k:ℝ)+1)^q*(1/64:ℝ)^k) atTop (nhds 0) := by
  have h:=tendsto_pow_const_mul_const_pow_of_lt_one q
    (by norm_num : (0:ℝ)≤1/64) (by norm_num : (1/64:ℝ)<1)
  have hh:=(h.comp (tendsto_add_atTop_nat 1)).div_const (1/64:ℝ)
  simpa only [Function.comp_apply,Nat.cast_add,Nat.cast_one,pow_succ,mul_div_assoc,
    mul_div_cancel_right₀ _ (by norm_num : (1/64:ℝ)≠0),zero_div] using hh

/-- The whole logical-cube factor times any fixed polynomial is absorbed
uniformly once the rail baseline is at least sixteen. -/
theorem prefix_envelope_polynomial_absorption (A:ℝ) (hA:0≤A) (q:ℕ) :
    ∀ᶠk:ℕ in atTop,∀n R:ℝ,1≤n→16≤R→
      R*(OnlineLowerRelu.Family.prefixDim k:ℝ)≤n→
      (2:ℝ)^(6*k+6)*tanhPrefixEnvelope (OnlineLowerRelu.Family.prefixDim k) n*
        (A*((k:ℝ)+1)^q)<1 := by
  have h: Tendsto (fun k:ℕ=>(3*optimizedCostCurvature/16)*A*
      (((k:ℝ)+1)^q*(1/64:ℝ)^k)) atTop (nhds 0):=by
    convert (prefix_polynomial_geometric_tendsto q).const_mul ((3*optimizedCostCurvature/16)*A) using 1 <;> simp
  filter_upwards [h.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1))] with k hk
  intro n R hn hR hbase
  have hh:=mul_le_mul_of_nonneg_right (tanhPrefixEnvelope_logical_scaled k hn hR hbase)
    (show 0≤A*((k:ℝ)+1)^q by positivity)
  exact hh.trans_lt (by nlinarith [hk])


end NeuralGeneralization.OnlineLowerTanh
