import NeuralGeneralization.BatchTwoActivationOneStep

/-! Jointly measurable exceptional events for the actual Gaussian layers,
their conditional-uniform probability bounds, and diagonal propagation. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields CompressionSampling
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

def residualBadRows (c : I → Fin n → ℝ) (N : ℕ) (M q : ℝ) : Set (Fin N → Fin n → ℝ) :=
  {x | 8*(N:ℝ)*(q+Real.log 3)≤∑j,‖gaussianResidualSource c M (x j)‖^2}

def activationLayerBad (c : I → Fin n → ℝ) (F : I×I → (I → ℝ) → ℝ)
    (N : ℕ) (M B G q : ℝ) : Set (Fin N → Fin n → ℝ) :=
  residualBadRows c N M q ∪ scaledBadRows c F N B G q

theorem residualBadRows_joint_measurable {M : ℝ} (hM : 0<M) (q : ℝ) :
    MeasurableSet {p : (I → Fin n → ℝ) × (Fin N → Fin n → ℝ) |
      p.2 ∈ residualBadRows p.1 N M q} := by
  change MeasurableSet {p : (I → Fin n → ℝ) × (Fin N → Fin n → ℝ) |
    8*(N:ℝ)*(q+Real.log 3)≤∑j,‖gaussianResidualSource p.1 M (p.2 j)‖^2}
  apply measurableSet_le measurable_const
  apply Finset.measurable_sum
  intro j hj
  exact ((gaussianResidualSource_norm_joint_measurable hM).comp
    (measurable_fst.prodMk ((measurable_pi_apply j).comp measurable_snd))).pow_const 2

theorem activationLayerBad_joint_measurable (F : I×I → (I → ℝ) → ℝ)
    (hF : ∀j,Continuous (F j)) {M B : ℝ} (hM : 0<M) (hB : 0<B)
    (hb : ∀j z,|F j z|≤B) (G q : ℝ) :
    MeasurableSet {p : (I → Fin n → ℝ) × (Fin N → Fin n → ℝ) |
      p.2 ∈ activationLayerBad p.1 F N M B G q} :=
  (residualBadRows_joint_measurable hM q).union
    (scaledBadRows_joint_open F hF hB hb G q).measurableSet

theorem activationLayerBad_tail (c : I → Fin n → ℝ) (F : I×I → (I → ℝ) → ℝ)
    (hF : ∀j,Measurable (F j)) {M B G q K : ℝ} (hM : 0<M) (hB : 0<B) (hG : 0<G)
    (hvar : ∀i,(∑j,(c i j)^2)≤M) (hb : ∀j z,|F j z|≤B)
    {s : ℕ} (hN : 0<N) (hs : 0<s) (hq : K≤q)
    (hwidth : (s:ℝ)*Real.log (2*(Fintype.card (I×I):ℝ)+1)-
      (N:ℝ)*(q-(G*B)^2/(2*(s:ℝ)))≤-(N:ℝ)*K) :
    (iidSamples (standardLaw (Fin n)) N).real (activationLayerBad c F N M B G q)≤
      2*Real.exp (-(N:ℝ)*K) := by
  have hr := gaussianResidualSource_empirical_tail N c hM hvar q
  have hd := scaledBadRows_tail c F hF (K := q) hB hG hb hN hs
  have hre : Real.exp (-(N:ℝ)*q)≤Real.exp (-(N:ℝ)*K) :=
    Real.exp_le_exp.mpr (by nlinarith [Nat.cast_nonneg N (α:=ℝ)])
  have hde := Real.exp_le_exp.mpr hwidth
  have hu := measureReal_union_le
    (μ:=iidSamples (standardLaw (Fin n)) N)
    (residualBadRows c N M q) (scaledBadRows c F N B G q)
  change (iidSamples (standardLaw (Fin n)) N).real (activationLayerBad c F N M B G q)≤
    (iidSamples (standardLaw (Fin n)) N).real (residualBadRows c N M q)+
      (iidSamples (standardLaw (Fin n)) N).real (scaledBadRows c F N B G q) at hu
  change (iidSamples (standardLaw (Fin n)) N).real (residualBadRows c N M q)≤
    Real.exp (-(N:ℝ)*q) at hr
  linarith

theorem gaussian_layer_diagonal (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    {φ : ℝ → ℝ} {ℓ M A : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) (hM : 0<M) (hvar : ∀i,(∑j,(c i j)^2)≤M) (hN : 0<N)
    (henergy : ∑j,‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A) (i : I) :
    (∑j,(φ (fieldLinear c (x j) i))^2)/(N:ℝ)≤
      2*ℓ^2*(gaussianBulkThreshold I M)^2+2*ℓ^2*M*A := by
  have he (j : Fin N) :
      |linearObservation c (WithLp.toLp 2 (x j)) i-
        linearObservation c (gaussianResidualSource c M (x j)) i|≤gaussianBulkThreshold I M := by
    rw [gaussianBulkSource_add_residual c M (x j) i,add_sub_cancel_right]
    exact gaussianBulkSource_bound c M (x j) i
  have hh := empirical_activation_diagonal (A:=A) hφ hℓ (Real.sqrt_nonneg _)
    (Real.sqrt_nonneg M)
    (fun j => linearObservation c (WithLp.toLp 2 (x j)) i)
    (fun j => linearObservation c (gaussianResidualSource c M (x j)) i)
    (fun j => ‖gaussianResidualSource c M (x j)‖) (fun j => norm_nonneg _) he
    (fun j => linearObservation_abs_le c hM.le hvar _ i) (by simpa using henergy)
  apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).2
  simpa only [Fintype.card_fin,Real.sq_sqrt hM.le,gaussianBulkThreshold,
    linearObservation,fieldLinear_apply,mul_comm] using hh

end NeuralGeneralization.BatchTwoActivation
