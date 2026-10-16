import NeuralGeneralization.LocalizedBumpEnergy
import NeuralGeneralization.FieldPosteriorBridge

/-! # Actual Gaussian conditioning cost from localized interpolation

The event is the paper's strict global margin together with training signs.
The comparator, its Fourier coefficients, its Gaussian feature energy, and
the translated Gaussian event are all connected explicitly.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel FieldPosteriorBridge GaussianFieldTilt
variable {d n : ℕ}

/-- Uniform perturbations of the explicit comparator preserve both the
global strict margin and the prescribed training signs. -/
theorem comparator_buffer (a t : ℝ) (ha : 0 ≤ a) (ht : 0 ≤ t)
    (s : Fin n → ClippingCube d) (f : BooleanFunction d) (R : ℕ) (hR : 0 < R)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (z : ClippingCube d → ℝ)
    (hz : ∀ x, |z x-comparator (a+t+1) s (Finset.univ.filter (fun j => f (s j)=false)) x| < t) :
    z ∈ conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s := by
  have hA : 0 < a+t+1 := by linarith
  let T := Finset.univ.filter (fun j => f (s j)=false)
  constructor
  · intro x
    have hg := comparator_global_margin (a+t+1) hA s T R hsep hsmall x
    have he := abs_sub_abs_le_abs_sub (comparator (a+t+1) s T x) (z x)
    rw [abs_sub_comm] at he
    have hh := hz x
    change |z x-comparator (a+t+1) s T x| < t at hh
    change a < |z x|
    linarith
  · intro i
    have hg := comparator_training_margin (a+t+1) hA s (fun j => f (s j)) R hR hsep hsmall i
    have he : |labelReal (f (s i))*z (s i)-labelReal (f (s i))*
        comparator (a+t+1) s T (s i)| < t := by
      rw [← mul_sub, abs_mul, abs_labelReal, one_mul]
      exact hz (s i)
    change 0 < labelReal (f (s i))*z (s i)
    have hh := (abs_lt.mp he).1
    change a+t+1 < labelReal (f (s i))*comparator (a+t+1) s T (s i) at hg
    linarith

/-- A fully quantitative finite conditioning-cost bound. The only kernel
inputs are explicitly stated spectral energy bounds on the actual bump
and its sampled off-diagonal pairs. -/
theorem conditioning_cost_of_pair_bound
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (v : Finset (Fin d) → ℝ≥0) (hv : ∀ S, 0 < v S) (hv1 : ∀ S, v S ≤ 1)
    (a t V D C : ℝ) (ha : 0 ≤ a) (ht : 0 ≤ t) (hV : 0 < V)
    (hvar : (∑ S, w S*(v S : ℝ)) ≤ V)
    (hsize : 4*(Fintype.card (ClippingCube d) : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (s : Fin n → ClippingCube d) (f : BooleanFunction d) (R : ℕ) (hR : 0 < R)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (hdiag : diagonalEnergy (fun S => w S*(v S : ℝ)) ≤ D)
    (hcross : (∑ i, ∑ j ∈ Finset.univ.erase i,
      |pairEnergy (fun S => w S*(v S : ℝ)) (s i) (s j)|) ≤ C) :
    Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real
      (conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s)) ≤
      Real.log 2+4*(a+t+1)^2*(1/(w ∅*(v ∅ : ℝ))+4*((n:ℝ)*D+C))-
        Real.log (∏ S, Real.sqrt (v S : ℝ)) := by
  let wt := fun S => w S*(v S : ℝ)
  have hwt (S : Finset (Fin d)) : 0 < wt S := mul_pos (hw S) (hv S)
  let T := Finset.univ.filter (fun j => f (s j)=false)
  have hcenter : featureEnergy wt (walshCoefficients (centerSum s T)) ≤ (n:ℝ)*D+C := by
    calc
      _ ≤ (n:ℝ)*diagonalEnergy wt + ∑ i, ∑ j ∈ Finset.univ.erase i,
          |pairEnergy wt (s i) (s j)| := centerSum_energy_le wt (fun S => (hwt S).le) s T
      _ ≤ _ := add_le_add (mul_le_mul_of_nonneg_left hdiag (by positivity)) hcross
  have henergy : featureEnergy wt (walshCoefficients (comparator (a+t+1) s T)) ≤
      8*(a+t+1)^2*(1/wt ∅+4*((n:ℝ)*D+C)) := by
    have hh := comparator_energy_le wt hwt (a+t+1) s T
    have hm := mul_le_mul_of_nonneg_left hcenter (show 0 ≤ 32*(a+t+1)^2 by positivity)
    nlinarith
  have hh := WalshGaussianEnergy.damped_walsh_comparator_cost w hw v hv hv1
    (comparator (a+t+1) s T) V t (8*(a+t+1)^2*(1/wt ∅+4*((n:ℝ)*D+C))) hV ht hvar hsize henergy
    (conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s)
    (measurableSet_conditioningEvent _ (fun x => measurable_pi_apply x) a f s)
    (comparator_buffer a t ha ht s f R hR hsep hsmall)
  convert! hh using 1
  dsimp [wt]
  ring

end NeuralGeneralization.LocalizedCubeBump
