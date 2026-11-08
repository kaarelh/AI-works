import NeuralGeneralization.OnlineLowerTanhResidualCLT
import NeuralGeneralization.OnlineLowerTanhResidualBalanced
import NeuralGeneralization.OnlineLowerTanhConditioningCap
import NeuralGeneralization.OnlineLowerCentralBinomialLimit
import Mathlib.Analysis.Normed.Group.Tannery

/-! Uniform residual bounds transfer through actual coordinate conditioning.
The normalization keeps the full incoming energy, including omitted coordinates. -/
noncomputable section
open scoped Topology BigOperators
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicCoefficient_continuousAt {a : ℝ} (ha : 0 < a) (j : ℕ) :
    ContinuousAt (fun a => periodicCoefficient a j) a := by
  have hdec : ContinuousAt periodicDecay a := by
    unfold periodicDecay
    fun_prop (disch := positivity)
  unfold periodicCoefficient
  apply ContinuousAt.div
  · fun_prop (disch := positivity)
  · exact Real.continuous_sinh.continuousAt.comp (continuousAt_const.mul hdec)
  · exact ne_of_gt (Real.sinh_pos_iff.mpr (by
      have h := periodicDecay_pos ha
      positivity))

lemma scalarF0_tendsto_of_positive {ι : Type*} {l : Filter ι}
    {a : ι → ℝ} {a0 : ℝ} (ha0 : 0 < a0) (ha : Tendsto a l (𝓝 a0)) :
    Tendsto (fun i => scalarF0 (a i)) l (𝓝 (scalarF0 a0)) := by
  let lo := a0/2
  let hi := a0+1
  have hlo : 0 < lo := by dsimp [lo]; positivity
  have hhi : 0 < hi := by dsimp [hi]; positivity
  have hbounds : ∀ᶠ i in l, lo ≤ a i ∧ a i ≤ hi :=
    (ha.eventually (Icc_mem_nhds (by dsimp [lo]; linarith)
      (by dsimp [hi]; linarith)))
  have hq := periodicRatio_mem hhi
  have hsum := ((hasSum_geometric_of_lt_one hq.1.le hq.2).summable).mul_left
    ((Real.pi/lo)/Real.sinh (periodicDecay hi))
  have ht := tendsto_tsum_of_dominated_convergence hsum
    (fun j => tendsto_const_nhds.mul ((periodicCoefficient_continuousAt ha0 j).tendsto.comp ha))
    (show ∀ᶠ i in l, ∀j:ℕ, ‖(-1:ℝ)^j*periodicCoefficient (a i) j‖ ≤
      ((Real.pi/lo)/Real.sinh (periodicDecay hi))*periodicRatio hi^j from by
      filter_upwards [hbounds] with i hi' j
      rw [Real.norm_eq_abs,abs_mul,abs_neg_one_pow,one_mul,
        abs_of_pos (periodicCoefficient_pos (hlo.trans_le hi'.1) j)]
      exact periodicCoefficient_compact_bound hlo hi'.1 hi'.2 j)
  have hid (x : ℝ) (hx : 0 < x) :
      (∑' j:ℕ, (-1:ℝ)^j*periodicCoefficient x j) = scalarF0 x := by
    rw [← periodicFourierMaximum_eq_scalarF0 x hx]
    have h := periodicFourierResponse_centered hx 0
    simpa only [periodicFourierMaximum,add_zero,periodicCenteredTerm,mul_zero,
      Real.cos_zero,mul_one] using h.symm
  rw [hid a0 ha0] at ht
  apply ht.congr'
  filter_upwards [hbounds] with i hi'
  exact hid (a i) (hlo.trans_le hi'.1)

lemma smoothedResponse_le_scalarF0 {a E : ℝ} (ha : 0 < a) (ha2 : a ≤ 2)
    (hE : 0 ≤ E) (b : ℝ) : |smoothedResponse a E b| ≤ scalarF0 a := by
  have h := smoothedResponse_energy_deficit ha ha2 hE b
  have he : Real.exp (-E*periodicFrequency a^2/2) ≤ 1 :=
    Real.exp_le_one_iff.mpr (by nlinarith [mul_nonneg hE (sq_nonneg (periodicFrequency a))])
  have hp := periodicCoefficient_pos ha 0
  rw [periodicFourierMaximum_eq_scalarF0 a ha] at h
  nlinarith

lemma residualLeading_scaled_cap {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀i, 0 < q i) (d : Fin n → ℝ) {A : ℝ} (hA : 0 < A) (hA2 : A ≤ 2) (B : ℝ) :
    Real.sqrt (residualVariance q)*|residualLeading q d A B| ≤
      Real.sqrt (2/Real.pi)*scalarF0 A := by
  have hV := residualVariance_pos hn q hq
  have hs := smoothedResponse_le_scalarF0 (E := ∑i,(d i)^2) hA hA2
    (Finset.sum_nonneg (fun i _ => sq_nonneg (d i))) (B+(n%2:ℕ)*A)
  have hF : 0 ≤ scalarF0 A := (abs_nonneg _).trans hs
  have he : Real.exp (-B^2/(2*A^2*residualVariance q)) ≤ 1 :=
    Real.exp_le_one_iff.mpr (by
      have hd : 0 < 2*A^2*residualVariance q := by positivity
      exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg B)) hd.le)
  have hnorm : Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q)) =
      Real.sqrt (2/Real.pi) := by
    rw [← Real.sqrt_mul hV.le]
    congr 1
    field_simp
  unfold residualLeading
  rw [abs_mul,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),abs_of_pos (Real.exp_pos _)]
  calc
    _ = (Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q)))*
        (Real.exp (-B^2/(2*A^2*residualVariance q))*
          |smoothedResponse A (∑i,(d i)^2) (B+(n%2:ℕ)*A)|) := by ring
    _ ≤ Real.sqrt (2/Real.pi)*scalarF0 A := by
      rw [hnorm]
      apply mul_le_mul_of_nonneg_left _ (Real.sqrt_nonneg _)
      exact (mul_le_mul_of_nonneg_left hs (Real.exp_pos _).le).trans
        (mul_le_of_le_one_left hF he)

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

/-- Uniformity in the external bias is what permits conditioning away all
coordinates outside the selected finite-frequency alphabet. -/
theorem uniform_scaled_cap (hA0 : S.A₀ < 2) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀B:ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*|parityCorrelation (S.incoming k) B| ≤
        Real.sqrt (2/Real.pi)*scalarF0 S.A₀+ε := by
  intro ε hε
  have ht := (scalarF0_tendsto_of_positive (S.lo_pos.trans_le S.A₀_lo) S.A_tendsto).const_mul
    (Real.sqrt (2/Real.pi))
  filter_upwards [S.uniform_residual_clt (ε/2) (by positivity),
    S.A_tendsto.eventually (gt_mem_nhds hA0),
    ht.eventually (gt_mem_nhds (by linarith : Real.sqrt (2/Real.pi)*scalarF0 S.A₀ <
      Real.sqrt (2/Real.pi)*scalarF0 S.A₀+ε/2))] with k hk hA hF B
  have hl := residualLeading_scaled_cap (S.N_pos k) (S.alphabet k) (S.alphabet_pos k)
    (S.d k) (S.gain_pos k) hA.le B
  have htri := abs_add_le (parityCorrelation (S.incoming k) B-
    residualLeading (S.alphabet k) (S.d k) (S.A k) B)
    (residualLeading (S.alphabet k) (S.d k) (S.A k) B)
  rw [sub_add_cancel] at htri
  have hm := mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (residualVariance (S.alphabet k)))
  rw [mul_add] at hm
  linarith [hk B]

end ResidualSequence
/-- A normalization lemma keeps the full energy E, rather than replacing it
by the energy of the retained coordinates. -/
theorem normalized_efficiency_upper_bound
    (N V E c : ℕ → ℝ) (v e B : ℝ) (hv : 0 < v) (he : 0 < e)
    (hN : ∀ᶠ k in atTop, 0 < N k)
    (hV : Tendsto (fun k => V k/N k) atTop (𝓝 v))
    (hE : Tendsto (fun k => E k/N k) atTop (𝓝 e))
    (hcap : ∀ δ > 0, ∀ᶠ k in atTop, Real.sqrt (V k)*|c k| ≤ B+δ) :
    ∀ ε > 0, ∀ᶠ k in atTop,
      N k*|c k|/Real.sqrt (E k) ≤ B/Real.sqrt (v*e)+ε := by
  intro ε hε
  let d := Real.sqrt (v*e)
  have hd : 0 < d := Real.sqrt_pos.mpr (mul_pos hv he)
  let δ := ε*d/2
  have hδ : 0 < δ := by dsimp [δ]; positivity
  have ht : Tendsto (fun k => (B+δ)/Real.sqrt ((V k/N k)*(E k/N k))) atTop
      (𝓝 ((B+δ)/d)) := tendsto_const_nhds.div (Real.continuous_sqrt.continuousAt.tendsto.comp
        (hV.mul hE)) hd.ne'
  have htlim : (B+δ)/d < B/d+ε := by
    dsimp [δ]
    rw [add_div]
    have hcancel : ε*d/2/d = ε/2 := by field_simp
    rw [hcancel]
    linarith
  filter_upwards [hN,hV.eventually (lt_mem_nhds hv),hE.eventually (lt_mem_nhds he),
    hcap δ hδ,ht.eventually (gt_mem_nhds htlim)] with k hn hvk hek hck htk
  have hVk : 0 < V k := ((div_pos_iff.mp hvk).resolve_right (by intro h; linarith)).1
  have hEk : 0 < E k := ((div_pos_iff.mp hek).resolve_right (by intro h; linarith)).1
  have heq : N k*|c k|/Real.sqrt (E k) =
      (Real.sqrt (V k)*|c k|)/Real.sqrt ((V k/N k)*(E k/N k)) := by
    rw [Real.sqrt_mul hvk.le,Real.sqrt_div hVk.le,Real.sqrt_div hEk.le]
    have hvroot := Real.sqrt_pos.mpr hVk
    have heroot := Real.sqrt_pos.mpr hEk
    have hnroot := Real.sqrt_pos.mpr hn
    field_simp
    rw [Real.sq_sqrt hn.le]
    ring
  rw [heq]
  exact (div_le_div_of_nonneg_right hck (Real.sqrt_nonneg _)).trans htk.le

namespace ResidualSequence
variable {ι : Type*} [Fintype ι] [DecidableEq ι] (S : ResidualSequence ι)

/-- Any actual full correlation controlled by conditioning on this residual
sequence has the sharp normalized efficiency upper bound. -/
theorem conditioned_efficiency_upper_bound (hA0 : S.A₀ < 2)
    (N : ℕ → ℕ) (u : (k : ℕ) → Fin (N k) → ℝ) (bias : ℕ → ℝ)
    (A : (k : ℕ) → Finset (Fin (N k)))
    (hidentify : ∀k B, parityCorrelation (subsetWeights (A k) (fun i => |u k i|)) B =
      parityCorrelation (S.incoming k) B)
    (v e : ℝ) (hv : 0 < v) (he : 0 < e)
    (hN : ∀ᶠ k in atTop, 0 < N k)
    (hV : Tendsto (fun k => residualVariance (S.alphabet k)/(N k:ℝ)) atTop (𝓝 v))
    (hE : Tendsto (fun k => incomingEnergy (u k)/(N k:ℝ)) atTop (𝓝 e)) :
    ∀ ε > 0, ∀ᶠ k in atTop,
      (N k:ℝ)*|parityCorrelation (u k) (bias k)|/Real.sqrt (incomingEnergy (u k)) ≤
      (Real.sqrt (2/Real.pi)*scalarF0 S.A₀)/Real.sqrt (v*e)+ε := by
  apply normalized_efficiency_upper_bound (fun k => (N k:ℝ))
    (fun k => residualVariance (S.alphabet k)) (fun k => incomingEnergy (u k))
    (fun k => parityCorrelation (u k) (bias k)) v e _ hv he
  · filter_upwards [hN] with k hk
    exact_mod_cast hk
  · exact hV
  · exact hE
  · intro δ hδ
    filter_upwards [S.uniform_scaled_cap hA0 δ hδ] with k hk
    have hroot := Real.sqrt_pos.mpr (residualVariance_pos (S.N_pos k) (S.alphabet k) (S.alphabet_pos k))
    rw [parityCorrelation_abs_weights]
    rw [mul_comm]
    apply (le_div_iff₀ hroot).mp
    apply parityCorrelation_le_uniform_subset_cap (A k) (fun i => |u k i|) (bias k)
    intro B
    rw [hidentify]
    exact (le_div_iff₀ hroot).mpr (by simpa only [mul_comm] using hk B)

end ResidualSequence
end NeuralGeneralization.OnlineLowerTanh
