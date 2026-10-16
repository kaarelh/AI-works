import NeuralGeneralization.NetworkMomentUpdate
import NeuralGeneralization.NetworkLayerSplit

/-! Exact Gram identities and the initial-layer Gaussian covariance limit. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.NetworkGramBasics
open ConcreteModel TowerNetwork GaussianPairMoments GaussianTanhSaturation GaussianMomentLimits

@[fun_prop] theorem continuous_finalCovariance {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x y : Cube d) :
    Continuous (fun w : Weights d N r => finalCovariance φ w x y) := by
  apply Continuous.div_const
  exact continuous_finsetSum _ (fun i _ =>
    (continuous_finalHidden hφ x i).mul (continuous_finalHidden hφ y i))

theorem finalCovariance_appendLayer {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (a : Fin N × Fin N → ℝ) (x y : Cube d) :
    finalCovariance φ (appendLayer w (fun i j => a (i,j))) x y =
      LayerGramConcentration.empiricalGram N φ (fun i x => finalHidden φ w x i) a x y := by
  simp only [finalCovariance, finalHidden_appendLayer,
    LayerGramConcentration.empiricalGram, LayerGramConcentration.rowFeature]

theorem inputVector_square_sum {d : ℕ} (x : Cube d) :
    (∑ j, inputVector x j ^ 2) = (d : ℝ) + 1 := by
  rw [Fin.sum_univ_succ]
  have hsq (i : Fin d) : labelReal (x i) ^ 2 = 1 := by cases x i <;> norm_num
  simp [inputVector, hsq, add_comm]

theorem inputVector_pair_sum {d : ℕ} (x y : Cube d) :
    (∑ j, inputVector x j * inputVector y j) = ((d : ℝ) + 1) * biasedDot x y := by
  rw [Fin.sum_univ_succ]
  simp only [inputVector, Fin.cases_zero, Fin.cases_succ, one_mul]
  unfold biasedDot
  have hsign (b : Bool) : labelReal b = cubeCoordinateSign b := rfl
  simp only [hsign]
  field_simp

theorem arcsineCovariance_diag (d k : ℕ) (x : Cube d) :
    arcsineCovariance d k x x = 1 := by
  have hb : biasedDot x x = 1 := by
    have hs (i : Fin d) : cubeCoordinateSign (x i) * cubeCoordinateSign (x i) = 1 := by
      cases x i <;> norm_num [cubeCoordinateSign]
    simp [biasedDot, hs, add_comm, show (d + 1 : ℝ) ≠ 0 by positivity]
  unfold arcsineCovariance
  rw [hb]
  induction k with
  | zero => rfl
  | succ k ih => rw [iteratedArcsine, ih, arcsineLink_one]

/-- The initial layer's deterministic covariance converges to the actual
first arcsine kernel for every subcritical exponent. -/
theorem first_covariance_tendsto {d : ℕ} (hd : 0 < d) {γ : ℝ} (hγ : γ < 1)
    (x y : Cube d) :
    Tendsto (fun N : ℕ => LayerGramConcentration.covariance Real.tanh
      (fun j (x : Cube d) => inputVector x j)
      (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y) atTop
      (𝓝 (arcsineCovariance d 1 x y)) := by
  have hdp : (0 : ℝ) < d := by exact_mod_cast hd
  have hs : Tendsto (fun N : ℕ => Real.sqrt ((N : ℝ) ^ (1 - γ) / d)) atTop atTop := by
    apply Real.tendsto_sqrt_atTop.comp
    exact ((tendsto_rpow_atTop (by linarith : 0 < 1 - γ)).comp
      tendsto_natCast_atTop_atTop).atTop_div_const hdp
  have hlim := tendsto_tanhCovariance_of_gram (I := fun _ => Fin (d + 1))
    (c := fun _ => inputVector x) (d := fun _ => inputVector y)
    hs (show Tendsto (fun _ : ℕ => ∑ j, inputVector x j ^ 2) atTop
      (𝓝 ((d : ℝ) + 1)) by simpa only [inputVector_square_sum] using tendsto_const_nhds)
    (show Tendsto (fun _ : ℕ => ∑ j, inputVector y j ^ 2) atTop
      (𝓝 ((d : ℝ) + 1)) by simpa only [inputVector_square_sum] using tendsto_const_nhds)
    (show Tendsto (fun _ : ℕ => ∑ j, inputVector x j * inputVector y j) atTop
      (𝓝 (((d : ℝ) + 1) * biasedDot x y)) by
      simpa only [inputVector_pair_sum] using tendsto_const_nhds)
    (by positivity) (by positivity)
  have htarget : (2 / Real.pi) * Real.arcsin
      ((((d : ℝ) + 1) * biasedDot x y) / (Real.sqrt ((d : ℝ) + 1) *
        Real.sqrt ((d : ℝ) + 1))) = arcsineCovariance d 1 x y := by
    rw [← sq, Real.sq_sqrt (by positivity)]
    simp only [arcsineCovariance, iteratedArcsine, arcsineLink]
    congr 2
    field_simp
  rw [htarget] at hlim
  apply hlim.congr
  intro N
  have hv : 0 ≤ (N : ℝ) ^ (1 - γ) / d :=
    div_nonneg (Real.rpow_nonneg (Nat.cast_nonneg N) _) hdp.le
  rw [show LayerGramConcentration.covariance Real.tanh
      (fun j (x : Cube d) => inputVector x j)
      (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y =
      pairMoment Real.tanh (((N : ℝ) ^ (1 - γ) / d).toNNReal)
        (inputVector x) (inputVector y) by
    simp only [LayerGramConcentration.covariance, LayerGramConcentration.rowFeature,
      pairMoment, mul_comm]]
  rw [tanh_pairMoment_standardize, Real.toNNReal_of_nonneg hv]
  rfl

/-- The input matrix is an exact marginal of the original full parameter
prior, with no conditioning or limiting argument. -/
theorem measurePreserving_inputMatrix (d N r : ℕ) (γ : ℝ) :
    MeasurePreserving (fun w : Weights d N r => fun ij : Fin N × Fin (d + 1) => w (.inl ij))
      (powerPrior d N r γ)
      (Measure.pi fun _ : Fin N × Fin (d + 1) => gaussianReal 0
        (((N : ℝ) ^ (1 - γ) / d).toNNReal)) := by
  have h := measurePreserving_sumPiEquivProdPi
    (fun i : WeightIndex d N r => gaussianReal 0 (powerVariance d N r γ i).toNNReal)
  exact measurePreserving_fst.comp h

end NeuralGeneralization.NetworkGramBasics
