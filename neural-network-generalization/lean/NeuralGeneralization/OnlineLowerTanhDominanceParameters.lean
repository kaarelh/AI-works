import NeuralGeneralization.OnlineLowerTanhPathBudget
import NeuralGeneralization.OnlineLowerTanhConstructionThresholds

/-! Integer construction inequalities for the dominant distinguished pair. -/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerGeometry

/-- The two large increments eventually dominate the total old increment,
while every increment remains small relative to the actual baseline. -/
theorem construction_dominance_parameters (K:ℕ) (hK:1≤K) (L S U:ℝ) (hL:0≤L) (hS:0<S) :
    ∀ᶠk:ℕ in atTop,
      let R:=constructionBaseline K k
      let H:=constructionIncrement k
      let n:ℝ:=(pairDim R H k:ℝ)*R+1
      let old:ℝ:=4*OnlineLowerRelu.Family.pairDim k
      U≤n ∧ S*(OnlineLowerRelu.Family.pairDim k+3:ℕ)≤n ∧
      L*old≤H ∧ old+2*H≤n ∧ (H:ℝ)≤n ∧ (dimension R H k:ℝ)≤3*n := by
  filter_upwards [constructionBaseline_eventually_ge K hK (max (2*S) (U+1)),
    log_nat_eventually_ge (max 16 (4*L)),eventually_ge_atTop 2] with k hbase hlog hk
  dsimp only
  let R:=constructionBaseline K k
  let H:=constructionIncrement k
  let m:ℝ:=logicalDim k
  let p:ℝ:=pairDim R H k
  let old:ℝ:=4*OnlineLowerRelu.Family.pairDim k
  let l:=constructionLog k
  let n:ℝ:=p*R+1
  have hKR:(1:ℝ)≤K:=by exact_mod_cast hK
  have hm:(1:ℝ)≤m:=by dsimp [m];exact_mod_cast (show 1≤logicalDim k by rw [logicalDim_eq];omega)
  have hl:max 16 (4*L)≤l:=hlog.trans (constructionLog_comparison k hk).1
  have hl16:16≤l:=(le_max_left _ _).trans hl
  have hlL:4*L≤l:=(le_max_right _ _).trans hl
  have hpold:OnlineLowerRelu.Family.pairDim k≤2*logicalDim k:=by
    rw [OnlineLowerRelu.Family.pairDim_eq,logicalDim_eq];omega
  have hml:logicalDim k≤pairDim R H k:=by
    unfold pairDim;rw [OnlineLowerRelu.Family.pairDim_eq,logicalDim_eq];omega
  have hmp:m≤p:=by dsimp [m,p]; exact_mod_cast hml
  have hp0:0≤p:=by positivity
  have hp1:1≤p:=hm.trans hmp
  have hold:old≤8*m:=by dsimp [old,m];exact_mod_cast (show 4*OnlineLowerRelu.Family.pairDim k≤8*logicalDim k by omega)
  have hold0:0≤old:=by positivity
  have hRl:2*l^2≤(R:ℝ):=by
    have hh:=(constructionBaseline_bounds K k).1
    change 2*(K:ℝ)*l^2≤(R:ℝ) at hh
    nlinarith [mul_nonneg (by linarith : 0≤(K:ℝ)-1) (sq_nonneg l)]
  have hHl:2*m*l≤(H:ℝ):=(constructionIncrement_bounds k).1
  have hHu:(H:ℝ)≤2*m*l+2:=(constructionIncrement_bounds k).2
  have hn:2*m*l^2+1≤n:=by
    have hh:=mul_le_mul hmp hRl (by positivity : 0≤2*l^2) hp0
    dsimp [n];nlinarith only [hh]
  have hnH:(H:ℝ)≤n:=by
    have hpoly:m*l^2≥2*m*l+2:=by
      have ha:=mul_nonneg (by linarith : 0≤l-4) (by positivity : 0≤l)
      have hb:=mul_le_mul_of_nonneg_left (show 4*l≤l^2 by nlinarith only [ha]) (by positivity : 0≤m)
      nlinarith
    nlinarith
  have hnD:old+2*H≤n:=by
    have hp:l^2≥8+4*l:=by nlinarith [sq_nonneg (l-8)]
    have hh:=mul_le_mul_of_nonneg_left hp (by positivity : 0≤m)
    nlinarith
  have hdom:L*old≤(H:ℝ):=by
    have ho:=mul_le_mul_of_nonneg_left hold hL
    have hh:=mul_le_mul_of_nonneg_left hlL (by positivity : 0≤2*m)
    nlinarith only [ho,hh,hHl]
  have hU:U≤n:=by
    have hr:U+1≤(R:ℝ):=(le_max_right _ _).trans hbase
    have hp:0≤(p-1)*R:=mul_nonneg (by linarith) (Nat.cast_nonneg R)
    dsimp [n];nlinarith only [hr,hp]
  have hSbase:S*(OnlineLowerRelu.Family.pairDim k+3:ℕ)≤n:=by
    have hpN:OnlineLowerRelu.Family.pairDim k+3≤2*pairDim R H k:=by
      unfold pairDim;rw [OnlineLowerRelu.Family.pairDim_eq];omega
    have hpR:((OnlineLowerRelu.Family.pairDim k+3:ℕ):ℝ)≤2*p:=by dsimp [p]; exact_mod_cast hpN
    have hr:2*S≤(R:ℝ):=(le_max_left _ _).trans hbase
    have ha:=mul_le_mul_of_nonneg_left hpR hS.le
    have hb:=mul_le_mul_of_nonneg_left hr hp0
    dsimp [n];nlinarith only [ha,hb]
  have hd:(dimension R H k:ℝ)≤3*n:=by
    have he:(dimension R H k:ℝ)=2*n+old+2*H-1:=by
      rw [dimension_eq]
      dsimp [n,p,old]
      push_cast
      ring
    linarith only [he,hnD]
  exact ⟨hU,hSbase,hdom,hnD,hnH,hd⟩

/-- A generous numerical separation turns the noncentral-pair budget into
one quarter of the distinguished coefficient. -/
lemma paired_budget_absorbed (C n d H old W P:ℝ)
    (hC:0<C) (hn:0<n) (hd:0<d) (hH:0<H) (hold:0≤old)
    (hdom:4096*old≤H) (hdegree:d≤3*n)
    (hP:P≤(3*C/(4*n^3))*(old*(old+2*H)))
    (hW:C*H^2/(4*d^3)≤W) : P≤W/4 := by
  have hD:old+2*H≤3*H:=by linarith
  have hprod:4096*(old*(old+2*H))≤3*H^2:=by
    have hh:=mul_le_mul hdom hD (by positivity : 0≤old+2*H) hH.le
    nlinarith only [hh]
  have hcube:d^3≤27*n^3:=by nlinarith [pow_le_pow_left₀ hd.le hdegree 3]
  have hmul:=mul_le_mul hprod hcube (by positivity : 0≤d^3) (by positivity : 0≤3*H^2)
  have hbase:12*(old*(old+2*H))*d^3≤H^2*n^3:=by
    nlinarith [mul_nonneg (sq_nonneg H) (pow_nonneg hn.le 3)]
  have hbaseC:=mul_le_mul_of_nonneg_left hbase hC.le
  have hcompare:(3*C/(4*n^3))*(old*(old+2*H))≤(C*H^2/(4*d^3))/4:=by
    apply (le_div_iff₀ (by norm_num : (0:ℝ)<4)).mpr
    apply (le_div_iff₀ (by positivity : 0<4*d^3)).mpr
    simp only [div_mul_eq_mul_div]
    apply (div_le_iff₀ (by positivity : 0<4*n^3)).mpr
    nlinarith only [hbaseC]
  exact hP.trans (hcompare.trans (div_le_div_of_nonneg_right hW (by norm_num)))

end NeuralGeneralization.OnlineLowerTanh.Family
