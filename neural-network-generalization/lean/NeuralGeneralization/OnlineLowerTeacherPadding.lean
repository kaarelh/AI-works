import NeuralGeneralization.OnlineLowerTeacherModel
import NeuralGeneralization.OnlineLowerVariationWitness

/-! Exact zero-padding of the specified bounded teacher. No activation
homogeneity, boundedness or zero-at-zero hypothesis is required. -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

theorem BoundedTeacher.mono_width {d C N : ℕ} {φ : ℝ → ℝ}
    {f : BooleanFunction d} (hteacher : BoundedTeacher φ f C) (hCN : C ≤ N) :
    BoundedTeacher φ f N := by
  classical
  obtain ⟨hC, w, hmargin, hbounded⟩ := hteacher
  have hcap : (∑ _j : Fin C, (1 : ℕ)) ≤ N := by simpa using hCN
  let e := allocationEquiv (fun _j : Fin C => 1) hcap
  let v := allocatedWeights (fun _j : Fin C => 1) e (incomingAtoms w) (readoutAtoms w)
  have hout (x : Cube d) : networkOutput φ v x = networkOutput φ w x := by
    rw [networkOutput_allocated _ (fun _ => by norm_num)]
    exact (networkOutput_eq_atomicScore φ w x).symm
  have hCNR : (C : ℝ) ≤ N := by exact_mod_cast hCN
  refine ⟨hC.trans hCN, v, fun x => ?_, ?_⟩
  · simpa only [hout x] using hmargin x
  · intro idx
    cases idx with
    | inl pair =>
      rcases pair with ⟨i, k⟩
      cases hi : e.symm i with
      | inl atom =>
        simpa [v, allocatedWeights, incomingAtoms, hi] using
          (hbounded (.inl (atom.1, k))).trans hCNR
      | inr pad =>
        simpa [v, allocatedWeights, hi] using (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
    | inr other =>
      cases other with
      | inl middle => exact Fin.elim0 middle.1
      | inr i =>
        cases hi : e.symm i with
        | inl atom =>
          simpa [v, allocatedWeights, readoutAtoms, hi] using
            (hbounded (.inr (.inr atom.1))).trans hCNR
        | inr pad =>
          simpa [v, allocatedWeights, hi] using (Nat.cast_nonneg N : (0 : ℝ) ≤ N)

end NeuralGeneralization.OnlineLower
