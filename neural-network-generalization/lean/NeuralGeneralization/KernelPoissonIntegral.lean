import NeuralGeneralization.KernelPoissonGamma
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! The integrable odd-coordinate-walk Poisson mixture, evaluated from
actual path counts. The coefficient weight is the explicit Gamma ratio. -/

noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set
open scoped BigOperators

def oddPoissonEndpoint (d : ℕ) (u : ℝ) (S : Finset (Fin d)) : ℝ :=
  (poissonFlipProbability u)^S.card*(1-poissonFlipProbability u)^(d-S.card)*
    (if Even S.card then poissonFlipProbability u else 1-poissonFlipProbability u)

theorem poissonFlipProbability_le_self {u : ℝ} (_hu : 0 ≤ u) :
    poissonFlipProbability u ≤ u := by
  have h := Real.add_one_le_exp (-2*u)
  unfold poissonFlipProbability
  linarith

theorem oddPoissonEndpoint_bounds (d : ℕ) {u : ℝ} (hu : 0 ≤ u)
    (S : Finset (Fin d)) :
    0 ≤ oddPoissonEndpoint d u S ∧ oddPoissonEndpoint d u S ≤ min u 1 := by
  let p := poissonFlipProbability u
  have hp0 : 0 ≤ p := poissonFlipProbability_nonneg hu
  have hp1 : p ≤ 1 := (poissonFlipProbability_lt_half u).le.trans (by norm_num)
  have hq0 : 0 ≤ 1-p := by linarith
  have hq1 : 1-p ≤ 1 := by linarith
  have hfirst : p^S.card ≤ 1 := pow_le_one₀ hp0 hp1
  have hsecond : (1-p)^(d-S.card) ≤ 1 := pow_le_one₀ hq0 hq1
  have hprod : p^S.card*(1-p)^(d-S.card) ≤ 1 :=
    mul_le_one₀ hfirst (pow_nonneg hq0 _) hsecond
  have hsmall : oddPoissonEndpoint d u S ≤ p := by
    unfold oddPoissonEndpoint
    change p^S.card*(1-p)^(d-S.card)*(if Even S.card then p else 1-p) ≤ p
    by_cases he : Even S.card
    · rw [if_pos he]
      simpa using mul_le_mul_of_nonneg_right hprod hp0
    · rw [if_neg he]
      have hcard : 1 ≤ S.card := by
        by_contra hn
        have hc : S.card=0 := by omega
        exact he (hc ▸ (by decide : Even 0))
      have hpow : p^S.card ≤ p := by
        simpa using pow_le_pow_of_le_one hp0 hp1 hcard
      calc
        p^S.card*(1-p)^(d-S.card)*(1-p) ≤ p*1*1 := by gcongr
        _ = p := by ring
  constructor
  · unfold oddPoissonEndpoint
    split_ifs <;> positivity
  · exact le_min (hsmall.trans (poissonFlipProbability_le_self hu)) (hsmall.trans hp1)

/-- The integrable singular weight is regularized at zero by the odd clock:
there is always at least one coordinate flip, including the bias flip. -/
theorem oddPoissonEndpoint_rpow_integrable (d : ℕ) {β : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1) (S : Finset (Fin d)) :
    IntegrableOn (fun u => u^(-1-β)*oddPoissonEndpoint d u S) (Ioi 0) := by
  have hmeas : AEStronglyMeasurable
      (fun u : ℝ => u^(-1-β)*oddPoissonEndpoint d u S) volume := by
    apply Measurable.aestronglyMeasurable
    unfold oddPoissonEndpoint poissonFlipProbability
    split_ifs <;> fun_prop
  rw [← Ioc_union_Ioi_eq_Ioi (show (0 : ℝ) ≤ 1 by norm_num),integrableOn_union]
  constructor
  · have hint : IntegrableOn (fun u : ℝ => u^(-β)) (Ioc 0 1) := by
      apply (intervalIntegrable_iff_integrableOn_Ioc_of_le (by norm_num : (0 : ℝ) ≤ 1)).mp
      exact intervalIntegral.intervalIntegrable_rpow' (by linarith)
    apply hint.mono' hmeas.restrict
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with u hu
    have hb := oddPoissonEndpoint_bounds d hu.1.le S
    rw [Real.norm_eq_abs,abs_of_nonneg (mul_nonneg (Real.rpow_nonneg hu.1.le _) hb.1)]
    calc
      u^(-1-β)*oddPoissonEndpoint d u S ≤ u^(-1-β)*u :=
        mul_le_mul_of_nonneg_left (hb.2.trans (min_le_left _ _)) (Real.rpow_nonneg hu.1.le _)
      _ = u^(-β) := by
        conv_lhs => rhs; rw [← Real.rpow_one u]
        rw [← Real.rpow_add hu.1]
        congr 1
        ring
  · have hint : IntegrableOn (fun u : ℝ => u^(-1-β)) (Ioi 1) :=
      integrableOn_Ioi_rpow_of_lt (by linarith) (by norm_num)
    apply hint.mono' hmeas.restrict
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with u hu
    have hu0 : 0 ≤ u := le_trans (by norm_num : (0 : ℝ) ≤ 1) hu.le
    have hb := oddPoissonEndpoint_bounds d hu0 S
    rw [Real.norm_eq_abs,abs_of_nonneg (mul_nonneg (Real.rpow_nonneg hu0 _) hb.1)]
    calc
      u^(-1-β)*oddPoissonEndpoint d u S ≤ u^(-1-β)*1 :=
        mul_le_mul_of_nonneg_left (hb.2.trans (min_le_right _ _)) (Real.rpow_nonneg hu0 _)
      _ = _ := mul_one _

/-- Tonelli/dominated convergence for the actual odd-time walk gives the
full Gamma-weighted Poissonization identity, with no analytic interchange
assumed. -/
theorem gamma_weighted_odd_biased_walk_hasSum (d : ℕ) {β : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1) (S : Finset (Fin d)) :
    HasSum (fun m : ℕ => if Odd m then
      ((d : ℝ)+1)^β*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ))*
        ((biasedPathCount m S : ℝ)/((d : ℝ)+1)^m) else 0)
      (∫ u : ℝ in Ioi 0,u^(-1-β)*oddPoissonEndpoint d u S) := by
  let F : ℕ → ℝ → ℝ := fun m u => u^(-1-β)*(if Odd m then
    Real.exp (-((d : ℝ)+1)*u)*(u^m/(m.factorial : ℝ))*(biasedPathCount m S : ℝ)
    else 0)
  have hs (u : ℝ) : HasSum (fun m => F m u)
      (u^(-1-β)*oddPoissonEndpoint d u S) :=
    (poissonized_odd_biased_path_count_hasSum d u S).mul_left _
  have hmeas (m : ℕ) : AEStronglyMeasurable (F m) (volume.restrict (Ioi 0)) := by
    apply Measurable.aestronglyMeasurable
    dsimp [F]
    split_ifs <;> fun_prop
  have hbound (m : ℕ) : ∀ᵐ u ∂volume.restrict (Ioi 0), ‖F m u‖ ≤ F m u := by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with u hu
    have hu0 : 0 ≤ u := hu.le
    have hnonneg : 0 ≤ F m u := by
      dsimp [F]
      split_ifs <;> positivity
    rw [Real.norm_eq_abs,abs_of_nonneg hnonneg]
  have hint : Integrable (fun u => ∑' m,F m u) (volume.restrict (Ioi 0)) := by
    have he : (fun u => ∑' m,F m u) = fun u => u^(-1-β)*oddPoissonEndpoint d u S := by
      funext u
      exact (hs u).tsum_eq
    rw [he]
    exact oddPoissonEndpoint_rpow_integrable d hβ0 hβ1 S
  have h := hasSum_integral_of_dominated_convergence F hmeas hbound
    (Filter.Eventually.of_forall fun u => (hs u).summable) hint
    (Filter.Eventually.of_forall hs)
  convert h using 1 <;> try rfl
  funext m
  by_cases ho : Odd m
  · simp only [if_pos ho]
    have hm : β < (m : ℝ) := hβ1.trans_le (by exact_mod_cast ho.pos)
    have he : F m = fun u : ℝ => u^(-1-β)*Real.exp (-((d : ℝ)+1)*u)*
        (u^m/(m.factorial : ℝ))*(biasedPathCount m S : ℝ) := by
      funext u
      simp only [F,if_pos ho]
      ring
    rw [he,biased_path_poisson_gamma_integral d m β hm S]
  · simp [F,ho]

/-- Normalized form used by the spectral comparison: the scale outside
 the integral is exactly `(d+1)^(-β)`. -/
theorem normalized_gamma_weighted_odd_biased_walk_hasSum (d : ℕ) {β : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1) (S : Finset (Fin d)) :
    HasSum (fun m : ℕ => if Odd m then
      (Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ))*
        ((biasedPathCount m S : ℝ)/((d : ℝ)+1)^m) else 0)
      (((d : ℝ)+1)^(-β)*
        (∫ u : ℝ in Ioi 0,u^(-1-β)*oddPoissonEndpoint d u S)) := by
  have h := (gamma_weighted_odd_biased_walk_hasSum d hβ0 hβ1 S).div_const
    (((d : ℝ)+1)^β)
  have hD : ((d : ℝ)+1)^β ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos (by positivity) _)
  convert h using 1 <;> try rfl
  · funext m
    by_cases ho : Odd m
    · simp only [if_pos ho]
      field_simp
    · simp [ho]
  · rw [Real.rpow_neg (by positivity : (0 : ℝ) ≤ d+1)]
    ring

end NeuralGeneralization
