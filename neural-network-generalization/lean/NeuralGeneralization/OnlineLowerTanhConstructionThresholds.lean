import NeuralGeneralization.OnlineLowerTanhResources
import NeuralGeneralization.OnlineLowerTanhCodeNetwork

/-! Exact integer-family thresholds for the shared-carrier code theorem. -/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

lemma construction_pairDim_bound (K k:ℕ) (hK:1≤K) (hk:1≤k)
    (hl:1≤constructionLog k) :
    pairDim (constructionBaseline K k) (constructionIncrement k) k≤8*logicalDim k := by
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  let m:=logicalDim k
  let l:=constructionLog k
  have hR0:0<R:=constructionBaseline_pos K k (by omega)
  have hRpos:(0:ℝ)<R:=Nat.cast_pos.mpr hR0
  have hKR:(1:ℝ)≤K:=by exact_mod_cast hK
  have hm:(1:ℝ)≤m:=by exact_mod_cast (show 1≤logicalDim k by rw [logicalDim_eq];omega)
  have hR:2*l^2≤(R:ℝ):=by
    have hh:=(constructionBaseline_bounds K k).1
    change 2*(K:ℝ)*l^2≤(R:ℝ) at hh
    nlinarith [mul_nonneg (by linarith : 0≤(K:ℝ)-1) (sq_nonneg l)]
  have hH:(H:ℝ)≤4*(m:ℝ)*l^2:=by
    have hh:=(constructionIncrement_bounds k).2
    change (H:ℝ)≤2*(m:ℝ)*l+2 at hh
    have hls:1≤l^2:=by nlinarith
    have hml:1≤(m:ℝ)*l^2:=by nlinarith
    have hll:(m:ℝ)*l≤m*l^2:=mul_le_mul_of_nonneg_left (by nlinarith) (by positivity)
    linarith
  have hsplit:(splitCount H R:ℝ)*R≤H+R:=by exact_mod_cast splitCount_mul_bound H R
  have htwo:4*(m:ℝ)*l^2≤2*m*R:=by nlinarith [mul_le_mul_of_nonneg_left hR (by positivity : 0≤2*(m:ℝ))]
  have hs:(splitCount H R:ℝ)≤2*m+1:=by nlinarith
  have hsn:splitCount H R≤2*m+1:=by exact_mod_cast hs
  have hp:OnlineLowerRelu.Family.pairDim k≤2*m:=by
    dsimp [m]; rw [OnlineLowerRelu.Family.pairDim_eq,logicalDim_eq];omega
  change OnlineLowerRelu.Family.pairDim k+2*splitCount H R≤8*m
  have hmN:1≤m:=by exact_mod_cast hm
  omega

lemma construction_pairLog_bound (K k:ℕ) (hK:1≤K) (hk:1≤k)
    (hl:1≤constructionLog k) :
    Real.log ((pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2)≤
      2*constructionLog k := by
  have hp:=construction_pairDim_bound K k hK hk hl
  have hpR:(pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)≤8*logicalDim k:=by exact_mod_cast hp
  have hm:(6:ℝ)≤logicalDim k:=by exact_mod_cast (show 6≤logicalDim k by rw [logicalDim_eq];omega)
  have hquad:(pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2≤
      ((logicalDim k:ℝ)+2)^2:=by nlinarith
  have hh:=Real.log_le_log (by positivity : (0:ℝ)<(pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2) hquad
  simpa only [Real.log_pow,Nat.cast_ofNat,constructionLog] using hh

/-- The baseline ceiling satisfies the actual code threshold uniformly
for every sufficiently large construction index. -/
theorem construction_code_thresholds_eventually (k₀ p₀ K:ℕ) (hK:1≤K) (hK₀:2*k₀≤K) :
    ∀ᶠk:ℕ in atTop,
      144<constructionDimension K k ∧ 6≤constructionBaseline K k ∧
      p₀≤pairDim (constructionBaseline K k) (constructionIncrement k) k ∧
      (k₀:ℝ)*Real.log ((pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2)^2≤
        constructionBaseline K k := by
  filter_upwards [construction_resources_eventually K hK,log_nat_eventually_ge 2,
    eventually_ge_atTop (max p₀ 145)] with k hres hlog hk
  have hk1:1≤k:=by omega
  have hk2:2≤k:=by omega
  have hl:1≤constructionLog k:=(by linarith : (1:ℝ)≤Real.log (k:ℝ)).trans
    (constructionLog_comparison k hk2).1
  have hpair:=construction_pairLog_bound K k hK hk1 hl
  have hlognonneg:0≤Real.log ((pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2):=
    Real.log_nonneg (by have hh:=Nat.cast_nonneg (α:=ℝ) (pairDim (constructionBaseline K k) (constructionIncrement k) k); linarith)
  have hsq:Real.log ((pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2)^2≤
      4*constructionLog k^2:=by nlinarith
  have hK₀R:2*(k₀:ℝ)≤K:=by exact_mod_cast hK₀
  have hth: (k₀:ℝ)*Real.log ((pairDim (constructionBaseline K k) (constructionIncrement k) k:ℝ)+2)^2≤
      constructionBaseline K k:=by
    have hb:=(constructionBaseline_bounds K k).1
    have ha:=mul_le_mul_of_nonneg_left hsq (Nat.cast_nonneg k₀)
    have hc:=mul_le_mul_of_nonneg_right hK₀R (sq_nonneg (constructionLog k))
    nlinarith only [hb,ha,hc]
  have hdim:144<constructionDimension K k:=by
    have hkR:(145:ℝ)≤k:=by exact_mod_cast (show 145≤k by omega)
    have hkn:0≤(k:ℝ):=Nat.cast_nonneg _
    have hs:4≤Real.log (k:ℝ)^2:=by nlinarith
    have hprod:=mul_le_mul_of_nonneg_left hs hkn
    have hdR:(144:ℝ)<constructionDimension K k:=by nlinarith [hres.2.2.2.2.1]
    exact_mod_cast hdR
  refine ⟨hdim,hres.2.1,?_,hth⟩
  unfold pairDim
  rw [OnlineLowerRelu.Family.pairDim_eq]
  omega

/-- Every selected support tends to infinity uniformly over the logical
Fourier index. This transfers an eventual odd-degree intrinsic theorem. -/
theorem construction_intrinsic_eventually
    (hsharp:∃r₀:ℕ,∀r:ℕ,r₀≤r → IntrinsicParityBound (2*r+1) (balancedCost r))
    (K:ℕ) (hK:1≤K) :
    ∀ᶠk:ℕ in atTop,∀s,
      IntrinsicParityBound
        (((physicalCode (constructionBaseline K k) (constructionIncrement k) k
          (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)).support s).card)
        (codeBalancedCost (physicalCode (constructionBaseline K k) (constructionIncrement k) k
          (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)) s) := by
  obtain ⟨r₀,hr₀⟩:=hsharp
  filter_upwards [construction_resources_eventually K hK,eventually_ge_atTop r₀] with k hres hk
  intro s
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  let C:=physicalCode R H k (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k)
  have hevenR:=constructionBaseline_even K k
  have hevenH:=constructionIncrement_even k
  have ho:Odd ((C.support s).card):=support_odd R H k hevenR hevenH s
  have hdegree:(C.support s).card=2*((C.support s).card/2)+1:=by
    obtain ⟨a,ha⟩:=ho;omega
  have hcard:1+pairDim R H k≤(C.support s).card:=by
    change 1+pairDim R H k≤(carrierSupport (size R H k) (column R H k) s).card
    rw [carrierSupport_card]
    apply Nat.add_le_add_left
    have hp:=Finset.sum_le_sum (s:=Finset.univ) (fun i _=>
      Nat.succ_le_of_lt (size_pos R H k (constructionBaseline_pos K k (by omega)) i (railOrientation (column R H k) s i)))
    simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul,Nat.succ_eq_add_one,Nat.zero_add,mul_one] using hp
  have hp:2*r₀≤pairDim R H k:=by
    unfold pairDim
    rw [OnlineLowerRelu.Family.pairDim_eq]
    omega
  have hr:r₀≤(C.support s).card/2:=by omega
  have hh:=hr₀ ((C.support s).card/2) hr
  rw [←hdegree] at hh
  exact hh

end NeuralGeneralization.OnlineLowerTanh.Family
