import NeuralGeneralization.BatchTwoActivationStatements
import NeuralGeneralization.RobustCompressionGridMeasurable

/-!
# An actual finite cover of zero-at-zero Lipschitz activations

Representatives are chosen from the original activation class; consequently
they remain globally one-Lipschitz and vanish at zero. A grid of input/output
values gives covering error `4R/J` and cardinality `(2J+1)^(2J+1)`.

This elementary cover has a harmless logarithmic entropy loss compared with
the sharper adjacent-increment encoding in the manuscript. It is sufficient
for an existential fixed-depth polynomial learning theorem, without asserting
the sharper displayed capacity constant.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel ParameterGrid

abbrev UnitActivation := {φ : ℝ → ℝ // zeroLipschitzActivation 1 φ}
abbrev ActivationCode (J : ℕ) := GridInt J → GridInt J

def zeroUnitActivation : UnitActivation :=
  ⟨fun _ => 0, by constructor <;> simp⟩

def activationGridNode (R : ℝ) (J : ℕ) (i : GridInt J) : ℝ :=
  R * ((i.val : ℝ) / J)

def activationCode (R : ℝ) (J : ℕ) (φ : UnitActivation) : ActivationCode J :=
  fun i => roundUnitGrid J (φ.val (activationGridNode R J i) / R)

def activationRepresentative (R : ℝ) (J : ℕ) (q : ActivationCode J) : UnitActivation := by
  classical
  exact if h : ∃ φ : UnitActivation, activationCode R J φ = q then Classical.choose h
  else zeroUnitActivation

theorem activationRepresentative_code (R : ℝ) (J : ℕ) (φ : UnitActivation) :
    activationCode R J (activationRepresentative R J (activationCode R J φ)) =
      activationCode R J φ := by
  unfold activationRepresentative
  split_ifs with h
  · exact Classical.choose_spec h
  · exact False.elim (h ⟨φ, rfl⟩)

theorem activationCode_card (J : ℕ) :
    Fintype.card (ActivationCode J) = (2*J+1)^(2*J+1) := by
  rw [Fintype.card_fun, gridInt_card]

theorem activationGridNode_abs_le {R : ℝ} (hR : 0 < R) {J : ℕ} (hJ : 0 < J)
    (i : GridInt J) : |activationGridNode R J i| ≤ R := by
  have hd := decode_abs_le_one J hJ (fun _ : Unit => i) ()
  change |(i.val : ℝ)/(J : ℝ)| ≤ 1 at hd
  rw [activationGridNode, abs_mul, abs_of_pos hR]
  exact (mul_le_mul_of_nonneg_left hd hR.le).trans_eq (mul_one R)

theorem scaled_grid_error {R : ℝ} (hR : 0 < R) {J : ℕ} (hJ : 0 < J)
    (x : ℝ) (hx : |x| ≤ R) :
    |x - activationGridNode R J (roundUnitGrid J (x/R))| ≤ R/(J : ℝ) := by
  have hx' : |x/R| ≤ 1 := by
    rw [abs_div, abs_of_pos hR]
    exact (div_le_one hR).2 hx
  have hround := roundUnitGrid_close J hJ (x/R) hx'
  have hm := mul_le_mul_of_nonneg_left hround hR.le
  have heq : R * |x/R - ((roundUnitGrid J (x/R)).val : ℝ)/J| =
      |x - activationGridNode R J (roundUnitGrid J (x/R))| := by
    calc
      _ = |R * (x/R - ((roundUnitGrid J (x/R)).val : ℝ)/J)| := by
        rw [abs_mul, abs_of_pos hR]
      _ = _ := by
        congr 1
        unfold activationGridNode
        field_simp [hR.ne']
  rw [heq] at hm
  simpa only [mul_one_div] using hm

theorem activation_grid_value_close {R : ℝ} (hR : 0 < R) {J : ℕ} (hJ : 0 < J)
    (φ : UnitActivation) (i : GridInt J) :
    |φ.val (activationGridNode R J i) -
      activationGridNode R J (activationCode R J φ i)| ≤ R/(J : ℝ) := by
  have hab : |φ.val (activationGridNode R J i)| ≤ R := by
    have h := activation_abs_le φ.property (activationGridNode R J i)
    simp only [one_mul] at h
    exact h.trans (activationGridNode_abs_le hR hJ i)
  exact scaled_grid_error hR hJ _ hab

/-- Equal finite codes force uniform approximation on the whole interval,
not just at the finitely many sampled locations. -/
theorem equal_activationCode_close {R : ℝ} (hR : 0 < R) {J : ℕ} (hJ : 0 < J)
    (φ ψ : UnitActivation) (hcode : activationCode R J φ = activationCode R J ψ)
    (x : ℝ) (hx : |x| ≤ R) : |φ.val x - ψ.val x| ≤ 4*R/(J : ℝ) := by
  let i := roundUnitGrid J (x/R)
  let y := activationGridNode R J i
  have hxy : |x-y| ≤ R/(J : ℝ) := scaled_grid_error hR hJ x hx
  have hφ := activation_grid_value_close hR hJ φ i
  have hψ := activation_grid_value_close hR hJ ψ i
  have hi := congrFun hcode i
  rw [hi] at hφ
  have hmid : |φ.val y - ψ.val y| ≤ 2*R/(J : ℝ) := by
    have htriangle := abs_sub_le (φ.val y)
      (activationGridNode R J (activationCode R J ψ i)) (ψ.val y)
    rw [abs_sub_comm (activationGridNode R J (activationCode R J ψ i)) (ψ.val y)] at htriangle
    change |φ.val y - _| ≤ _ at hφ
    change |ψ.val y - _| ≤ _ at hψ
    rw [mul_div_assoc]
    linarith
  have hleft := φ.property.2 x y
  have hright := ψ.property.2 y x
  simp only [one_mul, abs_sub_comm y x] at hleft hright
  have ht₁ := abs_sub_le (φ.val x) (φ.val y) (ψ.val x)
  have ht₂ := abs_sub_le (φ.val y) (ψ.val y) (ψ.val x)
  rw [mul_div_assoc] at hmid ⊢
  linarith

/-- Every covered representative is an actual globally one-Lipschitz
zero-at-zero function, and every such function has a code attaining the
stated approximation error. -/
theorem activationRepresentative_covers {R : ℝ} (hR : 0 < R) {J : ℕ} (hJ : 0 < J)
    (φ : UnitActivation) :
    ∀ x : ℝ, |x| ≤ R →
      |φ.val x - (activationRepresentative R J (activationCode R J φ)).val x| ≤ 4*R/(J : ℝ) := by
  intro x hx
  apply equal_activationCode_close hR hJ φ _
    (activationRepresentative_code R J φ).symm x hx

end NeuralGeneralization.BatchTwoActivation
