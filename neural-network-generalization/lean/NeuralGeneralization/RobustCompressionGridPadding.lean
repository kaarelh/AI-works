import NeuralGeneralization.RobustCompressionGridMeasurable
import NeuralGeneralization.Cloning

/-!
# Measurable width padding into one common finite output grid

Disconnected padding preserves real-valued outputs for every activation,
including activations with a nonzero value at zero.
-/

noncomputable section
open MeasureTheory

namespace NeuralGeneralization.ConcreteModel

theorem measurable_clonedWeights {d C N r k p : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) :
    Measurable (clonedWeights (d := d) (r := r) e) := by
  apply measurable_pi_lambda
  intro a
  rcases a with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · cases hi : e.symm i with
    | inl ab => simpa [clonedWeights, hi] using
        (measurable_pi_apply (Sum.inl (ab.1,j)) : Measurable
          (fun w : Weights d C r => w (Sum.inl (ab.1,j))))
    | inr p => simpa [clonedWeights, hi] using
        (measurable_const : Measurable (fun _ : Weights d C r => (0 : ℝ)))
  · cases hi : e.symm i with
    | inl ab =>
      cases hj : e.symm j with
      | inl cd =>
          have hm : Measurable (fun w : Weights d C r =>
              w (Sum.inr (Sum.inl (s,ab.1,cd.1)))) := measurable_pi_apply _
          simpa [clonedWeights, hi, hj] using hm.div_const (k : ℝ)
      | inr p => simpa [clonedWeights, hi, hj] using
          (measurable_const : Measurable (fun _ : Weights d C r => (0 : ℝ)))
    | inr p => simpa [clonedWeights, hi] using
        (measurable_const : Measurable (fun _ : Weights d C r => (0 : ℝ)))
  · cases hi : e.symm i with
    | inl ab =>
        have hm : Measurable (fun w : Weights d C r =>
            w (Sum.inr (Sum.inr ab.1))) := measurable_pi_apply _
        simpa [clonedWeights, hi] using hm.div_const (k : ℝ)
    | inr p => simpa [clonedWeights, hi] using
        (measurable_const : Measurable (fun _ : Weights d C r => (0 : ℝ)))

def widthPaddingEquiv {n M : ℕ} (hnM : n ≤ M) :
    ((Fin n × Fin 1) ⊕ Fin (M-n)) ≃ Fin M :=
  Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin, mul_one]
    omega)

def widthPaddedWeights {d n M r : ℕ} (hnM : n ≤ M)
    (w : Weights d n r) : Weights d M r :=
  clonedWeights (widthPaddingEquiv hnM) w

theorem measurable_widthPaddedWeights {d n M r : ℕ} (hnM : n ≤ M) :
    Measurable (widthPaddedWeights (d := d) (r := r) hnM) :=
  measurable_clonedWeights _

theorem networkOutput_widthPaddedWeights {d n M r : ℕ} (hnM : n ≤ M)
    (φ : ℝ → ℝ) (w : Weights d n r) (x : Cube d) :
    networkOutput φ (widthPaddedWeights hnM w) x = networkOutput φ w x :=
  networkOutput_cloned (by decide) φ _ w x

theorem widthPaddedWeights_bounded {d n M r : ℕ} (hnM : n ≤ M)
    {B : ℝ} (hB : 0 ≤ B) (w : Weights d n r) (hw : boundedWeights B w) :
    boundedWeights B (widthPaddedWeights hnM w) := by
  let e := widthPaddingEquiv hnM
  intro a
  change |clonedWeights e w a| ≤ B
  rcases a with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · cases hi : e.symm i with
    | inl ab => simpa [clonedWeights, hi] using hw (Sum.inl (ab.1,j))
    | inr p => simpa [clonedWeights, hi] using hB
  · cases hi : e.symm i with
    | inl ab =>
      cases hj : e.symm j with
      | inl cd => simpa [clonedWeights, hi, hj] using (hw (Sum.inr (Sum.inl (s,ab.1,cd.1))))
      | inr p => simpa [clonedWeights, hi, hj] using hB
    | inr p => simpa [clonedWeights, hi] using hB
  · cases hi : e.symm i with
    | inl ab => simpa [clonedWeights, hi] using hw (Sum.inr (Sum.inr ab.1))
    | inr p => simpa [clonedWeights, hi] using hB

def padAndRoundCode {d n M r : ℕ} (hnM : n ≤ M) (B R : ℕ)
    (w : Weights d n r) : RobustOutputCode d M r B R :=
  roundRobustCode d M r B R (widthPaddedWeights hnM w)

theorem measurable_padAndRoundCode {d n M r : ℕ}
    (hnM : n ≤ M) (B R : ℕ) :
    Measurable (padAndRoundCode (d := d) (r := r) hnM B R) :=
  (measurable_roundRobustCode d M r B R).comp (measurable_widthPaddedWeights hnM)

/-- One finite class covers every smaller bounded network by a measurable map. -/
theorem padAndRoundCode_output_close {d n M r B R : ℕ}
    (hnM : n ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hB : 0 < B) (hR : 0 < R)
    (w : Weights d n r) (hw : boundedWeights B w) (x : Cube d) :
    |networkOutput φ w x -
      robustGridOutput d M r B R φ (padAndRoundCode hnM B R w) x| ≤
        1 / (R : ℝ) := by
  have hh := roundRobustCode_output_close φ hφ hB hR
    (widthPaddedWeights hnM w)
    (widthPaddedWeights_bounded hnM (Nat.cast_nonneg B) w hw) x
  simpa only [networkOutput_widthPaddedWeights, padAndRoundCode] using hh

end NeuralGeneralization.ConcreteModel
