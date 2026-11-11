import NeuralGeneralization.BatchTwoContinuousDepthEnergyLipschitz
import NeuralGeneralization.BatchTwoContinuousConditionedRate

/-! The literal energy/product and depth-independent Lipschitz formulas from
`continuous-depth-lower-bound/source/posterior.tex`, in every input dimension. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower CompressionSampling Compression

def energyBudget (L : ℕ) (T : ℝ) : ℝ :=
  2 + ((L : ℝ)+14) * T ^ (1/((L : ℝ)-1))

def lipschitzCeiling (d : ℕ) (T : ℝ) : ℝ :=
  Real.exp (17/2) / Real.sqrt d * T ^ (3/4 : ℝ)

theorem energyBudget_nonneg {L : ℕ} {T : ℝ} (hT : 1 ≤ T) : 0 ≤ energyBudget L T := by
  unfold energyBudget
  positivity

theorem energyBudget_add_one {L : ℕ} (hL : 3 ≤ L) {T : ℝ} (hT : 1 ≤ T) :
    energyBudget L T+1 ≤ ((L : ℝ)+17)*T^(1/((L : ℝ)-1)) := by
  have hLR : (3 : ℝ) ≤ L := by exact_mod_cast hL
  have ht := Real.one_le_rpow hT (show 0 ≤ 1/((L : ℝ)-1) by apply div_nonneg (by norm_num); linarith)
  unfold energyBudget
  nlinarith

/-- The paper's exact product estimate, with no depth-dependent replacement. -/
theorem energyBudget_product {L : ℕ} (hL : 3 ≤ L) {T : ℝ} (hT : 1 ≤ T) :
    ((energyBudget L T+1)/(L : ℝ))^L ≤ Real.exp 17*T^(3/2 : ℝ) := by
  have hLR : (3 : ℝ) ≤ L := by exact_mod_cast hL
  have hLp : (0 : ℝ) < L := by linarith
  have hTm : 0 ≤ T := by linarith
  have hbase : (energyBudget L T+1)/(L : ℝ) ≤
      (1+17/(L : ℝ))*T^(1/((L : ℝ)-1)) := by
    calc
      _ ≤ (((L : ℝ)+17)*T^(1/((L : ℝ)-1)))/(L : ℝ) :=
        div_le_div_of_nonneg_right (energyBudget_add_one hL hT) hLp.le
      _ = _ := by field_simp <;> ring
  have hex : (1+17/(L : ℝ))^L ≤ Real.exp 17 := by
    calc
      _ ≤ (Real.exp (17/(L : ℝ)))^L := pow_le_pow_left₀ (by positivity)
        (by linarith only [Real.add_one_le_exp (17/(L : ℝ))]) L
      _ = Real.exp 17 := by rw [← Real.exp_nat_mul]; congr 1; field_simp
  have hpow : (T^(1/((L : ℝ)-1)))^L ≤ T^(3/2 : ℝ) := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul hTm]
    apply Real.rpow_le_rpow_of_exponent_le hT
    rw [one_div, inv_mul_eq_div]
    apply (div_le_iff₀ (by linarith : 0 < (L : ℝ)-1)).mpr
    linarith
  calc
    _ ≤ ((1+17/(L : ℝ))*T^(1/((L : ℝ)-1)))^L :=
      pow_le_pow_left₀ (by have := energyBudget_nonneg (L:=L) hT; positivity) hbase L
    _ = (1+17/(L : ℝ))^L*(T^(1/((L : ℝ)-1)))^L := mul_pow _ _ _
    _ ≤ Real.exp 17*T^(3/2 : ℝ) := mul_le_mul hex hpow (by positivity) (Real.exp_nonneg _)

/-- AM--GM in the exact finite-product form needed by the layer energies. -/
theorem product_le_average_power {ι : Type*} [Fintype ι] (e : ι → ℝ)
    (he : ∀ i, 0 ≤ e i) {a : ℝ} (ha : 0 < a)
    (hs : ∑ i, e i ≤ a*(Fintype.card ι : ℝ)) :
    ∏ i, e i ≤ a^Fintype.card ι := by
  classical
  have hp (i : ι) : e i ≤ a*Real.exp (e i/a-1) := by
    calc
      _ = a*((e i/a-1)+1) := by field_simp <;> ring
      _ ≤ _ := mul_le_mul_of_nonneg_left (Real.add_one_le_exp (e i/a-1)) ha.le
  calc
    _ ≤ ∏ i, a*Real.exp (e i/a-1) := Finset.prod_le_prod (fun i _ => he i) (fun i _ => hp i)
    _ = a^Fintype.card ι * Real.exp ((∑ i,e i)/a-(Fintype.card ι : ℝ)) := by
      rw [Finset.prod_mul_distrib, ← Real.exp_sum]
      simp [Finset.sum_sub_distrib, ← Finset.sum_div]
    _ ≤ a^Fintype.card ι*1 := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      rw [Real.exp_le_one_iff]
      have h := (div_le_iff₀ ha).mpr (by simpa only [mul_comm] using hs)
      linarith
    _ = _ := mul_one _

def layerEnergy {d N r : ℕ} (w : Weights d N r) : Fin r ⊕ Bool → ℝ
  | Sum.inl s => ∑ i,∑ j,(w (Sum.inr (Sum.inl (s,i,j))))^2
  | Sum.inr true => (d : ℝ)/N*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)
  | Sum.inr false => (N : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2)

theorem layerEnergy_nonneg {d N r : ℕ} (w : Weights d N r) (a : Fin r ⊕ Bool) :
    0 ≤ layerEnergy w a := by cases a with
  | inl s => unfold layerEnergy; positivity
  | inr b => cases b <;> unfold layerEnergy <;> positivity

theorem layerEnergy_sum {d N r : ℕ} (w : Weights d N r) :
    ∑ a,layerEnergy w a=weightedSquaredNorm w := by
  simp only [Fintype.sum_sum_type,Fintype.sum_bool,layerEnergy,weightedSquaredNorm]
  ring

theorem layerEnergy_product {d N r : ℕ} (w : Weights d N r) {K : ℝ} (hK : 0 < K)
    (hw : weightedSquaredNorm w ≤ K) :
    ∏ a, layerEnergy w a ≤ (K/((r : ℝ)+2))^(r+2) := by
  have h := product_le_average_power (layerEnergy w) (layerEnergy_nonneg w)
    (show 0 < K/((r : ℝ)+2) by positivity) (by
      simp only [layerEnergy_sum, Fintype.card_sum, Fintype.card_fin,
        Fintype.card_bool, Nat.cast_add, Nat.cast_ofNat]
      rw [div_mul_cancel₀ _ (by positivity)]
      exact hw)
  simpa only [Fintype.card_sum,Fintype.card_fin,Fintype.card_bool] using h

theorem layerEnergy_product_suffix {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w : Weights d N r) :
    suffixSquaredGain w 0*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)=
      (∏ a,layerEnergy w a)/(d : ℝ) := by
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  have hdR : (d : ℝ)≠0 := by exact_mod_cast hd.ne'
  simp only [Fintype.prod_sum_type,Fintype.prod_bool,layerEnergy,suffixSquaredGain,List.drop_zero,
    ← Fin.prod_univ_def]
  field_simp
  <;> ring


theorem output_difference_sq_le_product {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w : Weights d N r) (x y : RealInput d) :
    (output Real.tanh w x-output Real.tanh w y)^2 ≤
      ((∏ a,layerEnergy w a)/(d : ℝ))*(∑ i,(x i-y i)^2) := by
  have hφ : ∀ t s, |Real.tanh t-Real.tanh s| ≤ |t-s| := tanh_admissible.2
  have hh := activated_matrix_squaredDistance_le Real.tanh hφ
    (fun i j => w (Sum.inl (i,j))) (augmentedInput x) (augmentedInput y)
  rw [augmented_difference_sq_sum] at hh
  have hs := suffix_readout_squaredDistance_le Real.tanh hφ w 0
    (BatchTwoContinuous.firstHidden Real.tanh w x) (BatchTwoContinuous.firstHidden Real.tanh w y)
  have hs' : (output Real.tanh w x-output Real.tanh w y)^2 ≤
      suffixSquaredGain w 0*squaredDistance (BatchTwoContinuous.firstHidden Real.tanh w x)
        (BatchTwoContinuous.firstHidden Real.tanh w y) := by
    simpa [output,BatchTwoContinuous.finalHidden,linearReadout,hiddenSuffix] using hs
  have hh' : squaredDistance (BatchTwoContinuous.firstHidden Real.tanh w x)
      (BatchTwoContinuous.firstHidden Real.tanh w y) ≤
      (∑ i,∑ j,(w (Sum.inl (i,j)))^2)*(∑ i,(x i-y i)^2) := hh
  calc
    _ ≤ suffixSquaredGain w 0*((∑ i,∑ j,(w (Sum.inl (i,j)))^2)*(∑ i,(x i-y i)^2)) :=
      hs'.trans (mul_le_mul_of_nonneg_left hh' (suffixSquaredGain_nonneg w 0))
    _ = _ := by rw [← mul_assoc,layerEnergy_product_suffix hd hN]

theorem lipschitzCeiling_nonneg (d : ℕ) {T : ℝ} (hT : 0 ≤ T) :
    0 ≤ lipschitzCeiling d T := by unfold lipschitzCeiling; positivity

theorem lipschitzCeiling_sq (d : ℕ) {T : ℝ} (hT : 0 ≤ T) :
    (lipschitzCeiling d T)^2 = Real.exp 17/(d : ℝ)*T^(3/2 : ℝ) := by
  unfold lipschitzCeiling
  rw [mul_pow,div_pow,Real.sq_sqrt (Nat.cast_nonneg d)]
  have he : (Real.exp (17/2))^2 = Real.exp 17 := by
    rw [← Real.exp_nat_mul]
    norm_num
  have ht : (T^(3/4 : ℝ))^2 = T^(3/2 : ℝ) := by
    rw [← Real.rpow_natCast,← Real.rpow_mul hT]
    norm_num
  rw [he,ht]

/-- Literal exp(17/2)/sqrt(d) * T^(3/4) ceiling on the real output. -/
theorem energyBudget_output_lipschitz {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (hr : 1 ≤ r) {T : ℝ} (hT : 1 ≤ T) (w : Weights d N r)
    (hw : weightedSquaredNorm w ≤ energyBudget (r+2) T+1) (x y : RealInput d) :
    |output Real.tanh w x-output Real.tanh w y| ≤
      lipschitzCeiling d T * Real.sqrt (∑ i,(x i-y i)^2) := by
  have he0 := energyBudget_nonneg (L:=r+2) hT
  have hp := layerEnergy_product w (by linarith : 0 < energyBudget (r+2) T+1) hw
  have hp' : ∏ a,layerEnergy w a ≤ Real.exp 17*T^(3/2 : ℝ) := by
    apply hp.trans
    simpa only [Nat.cast_add, Nat.cast_ofNat] using energyBudget_product (by omega : 3 ≤ r+2) hT
  have hb := output_difference_sq_le_product hd hN w x y
  apply abs_le_of_sq_le_sq _ (mul_nonneg (lipschitzCeiling_nonneg d (by linarith)) (Real.sqrt_nonneg _))
  rw [mul_pow,lipschitzCeiling_sq d (by linarith),Real.sq_sqrt (by positivity)]
  apply hb.trans
  apply mul_le_mul_of_nonneg_right _ (by positivity)
  have hdiv := div_le_div_of_nonneg_right hp' (Nat.cast_nonneg d)
  simpa only [div_mul_eq_mul_div] using hdiv

/-- Every exact energy minimizer inherits the literal ceiling from a witness
at the manuscript's energy budget. The witness is not assumed to minimize. -/
theorem energyMinimizer_output_lipschitz {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    (hr : 1 ≤ r) {T : ℝ} (hT : 1 ≤ T) (f : RealInput d → ℝ) (s : Fin n → RealInput d)
    (v : Weights d N r) (hv : v ∈ exactInterpolants Real.tanh f s)
    (hvE : weightedSquaredNorm v ≤ energyBudget (r+2) T)
    (w : Weights d N r) (hw : w ∈ energyMinimizers Real.tanh f s) (x y : RealInput d) :
    |output Real.tanh w x-output Real.tanh w y| ≤
      lipschitzCeiling d T * Real.sqrt (∑ i,(x i-y i)^2) := by
  apply energyBudget_output_lipschitz hd hN hr hT w _ x y
  exact (energyMinimizers_energy_le hv hw).trans (hvE.trans (by linarith))


open MeasureTheory ProbabilityTheory Filter
open scoped Topology
open BatchTwoParameterPriorRate

def outputLipschitz {d N r : ℕ} (Λ : ℝ) (w : Weights d N r) : Prop :=
  ∀ x y : RealInput d, |output Real.tanh w x-output Real.tanh w y| ≤
    Λ*Real.sqrt (∑ i,(x i-y i)^2)

theorem isClosed_outputLipschitz {d N r : ℕ} (Λ : ℝ) :
    IsClosed {w : Weights d N r | outputLipschitz Λ w} := by
  simp only [outputLipschitz, Set.setOf_forall]
  apply isClosed_iInter
  intro x
  apply isClosed_iInter
  intro y
  exact isClosed_le (((continuous_output_weights tanh_continuous x).sub
    (continuous_output_weights tanh_continuous y)).abs) continuous_const

/-- The strong-prior ceiling lemma, as a limit of the actual posterior mass.
The exact interpolating witness has the precise manuscript energy budget. -/
theorem posterior_lipschitz_ceiling_tendsto_zero {d N r n : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hr : 1 ≤ r) {T : ℝ} (hT : 1 ≤ T)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) {ρ : ℝ} (hρ : 0 < ρ)
    (v : Weights d N r) (hv : v ∈ exactInterpolants Real.tanh f s)
    (hvE : weightedSquaredNorm v ≤ energyBudget (r+2) T) :
    Tendsto (fun σ => (BatchTwoContinuous.posterior Real.tanh (smallPrior d N r σ) f ρ s).real
      {w | ¬ outputLipschitz (lipschitzCeiling d T) w}) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hV : v ∈ trainingEvent Real.tanh f ρ s := by
    intro i
    have he := hv i
    rw [he,sub_self,abs_zero]
    exact hρ
  have he := eventEnergy_le hV
  have hK : 2*eventEnergy (trainingEvent (N:=N) (r:=r) Real.tanh f ρ s) <
      energyBudget (r+2) T+1 := by linarith
  have ht := posterior_energy_tail_tendsto_zero hd hN tanh_continuous f s ⟨v,hV⟩ hK
  have hsub : {w : Weights d N r | ¬ outputLipschitz (lipschitzCeiling d T) w} ⊆
      {w | energyBudget (r+2) T+1 < weightedSquaredNorm w} := by
    intro w hw
    by_contra hnot
    exact hw (energyBudget_output_lipschitz hd hN hr hT w (le_of_not_gt hnot))
  apply squeeze_zero' (Eventually.of_forall (fun _ => measureReal_nonneg)) _ ht
  filter_upwards [self_mem_nhdsWithin] with σ hσ
  have hσpos : 0 < σ := hσ
  letI := posterior_probability hd hN tanh_continuous f s hσpos ⟨v,hV⟩
  exact measureReal_mono hsub

end NeuralGeneralization.BatchTwoContinuousDepthPaper
