import NeuralGeneralization.LocalizedBumpPairMean
import NeuralGeneralization.ElementaryTailGram

/-! # Actual IID-sample bounds for localized-bump interpolation

The sample includes collisions. A simple distance generating function gives
separation, and the actual Fourier pair mean controls cross energies.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
open CompressionSampling
variable {d n : ℕ}

def offDiagonalSum (F : ClippingCube d → ClippingCube d → ℝ)
    (s : Fin n → ClippingCube d) : ℝ := ∑ i, ∑ j ∈ Finset.univ.erase i, F (s i) (s j)

lemma offDiagonalSum_nonneg (F : ClippingCube d → ClippingCube d → ℝ)
    (hF : ∀ x y, 0 ≤ F x y) (s : Fin n → ClippingCube d) :
    0 ≤ offDiagonalSum F s := Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => hF _ _

lemma offDiagonalSum_integral_le (F : ClippingCube d → ClippingCube d → ℝ)
    (B : ℝ) (hB : 0 ≤ B) (hmean : uniformCubeMean (fun x => uniformCubeMean (F x)) ≤ B) :
    (∫ s : Fin n → ClippingCube d, offDiagonalSum F s ∂iidSamples (uniformCubeMeasure d) n) ≤
      (n:ℝ)^2*B := by
  classical
  unfold offDiagonalSum
  rw [integral_finsetSum _ (fun _ _ => Integrable.of_finite)]
  simp_rw [integral_finsetSum _ (fun _ _ => Integrable.of_finite)]
  calc
    _ ≤ ∑ i : Fin n, ∑ _j ∈ Finset.univ.erase i, B := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      rw [uniformCubeSample_pair_integral d n i j (Ne.symm (Finset.mem_erase.mp hj).1)]
      exact hmean
    _ ≤ ∑ _i : Fin n, ∑ _j : Fin n, B := by
      apply Finset.sum_le_sum
      intro i hi
      exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _) (fun j _ _ => hB)
    _ = _ := by simp; ring

/-- Markov's inequality for the exact IID cube law. -/
theorem offDiagonalSum_bad_probability (F : ClippingCube d → ClippingCube d → ℝ)
    (hF : ∀ x y, 0 ≤ F x y) (B : ℝ) (hB : 0 ≤ B)
    (hmean : uniformCubeMean (fun x => uniformCubeMean (F x)) ≤ B)
    (q : ℝ) (hq : 0 < q) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => q ≤ offDiagonalSum F s) ≤ (n:ℝ)^2*B/q := by
  have hM := mul_meas_ge_le_integral_of_nonneg
    (μ:=iidSamples (uniformCubeMeasure d) n) (f:=fun s => offDiagonalSum F s)
    (ae_of_all _ (offDiagonalSum_nonneg F hF)) Integrable.of_finite q
  have hh := hM.trans (offDiagonalSum_integral_le F B hB hmean)
  rw [uniformCubeSample_measure_eq_probability] at hh
  exact (le_div_iff₀ hq).mpr (by simpa only [mul_comm q] using hh)

/-- A single event controls the energy of every labeling of the sample. -/
theorem pairEnergy_bad_probability (w : Finset (Fin d) → ℝ)
    (hw : ∀ S, 0 ≤ w S) (v : ℝ) (hv0 : 0 ≤ v)
    (hv : ∀ S, coefficient d S.card^2/w S ≤ v) (q : ℝ) (hq : 0 < q) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n (fun s =>
      q ≤ ∑ i, ∑ j ∈ Finset.univ.erase i, |pairEnergy w (s i) (s j)|) ≤
      (n:ℝ)^2*Real.sqrt (v*diagonalEnergy w)/q :=
  offDiagonalSum_bad_probability (fun x y => |pairEnergy w x y|) (fun _ _ => abs_nonneg _)
    _ (Real.sqrt_nonneg _) (pairEnergy_abs_double_mean_le w hw v hv0 hv) q hq

lemma distance_probe_mean (x : ClippingCube d) :
    uniformCubeMean (fun y => (1/2:ℝ)^hammingDist y x) = (3/4:ℝ)^d := by
  have hh := raw_walsh (d:=d) (1/4:ℝ) x ∅
  simp only [Finset.card_empty, pow_zero, Nat.sub_zero, one_mul] at hh
  have he (y : ClippingCube d) : walshCharacter ∅ y=1 := by simp [walshCharacter]
  simp only [he, mul_one, walshCoefficients] at hh
  simp_rw [raw_eq_distance] at hh
  norm_num at hh
  exact hh

lemma separation_failure_subset (R : ℕ) :
    {s : Fin n → ClippingCube d | ¬ ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j)} ⊆
    {s | (1/2:ℝ)^(2*R) ≤ offDiagonalSum (fun x y => (1/2:ℝ)^hammingDist y x) s} := by
  classical
  intro s hs
  push Not at hs
  obtain ⟨i,j,hij,hnear⟩ := hs
  have hji : j ∈ (Finset.univ : Finset (Fin n)).erase i := by simp [Ne.symm hij]
  have hsingle := Finset.single_le_sum
    (fun j (_ : j ∈ (Finset.univ : Finset (Fin n)).erase i) =>
      pow_nonneg (by norm_num : (0:ℝ) ≤ 1/2) (hammingDist (s j) (s i))) hji
  have houter := Finset.single_le_sum
    (s:=(Finset.univ : Finset (Fin n)))
    (f:=fun i => ∑ j ∈ Finset.univ.erase i, (1/2:ℝ)^hammingDist (s j) (s i))
    (fun i _ => Finset.sum_nonneg fun j _ => by positivity) (Finset.mem_univ i)
  change (1/2:ℝ)^(2*R) ≤ offDiagonalSum _ s
  have hp := pow_le_pow_of_le_one (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (1/2:ℝ) ≤ 1)
    (show hammingDist (s j) (s i) ≤ 2*R by rw [hammingDist_comm]; omega)
  exact hp.trans (hsingle.trans houter)

/-- An elementary exponential separation bound using the exact Hamming
probability-generating function, valid for every dimension/sample size. -/
theorem separation_bad_probability (d n R : ℕ) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ¬ ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j)) ≤
      (n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R) := by
  have hm : uniformCubeMean (fun x : ClippingCube d => uniformCubeMean
      (fun y => (1/2:ℝ)^hammingDist y x)) ≤ (3/4:ℝ)^d := by
    simp_rw [distance_probe_mean]
    rw [uniformCubeMean_const]
  have hh := offDiagonalSum_bad_probability (n:=n)
    (fun x y : ClippingCube d => (1/2:ℝ)^hammingDist y x)
    (fun x y => by positivity) ((3/4:ℝ)^d) (by positivity) hm
    ((1/2:ℝ)^(2*R)) (by positivity)
  refine le_trans ?_ hh
  rw [← uniformCubeSample_measure_eq_probability, ← uniformCubeSample_measure_eq_probability]
  exact measureReal_mono (separation_failure_subset R)

end NeuralGeneralization.LocalizedCubeBump
