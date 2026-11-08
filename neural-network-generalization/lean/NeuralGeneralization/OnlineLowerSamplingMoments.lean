import NeuralGeneralization.OnlineLowerSamplerEquiv

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

theorem finiteAverage_add {Ω : Type*} [Fintype Ω] (f g:Ω→ℝ) :
    finiteAverage (fun x=>f x+g x)=finiteAverage f+finiteAverage g := by
  simp only [finiteAverage,Finset.sum_add_distrib,add_div]

theorem finiteAverage_sub {Ω : Type*} [Fintype Ω] (f g:Ω→ℝ) :
    finiteAverage (fun x=>f x-g x)=finiteAverage f-finiteAverage g := by
  simp only [finiteAverage,Finset.sum_sub_distrib,sub_div]

theorem finiteAverage_nonneg {Ω : Type*} [Fintype Ω] (f:Ω→ℝ) (h:∀x,0≤f x) :
    0≤finiteAverage f := div_nonneg (Finset.sum_nonneg (fun x _=>h x)) (Nat.cast_nonneg _)

theorem finiteAverage_mul_right {Ω : Type*} [Fintype Ω] (f:Ω→ℝ) (c:ℝ) :
    finiteAverage (fun x=>f x*c)=finiteAverage f*c := by
  simpa [mul_comm] using finiteAverage_mul_left c f

theorem finiteAverage_prod_mul {α β : Type*} [Fintype α] [Fintype β]
    (f:α→ℝ) (g:β→ℝ) :
    finiteAverage (fun z:α×β=>f z.1*g z.2)=finiteAverage f*finiteAverage g := by
  rw [finiteAverage_prod (fun a b=>f a*g b)]
  simp_rw [finiteAverage_mul_left]
  exact finiteAverage_mul_right f _

theorem square_le_card_average {α : Type*} [Fintype α] [Nonempty α]
    (f:α→ℝ) (a:α) : f a^2≤Fintype.card α*finiteAverage (fun a=>f a^2) := by
  have h := Finset.single_le_sum (s:=Finset.univ) (f:=fun a=>f a^2)
    (fun a _=>sq_nonneg (f a)) (Finset.mem_univ a)
  have hn : (Fintype.card α:ℝ)≠0 := by exact_mod_cast Fintype.card_ne_zero
  calc
    f a^2 ≤ ∑ a,f a^2 := h
    _ = Fintype.card α*finiteAverage (fun a=>f a^2) := by unfold finiteAverage; field_simp

/-- Independent finite rail samples cannot both carry substantial second
moment while almost always having zero minimum. The finite support bound is
proved from the coordinate average, not assumed as a distributional tail bound. -/
theorem independent_min_square_bound {α β : Type*}
    [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (X:α→ℝ) (Y:β→ℝ) (R:ℝ)
    (hX:(Fintype.card α:ℝ)≤R) (hY:(Fintype.card β:ℝ)≤R)
    (hAB:finiteAverage (fun b=>Y b^2)≤finiteAverage (fun a=>X a^2)) :
    finiteAverage (fun b=>Y b^2) ≤
      2*R*finiteAverage (fun z:α×β=>min (X z.1^2) (Y z.2^2)) := by
  let A := finiteAverage (fun a=>X a^2)
  let B := finiteAverage (fun b=>Y b^2)
  let E := finiteAverage (fun z:α×β=>min (X z.1^2) (Y z.2^2))
  have hA : 0≤A := finiteAverage_nonneg _ (fun a=>sq_nonneg _)
  have hB : 0≤B := finiteAverage_nonneg _ (fun b=>sq_nonneg _)
  have hE : 0≤E := finiteAverage_nonneg _ (fun z=>le_min (sq_nonneg _) (sq_nonneg _))
  have hR : 0<R := lt_of_lt_of_le (by exact_mod_cast Fintype.card_pos) hX
  have hx (a:α) : X a^2≤R*A :=
    (square_le_card_average X a).trans (mul_le_mul_of_nonneg_right hX hA)
  have hy (b:β) : Y b^2≤R*B :=
    (square_le_card_average Y b).trans (mul_le_mul_of_nonneg_right hY hB)
  have hpoint (z:α×β) : X z.1^2*Y z.2^2≤R*(A+B)*min (X z.1^2) (Y z.2^2) := by
    have hm : max (X z.1^2) (Y z.2^2)≤R*(A+B) := by
      apply max_le
      · nlinarith [hx z.1]
      · nlinarith [hy z.2]
    have hh := mul_le_mul_of_nonneg_left hm (le_min (sq_nonneg (X z.1)) (sq_nonneg (Y z.2)))
    rw [min_mul_max] at hh
    nlinarith
  have havg := finiteAverage_mono _ _ hpoint
  rw [finiteAverage_prod_mul (fun a=>X a^2) (fun b=>Y b^2),finiteAverage_mul_left] at havg
  change A*B≤R*(A+B)*E at havg
  change B≤2*R*E
  change B≤A at hAB
  rcases hA.eq_or_lt with hAz | hAz
  · nlinarith
  · have hh : R*(A+B)*E≤2*A*R*E := by nlinarith [mul_nonneg (sub_nonneg.mpr hAB) (mul_nonneg hR.le hE)]
    nlinarith

end NeuralGeneralization.OnlineLowerRelu
