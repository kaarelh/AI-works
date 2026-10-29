import NeuralGeneralization.RobustCouplingSequential
import NeuralGeneralization.BatchTwoNonGaussianTaylor

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy NeuralGeneralization.RobustCoupling

variable {A B : Type*} [MeasurableSpace A] [MeasurableSpace B]
  [StandardBorelSpace A] [StandardBorelSpace B] [Nonempty A] [Nonempty B]

/-- Replace the conditional law beyond the anchors by the reference conditional
law, retaining the controlled anchor marginal. Both laws are actual measures. -/
def anchorReplacement (Q G : Measure (A × B)) [IsFiniteMeasure G] : Measure (A × B) := Q.fst ⊗ₘ G.condKernel

instance anchorReplacement_probability (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] : IsProbabilityMeasure (anchorReplacement Q G) := by
  unfold anchorReplacement
  infer_instance

theorem anchorReplacement_fst (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] : (anchorReplacement Q G).fst=Q.fst := by
  exact Measure.fst_compProd Q.fst G.condKernel

/-- The replacement has exactly the anchor entropy relative to the original
reference, including when that entropy is infinite. -/
theorem anchorReplacement_kl (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] : klDiv (anchorReplacement Q G) G=klDiv Q.fst G.fst := by
  calc
    klDiv (anchorReplacement Q G) G =
        klDiv (Q.fst ⊗ₘ G.condKernel) (G.fst ⊗ₘ G.condKernel) := by
      rw [Measure.disintegrate G G.condKernel]
      rfl
    _ = _ := klDiv_compProd_left Q.fst G.fst G.condKernel

/-- The conditional entropy discarded by replacement is the exact remainder
in the KL chain rule, not merely a data-processing upper bound. -/
theorem anchorReplacement_chain (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] :
    klDiv Q G=klDiv Q.fst G.fst+klDiv Q (anchorReplacement Q G) := by
  have hh := klDiv_compProd_eq_add Q.fst G.fst Q.condKernel G.condKernel
  rw [Measure.disintegrate Q Q.condKernel,Measure.disintegrate G G.condKernel] at hh
  exact hh

theorem anchorReplacement_conditional_finite (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] (hfinite : klDiv Q G≠∞) : klDiv Q (anchorReplacement Q G)≠∞ := by
  have hh := anchorReplacement_chain Q G
  rw [hh] at hfinite
  exact (ENNReal.add_ne_top.mp hfinite).2

theorem anchorReplacement_conditional_toReal (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] (hfinite : klDiv Q G≠∞) :
    (klDiv Q (anchorReplacement Q G)).toReal=(klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal := by
  have hh := anchorReplacement_chain Q G
  have hf := hfinite
  rw [hh] at hf
  have hr := congrArg ENNReal.toReal hh
  rw [ENNReal.toReal_add (ENNReal.add_ne_top.mp hf).1 (ENNReal.add_ne_top.mp hf).2] at hr
  linarith

theorem anchorReplacement_conditional_integral (Q G : Measure (A × B)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] :
    klDiv Q (anchorReplacement Q G)=∫⁻a,klDiv (Q.condKernel a) (G.condKernel a) ∂Q.fst := by
  have hh := klDiv_compProd_same_left_eq_lintegral Q.fst Q.condKernel G.condKernel
  rw [Measure.disintegrate Q Q.condKernel] at hh
  exact hh

/-- Explicit measurable conditional common-part coupling. The same anchor
value is shared by the old and replacement query. -/
def sharedAnchorCoupling (Q G : Measure (A × ℝ)) [IsFiniteMeasure Q]
    [IsFiniteMeasure G] : Measure (A × (ℝ × ℝ)) :=
  Q.fst ⊗ₘ entropyCouplingKernel Q.condKernel G.condKernel

instance sharedAnchorCoupling_probability (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] : IsProbabilityMeasure (sharedAnchorCoupling Q G) := by
  unfold sharedAnchorCoupling
  infer_instance

theorem sharedAnchorCoupling_left (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] :
    (sharedAnchorCoupling Q G).map (fun p => (p.1,p.2.1))=Q := by
  have hh := map_compProd_pair Q.fst (entropyCouplingKernel Q.condKernel G.condKernel)
    Q.condKernel id Prod.fst measurable_id measurable_fst
    (fun a => entropyCouplingKernel_fst Q.condKernel G.condKernel a)
  simp only [Measure.map_id,id_eq,Measure.disintegrate Q Q.condKernel] at hh
  exact hh

theorem sharedAnchorCoupling_right (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] :
    (sharedAnchorCoupling Q G).map (fun p => (p.1,p.2.2))=anchorReplacement Q G := by
  have hh := map_compProd_pair Q.fst (entropyCouplingKernel Q.condKernel G.condKernel)
    G.condKernel id Prod.snd measurable_id measurable_snd
    (fun a => entropyCouplingKernel_snd Q.condKernel G.condKernel a)
  simp only [Measure.map_id,id_eq] at hh
  exact hh

/-- Mismatch probability is bounded by the exact discarded conditional KL. -/
theorem sharedAnchorCoupling_mismatch (Q G : Measure (A × ℝ)) [IsProbabilityMeasure Q]
    [IsProbabilityMeasure G] {s : ℝ} (hs : 0<s) :
    sharedAnchorCoupling Q G {p | p.2.1≠p.2.2}≤
      ENNReal.ofReal (1/s)*klDiv Q (anchorReplacement Q G)+ENNReal.ofReal s := by
  have hm : Measurable (fun p : A × (ℝ × ℝ) => scalarMismatch p.2) :=
    measurable_scalarMismatch.comp measurable_snd
  have hleft : sharedAnchorCoupling Q G {p | p.2.1≠p.2.2}=
      ∫⁻p,scalarMismatch p.2 ∂sharedAnchorCoupling Q G := by
    exact (lintegral_indicator_one (measurableSet_eq_fun
      (measurable_fst.comp measurable_snd) (measurable_snd.comp measurable_snd)).compl).symm
  rw [hleft,sharedAnchorCoupling,Measure.lintegral_compProd hm]
  simp only [entropyCouplingKernel_apply,lintegral_scalarMismatch]
  calc
    _ ≤ ∫⁻a,ENNReal.ofReal (1/s)*klDiv (Q.condKernel a) (G.condKernel a)+ENNReal.ofReal s ∂Q.fst :=
      lintegral_mono fun a => entropyCoupling_disagreement_le_ennreal _ _ hs
    _ = _ := by
      rw [lintegral_add_right _ measurable_const,
        lintegral_const_mul _ (measurable_kernel_klDiv Q.condKernel G.condKernel),
        lintegral_const,measure_univ,mul_one,← anchorReplacement_conditional_integral Q G]

theorem sharedAnchorCoupling_bounded_error_parameter (Q G : Measure (A × ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (hfinite : klDiv Q G≠∞)
    {s : ℝ} (hs : 0<s) (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀x,|g x|≤1) :
    (∫p,(g p.2.1-g p.2.2)^2 ∂sharedAnchorCoupling Q G)≤
      4*((klDiv Q (anchorReplacement Q G)).toReal/s+s) := by
  have hf := anchorReplacement_conditional_finite Q G hfinite
  have hm := sharedAnchorCoupling_mismatch Q G hs
  have hmf : ENNReal.ofReal (1/s)*klDiv Q (anchorReplacement Q G)+ENNReal.ofReal s≠∞ := by
    finiteness
  have hmr := ENNReal.toReal_mono hmf hm
  rw [ENNReal.toReal_add (by finiteness) ENNReal.ofReal_ne_top,ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (one_div_pos.mpr hs).le,ENNReal.toReal_ofReal hs.le] at hmr
  have he := bounded_squared_error_le_disagreement (sharedAnchorCoupling Q G).snd g hg hbound
  have heq : (sharedAnchorCoupling Q G).snd.real {p | p.1≠p.2}=
      (sharedAnchorCoupling Q G {p | p.2.1≠p.2.2}).toReal := by
    unfold Measure.real Measure.snd
    rw [Measure.map_apply measurable_snd (show MeasurableSet {p : ℝ × ℝ | p.1≠p.2} from
      (measurableSet_eq_fun measurable_fst measurable_snd).compl)]
    rfl
  rw [heq] at he
  have hieq : (∫p,(g p.1-g p.2)^2 ∂(sharedAnchorCoupling Q G).snd)=
      ∫p,(g p.2.1-g p.2.2)^2 ∂sharedAnchorCoupling Q G := by
    unfold Measure.snd
    rw [integral_map (by fun_prop) (by fun_prop)]
  rw [hieq] at he
  have hid : (1/s)*(klDiv Q (anchorReplacement Q G)).toReal=
      (klDiv Q (anchorReplacement Q G)).toReal/s := by ring
  rw [hid] at hmr
  linarith

/-- The actual shared-anchor coupling has bounded-output squared error at
most 8 sqrt(delta) whenever adding the query increases anchor KL by delta.
In particular this holds for tanh, without needing a conditional Gaussian
transport theorem. -/
theorem sharedAnchorCoupling_bounded_error (Q G : Measure (A × ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (hfinite : klDiv Q G≠∞)
    {δ : ℝ} (hδ : 0<δ)
    (hgap : (klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal≤δ)
    (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀x,|g x|≤1) :
    (∫p,(g p.2.1-g p.2.2)^2 ∂sharedAnchorCoupling Q G)≤8*Real.sqrt δ := by
  have hs : 0<Real.sqrt δ := Real.sqrt_pos.mpr hδ
  have hh := sharedAnchorCoupling_bounded_error_parameter Q G hfinite hs g hg hbound
  rw [anchorReplacement_conditional_toReal Q G hfinite] at hh
  have hd : ((klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal)/Real.sqrt δ≤Real.sqrt δ := by
    apply (div_le_iff₀ hs).mpr
    rw [← sq,Real.sq_sqrt hδ.le]
    exact hgap
  linarith

theorem sharedAnchorCoupling_tanh_error (Q G : Measure (A × ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (hfinite : klDiv Q G≠∞)
    {δ : ℝ} (hδ : 0<δ)
    (hgap : (klDiv Q G).toReal-(klDiv Q.fst G.fst).toReal≤δ) :
    (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂sharedAnchorCoupling Q G)≤8*Real.sqrt δ :=
  sharedAnchorCoupling_bounded_error Q G hfinite hδ hgap Real.tanh (by fun_prop)
    (fun x => (Real.abs_tanh_lt_one x).le)

#print axioms anchorReplacement_kl
#print axioms anchorReplacement_conditional_toReal
#print axioms sharedAnchorCoupling_mismatch
#print axioms sharedAnchorCoupling_tanh_error
end ConditionalNonpolynomial.Analytic
