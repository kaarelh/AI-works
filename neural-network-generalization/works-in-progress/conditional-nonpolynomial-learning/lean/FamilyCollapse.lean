import AnalyticCeiling
import FiniteReductionCircuits
import TeacherFamilies
import ThresholdToBoolean
import FamilyResources
import CircuitFamilies

/-!
# The family-level complexity reduction

This module proves the reusable reduction with the analytic posterior ceiling
as an explicit premise. `ClosedConditionalImpossibility.lean` supplies its proved
analytic input and the closed main theorem.
-/

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial
open NeuralGeneralization.ConcreteModel

theorem finite_circuit_of_ceiling (b : CeilingConstants) (hceil : CeilingAt b)
    (T : CanonicalSchedule) {d n r C N : ℕ} (hd : 1 ≤ d) (hn : 1 ≤ n) (hr : 1 ≤ r)
    (hpad : b.padding * Nat.log2 (ceilingResource d n r) ≤ r+2)
    (hwidth : ceilingWidth b d n r ≤ N) (hCN : C ≤ N)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hsuccess : ∀ D : InputLaw d,
      0 < successProbability (r := r) (N := N) (n := n) T f D) :
    ∃ c : ThresholdCircuit d,
      c.size ≤ (400*(d+1))*((ceilingResource d n r)^b.circuit+1)+1 ∧
      c.depth ≤ b.circuit * Nat.log2 (ceilingResource d n r)+1 ∧ c.eval = f := by
  obtain ⟨gs,hgs,hvote⟩ := exact_majority_of_ceiling b hceil T hd hn hr hpad hwidth hCN f hf hsuccess
  exact compile_exact_majority f gs hvote _ _ hgs

/-- Explicit polynomial size accounting after adding the majority gate. -/
theorem majority_size_polynomial {d R B e K S : ℕ}
    (hR : R ≤ B*(d+2)^e)
    (hS : S ≤ (400*(d+1))*(R^K+1)+1) :
    S ≤ (400*(B^K+1)+1)*(d+2)^(e*K+1) := by
  have hpow : R^K ≤ B^K*(d+2)^(e*K) := by
    simpa only [Nat.mul_pow, ← Nat.pow_mul] using Nat.pow_le_pow_left hR K
  have hbase : 1 ≤ (d+2)^(e*K) := Nat.one_le_pow _ _ (by omega)
  have hlarge : 1 ≤ (d+2)^(e*K+1) := Nat.one_le_pow _ _ (by omega)
  have hsum : R^K+1 ≤ (B^K+1)*(d+2)^(e*K) := by nlinarith
  calc
    S ≤ (400*(d+1))*(R^K+1)+1 := hS
    _ ≤ (400*(d+2))*((B^K+1)*(d+2)^(e*K))+1 := by
      exact Nat.add_le_add_right
        (Nat.mul_le_mul (by omega) hsum) 1
    _ ≤ (400*(B^K+1)+1)*(d+2)^(e*K+1) := by
      rw [pow_succ]
      nlinarith

theorem majority_depth_logarithmic {d R B K D : ℕ}
    (hR : Nat.log2 R ≤ B*Nat.log2 (d+2))
    (hD : D ≤ K*Nat.log2 R+1) :
    D ≤ (K*B+1)*Nat.log2 (d+2) := by
  have hbase : 1 ≤ Nat.log2 (d+2) := by
    exact Nat.le_log2 (by omega) |>.mpr (by omega)
  have := Nat.mul_le_mul_left K hR
  nlinarith

/-- The full complexity-family implication from the analytic ceiling, which is
proved separately in the final assembly. All subsequent probability, circuit,
teacher and asymptotic resource steps are verified here and in imported modules. -/
theorem PPoly_subset_TC1_of_ceiling (hceiling : AnalyticPosteriorCeiling)
    (T : CanonicalSchedule) (hlearn : UniversalPolynomialGuarantee T) :
    PPoly ⊆ TC1 := by
  rcases hceiling with ⟨b,hceil⟩
  rcases hlearn with ⟨A,hA,k,hlearn⟩
  obtain ⟨A0,hA0⟩ := exists_nat_ge A
  have hA0pos : 0 < A0 := by exact_mod_cast (lt_of_lt_of_le hA hA0)
  intro f hf
  obtain ⟨D,e,hteacher⟩ := PPoly_has_polynomial_teachers hf
  let B := (A0+2)*(D+1)^(k+1)
  let m := e*(k+1)
  let Z := Nat.log2 B+1+2*m
  let d0 := 2^(b.padding*Z+4)
  apply mem_TC1_of_PPoly_eventually f hf
  refine ⟨400*(B^b.circuit+1)+1,m*b.circuit+1,b.circuit*Z+1,d0,?_⟩
  intro d hd0
  have hd : 1 ≤ d := (Nat.one_le_pow _ _ (by omega : 1 ≤ (2:ℕ))).trans hd0
  obtain ⟨C,r,hr,hdL,hresources,hreal⟩ := hteacher d
  let S := d+C+(r+2)+1
  let n := A0*S^k
  have hSpos : 0 < S := by dsimp [S]; omega
  have hn : 1 ≤ n := Nat.succ_le_iff.mpr (Nat.mul_pos hA0pos (Nat.pow_pos hSpos))
  have hR : ceilingResource d n r ≤ B*(d+2)^m := by
    exact FamilyResources.resource_bound d C r A0 k D e hresources
  have hpad : b.padding*Nat.log2 (ceilingResource d n r) ≤ r+2 :=
    (FamilyResources.polynomial_padding b.padding B m d (ceilingResource d n r)
      hd0 hR).trans hdL
  let N := max C (ceilingWidth b d n r)
  have hCN : C ≤ N := le_max_left _ _
  have hwidth : ceilingWidth b d n r ≤ N := le_max_right _ _
  have hsamp : sampleEnvelope A k d C r ≤ (n:ℝ) := by
    have hpow : (0:ℝ) ≤ (S:ℝ)^k := pow_nonneg (Nat.cast_nonneg S) k
    have hm := mul_le_mul_of_nonneg_right hA0 hpow
    simpa only [sampleEnvelope, n, S, Nat.cast_mul, Nat.cast_pow, Nat.cast_add,
      Nat.cast_one, Nat.cast_ofNat, add_comm, add_left_comm, add_assoc] using hm
  have hsuccess : ∀ law : InputLaw d,
      0 < successProbability (r := r) (N := N) (n := n) T (f d) law := by
    intro law
    exact lt_of_lt_of_le (by norm_num : (0:ℝ)<1/2)
      (hlearn d hd r hr (f d) C hreal N hCN law n hsamp)
  obtain ⟨c,hs,hdep,heval⟩ := circuit_of_ceiling b hceil T hd hn hr hpad hwidth hCN
    (f d) hreal hsuccess
  refine ⟨c, majority_size_polynomial hR hs, ?_, heval⟩
  exact majority_depth_logarithmic
    (FamilyResources.polynomial_log2_bound B m d (ceilingResource d n r) hR) hdep

/-- The concrete main statement follows from the analytic ceiling. This
reusable reduction is instantiated without an extra premise by
`conditionalImpossibility` in `ClosedConditionalImpossibility.lean`. -/
theorem conditionalImpossibility_of_posteriorCeiling
    (hceiling : AnalyticPosteriorCeiling) : ConditionalImpossibility := by
  intro hsep T hlearn
  apply hsep
  exact Set.Subset.antisymm (PPoly_subset_TC1_of_ceiling hceiling T hlearn) TC1_subset_PPoly

/-- The same conditional reduction with every polynomial's concrete neural
counterexample spelled out, rather than expressed as a negated guarantee. -/
theorem conditionalCounterexamples_of_posteriorCeiling
    (hceiling : AnalyticPosteriorCeiling) : ConditionalCounterexamples :=
  conditional_statement_iff.mp (conditionalImpossibility_of_posteriorCeiling hceiling)

#print axioms PPoly_subset_TC1_of_ceiling
#print axioms conditionalImpossibility_of_posteriorCeiling
#print axioms conditionalCounterexamples_of_posteriorCeiling

end ConditionalNonpolynomial
