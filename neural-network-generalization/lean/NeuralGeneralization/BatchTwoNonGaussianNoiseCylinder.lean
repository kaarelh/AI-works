import NeuralGeneralization.BatchTwoNonGaussianGroupGeometry
import NeuralGeneralization.BatchTwoNonGaussianMatrixTail
import NeuralGeneralization.NetworkInputSplit

/-! Probability and measurability of the genuine non-Gaussian teacher cylinder.
The unrestricted matrices are intersected with action bounds under the original
product law; no conditional independence or convex-conditioning lemma is used. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel GaussianTail NetworkLayerSplit

def matrixGroupEvent {C k p N : ℕ} (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (ρ : ℝ) : Set (Fin N × Fin N → ℝ) :=
  {z | ∀ i, (fun j => z (i,j)) ∈ groupCylinder e ρ}

theorem matrixGroupEvent_probability (ν : CoordinateLaw) {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ : ℝ) :
    (Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixGroupEvent e ρ) =
      ((Measure.pi fun _ : Fin k => ν.law).real {x | |normalizedSum k x| ≤ ρ})^(C*N) := by
  have h := (LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin N) (_ : Fin N) => ν.law)).symm
  simp only [MeasurableEquiv.symm_symm] at h
  have he : matrixGroupEvent e ρ = (MeasurableEquiv.curry (Fin N) (Fin N) ℝ) ⁻¹'
      (Set.pi Set.univ fun _ : Fin N => groupCylinder e ρ) := by
    ext z
    simp only [matrixGroupEvent, Set.mem_setOf_eq, Set.mem_preimage, Set.mem_pi,
      Set.mem_univ, forall_true_left]
    rfl
  rw [he, Measure.real, ← MeasurableEquiv.map_apply, h.map_eq, Measure.pi_pi,
    Finset.prod_const, Finset.card_univ, Fintype.card_fin, ENNReal.toReal_pow]
  change ((Measure.pi fun _ : Fin N => ν.law).real (groupCylinder e ρ))^N = _
  rw [groupCylinder_probability, pow_mul]

def matrixActionEvent (N : ℕ) (b : ℝ) : Set (Fin N × Fin N → ℝ) :=
  {z | matrixActionBound (fun i j => z (i,j)) (b*Real.sqrt N)}

theorem isClosed_matrixActionEvent (N : ℕ) (b : ℝ) : IsClosed (matrixActionEvent N b) := by
  unfold matrixActionEvent matrixActionBound
  simp only [setOf_forall]
  apply isClosed_iInter
  intro v
  apply isClosed_le _ continuous_const
  fun_prop

theorem matrixActionEvent_tail (ν : CoordinateLaw) (N : ℕ) {b : ℝ} (hb : 0 ≤ b) :
    (Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixActionEvent N b)ᶜ ≤
      2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) := by
  have hsub : (matrixActionEvent N b)ᶜ ⊆
      {z | b*Real.sqrt N < ‖coordinateMatrixOperator z‖} := by
    intro z hz
    by_contra hn
    change ¬b*Real.sqrt N < ‖coordinateMatrixOperator z‖ at hn
    exact hz (matrixActionBound_of_operatorNorm (fun i j => z (i,j))
      (b*Real.sqrt N) (by positivity) (le_of_not_gt hn))
  have ht := actual_matrix_operator_tail (m := Fin N) (n := Fin N) ν
    (b*Real.sqrt N/2) (by positivity)
  have he : 2*(b*Real.sqrt (N : ℝ)/2)=b*Real.sqrt N := by ring
  rw [he] at ht
  have hexp : -(b*Real.sqrt (N : ℝ)/2)^2/(2*subGaussianVariance ν)=
      -b^2*N/(8*subGaussianVariance ν) := by
    rw [div_pow, mul_pow, Real.sq_sqrt (Nat.cast_nonneg _)]
    ring
  simpa only [hexp, Fintype.card_fin] using (measureReal_mono hsub).trans ht

def matrixNoiseCylinder {C k p N : ℕ} (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (ρ b : ℝ) : Set (Fin N × Fin N → ℝ) := matrixGroupEvent e ρ ∩ matrixActionEvent N b

theorem measurable_matrixNoiseCylinder {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) :
    MeasurableSet (matrixNoiseCylinder e ρ b) := by
  apply MeasurableSet.inter _ (isClosed_matrixActionEvent N b).measurableSet
  unfold matrixGroupEvent
  simp only [setOf_forall]
  apply MeasurableSet.iInter
  intro i
  exact (measurable_groupCylinder e ρ).preimage (by fun_prop)

theorem matrixNoiseCylinder_lower (ν : CoordinateLaw) {C k p N : ℕ} (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) {ρ b : ℝ}
    (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2) (hb : 0 ≤ b)
    (hsize : 4*(smallBallTilt ρ)^2 ≤ (k : ℝ))
    (herr : (replacementConstant ν standardGaussian*lindebergPolynomial (smallBallTilt ρ))^2 ≤ (k : ℝ)) :
    (ρ^2/1024)^(C*N)-2*(9 : ℝ)^(N+N)*Real.exp (-b^2*N/(8*subGaussianVariance ν)) ≤
      (Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixNoiseCylinder e ρ b) := by
  let μ := Measure.pi fun _ : Fin N × Fin N => ν.law
  have hg : (ρ^2/1024)^(C*N) ≤ μ.real (matrixGroupEvent e ρ) := by
    rw [matrixGroupEvent_probability]
    exact pow_le_pow_left₀ (by positivity) (normalized_sum_small_ball ν k hk hρ hρhalf hsize herr) _
  have ht := matrixActionEvent_tail ν N hb
  have hm := le_measureReal_sdiff (μ := μ) (s₁ := matrixGroupEvent e ρ)
    (s₂ := (matrixActionEvent N b)ᶜ) (measure_ne_top _ _)
  have he : matrixGroupEvent e ρ \ (matrixActionEvent N b)ᶜ = matrixNoiseCylinder e ρ b := by
    ext z
    simp [matrixNoiseCylinder]
  rw [he] at hm
  linarith

def rawPrior (ν : CoordinateLaw) (d N r : ℕ) : Measure (Weights d N r) :=
  Measure.pi fun _ : WeightIndex d N r => ν.law

instance (ν : CoordinateLaw) (d N r : ℕ) : IsProbabilityMeasure (rawPrior ν d N r) := by
  unfold rawPrior
  infer_instance

theorem rawPrior_layer_split (ν : CoordinateLaw) (d N r : ℕ) :
    MeasurePreserving (NetworkLayerSplit.split d N r) (rawPrior ν d N (r+1))
      ((rawPrior ν d N r).prod (Measure.pi fun _ : Fin N × Fin N => ν.law)) := by
  have h1 := measurePreserving_piCongrLeft
    (fun _ : WeightIndex d N (r+1) => ν.law) (NetworkLayerSplit.indexJoin d N r)
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun _ : WeightIndex d N r ⊕ (Fin N × Fin N) => ν.law)
  exact MeasurePreserving.symm (NetworkLayerSplit.split d N r).symm (h1.comp h2)

theorem rawPrior_input_split (ν : CoordinateLaw) (d N : ℕ) :
    MeasurePreserving (NetworkInputSplit.split d N) (rawPrior ν d N 0)
      ((Measure.pi fun _ : Fin N × Fin (d+1) => ν.law).prod
        (Measure.pi fun _ : Fin N => ν.law)) := by
  have h1 := measurePreserving_piCongrLeft
    (fun _ : WeightIndex d N 0 => ν.law) (NetworkInputSplit.indexJoin d N)
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun _ : (Fin N × Fin (d+1)) ⊕ Fin N => ν.law)
  exact MeasurePreserving.symm (NetworkInputSplit.split d N).symm (h1.comp h2)

def noiseCylinder {C k p N : ℕ} (d : ℕ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) : (r : ℕ) → Set (Weights d N r)
  | 0 => (NetworkInputSplit.split d N) ⁻¹'
      ((Set.pi Set.univ fun _ => Icc (-ρ) ρ) ×ˢ (Set.pi Set.univ fun _ => Icc (-ρ) ρ))
  | r+1 => (NetworkLayerSplit.split d N r) ⁻¹'
      (noiseCylinder d e ρ b r ×ˢ matrixNoiseCylinder e ρ b)

theorem measurable_noiseCylinder {C k p N : ℕ} (d : ℕ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) (r : ℕ) :
    MeasurableSet (noiseCylinder d e ρ b r) := by
  induction r with
  | zero => exact ((MeasurableSet.univ_pi (fun _ => measurableSet_Icc)).prod
      (MeasurableSet.univ_pi (fun _ => measurableSet_Icc))).preimage (NetworkInputSplit.split d N).measurable
  | succ r ih =>
    exact (ih.prod (measurable_matrixNoiseCylinder e ρ b)).preimage
      (NetworkLayerSplit.split d N r).measurable

theorem noiseCylinder_probability (ν : CoordinateLaw) {C k p N : ℕ} (d : ℕ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) (r : ℕ) :
    (rawPrior ν d N r).real (noiseCylinder d e ρ b r) =
      (ν.law.real (Icc (-ρ) ρ))^(N*(d+2))*
        ((Measure.pi fun _ : Fin N × Fin N => ν.law).real (matrixNoiseCylinder e ρ b))^r := by
  induction r with
  | zero =>
    rw [noiseCylinder, Measure.real, ← MeasurableEquiv.map_apply,
      (rawPrior_input_split ν d N).map_eq, Measure.prod_prod,
      Measure.pi_pi, Measure.pi_pi, Finset.prod_const, Finset.prod_const,
      Finset.card_univ, Finset.card_univ, Fintype.card_prod, Fintype.card_fin,
      Fintype.card_fin, ENNReal.toReal_mul, ENNReal.toReal_pow, ENNReal.toReal_pow,
      pow_zero, mul_one, ← pow_add]
    congr 1
  | succ r ih =>
    rw [noiseCylinder, Measure.real, ← MeasurableEquiv.map_apply,
      (rawPrior_layer_split ν d N r).map_eq, Measure.prod_prod, ENNReal.toReal_mul]
    change (rawPrior ν d N r).real (noiseCylinder d e ρ b r)*_ = _
    rw [ih, pow_succ, mul_assoc]
    rfl

end NeuralGeneralization.BatchTwoNonGaussian
