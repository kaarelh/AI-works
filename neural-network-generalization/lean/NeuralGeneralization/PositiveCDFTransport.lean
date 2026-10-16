import Mathlib.MeasureTheory.Integral.IntervalIntegral.IntegrationByParts
import Mathlib.Analysis.Calculus.Deriv.Inverse
import Mathlib.Analysis.Calculus.Deriv.MeanValue
import Mathlib.Topology.Order.ProjIcc
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! The actual increasing transport between two positive continuous
densities on a compact real interval. This is the one-dimensional analytic
ingredient in the Prékopa--Leindler proof. -/
noncomputable section
open MeasureTheory Set Filter
open scoped Topology
namespace NeuralGeneralization.PositiveCDFTransport

def mass (f : ℝ → ℝ) (a b : ℝ) : ℝ := ∫ x in a..b, f x

def cdf (f : ℝ → ℝ) (a b x : ℝ) : ℝ := (∫ y in a..x, f y) / mass f a b

variable {f : ℝ → ℝ} {a b : ℝ}

theorem mass_pos (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) : 0 < mass f a b :=
  intervalIntegral.intervalIntegral_pos_of_pos (hf.intervalIntegrable a b) hpos hab

theorem hasDerivAt_cdf (hf : Continuous f) (x : ℝ) :
    HasDerivAt (cdf f a b) (f x / mass f a b) x := by
  exact (intervalIntegral.integral_hasDerivAt_right (hf.intervalIntegrable a x)
    hf.stronglyMeasurable.stronglyMeasurableAtFilter hf.continuousAt).div_const _

theorem continuous_cdf (hf : Continuous f) : Continuous (cdf f a b) :=
  continuous_iff_continuousAt.mpr (fun x => (hasDerivAt_cdf hf x).continuousAt)

theorem strictMono_cdf (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) :
    StrictMono (cdf f a b) :=
  strictMono_of_hasDerivAt_pos (hasDerivAt_cdf hf)
    (fun x => div_pos (hpos x) (mass_pos hf hpos hab))

@[simp] theorem cdf_left (f : ℝ → ℝ) (a b : ℝ) : cdf f a b a = 0 := by simp [cdf]

theorem cdf_right (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) : cdf f a b b = 1 := by
  exact div_self (mass_pos hf hpos hab).ne'

theorem cdf_mem_Icc (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b)
    {x : ℝ} (hx : x ∈ Icc a b) : cdf f a b x ∈ Icc 0 1 := by
  have hm := (strictMono_cdf hf hpos hab).monotone
  constructor
  · simpa only [cdf_left] using hm hx.1
  · simpa only [cdf_right hf hpos hab] using hm hx.2

theorem cdf_mem_Ioo (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b)
    {x : ℝ} (hx : x ∈ Ioo a b) : cdf f a b x ∈ Ioo 0 1 := by
  constructor
  · simpa only [cdf_left] using strictMono_cdf hf hpos hab hx.1
  · simpa only [cdf_right hf hpos hab] using strictMono_cdf hf hpos hab hx.2

def cdfOrderIso (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) : Icc a b ≃o Icc (0 : ℝ) 1 :=
  StrictMono.orderIsoOfSurjective
    (fun x => ⟨cdf f a b x, cdf_mem_Icc hf hpos hab x.property⟩)
    (fun x y hxy => strictMono_cdf hf hpos hab hxy)
    (by
      intro y
      have h := intermediate_value_Icc hab.le (continuous_cdf (a := a) (b := b) hf).continuousOn
      have hy : (y : ℝ) ∈ Icc (cdf f a b a) (cdf f a b b) := by
        simpa only [cdf_left, cdf_right hf hpos hab] using y.property
      obtain ⟨x, hx, hxy⟩ := h hy
      exact ⟨⟨x,hx⟩, Subtype.ext hxy⟩)

def quantile (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) (t : ℝ) : ℝ :=
  ((cdfOrderIso hf hpos hab).symm (projIcc 0 1 zero_le_one t) : ℝ)

theorem continuous_quantile (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) :
    Continuous (quantile hf hpos hab) :=
  continuous_subtype_val.comp ((cdfOrderIso hf hpos hab).symm.continuous.comp continuous_projIcc)

theorem quantile_mem_Icc (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) (t : ℝ) :
    quantile hf hpos hab t ∈ Icc a b :=
  ((cdfOrderIso hf hpos hab).symm (projIcc 0 1 zero_le_one t)).property

theorem cdf_quantile (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b)
    {t : ℝ} (ht : t ∈ Icc 0 1) : cdf f a b (quantile hf hpos hab t) = t := by
  have h := congrArg Subtype.val ((cdfOrderIso hf hpos hab).apply_symm_apply (projIcc 0 1 zero_le_one t))
  simpa only [cdfOrderIso, StrictMono.coe_orderIsoOfSurjective, quantile,
    projIcc_of_mem zero_le_one ht] using h

theorem quantile_cdf (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b)
    {x : ℝ} (hx : x ∈ Icc a b) : quantile hf hpos hab (cdf f a b x) = x := by
  have h := congrArg Subtype.val ((cdfOrderIso hf hpos hab).symm_apply_apply (⟨x,hx⟩ : Icc a b))
  simpa only [quantile, projIcc_of_mem zero_le_one (cdf_mem_Icc hf hpos hab hx),
    cdfOrderIso, StrictMono.coe_orderIsoOfSurjective] using h

theorem quantile_zero (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) :
    quantile hf hpos hab 0 = a := by
  simpa only [cdf_left] using quantile_cdf hf hpos hab (left_mem_Icc.mpr hab.le)

theorem quantile_one (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b) :
    quantile hf hpos hab 1 = b := by
  simpa only [cdf_right hf hpos hab] using quantile_cdf hf hpos hab (right_mem_Icc.mpr hab.le)

theorem hasDerivAt_quantile (hf : Continuous f) (hpos : ∀ x, 0 < f x) (hab : a < b)
    {t : ℝ} (ht : t ∈ Ioo 0 1) :
    HasDerivAt (quantile hf hpos hab) (mass f a b / f (quantile hf hpos hab t)) t := by
  have hq := HasDerivAt.of_local_left_inverse (continuous_quantile hf hpos hab).continuousAt
    (hasDerivAt_cdf hf (quantile hf hpos hab t))
    (div_pos (hpos _) (mass_pos hf hpos hab)).ne'
    (by
      filter_upwards [isOpen_Ioo.mem_nhds ht] with s hs
      exact cdf_quantile hf hpos hab (Ioo_subset_Icc_self hs))
  simpa only [inv_div] using hq

def transport {g : ℝ → ℝ} (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b)
    (f : ℝ → ℝ) (x : ℝ) : ℝ := quantile hg hgpos hab (cdf f a b x)

theorem continuous_transport {g : ℝ → ℝ} (hf : Continuous f) (hg : Continuous g)
    (hgpos : ∀ x, 0 < g x) (hab : a < b) : Continuous (transport hg hgpos hab f) :=
  (continuous_quantile hg hgpos hab).comp (continuous_cdf hf)

theorem hasDerivAt_transport {g : ℝ → ℝ} (hf : Continuous f) (hfpos : ∀ x, 0 < f x)
    (hg : Continuous g) (hgpos : ∀ x, 0 < g x) (hab : a < b) {x : ℝ} (hx : x ∈ Ioo a b) :
    HasDerivAt (transport hg hgpos hab f)
      ((mass g a b / g (transport hg hgpos hab f x)) * (f x / mass f a b)) x :=
  (hasDerivAt_quantile hg hgpos hab (cdf_mem_Ioo hf hfpos hab hx)).comp x (hasDerivAt_cdf hf x)

end NeuralGeneralization.PositiveCDFTransport
end
