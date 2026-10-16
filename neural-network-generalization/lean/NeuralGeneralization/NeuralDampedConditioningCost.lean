import NeuralGeneralization.NeuralSharpLocalizedBumpEnergy
import NeuralGeneralization.ArcsineNoiseTail

/-! # Actual fixed-margin conditioning cost at every neural depth

The damped comparator pays a sharp d^beta energy, an explicit low-mode
correction, and the exact Gaussian determinant. Its sample exceptional set
is controlled under the actual IID uniform sampling law.
-/
noncomputable section
open MeasureTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel FieldPosteriorBridge GaussianFieldTilt CompressionSampling
variable {d n : ℕ}

def dampedEnergyBudget (d k r : ℕ) (tau : ℝ≥0) : ℝ :=
  sharpEnergyBudget d k+(lowModes d r).card*neuralCoordinateBudget d k/(tau:ℝ)

def dampedCostBudget (d k r n : ℕ) (tau : ℝ≥0) (a t q : ℝ) : ℝ :=
  Real.log 2+4*(a+t+1)^2*(1/(walshCoefficients (arcsineProfile d (k+1)) ∅*(tau:ℝ))+
    4*((n:ℝ)*dampedEnergyBudget d k r tau+q))-
      ((lowModes d r).card:ℝ)/2*Real.log (tau:ℝ)

lemma dampedEnergyBudget_pos (d k r : ℕ) (tau : ℝ≥0) : 0 < dampedEnergyBudget d k r tau := by
  have := sharpEnergyBudget_pos d k
  have := neuralCoordinateBudget_pos d k
  unfold dampedEnergyBudget
  positivity

lemma neural_damped_energy_le {d : ℕ} (hd : 101 ≤ d) (k r : ℕ) (tau : ℝ≥0)
    (htau : 0 < tau) :
    diagonalEnergy (fun S => walshCoefficients (arcsineProfile d (k+1)) S*(damping r tau S:ℝ)) ≤
      dampedEnergyBudget d k r tau := by
  exact (damping_diagonalEnergy_le _ (iterated_arcsine_coefficient_pos d k)
    r tau htau (neuralCoordinateBudget d k) (neural_coefficient_energy_max (by omega) k)).trans
    (add_le_add (sharp_diagonalEnergy_bound hd k) le_rfl)

lemma neural_damped_variance_le (d k r : ℕ) (tau : ℝ≥0) :
    (∑ S, walshCoefficients (arcsineProfile d (k+1)) S*(damping r tau S:ℝ)) ≤
      (tau:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r := by
  have hs : (∑ S, walshCoefficients (arcsineProfile d (k+1)) S)=1 := by
    have h := walshExpansion_coefficients (arcsineProfile d (k+1)) (fun _ => true)
    simpa [walshExpansion, walshCharacter, cubeCoordinateSign, arcsineProfile_one] using h
  exact damping_variance_le _ (fun S => (iterated_arcsine_coefficient_pos d k S).le) hs.le r tau

/-- On the two explicit sample events, the conditioning cost is bounded
with no abstract spectrum or comparator hypotheses. -/
theorem neural_damped_conditioning_cost {d : ℕ} (hd : 101 ≤ d)
    (k r R : ℕ) (hr : 0 < r) (hR : 0 < R) (tau : ℝ≥0) (htau : 0 < tau) (htau1 : tau ≤ 1)
    (a t q : ℝ) (ha : 0 ≤ a) (ht : 0 ≤ t)
    (hsize : 4*(Fintype.card (ClippingCube d):ℝ)*Real.exp
      (-t^2/(2*((tau:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r))) ≤ 1)
    (s : Fin n → ClippingCube d) (f : BooleanFunction d)
    (hsep : ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j))
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20)
    (hcross : offDiagonalSum (fun x y => |pairEnergy
      (fun S => walshCoefficients (arcsineProfile d (k+1)) S*(damping r tau S:ℝ)) x y|) s ≤ q) :
    Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
      (conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s)) ≤ dampedCostBudget d k r n tau a t q := by
  have ht0 : (0:ℝ) < tau := htau
  have htail : 0 ≤ walshSpectralTail (arcsineProfile d (k+1)) r :=
    Finset.sum_nonneg fun S hS => (iterated_arcsine_coefficient_pos d k S).le
  have hh := conditioning_cost_of_pair_bound _ (iterated_arcsine_coefficient_pos d k)
    (damping r tau) (damping_pos r tau htau) (damping_le_one r tau htau1)
    a t ((tau:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r)
    (dampedEnergyBudget d k r tau) q ha ht (by positivity)
    (neural_damped_variance_le d k r tau) hsize s f R hR hsep hsmall
    (neural_damped_energy_le hd k r tau htau) hcross
  simpa only [damping_empty r hr tau, damping_log_determinant r tau htau, dampedCostBudget] using hh

/-- Actual IID samples simultaneously admit the displayed conditioning-cost
bound for every Boolean target. -/
theorem neural_damped_conditioning_cost_probability {d : ℕ} (hd : 101 ≤ d)
    (k r n R : ℕ) (hr : 0 < r) (hR : 0 < R) (tau : ℝ≥0) (htau : 0 < tau) (htau1 : tau ≤ 1)
    (a t q : ℝ) (ha : 0 ≤ a) (ht : 0 ≤ t) (hq : 0 < q)
    (hsize : 4*(Fintype.card (ClippingCube d):ℝ)*Real.exp
      (-t^2/(2*((tau:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r))) ≤ 1)
    (hsmall : (n:ℝ)*(1/5:ℝ)^R < 1/20) :
    1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
      (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(tau:ℝ))*dampedEnergyBudget d k r tau)/q ≤
    sampleProbability (uniformLaw d) n (fun s => ∀ f : BooleanFunction d,
      Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
        (conditioningEvent (fun z : ClippingCube d → ℝ => z) a f s)) ≤ dampedCostBudget d k r n tau a t q) := by
  classical
  let w := fun S => walshCoefficients (arcsineProfile d (k+1)) S*(damping r tau S:ℝ)
  let μ := iidSamples (uniformCubeMeasure d) n
  let SepBad := {s : Fin n → ClippingCube d | ¬ ∀ i j, i ≠ j → 2*R ≤ hammingDist (s i) (s j)}
  let CrossBad := {s : Fin n → ClippingCube d | q ≤ offDiagonalSum (fun x y => |pairEnergy w x y|) s}
  have hw (S) : 0 < w S := mul_pos (iterated_arcsine_coefficient_pos d k S) (damping_pos r tau htau S)
  have hb0 : 0 ≤ neuralCoordinateBudget d k/(tau:ℝ) :=
    div_nonneg (neuralCoordinateBudget_pos d k).le tau.coe_nonneg
  have hs := separation_bad_probability d n R
  have hc := pairEnergy_bad_probability (n:=n) w (fun S => (hw S).le)
    (neuralCoordinateBudget d k/(tau:ℝ)) hb0
    (damping_coefficient_max_le _ (iterated_arcsine_coefficient_pos d k) r tau htau htau1
      (neuralCoordinateBudget d k) (neural_coefficient_energy_max (by omega) k)) q hq
  have he := neural_damped_energy_le hd k r tau htau
  have hp : (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(tau:ℝ))*diagonalEnergy w)/q ≤
      (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(tau:ℝ))*dampedEnergyBudget d k r tau)/q := by
    apply div_le_div_of_nonneg_right _ hq.le
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    apply Real.sqrt_le_sqrt
    exact mul_le_mul_of_nonneg_left he hb0
  have hc' := hc.trans hp
  rw [← uniformCubeSample_measure_eq_probability] at hs hc'
  change μ.real SepBad ≤ _ at hs
  change μ.real CrossBad ≤ _ at hc'
  have hbad := (measureReal_union_le (μ:=μ) SepBad CrossBad).trans (add_le_add hs hc')
  have hgood : 1-(n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*R)-
      (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(tau:ℝ))*dampedEnergyBudget d k r tau)/q ≤
      μ.real (SepBad ∪ CrossBad)ᶜ := by
    rw [probReal_compl_eq_one_sub (Set.toFinite _).measurableSet]
    linarith
  rw [← uniformCubeSample_measure_eq_probability]
  refine hgood.trans (measureReal_mono ?_)
  intro s hs
  have hs' : s ∉ SepBad ∧ s ∉ CrossBad := by simpa only [Set.mem_compl_iff, Set.mem_union, not_or] using hs
  exact fun f => neural_damped_conditioning_cost hd k r R hr hR tau htau htau1 a t q ha ht
    hsize s f (not_not.mp hs'.1) hsmall (lt_of_not_ge hs'.2).le

end NeuralGeneralization.LocalizedCubeBump
