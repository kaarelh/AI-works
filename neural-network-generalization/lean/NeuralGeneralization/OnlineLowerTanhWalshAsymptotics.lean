import NeuralGeneralization.OnlineLowerTanhIncrementWalsh
import NeuralGeneralization.OnlineLowerTanhCostMonotone

/-! # Uniform moving-dimension Walsh signs and explicit coefficient bounds -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

lemma increment_walsh_singleton_neg {d:ℕ} (δ:Fin d→ℝ) (hδ:∀i,0<δ i)
    (f:ℝ→ℝ) (a n:ℝ) (hf:StrictMonoOn f (Ici a)) (hn:a ≤ n)
    (T:Finset (Fin d)) (hT:T.card=1) :
    walshCoefficients (incrementScore δ f n) T<0 := by
  rw [increment_walsh_eq_difference_average]
  apply div_neg_of_neg_of_pos _ (by exact_mod_cast Fintype.card_pos)
  apply Finset.sum_neg
  · intro y _
    have hlen:(List.ofFn (subsetWeights T δ)).length=1 := by simpa using hT
    obtain ⟨h,hh⟩:=List.length_eq_one_iff.mp hlen
    have hhmem:h∈List.ofFn (subsetWeights T δ) := by rw [hh]; simp
    obtain ⟨i,hi⟩:=List.mem_ofFn.mp hhmem
    have hh0:0<h := by rw [←hi]; exact hδ _
    rw [hh,mixedBackwardDifference,mixedBackwardDifference]
    have hx:a ≤ n+incrementLinear (subsetWeights Tᶜ δ) y := by
      have hh:=incrementLinear_nonneg (subsetWeights Tᶜ δ) (fun i=>(hδ _).le) y
      linarith
    exact sub_neg.mpr (hf hx (by change a ≤ _; linarith) (by linarith))
  · exact Finset.univ_nonempty

/-- δ_i≥2 and D/n→0 already imply the finite linear dimension threshold;
the logarithmic hypothesis in the paper is unnecessary for this stronger
mixed-derivative proof. -/
lemma increment_dimension_threshold
    (d:ℕ→ℕ) (δ:∀k,Fin (d k)→ℝ) (hδ:∀k i,2 ≤ δ k i)
    (n:ℕ→ℝ) (hn:Tendsto n atTop atTop)
    (hD:Tendsto (fun k=>(∑i,δ k i)/n k) atTop (𝓝 0))
    (S:ℝ) (hS:0<S) : ∀ᶠk in atTop,S*(d k+1:ℕ) ≤ n k := by
  have hs:0<1/S := by positivity
  filter_upwards [hn.eventually (eventually_gt_atTop (2*S)),
    hD.eventually (gt_mem_nhds hs)] with k hnk hDk
  have hn0:0<n k := by linarith
  have hd:2*(d k:ℝ) ≤ ∑i,δ k i := by
    simpa [mul_comm] using (Finset.sum_le_sum (s:=Finset.univ) (fun i _=>hδ k i))
  have hD':S*(∑i,δ k i)<n k := by
    have hh:=(div_lt_iff₀ hn0).mp hDk
    have hh':=mul_lt_mul_of_pos_left hh hS
    field_simp at hh'
    nlinarith
  push_cast
  nlinarith

/-- The paper's moving-dimension coefficient bounds with zero remainder,
and hence with E₀=O(exp(−c'n)) for any c'>0. Both constants are explicit. -/
theorem optimized_increment_uniform_asymptotics
    (b:ActualGainBranch) (d:ℕ→ℕ) (δ:∀k,Fin (d k)→ℝ)
    (hδ:∀k i,2 ≤ δ k i) (n:ℕ→ℝ) (hn:Tendsto n atTop atTop)
    (hD:Tendsto (fun k=>(∑i,δ k i)/n k) atTop (𝓝 0)) :
    ∀ᶠk in atTop,
      (∀T:Finset (Fin (d k)),2 ≤ T.card→
        (optimizedCostCurvature/2)*(∏i∈T,δ k i)/
          ((2:ℝ)^T.card*(n k+∑i,δ k i)^(T.card+1)) ≤
            walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) T ∧
        walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) T ≤
          (3*optimizedCostCurvature/2)*(T.card.factorial:ℝ)*(∏i∈T,δ k i)/
            ((2:ℝ)^T.card*(n k)^(T.card+1)) ∧
        0<walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) T) ∧
      (∀T:Finset (Fin (d k)),T.card=1→
        walshCoefficients (incrementScore (δ k) (optimizedRealCost b) (n k)) T<0) := by
  obtain ⟨S,hS,hbounds⟩:=optimized_increment_walsh_bounds b
  obtain ⟨U,hU,hUb,hmono⟩:=optimizedRealCost_eventually_strictMono b
  filter_upwards [increment_dimension_threshold d δ hδ n hn hD S hS,
    hn.eventually (eventually_ge_atTop U)] with k hk hkU
  have hp:∀i,0<δ k i := fun i=>lt_of_lt_of_le (by norm_num) (hδ k i)
  have hn0:0<n k := hU.trans_le hkU
  have hsum:0 ≤ ∑i,δ k i:=Finset.sum_nonneg (fun i _=>(hp i).le)
  constructor
  · intro T hT
    obtain ⟨hlo,hhi⟩:=hbounds (d k) (δ k) hp (n k) hk T hT
    have hfac:(1:ℝ) ≤ (T.card.factorial:ℝ) := by exact_mod_cast Nat.one_le_iff_ne_zero.mpr (Nat.factorial_ne_zero _)
    have hprod:0<∏i∈T,δ k i:=Finset.prod_pos (fun i _=>hp i)
    have hbase:0<(optimizedCostCurvature/2)*(∏i∈T,δ k i)/
        ((2:ℝ)^T.card*(n k+∑i,δ k i)^(T.card+1)) := by positivity [optimizedCostCurvature_pos]
    have hlower:(optimizedCostCurvature/2)*(∏i∈T,δ k i)/
        ((2:ℝ)^T.card*(n k+∑i,δ k i)^(T.card+1)) ≤
        ((∏i∈T,δ k i)*((optimizedCostCurvature/2)*(T.card.factorial:ℝ)/
        (n k+∑i,δ k i)^(T.card+1)))/(2:ℝ)^T.card := by
      calc
        _ ≤ ((optimizedCostCurvature/2)*(∏i∈T,δ k i)/
            ((2:ℝ)^T.card*(n k+∑i,δ k i)^(T.card+1)))*(T.card.factorial:ℝ) :=
          le_mul_of_one_le_right hbase.le hfac
        _ = _ := by simp only [div_eq_mul_inv,mul_inv_rev]; ring
    refine ⟨hlower.trans hlo,?_,hbase.trans_le (hlower.trans hlo)⟩
    convert hhi using 1 <;> simp only [div_eq_mul_inv,mul_inv_rev] <;> ring
  · intro T hT
    exact increment_walsh_singleton_neg (δ k) hp _ U (n k) hmono hkU T hT

end NeuralGeneralization.OnlineLowerTanh
