import NeuralGeneralization.OnlineLowerReluAssembly
import NeuralGeneralization.OnlineLowerMistakes

/-!
# Exact manuscript-level ReLU statement and explicit threshold arithmetic

Unlike the asymptotic resource proposition, the target below retains every
parameter in the paper's main theorem, including its sufficient learner
width `N₀ = 2^(m+d+1)` and its exact number `2^(k−1)` of designated rounds.
The main target is proved by the concrete analytic/geometry assembly in
`OnlineLowerReluMain`; none of its existence content is assumed here.
-/

noncomputable section
open scoped BigOperators Topology
open Filter Classical
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerRelu

def reluFixedRailSize : ℕ := 2^1024
abbrev reluConcreteDimension (k:ℕ) : ℕ := reluFamilyDimension reluFixedRailSize k
abbrev reluConcreteTeacherWidth (k:ℕ) : ℕ := reluFamilyTeacherWidth reluFixedRailSize k
abbrev reluConcreteTarget (k:ℕ) : BooleanFunction (reluConcreteDimension k) :=
  reluFamilyTarget reluFixedRailSize k

def reluConcreteThreshold (k:ℕ) : ℕ :=
  2^(Family.logicalDim k+reluConcreteDimension k+1)

def reluConcreteCount (k:ℕ) : ℕ := 2^(k-1)

theorem reluFixedRailSize_pos : 0<reluFixedRailSize := by unfold reluFixedRailSize; positivity

theorem reluConcreteDimension_eq (k:ℕ) :
    reluConcreteDimension k=(8*k+4)*(2*2^1024+4) := by
  change railDimension (Family.size reluFixedRailSize k)=_
  rw [Family.physicalDimension_eq,Family.pairDim_eq,reluFixedRailSize]

theorem reluConcreteTeacherWidth_eq (k:ℕ) :
    reluConcreteTeacherWidth k=3*(6*k+5)*(reluConcreteDimension k+1) := by
  change teacherWidth (reluConcreteDimension k) (Family.logicalDim k)=_
  rw [teacherWidth_eq,Family.logicalDim_eq]

theorem reluConcreteDimension_pos (k:ℕ) : 0<reluConcreteDimension k := by
  rw [reluConcreteDimension_eq]
  positivity

theorem successor_le_two_power (n:ℕ) : n+1≤2^n := by
  induction n with
  | zero => norm_num
  | succ n ih => rw [pow_succ]; nlinarith

theorem three_successor_le_two_power (n:ℕ) (hn:3≤n) : 3*(n+1)≤2^(n+1) := by
  induction n,hn using Nat.le_induction with
  | base => norm_num
  | succ n hn ih => rw [pow_succ]; nlinarith

/-- Exact arithmetic used by the explicit learner-width threshold. -/
theorem generic_teacher_le_orbit_threshold (m d:ℕ) (hd:3≤d) :
    teacherWidth d m≤2^(m+d+1) := by
  rw [teacherWidth_eq]
  have h1:=successor_le_two_power m
  have h2:=three_successor_le_two_power d hd
  calc
    3*(m+1)*(d+1)=(m+1)*(3*(d+1)) := by ring
    _ ≤ 2^m*2^(d+1) := Nat.mul_le_mul h1 h2
    _ = _ := by rw [←pow_add]; congr 1

theorem reluConcreteTeacher_le_threshold (k:ℕ) :
    reluConcreteTeacherWidth k≤reluConcreteThreshold k := by
  apply generic_teacher_le_orbit_threshold
  change 3≤railDimension (Family.size reluFixedRailSize k)
  rw [Family.physicalDimension_eq,Family.pairDim_eq]
  exact le_trans (by norm_num : (3:ℕ)≤4*1)
    (Nat.mul_le_mul (by omega : 4≤8*k+4) (by omega : 1≤2*reluFixedRailSize+4))

theorem reluConcreteThreshold_pos (k:ℕ) : 0<reluConcreteThreshold k := by
  unfold reluConcreteThreshold
  positivity

/-- There is room for every Fourier parity orbit, with a factor-two slack. -/
theorem reluConcrete_orbits_le_threshold (k:ℕ) :
    2^(Family.logicalDim k)*Fintype.card (Cube (reluConcreteDimension k))≤reluConcreteThreshold k := by
  have hc:Fintype.card (Cube (reluConcreteDimension k))=2^(reluConcreteDimension k) := by
    simp [Cube]
  rw [hc,←pow_add,reluConcreteThreshold,pow_succ]
  exact Nat.le_mul_of_pos_right _ (by norm_num)

/-- The precise fixed-permutation, fixed-threshold posterior conclusion. -/
def ReluConcreteProtocol (k:ℕ) (π:InputOrder (reluConcreteDimension k))
    (J:Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))) : Prop :=
  J.card=reluConcreteCount k ∧
  ∀N:ℕ,reluConcreteThreshold k≤N→
    (∀σ:ℝ,0<σ→∀j,0<denominatorAt relu (reluConcreteTarget k) π N σ j) ∧
    (∀j∈J,Tendsto (fun σ:ℝ=>correctAt relu (reluConcreteTarget k) π N σ j)
      (𝓝[>] (0:ℝ)) (𝓝 (0:ℝ)))

/-- Exact target corresponding to the main ReLU theorem of the paper.
It includes the actual bounded teacher, NAND circuit, full permutation,
exact count, and explicit learner threshold. This is a definition, not a
proof; `OnlineLowerReluMain.relu_concrete_main` supplies the proof. -/
def ReLUConcreteMainStatement : Prop :=
  ∃k₀:ℕ,3≤k₀∧∀k:ℕ,k₀≤k→
    BoundedTeacher relu (reluConcreteTarget k) (reluConcreteTeacherWidth k) ∧
    HasCircuitAtMost (reluConcreteTarget k) (17*reluConcreteDimension k+5) ∧
    ∃π:InputOrder (reluConcreteDimension k),
    ∃J:Finset (Fin (Fintype.card (Cube (reluConcreteDimension k)))),ReluConcreteProtocol k π J

theorem reluConcrete_teacher_and_circuit (k:ℕ) :
    BoundedTeacher relu (reluConcreteTarget k) (reluConcreteTeacherWidth k) ∧
      HasCircuitAtMost (reluConcreteTarget k) (17*reluConcreteDimension k+5) := by
  obtain ⟨ht,hc,_⟩:=Family.target_resources reluFixedRailSize k reluFixedRailSize_pos
  exact ⟨ht,hc⟩

theorem ReluConcreteProtocol.allLargeWidthsFail {k:ℕ}
    {π:InputOrder (reluConcreteDimension k)}
    {J:Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))}
    (h:ReluConcreteProtocol k π J) :
    AllLargeWidthsFail relu (reluConcreteTarget k) (reluConcreteTeacherWidth k) π J :=
  ⟨reluConcreteThreshold k,reluConcreteTeacher_le_threshold k,reluConcreteThreshold_pos k,h.2⟩

theorem ReLUConcreteMainStatement.squareRootStatement (h:ReLUConcreteMainStatement) :
    ReLUSquareRootStatement := by
  obtain ⟨k₀,hk₀,hfamily⟩:=h
  apply relu_square_root_resources_of_concrete_family reluFixedRailSize k₀ reluFixedRailSize_pos
  intro k hk _
  obtain ⟨_,_,π,J,hprotocol⟩:=hfamily k hk
  exact ⟨π,J,by rw [hprotocol.1]; rfl,hprotocol.allLargeWidthsFail⟩

/-- Literal finite-joint-law probability of at least all designated mistakes. -/
def designatedAtLeastProbability {d:ℕ} (φ:ℝ→ℝ) (f:BooleanFunction d)
    (π:InputOrder d) (N:ℕ) (σ:ℝ)
    (J:Finset (Fin (Fintype.card (Cube d)))) (T:ℕ) : ℝ :=
  ∑draw:J→BooleanFunction d,
    if (T:ℝ)≤designatedSampledMistakes f π J draw
    then designatedJointWeight φ f π N σ J draw else 0

theorem designatedAtLeastProbability_ge_allWrong {d N:ℕ}
    (φ:ℝ→ℝ) (f:BooleanFunction d) (π:InputOrder d) (σ:ℝ)
    (J:Finset (Fin (Fintype.card (Cube d))))
    (hden:∀j∈J,0<denominatorAt φ f π N σ j) :
    independentAllWrongProbability φ f π N σ J≤
      designatedAtLeastProbability φ f π N σ J J.card := by
  rw [←designated_all_wrong_probability_identity φ f π σ J hden]
  unfold designatedAtLeastProbability
  apply Finset.sum_le_sum
  intro draw _
  by_cases hw:∀j:J,draw j (π j.val)≠f (π j.val)
  · rw [if_pos hw]
    have hcount:=designatedSampledMistakes_eq_card_of_all_wrong f π J draw hw
    rw [hcount,if_pos le_rfl]
  · rw [if_neg hw]
    split_ifs
    · exact (designatedJointWeight_probability φ f π σ J hden).1 draw
    · rfl

/-- The three finite-scale bullets of the paper hold simultaneously, at
one positive scale threshold, for the same actual posterior and sequence. -/
theorem ReluConcreteProtocol.finite_scale {k N:ℕ}
    {π:InputOrder (reluConcreteDimension k)}
    {J:Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))}
    (h:ReluConcreteProtocol k π J) (hN:reluConcreteThreshold k≤N)
    (η:ℝ) (hη:0<η) :
    ∃σ₀:ℝ,0<σ₀∧∀σ:ℝ,0<σ→σ<σ₀→
      (1-η<designatedAtLeastProbability relu (reluConcreteTarget k) π N σ J (reluConcreteCount k)) ∧
      (∀j∈J,correctAt relu (reluConcreteTarget k) π N σ j<(1/2:ℝ) ∧
        correctAt relu (reluConcreteTarget k) π N σ j<(2/3:ℝ)) := by
  have hl:=(h.2 N hN).2
  obtain ⟨σ₁,hσ₁,hsmall₁⟩:=finite_scale_all_wrong_probability relu (reluConcreteTarget k) π J hl η hη
  obtain ⟨σ₂,hσ₂,hsmall₂⟩:=finite_designated_scale relu (reluConcreteTarget k) π J hl (1/2) (by norm_num)
  refine ⟨min σ₁ σ₂,lt_min hσ₁ hσ₂,?_⟩
  intro σ hσ hσlt
  have hs₁:σ<σ₁:=lt_of_lt_of_le hσlt (min_le_left _ _)
  have hs₂:σ<σ₂:=lt_of_lt_of_le hσlt (min_le_right _ _)
  constructor
  · have hp:=designatedAtLeastProbability_ge_allWrong relu (reluConcreteTarget k) π σ J
      (fun j _=>(h.2 N hN).1 σ hσ j)
    rw [h.1] at hp
    exact lt_of_lt_of_le (hsmall₁ σ hσ hs₁) hp
  · intro j hj
    have hh:=hsmall₂ σ hσ hs₂ j hj
    exact ⟨hh,by linarith⟩

end NeuralGeneralization.OnlineLower
