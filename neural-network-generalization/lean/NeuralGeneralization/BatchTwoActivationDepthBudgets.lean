import NeuralGeneralization.BatchTwoActivationPolynomialEvents
import NeuralGeneralization.PolynomialGrowth

/-! Explicit fixed-depth polynomial envelopes for backward precision and
forward finite reconstruction. These arithmetic bounds do not assert that a
network satisfies the layer good events. -/
namespace NeuralGeneralization.BatchTwoActivation

def activationPrecisionGrow (b : ℕ) : ℕ → ℕ
  | 0 => b
  | s+1 => (activationPrecisionGrow b s)^160

def activationStageBudget (H b s : ℕ) : ℕ := activationPrecisionGrow b (H-1-s)

theorem activationPrecisionGrow_pos {b : ℕ} (hb : 0<b) (s : ℕ) :
    0<activationPrecisionGrow b s := by
  induction s with
  | zero => exact hb
  | succ s ih => exact Nat.pow_pos ih

theorem activationPrecisionGrow_ge_base {b : ℕ} (hb : 1≤b) (s : ℕ) :
    b≤activationPrecisionGrow b s := by
  induction s with
  | zero => rfl
  | succ s ih =>
    apply ih.trans
    exact Nat.le_pow (by omega)

theorem activationPrecisionGrow_mono (b : ℕ) : Monotone (activationPrecisionGrow b) := by
  apply monotone_nat_of_le_succ
  intro s
  exact Nat.le_pow (by omega)

theorem activationStageBudget_backward {H b s : ℕ} (hs : s+1<H) :
    activationStageBudget H b s=(activationStageBudget H b (s+1))^160 := by
  have he : H-1-s=(H-1-(s+1))+1 := by omega
  unfold activationStageBudget
  rw [he,activationPrecisionGrow]

theorem activationStageBudget_terminal {H b : ℕ} (hH : 0<H) :
    activationStageBudget H b (H-1)=b := by simp [activationStageBudget,activationPrecisionGrow]

theorem activationStageBudget_le_max (H b s : ℕ) :
    activationStageBudget H b s≤activationPrecisionGrow b H := by
  exact activationPrecisionGrow_mono b (by omega)

theorem activationPrecisionGrow_polynomial {b : ℕ → ℕ → ℕ}
    (hb : PolynomialGrowth2 b) (H : ℕ) :
    PolynomialGrowth2 (fun d K => activationPrecisionGrow (b d K) H) := by
  induction H with
  | zero => exact hb
  | succ H ih => exact ih.pow 160

def activationDiagonalBudget (b d K H : ℕ) : ℕ :=
  2*(128*b^2*(d+K+4))^H

def activationBaseBudget (b d K H : ℕ) : ℕ :=
  128+b+512*K+(d+2)+2*activationDiagonalBudget b d K H*(d+4)+1

def activationMaxBudget (b d K H : ℕ) : ℕ :=
  activationPrecisionGrow (activationBaseBudget b d K H) H

def activationLearnerThreshold (b d K H : ℕ) : ℕ :=
  (activationMaxBudget b d K H)^84

def activationFiniteWidth (b d K H : ℕ) : ℕ :=
  d+2+2*(activationMaxBudget b d K H)^48

def activationSourceBudget (b d K H : ℕ) : ℕ :=
  let k := activationMaxBudget b d K H
  4*k^36+4*k^48*(activationFiniteWidth b d K H+1)+4

def activationRowBudget (b d K H : ℕ) : ℕ :=
  (2+56*K)*(activationSourceBudget b d K H+(activationMaxBudget b d K H)^10)

def activationStateBudget (b d K H : ℕ) : ℕ :=
  (1+b*activationFiniteWidth b d K H*activationRowBudget b d K H)^(3^H)

def activationRawBudget (b d K H : ℕ) : ℕ :=
  1+(activationFiniteWidth b d K H)^2*(activationRowBudget b d K H*activationStateBudget b d K H)^2+
    activationFiniteWidth b d K H*(32*K*(1+56*K)*activationStateBudget b d K H)^2

theorem activationDiagonalBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationDiagonalBudget b d K H) := by
  unfold activationDiagonalBudget
  exact (PolynomialGrowth2.const 2).mul
    (((PolynomialGrowth2.const (128*b^2)).mul
      ((PolynomialGrowth2.left.add PolynomialGrowth2.right).add (PolynomialGrowth2.const 4))).pow H)

theorem activationBaseBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationBaseBudget b d K H) := by
  unfold activationBaseBudget
  exact ((((PolynomialGrowth2.const (128+b)).add
    ((PolynomialGrowth2.const 512).mul PolynomialGrowth2.right)).add
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 2))).add
    (((PolynomialGrowth2.const 2).mul (activationDiagonalBudget_polynomial b H)).mul
      (PolynomialGrowth2.left.add (PolynomialGrowth2.const 4)))).add (PolynomialGrowth2.const 1)

theorem activationMaxBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationMaxBudget b d K H) :=
  activationPrecisionGrow_polynomial (activationBaseBudget_polynomial b H) H

theorem activationLearnerThreshold_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationLearnerThreshold b d K H) :=
  (activationMaxBudget_polynomial b H).pow 84

theorem activationFiniteWidth_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationFiniteWidth b d K H) :=
  (PolynomialGrowth2.left.add (PolynomialGrowth2.const 2)).add
    ((PolynomialGrowth2.const 2).mul ((activationMaxBudget_polynomial b H).pow 48))

theorem activationSourceBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationSourceBudget b d K H) :=
  (((PolynomialGrowth2.const 4).mul ((activationMaxBudget_polynomial b H).pow 36)).add
    (((PolynomialGrowth2.const 4).mul ((activationMaxBudget_polynomial b H).pow 48)).mul
      ((activationFiniteWidth_polynomial b H).add (PolynomialGrowth2.const 1)))).add
    (PolynomialGrowth2.const 4)

theorem activationRowBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationRowBudget b d K H) :=
  ((PolynomialGrowth2.const 2).add ((PolynomialGrowth2.const 56).mul PolynomialGrowth2.right)).mul
    ((activationSourceBudget_polynomial b H).add ((activationMaxBudget_polynomial b H).pow 10))

theorem activationStateBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationStateBudget b d K H) :=
  ((PolynomialGrowth2.const 1).add
    (((PolynomialGrowth2.const b).mul (activationFiniteWidth_polynomial b H)).mul
      (activationRowBudget_polynomial b H))).pow (3^H)

theorem activationRawBudget_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationRawBudget b d K H) :=
  ((PolynomialGrowth2.const 1).add
    (((activationFiniteWidth_polynomial b H).pow 2).mul
      (((activationRowBudget_polynomial b H).mul (activationStateBudget_polynomial b H)).pow 2))).add
    ((activationFiniteWidth_polynomial b H).mul
      (((((PolynomialGrowth2.const 32).mul PolynomialGrowth2.right).mul
        ((PolynomialGrowth2.const 1).add ((PolynomialGrowth2.const 56).mul PolynomialGrowth2.right))).mul
        (activationStateBudget_polynomial b H)).pow 2))

end NeuralGeneralization.BatchTwoActivation
