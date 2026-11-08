import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.Data.Nat.Choose.Central
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith

noncomputable section
namespace NeuralGeneralization.OnlineLowerBernstein

/-- Continuous extension of the inverse balanced ReLU parity coefficient. -/
def gammaCost (n : ℝ) : ℝ :=
  2 * Real.sqrt n * Real.Gamma (1/2) * Real.Gamma (n/2) /
    Real.Gamma ((n-1)/2)

/-- The actual central-binomial coefficient at even degree `2k+2`. -/
def evenReluKappa (k : ℕ) : ℝ :=
  (Nat.centralBinom k : ℝ) / 2^(2*k+1)

def balancedReluCost (k : ℕ) : ℝ := Real.sqrt (2*k+2) / evenReluKappa k

theorem gamma_half_centralBinom (k : ℕ) :
    Real.Gamma ((k : ℝ)+1/2) * 4^k =
      Real.Gamma (1/2) * (Nat.centralBinom k : ℝ) * (k.factorial : ℝ) := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hc : ((k:ℝ)+1)*(Nat.centralBinom (k+1):ℝ) =
        2*(2*(k:ℝ)+1)*(Nat.centralBinom k:ℝ) := by
      exact_mod_cast Nat.succ_mul_centralBinom_succ k
    have hg : Real.Gamma ((k:ℝ)+1/2+1) =
        ((k:ℝ)+1/2)*Real.Gamma ((k:ℝ)+1/2) :=
      Real.Gamma_add_one (by positivity)
    rw [Nat.cast_succ,show (k:ℝ)+1+1/2=(k:ℝ)+1/2+1 by ring,hg,pow_succ,
      Nat.factorial_succ,Nat.cast_mul,Nat.cast_succ]
    calc
      _ = 4*((k:ℝ)+1/2)*(Real.Gamma ((k:ℝ)+1/2)*4^k) := by ring
      _ = 4*((k:ℝ)+1/2)*(Real.Gamma (1/2)*(Nat.centralBinom k:ℝ)*(k.factorial:ℝ)) := by rw [ih]
      _ = Real.Gamma (1/2)*(((k:ℝ)+1)*(Nat.centralBinom (k+1):ℝ))*(k.factorial:ℝ) := by rw [hc]; ring
      _ = _ := by ring

theorem gammaCost_even (k : ℕ) : gammaCost (2*(k:ℝ)+2) = balancedReluCost k := by
  have hc : (Nat.centralBinom k : ℝ) ≠ 0 := by exact_mod_cast (Nat.centralBinom_pos k).ne'
  have hf : (k.factorial : ℝ) ≠ 0 := by exact_mod_cast (Nat.factorial_ne_zero k)
  have hg : Real.Gamma ((k:ℝ)+1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by positivity)).ne'
  have gh : Real.Gamma (1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by norm_num)).ne'
  have h := gamma_half_centralBinom k
  unfold gammaCost balancedReluCost evenReluKappa
  rw [show (2*(k:ℝ)+2)/2=(k:ℝ)+1 by ring,
    show (2*(k:ℝ)+2-1)/2=(k:ℝ)+1/2 by ring,Real.Gamma_nat_eq_factorial]
  have hp : (2:ℝ)^(2*k+1)=2*4^k := by rw [pow_succ,pow_mul]; norm_num; ring
  rw [hp]
  field_simp
  rw [show (2*(k:ℝ)+1)/2=(k:ℝ)+1/2 by ring]
  nlinarith [h]


/-- Same identity with the paper's literal even-degree binomial coefficient. -/
theorem gammaCost_nat_even {n : ℕ} (hn : 2 ≤ n) (heven : Even n) :
    gammaCost n = Real.sqrt n /
      ((Nat.choose (n-2) ((n-2)/2) : ℝ) / (2:ℝ)^(n-1)) := by
  obtain ⟨j,hj⟩ := heven
  cases j with
  | zero => simp at hj; omega
  | succ k =>
    have hn' : n=2*k+2 := by omega
    rw [hn']
    have h := gammaCost_even k
    simpa [balancedReluCost,evenReluKappa,Nat.centralBinom_eq_two_mul_choose,
      show 2*k+2-2=2*k by omega,show 2*k+2-1=2*k+1 by omega] using h

end NeuralGeneralization.OnlineLowerBernstein
