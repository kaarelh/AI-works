import NeuralGeneralization.ModelFacts
import Mathlib.Tactic.FieldSimp

/-!
# Whitening the actual finite neural-network Gaussian

The diagonal change of variables here is independent of the small prior scale.
It maps an isotropic product Gaussian of variance `σ²` to `smallPrior`, and maps
Euclidean sum-of-squares energy exactly to the manuscript's weighted norm.
Thus an isotropic open-set Gaussian rate theorem applies to the actual network
margin event through the explicitly defined preimage below.
-/

noncomputable section

open scoped BigOperators
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.ConcreteModel

def coordinateScale (d N r : ℕ) (i : WeightIndex d N r) : ℝ :=
  Real.sqrt (smallVariance d N r 1 i)

def unwhiten {d N r : ℕ} (u : Weights d N r) : Weights d N r :=
  fun i => coordinateScale d N r i * u i

def whiten {d N r : ℕ} (w : Weights d N r) : Weights d N r :=
  fun i => w i / coordinateScale d N r i

theorem coordinateScale_pos {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (i : WeightIndex d N r) : 0 < coordinateScale d N r i :=
  Real.sqrt_pos.mpr (smallVariance_pos hd hN (by norm_num) i)

theorem whiten_unwhiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) : whiten (unwhiten u) = u := by
  funext i
  simp [whiten, unwhiten, (coordinateScale_pos hd hN i).ne']

theorem unwhiten_whiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (w : Weights d N r) : unwhiten (whiten w) = w := by
  funext i
  change coordinateScale d N r i * (w i / coordinateScale d N r i) = w i
  field_simp [(coordinateScale_pos hd hN i).ne']

theorem continuous_unwhiten (d N r : ℕ) :
    Continuous (unwhiten : Weights d N r → Weights d N r) :=
  continuous_pi (fun i => continuous_const.mul (continuous_apply i))

theorem continuous_whiten (d N r : ℕ) :
    Continuous (whiten : Weights d N r → Weights d N r) :=
  continuous_pi (fun i => (continuous_apply i).div_const _)

def unwhiteningHomeomorph {d N r : ℕ} (hd : 0 < d) (hN : 0 < N) :
    Weights d N r ≃ₜ Weights d N r where
  toFun := unwhiten
  invFun := whiten
  left_inv := whiten_unwhiten hd hN
  right_inv := unwhiten_whiten hd hN
  continuous_toFun := continuous_unwhiten d N r
  continuous_invFun := continuous_whiten d N r

theorem smallVariance_eq_base_mul (d N r : ℕ) (σ : ℝ) (i : WeightIndex d N r) :
    smallVariance d N r σ i = smallVariance d N r 1 i * σ ^ 2 := by
  rcases i with ij | (sij | j)
  · simp [smallVariance]
  · simp [smallVariance]
  · simp [smallVariance, div_eq_mul_inv, mul_comm]

theorem coordinateScale_sq {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (i : WeightIndex d N r) :
    coordinateScale d N r i ^ 2 = smallVariance d N r 1 i :=
  Real.sq_sqrt (smallVariance_pos hd hN (by norm_num) i).le

/-- Exact pushforward identity, with `σ²` as the isotropic variance. -/
theorem map_isotropic_eq_smallPrior {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) :
    (Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal)).map
        unwhiten = smallPrior d N r σ := by
  change (Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal)).map
    (fun u i => coordinateScale d N r i * u i) =
      Measure.pi (fun i => gaussianReal 0 (smallVariance d N r σ i).toNNReal)
  rw [Measure.pi_map_pi
    (f := fun (i : WeightIndex d N r) (x : ℝ) => coordinateScale d N r i * x)
    (fun i =>
    (measurable_const.mul measurable_id : Measurable
      (fun x : ℝ => coordinateScale d N r i * x)).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul, mul_zero]
  apply congrArg (gaussianReal 0)
  apply NNReal.eq
  simp only [NNReal.coe_mul, NNReal.coe_mk,
    Real.coe_toNNReal (σ ^ 2) (sq_nonneg σ),
    Real.coe_toNNReal (smallVariance d N r σ i) (smallVariance_pos hd hN hσ i).le]
  rw [coordinateScale_sq hd hN, smallVariance_eq_base_mul d N r σ i]

/-- Exact relation between the two prior parameterizations at a fixed width.
The scale depends on width, so this identity alone does not justify a
uniform-in-width interchange of limits. -/
theorem powerVariance_eq_smallVariance {d N r : ℕ} (hN : 0 < N) (γ : ℝ) :
    powerVariance d N r γ =
      smallVariance d N r (Real.sqrt ((N : ℝ) ^ (-γ))) := by
  have hNR : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  have hv : 0 ≤ (N : ℝ) ^ (-γ) := (Real.rpow_pos_of_pos hNR _).le
  have hf : (N : ℝ) ^ (1 - γ) = N * (N : ℝ) ^ (-γ) := by
    rw [sub_eq_add_neg, Real.rpow_add hNR, Real.rpow_one]
  have ho : (N : ℝ) ^ (-γ - 1) = (N : ℝ) ^ (-γ) / N := by
    rw [Real.rpow_sub hNR, Real.rpow_one]
  funext i
  rcases i with ij | (sij | j)
  · simp only [powerVariance, smallVariance, Real.sq_sqrt hv, hf]
    ring
  · simp only [powerVariance, smallVariance, Real.sq_sqrt hv]
  · simp only [powerVariance, smallVariance, Real.sq_sqrt hv, ho]

theorem powerPrior_eq_smallPrior {d N r : ℕ} (hN : 0 < N) (γ : ℝ) :
    powerPrior d N r γ = smallPrior d N r (Real.sqrt ((N : ℝ) ^ (-γ))) := by
  unfold powerPrior smallPrior
  rw [powerVariance_eq_smallVariance hN γ]

def coordinatePrecision (d N r : ℕ) : WeightIndex d N r → ℝ
  | Sum.inl _ => (d : ℝ) / N
  | Sum.inr (Sum.inl _) => 1
  | Sum.inr (Sum.inr _) => N

theorem weightedSquaredNorm_eq_coordinateSum {d N r : ℕ} (w : Weights d N r) :
    weightedSquaredNorm w = ∑ i, coordinatePrecision d N r i * w i ^ 2 := by
  simp [weightedSquaredNorm, coordinatePrecision, Fintype.sum_sum_type,
    Fintype.sum_prod_type, Finset.mul_sum, add_assoc]

theorem precision_mul_scale_sq {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (i : WeightIndex d N r) :
    coordinatePrecision d N r i * coordinateScale d N r i ^ 2 = 1 := by
  rw [coordinateScale_sq hd hN]
  have hdR : (d : ℝ) ≠ 0 := (Nat.cast_pos.mpr hd).ne'
  have hNR : (N : ℝ) ≠ 0 := (Nat.cast_pos.mpr hN).ne'
  rcases i with ij | (sij | j)
  · simp [coordinatePrecision, smallVariance]
    field_simp [hdR, hNR]
  · simp [coordinatePrecision, smallVariance]
  · simp [coordinatePrecision, smallVariance, hNR]

/-- The manuscript's weighted quadratic energy is exactly Euclidean after whitening. -/
theorem weightedSquaredNorm_unwhiten {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (u : Weights d N r) : weightedSquaredNorm (unwhiten u) = ∑ i, u i ^ 2 := by
  rw [weightedSquaredNorm_eq_coordinateSum]
  apply Finset.sum_congr rfl
  intro i _
  simp only [unwhiten, mul_pow]
  rw [← mul_assoc, precision_mul_scale_sq hd hN, one_mul]

def whitenedMarginEvent {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (f : BooleanFunction d) : Set (Weights d N r) :=
  unwhiten ⁻¹' marginEvent φ a f

theorem isOpen_whitenedMarginEvent {d N r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (a : ℝ) (f : BooleanFunction d) :
    IsOpen (whitenedMarginEvent (N := N) (r := r) φ a f) :=
  (isOpen_marginEvent hφ a f).preimage (continuous_unwhiten d N r)

theorem smallPrior_marginEvent_eq_isotropic {d N r : ℕ} (hd : 0 < d)
    (hN : 0 < N) {φ : ℝ → ℝ} (hφ : Continuous φ) (a : ℝ)
    (f : BooleanFunction d) {σ : ℝ} (hσ : 0 < σ) :
    smallPrior d N r σ (marginEvent φ a f) =
      (Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal))
        (whitenedMarginEvent φ a f) := by
  rw [← map_isotropic_eq_smallPrior hd hN hσ]
  exact Measure.map_apply (continuous_unwhiten d N r).measurable
    (isOpen_marginEvent hφ a f).measurableSet

theorem whitenedMarginEvent_nonempty {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (a : ℝ) (f : BooleanFunction d)
    (hf : (marginEvent (N := N) (r := r) φ a f).Nonempty) :
    (whitenedMarginEvent (N := N) (r := r) φ a f).Nonempty := by
  obtain ⟨w, hw⟩ := hf
  refine ⟨whiten w, ?_⟩
  change unwhiten (whiten w) ∈ marginEvent φ a f
  rwa [unwhiten_whiten hd hN]

theorem whitened_energy_image {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (a : ℝ) (f : BooleanFunction d) :
    (fun u : Weights d N r => ∑ i, u i ^ 2) '' whitenedMarginEvent φ a f =
      weightedSquaredNorm '' marginEvent (N := N) (r := r) φ a f := by
  ext q
  constructor
  · rintro ⟨u, hu, rfl⟩
    exact ⟨unwhiten u, hu, weightedSquaredNorm_unwhiten hd hN u⟩
  · rintro ⟨w, hw, rfl⟩
    refine ⟨whiten w, ?_, ?_⟩
    · change unwhiten (whiten w) ∈ marginEvent φ a f
      rwa [unwhiten_whiten hd hN]
    · change (∑ i, whiten w i ^ 2) = weightedSquaredNorm w
      rw [← weightedSquaredNorm_unwhiten hd hN, unwhiten_whiten hd hN]

theorem whitened_energy_infimum {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (a : ℝ) (f : BooleanFunction d) :
    sInf ((fun u : Weights d N r => ∑ i, u i ^ 2) '' whitenedMarginEvent φ a f) =
      sInf (weightedSquaredNorm '' marginEvent (N := N) (r := r) φ a f) :=
  congrArg sInf (whitened_energy_image hd hN φ a f)

end NeuralGeneralization.ConcreteModel
