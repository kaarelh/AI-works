import NeuralGeneralization.NeuralSpectrumMonotone
import NeuralGeneralization.FunctionPrior
import NeuralGeneralization.IIDLaw
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.Probability.Distributions.Uniform
import Mathlib.Probability.ProbabilityMassFunction.Integrals
import Mathlib.Probability.Independence.Basic

/-!
# An elementary, quantitative sampled neural-tail Gram bound

The off-diagonal Frobenius norm and Markov's inequality give a bound at
`n² / choose(d,r)` scale. This is weaker than the random-principal-submatrix
bound needed at the paper's adaptive cutoff; it is not presented as a
replacement for that missing theorem.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators ENNReal NNReal
open MeasureTheory ProbabilityTheory
open CompressionSampling

/-- Literal independent uniform draws from the cube. -/
def uniformCubeMeasure (d : ℕ) : Measure (ClippingCube d) :=
  (PMF.uniformOfFintype (ClippingCube d)).toMeasure

instance uniformCubeMeasure_probability (d : ℕ) : IsProbabilityMeasure (uniformCubeMeasure d) := by
  unfold uniformCubeMeasure
  infer_instance

theorem uniformCubeMeasure_integral (d : ℕ) (f : ClippingCube d → ℝ) :
    (∫ x, f x ∂uniformCubeMeasure d) = uniformCubeMean f := by
  unfold uniformCubeMeasure uniformCubeMean
  rw [PMF.integral_eq_sum]
  simp only [PMF.uniformOfFintype_apply, ENNReal.toReal_inv,
    ENNReal.toReal_natCast, smul_eq_mul]
  rw [← Finset.mul_sum]
  ring

/-- The actual law of any two distinct coordinates of an IID cube sample. -/
theorem uniformCubeSample_pair_map (d n : ℕ) (i j : Fin n) (hij : i ≠ j) :
    (iidSamples (uniformCubeMeasure d) n).map (fun s => (s i, s j)) =
      (uniformCubeMeasure d).prod (uniformCubeMeasure d) := by
  have hindep : iIndepFun
      (fun i : Fin n => fun s : Fin n → ClippingCube d => s i)
      (iidSamples (uniformCubeMeasure d) n) :=
    iIndepFun_pi (fun _ => aemeasurable_id)
  have hmap := (hindep.indepFun hij).map_prod_eq_prod_map_map
    (measurable_pi_apply i).aemeasurable (measurable_pi_apply j).aemeasurable
  have hi : (iidSamples (uniformCubeMeasure d) n).map (fun s => s i) = uniformCubeMeasure d :=
    (measurePreserving_eval (fun _ : Fin n => uniformCubeMeasure d) i).map_eq
  have hj : (iidSamples (uniformCubeMeasure d) n).map (fun s => s j) = uniformCubeMeasure d :=
    (measurePreserving_eval (fun _ : Fin n => uniformCubeMeasure d) j).map_eq
  rwa [hi, hj] at hmap

theorem uniformCubeSample_pair_integral (d n : ℕ) (i j : Fin n) (hij : i ≠ j)
    (F : ClippingCube d → ClippingCube d → ℝ) :
    (∫ s, F (s i) (s j) ∂iidSamples (uniformCubeMeasure d) n) =
      uniformCubeMean (fun x => uniformCubeMean (F x)) := by
  have h := integral_map (μ := iidSamples (uniformCubeMeasure d) n)
    ((measurable_pi_apply i).prodMk (measurable_pi_apply j)).aemeasurable
    (measurable_of_finite (fun z : ClippingCube d × ClippingCube d => F z.1 z.2)).aestronglyMeasurable
  rw [uniformCubeSample_pair_map d n i j hij] at h
  rw [← h, integral_prod _ Integrable.of_finite]
  simp_rw [uniformCubeMeasure_integral]

/-- Delete the diagonal from a finite matrix. -/
def offDiagonal {ι : Type*} [DecidableEq ι] (A : ι → ι → ℝ) (i j : ι) : ℝ :=
  if i = j then 0 else A i j

/-- The squared Frobenius norm of the off-diagonal sampled matrix. -/
def offDiagonalSquare {ι : Type*} [Fintype ι] [DecidableEq ι] (A : ι → ι → ℝ) : ℝ :=
  ∑ i, ∑ j, offDiagonal A i j ^ 2

theorem offDiagonalSquare_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : ι → ι → ℝ) : 0 ≤ offDiagonalSquare A :=
  Finset.sum_nonneg (fun _ _ => Finset.sum_nonneg (fun _ _ => sq_nonneg _))

/-- A Frobenius bound controls every quadratic form. No matrix concentration
or operator-norm assertion is assumed. -/
theorem finiteQuadratic_square_le_frobenius {ι : Type*} [Fintype ι]
    (A : ι → ι → ℝ) (b : ι → ℝ) :
    finiteQuadratic A b ^ 2 ≤ (∑ i, ∑ j, A i j ^ 2) * (∑ i, b i ^ 2) ^ 2 := by
  classical
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun ij : ι × ι => A ij.1 ij.2) (fun ij : ι × ι => b ij.1 * b ij.2)
  have hquad : (∑ ij : ι × ι, A ij.1 ij.2 * (b ij.1 * b ij.2)) = finiteQuadratic A b := by
    rw [Fintype.sum_prod_type]
    unfold finiteQuadratic
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  have hright : (∑ ij : ι × ι, (b ij.1 * b ij.2) ^ 2) = (∑ i, b i ^ 2) ^ 2 := by
    rw [Fintype.sum_prod_type]
    simp_rw [mul_pow]
    rw [pow_two, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro i _
    rw [Finset.mul_sum]
  rw [hquad, hright, Fintype.sum_prod_type] at h
  exact h

theorem finiteQuadratic_offDiagonal_decomposition {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : ι → ι → ℝ) (τ : ℝ) (hdiag : ∀ i, A i i = τ) (b : ι → ℝ) :
    finiteQuadratic A b = τ * (∑ i, b i ^ 2) + finiteQuadratic (offDiagonal A) b := by
  classical
  have hentry (i j : ι) : b i * A i j * b j =
      (if i = j then τ * b i ^ 2 else 0) + b i * offDiagonal A i j * b j := by
    by_cases hij : i = j
    · subst j
      simp [offDiagonal, hdiag]
      ring
    · simp [hij, offDiagonal]
  unfold finiteQuadratic
  simp_rw [hentry, Finset.sum_add_distrib]
  simp [← Finset.mul_sum]

theorem finiteQuadratic_close_of_offDiagonalSquare {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : ι → ι → ℝ) (τ t : ℝ) (hdiag : ∀ i, A i i = τ) (ht : 0 ≤ t)
    (hsmall : offDiagonalSquare A ≤ t ^ 2) (b : ι → ℝ) :
    |finiteQuadratic A b - τ * (∑ i, b i ^ 2)| ≤ t * (∑ i, b i ^ 2) := by
  rw [finiteQuadratic_offDiagonal_decomposition A τ hdiag b, add_sub_cancel_left]
  have h := finiteQuadratic_square_le_frobenius (offDiagonal A) b
  have hbound := (mul_le_mul_of_nonneg_right hsmall (sq_nonneg (∑ i, b i ^ 2)))
  have hnonneg : 0 ≤ t * (∑ i, b i ^ 2) :=
    mul_nonneg ht (Finset.sum_nonneg (fun i _ => sq_nonneg _))
  have hfinal : finiteQuadratic (offDiagonal A) b ^ 2 ≤ (t * (∑ i, b i ^ 2)) ^ 2 := by
    calc
      _ ≤ offDiagonalSquare A * (∑ i, b i ^ 2) ^ 2 := h
      _ ≤ _ := by simpa only [mul_pow] using hbound
  exact (sq_le_sq₀ (abs_nonneg _) hnonneg).mp (by simpa only [sq_abs] using hfinal)

/-- The literal second moment of an IID neural-tail Gram entry. -/
theorem arcsineTailGram_entry_integral (d k r n : ℕ) (i j : Fin n) (hij : i ≠ j) :
    (∫ s, arcsineTailCovariance d k r (s i) (s j) ^ 2
      ∂iidSamples (uniformCubeMeasure d) n) =
      ∑ S ∈ (Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card)),
        walshCoefficients (arcsineProfile d k) S ^ 2 := by
  rw [uniformCubeSample_pair_integral d n i j hij (fun x y => arcsineTailCovariance d k r x y ^ 2)]
  simp_rw [arcsineTailCovariance_square_row]
  simp [uniformCubeMean]

/-- An unconditional Frobenius second-moment bound for the actual sampled
neural tail covariance. The sample is IID and collisions are included. -/
theorem arcsineTailGram_offDiagonal_integral (d k r n : ℕ) :
    (d.choose r : ℝ) *
        (∫ s, offDiagonalSquare (fun i j : Fin n => arcsineTailCovariance d k r (s i) (s j))
          ∂iidSamples (uniformCubeMeasure d) n) ≤
      (n : ℝ) ^ 2 * walshSpectralTail (arcsineProfile d k) r ^ 2 := by
  classical
  have hterm (i j : Fin n) : (d.choose r : ℝ) *
      (∫ s, offDiagonal (fun i j : Fin n => arcsineTailCovariance d k r (s i) (s j)) i j ^ 2
        ∂iidSamples (uniformCubeMeasure d) n) ≤
      walshSpectralTail (arcsineProfile d k) r ^ 2 := by
    by_cases hij : i = j
    · simp [offDiagonal, hij, sq_nonneg]
    · simp only [offDiagonal, if_neg hij]
      rw [arcsineTailGram_entry_integral d k r n i j hij]
      exact arcsineProfile_tail_second_moment k r
  unfold offDiagonalSquare
  rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  simp_rw [integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  rw [Finset.mul_sum]
  simp_rw [Finset.mul_sum]
  calc
    _ ≤ ∑ i : Fin n, ∑ j : Fin n, walshSpectralTail (arcsineProfile d k) r ^ 2 :=
      Finset.sum_le_sum (fun i _ => Finset.sum_le_sum (fun j _ => hterm i j))
    _ = _ := by simp; ring


/-- The measure used above is exactly the product probability appearing in
our main theorem, rather than a separate model of sampling. -/
theorem uniformCubeSample_measure_eq_probability (d n : ℕ)
    (E : (Fin n → ClippingCube d) → Prop) :
    (iidSamples (uniformCubeMeasure d) n).real {s | E s} =
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n E := by
  classical
  let μ := iidSamples (uniformCubeMeasure d) n
  have hsingle (s : Fin n → ClippingCube d) :
      μ.real {s} = ∏ _i : Fin n, (Fintype.card (ClippingCube d) : ℝ)⁻¹ := by
    change ((Measure.pi (fun _ : Fin n => uniformCubeMeasure d)) {s}).toReal = _
    rw [Measure.pi_singleton, ENNReal.toReal_prod]
    apply Finset.prod_congr rfl
    intro i _
    unfold uniformCubeMeasure
    rw [PMF.toMeasure_apply_singleton _ _ (measurableSet_singleton _)]
    simp [PMF.uniformOfFintype_apply]
  let F : Finset (Fin n → ClippingCube d) := Finset.univ.filter E
  have hF : (F : Set (Fin n → ClippingCube d)) = {s | E s} := by ext s; simp [F]
  change μ.real {s | E s} = _
  rw [← hF, ← sum_measureReal_singleton]
  simp_rw [hsingle]
  rw [Finset.sum_filter]
  rfl

/-- The positive neural tail trace, whenever the tail contains a Fourier
level. -/
theorem arcsineSpectralTail_pos (d k r : ℕ) (hr : r ≤ d) :
    0 < walshSpectralTail (arcsineProfile d (k + 1)) r := by
  classical
  have hmem : (Finset.univ : Finset (Fin d)) ∈
      Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card) := by simp [hr]
  have hle := Finset.single_le_sum
    (s := Finset.univ.filter (fun S : Finset (Fin d) => r ≤ S.card))
    (f := fun S => walshCoefficients (arcsineProfile d (k + 1)) S)
    (fun S _ => (iterated_arcsine_coefficient_pos d k S).le) hmem
  exact (iterated_arcsine_coefficient_pos d k Finset.univ).trans_le hle

/-- A genuine probability bound for the off-diagonal Frobenius event.
The loss is `n² / choose(d,r)`, which is explicit and must not be confused
with the sharper Gram estimate used in the main paper. -/
theorem arcsineTailGram_frobenius_bad_probability (d k r n : ℕ) (hr : r ≤ d)
    (ε : ℝ) (hε : 0 < ε) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s =>
      (ε * walshSpectralTail (arcsineProfile d (k + 1)) r) ^ 2 ≤
        offDiagonalSquare (fun i j : Fin n => arcsineTailCovariance d (k + 1) r (s i) (s j))) ≤
      (n : ℝ) ^ 2 / (ε ^ 2 * d.choose r) := by
  classical
  let τ := walshSpectralTail (arcsineProfile d (k + 1)) r
  let F := fun s : Fin n → ClippingCube d =>
    offDiagonalSquare (fun i j : Fin n => arcsineTailCovariance d (k + 1) r (s i) (s j))
  have hτ : 0 < τ := arcsineSpectralTail_pos d k r hr
  have hc : (0 : ℝ) < d.choose r := Nat.cast_pos.mpr (Nat.choose_pos hr)
  have hM := mul_meas_ge_le_integral_of_nonneg
    (μ := iidSamples (uniformCubeMeasure d) n) (f := F)
    (ae_of_all _ (fun s => offDiagonalSquare_nonneg _)) Integrable.of_finite ((ε * τ) ^ 2)
  have hscale := mul_le_mul_of_nonneg_left hM hc.le
  have hexpect := arcsineTailGram_offDiagonal_integral d (k + 1) r n
  have hbound := hscale.trans hexpect
  rw [uniformCubeSample_measure_eq_probability] at hbound
  apply (le_div_iff₀ (mul_pos (sq_pos_of_pos hε) hc)).mpr
  apply (mul_le_mul_iff_right₀ (sq_pos_of_pos hτ)).mp
  dsimp [τ, F] at hbound ⊢
  nlinarith only [hbound]

/-- With the stated probability, every sampled quadratic form is within
relative error `ε` of its diagonal trace. This is an actual finite neural
kernel statement, valid for IID samples with replacement and all `n`. -/
theorem arcsineTailGram_quadratic_probability (d k r n : ℕ) (hr : r ≤ d)
    (ε : ℝ) (hε : 0 < ε) :
    1 - (n : ℝ) ^ 2 / (ε ^ 2 * d.choose r) ≤
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s =>
        ∀ b : Fin n → ℝ,
          |finiteQuadratic (fun i j => arcsineTailCovariance d (k + 1) r (s i) (s j)) b -
            walshSpectralTail (arcsineProfile d (k + 1)) r * (∑ i, b i ^ 2)| ≤
              ε * walshSpectralTail (arcsineProfile d (k + 1)) r * (∑ i, b i ^ 2)) := by
  classical
  let τ := walshSpectralTail (arcsineProfile d (k + 1)) r
  let B := fun s : Fin n → ClippingCube d => (ε * τ) ^ 2 ≤
    offDiagonalSquare (fun i j : Fin n => arcsineTailCovariance d (k + 1) r (s i) (s j))
  have hbad := arcsineTailGram_frobenius_bad_probability d k r n hr ε hε
  have htotal : ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n B +
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s => ¬B s) = 1 := by
    rw [← uniformCubeSample_measure_eq_probability, ← uniformCubeSample_measure_eq_probability]
    have he : {s : Fin n → ClippingCube d | ¬ B s} = {s | B s}ᶜ := rfl
    rw [he, measureReal_add_measureReal_compl (Set.toFinite _).measurableSet]
    simp
  have hgood : 1 - (n : ℝ) ^ 2 / (ε ^ 2 * d.choose r) ≤
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s => ¬B s) := by
    change ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n B ≤ _ at hbad
    linarith
  apply hgood.trans
  unfold ConcreteModel.sampleProbability
  apply Finset.sum_le_sum
  intro s _
  by_cases hs : ¬B s
  · have hquad : ∀ b : Fin n → ℝ,
        |finiteQuadratic (fun i j => arcsineTailCovariance d (k + 1) r (s i) (s j)) b -
          τ * (∑ i, b i ^ 2)| ≤ ε * τ * (∑ i, b i ^ 2) := by
      intro b
      apply finiteQuadratic_close_of_offDiagonalSquare _ τ (ε * τ)
      · intro i; exact arcsineTailCovariance_diagonal (k + 1) r (s i)
      · exact (mul_pos hε (arcsineSpectralTail_pos d k r hr)).le
      · exact (lt_of_not_ge hs).le
    simp only [if_pos hs]
    split_ifs with hq
    · exact le_refl _
    · exact False.elim (hq hquad)
  · simp only [if_neg hs]
    split_ifs
    · exact Finset.prod_nonneg (fun i _ => (ConcreteModel.uniformLaw d).nonneg (s i))
    · exact le_refl _

end NeuralGeneralization
