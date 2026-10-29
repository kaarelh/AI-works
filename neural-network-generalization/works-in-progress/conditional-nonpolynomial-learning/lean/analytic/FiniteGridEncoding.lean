import ScalarRounding
import NeuralGeneralization.FiniteParameterGrid
import Mathlib.Data.Fintype.EquivFin

/-! A finite scalar grid represented by actual integer numerators. The code
uses one-hot indices; its cardinality and rounding error are proved. -/
noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ParameterGrid

abbrev ScalarGrid (Q N : ℕ) := GridInt (Q*N+1)
abbrev ScalarCode (Q N : ℕ) := Fin (Fintype.card (ScalarGrid Q N))

def scalarNumerator (Q N : ℕ) (i : ScalarCode Q N) : ℤ :=
  ((Fintype.equivFin (ScalarGrid Q N)).symm i).val

def scalarDecode (Q N : ℕ) (i : ScalarCode Q N) : ℝ := (scalarNumerator Q N i:ℝ)/Q

lemma round_mem_scalarGrid (Q N : ℕ) (x : ℝ) (hx : |x| ≤ (N:ℝ)) :
    round ((Q:ℝ)*x) ∈ Finset.Icc (-((Q*N+1:ℕ):ℤ)) ((Q*N+1:ℕ):ℤ) := by
  have h := gridRound_numerator_bound Q x N hx
  have hl : -((Q*N+1:ℕ):ℝ) ≤ (round ((Q:ℝ)*x):ℝ) := by
    have hh := (abs_le.mp h).1
    push_cast
    linarith
  have hu : (round ((Q:ℝ)*x):ℝ) ≤ ((Q*N+1:ℕ):ℝ) := by
    have hh := (abs_le.mp h).2
    push_cast
    linarith
  apply Finset.mem_Icc.mpr
  constructor
  · exact_mod_cast hl
  · exact_mod_cast hu

def scalarEncode (Q N : ℕ) (x : ℝ) : ScalarCode Q N :=
  Fintype.equivFin (ScalarGrid Q N) (if hx : |x| ≤ (N:ℝ)
    then ⟨round ((Q:ℝ)*x),round_mem_scalarGrid Q N x hx⟩ else ⟨0,by apply Finset.mem_Icc.mpr; constructor <;> omega⟩)

@[simp] theorem scalarDecode_encode (Q N : ℕ) (x : ℝ) (hx : |x| ≤ (N:ℝ)) :
    scalarDecode Q N (scalarEncode Q N x) = gridRound Q x := by
  simp [scalarDecode, scalarNumerator, scalarEncode, hx, gridRound]

theorem scalarEncode_error (Q N : ℕ) (hQ : 0 < Q) (x : ℝ) (hx : |x| ≤ (N:ℝ)) :
    |x-scalarDecode Q N (scalarEncode Q N x)| ≤ 1/(2*(Q:ℝ)) := by
  rw [scalarDecode_encode Q N x hx]
  exact gridRound_error Q hQ x

@[simp] theorem scalarGrid_card (Q N : ℕ) : Fintype.card (ScalarGrid Q N) = 2*(Q*N+1)+1 :=
  gridInt_card _

theorem scalarNumerator_bound (Q N : ℕ) (i : ScalarCode Q N) :
    (scalarNumerator Q N i).natAbs ≤ Q*N+1 := by
  have h := ((Fintype.equivFin (ScalarGrid Q N)).symm i).property
  have hh : |scalarNumerator Q N i| ≤ ((Q*N+1:ℕ):ℤ) := abs_le.mpr (Finset.mem_Icc.mp h)
  rw [← Int.natCast_natAbs] at hh
  exact_mod_cast hh

#print axioms scalarEncode_error
#print axioms scalarNumerator_bound
end ConditionalNonpolynomial.Analytic
