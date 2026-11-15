import NeuralGeneralization.OnlineLowerTanhResidualGaussianJet

/-! # Differentiating the full Gaussian-times-periodic leading expression -/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

def residualEnvelopeRemainder (j:ℕ) (lo hi s:ℝ) : ℝ :=
  ∑ i ∈ Finset.range j, (j.choose (i+1):ℝ)*|s|^(i+1)*
    residualGaussianDerivativeBound (i+1)*
      (∑' l:ℕ,momentMajorant (j-(i+1)) lo hi l)

lemma residualEnvelopeRemainder_tendsto (j:ℕ) (lo hi:ℝ) :
    Tendsto (residualEnvelopeRemainder j lo hi) (𝓝 0) (𝓝 0) := by
  unfold residualEnvelopeRemainder
  have ht : ∀i∈Finset.range j,
      Tendsto (fun s:ℝ=>(j.choose (i+1):ℝ)*|s|^(i+1)*
        residualGaussianDerivativeBound (i+1)*(∑' l:ℕ,momentMajorant (j-(i+1)) lo hi l))
        (𝓝 0) (𝓝 0) := by
    intro i hmem
    have h:=((((continuous_abs.tendsto 0).pow (i+1)).const_mul (j.choose (i+1):ℝ)).mul_const
      (residualGaussianDerivativeBound (i+1))).mul_const
        (∑' l:ℕ,momentMajorant (j-(i+1)) lo hi l)
    simpa only [abs_zero,zero_pow (by omega : i+1≠0),mul_zero,zero_mul] using h
  simpa only [Finset.sum_const_zero] using tendsto_finset_sum (Finset.range j) ht

/-- All terms in Leibniz's rule in which a derivative lands on the slow
Gaussian factor vanish uniformly as its frequency scale tends to zero. -/
lemma residual_gaussian_product_derivative_error (j:ℕ) {a E lo hi:ℝ}
    (hlo:0<lo) (ha:lo≤a) (hah:a≤hi) (hE:0≤E) (s b₀ b:ℝ) :
    |iteratedDeriv j (fun x=>residualUnitGaussian (s*x)*smoothedResponse a E (x+b₀)) b-
      residualUnitGaussian (s*b)*iteratedDeriv j (smoothedResponse a E) (b+b₀)| ≤
        residualEnvelopeRemainder j lo hi s := by
  have ha0:=hlo.trans_le ha
  have hg:ContDiff ℝ j (fun x=>residualUnitGaussian (s*x)) := by
    unfold residualUnitGaussian; fun_prop
  have hf:ContDiff ℝ j (fun x=>smoothedResponse a E (x+b₀)) :=
    (contDiff_smoothedResponse ha0 hE j).comp (by fun_prop)
  rw [iteratedDeriv_fun_mul hg.contDiffAt hf.contDiffAt]
  simp_rw [iteratedDeriv_comp_add_const]
  rw [Finset.sum_range_succ']
  simp only [Nat.choose_zero_right,Nat.cast_one,one_mul,iteratedDeriv_zero,Nat.sub_zero]
  rw [add_sub_cancel_right]
  unfold residualEnvelopeRemainder
  apply (Finset.abs_sum_le_sum_abs _ _).trans
  apply Finset.sum_le_sum
  intro i hmem
  rw [abs_mul,abs_mul,abs_of_nonneg (Nat.cast_nonneg _)]
  have h1:=residualGaussian_scaled_derivative_bound (i+1) s b
  have h2:=smoothedResponse_derivative_bound (j-(i+1)) hlo ha hah hE (b+b₀)
  have hm:=mul_le_mul h1 h2 (abs_nonneg _)
    (mul_nonneg (pow_nonneg (abs_nonneg s) _) (residualGaussianDerivativeBound_nonneg _))
  have hh:=mul_le_mul_of_nonneg_left hm (Nat.cast_nonneg (j.choose (i+1)))
  nlinarith

lemma residualLeading_eq_gaussian_product {n:ℕ} (hn:0<n) (q:Fin n→ℕ)
    (hq:∀i,0<q i) (d:Fin n→ℝ) {a:ℝ} (ha:0<a) (b:ℝ) :
    residualLeading q d a b =
      (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q)))*
        (residualUnitGaussian (residualScale a q*b)*
          smoothedResponse a (∑i,(d i)^2) (b+(n%2:ℕ)*a)) := by
  unfold residualLeading residualUnitGaussian
  rw [show -( (residualScale a q*b)^2/2) = -b^2/(2*a^2*residualVariance q) by
    simpa only [mul_comm,neg_div] using residual_gaussian_exponent hn q hq ha b]
  ring

lemma residual_full_leading_derivative_error {n:ℕ} (hn:0<n) (q:Fin n→ℕ)
    (hq:∀i,0<q i) (d:Fin n→ℝ) (j:ℕ) {a lo hi:ℝ}
    (hlo:0<lo) (ha:lo≤a) (hah:a≤hi) (b:ℝ) :
    Real.sqrt (residualVariance q)*
      |iteratedDeriv j (residualLeading q d a) b-
        residualMomentLeading j q d a b ((j:ℝ)*Real.pi/2)| ≤
      (Real.sqrt (2*Real.pi)/Real.pi)*residualEnvelopeRemainder j lo hi (residualScale a q) := by
  have ha0:=hlo.trans_le ha
  have hE:0≤∑i,(d i)^2:=Finset.sum_nonneg (fun _ _=>sq_nonneg _)
  have hfun:=funext (residualLeading_eq_gaussian_product hn q hq d ha0)
  rw [hfun,iteratedDeriv_const_mul_field]
  unfold residualMomentLeading
  have he:Real.exp (-b^2/(2*a^2*residualVariance q))=
    residualUnitGaussian (residualScale a q*b) := by
    unfold residualUnitGaussian
    rw [show -( (residualScale a q*b)^2/2) = -b^2/(2*a^2*residualVariance q) by
      simpa only [mul_comm,neg_div] using residual_gaussian_exponent hn q hq ha0 b]
  rw [he,←iteratedDeriv_smoothedResponse ha0 hE j]
  rw [show (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q)))*
    residualUnitGaussian (residualScale a q*b)*
    iteratedDeriv j (smoothedResponse a (∑i,(d i)^2)) (b+(n%2:ℕ)*a) =
    (residualPhaseSign q*Real.sqrt (2/(Real.pi*residualVariance q)))*
      (residualUnitGaussian (residualScale a q*b)*
        iteratedDeriv j (smoothedResponse a (∑i,(d i)^2)) (b+(n%2:ℕ)*a)) by ring]
  rw [←mul_sub,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),←mul_assoc,residual_sqrt_normalization hn q hq]
  exact mul_le_mul_of_nonneg_left
    (residual_gaussian_product_derivative_error j hlo ha hah hE (residualScale a q) ((n%2:ℕ)*a) b)
    (by positivity)

/-- The full leading expression is differentiated, including every
Gaussian-envelope term, at every fixed derivative order. -/
theorem ResidualSequence.uniform_residual_full_derivatives
    {ι:Type*} [Fintype ι] [DecidableEq ι] (S:ResidualSequence ι) (j:ℕ) :
    ∀ ε>0, ∀ᶠ k in atTop, ∀ b:ℝ,
      Real.sqrt (residualVariance (S.alphabet k))*
        |iteratedDeriv j (parityCorrelation (S.incoming k)) b-
          iteratedDeriv j (residualLeading (S.alphabet k) (S.d k) (S.A k)) b| < ε := by
  intro ε hε
  have hs:=residualScale_tendsto S.N S.alphabet S.N_tendsto S.alphabet_pos
    S.A S.A_tendsto ((S.lo_pos.trans_le S.A₀_lo).ne')
  have he:=((residualEnvelopeRemainder_tendsto j S.lo S.hi).comp hs).const_mul
    (Real.sqrt (2*Real.pi)/Real.pi)
  simp only [mul_zero] at he
  filter_upwards [S.uniform_residual_all_derivatives j (ε/2) (by linarith),
    he.eventually (gt_mem_nhds (by linarith : (0:ℝ)<ε/2))] with k hk hke b
  have hb:=residual_full_leading_derivative_error (S.N_pos k) (S.alphabet k)
    (S.alphabet_pos k) (S.d k) j S.lo_pos (S.A_lo k) (S.A_hi k) b
  have ht:=abs_sub_le
    (iteratedDeriv j (parityCorrelation (S.incoming k)) b)
    (residualMomentLeading j (S.alphabet k) (S.d k) (S.A k) b ((j:ℝ)*Real.pi/2))
    (iteratedDeriv j (residualLeading (S.alphabet k) (S.d k) (S.A k)) b)
  rw [abs_sub_comm (residualMomentLeading _ _ _ _ _ _)] at ht
  have hm:=mul_le_mul_of_nonneg_left ht (Real.sqrt_nonneg (residualVariance (S.alphabet k)))
  have hh:=hk b
  dsimp only [Function.comp_apply] at hke
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
