import NeuralGeneralization.RobustEntropySelectedCurrent
import NeuralGeneralization.RobustEntropySelectedBasis
import NeuralGeneralization.RobustGaussianGeometryActiveKernel

/-! # Width-correct active energy for the actual selected current block -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry RobustCompressionInduction ConcreteModel
variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [StandardBorelSpace A] [StandardBorelSpace Y] [Nonempty A] [Nonempty Y]
    {N M q : ℕ} [MeasurableSpace (Finset (Fin M))]
    [MeasurableSingletonClass (Finset (Fin M))]
    [MeasurableSpace (QueryMessage (Fin M) q)]
    [MeasurableSingletonClass (QueryMessage (Fin M) q)]
local notation "E" => EuclideanSpace ℝ (Fin N)
local notation "Rows" => Fin N → E

/-- The active energy costs q per row. Neither the source width nor the number
of possible input points replaces q in this estimate. -/
theorem actual_selected_active_energy
    (Q : Measure (A × (Rows × Y))) [IsProbabilityMeasure Q]
    (P : Measure Y) [IsProbabilityMeasure P]
    (b : A → Fin M → E) (hb : Measurable b)
    (J : A × Y → Finset (Fin M)) (hJ : Measurable J)
    {K t : ℝ} (hK : 0 ≤ K) (ht : 0 < t) (ht1 : t^2 ≤ 1)
    (hentropy : futureEntropy Q ((rowGaussian N N).prod P) ≤
      ENNReal.ofReal (2*N*K/t^2)) :
    (∫⁻ a, ∫⁻ H, ENNReal.ofReal (∑ i : Fin N, ‖H i‖^2)
      ∂activeHKernel (currentRowJoint Q).condKernel (selectedMessageBasis (q := q) b J)
        (measurable_selectedMessageBasis b hb J hJ) t a
      ∂(currentRowJoint Q).fst) ≤ ENNReal.ofReal (N*(8*K+2*q)) := by
  have hmean := (current_given_future_entropy_le Q (rowGaussian N N) P).trans hentropy
  have hbound := activeHKernel_energy_le (currentRowJoint Q).fst (by simp)
    (currentRowJoint Q).condKernel (selectedMessageBasis (q := q) b J)
    (measurable_selectedMessageBasis b hb J hJ) t
    (ENNReal.ofReal (2*N*K/t^2)) hmean
  apply hbound.trans
  rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ 4*t^2),
    ← ENNReal.ofReal_add (by positivity) (by positivity)]
  apply ENNReal.ofReal_le_ofReal
  have he : 4*t^2*(2*(N:ℝ)*K/t^2) = 8*N*K := by
    field_simp
    ring
  rw [he]
  have hh := mul_le_mul_of_nonneg_right ht1 (by positivity : 0 ≤ 2*(N:ℝ)*q)
  nlinarith

end NeuralGeneralization.RobustEntropy
