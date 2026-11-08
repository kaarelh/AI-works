import NeuralGeneralization.OnlineLowerTanhIncrementWalsh
import NeuralGeneralization.OnlineLowerGeometryAlgebra
import NeuralGeneralization.OnlineLowerCostColumns

/-! # Exact Walsh pushforward through literal Boolean code columns -/
noncomputable section
open scoped BigOperators Classical symmDiff
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu OnlineLowerGeometry

/-- Coefficient pushforward along the actual symmetric-difference column map. -/
def columnCoefficientPushforward {m p : ℕ} (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) (T : Finset (Fin m)) : ℝ :=
  ∑ I : Finset (Fin p), if generatedSupport ∅ column I=T then c I else 0

lemma walshExpansion_column_pushforward {m p : ℕ}
    (column : Fin p → Finset (Fin m)) (c : Finset (Fin p) → ℝ) (x : ClippingCube m) :
    walshExpansion (columnCoefficientPushforward column c) x =
      walshExpansion c (generatedSyndrome column x) := by
  unfold walshExpansion columnCoefficientPushforward
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro I hI
  simp only [ite_mul, zero_mul]
  rw [Finset.sum_ite_eq]
  simp only [Finset.mem_univ, ite_true]
  have hh := generatedSupport_character (∅ : Finset (Fin m)) column I x
  simpa only [walshCharacter, Finset.prod_empty, one_mul] using congrArg (fun z => c I*z) hh

/-- Pulling back a cube score through the literal column characters sums its
independent Walsh coefficients over precisely the symmetric-difference fiber. -/
theorem walshCoefficients_column_pullback {m p : ℕ}
    (column : Fin p → Finset (Fin m)) (F : ClippingCube p → ℝ) (T : Finset (Fin m)) :
    walshCoefficients (fun x => F (generatedSyndrome column x)) T =
      columnCoefficientPushforward column (walshCoefficients F) T := by
  have he : (fun x => F (generatedSyndrome column x)) =
      walshExpansion (columnCoefficientPushforward column (walshCoefficients F)) := by
    funext x
    rw [walshExpansion_column_pushforward, walshExpansion_coefficients]
  rw [he, OnlineLowerGeometry.walshCoefficients_expansion]

/-- The independent-increment score pulled through the code is exactly the
existing physical-column degree score. -/
lemma incrementScore_column_pullback {m p : ℕ}
    (column : Fin p → Finset (Fin m)) (δ : Fin p → ℝ) (f : ℝ → ℝ) (n : ℝ) :
    (fun x => incrementScore δ f n (generatedSyndrome column x)) =
      (fun x => f (OnlineLower.columnDegree n column δ x)) := by
  funext x
  unfold incrementScore incrementLinear OnlineLower.columnDegree
  congr 2
  apply Finset.sum_congr rfl
  intro i hi
  rw [← generatedSyndrome_sign column x i]
  cases hb : generatedSyndrome column x i <;> simp [cubeCoordinateSign] <;> ring

theorem columnDegree_walsh_pushforward {m p : ℕ}
    (column : Fin p → Finset (Fin m)) (δ : Fin p → ℝ) (f : ℝ → ℝ) (n : ℝ)
    (T : Finset (Fin m)) :
    walshCoefficients (fun x => f (OnlineLower.columnDegree n column δ x)) T =
      columnCoefficientPushforward column (walshCoefficients (incrementScore δ f n)) T := by
  rw [← incrementScore_column_pullback column δ f n]
  exact walshCoefficients_column_pullback column (incrementScore δ f n) T

lemma generatedSupport_singleton {m p : ℕ} (column : Fin p → Finset (Fin m)) (i : Fin p) :
    generatedSupport ∅ column {i}=column i := by
  rw [show ({i} : Finset (Fin p))=insert i ∅ by rfl,
    generatedSupport_insert ∅ column ∅ i (by simp), generatedSupport_empty]
  simp

/-- A nonzero output label which is not itself a column has no empty or
singleton preimage. Thus only high-order independent coefficients contribute. -/
lemma column_fiber_card_ge_two {m p : ℕ} (column : Fin p → Finset (Fin m))
    {T : Finset (Fin m)} (hT : T≠∅) (hcolumn : ∀i,column i≠T)
    {I : Finset (Fin p)} (hI : generatedSupport ∅ column I=T) : 2≤I.card := by
  by_contra hcard
  have hc : I.card=0 ∨ I.card=1 := by omega
  rcases hc with hc | hc
  · have he : I=∅ := Finset.card_eq_zero.mp hc
    subst I
    exact hT (by simpa only [generatedSupport_empty] using hI.symm)
  · obtain ⟨i, rfl⟩ := Finset.card_eq_one.mp hc
    exact hcolumn i (by simpa only [generatedSupport_singleton] using hI)

theorem column_pushforward_nonneg {m p : ℕ} (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) (hc : ∀I,2≤I.card → 0≤c I)
    {T : Finset (Fin m)} (hT : T≠∅) (hcolumn : ∀i,column i≠T) :
    0≤columnCoefficientPushforward column c T := by
  apply Finset.sum_nonneg
  intro I hI
  split_ifs with h
  · exact hc I (column_fiber_card_ge_two column hT hcolumn h)
  · rfl

theorem column_pushforward_pos {m p : ℕ} (column : Fin p → Finset (Fin m))
    (c : Finset (Fin p) → ℝ) (hc : ∀I,2≤I.card → 0≤c I)
    {T : Finset (Fin m)} (hT : T≠∅) (hcolumn : ∀i,column i≠T)
    {I : Finset (Fin p)} (hI : generatedSupport ∅ column I=T) (hpos : 0<c I) :
    0<columnCoefficientPushforward column c T := by
  have hh : c I ≤ columnCoefficientPushforward column c T := by
    have hs := Finset.single_le_sum (s:=Finset.univ)
      (f:=fun J : Finset (Fin p)=>if generatedSupport ∅ column J=T then c J else 0)
      (fun J _=>by
        split_ifs with h
        · exact hc J (column_fiber_card_ge_two column hT hcolumn h)
        · rfl) (Finset.mem_univ I)
    change c I ≤ ∑ J : Finset (Fin p), if generatedSupport ∅ column J=T then c J else 0
    simpa only [hI,ite_true] using hs
  exact hpos.trans_le hh

end NeuralGeneralization.OnlineLowerTanh
