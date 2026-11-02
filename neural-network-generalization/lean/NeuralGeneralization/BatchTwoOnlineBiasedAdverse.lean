import NeuralGeneralization.BatchTwoOnlineBiasedOrder
import NeuralGeneralization.BatchTwoOnlineAdverseOrder

/-! The adverse-order prior under explicitly normalized geometric IID
inputs. Repeated observations are handled by the actual consistency history. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Classical MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnline.BiasedIID
open NeuralGeneralization.BatchTwoOnline

def geometricWeight (m : ℕ) (ρ : ℝ) (x : Fin (m+1)) : ℝ :=
  ρ^x.val/(∑ y : Fin (m+1),ρ^y.val)

theorem geometric_normalizer_pos (m : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    0 < ∑ y : Fin (m+1),ρ^y.val :=
  Finset.sum_pos (fun _ _ => pow_pos hρ _) Finset.univ_nonempty

theorem geometricWeight_pos (m : ℕ) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin (m+1)) :
    0 < geometricWeight m ρ x := div_pos (pow_pos hρ _) (geometric_normalizer_pos m hρ)

theorem geometricWeight_sum (m : ℕ) {ρ : ℝ} (hρ : 0 < ρ) :
    ∑ x,geometricWeight m ρ x = 1 := by
  simp only [geometricWeight, ← Finset.sum_div]
  exact div_self (geometric_normalizer_pos m hρ).ne'

def geometricLaw (m : ℕ) (ρ : ℝ) (hρ : 0 < ρ) : Measure (Fin (m+1)) :=
  finiteWeightLaw (geometricWeight m ρ) (fun x => (geometricWeight_pos m hρ x).le)
    (geometricWeight_sum m hρ)

instance geometricLaw_probability (m : ℕ) (ρ : ℝ) (hρ : 0 < ρ) :
    IsProbabilityMeasure (geometricLaw m ρ hρ) := by unfold geometricLaw; infer_instance

@[simp] theorem geometricLaw_real (m : ℕ) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin (m+1)) :
    (geometricLaw m ρ hρ).real {x} = geometricWeight m ρ x := by
  rw [Measure.real, geometricLaw, finiteWeightLaw_singleton,
    ENNReal.toReal_ofReal (geometricWeight_pos m hρ x).le]

theorem geometricLaw_ratio {m : ℕ} {ρ : ℝ} (hρ : 0 < ρ) (i : Fin m) :
    (geometricLaw m ρ hρ).real {i.succ} = ρ*(geometricLaw m ρ hρ).real {i.castSucc} := by
  rw [geometricLaw_real, geometricLaw_real]
  simp only [geometricWeight, Fin.val_succ, Fin.coe_castSucc, pow_succ]
  ring

/-- Actual histories at first appearances equal the prescribed-order
histories; duplicates impose no new consistency constraint. -/
theorem history_at_ordered_first_hit {H : Type*} {m : ℕ}
    (good : H → ℕ → Prop) (s : ℕ → Fin (m+1)) (t : Fin (m+1) → ℕ)
    (hmono : StrictMono t) (ht : ∀ x,s (t x)=x ∧ ∀ k < t x,s k≠x)
    (i : Fin (m+1)) :
    history good (fun n => (s n).val) (t i) = history good id i.val := by
  funext h
  apply propext
  constructor
  · intro hh j hj
    let x : Fin (m+1) := ⟨j,lt_trans hj i.isLt⟩
    have htime : t x < t i := hmono hj
    have he := hh (t x) htime
    simpa only [(ht x).1, x, id_eq] using he
  · intro hh n hn
    have hfirst : t (s n) ≤ n := by
      by_contra hnot
      exact (ht (s n)).2 n (by omega) rfl
    have hval : (s n).val < i.val := by
      by_contra hnot
      have hle : i ≤ s n := by omega
      have hh' := hmono.monotone hle
      omega
    exact hh (s n).val hval

theorem onlineError_at_ordered_first_hit {H : Type*} [Fintype H] {m : ℕ}
    (w : H → ℝ) (good : H → ℕ → Prop) (s : ℕ → Fin (m+1)) (t : Fin (m+1) → ℕ)
    (hmono : StrictMono t) (ht : ∀ x,s (t x)=x ∧ ∀ k < t x,s k≠x)
    (i : Fin (m+1)) :
    onlineError w good (fun n => (s n).val) (t i) = onlineError w good id i.val := by
  simp only [onlineError, onlinePosterior, history_at_ordered_first_hit good s t hmono ht i,
    (ht i).1, id_eq]

/-- With probability at least 1-(support size-1)ρ, every distinct input
causes an error above 1-1/R on first appearance. For R>3 every such
appearance is a majority mistake and a 2/3-confidence failure. This is
an abstract finite-class prior, not a Gaussian NNBayes lower bound. -/
theorem geometric_iid_adverse_errors (m : ℕ) {ρ R : ℝ} (hρ : 0 < ρ) (hR : 3 < R) :
    ∃ E : Set (ℕ → Fin (m+1)), MeasurableSet E ∧
      1-(m:ℝ)*ρ ≤ (Measure.infinitePi (fun _ : ℕ => geometricLaw m ρ hρ)).real E ∧
      ∀ s ∈ E,∃ t : Fin (m+1) → ℕ, StrictMono t ∧
        ∀ i,s (t i)=i ∧
          1-1/R < onlineError (AdverseOrder.weight (m+1) R) (AdverseOrder.good (m+1))
            (fun n => (s n).val) (t i) ∧
          1-onlineError (AdverseOrder.weight (m+1) R) (AdverseOrder.good (m+1))
            (fun n => (s n).val) (t i) < 1/3 := by
  obtain ⟨E,hE,hprob,horder⟩ := biased_iid_first_appearance (geometricLaw m ρ hρ) hρ.le
    (fun x => by rw [geometricLaw_real]; exact geometricWeight_pos m hρ x)
    (geometricLaw_ratio hρ)
  refine ⟨E,hE,hprob,?_⟩
  intro s hs
  obtain ⟨t,hmono,ht⟩ := horder s hs
  refine ⟨t,hmono,fun i => ⟨(ht i).1,?_⟩⟩
  rw [onlineError_at_ordered_first_hit _ _ s t hmono ht i]
  exact ⟨AdverseOrder.error_gt i.isLt (by linarith),AdverseOrder.correct_probability_lt_third i.isLt hR⟩

end NeuralGeneralization.BatchTwoOnline.BiasedIID
