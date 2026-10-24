import NeuralGeneralization.BatchTwoContinuousFiniteInputStability
import NeuralGeneralization.BatchTwoNonGaussianSpectralLaw
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldBudget

/-! Actual non-Gaussian mean-field probability of bounded input Lipschitz
constant. Endpoint energies and internal operator norms are controlled under
the original independent-coordinate law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteInput
open ConcreteModel BatchTwoNonGaussian

def operatorBound (ν : CoordinateLaw) (K : ℕ) : ℕ := 32*NonGaussianMeanField.tailScale ν*(K+1)

theorem normalized_matrix_action {N : ℕ} (hN : 0<N) (a : Fin N×Fin N → ℝ) {b : ℝ}
    (ha : a∈matrixActionEvent N b) :
    matrixActionBound (fun i j => a (i,j)/Real.sqrt N) b := by
  intro z
  have h := ha z
  have hs : (Real.sqrt (N : ℝ))^2=N := Real.sq_sqrt (Nat.cast_nonneg N)
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have he : (∑ i,(∑ j,a (i,j)/Real.sqrt N*z j)^2)=
      (∑ i,(∑ j,a (i,j)*z j)^2)/(N : ℝ) := by
    simp only [div_mul_eq_mul_div,←Finset.sum_div,div_pow,hs]
  rw [he]
  apply (div_le_iff₀ hNR).mpr
  dsimp only [matrixActionEvent,matrixActionBound] at ha
  have hh := ha z
  rw [mul_pow,hs] at hh
  nlinarith

theorem raw_internal_action_tail (ν : CoordinateLaw) {d N r : ℕ} (hN : 0<N)
    (s : Fin r) {b : ℝ} (hb : 0≤b) :
    (rawPrior ν d N r).real {z | ¬matrixActionBound
      (fun i j => NonGaussianMeanField.weights z (.inr (.inl (s,i,j)))) b}≤
      2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) := by
  let e : Fin N×Fin N → WeightIndex d N r := fun ij => .inr (.inl (s,ij.1,ij.2))
  have he : Function.Injective e := by
    intro a b h
    simpa [e] using h
  have hm := productLaw_map_subfamily ν.law e he
  have hprob : (rawPrior ν d N r).real {z | (fun ij => z (e ij))∈(matrixActionEvent N b)ᶜ}=
      (Measure.pi fun _ : Fin N×Fin N => ν.law).real (matrixActionEvent N b)ᶜ := by
    rw [←hm]
    simp only [Measure.real]
    rw [Measure.map_apply (by fun_prop) (isClosed_matrixActionEvent N b).measurableSet.compl]
    rfl
  have hsub : {z : Weights d N r | ¬matrixActionBound
      (fun i j => NonGaussianMeanField.weights z (.inr (.inl (s,i,j)))) b}⊆
      {z | (fun ij => z (e ij))∈(matrixActionEvent N b)ᶜ} := by
    intro z hz hgood
    exact hz (normalized_matrix_action hN (fun ij => z (e ij)) hgood)
  exact ((measureReal_mono (μ := rawPrior ν d N r) hsub).trans hprob.le).trans
    (matrixActionEvent_tail ν N hb)

theorem operatorBound_rate (ν : CoordinateLaw) (K : ℕ) :
    (K : ℝ)+18≤(operatorBound ν K : ℝ)^2/(8*subGaussianVariance ν) := by
  have hq := NonGaussianMeanField.tailScale_ge_one ν
  have hvq := NonGaussianMeanField.tailScale_ge_variance ν
  have hv := subGaussianVariance_pos ν
  have hK : (0 : ℝ)≤K := Nat.cast_nonneg K
  apply (le_div_iff₀ (by positivity : 0<8*subGaussianVariance ν)).mpr
  have hh := mul_le_mul_of_nonneg_left hvq (by positivity : (0 : ℝ)≤8*((K : ℝ)+18))
  have hq2 : (NonGaussianMeanField.tailScale ν : ℝ)≤(NonGaussianMeanField.tailScale ν : ℝ)^2 := by nlinarith
  have hq2K := mul_le_mul_of_nonneg_right hq2 (sq_nonneg ((K : ℝ)+1))
  have hbase : 8*((K : ℝ)+18)≤1024*((K : ℝ)+1)^2 := by nlinarith [sq_nonneg (K : ℝ)]
  have hmul := mul_le_mul_of_nonneg_left hbase (by positivity : (0 : ℝ)≤NonGaussianMeanField.tailScale ν)
  unfold operatorBound
  push_cast
  nlinarith

theorem raw_internal_action_tail_polynomial (ν : CoordinateLaw) {d N r : ℕ} (hN : 0<N)
    (s : Fin r) (K : ℕ) :
    (rawPrior ν d N r).real {z | ¬matrixActionBound
      (fun i j => NonGaussianMeanField.weights z (.inr (.inl (s,i,j)))) (operatorBound ν K)}≤
      2*Real.exp (-(N : ℝ)*(K : ℝ)) := by
  apply (raw_internal_action_tail ν hN s (Nat.cast_nonneg _)).trans
  have h9 : (9 : ℝ)≤Real.exp 9 := (by linarith [Real.add_one_le_exp (9 : ℝ)])
  have hp := pow_le_pow_left₀ (by norm_num : (0 : ℝ)≤9) h9 (N+N)
  have he : (Real.exp (9 : ℝ))^(N+N)=Real.exp (18*(N : ℝ)) := by
    rw [←Real.exp_nat_mul]
    congr 1
    push_cast
    ring
  rw [he] at hp
  apply (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hp (by norm_num : (0 : ℝ)≤2)) (Real.exp_nonneg _)).trans
  rw [mul_assoc,←Real.exp_add]
  apply mul_le_mul_of_nonneg_left _ (by norm_num : (0 : ℝ)≤2)
  apply Real.exp_le_exp.mpr
  have h := mul_le_mul_of_nonneg_left (operatorBound_rate ν K) (Nat.cast_nonneg N : (0 : ℝ)≤N)
  ring_nf at h ⊢
  linarith

theorem goodWeights_complement_tail (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 0<d) (hN : 0<N)
    (hK : 8*NonGaussianMeanField.tailScale ν*(d+1)≤K) :
    (rawPrior ν d N r).real {z | NonGaussianMeanField.weights z∉
      goodWeights d N r K (operatorBound ν K)}≤
      (2*(r : ℝ)+2)*Real.exp (-(N : ℝ)*(K : ℝ)/(8*(NonGaussianMeanField.tailScale ν : ℝ))) := by
  let μ := powerPrior ν d N r 1
  let F : Set (Weights d N r) := {w | (K : ℝ)<(d : ℝ)/N*(∑ i,∑ j,w (.inl (i,j))^2)}
  let O : Set (Weights d N r) := {w | (K : ℝ)<(N : ℝ)*(∑ i,w (.inr (.inr i))^2)}
  let M (s : Fin r) : Set (Weights d N r) := {z | ¬matrixActionBound
    (fun i j => NonGaussianMeanField.weights z (.inr (.inl (s,i,j)))) (operatorBound ν K)}
  let t := Real.exp (-(N : ℝ)*(K : ℝ)/(8*(NonGaussianMeanField.tailScale ν : ℝ)))
  have hv := subGaussianVariance_pos ν
  have hq := NonGaussianMeanField.tailScale_ge_one ν
  have hvq := NonGaussianMeanField.tailScale_ge_variance ν
  have hKR : 8*((d : ℝ)+1)*subGaussianVariance ν≤(K : ℝ) := by
    have hc : 8*(NonGaussianMeanField.tailScale ν : ℝ)*((d : ℝ)+1)≤(K : ℝ) := by exact_mod_cast hK
    nlinarith [mul_le_mul_of_nonneg_left hvq (by positivity : 0≤8*((d : ℝ)+1))]
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have hf := powerPrior_first_energy_tail ν hd hN (r := r) 1 K (by
    simp only [Real.rpow_neg_one,Nat.cast_mul,Nat.cast_add,Nat.cast_one]
    convert hKR using 1 <;> field_simp <;> ring)
  have ho := powerPrior_readout_energy_tail ν hd hN (r := r) 1 K (by
    simp only [Real.rpow_neg_one]
    have hh : 8*subGaussianVariance ν≤(K : ℝ) := by nlinarith [mul_nonneg (Nat.cast_nonneg d : (0 : ℝ)≤d) hv.le]
    convert hh using 1 <;> field_simp)
  have he : Real.exp (-(K : ℝ)/(8*((N : ℝ)^(-(1 : ℝ))*subGaussianVariance ν)))≤t := by
    simp only [Real.rpow_neg_one]
    apply Real.exp_le_exp.mpr
    have hh := div_le_div_of_nonneg_left (show 0≤(N : ℝ)*(K : ℝ) by positivity)
      (show 0<8*subGaussianVariance ν by positivity) (show 8*subGaussianVariance ν≤8*(NonGaussianMeanField.tailScale ν : ℝ) by linarith)
    field_simp at hh ⊢
    nlinarith
  have hF : (rawPrior ν d N r).real (NonGaussianMeanField.weights ⁻¹' F)≤t := by
    have hm : (rawPrior ν d N r).real (NonGaussianMeanField.weights ⁻¹' F)=μ.real F := by
      dsimp only [μ]
      rw [←NonGaussianMeanField.map_weights_eq_powerPrior ν d N r]
      simp only [Measure.real]
      rw [
        Measure.map_apply (NonGaussianMeanField.continuous_weights d N r).measurable
          (show MeasurableSet F by apply measurableSet_lt measurable_const; fun_prop)]
    rw[hm]
    exact (measureReal_mono (μ := μ) (show F⊆{w | (K : ℝ)≤(d : ℝ)/N*(∑ i,∑ j,w (.inl (i,j))^2)} from by intro w hw; dsimp only [F,Set.mem_setOf_eq] at hw ⊢; exact hw.le)).trans (hf.trans he)
  have hO : (rawPrior ν d N r).real (NonGaussianMeanField.weights ⁻¹' O)≤t := by
    have hm : (rawPrior ν d N r).real (NonGaussianMeanField.weights ⁻¹' O)=μ.real O := by
      dsimp only [μ]
      rw [←NonGaussianMeanField.map_weights_eq_powerPrior ν d N r]
      simp only [Measure.real]
      rw [
        Measure.map_apply (NonGaussianMeanField.continuous_weights d N r).measurable
          (show MeasurableSet O by apply measurableSet_lt measurable_const; fun_prop)]
    rw[hm]
    exact (measureReal_mono (μ := μ) (show O⊆{w | (K : ℝ)≤(N : ℝ)*(∑ i,w (.inr (.inr i))^2)} from by intro w hw; dsimp only [O,Set.mem_setOf_eq] at hw ⊢; exact hw.le)).trans (ho.trans he)
  have hM : (rawPrior ν d N r).real (⋃ s,M s)≤2*(r : ℝ)*t := by
    apply (measureReal_iUnion_fintype_le M).trans
    have hexp : Real.exp (-(N : ℝ)*(K : ℝ))≤t := by
      apply Real.exp_le_exp.mpr
      have hh := div_le_self (show 0≤(N : ℝ)*(K : ℝ) by positivity) (show 1≤8*(NonGaussianMeanField.tailScale ν : ℝ) by linarith)
      simpa only [neg_mul,neg_div,neg_le_neg_iff] using hh
    calc
      _ ≤ ∑ _s : Fin r,2*t := Finset.sum_le_sum fun s _ =>
        (raw_internal_action_tail_polynomial ν hN s K).trans (mul_le_mul_of_nonneg_left hexp (by norm_num))
      _ = _ := by simp; ring
  have hs : {z | NonGaussianMeanField.weights z∉goodWeights d N r K (operatorBound ν K)}=
      (NonGaussianMeanField.weights ⁻¹' F) ∪ (NonGaussianMeanField.weights ⁻¹' O) ∪ ⋃ s,M s := by
    ext z
    simp only [goodWeights,F,O,M,Set.mem_preimage,Set.mem_setOf_eq,Set.mem_union,Set.mem_iUnion,
      not_and_or,not_le,not_forall]
    tauto
  rw [hs]
  have hu := measureReal_union_le (μ := rawPrior ν d N r)
    (NonGaussianMeanField.weights ⁻¹' F ∪ NonGaussianMeanField.weights ⁻¹' O) (⋃ s,M s)
  have hu' := measureReal_union_le (μ := rawPrior ν d N r)
    (NonGaussianMeanField.weights ⁻¹' F) (NonGaussianMeanField.weights ⁻¹' O)
  change _≤(2*(r : ℝ)+2)*t
  nlinarith

end NeuralGeneralization.BatchTwoContinuous.FiniteInput
