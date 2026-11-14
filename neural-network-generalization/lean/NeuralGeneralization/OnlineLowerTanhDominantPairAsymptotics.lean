import NeuralGeneralization.OnlineLowerTanhWalshAsymptotics
import NeuralGeneralization.OnlineLowerTanhDominantPairBounds

/-! # The moving-dimension dominant-pair ratio -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open Filter Set Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def noncentralIncrementMass (b:ActualGainBranch) {d:ℕ} (δ:Fin d→ℝ) (n:ℝ) (i j:Fin d):ℝ:=
  ∑T:Finset (Fin d),if 2 ≤ T.card ∧ T≠({i,j}:Finset (Fin d))
    then walshCoefficients (incrementScore δ (optimizedRealCost b) n) T else 0

def otherIncrementMass {d:ℕ} (δ:Fin d→ℝ) (i j:Fin d):ℝ:=
  ∑t∈({i,j}:Finset (Fin d))ᶜ,δ t

lemma dominant_pair_numeric_bound {C n H S D ai aj P U:ℝ}
    (hC:0<C) (hn:0<n) (hH:0<H) (hS:0 ≤ S) (hD:0 ≤ D)
    (hD5:D ≤ 5*H) (hDn:D ≤ n) (hai:H ≤ ai) (haj:H ≤ aj)
    (hP:C*(ai*aj)/(4*(n+D)^3) ≤ P)
    (hU:U ≤ (3*C/(4*n^3))*(S*D)) : U/P ≤ 120*(S/H) := by
  have hnD:0<n+D:=add_pos_of_pos_of_nonneg hn hD
  have hpair:0<C*H^2/(32*n^3) := by positivity
  have hprod:H^2 ≤ ai*aj := by nlinarith [mul_le_mul hai haj hH.le (hH.trans_le hai).le]
  have hden:(n+D)^3 ≤ (2*n)^3 := pow_le_pow_left₀ hnD.le (by linarith) 3
  have hPlow:C*H^2/(32*n^3) ≤ P := by
    apply le_trans _ hP
    calc
      _ = C*H^2/(4*(2*n)^3) := by ring
      _ ≤ C*H^2/(4*(n+D)^3) :=
        div_le_div_of_nonneg_left (by positivity) (by positivity) (by nlinarith)
      _ ≤ C*(ai*aj)/(4*(n+D)^3) := by gcongr
  have hPpos:=hpair.trans_le hPlow
  have hUup:U ≤ 15*C*S*H/(4*n^3) := by
    apply hU.trans
    have hh:=mul_le_mul_of_nonneg_left hD5 hS
    have hhh:=mul_le_mul_of_nonneg_left hh (show 0 ≤ 3*C/(4*n^3) by positivity)
    convert hhh using 1 <;> ring
  calc
    _ ≤ (15*C*S*H/(4*n^3))/P := div_le_div_of_nonneg_right hUup hPpos.le
    _ ≤ (15*C*S*H/(4*n^3))/(C*H^2/(32*n^3)) :=
      div_le_div_of_nonneg_left (by positivity) hpair hPlow
    _ = _ := by field_simp; ring

/-- Stronger than the paper's O(S/H+H/n): all other high-order coefficients
have ratio O(S/H) to the distinguished pair, under the same hypotheses. -/
theorem optimized_increment_dominant_pair_asymptotics
    (b:ActualGainBranch) (d:ℕ→ℕ) (δ:∀k,Fin (d k)→ℝ)
    (hδ:∀k i,2 ≤ δ k i) (n H:ℕ→ℝ) (hn:Tendsto n atTop atTop)
    (hH:∀k,0<H k) (i j:∀k,Fin (d k)) (hij:∀k,i k≠j k)
    (hi:∀k,H k ≤ δ k (i k) ∧ δ k (i k) ≤ 2*H k)
    (hj:∀k,H k ≤ δ k (j k) ∧ δ k (j k) ≤ 2*H k)
    (hSH:Tendsto (fun k=>otherIncrementMass (δ k) (i k) (j k)/H k) atTop (𝓝 0))
    (hHn:Tendsto (fun k=>H k/n k) atTop (𝓝 0)) :
    (fun k=>noncentralIncrementMass b (δ k) (n k) (i k) (j k)/
      walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) {i k,j k})
      =O[atTop] (fun k=>otherIncrementMass (δ k) (i k) (j k)/H k) := by
  let S:ℕ→ℝ:=fun k=>otherIncrementMass (δ k) (i k) (j k)
  let D:ℕ→ℝ:=fun k=>∑t,δ k t
  have hS:∀k,0 ≤ S k:=fun k=>Finset.sum_nonneg (fun t _=>le_trans (by norm_num) (hδ k t))
  have hD:∀k,0 ≤ D k:=fun k=>Finset.sum_nonneg (fun t _=>le_trans (by norm_num) (hδ k t))
  have hDeq (k:ℕ):D k=δ k (i k)+δ k (j k)+S k := by
    have hh:=Finset.sum_add_sum_compl ({i k,j k}:Finset (Fin (d k))) (δ k)
    simpa [S,D,otherIncrementMass,Finset.sum_pair (hij k)] using hh.symm
  have hDlim:Tendsto (fun k=>D k/n k) atTop (𝓝 0) := by
    have hup:=((hSH.mul hHn).add (hHn.const_mul 4))
    simp only [mul_zero,zero_add] at hup
    apply squeeze_zero' (by
      filter_upwards [hn.eventually (eventually_ge_atTop 0)] with k hk
      exact div_nonneg (hD k) hk) ?_ hup
    filter_upwards [hn.eventually (eventually_gt_atTop 0)] with k hnk
    have hbound:D k ≤ S k+4*H k := by rw [hDeq]; linarith [(hi k).2,(hj k).2]
    have hh:=div_le_div_of_nonneg_right hbound hnk.le
    convert! hh using 1 <;> field_simp [(hH k).ne'] <;> ring
  obtain ⟨T,hT,hbounds⟩:=optimized_increment_dominant_pair_bounds b
  obtain ⟨Tp,hTp,hpositive⟩:=optimized_increment_walsh_positive b
  apply isBigO_iff.mpr
  refine ⟨120,?_⟩
  filter_upwards [increment_dimension_threshold d δ hδ n hn hDlim T hT,
    increment_dimension_threshold d δ hδ n hn hDlim Tp hTp,
    hSH.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1)),
    hDlim.eventually (gt_mem_nhds (by norm_num : (0:ℝ)<1)),
    hn.eventually (eventually_gt_atTop 0)] with k hk hkp hsk hdk hnk
  have hp:∀t,0<δ k t:=fun t=>lt_of_lt_of_le (by norm_num) (hδ k t)
  have hSle:S k ≤ H k:=by simpa only [one_mul] using ((div_lt_iff₀ (hH k)).mp hsk).le
  have hD5:D k ≤ 5*H k:=by rw [hDeq]; linarith [(hi k).2,(hj k).2]
  have hDn:D k ≤ n k:=by have hh:=(div_lt_iff₀ hnk).mp hdk; simpa using hh.le
  obtain ⟨hpair,hmass⟩:=hbounds (d k) (δ k) hp (n k) hk (i k) (j k) (hij k)
  have hpairpos:0<walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) {i k,j k}:=
    hpositive (d k) (δ k) hp (n k) hkp _ (by simp [hij k])
  have hmasspos:0 ≤ noncentralIncrementMass b (δ k) (n k) (i k) (j k) := by
    apply Finset.sum_nonneg
    intro A _
    split_ifs with hA
    · exact (hpositive (d k) (δ k) hp (n k) hkp A hA.1).le
    · rfl
  have hratio:=dominant_pair_numeric_bound optimizedCostCurvature_pos hnk (hH k) (hS k) (hD k)
    hD5 hDn (hi k).1 (hj k).1 hpair hmass
  have hsmall:0 ≤ otherIncrementMass (δ k) (i k) (j k)/H k := div_nonneg (hS k) (hH k).le
  change noncentralIncrementMass b (δ k) (n k) (i k) (j k)/
    walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) {i k,j k} ≤
      120*(otherIncrementMass (δ k) (i k) (j k)/H k) at hratio
  simpa only [Real.norm_eq_abs,abs_of_nonneg (div_nonneg hmasspos hpairpos.le),
    abs_of_nonneg hsmall] using hratio

/-- The exact Big-O display in the manuscript, as a corollary of the stronger estimate. -/
theorem optimized_increment_dominant_pair_paper_asymptotics
    (b:ActualGainBranch) (d:ℕ→ℕ) (δ:∀k,Fin (d k)→ℝ)
    (hδ:∀k i,2 ≤ δ k i) (n H:ℕ→ℝ) (hn:Tendsto n atTop atTop)
    (hH:∀k,0<H k) (i j:∀k,Fin (d k)) (hij:∀k,i k≠j k)
    (hi:∀k,H k ≤ δ k (i k) ∧ δ k (i k) ≤ 2*H k)
    (hj:∀k,H k ≤ δ k (j k) ∧ δ k (j k) ≤ 2*H k)
    (hSH:Tendsto (fun k=>otherIncrementMass (δ k) (i k) (j k)/H k) atTop (𝓝 0))
    (hHn:Tendsto (fun k=>H k/n k) atTop (𝓝 0)) :
    (fun k=>noncentralIncrementMass b (δ k) (n k) (i k) (j k)/
      walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) {i k,j k})
      =O[atTop] (fun k=>otherIncrementMass (δ k) (i k) (j k)/H k+H k/n k) := by
  have hstrong:=optimized_increment_dominant_pair_asymptotics b d δ hδ n H hn hH i j hij hi hj hSH hHn
  apply hstrong.trans
  apply isBigO_iff.mpr
  refine ⟨1,?_⟩
  filter_upwards [hn.eventually (eventually_gt_atTop 0)] with k hnk
  have hs:0 ≤ otherIncrementMass (δ k) (i k) (j k)/H k := by
    apply div_nonneg _ (hH k).le
    exact Finset.sum_nonneg (fun t _=>le_trans (by norm_num) (hδ k t))
  have hh:0 ≤ H k/n k:=div_nonneg (hH k).le hnk.le
  rw [Real.norm_eq_abs,Real.norm_eq_abs,abs_of_nonneg hs,abs_of_nonneg (add_nonneg hs hh),one_mul]
  exact le_add_of_nonneg_right hh

end NeuralGeneralization.OnlineLowerTanh
