import NeuralGeneralization.OnlineLowerReluSupportWalsh
import NeuralGeneralization.OnlineLowerReluRailAtom
import NeuralGeneralization.OnlineLowerSamplingDistance
import NeuralGeneralization.OnlineLowerNetworkActivation

/-! # Exact norm saturation and Fourier support of balanced signed rays -/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry

theorem signed_balanced_support_coefficient {d : ℕ} (A : Finset (Fin d))
    (r : ℕ) (hcard : A.card = 2 * r + 2) (v : Fin d → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hv : ∀ i, |v i| = if i ∈ A then c else 0) :
    |walshCoefficients (fun x => max (cubeAffine 0 v x) 0) A| = c * evenReluKappa r := by
  classical
  let z : ClippingCube d := fun i => decide (0 ≤ v i)
  have hsign (i : Fin d) : v i = if i ∈ A then c * cubeCoordinateSign (z i) else 0 := by
    have h := hv i
    by_cases hi : i ∈ A
    · rw [if_pos hi] at h ⊢
      by_cases hs : 0 ≤ v i
      · rw [abs_of_nonneg hs] at h
        simp [z, cubeCoordinateSign, h, hc]
      · rw [abs_of_neg (lt_of_not_ge hs)] at h
        simp [z, cubeCoordinateSign, hs]
        linarith
    · rw [if_neg hi] at h ⊢
      exact abs_eq_zero.mp h
  have hscore (x : ClippingCube d) : cubeAffine 0 v x =
      c * ∑ i ∈ A, cubeCoordinateSign (cubeTranslation z x i) := by
    unfold cubeAffine
    rw [zero_add, Finset.mul_sum]
    simp_rw [hsign, ite_mul, zero_mul, Fintype.sum_ite_mem]
    apply Finset.sum_congr rfl
    intro i _
    rw [cubeCoordinateSign_translation]
    ring
  have hfun : (fun x => max (cubeAffine 0 v x) 0) =
      (fun x => c * atomOutput (fun t => max t 0) (supportIncoming A) (cubeTranslation z x)) := by
    funext x
    rw [hscore, supportIncoming_score]
    simpa only [mul_zero] using (mul_max_of_nonneg (∑ i ∈ A, cubeCoordinateSign (cubeTranslation z x i)) 0 hc).symm
  rw [hfun, coefficient_const_mul, walshCoefficients_translation, abs_mul,
    abs_of_nonneg hc, abs_mul]
  have hz : |walshCharacter A z| = 1 := by
    nlinarith [walshCharacter_sq A z, sq_abs (walshCharacter A z), abs_nonneg (walshCharacter A z)]
  rw [hz, one_mul, support_relu_walsh_abs A r hcard]

theorem signed_balanced_support_energy {d : ℕ} (A : Finset (Fin d))
    (v : Fin d → ℝ) (c : ℝ) (hv : ∀ i, |v i| = if i ∈ A then c else 0) :
    (∑ i, v i ^ 2) = (A.card : ℝ) * c ^ 2 := by
  have hsq (i : Fin d) : v i ^ 2 = if i ∈ A then c ^ 2 else 0 := by
    rw [← sq_abs, hv]
    split_ifs <;> simp
  simp only [hsq, Fintype.sum_ite_mem, Finset.sum_const, nsmul_eq_mul]

/-- A signed ray with one common magnitude on an even support exactly
saturates the inverse-parity-coefficient norm cost. -/
theorem signed_balanced_support_saturation {d : ℕ} (A : Finset (Fin d))
    (r : ℕ) (hcard : A.card = 2 * r + 2) (v : Fin d → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hv : ∀ i, |v i| = if i ∈ A then c else 0) :
    evenReluCost r * |walshCoefficients (fun x => max (cubeAffine 0 v x) 0) A| =
      Real.sqrt (∑ i, v i ^ 2) := by
  rw [signed_balanced_support_coefficient A r hcard v c hc hv,
    signed_balanced_support_energy A v c hv]
  have hsqrt : Real.sqrt ((A.card : ℝ) * c ^ 2) = Real.sqrt (A.card : ℝ) * c := by
    rw [Real.sqrt_mul (Nat.cast_nonneg _), Real.sqrt_sq_eq_abs, abs_of_nonneg hc]
  rw [hsqrt, hcard]
  unfold evenReluCost
  have hne := ne_of_gt (evenReluKappa_pos r)
  have hreal : ((2 * r + 2 : ℕ) : ℝ) = 2 * (r + 1 : ℝ) := by push_cast; ring
  rw [hreal]
  field_simp

/-- If all incoming coordinates outside `A` vanish, an affine neuron
cannot have a Fourier coefficient involving a coordinate outside `A`. -/
theorem affine_coefficient_zero_outside {d : ℕ} (A : Finset (Fin d))
    (v : Fin d → ℝ) (hv : ∀ i, i ∉ A → v i = 0)
    (bias : ℝ) (φ : ℝ → ℝ) (T : Finset (Fin d)) (hT : ¬ T ⊆ A) :
    walshCoefficients (fun x => φ (cubeAffine bias v x)) T = 0 := by
  classical
  obtain ⟨i,hiT,hiA⟩ := Finset.not_subset.mp hT
  have hinv (x : ClippingCube d) : cubeAffine bias v (cubeFlip i x) = cubeAffine bias v x := by
    unfold cubeAffine
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    by_cases hji : j = i
    · subst j
      simp [hv i hiA]
    · simp [cubeFlip, Function.update_of_ne hji]
  have hsum := (cubeFlip i).sum_comp
    (fun x => φ (cubeAffine bias v x) * walshCharacter T x)
  simp_rw [hinv, walshCharacter_flip, if_pos hiT, mul_neg, Finset.sum_neg_distrib] at hsum
  have hz : (∑ x : ClippingCube d, φ (cubeAffine bias v x) * walshCharacter T x) = 0 := by linarith
  simp only [walshCoefficients, uniformCubeMean, hz, zero_div]

/-- The teacher sampling witness has exactly the common-magnitude shape
required by the saturation theorem, in actual physical coordinates. -/
theorem signedBlockRay_physical_abs {p d : ℕ} {β : Fin p × Bool → Type*}
    [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]
    (e : ((j : Fin p × Bool) × β j) ≃ Fin d)
    (u : (j : Fin p × Bool) → β j → ℝ) (θ : Fin p → Bool) (c : ℝ) (hc : 0 ≤ c)
    (i : Fin d) :
    |blockWeights e (signedBlockRay u θ c) i| =
      if i ∈ blockSupport e (railBlockOrientation θ) then c else 0 := by
  obtain ⟨⟨j,a⟩,rfl⟩ := e.surjective i
  rw [blockWeights_apply, signedBlockRay_abs u θ c hc]
  simp [positiveBlockRay, blockSupport, railBlockOrientation]

theorem even_support_ray_saturation {d : ℕ} (A : Finset (Fin d))
    (htwo : 2 ≤ A.card) (heven : Even A.card) (v : Fin d → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (hv : ∀ i, |v i| = if i ∈ A then c else 0) :
    evenReluCost ((A.card - 2) / 2) *
      |walshCoefficients (fun x => max (cubeAffine 0 v x) 0) A| =
        Real.sqrt (∑ i, v i ^ 2) := by
  obtain ⟨n,hn⟩ := heven
  have hcard : A.card = 2 * ((A.card - 2) / 2) + 2 := by omega
  exact signed_balanced_support_saturation A _ hcard v c hc hv

theorem signedBlockRay_physical_saturation {p d : ℕ} {β : Fin p × Bool → Type*}
    [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]
    (e : ((j : Fin p × Bool) × β j) ≃ Fin d)
    (u : (j : Fin p × Bool) → β j → ℝ) (θ : Fin p → Bool) (c : ℝ) (hc : 0 ≤ c)
    (htwo : 2 ≤ (blockSupport e (railBlockOrientation θ)).card)
    (heven : Even (blockSupport e (railBlockOrientation θ)).card) :
    evenReluCost (((blockSupport e (railBlockOrientation θ)).card - 2) / 2) *
      |walshCoefficients
        (fun x => max (cubeAffine 0 (blockWeights e (signedBlockRay u θ c)) x) 0)
        (blockSupport e (railBlockOrientation θ))| =
      Real.sqrt (∑ i, blockWeights e (signedBlockRay u θ c) i ^ 2) :=
  even_support_ray_saturation _ htwo heven _ c hc (signedBlockRay_physical_abs e u θ c hc)

theorem signedBlockRay_physical_coefficient_zero {p d : ℕ} {β : Fin p × Bool → Type*}
    [∀ j, Fintype (β j)] [∀ j, Nonempty (β j)]
    (e : ((j : Fin p × Bool) × β j) ≃ Fin d)
    (u : (j : Fin p × Bool) → β j → ℝ) (θ : Fin p → Bool) (c : ℝ) (hc : 0 ≤ c)
    (bias : ℝ) (φ : ℝ → ℝ) (T : Finset (Fin d))
    (hT : ¬ T ⊆ blockSupport e (railBlockOrientation θ)) :
    walshCoefficients
      (fun x => φ (cubeAffine bias (blockWeights e (signedBlockRay u θ c)) x)) T = 0 := by
  apply affine_coefficient_zero_outside _ _ _ bias φ T hT
  intro i hi
  have h := signedBlockRay_physical_abs e u θ c hc i
  rw [if_neg hi] at h
  exact abs_eq_zero.mp h

end NeuralGeneralization.OnlineLowerRelu
