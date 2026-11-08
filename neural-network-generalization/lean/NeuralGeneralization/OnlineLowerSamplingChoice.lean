import NeuralGeneralization.OnlineLowerSamplingTransfer
import NeuralGeneralization.OnlineLowerReluSamplingEnergy

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

variable {κ : Type*} [Fintype κ] [DecidableEq κ] {β:κ→Type*}
variable [∀j,Fintype (β j)] [∀j,Nonempty (β j)]

theorem uniformBlockAverage_eq_finiteAverage (F:((j:κ)→β j)→ℝ) :
    uniformBlockAverage F=finiteAverage F := by
  unfold uniformBlockAverage finiteAverage
  rw [Fintype.card_pi,Nat.cast_prod,Finset.prod_inv_distrib]
  ring

theorem finiteAverage_coordinate (j:κ) (F:β j→ℝ) :
    finiteAverage (fun pick:(j:κ)→β j=>F (pick j))=finiteAverage F := by
  rw [←uniformBlockAverage_eq_finiteAverage,uniformBlockAverage_coordinate]
  unfold finiteAverage
  ring

theorem finiteAverage_mul_coordinates (j k:κ) (hjk:j≠k) (F:β j→ℝ) (G:β k→ℝ) :
    finiteAverage (fun pick:(j:κ)→β j=>F (pick j)*G (pick k))=
      finiteAverage (fun pick:(j:κ)→β j=>F (pick j))*
      finiteAverage (fun pick:(j:κ)→β j=>G (pick k)) := by
  simp_rw [←uniformBlockAverage_eq_finiteAverage]
  exact uniformBlockAverage_mul_coordinates j k hjk F G

section Pairs
variable {p:ℕ} {β:(Fin p×Bool)→Type*}
variable [∀j,Fintype (β j)] [∀j,Nonempty (β j)]

def railSecondMoment (u:(j:Fin p×Bool)→β j→ℝ) (j:Fin p×Bool) : ℝ :=
  finiteAverage (fun a=>u j a^2)

def secondMomentChoice (u:(j:Fin p×Bool)→β j→ℝ) (i:Fin p) : Bool :=
  decide (railSecondMoment u (i,false)≤railSecondMoment u (i,true))

def chosenSample (u:(j:Fin p×Bool)→β j→ℝ) (pick:(j:Fin p×Bool)→β j) (i:Fin p) : ℝ :=
  u (i,secondMomentChoice u i) (pick (i,secondMomentChoice u i))

def discardedSample (u:(j:Fin p×Bool)→β j→ℝ) (pick:(j:Fin p×Bool)→β j) (i:Fin p) : ℝ :=
  u (i,!(secondMomentChoice u i)) (pick (i,!(secondMomentChoice u i)))

theorem chosen_secondMoment_larger (u:(j:Fin p×Bool)→β j→ℝ) (i:Fin p) :
    finiteAverage (fun pick=>discardedSample u pick i^2)≤
      finiteAverage (fun pick=>chosenSample u pick i^2) := by
  simp only [chosenSample,discardedSample]
  rw [finiteAverage_coordinate (i,!(secondMomentChoice u i)) (fun a=>u (i,!(secondMomentChoice u i)) a^2),
    finiteAverage_coordinate (i,secondMomentChoice u i) (fun a=>u (i,secondMomentChoice u i) a^2)]
  change railSecondMoment u (i,!(secondMomentChoice u i))≤railSecondMoment u (i,secondMomentChoice u i)
  unfold secondMomentChoice
  by_cases h:railSecondMoment u (i,false)≤railSecondMoment u (i,true)
  · simpa [h] using h
  · simpa [h] using (le_of_not_ge h)

theorem sample_square_bound (u:(j:Fin p×Bool)→β j→ℝ) (R:ℝ)
    (hR:∀j,(Fintype.card (β j):ℝ)≤R) (j:Fin p×Bool) (pick:(j:Fin p×Bool)→β j) :
    u j (pick j)^2≤R*finiteAverage (fun pick:(j:Fin p×Bool)→β j=>u j (pick j)^2) := by
  rw [finiteAverage_coordinate j (fun a=>u j a^2)]
  exact (square_le_card_average (u j) (pick j)).trans
    (mul_le_mul_of_nonneg_right (hR j) (finiteAverage_nonneg _ (fun a=>sq_nonneg _)))

/-- The hypotheses of scalar rounding follow from the actual independent
coordinate-copying experiment. There are no independence assumptions in this theorem. -/
theorem actual_deterministic_rail_rounding (hp:2≤p)
    (u:(j:Fin p×Bool)→β j→ℝ) (hu:∀j a,0≤u j a) (R:ℝ)
    (hR:∀j,(Fintype.card (β j):ℝ)≤R) :
    finiteAverage (fun pick=>∑ i,(chosenSample u pick i-
      scalarMean (fun j=>finiteAverage (fun pick=>chosenSample u pick j)))^2)+
      finiteAverage (fun pick=>∑ i,discardedSample u pick i^2) ≤
      (4+10*R)*finiteAverage (fun pick=>
        (∑ i,min (chosenSample u pick i^2) (discardedSample u pick i^2))+
        scalarSpread (fun i=>max (chosenSample u pick i) (discardedSample u pick i))) := by
  have hp0:0<p := by omega
  let i0:Fin p:=⟨0,hp0⟩
  have hR0:0≤R := (Nat.cast_nonneg (Fintype.card (β (i0,false)))).trans (hR _)
  apply deterministic_rail_rounding p hp (chosenSample u) (discardedSample u) R hR0
  · intro pick i; exact hu _ _
  · intro pick i; exact hu _ _
  · exact chosen_secondMoment_larger u
  · intro pick i; exact sample_square_bound u R hR _ pick
  · intro pick i; exact sample_square_bound u R hR _ pick
  · intro i
    apply finiteAverage_mul_coordinates (i,secondMomentChoice u i) (i,!(secondMomentChoice u i))
      (F:=fun a=>u (i,secondMomentChoice u i) a^2)
      (G:=fun a=>u (i,!(secondMomentChoice u i)) a^2)
    intro he
    have hh := congrArg Prod.snd he
    cases secondMomentChoice u i <;> simp at hh
  · intro i j hij
    apply finiteAverage_mul_coordinates
    intro he
    exact hij (congrArg Prod.fst he)

end Pairs
end NeuralGeneralization.OnlineLowerRelu
