import PhysicalCanonicalProgramState

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

/-- Actual finite-path canonical-program construction. The original controlled
path stays separate. Only its anchor block is preserved at every layer; the
program's full query-query kernel is not identified with the path's kernel.
Each program step carries a genuine Gaussian-coordinate control and exact
canonical evaluation, with its original per-layer action bound. -/
theorem physical_canonical_anchor_program {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) :
    ∃states : ℕ → CanonicalProgramState d,
      (states 0).Index=Fin (d+1) ∧
      (∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
        inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) ∧
      (∀j≤H,(states j).physicalAnchorInvariant P S j) ∧
      (∀j≤H,(states j).dimension≤d+1+j*(S.card+1)) ∧
      ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1)) := by
  classical
  let initial : CanonicalProgramState d :=
    { Index := Fin (d+1), feature := normalizedInputFeature d }
  let State := fun n => {B : CanonicalProgramState d // n≤H →
    B.physicalAnchorInvariant P S n ∧ B.dimension≤d+1+n*(S.card+1)}
  have hstep : ∀n,n<H → ∀s:State n, ∃s':State (n+1),
      PhysicalCanonicalProgramStep P S n s.val s'.val := by
    intro n hn s
    have hgood := s.property (Nat.le_of_lt hn)
    obtain ⟨C,hCstep,hCanchor,hCdim⟩ := physical_canonical_program_step_exists P S n hn s.val hgood.1
    have hdim : C.dimension≤d+1+(n+1)*(S.card+1) := by
      have hb := hgood.2
      simp only [Nat.add_mul,Nat.one_mul]
      omega
    exact ⟨⟨C,fun _ => ⟨hCanchor,hdim⟩⟩,hCstep⟩
  let step := fun n (s:State n) => if hn:n<H then Classical.choose (hstep n hn s)
    else (⟨initial,by intro h; omega⟩ : State (n+1))
  have step_spec (n:ℕ) (hn:n<H) (s:State n) :
      PhysicalCanonicalProgramStep P S n s.val (step n s).val := by
    simpa only [step,dif_pos hn] using Classical.choose_spec (hstep n hn s)
  let s0 : State 0 := ⟨initial,by
    intro _
    constructor
    · intro x hx y hy
      exact (P.initial x y).symm
    · simp only [CanonicalProgramState.dimension,initial,Fintype.card_fin,Nat.zero_mul,Nat.add_zero,le_refl]⟩
  let states : (n:ℕ) → State n := fun n => Nat.rec s0 (fun n s => step n s) n
  refine ⟨fun n => (states n).val,rfl,?_,?_,?_,?_⟩
  · intro x y
    rfl
  · intro j hj
    exact ((states j).property hj).1
  · intro j hj
    exact ((states j).property hj).2
  · intro j hj
    exact step_spec j hj (states j)

#print axioms physical_canonical_anchor_program
end ConditionalNonpolynomial.Analytic
