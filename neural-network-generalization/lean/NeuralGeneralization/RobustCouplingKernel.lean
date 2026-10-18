import NeuralGeneralization.RobustCoupling
import Mathlib.Probability.Kernel.RadonNikodym
import Mathlib.Probability.Kernel.Composition.Prod

/-!
# Measurable conditional common-part coupling

This module lifts the explicit real-valued coupling to actual Markov kernels.
Its construction uses the jointly measurable kernel Radon--Nikodym derivative,
not a nonmeasurable pointwise choice of couplings.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCoupling

variable {Α : Type*} [MeasurableSpace Α]

def commonPartKernel (κ η : Kernel Α ℝ) [IsFiniteKernel κ] [IsFiniteKernel η] :
    Kernel Α ℝ :=
  η.withDensity (fun a x =>
    ENNReal.ofReal (min (Kernel.rnDeriv κ η a x).toReal 1))

theorem commonPartKernel_apply (κ η : Kernel Α ℝ)
    [IsFiniteKernel κ] [IsFiniteKernel η] (a : Α) :
    commonPartKernel κ η a = commonPart (κ a) (η a) := by
  have hm : Measurable (Function.uncurry (fun a x =>
      ENNReal.ofReal (min (Kernel.rnDeriv κ η a x).toReal 1))) :=
    (((Kernel.measurable_rnDeriv κ η).ennreal_toReal).min measurable_const).ennreal_ofReal
  rw [commonPartKernel, Kernel.withDensity_apply η hm, commonPart]
  apply withDensity_congr_ae
  filter_upwards [Kernel.rnDeriv_eq_rnDeriv_measure (κ := κ) (η := η) (a := a)] with x hx
  rw [hx]

instance commonPartKernel_finite (κ η : Kernel Α ℝ)
    [IsFiniteKernel κ] [IsFiniteKernel η] : IsFiniteKernel (commonPartKernel κ η) := by
  apply isFiniteKernel_of_le (ν := η)
  intro a
  rw [commonPartKernel_apply]
  exact commonPart_le_right (κ a) (η a)

theorem commonPartKernel_le_left (κ η : Kernel Α ℝ)
    [IsFiniteKernel κ] [IsFiniteKernel η] : commonPartKernel κ η ≤ κ := by
  intro a
  rw [commonPartKernel_apply]
  exact commonPart_le_left_general (κ a) (η a)

theorem commonPartKernel_le_right (κ η : Kernel Α ℝ)
    [IsFiniteKernel κ] [IsFiniteKernel η] : commonPartKernel κ η ≤ η := by
  intro a
  rw [commonPartKernel_apply]
  exact commonPart_le_right (κ a) (η a)

def residualKernel (κ ρ : Kernel Α ℝ) [IsFiniteKernel ρ] (hle : ρ ≤ κ) :
    Kernel Α ℝ where
  toFun a := κ a - ρ a
  measurable' := by
    apply Measure.measurable_of_measurable_coe
    intro s hs
    simp_rw [Measure.sub_apply hs (hle _)]
    exact (κ.measurable_coe hs).sub (ρ.measurable_coe hs)

instance residualKernel_finite (κ ρ : Kernel Α ℝ)
    [IsFiniteKernel κ] [IsFiniteKernel ρ] (hle : ρ ≤ κ) :
    IsFiniteKernel (residualKernel κ ρ hle) := by
  apply isFiniteKernel_of_le (ν := κ)
  intro a
  exact Measure.sub_le

def commonCouplingKernel (κ η ρ : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] [IsFiniteKernel ρ]
    (hρκ : ρ ≤ κ) (hρη : ρ ≤ η) : Kernel Α (ℝ × ℝ) where
  toFun a := commonCoupling (κ a) (η a) (ρ a)
  measurable' := by
    classical
    apply Measure.measurable_of_measurable_coe
    intro s hs
    let l := residualKernel κ ρ hρκ
    let r := residualKernel η ρ hρη
    have hm : Measurable (fun a => l a univ) := l.measurable_coe MeasurableSet.univ
    have hd : Measurable (fun x : ℝ => (x, x)) := measurable_id.prodMk measurable_id
    have hk : Measurable (fun a => (κ a).map (fun x => (x, x)) s) := by
      simp_rw [Measure.map_apply hd hs]
      exact κ.measurable_coe (hs.preimage hd)
    have hp : Measurable (fun a => (ρ a).map (fun x => (x, x)) s) := by
      simp_rw [Measure.map_apply hd hs]
      exact ρ.measurable_coe (hs.preimage hd)
    have hprod : Measurable (fun a => (l a).prod (r a) s) := by
      simpa only [Kernel.prod_apply] using (l ×ₖ r).measurable_coe hs
    have hz : MeasurableSet {a | l a univ = 0} :=
      measurableSet_eq_fun hm measurable_const
    have h : Measurable (fun a => if l a univ = 0
        then (κ a).map (fun x => (x, x)) s
        else (ρ a).map (fun x => (x, x)) s + (l a univ)⁻¹ * (l a).prod (r a) s) :=
      hk.ite hz (hp.add (hm.inv.mul hprod))
    simpa only [commonCoupling, apply_ite, ite_apply, Measure.add_apply, Measure.smul_apply, smul_eq_mul,
      l, r, residualKernel, Kernel.coe_mk] using h

instance commonCouplingKernel_markov (κ η ρ : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] [IsFiniteKernel ρ]
    (hρκ : ρ ≤ κ) (hρη : ρ ≤ η) :
    IsMarkovKernel (commonCouplingKernel κ η ρ hρκ hρη) := by
  constructor
  intro a
  exact commonCoupling_isProbability (κ a) (η a) (ρ a) (hρκ a) (hρη a)

def entropyCouplingKernel (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] : Kernel Α (ℝ × ℝ) :=
  commonCouplingKernel κ η (commonPartKernel κ η)
    (commonPartKernel_le_left κ η) (commonPartKernel_le_right κ η)

theorem entropyCouplingKernel_apply (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α) :
    entropyCouplingKernel κ η a = entropyCoupling (κ a) (η a) := by
  change commonCoupling (κ a) (η a) (commonPartKernel κ η a) = _
  rw [commonPartKernel_apply]
  rfl

instance entropyCouplingKernel_markov (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] :
    IsMarkovKernel (entropyCouplingKernel κ η) := by
  unfold entropyCouplingKernel
  infer_instance

theorem entropyCouplingKernel_fst (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α) :
    (entropyCouplingKernel κ η a).map Prod.fst = κ a := by
  rw [entropyCouplingKernel_apply]
  exact entropyCoupling_fst _ _

theorem entropyCouplingKernel_snd (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α) :
    (entropyCouplingKernel κ η a).map Prod.snd = η a := by
  rw [entropyCouplingKernel_apply]
  exact entropyCoupling_snd _ _

/-- The parameterized coupling is measurable even where KL is infinite;
the quantitative estimate only requires finite KL at the selected parameter. -/
theorem entropyCouplingKernel_disagreement_le (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α)
    (hfinite : InformationTheory.klDiv (κ a) (η a) ≠ ⊤) :
    (entropyCouplingKernel κ η a).real {p | p.1 ≠ p.2} ≤
      2 * Real.sqrt (InformationTheory.klDiv (κ a) (η a)).toReal := by
  rw [entropyCouplingKernel_apply]
  exact entropyCoupling_disagreement_le _ _ hfinite

theorem entropyCouplingKernel_disagreement_le_parameter (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α)
    (hfinite : InformationTheory.klDiv (κ a) (η a) ≠ ⊤) {s : ℝ} (hs : 0 < s) :
    (entropyCouplingKernel κ η a).real {p | p.1 ≠ p.2} ≤
      (InformationTheory.klDiv (κ a) (η a)).toReal / s + s := by
  rw [entropyCouplingKernel_apply]
  exact entropyCoupling_disagreement_le_parameter _ _ hfinite hs

theorem entropyCouplingKernel_bounded_squared_error_parameter (κ η : Kernel Α ℝ)
    [IsMarkovKernel κ] [IsMarkovKernel η] (a : Α)
    (hfinite : InformationTheory.klDiv (κ a) (η a) ≠ ⊤) {s : ℝ} (hs : 0 < s)
    (g : ℝ → ℝ) (hg : Measurable g) (hbound : ∀ x, |g x| ≤ 1) :
    (∫ p, (g p.1 - g p.2) ^ 2 ∂entropyCouplingKernel κ η a) ≤
      4 * ((InformationTheory.klDiv (κ a) (η a)).toReal / s + s) := by
  rw [entropyCouplingKernel_apply]
  exact entropyCoupling_bounded_squared_error_parameter _ _ hfinite hs g hg hbound

end NeuralGeneralization.RobustCoupling
