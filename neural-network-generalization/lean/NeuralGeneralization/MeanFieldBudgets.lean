import NeuralGeneralization.BackwardBudgets
import NeuralGeneralization.PolynomialGrowth
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Explicit polynomial backward budgets at the mean-field endpoint

There are `r+1` hidden layers. Actual tilt index `j : Fin (r+1)` uses
`layerBudget r K (j+1)`. The auxiliary index zero closes the backward
recurrence without an exceptional first-layer case.
-/

namespace NeuralGeneralization.MeanFieldBudgets

def grow (B : ℕ) : ℕ → ℕ
  | 0 => B
  | n+1 => 8 * grow B n * (1 + grow B n)^2

def baseBudget (r K : ℕ) : ℕ := 32 * (r+1) * K^2

def layerBudget (r K s : ℕ) : ℕ := grow (baseBudget r K) ((r+1)-s)

def maxTiltBudget (r K : ℕ) : ℕ := grow (baseBudget r K) r

def sparseCount (r K : ℕ) : ℕ := (maxTiltBudget r K)^2 + 1

def empiricalWidthThreshold (d r K : ℕ) : ℕ := 8*d*sparseCount r K+1

/-- Inverse covariance precision used by the actual finite tower. -/
def towerPrecision (r K : ℕ) : ℕ :=
  32*K*(r+1)*(8*(1+maxTiltBudget r K)^2)^r

theorem grow_pos {B : ℕ} (hB : 0 < B) (n : ℕ) : 0 < grow B n := by
  induction n with
  | zero => exact hB
  | succ n ih => simp only [grow]; positivity

theorem grow_mono (B : ℕ) : Monotone (grow B) := by
  apply monotone_nat_of_le_succ
  intro n
  change grow B n ≤ 8 * grow B n * (1 + grow B n)^2
  have hh : 1 ≤ (1 + grow B n)^2 := one_le_pow₀ (by omega)
  nlinarith

theorem layerBudget_pos (r : ℕ) {K : ℕ} (hK : 0 < K) (s : ℕ) :
    0 < layerBudget r K s := by
  exact grow_pos (by unfold baseBudget; positivity) _

theorem maxTiltBudget_pos (r : ℕ) {K : ℕ} (hK : 0 < K) :
    0 < maxTiltBudget r K := by
  exact grow_pos (by unfold baseBudget; positivity) _

theorem layerBudget_terminal (r K : ℕ) :
    layerBudget r K (r+1) = 32*(r+1)*K^2 := by
  simp [layerBudget, grow, baseBudget]

theorem layerBudget_backward {r K s : ℕ} (hs : s < r+1) :
    layerBudget r K s =
      8*(1+layerBudget r K (s+1))^2*layerBudget r K (s+1) := by
  have hsub : (r+1)-s = ((r+1)-(s+1))+1 := by omega
  unfold layerBudget
  rw [hsub, grow]
  ring

theorem layerBudget_le_max (r K : ℕ) {s : ℕ} (hs : 1 ≤ s) :
    layerBudget r K s ≤ maxTiltBudget r K := by
  apply grow_mono
  omega

theorem layerBudget_antitone (r K : ℕ) : Antitone (layerBudget r K) := by
  intro s t hst
  apply grow_mono
  omega

theorem sparseCount_pos (r K : ℕ) : 0 < sparseCount r K := by
  unfold sparseCount
  omega

theorem layerBudget_sq_le_twice_sparseCount (r K : ℕ) {s : ℕ} (hs : 1 ≤ s) :
    (layerBudget r K s : ℝ)^2 ≤ 2*(sparseCount r K : ℝ) := by
  have hnat : (layerBudget r K s)^2 ≤ (maxTiltBudget r K)^2 :=
    Nat.pow_le_pow_left (layerBudget_le_max r K hs) 2
  have hh : (layerBudget r K s)^2 ≤ 2*sparseCount r K := by
    unfold sparseCount
    omega
  exact_mod_cast hh

/-- The integer width threshold absorbs the covariance-test prefactor at
all `K≥4`, with room to spare. -/
theorem empiricalWidthThreshold_entropy {d r K N : ℕ}
    (hK : 4 ≤ K) (hN : empiricalWidthThreshold d r K ≤ N) :
    4*(d : ℝ)*(sparseCount r K : ℝ) ≤ (N : ℝ)*((K : ℝ)-1)/2 := by
  have hNR : (8*d*sparseCount r K+1 : ℕ) ≤ N := hN
  have hNR' : 8*(d : ℝ)*(sparseCount r K : ℝ)+1 ≤ (N : ℝ) := by exact_mod_cast hNR
  have hKR : (4 : ℝ) ≤ K := by exact_mod_cast hK
  have hN0 : (0 : ℝ) ≤ N := Nat.cast_nonneg N
  nlinarith

/-- Specializing the proved recurrence gives the terminal covariance error
required by the readout margin argument. -/
theorem terminal_error_bound {r K : ℕ} (hK : 0 < K)
    (error : ℕ → ℝ) (hzero : error 0 = 0)
    (hstep : ∀ s, s < r+1 → error (s+1) ≤
      (K : ℝ)/(layerBudget r K (s+1) : ℝ) +
      8*(1+(layerBudget r K (s+1) : ℝ))^2*error s) :
    error (r+1) ≤ 1/(32*(K : ℝ)) := by
  apply BackwardBudgets.terminal_error_bound error
    (fun s => (layerBudget r K s : ℝ))
    (fun s => 8*(1+(layerBudget r K s : ℝ))^2) (K : ℝ) (r+1)
    (by exact_mod_cast hK) (by omega) hzero
    (fun s _ => by exact_mod_cast layerBudget_pos r hK s)
    (fun s hs => by exact_mod_cast layerBudget_backward (K := K) hs) hstep
  rw [layerBudget_terminal]
  push_cast
  rfl

theorem towerPrecision_pos (r : ℕ) {K : ℕ} (hK : 0 < K) :
    0 < towerPrecision r K := by
  unfold towerPrecision
  positivity

/-- Exact covariance precision; the finite network can use `η=1/E`. -/
theorem towerPrecision_error (r : ℕ) {K : ℕ} (hK : 0 < K) :
    ((r : ℝ)+1)*(8*(1+(maxTiltBudget r K : ℝ))^2)^r*
      (1/(towerPrecision r K : ℝ)) = 1/(32*(K : ℝ)) := by
  have hKR : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have hr : ((r : ℝ)+1) ≠ 0 := by positivity
  have hg : 8*(1+(maxTiltBudget r K : ℝ))^2 ≠ 0 := by positivity
  unfold towerPrecision
  push_cast
  field_simp

/-- Any fixed number of cubic budget expansions preserves polynomial growth. -/
theorem grow_polynomialGrowth {B : ℕ → ℕ → ℕ} (hB : PolynomialGrowth2 B) (n : ℕ) :
    PolynomialGrowth2 (fun d K => grow (B d K) n) := by
  induction n with
  | zero => exact hB
  | succ n ih =>
    simp only [grow]
    exact ((PolynomialGrowth2.const 8).mul ih).mul
      (((PolynomialGrowth2.const 1).add ih).pow 2)

theorem maxTiltBudget_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun _ K => maxTiltBudget r K) := by
  unfold maxTiltBudget baseBudget
  exact grow_polynomialGrowth
    ((PolynomialGrowth2.const (32*(r+1))).mul (PolynomialGrowth2.right.pow 2)) r

theorem sparseCount_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun _ K => sparseCount r K) := by
  unfold sparseCount
  exact ((maxTiltBudget_polynomialGrowth r).pow 2).add (PolynomialGrowth2.const 1)

theorem empiricalWidthThreshold_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d K => empiricalWidthThreshold d r K) := by
  unfold empiricalWidthThreshold
  exact (((PolynomialGrowth2.const 8).mul PolynomialGrowth2.left).mul
    (sparseCount_polynomialGrowth r)).add (PolynomialGrowth2.const 1)

theorem towerPrecision_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun _ K => towerPrecision r K) := by
  unfold towerPrecision
  exact (((PolynomialGrowth2.const 32).mul PolynomialGrowth2.right).mul
    (PolynomialGrowth2.const (r+1))).mul
    (((PolynomialGrowth2.const 8).mul
      (((PolynomialGrowth2.const 1).add (maxTiltBudget_polynomialGrowth r)).pow 2)).pow r)

end NeuralGeneralization.MeanFieldBudgets
