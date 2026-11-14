import NeuralGeneralization.OnlineLowerReluConcreteStatement
import NeuralGeneralization.OnlineLowerSoftplusBasic

/-!
# Literal standard-softplus extension of the ReLU online lower bound

The activation is `log(1+exp x)`. The target and full input permutation are
shared with the ReLU theorem. The softplus width threshold is existential,
then every larger width is fixed before the Gaussian scale tends to zero.
The raw teacher has the original width, margin greater than one, and
coefficients bounded by 24 times that width; padding gives a bounded teacher.
-/
noncomputable section
open scoped BigOperators Topology
open Filter Classical
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower OnlineLowerRelu

abbrev softplusConcreteTeacherWidth (k : ℕ) : ℕ := 24*reluConcreteTeacherWidth k

def SoftplusConcreteTeacher (k : ℕ) : Prop :=
  ∃ w : Weights (reluConcreteDimension k) (reluConcreteTeacherWidth k) 0,
    (∀ x,1 < labelReal (reluConcreteTarget k x)*networkOutput softplus w x) ∧
    boundedWeights (softplusConcreteTeacherWidth k) w

def SoftplusConcreteMainStatement : Prop :=
  ∃ k₀ : ℕ,3 ≤ k₀ ∧ ∀ k : ℕ,k₀ ≤ k →
    SoftplusConcreteTeacher k ∧
    BoundedTeacher softplus (reluConcreteTarget k) (softplusConcreteTeacherWidth k) ∧
    HasCircuitAtMost (reluConcreteTarget k) (17*reluConcreteDimension k+5) ∧
    ∃ π : InputOrder (reluConcreteDimension k),
    ∃ J : Finset (Fin (Fintype.card (Cube (reluConcreteDimension k)))),
      ReluConcreteProtocol k π J ∧
      AllLargeWidthsFail softplus (reluConcreteTarget k) (softplusConcreteTeacherWidth k) π J

/-- The exact same permutation and designated set supply the finite-scale
majority, confidence, and fresh independent posterior-sampling consequences. -/
theorem softplus_finite_scale {k : ℕ}
    {π : InputOrder (reluConcreteDimension k)}
    {J : Finset (Fin (Fintype.card (Cube (reluConcreteDimension k))))}
    (hcount : J.card=reluConcreteCount k)
    (hfail : AllLargeWidthsFail softplus (reluConcreteTarget k)
      (softplusConcreteTeacherWidth k) π J) :
    ∃ N₀ : ℕ,softplusConcreteTeacherWidth k ≤ N₀ ∧ 0 < N₀ ∧
      ∀ N : ℕ,N₀ ≤ N → ∀ η : ℝ,0 < η →
        ∃ σ₀ : ℝ,0 < σ₀ ∧ ∀ σ : ℝ,0 < σ → σ < σ₀ →
          (1-η < designatedAtLeastProbability softplus (reluConcreteTarget k) π N σ J
            (reluConcreteCount k)) ∧
          (∀ j ∈ J,OnlineLower.correctAt softplus (reluConcreteTarget k) π N σ j < (1/2:ℝ) ∧
            OnlineLower.correctAt softplus (reluConcreteTarget k) π N σ j < (2/3:ℝ)) := by
  obtain ⟨N₀,hCN,hN₀,hlarge⟩ := hfail
  refine ⟨N₀,hCN,hN₀,?_⟩
  intro N hN η hη
  have hl := (hlarge N hN).2
  obtain ⟨σ₁,hσ₁,hsmall₁⟩ := finite_scale_all_wrong_probability softplus (reluConcreteTarget k) π J hl η hη
  obtain ⟨σ₂,hσ₂,hsmall₂⟩ := finite_designated_scale softplus (reluConcreteTarget k) π J hl (1/2) (by norm_num)
  refine ⟨min σ₁ σ₂,lt_min hσ₁ hσ₂,?_⟩
  intro σ hσ hσlt
  have hs₁ : σ < σ₁ := lt_of_lt_of_le hσlt (min_le_left _ _)
  have hs₂ : σ < σ₂ := lt_of_lt_of_le hσlt (min_le_right _ _)
  constructor
  · have hp := designatedAtLeastProbability_ge_allWrong softplus (reluConcreteTarget k) π σ J
      (fun j _ => (hlarge N hN).1 σ hσ j)
    rw [hcount] at hp
    exact lt_of_lt_of_le (hsmall₁ σ hσ hs₁) hp
  · intro j hj
    have hh := hsmall₂ σ hσ hs₂ j hj
    exact ⟨hh,by linarith⟩

/-- The actual bounded teacher and same-sequence posterior theorem imply
an exponential lower bound with linear input dimension and quadratic width. -/
theorem SoftplusConcreteMainStatement.squareRootStatement
    (h : SoftplusConcreteMainStatement) : PolynomialResourceFamily softplus 1 2 := by
  obtain ⟨k₀,hk₀,hfamily⟩ := h
  let R := reluFixedRailSize
  let K := 24*(600*(4*R+9))+(24*R+48)+22
  have hK : 0 < K := by dsimp [K]; omega
  have hKu : 24*R+48 ≤ K := by dsimp [K]; omega
  have hKC : 24*(600*(4*R+9)) ≤ K := by dsimp [K]; omega
  have hKcirc : 22 ≤ K := by dsimp [K]; omega
  refine ⟨K,hK,Real.log 2/2,div_pos (Real.log_pos (by norm_num)) (by norm_num),
    k₀,by omega,?_⟩
  intro k hk
  obtain ⟨_,hteacher,_,π,J,hrelu,hfail⟩ := hfamily k hk
  have hk2 : 2 ≤ k := by omega
  obtain ⟨hd,hC,hdl,hdu,hCu,_,hcircuit⟩ :=
    reluFamily_resource_bounds R k reluFixedRailSize_pos (by omega)
  refine ⟨reluConcreteDimension k,softplusConcreteTeacherWidth k,reluConcreteTarget k,
    π,J,hd,hteacher.1,?_,?_,?_,hteacher,?_,?_,hfail⟩
  · simpa only [pow_one] using hdl.trans (Nat.le_mul_of_pos_left _ hK)
  · simpa only [pow_one] using hdu.trans (Nat.mul_le_mul_right _ hKu)
  · calc
      softplusConcreteTeacherWidth k ≤ 24*(600*(4*R+9)*k^2) := Nat.mul_le_mul_left 24 hCu
      _ = (24*(600*(4*R+9)))*k^2 := by ring
      _ ≤ K*k^2 := Nat.mul_le_mul_right _ hKC
  · obtain ⟨c,hc,he⟩ := hcircuit
    exact ⟨c,hc.trans (Nat.mul_le_mul_right _ hKcirc),he⟩
  · rw [hrelu.1]
    simpa only [reluConcreteCount,Nat.cast_pow] using binary_family_exponential_count k hk2

end NeuralGeneralization.OnlineLowerSoftplus
