import NeuralGeneralization.BatchTwoContinuousScaledCompression
import NeuralGeneralization.FiniteParameterGrid

/-! Explicit finite nets of arbitrary nonempty subsets of the unit ball.
Representatives lie in the domain, so their Euclidean norms remain bounded. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling ParameterGrid

abbrev InputCode (d T : ℕ) := Fin d → GridInt T

theorem inputCode_card (d T : ℕ) : Fintype.card (InputCode d T)=(2*T+1)^d := by
  change Fintype.card (Fin d → GridInt T)=_
  rw [Fintype.card_fun,Fintype.card_fin,gridInt_card]

theorem netDimension_inputCode_le (d T : ℕ) :
    netDimension d (InputCode d T) ≤ d+d*(2*T+1) := by
  unfold netDimension
  rw [inputCode_card]
  apply Nat.add_le_add_left
  apply Nat.clog_le_of_le_pow
  calc
    (2*T+1)^d ≤ (2^(2*T+1))^d := Nat.pow_le_pow_left (Nat.le_of_lt (Nat.lt_two_pow_self)) _
    _ = _ := by rw [← Nat.pow_mul,Nat.mul_comm (2*T+1)]

theorem coord_abs_le_one {d : ℕ} (x : RealInput d) (hx : ∑ i, x i^2 ≤ 1) (i : Fin d) :
    |x i| ≤ 1 := by
  have h := (Finset.single_le_sum (f := fun j => x j^2) (fun _ _ => sq_nonneg _) (Finset.mem_univ i)).trans hx
  exact abs_le_of_sq_le_sq (by simpa using h) (by norm_num)

def inputCell {d T : ℕ} (X : Set (RealInput d)) (q : InputCode d T) : Set (RealInput d) :=
  {x | x ∈ X ∧ ∀ i, |x i-decode T q i| ≤ 1/(T : ℝ)}

def inputRepresentative {d T : ℕ} (X : Set (RealInput d)) (hX : X.Nonempty)
    (q : InputCode d T) : RealInput d := by
  classical
  exact if h : (inputCell X q).Nonempty then h.choose else hX.choose

theorem inputRepresentative_mem {d T : ℕ} (X : Set (RealInput d)) (hX : X.Nonempty)
    (q : InputCode d T) : inputRepresentative X hX q ∈ X := by
  classical
  unfold inputRepresentative
  split_ifs with h
  · exact h.choose_spec.1
  · exact hX.choose_spec

theorem inputRepresentative_close {d T : ℕ} (hT : 0 < T)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x ∈ X, ∑ i, x i^2 ≤ 1)
    (x : RealInput d) (hx : x ∈ X) :
    ∃ q : InputCode d T, ∀ i, |x i-inputRepresentative X hX q i| ≤ 2/(T : ℝ) := by
  classical
  obtain ⟨q,hq⟩ := exists_close_grid T hT x (coord_abs_le_one x (hball x hx))
  have hcell : (inputCell X q).Nonempty := ⟨x,hx,hq⟩
  refine ⟨q,?_⟩
  intro i
  have hrep : |inputRepresentative X hX q i-decode T q i| ≤ 1/(T : ℝ) := by
    simpa only [inputRepresentative,dif_pos hcell] using hcell.choose_spec.2 i
  have ht := abs_sub_le (x i) (decode T q i) (inputRepresentative X hX q i)
  rw [abs_sub_comm (decode T q i)] at ht
  have hid : 2/(T : ℝ)=1/(T : ℝ)+1/(T : ℝ) := by ring
  rw [hid]
  linarith [hq i]

end NeuralGeneralization.BatchTwoContinuous
