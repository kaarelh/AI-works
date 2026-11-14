import NeuralGeneralization.OnlineLowerReluCoverageVariation

/-! Every real cube function has an explicit finite affine ReLU representation. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerRelu
open ConcreteModel OnlineLower OnlineLowerGeometry

def pointIndicatorWeights {d : ℕ} (x : Cube d) : Fin (d+1) → ℝ :=
  Fin.cases (1-(d:ℝ)) (fun i=>labelReal (x i))

lemma labelReal_mul_self (b : Bool) : labelReal b*labelReal b=1 := by
  cases b <;> norm_num [labelReal]

lemma labelReal_mul_le_one (a b : Bool) : labelReal a*labelReal b ≤ 1 := by
  cases a <;> cases b <;> norm_num [labelReal]

lemma labelReal_mul_of_ne (a b : Bool) (h : a ≠ b) : labelReal a*labelReal b = -1 := by
  cases a <;> cases b <;> simp_all [labelReal]

/-- One affine hinge isolates each vertex of the Boolean cube exactly. -/
theorem pointIndicatorWeights_output {d : ℕ} (x y : Cube d) :
    atomOutput (fun t=>max t 0) (pointIndicatorWeights x) y = if x=y then 1 else 0 := by
  have hp : (∑j,pointIndicatorWeights x j*inputVector y j) =
      1-(d:ℝ)+∑i,labelReal (x i)*labelReal (y i) := by
    rw [Fin.sum_univ_succ]
    simp only [pointIndicatorWeights,inputVector,Fin.cases_zero,Fin.cases_succ,mul_one]
  unfold atomOutput
  rw [hp]
  by_cases hxy : x=y
  · subst y
    simp [labelReal_mul_self]
  · rw [if_neg hxy]
    have hi : ∃i,x i ≠ y i := by
      by_contra hn
      push Not at hn
      exact hxy (funext hn)
    obtain ⟨i,hi⟩ := hi
    have hsum : (∑j,labelReal (x j)*labelReal (y j)) ≤ (d:ℝ)-2 := by
      calc
        _ ≤ ∑j : Fin d,(1-(if j=i then 2 else 0):ℝ) := by
          apply Finset.sum_le_sum
          intro j _
          by_cases hji : j=i
          · subst j
            norm_num [labelReal_mul_of_ne _ _ hi]
          · simpa only [if_neg hji,sub_zero] using labelReal_mul_le_one (x j) (y j)
        _ = _ := by simp [Finset.sum_sub_distrib]
    exact max_eq_right (by linarith)

/-- No representability premise is needed when taking variation infima on a
finite Boolean cube: one exact point-indicator neuron per vertex suffices. -/
theorem reluVariationCosts_nonempty {d : ℕ} (F : Cube d → ℝ) :
    (reluVariationCosts F).Nonempty := by
  let q := Fintype.card (Cube d)
  let e : Fin q ≃ Cube d := (Fintype.equivFin (Cube d)).symm
  let a : Fin q → Fin (d+1) → ℝ := fun j=>pointIndicatorWeights (e j)
  let c : Fin q → ℝ := fun j=>F (e j)
  refine ⟨finiteVariationCost a c,q,a,c,?_,rfl⟩
  intro x
  change (∑j,c j*atomOutput (fun t=>max t 0) (a j) x)=F x
  simp only [a,c,pointIndicatorWeights_output]
  rw [e.sum_comp (fun y=>F y*(if y=x then 1 else 0))]
  simp

end NeuralGeneralization.OnlineLowerRelu
