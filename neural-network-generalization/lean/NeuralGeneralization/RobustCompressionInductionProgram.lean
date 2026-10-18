import NeuralGeneralization.RobustCompressionInductionLaw

/-! # Depth recursion of the actual canonical state laws

A program records the finite-message and ordinary-network reconstruction
kernels selected at each depth. It contains no test input. Executing it consumes
one actual original Gaussian block at a time and retains the entire remaining
future. The probability and entropy invariants are proved by depth induction.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy

universe u
variable (d N m : ℕ) (J : Type u) [MeasurableSpace J]

structure CanonicalStateLaw (s r : ℕ) where
  law : Measure (ActivePrefix d N m s × FutureWeights N r)
  probability : IsProbabilityMeasure law
attribute [instance] CanonicalStateLaw.probability

structure CanonicalTransition (s r : ℕ) where
  message : Kernel ((ActivePrefix d N m s × InternalBlock N) × FutureWeights N r) J
  message_markov : IsMarkovKernel message
  reconstruct : Kernel ((ActivePrefix d N m s × InternalBlock N) × J)
    (ActivePrefix d N m (s+1))
  reconstruct_markov : IsMarkovKernel reconstruct
attribute [instance] CanonicalTransition.message_markov CanonicalTransition.reconstruct_markov

def CanonicalTransition.next {s r : ℕ} (T : CanonicalTransition d N m J s r)
    (Q : CanonicalStateLaw d N m s (r+1)) : CanonicalStateLaw d N m (s+1) r where
  law := canonicalStepLaw Q.law T.message T.reconstruct
  probability := inferInstance

/-- Start stage, number of remaining blocks, and final stage are indexed
separately, avoiding any transport of measures through arithmetic equalities. -/
inductive CanonicalProgram : ℕ → ℕ → ℕ → Type u
  | nil (s : ℕ) : CanonicalProgram s 0 s
  | cons {s r k : ℕ} (step : CanonicalTransition d N m J s r)
      (tail : CanonicalProgram (s+1) r k) : CanonicalProgram s (r+1) k

namespace CanonicalProgram
variable {d N m J}

def run {s r k : ℕ} (P : CanonicalProgram d N m J s r k)
    (Q : CanonicalStateLaw d N m s r) : CanonicalStateLaw d N m k 0 :=
  match P with
  | .nil _ => Q
  | .cons step tail => tail.run (CanonicalTransition.next d N m J step Q)

theorem final_stage {s r k : ℕ} (P : CanonicalProgram d N m J s r k) : k=s+r := by
  induction P with
  | nil s => simp
  | @cons s r k step tail ih => omega

variable [Fintype J] [Nonempty J] [MeasurableSingletonClass J] [StandardBorelSpace J]

theorem futureEntropy_run_le {s r k : ℕ} (P : CanonicalProgram d N m J s r k)
    (Q : CanonicalStateLaw d N m s r) :
    futureEntropy (P.run Q).law (futurePrior N 0) ≤
      futureEntropy Q.law (futurePrior N r) +
        r • ENNReal.ofReal (Real.log (Fintype.card J)) := by
  induction P with
  | nil s => simp [run]
  | @cons s r k step tail ih =>
    have ht := ih (CanonicalTransition.next d N m J step Q)
    have hs := canonicalStepLaw_futureEntropy_le Q.law step.message step.reconstruct
    refine ht.trans ?_
    change futureEntropy (canonicalStepLaw Q.law step.message step.reconstruct)
      (futurePrior N r) + r • _ ≤ _
    calc
      _ ≤ (futureEntropy Q.law (futurePrior N (r+1)) +
        ENNReal.ofReal (Real.log (Fintype.card J))) + r • _ := add_le_add hs le_rfl
      _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl

end CanonicalProgram
end NeuralGeneralization.RobustCompressionInduction
