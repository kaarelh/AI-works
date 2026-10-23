import NeuralGeneralization.BatchTwoActivationMatrixFamily
import NeuralGeneralization.Network

/-!
# Width-independent normalization of the concrete Gaussian energy

A harmlessly looser normalization by `K`, rather than the geometric mean of
layer norms, suffices for a polynomial at every fixed depth. All bounds here
are derived from the original weighted squared norm.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

variable {d N r : ℕ}

def normalizedFirstRow (w : Weights d N r) (K : ℝ) (i : Fin N) :
    EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (fun j => w (Sum.inl (i,j))/(Real.sqrt N*K))

def normalizedInternalRow (w : Weights d N r) (K : ℝ) (s : Fin r) (i : Fin N) :
    EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun j => w (Sum.inr (Sum.inl (s,i,j)))/K)

def normalizedReadout (w : Weights d N r) (K : ℝ) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun j => Real.sqrt N*w (Sum.inr (Sum.inr j))/K)

theorem first_energy_le (w : Weights d N r) :
    (d:ℝ)/N*(∑ i, ∑ j, w (Sum.inl (i,j))^2) ≤ weightedSquaredNorm w := by
  have hi : 0 ≤ ∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2 := by positivity
  have ho : 0 ≤ (N:ℝ)*(∑ i, w (Sum.inr (Sum.inr i))^2) := by positivity
  unfold weightedSquaredNorm
  linarith

theorem internal_energy_le (w : Weights d N r) (s : Fin r) :
    (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2) ≤ weightedSquaredNorm w := by
  have hf : 0 ≤ (d:ℝ)/N*(∑ i, ∑ j, w (Sum.inl (i,j))^2) := by positivity
  have ho : 0 ≤ (N:ℝ)*(∑ i, w (Sum.inr (Sum.inr i))^2) := by positivity
  have hs := Finset.single_le_sum (fun t (_ : t ∈ Finset.univ) =>
    show 0 ≤ ∑ i, ∑ j, w (Sum.inr (Sum.inl (t,i,j)))^2 by positivity)
    (Finset.mem_univ s)
  unfold weightedSquaredNorm
  linarith

theorem readout_energy_le (w : Weights d N r) :
    (N:ℝ)*(∑ i, w (Sum.inr (Sum.inr i))^2) ≤ weightedSquaredNorm w := by
  have hf : 0 ≤ (d:ℝ)/N*(∑ i, ∑ j, w (Sum.inl (i,j))^2) := by positivity
  have hi : 0 ≤ ∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2 := by positivity
  unfold weightedSquaredNorm
  linarith

theorem normalizedFirstRow_frobenius (hd : 1 ≤ d) (hN : 0 < N)
    (w : Weights d N r) {K : ℝ} (hK : 1 ≤ K) (henergy : weightedSquaredNorm w ≤ K) :
    (∑ i, ‖normalizedFirstRow w K i‖^2) ≤ 1 := by
  have hNp : (0:ℝ)<N := by exact_mod_cast hN
  have hdp : (1:ℝ)≤d := by exact_mod_cast hd
  have hKp : 0<K := lt_of_lt_of_le zero_lt_one hK
  have he := (first_energy_le w).trans henergy
  have hs : 0 ≤ ∑ i, ∑ j, w (Sum.inl (i,j))^2 := by positivity
  have he' : (∑ i, ∑ j, w (Sum.inl (i,j))^2) ≤ (N:ℝ)*K := by
    have := (div_le_iff₀ hNp).mp (show
      (d:ℝ)*(∑ i, ∑ j, w (Sum.inl (i,j))^2)/(N:ℝ) ≤ K by
        simpa only [div_mul_eq_mul_div] using he)
    nlinarith
  have hnorm : (∑ i, ‖normalizedFirstRow w K i‖^2) =
      (∑ i, ∑ j, w (Sum.inl (i,j))^2)/((N:ℝ)*K^2) := by
    simp only [EuclideanSpace.real_norm_sq_eq, normalizedFirstRow,
      PiLp.toLp_apply, div_pow, mul_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
    simp only [← Finset.sum_div]
  rw [hnorm]
  apply (div_le_one (mul_pos hNp (sq_pos_of_pos hKp))).mpr
  calc
    _ ≤ (N:ℝ)*K := he'
    _ ≤ (N:ℝ)*K^2 := mul_le_mul_of_nonneg_left (by nlinarith) hNp.le

theorem normalizedInternalRow_frobenius (w : Weights d N r) {K : ℝ}
    (hK : 1 ≤ K) (henergy : weightedSquaredNorm w ≤ K) (s : Fin r) :
    (∑ i, ‖normalizedInternalRow w K s i‖^2) ≤ 1 := by
  have hKp : 0<K := lt_of_lt_of_le zero_lt_one hK
  have he := (internal_energy_le w s).trans henergy
  have hnorm : (∑ i, ‖normalizedInternalRow w K s i‖^2) =
      (∑ i, ∑ j, w (Sum.inr (Sum.inl (s,i,j)))^2)/K^2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, normalizedInternalRow,
      PiLp.toLp_apply, div_pow, ← Finset.sum_div]
  rw [hnorm]
  apply (div_le_one (sq_pos_of_pos hKp)).mpr
  nlinarith

theorem normalizedReadout_norm_le (w : Weights d N r) {K : ℝ}
    (hK : 1 ≤ K) (henergy : weightedSquaredNorm w ≤ K) :
    ‖normalizedReadout w K‖ ≤ 1 := by
  have hKp : 0<K := lt_of_lt_of_le zero_lt_one hK
  have he := (readout_energy_le w).trans henergy
  have hnorm : ‖normalizedReadout w K‖^2 =
      ((N:ℝ)*(∑ i, w (Sum.inr (Sum.inr i))^2))/K^2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, normalizedReadout,
      PiLp.toLp_apply, div_pow, mul_pow, Real.sq_sqrt (Nat.cast_nonneg N),
      ← Finset.sum_div, ← Finset.mul_sum]
  have hs : ‖normalizedReadout w K‖^2 ≤ 1 := by
    rw [hnorm]
    apply (div_le_one (sq_pos_of_pos hKp)).mpr
    nlinarith
  nlinarith [norm_nonneg (normalizedReadout w K)]

end NeuralGeneralization.BatchTwoActivation
