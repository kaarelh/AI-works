import NeuralGeneralization.BatchTwoNeuralConverseNoise
import NeuralGeneralization.CylinderGeometry

/-! Exact suffix-product finite-disturbance certificates. The products use
actual Euclidean operator norms, including every possible injection depth. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel BatchTwoNeuralConverse
variable {d N r : ℕ}

theorem transpose_action_bound (A : Fin N → Fin N → ℝ) {β : ℝ}
    (hA : matrixActionBound A β) (u : Fin N → ℝ) :
    (∑ j,(∑ i,u i*A i j)^2) ≤ β^2*(∑ i,u i^2) := by
  let b : Fin N → ℝ := fun j => ∑ i,u i*A i j
  let S : ℝ := ∑ j,b j^2
  have he : S = ∑ i,u i*(∑ j,A i j*b j) := by
    dsimp [S]
    simp only [pow_two]
    conv_lhs => arg 2; ext j; arg 1; unfold b
    simp_rw [Finset.sum_mul, Finset.mul_sum]
    rw [Finset.sum_comm]
    congr 1
    funext i
    apply Finset.sum_congr rfl
    intro j _
    ring
  have hc := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ u (fun i => ∑ j,A i j*b j)
  rw [← he] at hc
  have hp := mul_le_mul_of_nonneg_left (hA b) (show 0 ≤ ∑ i,u i^2 by positivity)
  have hS : 0 ≤ S := by dsimp [S]; positivity
  change S ≤ β^2*(∑ i,u i^2)
  change _ ≤ (∑ i,u i^2)*(β^2*S) at hp
  by_cases hz : S = 0
  · rw [hz]
    positivity
  · have hpos : 0 < S := lt_of_le_of_ne hS (Ne.symm hz)
    apply (mul_le_mul_iff_left₀ hpos).mp
    nlinarith only [hc.trans hp]

def internalNorm (w : Weights d N r) (s : Fin r) : ℝ :=
  ‖coordinateMatrixOperator (fun ij : Fin N × Fin N => w (.inr (.inl (s,ij.1,ij.2))))‖

def suffixProduct (β : Fin r → ℝ) (ss : List (Fin r)) : ℝ :=
  (ss.map β).prod

def suffixSquareSum (β : Fin r → ℝ) : ℝ :=
  ∑ j : Fin (r+1), (suffixProduct β ((List.finRange r).drop j.val))^2

theorem pathRow_spectral_bound (w : Weights d N r) (D : Slopes N r)
    (hD : D ∈ slopeCube N r) (β : Fin r → ℝ)
    (hW : ∀ s,matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) (β s))
    (ss : List (Fin r)) :
    (∑ i,(pathRow w D ss i)^2) ≤
      (suffixProduct β ss)^2*(∑ i,w (.inr (.inr i))^2) := by
  induction ss with
  | nil => simp [suffixProduct, pathRow]
  | cons s ss ih =>
    have hdiag : (∑ i,(pathRow w D ss i*D s i)^2) ≤ ∑ i,(pathRow w D ss i)^2 := by
      apply Finset.sum_le_sum
      intro i _
      have h0 : 0 ≤ D s i := hD.1 s i
      have h1 : D s i ≤ 1 := hD.2 s i
      have hs : (D s i)^2 ≤ 1 := by nlinarith
      simpa only [mul_pow, mul_one] using mul_le_mul_of_nonneg_left hs (sq_nonneg _)
    have ht := transpose_action_bound _ (hW s) (fun i => pathRow w D ss i*D s i)
    apply ht.trans
    have hh := mul_le_mul_of_nonneg_left (hdiag.trans ih) (sq_nonneg (β s))
    simpa [suffixProduct, mul_pow, mul_assoc] using hh

theorem gainSq_suffix_bound (w : Weights d N r) (β : Fin r → ℝ)
    (hW : ∀ s,matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) (β s)) :
    gainSq w ≤ readoutEnergy w*suffixSquareSum β := by
  unfold gainSq
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  have hh := Finset.sum_le_sum (s := Finset.univ) (fun (j : Fin (r+1)) _ =>
    pathRow_spectral_bound w D hD β hW ((List.finRange r).drop j.val))
  have hm := mul_le_mul_of_nonneg_left hh (Nat.cast_nonneg N : (0:ℝ) ≤ N)
  simpa [gainEnergy, readoutEnergy, suffixSquareSum, ← Finset.sum_mul,
    mul_comm, mul_left_comm, mul_assoc] using hm

theorem internalNorm_action (w : Weights d N r) (s : Fin r) :
    matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) (internalNorm w s) :=
  matrixActionBound_of_operatorNorm _ _ (norm_nonneg _) le_rfl

/-- The literal square of the paper's spectral finite-radius inequality. -/
theorem spectral_noise_sq (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      (1+readoutEnergy w*suffixSquareSum (internalNorm w))*noiseBudgetSq η := by
  exact (noisy_difference_sq_le hN w x η).trans
    (mul_le_mul_of_nonneg_right (by linarith [gainSq_suffix_bound w _ (internalNorm_action w)])
      (noiseBudgetSq_nonneg η))

/-- The exact sufficient ratio 1/256, at the actual calibrated radius. -/
theorem spectral_support (hN : 0 < N) (w : Weights d N r) {c : ℝ}
    (hcert : c^2*(1+readoutEnergy w*suffixSquareSum (internalNorm w)) /
      (1+((r:ℝ)+1)*readoutEnergy w) ≤ 1/256) :
    w ∈ robustEvent Real.tanh c := by
  intro x η hη
  have hden : 0 < 1+((r:ℝ)+1)*readoutEnergy w := by
    have hh := readoutEnergy_nonneg w
    positivity
  have hg : 0 ≤ 1+readoutEnergy w*suffixSquareSum (internalNorm w) := by
    have hh := readoutEnergy_nonneg w
    unfold suffixSquareSum
    positivity
  have he : (1+readoutEnergy w*suffixSquareSum (internalNorm w))*(robustRadius c w)^2 =
      c^2*(1+readoutEnergy w*suffixSquareSum (internalNorm w)) /
      (1+((r:ℝ)+1)*readoutEnergy w) := by
    rw [robustRadius, div_pow, Real.sq_sqrt hden.le]
    ring
  have hs := (spectral_noise_sq hN w x η).trans (mul_le_mul_of_nonneg_left hη hg)
  rw [he] at hs
  have hb : |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ (1:ℝ)/16 := by
    apply (sq_le_sq₀ (abs_nonneg _) (by norm_num)).mp
    rw [sq_abs]
    exact (hs.trans hcert).trans_eq (by norm_num)
  exact (RobustStatistics.clippedScore_lipschitz _ _).trans hb

theorem suffixSquareSum_le {β : Fin r → ℝ} {R : ℝ}
    (hp : ∀ j : Fin (r+1), |suffixProduct β ((List.finRange r).drop j.val)| ≤ R) :
    suffixSquareSum β ≤ ((r:ℝ)+1)*R^2 := by
  calc
    _ ≤ ∑ _j : Fin (r+1), R^2 := by
      apply Finset.sum_le_sum
      intro j _
      exact (sq_le_sq).mpr (by simpa only [abs_abs] using (hp j).trans (le_abs_self R))
    _ = _ := by simp

/-- Suffix products may compensate expansion by contraction; individual
internal matrices need not be contractive. -/
theorem bounded_suffix_support (hN : 0 < N) (w : Weights d N r) {c R : ℝ}
    (hc : 0 ≤ c) (hR : 1 ≤ R)
    (hp : ∀ j : Fin (r+1), |suffixProduct (internalNorm w) ((List.finRange r).drop j.val)| ≤ R)
    (hsmall : c*R ≤ 1/16) : w ∈ robustEvent Real.tanh c := by
  apply spectral_support hN w
  have hE := readoutEnergy_nonneg w
  have hs := mul_le_mul_of_nonneg_left (suffixSquareSum_le hp) hE
  have hden : 0 < 1+((r:ℝ)+1)*readoutEnergy w := by positivity
  apply (div_le_iff₀ hden).mpr
  have hcR : c^2*R^2 ≤ 1/256 := by
    have hh := (sq_le_sq₀ (mul_nonneg hc (by linarith : 0 ≤ R))
      (by norm_num : (0:ℝ) ≤ 1/16)).mpr hsmall
    nlinarith only [hh]
  have hR2 : 1 ≤ R^2 := by nlinarith
  have hh := mul_le_mul_of_nonneg_left hs (sq_nonneg c)
  have h0 := mul_le_mul_of_nonneg_left hR2 (sq_nonneg c)
  have h1 := mul_le_mul_of_nonneg_right hcR (show 0 ≤ ((r:ℝ)+1)*readoutEnergy w by positivity)
  nlinarith

/-- No constraint on the first layer or readout is needed. -/
theorem contractive_support (hN : 0 < N) (w : Weights d N r) {c : ℝ}
    (hc : 0 ≤ c) (hc1 : c ≤ 1/16) (hW : ∀ s,internalNorm w s ≤ 1) :
    w ∈ robustEvent Real.tanh c := by
  apply bounded_suffix_support hN w hc (R := 1) le_rfl _ (by simpa using hc1)
  intro j
  have hprod (ss : List (Fin r)) : 0 ≤ suffixProduct (internalNorm w) ss ∧
      suffixProduct (internalNorm w) ss ≤ 1 := by
    induction ss with
    | nil => norm_num [suffixProduct]
    | cons s ss ih =>
      have hn : 0 ≤ internalNorm w s := norm_nonneg _
      simpa only [suffixProduct, List.map_cons, List.prod_cons] using
        And.intro (mul_nonneg hn ih.1)
          ((mul_le_mul (hW s) ih.2 ih.1 (by norm_num : (0:ℝ) ≤ 1)).trans_eq (by ring))
  rw [abs_of_nonneg (hprod _).1]
  exact (hprod _).2

end NeuralGeneralization.RobustCertificates
