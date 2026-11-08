import NeuralGeneralization.OnlineLowerTeacher

noncomputable section
namespace NeuralGeneralization.BatchTwoCircuitConverse
open ConcreteModel OnlineLower

namespace Circuit

def xnor {d : ℕ} (c : Circuit d) (a b : Fin c.wires) : Circuit d :=
  let c1 := c.add a b
  let a1 : Fin c1.wires := ⟨a, by simp [c1, Circuit.wires]; omega⟩
  let n1 : Fin c1.wires := ⟨c.wires, by simp [c1, Circuit.wires]⟩
  let c2 := c1.add a1 n1
  let b2 : Fin c2.wires := ⟨b, by simp [c2,c1,Circuit.wires] <;> omega⟩
  let n12 : Fin c2.wires := ⟨c.wires, by simp [c2,c1,Circuit.wires] <;> omega⟩
  let c3 := c2.add b2 n12
  let n2 : Fin c3.wires := ⟨c1.wires, by simp [c3,c2,Circuit.wires] <;> omega⟩
  let n3 : Fin c3.wires := ⟨c2.wires, by simp [c3,Circuit.wires]⟩
  let c4 := c3.add n2 n3
  let n4 : Fin c4.wires := ⟨c3.wires, by simp [c4,Circuit.wires]⟩
  c4.add n4 n4

@[simp] theorem size_xnor {d : ℕ} (c : Circuit d) (a b : Fin c.wires) :
    (c.xnor a b).size = c.size+5 := by simp [xnor]

theorem extends_xnor {d : ℕ} (c : Circuit d) (a b : Fin c.wires) :
    c.Extends (c.xnor a b) := by
  unfold xnor
  exact (c.extends_add _ _).trans ((Circuit.extends_add _ _ _).trans
    ((Circuit.extends_add _ _ _).trans ((Circuit.extends_add _ _ _).trans
      (Circuit.extends_add _ _ _))))

@[simp] theorem eval_xnor {d : ℕ} (c : Circuit d) (a b : Fin c.wires)
    (x : Cube d) :
    (c.xnor a b).eval x = (c.evalWire x a == c.evalWire x b) := by
  have ha := a.isLt
  have hb := b.isLt
  simp (disch := dsimp [Circuit.wires, Circuit.add] at *; omega) only [xnor, Circuit.eval_add,
    Circuit.evalWire_add_new, Circuit.evalWire_add_old]
  cases h1 : c.evalWire x a <;> cases h2 : c.evalWire x b <;> decide


def andWire {d : ℕ} (c : Circuit d) (a b : Fin c.wires) : Circuit d :=
  let c1 := c.add a b
  let n : Fin c1.wires := ⟨c.wires, by simp [c1, Circuit.wires]⟩
  c1.add n n

@[simp] theorem size_andWire {d : ℕ} (c : Circuit d) (a b : Fin c.wires) :
    (c.andWire a b).size = c.size+2 := by simp [andWire]

theorem extends_andWire {d : ℕ} (c : Circuit d) (a b : Fin c.wires) :
    c.Extends (c.andWire a b) :=
  (c.extends_add _ _).trans (Circuit.extends_add _ _ _)

@[simp] theorem eval_andWire {d : ℕ} (c : Circuit d) (a b : Fin c.wires)
    (x : Cube d) :
    (c.andWire a b).eval x = (c.evalWire x a && c.evalWire x b) := by
  simp [andWire]

end Circuit

theorem labelReal_xnor (a b : Bool) :
    labelReal (a == b) = labelReal a * labelReal b := by
  cases a <;> cases b <;> norm_num [labelReal]

theorem labelReal_eq_coordinate (a : Bool) : labelReal a = cubeCoordinateSign a := by
  cases a <;> rfl

theorem labelReal_eq_one_iff (a : Bool) : labelReal a = 1 ↔ a = true := by
  cases a <;> norm_num [labelReal]

/-- Build an actual NAND parity circuit, preserving all previous wires. -/
theorem exists_parity_extension {d : ℕ} (S : Finset (Fin d)) (c : Circuit d) :
    ∃ a : AccCircuit d, c.Extends a.circuit ∧
      a.circuit.size = c.size + 5*S.card ∧
      ∀ x, labelReal (a.eval x) = walshCharacter S x := by
  classical
  induction S using Finset.induction_on generalizing c with
  | empty =>
      refine ⟨⟨c, ⟨d+1, by unfold Circuit.wires; omega⟩⟩,
        Circuit.Extends.refl c, ?_, ?_⟩
      · simp
      · intro x
        simp [AccCircuit.eval, labelReal, walshCharacter]
  | @insert i S hi ih =>
      obtain ⟨a, he, hs, hv⟩ := ih c
      let ii : Fin a.circuit.wires := ⟨i, by unfold Circuit.wires; omega⟩
      let c' := a.circuit.xnor a.wire ii
      refine ⟨⟨c', ⟨c'.outputWire, c'.outputWire_lt⟩⟩,
        he.trans (Circuit.extends_xnor _ _ _), ?_, ?_⟩
      · simp [c', hs, Finset.card_insert_of_notMem hi]
        omega
      · intro x
        change labelReal (c'.eval x) = _
        rw [Circuit.eval_xnor, labelReal_xnor]
        change labelReal (a.eval x) * labelReal (a.circuit.evalWire x i) = _
        rw [hv, Circuit.evalWire_input, labelReal_eq_coordinate]
        simp [walshCharacter, Finset.prod_insert hi, mul_comm]


/-- Conjoin one freshly computed parity to an existing accumulator. -/
theorem exists_and_parity_extension {d : ℕ} (S : Finset (Fin d)) (a : AccCircuit d) :
    ∃ b : AccCircuit d, a.circuit.Extends b.circuit ∧
      b.circuit.size = a.circuit.size + 5*S.card+2 ∧
      ∀ x, b.eval x = (a.eval x && decide (walshCharacter S x = 1)) := by
  classical
  obtain ⟨p, he, hs, hv⟩ := exists_parity_extension S a.circuit
  let aa : Fin p.circuit.wires := ⟨a.wire, by
    have h := a.wire.isLt
    have hh := he.1
    unfold Circuit.wires at *
    omega⟩
  let c := p.circuit.andWire aa p.wire
  refine ⟨⟨c,⟨c.outputWire,c.outputWire_lt⟩⟩,
    he.trans (Circuit.extends_andWire _ _ _), ?_, ?_⟩
  · simp [c,hs]
  · intro x
    change c.eval x = _
    rw [Circuit.eval_andWire]
    change (p.circuit.evalWire x a.wire && p.eval x) = _
    rw [he.2 x a.wire a.wire.isLt]
    have hp : p.eval x = decide (walshCharacter S x = 1) := by
      apply Bool.eq_iff_iff.mpr
      simp only [decide_eq_true_eq]
      rw [←hv x, labelReal_eq_one_iff]
    rw [hp]
    rfl

/-- The sharing in this theorem is literal: old wires remain available, and
only five NAND gates per parity input plus two per conjunction are added. -/
theorem exists_and_parities_extension {d : ℕ} {ι : Type*} [DecidableEq ι]
    (S : Finset ι) (P : ι → Finset (Fin d)) (a : AccCircuit d) :
    ∃ b : AccCircuit d, a.circuit.Extends b.circuit ∧
      b.circuit.size = a.circuit.size + ∑ i ∈ S, (5*(P i).card+2) ∧
      ∀ x, b.eval x = (a.eval x && decide (∀ i ∈ S, walshCharacter (P i) x = 1)) := by
  classical
  induction S using Finset.induction_on generalizing a with
  | empty =>
      exact ⟨a,Circuit.Extends.refl _,by simp,by simp⟩
  | @insert i S hi ih =>
      obtain ⟨b,he,hs,hv⟩ := ih a
      obtain ⟨c,he',hs',hv'⟩ := exists_and_parity_extension (P i) b
      refine ⟨c,he.trans he',?_,?_⟩
      · rw [hs',hs]
        simp [Finset.sum_insert hi]
        omega
      · intro x
        rw [hv',hv]
        simp [Finset.mem_insert, Bool.and_assoc, Bool.and_comm, Bool.and_left_comm]


theorem parityAndTarget_xnor {d m : ℕ} (A0 : Finset (Fin d))
    (A P : Fin m → Finset (Fin d))
    (hchar : ∀ i x, walshCharacter (A i) x =
      walshCharacter A0 x * walshCharacter (P i) x) (x : Cube d) :
    parityAndTarget A0 A x =
      (decide (walshCharacter A0 x = 1) ==
        decide (∀ i, walshCharacter (P i) x = 1)) := by
  classical
  let b := walshCharacter A0 x
  let y : Fin m → ℝ := fun i => walshCharacter (P i) x
  have hb : b^2=1 := walshCharacter_sq _ _
  have hy (i) : (y i)^2=1 := walshCharacter_sq _ _
  have hs : parityAndScore A0 A x = b*((∑ i,y i)-((m:ℝ)-1)) := by
    unfold parityAndScore
    simp_rw [hchar]
    rw [←Finset.mul_sum]
    dsimp [b,y]
    ring
  have hbneg (h : b ≠ 1) : b = -1 := by
    have : (b-1)*(b+1)=0 := by nlinarith
    rcases mul_eq_zero.mp this with hh | hh
    · exact (h (by linarith)).elim
    · linarith
  by_cases hall : ∀ i, y i = 1
  · have hs' : parityAndScore A0 A x = b := by rw [hs]; simp [hall]
    by_cases h : b=1
    · simp [parityAndTarget,hs',h,show (∀ i,walshCharacter (P i) x=1) from hall,b]
    · have hn := hbneg h
      simp only [parityAndTarget,hs',hn]
      norm_num
      norm_num [show walshCharacter A0 x = -1 from hn,
        show (∀ i,walshCharacter (P i) x=1) from hall]
  · have hnall : ¬∀ i,walshCharacter (P i) x=1 := hall
    obtain ⟨j,hj⟩ := not_forall.mp hall
    have hjneg : y j = -1 := by
      have : (y j-1)*(y j+1)=0 := by nlinarith [hy j]
      rcases mul_eq_zero.mp this with hh | hh
      · exact (hj (by linarith)).elim
      · linarith
    have hsum : (∑ i,y i) ≤ (m:ℝ)-2 := by
      calc
        _ ≤ ∑ i:Fin m,(1-2*(if i=j then 1 else 0):ℝ) := by
          apply Finset.sum_le_sum
          intro i hi
          by_cases hh : i=j
          · subst i; norm_num [hjneg]
          · simp [hh]; nlinarith [hy i]
        _ = _ := by rw [Finset.sum_sub_distrib,←Finset.mul_sum]; simp
    by_cases h : b=1
    · have hneg : ¬0≤parityAndScore A0 A x := by rw [hs,h]; linarith
      simp [parityAndTarget,hneg,show walshCharacter A0 x=1 from h,hnall]
    · have hn := hbneg h
      have hpos : 0≤parityAndScore A0 A x := by rw [hs,hn]; linarith
      norm_num [parityAndTarget,hpos,show walshCharacter A0 x=-1 from hn,hnall]

/-- An explicit circuit-size bound for a parity times a conjunction of local
parities. The character identities state how the chosen target supports are
represented by those local parities. -/
theorem parityAnd_hasCircuit {d m : ℕ} (A0 : Finset (Fin d))
    (A P : Fin m → Finset (Fin d))
    (hchar : ∀ i x, walshCharacter (A i) x =
      walshCharacter A0 x * walshCharacter (P i) x) :
    HasCircuitAtMost (parityAndTarget A0 A)
      (5*A0.card + (∑ i, (5*(P i).card+2)) + 5) := by
  classical
  obtain ⟨a,he,hs,hv⟩ := exists_parity_extension A0 (Circuit.empty d)
  let init : AccCircuit d := ⟨a.circuit,⟨d+1,by unfold Circuit.wires; omega⟩⟩
  obtain ⟨b,he',hs',hv'⟩ := exists_and_parities_extension Finset.univ P init
  let aa : Fin b.circuit.wires := ⟨a.wire,by
    have hh := a.wire.isLt
    have hh' := he'.1
    change a.circuit.size ≤ b.circuit.size at hh'
    unfold Circuit.wires at *
    omega⟩
  let c := b.circuit.xnor aa b.wire
  refine ⟨c,?_,?_⟩
  · simp only [c,Circuit.size_xnor,hs']
    change a.circuit.size + (∑ i:Fin m, (5*(P i).card+2)) + 5 ≤ _
    rw [hs]
    simp
  · funext x
    rw [parityAndTarget_xnor A0 A P hchar x]
    rw [Circuit.eval_xnor]
    change (b.circuit.evalWire x a.wire == b.eval x) = _
    rw [he'.2 x a.wire a.wire.isLt]
    have ha : a.eval x = decide (walshCharacter A0 x=1) := by
      apply Bool.eq_iff_iff.mpr
      simp only [decide_eq_true_eq]
      rw [←hv x,labelReal_eq_one_iff]
    change (a.eval x == b.eval x) = _
    rw [ha,hv']
    simp [init,AccCircuit.eval]


theorem parityAnd_hasCircuit_linear {d m : ℕ} (A0 : Finset (Fin d))
    (A P : Fin m → Finset (Fin d))
    (hchar : ∀ i x, walshCharacter (A i) x =
      walshCharacter A0 x * walshCharacter (P i) x)
    (hm : m ≤ d) (hP : (∑ i, (P i).card) ≤ 2*d) :
    HasCircuitAtMost (parityAndTarget A0 A) (17*d+5) := by
  obtain ⟨c,hc,he⟩ := parityAnd_hasCircuit A0 A P hchar
  refine ⟨c,le_trans hc ?_,he⟩
  have hA : A0.card ≤ d := by simpa using Finset.card_le_univ A0
  rw [Finset.sum_add_distrib,←Finset.mul_sum]
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul]
  omega

/-- The complete deterministic resource estimate used by the lower bound:
the same target has an actual shallow ReLU teacher and a linear-size ordinary
NAND circuit. The only support hypothesis is the concrete parity identity. -/
theorem parityAnd_concrete_resources {d m K : ℕ} (A0 : Finset (Fin d))
    (A P : Fin m → Finset (Fin d))
    (hchar : ∀ i x, walshCharacter (A i) x =
      walshCharacter A0 x * walshCharacter (P i) x)
    (hmpos : 1 ≤ m) (hm : m ≤ d) (hd : d ≤ K*m)
    (hP : (∑ i, (P i).card) ≤ 2*d) :
    BoundedTeacher relu (parityAndTarget A0 A) (teacherWidth d m) ∧
    HasCircuitAtMost (parityAndTarget A0 A) (17*d+5) ∧
    teacherWidth d m ≤ 6*(K+1)*m^2 :=
  ⟨parityAnd_boundedTeacher A0 A,
    parityAnd_hasCircuit_linear A0 A P hchar hm hP,
    teacherWidth_quadratic hmpos hd⟩

end NeuralGeneralization.BatchTwoCircuitConverse
