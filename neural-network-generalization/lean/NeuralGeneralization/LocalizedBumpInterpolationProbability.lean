import NeuralGeneralization.LocalizedBumpSampling
import NeuralGeneralization.LocalizedBumpComparator

/-! # Quantitative high-probability global-margin interpolation

The constructed function interpolates every sample labeling simultaneously,
while retaining a strict margin at every input in the full cube.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel CompressionSampling
variable {d n : ℕ}

theorem exists_global_interpolant_of_good_sample
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A D q : ℝ) (hA : 0 < A) (hdiag : diagonalEnergy w ≤ D)
    (s : Fin n → ClippingCube d) (R : ℕ) (hR : 0 < R)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (hcross : offDiagonalSum (fun x y => |pairEnergy w x y|) s ≤ q)
    (f : BooleanFunction d) :
    ∃ P : ClippingCube d → ℝ, (∀ x, A < |P x|) ∧
      (∀ i, A < labelReal (f (s i))*P (s i)) ∧
      featureEnergy w (walshCoefficients P) ≤ 8*A^2*(1/w ∅+4*((n:ℝ)*D+q)) := by
  let T := Finset.univ.filter (fun j => f (s j)=false)
  refine ⟨comparator A s T, comparator_global_margin A hA s T R hsep hsmall, ?_, ?_⟩
  · exact comparator_training_margin A hA s (fun i => f (s i)) R hR hsep hsmall
  · have hh := comparator_energy_le w hw A s T
    have hc := centerSum_energy_le w (fun S => (hw S).le) s T
    have he : featureEnergy w (walshCoefficients (centerSum s T)) ≤ (n:ℝ)*D+q :=
      hc.trans (add_le_add (mul_le_mul_of_nonneg_left hdiag (by positivity)) hcross)
    have hm := mul_le_mul_of_nonneg_left he (show 0 ≤ 32*A^2 by positivity)
    nlinarith

/-- Actual IID samples admit the concrete low-energy global interpolant
for every labeling with this quantitative success probability. -/
theorem global_interpolant_probability
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (A D v q : ℝ) (hA : 0 < A) (hv : 0 ≤ v) (hq : 0 < q)
    (hdiag : diagonalEnergy w ≤ D)
    (hmax : ∀ S, coefficient d S.card^2/w S ≤ v)
    (R : ℕ) (hR : 0 < R) (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) :
    1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
        (n:ℝ)^2*Real.sqrt (v*diagonalEnergy w)/q ≤
      sampleProbability (uniformLaw d) n (fun s => ∀ f : BooleanFunction d,
        ∃ P : ClippingCube d → ℝ, (∀ x, A < |P x|) ∧
          (∀ i, A < labelReal (f (s i))*P (s i)) ∧
          featureEnergy w (walshCoefficients P) ≤ 8*A^2*(1/w ∅+4*((n:ℝ)*D+q))) := by
  classical
  let μ := iidSamples (uniformCubeMeasure d) n
  let SepBad := {s : Fin n → ClippingCube d | ¬ ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j)}
  let CrossBad := {s : Fin n → ClippingCube d | q ≤ offDiagonalSum (fun x y => |pairEnergy w x y|) s}
  have hs := separation_bad_probability d n R
  have hc := pairEnergy_bad_probability (n:=n) w (fun S => (hw S).le) v hv hmax q hq
  rw [← uniformCubeSample_measure_eq_probability] at hs hc
  change μ.real SepBad ≤ _ at hs
  change μ.real CrossBad ≤ _ at hc
  have hu := measureReal_union_le (μ:=μ) SepBad CrossBad
  have hbad := hu.trans (add_le_add hs hc)
  have hgood : 1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
      (n:ℝ)^2*Real.sqrt (v*diagonalEnergy w)/q ≤ μ.real (SepBad ∪ CrossBad)ᶜ := by
    rw [probReal_compl_eq_one_sub (Set.toFinite _).measurableSet]
    linarith
  rw [← uniformCubeSample_measure_eq_probability]
  refine hgood.trans (measureReal_mono ?_)
  intro s hs
  have hs' : s ∉ SepBad ∧ s ∉ CrossBad := by simpa only [Set.mem_compl_iff, Set.mem_union, not_or] using hs
  have hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j) := not_not.mp hs'.1
  have hcross : offDiagonalSum (fun x y => |pairEnergy w x y|) s ≤ q := (lt_of_not_ge hs'.2).le
  exact exists_global_interpolant_of_good_sample w hw A D q hA hdiag s R hR hsep hsmall hcross

end NeuralGeneralization.LocalizedCubeBump
