import NeuralGeneralization.OnlineLowerTanhWalshColumns
import NeuralGeneralization.OnlineLowerTanhGeometryCommonDual
import NeuralGeneralization.OnlineLowerCostRailBridge

/-! # Positive high-order mass after a literal column pushforward -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu OnlineLowerGeometry OnlineLower

lemma column_pushforward_sum {m p : ℕ} (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) :
    (∑T : Finset (Fin m),columnCoefficientPushforward column c T)=∑I,c I := by
  unfold columnCoefficientPushforward
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro I hI
  simp

lemma column_pushforward_ge_preimage {m p : ℕ} (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) (hc : ∀I,2≤I.card → 0≤c I)
    {T : Finset (Fin m)} (hT : T≠∅) (hcolumn : ∀i,column i≠T)
    {I : Finset (Fin p)} (hI : generatedSupport ∅ column I=T) :
    c I≤columnCoefficientPushforward column c T := by
  have hs := Finset.single_le_sum (s:=Finset.univ)
    (f:=fun J : Finset (Fin p)=>if generatedSupport ∅ column J=T then c J else 0)
    (fun J _=>by
      split_ifs with h
      · exact hc J (column_fiber_card_ge_two column hT hcolumn h)
      · rfl) (Finset.mem_univ I)
  change c I≤∑J : Finset (Fin p),if generatedSupport ∅ column J=T then c J else 0
  simpa only [hI,ite_true] using hs

/-- Empty and singleton independent modes cannot add positive mass away
from the zero label. All other mass is charged to high independent modes;
the distinguished preimage is omitted at its own image. -/
theorem column_noncentral_positive_mass_le {m p : ℕ}
    (column : Fin p → Finset (Fin m)) (c : Finset (Fin p) → ℝ)
    (hc : ∀I,2≤I.card → 0≤c I) (hsingle : ∀i,c {i}≤0)
    (Istar : Finset (Fin p)) :
    (∑T : Finset (Fin m),if T≠∅ ∧ T≠generatedSupport ∅ column Istar
      then max (columnCoefficientPushforward column c T) 0 else 0) ≤
      ∑I : Finset (Fin p),if 2≤I.card ∧ I≠Istar then c I else 0 := by
  let g := fun I : Finset (Fin p) => if 2≤I.card ∧ I≠Istar then c I else 0
  have hg (I : Finset (Fin p)) : 0≤g I := by
    dsimp [g]
    split_ifs with h
    · exact hc I h.1
    · rfl
  have hpg (T : Finset (Fin m)) : 0≤columnCoefficientPushforward column g T := by
    apply Finset.sum_nonneg
    intro I hI
    split_ifs
    · exact hg I
    · rfl
  have hupper (T : Finset (Fin m)) (hT : T≠∅)
      (hstar : T≠generatedSupport ∅ column Istar) :
      columnCoefficientPushforward column c T ≤ columnCoefficientPushforward column g T := by
    apply Finset.sum_le_sum
    intro I hI
    by_cases hpre : generatedSupport ∅ column I=T
    · have hne : I≠Istar := by intro he; subst I; exact hstar hpre.symm
      by_cases hcard : 2≤I.card
      · simp only [hpre,ite_true]
        change c I ≤ if 2≤I.card ∧ I≠Istar then c I else 0
        rw [if_pos ⟨hcard,hne⟩]
      · have h01 : I.card=0 ∨ I.card=1 := by omega
        rcases h01 with h0 | h1
        · have he : I=∅ := Finset.card_eq_zero.mp h0
          subst I
          exact False.elim (hT (by simpa only [generatedSupport_empty] using hpre.symm))
        · obtain ⟨i,rfl⟩ := Finset.card_eq_one.mp h1
          simpa only [hpre,ite_true,g,hcard,false_and,ite_false] using hsingle i
    · simp only [hpre,ite_false]
      exact le_rfl
  have hpoint (T : Finset (Fin m)) :
      (if T≠∅ ∧ T≠generatedSupport ∅ column Istar
        then max (columnCoefficientPushforward column c T) 0 else 0) ≤
        columnCoefficientPushforward column g T := by
    split_ifs with h
    · exact max_le (hupper T h.1 h.2) (hpg T)
    · exact hpg T
  have hh := Finset.sum_le_sum (s:=Finset.univ) (fun T _=>hpoint T)
  rw [column_pushforward_sum] at hh
  exact hh

/-- The maximum on a two-point orbit is no greater than the sum of the two
positive parts; the factor two cancels when all orbits are summed. -/
theorem rectanglePairedTotal_le_positive_mass {m : ℕ}
    (w : Finset (Fin m) → ℝ) (u : ClippingCube m) :
    rectanglePairedTotal w u ≤ ∑z : ClippingCube m,
      if z=cubeOne m ∨ z=u then 0 else max (rectangleWeightTransform w z) 0 := by
  let P := fun z : ClippingCube m =>
    if z=cubeOne m ∨ z=u then 0 else max (rectangleWeightTransform w z) 0
  have hP (z : ClippingCube m) : 0≤P z := by
    dsimp [P]
    split_ifs
    · rfl
    · exact le_max_right _ _
  have hpoint (z : ClippingCube m) : rectanglePairedCost w u z ≤ P z+P (cubeTranslation u z) := by
    by_cases hz : z=cubeOne m ∨ z=u
    · rw [rectanglePairedCost,if_pos hz]
      exact add_nonneg (hP z) (hP _)
    · have ht : ¬(cubeTranslation u z=cubeOne m ∨ cubeTranslation u z=u) := by
        rintro (he | he)
        · have hh := congrArg (cubeTranslation u) he
          have hz' : z=u := by
            simpa only [cubeTranslation_involutive, OnlineLowerGeometry.cubeTranslation_comm u (cubeOne m),
              cubeTranslation_one] using hh
          exact hz (Or.inr hz')
        · have hh := congrArg (cubeTranslation u) he
          have hz' : z=cubeOne m := by
            simpa only [cubeTranslation_involutive,cubeTranslation_self] using hh
          exact hz (Or.inl hz')
      simp only [rectanglePairedCost,P,if_neg hz,if_neg ht,rectangleWeightTransform]
      apply max_le
      · exact add_nonneg (le_max_right _ _) (le_max_right _ _)
      · apply max_le
        · linarith [le_max_left (walshExpansion w z / Fintype.card (ClippingCube m)) 0,
            le_max_right (walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)) 0]
        · linarith [le_max_right (walshExpansion w z / Fintype.card (ClippingCube m)) 0,
            le_max_left (walshExpansion w (cubeTranslation u z) / Fintype.card (ClippingCube m)) 0]
  have hh := Finset.sum_le_sum (s:=Finset.univ) (fun z _=>hpoint z)
  rw [Finset.sum_add_distrib,(cubeTranslation u).sum_comp P] at hh
  change (∑z,rectanglePairedCost w u z)/2 ≤ ∑z,P z
  linarith

/-- The rectangle paired mass is bounded by the noncentral high independent
mass. The supplied transform identity is the exact Walsh pushforward, proved
for actual column scores by `columnDegree_walsh_pushforward`. -/
theorem rectanglePairedTotal_le_column_high_mass {m p : ℕ}
    (w : Finset (Fin m) → ℝ) (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) (hc : ∀I,2≤I.card → 0≤c I)
    (hsingle : ∀i,c {i}≤0) (Istar : Finset (Fin p))
    (htransform : ∀T, rectangleWeightTransform w (negativeBitsCube T)=
      columnCoefficientPushforward column c T) :
    rectanglePairedTotal w (negativeBitsCube (generatedSupport ∅ column Istar)) ≤
      ∑I : Finset (Fin p),if 2≤I.card ∧ I≠Istar then c I else 0 := by
  let U := generatedSupport ∅ column Istar
  let P := fun z : ClippingCube m =>
    if z=cubeOne m ∨ z=negativeBitsCube U then 0 else max (rectangleWeightTransform w z) 0
  have hzero : negativeBitsCube (∅ : Finset (Fin m))=cubeOne m := by
    funext i
    simp [negativeBitsCube,cubeOne]
  have he (T : Finset (Fin m)) : P (negativeBitsCube T)=
      if T≠∅ ∧ T≠U then max (columnCoefficientPushforward column c T) 0 else 0 := by
    have hz : negativeBitsCube T=cubeOne m ↔ T=∅ := by
      constructor
      · intro hh
        apply (negativeBitsEquiv m).injective
        exact hh.trans hzero.symm
      · rintro rfl
        exact hzero
    have hu : negativeBitsCube T=negativeBitsCube U ↔ T=U := by
      change (negativeBitsEquiv m) T=(negativeBitsEquiv m) U ↔ T=U
      exact (negativeBitsEquiv m).injective.eq_iff
    dsimp [P]
    simp only [hz,hu,htransform]
    by_cases hT : T=∅ <;> by_cases hU : T=U <;> simp [hT,hU]
  have hsum := (negativeBitsEquiv m).sum_comp P
  change (∑T : Finset (Fin m),P (negativeBitsCube T))=∑z,P z at hsum
  simp_rw [he] at hsum
  calc
    _ ≤ ∑z,P z := rectanglePairedTotal_le_positive_mass w (negativeBitsCube U)
    _ = _ := hsum.symm
    _ ≤ _ := column_noncentral_positive_mass_le column c hc hsingle Istar

end NeuralGeneralization.OnlineLowerTanh
