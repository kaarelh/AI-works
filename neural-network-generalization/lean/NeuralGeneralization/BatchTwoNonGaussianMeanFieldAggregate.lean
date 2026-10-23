import NeuralGeneralization.BatchTwoNonGaussianMeanFieldBudget

/-! Aggregate mass outside the polynomial-size actual-network class for the
original non-Gaussian mean-field learner. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
open ConcreteModel MeanFieldBudgets

def goodWeights (ν : CoordinateLaw) (d N r K : ℕ) : Set (Weights d N r) :=
  {z | GoodHidden ν d N r (fun s => (layerBudget r (2*K) (s+1) : ℝ)) (K : ℝ) z ∧
    (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2) ≤ (K : ℝ)}

theorem excluded_mass_le_bad_event (ν : CoordinateLaw) {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (hK : 0 < K) (hNT : widthThreshold ν d r K ≤ N) :
    (∑ f ∈ Finset.univ \ functions ν d r K,
      functionMass Real.tanh (1/2) (powerPrior ν d N r 1) f) ≤
        (rawPrior ν d N r).real (goodWeights ν d N r K)ᶜ := by
  classical
  let A := Finset.univ \ functions ν d r K
  have hmeas : MeasurableSet (⋃ f ∈ A, marginEvent (N := N) (r := r) Real.tanh (1/2) f) := by
    exact MeasurableSet.biUnion (Set.to_countable _) (fun f hf =>
      (isOpen_marginEvent tanh_continuous (1/2) f).measurableSet)
  have heq : (powerPrior ν d N r 1).real (⋃ f ∈ A, marginEvent Real.tanh (1/2) f)=
      ∑ f ∈ A, functionMass Real.tanh (1/2) (powerPrior ν d N r 1) f := by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg => marginEvents_disjoint Real.tanh (by norm_num) hfg)
      (fun f hf => (isOpen_marginEvent tanh_continuous (1/2) f).measurableSet)
  rw [←heq,←map_weights_eq_powerPrior ν d N r,Measure.real,
    Measure.map_apply (continuous_weights d N r).measurable hmeas]
  apply measureReal_mono _ (measure_ne_top _ _)
  intro z hz hgood
  obtain ⟨f,hf,hm⟩ := Set.mem_iUnion₂.mp hz
  obtain ⟨hsize,herr⟩ := widthThreshold_budget ν hK hNT
  exact (Finset.mem_sdiff.mp hf).2
    (good_network_mem_functions ν hd hN hK z f hm hgood.2 hsize herr hgood.1)

theorem aggregate_tail (ν : CoordinateLaw) (r d : ℕ) (hd : 1 ≤ d)
    (K : ℕ) (hK : 8*tailScale ν ≤ K) (N : ℕ) (hNT : widthThreshold ν d r K ≤ N) :
    (∑ f ∈ Finset.univ \ functions ν d r K,
      functionMass Real.tanh (1/2) (powerPrior ν d N r 1) f) ≤
      ((r : ℝ)+2)*Real.exp (-(N : ℝ)*(K : ℝ)/(8*(tailScale ν : ℝ))) := by
  have hq : (1 : ℝ) ≤ tailScale ν := tailScale_ge_one ν
  have hqN : 1 ≤ tailScale ν := by exact_mod_cast hq
  have hK8 : 8 ≤ K := by omega
  have hK0 : 0 < K := by omega
  have hN : 0 < N := (widthThreshold_pos ν d r K).trans_le hNT
  have hKR : 8*(tailScale ν : ℝ) ≤ K := by exact_mod_cast hK
  let G : ℕ → ℝ := fun s => (layerBudget r (2*K) (s+1) : ℝ)
  have hh := goodHidden_compl_tail ν (r := r) (s := sparseCount r (2*K)) (by omega) hN
    (sparseCount_pos r (2*K)) G (K : ℝ) (by exact_mod_cast (by omega : 4 ≤ K))
    (fun j hj => by dsimp [G]; exact_mod_cast layerBudget_pos r (show 0 < 2*K by omega) (j+1))
    (fun j hj => layerBudget_sq_le_twice_sparseCount r (2*K) (show 1 ≤ j+1 by omega))
    (widthThreshold_entropy ν (by omega) hNT)
  have hr := readout_bad_tail ν (d := d) (r := r) hN
    (show 8*subGaussianVariance ν ≤ (K : ℝ) by linarith [tailScale_ge_variance ν])
  have hprod : 0 ≤ (N : ℝ)*(K : ℝ) := by positivity
  have hhiddenRate : Real.exp (-(N : ℝ)*(K : ℝ)/8) ≤
      Real.exp (-(N : ℝ)*(K : ℝ)/(8*(tailScale ν : ℝ))) := by
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div]
    apply neg_le_neg
    exact div_le_div_of_nonneg_left hprod (by norm_num) (by linarith)
  have hreadRate : Real.exp (-(N : ℝ)*(K : ℝ)/(8*subGaussianVariance ν)) ≤
      Real.exp (-(N : ℝ)*(K : ℝ)/(8*(tailScale ν : ℝ))) := by
    apply Real.exp_le_exp.mpr
    simp only [neg_mul,neg_div]
    apply neg_le_neg
    exact div_le_div_of_nonneg_left hprod (mul_pos (by norm_num) (subGaussianVariance_pos ν))
      (by linarith [tailScale_ge_variance ν])
  have hset : (goodWeights ν d N r K)ᶜ=
      {z | ¬GoodHidden ν d N r G (K : ℝ) z} ∪
      {z | (K : ℝ) < (N : ℝ)*(∑ i, weights z (.inr (.inr i))^2)} := by
    ext z
    simp only [goodWeights,Set.mem_compl_iff,Set.mem_setOf_eq,Set.mem_union,not_and_or,not_le]
    rfl
  apply (excluded_mass_le_bad_event ν (by omega) hN hK0 hNT).trans
  rw [hset]
  apply (measureReal_union_le _ _).trans
  have hh' := hh.trans (mul_le_mul_of_nonneg_left hhiddenRate (by positivity : (0 : ℝ) ≤ r+1))
  have hr' := hr.trans hreadRate
  nlinarith

end NeuralGeneralization.BatchTwoNonGaussian.NonGaussianMeanField
