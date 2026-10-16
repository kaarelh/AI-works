import NeuralGeneralization.PrekopaLeindlerInterval
import Mathlib.MeasureTheory.Integral.IntegralEqImproper
import Mathlib.Analysis.SpecialFunctions.Pow.Continuity

/-! Prékopa--Leindler on the real line, obtained from the proved compact
interval transport inequality by taking expanding intervals. -/
noncomputable section
open MeasureTheory Set Filter
open scoped Topology
namespace NeuralGeneralization.PrekopaLeindlerReal
open PrekopaLeindlerInterval PositiveCDFTransport

theorem prekopa_leindler_real {f g h : ℝ → ℝ} {t : ℝ}
    (hf : Continuous f) (hg : Continuous g) (hh : Continuous h)
    (hfpos : ∀ x, 0 < f x) (hgpos : ∀ x, 0 < g x)
    (hfi : Integrable f) (hgi : Integrable g) (hhi : Integrable h)
    (ht : t ∈ Icc 0 1)
    (hpoint : ∀ x y, f x ^ (1-t) * g y ^ t ≤ h (mix t x y)) :
    (∫ x, f x) ^ (1-t) * (∫ x, g x) ^ t ≤ ∫ x, h x := by
  have hlim (q : ℝ → ℝ) (hqi : Integrable q) :
      Tendsto (fun R : ℝ => mass q (-R) R) atTop (𝓝 (∫ x, q x)) :=
    intervalIntegral_tendsto_integral hqi tendsto_neg_atTop_atBot tendsto_id
  apply le_of_tendsto_of_tendsto
    (((hlim f hfi).rpow_const (Or.inr (sub_nonneg.mpr ht.2))).mul
      ((hlim g hgi).rpow_const (Or.inr ht.1))) (hlim h hhi)
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with R hR
  exact prekopa_leindler_interval hf hg hh hfpos hgpos (by linarith) ht
    (fun x _ y _ => hpoint x y)

end NeuralGeneralization.PrekopaLeindlerReal
end
