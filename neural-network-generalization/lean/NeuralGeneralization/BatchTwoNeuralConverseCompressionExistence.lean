import NeuralGeneralization.BatchTwoNeuralConverseCompressionNoise
import NeuralGeneralization.BatchTwoNeuralConverseCompressionBudget
import NeuralGeneralization.GaussianModelRate

/-! An actual compressed finite network at the manuscript's exact width. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical Set MeasureTheory ProbabilityTheory
open ConcreteModel CompressionSampling Compression
variable {d N r M : ℕ}

def stageSamplingBad (ρ K : ℝ) (w : Weights d N r) (x : Cube d)
    (s : Fin (r+1)) : Set (Fin (r+1) → Fin M → Fin N) :=
  Fin.lastCases (outputSamplingBad ρ K w x) (internalSamplingBad ρ K w x) s

theorem stageSamplingBad_probability (hN : 0<N) (hM : 0<M) {ρ K : ℝ} (hρ : 0<ρ) (hK : 0<K)
    (w : Weights d N r) (x : Cube d) (s : Fin (r+1)) :
    letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
    (allLayerLists N M r).real (stageSamplingBad (M:=M) ρ K w x s)≤
      Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
  induction s using Fin.lastCases with
  | last => simpa only [stageSamplingBad,Fin.lastCases_last] using outputSamplingBad_probability hN hM hρ hK w x
  | cast s => simpa only [stageSamplingBad,Fin.lastCases_castSucc] using internalSamplingBad_probability hN hM hρ hK w x s

theorem exists_good_compression_lists (hd : 0<d) (hN : 0<N) {ρ K : ℝ}
    (hρ : 0<ρ) (hρ6 : ρ≤1/6) (hK : 1≤K)
    (w : Weights d N r) (hw : weightedSquaredNorm w≤K) :
    ∃ I : Fin (r+1) → Fin (compressionWidth d r K ρ) → Fin N,
      weightedSquaredNorm (sampledWeights (compressionPruned ρ K w) I)≤4*K ∧
      ∀ x, (∀ s,I∉internalSamplingBad ρ K w x s) ∧ I∉outputSamplingBad ρ K w x := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  let M := compressionWidth d r K ρ
  have hM : 0<M := (compressionWidth_resources hd hK hρ hρ6).1
  have hK0 : 0<K := lt_of_lt_of_le zero_lt_one hK
  let E : Set (Fin (r+1) → Fin M → Fin N) := ⋃ z : Cube d × Fin (r+1), stageSamplingBad ρ K w z.1 z.2
  let F : Set (Fin (r+1) → Fin M → Fin N) := {I | 4*K≤weightedSquaredNorm (sampledWeights (compressionPruned ρ K w) I)}
  have hE : (allLayerLists N M r).real E≤((r:ℝ)+1)*2^d*Real.exp (1-(M:ℝ)*ρ^2/(128*K)) := by
    have hh := finite_failure_union_le (allLayerLists N M r)
      (fun z : Cube d × Fin (r+1) => stageSamplingBad (M:=M) ρ K w z.1 z.2)
      (fun z => stageSamplingBad_probability hN hM hρ hK0 w z.1 z.2)
    simpa only [Fintype.card_prod,Fintype.card_fin,Cube,Fintype.card_fun,Fintype.card_bool,
      Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_add,Nat.cast_one,mul_comm,mul_left_comm,mul_assoc] using hh
  have hF : (allLayerLists N M r).real F≤1/4 :=
    sampled_cost_tail hM (compressionPruned ρ K w) hK0 ((compressionPruned_cost_le ρ K w).trans hw)
  have hsmall : (allLayerLists N M r).real (E∪F)<1 := by
    have he := compressionWidth_union_bound (r:=r) hd hK hρ
    have hu := measureReal_union_le E F (μ := allLayerLists N M r)
    dsimp [M] at hE hu ⊢
    linarith
  have hne : ∃ I,I∉E∪F := by
    by_contra! hall
    have heq : E∪F=Set.univ := Set.eq_univ_of_forall hall
    rw [heq,probReal_univ] at hsmall
    exact lt_irrefl _ hsmall
  obtain ⟨I,hI⟩ := hne
  have hnotE : I∉E := fun he => hI (Or.inl he)
  have hnotF : I∉F := fun hf => hI (Or.inr hf)
  refine ⟨I,(lt_of_not_ge hnotF).le,?_⟩
  intro x
  constructor
  · intro s hs
    exact hnotE (Set.mem_iUnion.mpr ⟨(x,s.castSucc),by simpa [stageSamplingBad] using hs⟩)
  · intro ho
    exact hnotE (Set.mem_iUnion.mpr ⟨(x,Fin.last r),by simpa [stageSamplingBad] using ho⟩)

theorem coordinate_bound_of_energy (hd : 0<d) (hN : 0<N) (w : Weights d N r)
    {K : ℝ} (hK : 0≤K) (hw : weightedSquaredNorm w≤4*K) :
    boundedWeights (2*Real.sqrt ((N:ℝ)*K)) w := by
  have hd1 : (1:ℝ)≤d := by exact_mod_cast hd
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hN0 : (0:ℝ)<N := by exact_mod_cast hN
  have hprec (j : WeightIndex d N r) : (N:ℝ)⁻¹≤coordinatePrecision d N r j := by
    rcases j with ij | (sij | j)
    · change (N:ℝ)⁻¹≤(d:ℝ)/N
      simpa only [one_div] using div_le_div_of_nonneg_right hd1 hN0.le
    · simp only [coordinatePrecision]
      exact inv_le_one_of_one_le₀ hN1
    · change (N:ℝ)⁻¹≤N
      exact (inv_le_one_of_one_le₀ hN1).trans hN1
  intro i
  have hs : coordinatePrecision d N r i*(w i)^2≤weightedSquaredNorm w := by
    rw [weightedSquaredNorm_eq_coordinateSum]
    exact Finset.single_le_sum (s := Finset.univ)
      (f := fun j : WeightIndex d N r => coordinatePrecision d N r j*(w j)^2)
      (fun j _ => mul_nonneg ((inv_pos.mpr hN0).le.trans (hprec j)) (sq_nonneg _))
      (Finset.mem_univ i)
  have hq := (mul_le_mul_of_nonneg_right (hprec i) (sq_nonneg (w i))).trans (hs.trans hw)
  have hq' : (w i)^2≤4*(N:ℝ)*K := by
    have hh := (inv_mul_le_iff₀ hN0).mp hq
    nlinarith only [hh]
  apply (sq_le_sq₀ (abs_nonneg _) (by positivity)).mp
  rw [sq_abs,mul_pow,Real.sq_sqrt (by positivity)]
  nlinarith only [hq']

/-- The analytic compressor: no unproved approximation or sampling hypothesis. -/
theorem robust_energy_compression (hd : 0<d) (hN : 0<N) {ρ K : ℝ}
    (hρ : 0<ρ) (hρ6 : ρ≤1/6) (hK : 1≤K)
    (w : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (hrob : ∀ x η,noiseBudgetSq η≤ρ^2 →
      |clippedScore (noisyNetworkOutput Real.tanh w x η)-clippedScore (networkOutput Real.tanh w x)|≤1/16) :
    ∃ u : Weights d (compressionWidth d r K ρ) r,
      weightedSquaredNorm u≤4*K ∧ boundedWeights (2*Real.sqrt ((compressionWidth d r K ρ:ℝ)*K)) u ∧
      ∀ x,|clippedScore (networkOutput Real.tanh u x)-clippedScore (networkOutput Real.tanh w x)|≤1/16 := by
  obtain ⟨I,hI,hgood⟩ := exists_good_compression_lists hd hN hρ hρ6 hK w hw
  refine ⟨sampledWeights (compressionPruned ρ K w) I,hI,
    coordinate_bound_of_energy hd (compressionWidth_resources hd hK hρ hρ6).1 _ (by linarith) hI,?_⟩
  intro x
  have hnoise := virtualDisturbance_budget hN hρ (by linarith) w hw I x (hgood x).1 (hgood x).2
  have hh := hrob x (virtualDisturbance w (compressionPruned ρ K w) I x)
    (hnoise.trans (by nlinarith [sq_nonneg ρ]))
  rw [virtual_disturbance_output,←sampled_output_eq_virtual] at hh
  exact hh

end
end NeuralGeneralization.BatchTwoNeuralConverse
