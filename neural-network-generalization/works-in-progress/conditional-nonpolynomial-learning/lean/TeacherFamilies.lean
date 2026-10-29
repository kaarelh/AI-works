import Circuits
import TeacherCompilation

/-!
# Polynomial circuit families have polynomial-resource tanh teachers

This is the concrete teacher side of the complexity reduction. It is distinct
from the separately proved actual-posterior circuit ceiling.
-/

noncomputable section

namespace ConditionalNonpolynomial

open NeuralGeneralization.ConcreteModel

/-- Every polynomial-size NAND circuit family has actual tanh teachers with
joint polynomial width, depth, and input-dimension resources. The depth is at
least the input dimension, as needed for subsequent asymptotic padding. -/
theorem PPoly_has_polynomial_teachers {f : Family} (hf : f ∈ PPoly) :
    ∃ A k : ℕ, ∀ d : ℕ, ∃ C r : ℕ,
      1 ≤ r ∧ d ≤ r+2 ∧
      d+C+(r+2)+1 ≤ A*(d+2)^k ∧
      realizesAtComplexity (r := r) Real.tanh (f d) C := by
  rcases hf with ⟨A,k,h⟩
  refine ⟨2*A+300, k+1, ?_⟩
  intro d
  rcases h d with ⟨c,hs,he⟩
  refine ⟨d+c.size+256, c.size+d+1, by omega, by omega, ?_, ?_⟩
  · have hpow : (d+2)^k ≤ (d+2)^(k+1) :=
      Nat.pow_le_pow_right (by omega) (by omega)
    have hbase : d+2 ≤ (d+2)^(k+1) := by
      simpa only [pow_one] using
        (Nat.pow_le_pow_right (by omega : 0 < d+2) (by omega : 1 ≤ k+1))
    have hs' := hs.trans (Nat.mul_le_mul_left A hpow)
    nlinarith
  · simpa only [he] using NandTeacher.realizes_compiled c

#print axioms PPoly_has_polynomial_teachers

end ConditionalNonpolynomial
