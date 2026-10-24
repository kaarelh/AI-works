import NeuralGeneralization.BatchTwoImprovedGaussianT2Finite
import NeuralGeneralization.RobustPosteriorConditioning

/-!
# Dimension-free Gaussian moment comparison from proved transport

We use the actual measurable Gaussian coupling, rather than assume Gaussian
concentration. A zero set of positive mass controls a Lipschitz observable's
second moment. Conditioning on a tail event then yields concentration with
nonoptimized absolute constants.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoActivation
open BatchTwoImprovedGaussianTransport RobustPosterior

def standardGaussian (n : ℕ) : Measure (Fin n→ℝ) :=
  Measure.pi (fun _ => gaussianReal 0 1)

instance standardGaussian_probability (n : ℕ) : IsProbabilityMeasure (standardGaussian n) := by
  unfold standardGaussian
  infer_instance

def gaussianTransport (n : ℕ) (Q : Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] :
    Measure ((Fin n→ℝ)×(Fin n→ℝ)) :=
  finiteCouplingKernel (gaussianReal 0 1) n (Kernel.const Unit Q) ()

instance gaussianTransport_probability (n : ℕ) (Q : Measure (Fin n→ℝ))
    [IsProbabilityMeasure Q] : IsProbabilityMeasure (gaussianTransport n Q) := by
  unfold gaussianTransport
  infer_instance

theorem gaussianTransport_fst (n : ℕ) (Q : Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] :
    (gaussianTransport n Q).map Prod.fst=Q := by
  exact finiteCouplingKernel_fst (gaussianReal 0 1) n (Kernel.const Unit Q) ()

theorem gaussianTransport_snd (n : ℕ) (Q : Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] :
    (gaussianTransport n Q).map Prod.snd=standardGaussian n := by
  exact finiteCouplingKernel_snd (gaussianReal 0 1) n (Kernel.const Unit Q) ()

def euclideanSquaredDistance {n : ℕ} (x y : Fin n→ℝ) : ℝ :=
  ∑ i, (x i-y i)^2

theorem gaussianTransport_cost (n : ℕ) (Q : Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] :
    (∫⁻ p, ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) ∂gaussianTransport n Q)≤
      2*klDiv Q (standardGaussian n) := by
  have h := finiteCouplingKernel_squared_le n (Kernel.const Unit Q) ()
  simpa only [gaussianTransport, standardGaussian, euclideanSquaredDistance,
    ENNReal.ofReal_sum_of_nonneg (fun i _ => sq_nonneg _), scalarSquaredCost,
    Kernel.const_apply] using h

/-- Square-Lipschitz form is exactly unit Euclidean Lipschitz continuity,
written without changing the original product-coordinate measure space. -/
def SquareLipschitz {n : ℕ} (F : (Fin n→ℝ)→ℝ) : Prop :=
  ∀x y, (F x-F y)^2≤euclideanSquaredDistance x y

theorem gaussian_secondMoment_le_of_zeroSet {n : ℕ}
    (F : (Fin n→ℝ)→ℝ) (hF : Measurable F) (hLip : SquareLipschitz F)
    (A : Set (Fin n→ℝ)) (hA : MeasurableSet A) (hA0 : standardGaussian n A≠0)
    (hzero : ∀x∈A, F x=0) :
    (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂standardGaussian n)≤
      2*ENNReal.ofReal (-Real.log ((standardGaussian n).real A)) := by
  let Q := cond (standardGaussian n) A
  letI : IsProbabilityMeasure Q := cond_isProbabilityMeasure hA0
  let Γ := gaussianTransport n Q
  have hz : ∀ᵐ x∂Q, F x=0 := by
    filter_upwards [ae_cond_mem (μ := standardGaussian n) hA] with x hx
    exact hzero x hx
  have hz' : ∀ᵐ p∂Γ, F p.1=0 := by
    apply ae_of_ae_map (μ := Γ) (f := Prod.fst) (p := fun x => F x=0) measurable_fst.aemeasurable
    simpa only [Γ, gaussianTransport_fst] using hz
  have hm : Measurable (fun x => ENNReal.ofReal ((F x)^2)) := (hF.pow_const 2).ennreal_ofReal
  have hid : (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂standardGaussian n) =
      ∫⁻ p, ENNReal.ofReal ((F p.2)^2) ∂Γ := by
    rw [← gaussianTransport_snd n Q, lintegral_map hm measurable_snd]
  rw [hid]
  calc
    _ ≤ ∫⁻ p, ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) ∂Γ := by
      apply lintegral_mono_ae
      filter_upwards [hz'] with p hp
      apply ENNReal.ofReal_le_ofReal
      simpa only [hp, zero_sub, neg_sq] using hLip p.1 p.2
    _ ≤ 2*klDiv Q (standardGaussian n) := gaussianTransport_cost n Q
    _ = _ := by
      dsimp only [Q]
      rw [klDiv_cond_eq (standardGaussian n) A hA hA0]

/-- Transport compares second moments under every target law, including
conditional Gaussian laws. All integrals are nonnegative extended integrals;
no unproved integrability premise is needed. -/
theorem gaussian_secondMoment_transport {n : ℕ}
    (F : (Fin n→ℝ)→ℝ) (hF : Measurable F) (hLip : SquareLipschitz F)
    (Q : Measure (Fin n→ℝ)) [IsProbabilityMeasure Q] :
    (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂Q)≤
      2*(∫⁻ x, ENNReal.ofReal ((F x)^2) ∂standardGaussian n)+
        4*klDiv Q (standardGaussian n) := by
  let Γ := gaussianTransport n Q
  have hm : Measurable (fun x => ENNReal.ofReal ((F x)^2)) := (hF.pow_const 2).ennreal_ofReal
  have hcost : Measurable (fun p : (Fin n→ℝ)×(Fin n→ℝ) =>
      ENNReal.ofReal (euclideanSquaredDistance p.1 p.2)) := by
    unfold euclideanSquaredDistance
    fun_prop
  have hpoint (p : (Fin n→ℝ)×(Fin n→ℝ)) :
      ENNReal.ofReal ((F p.1)^2)≤2*ENNReal.ofReal ((F p.2)^2)+
        2*ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) := by
    have he : (F p.1)^2 ≤ 2*(F p.2)^2+2*euclideanSquaredDistance p.1 p.2 := by
      nlinarith [hLip p.1 p.2, sq_nonneg (F p.1-2*F p.2)]
    have hc : 0≤euclideanSquaredDistance p.1 p.2 := by unfold euclideanSquaredDistance; positivity
    simpa only [ENNReal.ofReal_add (by positivity : 0≤2*(F p.2)^2) (by positivity : 0≤2*euclideanSquaredDistance p.1 p.2),
      ENNReal.ofReal_mul (by norm_num : (0:ℝ)≤2), ENNReal.ofReal_ofNat] using
      ENNReal.ofReal_le_ofReal he
  have hid₁ : (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂Q) =
      ∫⁻ p, ENNReal.ofReal ((F p.1)^2) ∂Γ := by
    rw [← gaussianTransport_fst n Q, lintegral_map hm measurable_fst]
  have hid₂ : (∫⁻ x, ENNReal.ofReal ((F x)^2) ∂standardGaussian n) =
      ∫⁻ p, ENNReal.ofReal ((F p.2)^2) ∂Γ := by
    rw [← gaussianTransport_snd n Q, lintegral_map hm measurable_snd]
  rw [hid₁, hid₂]
  calc
    _ ≤ ∫⁻ p, (2*ENNReal.ofReal ((F p.2)^2)+
        2*ENNReal.ofReal (euclideanSquaredDistance p.1 p.2)) ∂Γ := lintegral_mono hpoint
    _ = 2*(∫⁻ p, ENNReal.ofReal ((F p.2)^2) ∂Γ)+
        2*(∫⁻ p, ENNReal.ofReal (euclideanSquaredDistance p.1 p.2) ∂Γ) := by
      rw [lintegral_add_left (by fun_prop),
        lintegral_const_mul (f := fun p : (Fin n→ℝ)×(Fin n→ℝ) => ENNReal.ofReal ((F p.2)^2)) 2 (by fun_prop),
        lintegral_const_mul _ hcost]
    _ ≤ 2*(∫⁻ p, ENNReal.ofReal ((F p.2)^2) ∂Γ)+
        2*(2*klDiv Q (standardGaussian n)) :=
      add_le_add le_rfl (mul_le_mul' le_rfl (gaussianTransport_cost n Q))
    _ = _ := by congr 1; ring

end NeuralGeneralization.BatchTwoActivation
