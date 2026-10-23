import NeuralGeneralization.RobustCompressionParameters
import NeuralGeneralization.RankOneGrowthConstants
import NeuralGeneralization.RudelsonFiniteRestriction
import Mathlib.Data.Nat.Sqrt
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-! Explicit sharp compression resources. A single universal integer is used
for the finite-matrix concentration constant; its size affects no exponent. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedResources
open ConcreteModel
abbrev Input := RobustCompressionInput

def inverseError (p : Input) : ℕ := 10000*(p.depth+1)*(p.inverseFailure+1)*(p.inverseRadius+1)^2

def inverseFailure (p : Input) : ℕ := 100*(p.depth+1)*(p.inverseFailure+1)

def selectionError (p : Input) : ℝ := ((inverseError p:ℝ)⁻¹)^((3:ℝ)⁻¹)

def rank (p : Input) : ℕ := 2*(p.energy+1)*inverseFailure p*inverseError p+1

def logEnvelope (p : Input) : ℕ := 1+p.dimension+p.depth+(p.energy+1)+inverseFailure p+
  p.inverseRadius+Nat.sqrt (inverseError p)

def readoutMoment (p : Input) : ℕ := (8*(p.energy+1)+2)*inverseFailure p

def bankSize (p : Input) : ℕ := 2^256*((p.energy+rank p+1)*inverseError p+
  rank p*(inverseFailure p)^2*logEnvelope p+
  readoutMoment p*inverseFailure p*(p.inverseRadius+1)^2)+1

def widthBound (p : Input) : ℕ := bankSize p+2*(p.depth+1)*(p.dimension+1)*(rank p+1)+1

def firstSquared (p : Input) : ℕ := 4*(4*p.energy+2*(p.dimension+1))*inverseError p

def activeSquared (p : Input) : ℕ := 16*(8*p.energy+2*rank p)*inverseError p

def gaussianSquared (p : Input) : ℕ := 512*bankSize p*inverseError p

def readoutClip (p : Input) : ℕ := 16*readoutMoment p*(p.inverseRadius+1)

def smallSquared (p : Input) : ℕ :=
  4*(4*widthBound p*p.energy+2*robustParameterCount p.dimension (widthBound p) (p.depth-2))*(p.inverseFailure+1)

def weightBound (p : Input) : ℕ := Nat.sqrt (smallSquared p)+Nat.sqrt (firstSquared p)+
  2*(Nat.sqrt (activeSquared p)+1)*(rank p+1)+2*(Nat.sqrt (gaussianSquared p)+1)+readoutClip p+4

theorem inverseError_pos (p : Input) : 0 < inverseError p := by unfold inverseError; positivity

theorem inverseFailure_pos (p : Input) : 0 < inverseFailure p := by unfold inverseFailure; positivity

theorem rank_pos (p : Input) : 0<rank p := by unfold rank; omega

theorem bankSize_pos (p : Input) : 0<bankSize p := by unfold bankSize; omega

theorem widthBound_pos (p : Input) : 0<widthBound p := by unfold widthBound; omega

theorem logEnvelope_pos (p : Input) : 0<logEnvelope p := by unfold logEnvelope; omega

theorem selectionError_pos (p : Input) : 0<selectionError p := by
  unfold selectionError
  exact Real.rpow_pos_of_pos (inv_pos.mpr (Nat.cast_pos.mpr (inverseError_pos p))) _

theorem selectionError_cube (p : Input) : (selectionError p)^3=(inverseError p:ℝ)⁻¹ := by
  exact Real.rpow_inv_natCast_pow (by positivity) (by decide : (3:ℕ)≠0)

theorem rank_allocation (p : Input) :
    2*(p.energy:ℝ)≤(inverseFailure p:ℝ)⁻¹*(selectionError p)^3*rank p := by
  rw [selectionError_cube]
  have hE : (inverseError p:ℝ)≠0 := (Nat.cast_pos.mpr (inverseError_pos p)).ne'
  have hH : (inverseFailure p:ℝ)≠0 := (Nat.cast_pos.mpr (inverseFailure_pos p)).ne'
  have he : (inverseFailure p:ℝ)⁻¹*(inverseError p:ℝ)⁻¹*rank p=
      2*(p.energy+1)+1/((inverseFailure p:ℝ)*(inverseError p:ℝ)) := by
    simp only [rank,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one]
    field_simp
  rw [he]
  have hp : 0≤1/((inverseFailure p:ℝ)*(inverseError p:ℝ)) := by positivity
  linarith

theorem error_le_logEnvelope_sq (p : Input) : inverseError p≤(logEnvelope p)^2 := by
  have h := Nat.lt_succ_sqrt' (inverseError p)
  have hs : Nat.sqrt (inverseError p)+1≤logEnvelope p := by unfold logEnvelope; omega
  exact h.le.trans (Nat.pow_le_pow_left hs 2)

theorem basic_logEnvelope_bounds (p : Input) :
    1≤logEnvelope p ∧ p.energy+1≤logEnvelope p ∧ inverseFailure p≤logEnvelope p ∧
      p.inverseRadius+1≤logEnvelope p := by unfold logEnvelope; omega

theorem rank_le_logEnvelope (p : Input) : rank p≤3*(logEnvelope p)^4 := by
  obtain ⟨hT,hK,hH,hR⟩ := basic_logEnvelope_bounds p
  have he := error_le_logEnvelope_sq p
  have h := Nat.mul_le_mul (Nat.mul_le_mul (Nat.mul_le_mul_left 2 hK) hH) he
  have hT4 : 1≤(logEnvelope p)^4 := Nat.one_le_pow _ _ hT
  unfold rank
  calc
    _ ≤ 2*logEnvelope p*logEnvelope p*(logEnvelope p)^2+1 := Nat.add_le_add_right h 1
    _ = 2*(logEnvelope p)^4+1 := by ring
    _ ≤ _ := by omega

theorem readoutMoment_le_logEnvelope (p : Input) : readoutMoment p≤10*(logEnvelope p)^2 := by
  obtain ⟨hT,hK,hH,hR⟩ := basic_logEnvelope_bounds p
  have hfirst : 8*(p.energy+1)+2≤10*logEnvelope p := by omega
  calc
    _ ≤ (10*logEnvelope p)*logEnvelope p := Nat.mul_le_mul hfirst hH
    _ = _ := by ring

end NeuralGeneralization.BatchTwoImprovedResources
