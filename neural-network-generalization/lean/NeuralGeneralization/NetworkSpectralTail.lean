import NeuralGeneralization.SpectralFunctionClass
import NeuralGeneralization.NetworkGaussianCylinder
import NeuralGeneralization.MatrixEntropyAsymptotics
import NeuralGeneralization.PowerPriorScaling
import Mathlib.Probability.Independence.Basic

/-!
# Actual network tails for spectral compression

Coordinate projections of the actual Gaussian network prior supply its first,
readout and internal matrix laws. A finite union then gives the aggregate mass
outside the compressed function class from a single-matrix tail estimate.
-/

noncomputable section
open scoped BigOperators NNReal
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization

/-- An injectively indexed subfamily of independent coordinates has its exact
product marginal law. -/
theorem productGaussian_map_subfamily {ι κ : Type*} [Fintype ι] [Fintype κ]
    (v : ι → ℝ≥0) (e : κ → ι) (he : Function.Injective e) :
    (Measure.pi fun i => gaussianReal 0 (v i)).map (fun x j => x (e j)) =
      Measure.pi (fun j => gaussianReal 0 (v (e j))) := by
  classical
  have hi : iIndepFun (fun i (x : ι → ℝ) => x i)
      (Measure.pi fun i => gaussianReal 0 (v i)) :=
    iIndepFun_pi (X := fun _ => id) (fun _ => aemeasurable_id)
  have hj := hi.precomp he
  have hh := hj.map_fun_eq_pi_map (fun j => (measurable_pi_apply (e j)).aemeasurable)
  simpa only [(measurePreserving_eval (fun i => gaussianReal 0 (v i)) _).map_eq] using hh

namespace ConcreteModel

/-- Exact equal-variance coordinates of every real power prior. -/
theorem map_powerPrior_whiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) (γ : ℝ) :
    (powerPrior d N r γ).map whiten =
      Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal) := by
  rw [powerPrior_eq_smallPrior hN γ,
    map_smallPrior_whiten hd hN (Real.sqrt_pos.mpr
      (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _)),
    Real.sq_sqrt (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _).le]

/-- The actual Gaussian law of any selected whitened coordinates. -/
theorem map_powerPrior_whiten_subfamily {d N r : ℕ} {κ : Type*} [Fintype κ]
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (e : κ → WeightIndex d N r)
    (he : Function.Injective e) :
    (powerPrior d N r γ).map (fun w j => whiten w (e j)) =
      Measure.pi (fun _ : κ => gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal) := by
  rw [show (fun (w : Weights d N r) j => whiten w (e j)) =
      (fun (x : Weights d N r) j => x (e j)) ∘ whiten from rfl,
    ← Measure.map_map (measurable_pi_lambda _ fun j => measurable_pi_apply (e j))
      (continuous_whiten d N r).measurable,
    map_powerPrior_whiten hd hN γ]
  exact productGaussian_map_subfamily _ e he

/-- The weighted first-layer energy is exactly the sum of its whitened squares. -/
theorem first_energy_eq_whitened {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w : Weights d N r) :
    (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2) =
      ∑ ij : Fin N × Fin (d+1), (whiten w (Sum.inl ij)) ^ 2 := by
  rw [Fintype.sum_prod_type, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  rw [whiten, div_pow, coordinateScale_sq hd hN]
  simp only [smallVariance, one_pow, mul_one]
  field_simp

/-- The weighted readout energy has the same exact square-sum form. -/
theorem readout_energy_eq_whitened {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w : Weights d N r) :
    (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2) =
      ∑ i : Fin N, (whiten w (Sum.inr (Sum.inr i))) ^ 2 := by
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [whiten, div_pow, coordinateScale_sq hd hN]
  simp [smallVariance, div_eq_mul_inv, mul_comm]

/-- Internal coordinates already have the common Gaussian scale. -/
@[simp] theorem whiten_internal {d N r : ℕ} (w : Weights d N r)
    (s : Fin r) (i j : Fin N) :
    whiten w (Sum.inr (Sum.inl (s,i,j))) = w (Sum.inr (Sum.inl (s,i,j))) := by
  simp [whiten, coordinateScale, smallVariance]

/-- A square-sum tail for any actual selected whitened coordinates. -/
theorem powerPrior_whiten_subfamily_tail {d N r : ℕ} {κ : Type*} [Fintype κ]
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (e : κ → WeightIndex d N r)
    (he : Function.Injective e) (b : ℝ)
    (hb : 8 * (Fintype.card κ : ℝ) * (N : ℝ) ^ (-γ) ≤ b) :
    (powerPrior d N r γ).real {w | b ≤ ∑ j, (whiten w (e j)) ^ 2} ≤
      Real.exp (-b / (4 * (N : ℝ) ^ (-γ))) := by
  let v : ℝ≥0 := ((N : ℝ) ^ (-γ)).toNNReal
  have hv : (v : ℝ) = (N : ℝ) ^ (-γ) :=
    Real.coe_toNNReal _ (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _).le
  have hmap := map_powerPrior_whiten_subfamily hd hN γ e he
  have hmeas : Measurable (fun w : Weights d N r => fun j => whiten w (e j)) :=
    measurable_pi_lambda _ fun j =>
      (measurable_pi_apply (e j)).comp (continuous_whiten d N r).measurable
  have hmeasure := Measure.le_map_apply (μ := powerPrior d N r γ) hmeas.aemeasurable
    {z : κ → ℝ | b ≤ ∑ j, z j ^ 2}
  rw [hmap] at hmeasure
  have hr := ENNReal.toReal_mono (measure_ne_top _ _) hmeasure
  exact hr.trans (by
    simpa only [hv, v, Measure.real] using gaussian_squaredNorm_upper_tail (ι := κ) v
      (by rw [hv]; exact Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _) b
      (by simpa only [hv] using hb))

/-- The first layer of the actual width-exponent prior has its expected
chi-square tail, including its bias coordinate. -/
theorem powerPrior_first_energy_tail {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (b : ℝ)
    (hb : 8 * ((N * (d+1) : ℕ) : ℝ) * (N : ℝ) ^ (-γ) ≤ b) :
    (powerPrior d N r γ).real
      {w | b ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2)} ≤
      Real.exp (-b / (4 * (N : ℝ) ^ (-γ))) := by
  have he := powerPrior_whiten_subfamily_tail hd hN (r := r) γ
    (Sum.inl : Fin N × Fin (d+1) → WeightIndex d N r) Sum.inl_injective b
    (by simpa using hb)
  simpa only [first_energy_eq_whitened hd hN] using he

/-- The readout of the actual width-exponent prior has the same rate. -/
theorem powerPrior_readout_energy_tail {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (b : ℝ)
    (hb : 8 * (N : ℝ) * (N : ℝ) ^ (-γ) ≤ b) :
    (powerPrior d N r γ).real
      {w | b ≤ (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)} ≤
      Real.exp (-b / (4 * (N : ℝ) ^ (-γ))) := by
  have he := powerPrior_whiten_subfamily_tail hd hN (r := r) γ
    (fun i : Fin N => Sum.inr (Sum.inr i))
    (Sum.inr_injective.comp Sum.inr_injective) b (by simpa using hb)
  simpa only [readout_energy_eq_whitened hd hN] using he

/-- The internal matrix has the exact independent common-variance law. -/
theorem map_powerPrior_internal {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (s : Fin r) :
    (powerPrior d N r γ).map
      (fun w (ij : Fin N × Fin N) => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) =
      Measure.pi (fun _ : Fin N × Fin N => gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal) := by
  have he : Function.Injective
      (fun ij : Fin N × Fin N => (Sum.inr (Sum.inl (s,ij.1,ij.2)) : WeightIndex d N r)) := by
    intro ij kl h
    simpa using h
  simpa only [whiten_internal] using map_powerPrior_whiten_subfamily hd hN γ _ he

/-- An actual single-matrix estimate transfers to every internal layer, even
when stated with an outer measure on a nonmeasurable approximation event. -/
theorem powerPrior_internal_approximation_tail {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (a K B : ℝ) (s : Fin r)
    (hmat : (Measure.pi fun _ : Fin N × Fin N =>
        gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal).real
        (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior d N r γ).real
      {w | (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) ∈
        matrixApproximationFailure N a K} ≤ B := by
  have hmeas : Measurable
      (fun (w : Weights d N r) (ij : Fin N × Fin N) => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) :=
    measurable_pi_lambda _ fun ij => measurable_pi_apply _
  have hmeasure := Measure.le_map_apply (μ := powerPrior d N r γ) hmeas.aemeasurable (matrixApproximationFailure N a K)
  rw [map_powerPrior_internal hd hN γ s] at hmeasure
  exact (ENNReal.toReal_mono (measure_ne_top _ _) hmeasure).trans hmat


/-- Failure of the actual network approximation is contained in the two
endpoint energy failures and the union of the internal matrix failures. -/
theorem badSpectralWeights_subset {d N r K : ℕ} (a : ℝ) :
    (goodSpectralWeightsAtRadius d N r K a)ᶜ ⊆
      {w | (K : ℝ) ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2)} ∪
      {w | (K : ℝ) ≤ (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)} ∪
      ⋃ s : Fin r, {w | (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) ∈
        matrixApproximationFailure N a K} := by
  classical
  intro w hbad
  by_cases hf : (K : ℝ) ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2)
  · exact Or.inl (Or.inl hf)
  by_cases hr : (K : ℝ) ≤ (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)
  · exact Or.inl (Or.inr hr)
  right
  by_contra hh
  have hm : ∀ s : Fin r, ∃ H : Fin N × Fin N → ℝ,
      LowRankGrid.squaredSum H ≤ (K : ℝ) ∧
      ‖matrixOperator (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) - matrixOperator H‖ ≤ a := by
    intro s
    by_contra hn
    exact hh (Set.mem_iUnion.mpr ⟨s,hn⟩)
  exact hbad ⟨(lt_of_not_ge hf).le,(lt_of_not_ge hr).le,hm⟩

/-- Quantitative network tail with one shared internal-matrix bound. All
endpoint tails here are proved for the actual product Gaussian prior. -/
theorem powerPrior_badSpectralWeights_tail {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ a B : ℝ)
    (hfirst : 8 * ((N * (d+1) : ℕ) : ℝ) * (N : ℝ) ^ (-γ) ≤ (K : ℝ))
    (hread : 8 * (N : ℝ) * (N : ℝ) ^ (-γ) ≤ (K : ℝ))
    (hmat : (Measure.pi fun _ : Fin N × Fin N =>
        gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal).real
        (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior d N r γ).real (goodSpectralWeightsAtRadius d N r K a)ᶜ ≤
      2 * Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) + (r : ℝ) * B := by
  classical
  let μ := powerPrior d N r γ
  let F : Set (Weights d N r) :=
    {w | (K : ℝ) ≤ (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i,j)) ^ 2)}
  let R : Set (Weights d N r) :=
    {w | (K : ℝ) ≤ (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)}
  let M (s : Fin r) : Set (Weights d N r) :=
    {w | (fun ij => w (Sum.inr (Sum.inl (s,ij.1,ij.2)))) ∈ matrixApproximationFailure N a K}
  have hF : μ.real F ≤ Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) :=
    powerPrior_first_energy_tail hd hN γ K hfirst
  have hR : μ.real R ≤ Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) :=
    powerPrior_readout_energy_tail hd hN γ K hread
  have hM : μ.real (⋃ s, M s) ≤ (r : ℝ) * B := by
    calc
      _ ≤ ∑ s, μ.real (M s) := measureReal_iUnion_fintype_le M
      _ ≤ ∑ _s : Fin r, B := Finset.sum_le_sum fun s _ =>
        powerPrior_internal_approximation_tail hd hN γ a K B s hmat
      _ = _ := by simp
  calc
    _ ≤ μ.real ((F ∪ R) ∪ ⋃ s, M s) :=
      measureReal_mono (badSpectralWeights_subset a) (measure_ne_top μ _)
    _ ≤ μ.real (F ∪ R) + μ.real (⋃ s, M s) := measureReal_union_le _ _
    _ ≤ μ.real F + μ.real R + μ.real (⋃ s, M s) :=
      add_le_add (measureReal_union_le F R) le_rfl
    _ ≤ _ := by linarith

/-- In `γ≥1`, an energy budget `K≥8(d+1)` controls both endpoint layers at
all widths. This leaves only the genuinely internal matrix estimate. -/
theorem powerPrior_badSpectralWeights_tail_of_gamma_ge_one {d N r K : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ a B : ℝ) (hγ : 1 ≤ γ)
    (hK : 8 * (d+1) ≤ K)
    (hmat : (Measure.pi fun _ : Fin N × Fin N =>
        gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal).real
        (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior d N r γ).real (goodSpectralWeightsAtRadius d N r K a)ᶜ ≤
      2 * Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) + (r : ℝ) * B := by
  have hscale : (N : ℝ) * (N : ℝ) ^ (-γ) ≤ 1 := by
    simpa only [powerStandardDeviation_sq hN] using
      width_mul_powerStandardDeviation_sq_le_one hN hγ
  have hKR : 8 * ((d : ℝ)+1) ≤ (K : ℝ) := by exact_mod_cast hK
  apply powerPrior_badSpectralWeights_tail hd hN γ a B _ _ hmat
  · push_cast
    have hh := mul_le_mul_of_nonneg_left hscale (by positivity : 0 ≤ 8 * ((d : ℝ)+1))
    nlinarith
  · have hh := mul_le_mul_of_nonneg_left hscale (by norm_num : (0 : ℝ) ≤ 8)
    have hd0 : (0 : ℝ) ≤ d := Nat.cast_nonneg d
    nlinarith

/-- Actual aggregate function-prior tail outside the finite compressed class. -/
theorem spectralFunctions_complement_mass_tail {d N r K : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 8 * (d+1) ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (γ a B : ℝ) (hγ : 1 ≤ γ) (ha : a ≤ spectralTruncationRadius r K)
    (hmat : (Measure.pi fun _ : Fin N × Fin N =>
        gaussianReal 0 ((N : ℝ) ^ (-γ)).toNNReal).real
        (matrixApproximationFailure N a K) ≤ B) :
    (∑ f ∈ Finset.univ \ spectralFunctions d r K φ,
      functionMass φ (1 / 2) (powerPrior d N r γ) f) ≤
      2 * Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) + (r : ℝ) * B := by
  exact (spectralFunctions_complement_mass_le_radius hd hN (by omega)
    φ hφ (powerPrior d N r γ) a ha).trans
    (powerPrior_badSpectralWeights_tail_of_gamma_ge_one (by omega) hN γ a B hγ hK hmat)


/-- The exact uniform large-width aggregate tail used in the above-mean-field
learning theorem. Its width threshold depends only on the fixed exponent. -/
theorem eventually_spectralFunctions_complement_mass_tail (γ : ℝ) (hγ : 1 < γ) :
    ∀ᶠ N : ℕ in Filter.atTop, ∀ d r K : ℕ,
      1 ≤ d → 8 * (d+1) ≤ K → (K : ℝ) ≤ (N : ℝ) ^ 2 →
      matrixTruncationScale N γ ≤ spectralTruncationRadius r K →
      ∀ φ : ℝ → ℝ, admissibleActivation φ →
      (∑ f ∈ Finset.univ \ spectralFunctions d r K φ,
        functionMass φ (1 / 2) (powerPrior d N r γ) f) ≤
        2 * ((r : ℝ)+1) * Real.exp (-(K : ℝ) * (N : ℝ) ^ γ / 64) := by
  filter_upwards [eventually_gaussian_matrix_approximation_tail γ hγ,
    Filter.eventually_ge_atTop 1] with N hmatrix hN d r K hd hK hKN ha φ hφ
  have hN0 : 0 < N := by omega
  have hKR : (1 : ℝ) ≤ K := by exact_mod_cast (show 1 ≤ K by omega)
  have ht := spectralFunctions_complement_mass_tail hd hN0 hK φ hφ γ
    (matrixTruncationScale N γ) (2 * Real.exp (-(K : ℝ) * (N : ℝ) ^ γ / 64))
    hγ.le ha (hmatrix K hKR hKN)
  have hconvert : -(K : ℝ) / (4 * (N : ℝ) ^ (-γ)) =
      -(K : ℝ) * (N : ℝ) ^ γ / 4 := by
    rw [Real.rpow_neg (Nat.cast_nonneg N)]
    field_simp
  have hexp : Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) ≤
      Real.exp (-(K : ℝ) * (N : ℝ) ^ γ / 64) := by
    rw [hconvert]
    apply Real.exp_le_exp.mpr
    have hpow := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN0) γ
    nlinarith
  calc
    _ ≤ 2 * Real.exp (-(K : ℝ) / (4 * (N : ℝ) ^ (-γ))) +
        (r : ℝ) * (2 * Real.exp (-(K : ℝ) * (N : ℝ) ^ γ / 64)) := ht
    _ ≤ _ := by linarith


end ConcreteModel
end NeuralGeneralization
