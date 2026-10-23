import NeuralGeneralization.BatchTwoImprovedGramProbability

/-! # Linear-rank Gram sampling on an active coordinate subspace

This replaces matrix Chernoff by the already verified rank-one Rademacher
bound. The loss in failure probability is polynomial; dependence on feature
rank remains linear, which preserves the paper's circuit-width exponent.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling
open Classical
variable {α : Type*} [Fintype α]

def badGramOn {m D : ℕ} (a : α → Fin D → ℝ) (T : (Fin D → ℝ) → Prop) (s : Fin m → α) : Prop :=
  ∃ v : Fin D → ℝ, T v ∧ (∑ j, (v j)^2) = 1 ∧
    (∑ i, (linearEvaluation (a (s i)) v)^2) < (m:ℝ)/2

/-- Probability is the literal sum of products of the original sampling
weights, and the bad event ranges over all real unit vectors. -/
theorem weighted_badGramOn_probability (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hmass : ∑ x, w x = 1)
    {m D : ℕ} (hm : 0 < m) (a : α → Fin D → ℝ) (T : (Fin D → ℝ) → Prop)
    (V : ℝ) (hV : 0 < V) (ha : ∀ x, ∑ j, (a x j)^2 ≤ V)
    (hpop : ∀ v : Fin D → ℝ,
      mean w (fun x => (linearEvaluation (a x) v)^2) ≤ ∑ j, (v j)^2)
    (hiso : ∀ v : Fin D → ℝ, T v →
      mean w (fun x => (linearEvaluation (a x) v)^2) = ∑ j, (v j)^2) :
    mean (iidWeight w m) (fun s => if badGramOn a T s then (1:ℝ) else 0) ≤
      (2/(m:ℝ)) * (4*(268435456*Real.sqrt (V*restrictionLog m D))^2 +
        2*(268435456*Real.sqrt (V*restrictionLog m D))*Real.sqrt ((m:ℝ)+1)) := by
  let b : (Fin m → α) → Fin D → ℝ := fun s =>
    if h : badGramOn a T s then h.choose else 0
  have hb (s : Fin m → α) : (∑ j, (b s j)^2) ≤ 1 := by
    by_cases h : badGramOn a T s
    · simp only [b, dif_pos h]
      exact h.choose_spec.2.1.le
    · simp [b, h]
  have hbbad (s : Fin m → α) (h : badGramOn a T s) :
      T (b s) ∧ (∑ j, (b s j)^2) = 1 ∧
      (∑ i, (linearEvaluation (a (s i)) (b s))^2) < (m:ℝ)/2 := by
    simpa only [b, dif_pos h] using h.choose_spec
  let p : Option (Fin m → α) → Fin D → ℝ := fun u => u.elim 0 b
  have hp (u : Option (Fin m → α)) : (∑ j, (p u j)^2) ≤ 1 := by
    cases u with
    | none => simp [p]
    | some s => exact hb s
  let Z := fun s : Fin m → α => envelope (fun u =>
    (∑ i, (linearEvaluation (a (s i)) (p u))^2) -
      m*mean w (fun x => (linearEvaluation (a x) (p u))^2))
  have hZ := weighted_gram_deviation w hw hmass hm a p none rfl V hV ha hp
    (fun u => (hpop (p u)).trans (hp u))
  have hpoint (s : Fin m → α) :
      ((m:ℝ)/2)*(if badGramOn a T s then (1:ℝ) else 0) ≤ Z s := by
    by_cases h : badGramOn a T s
    · simp only [if_pos h, mul_one]
      obtain ⟨hT, hunit, hsmall⟩ := hbbad s h
      have he := le_envelope_finite (fun u =>
        (∑ i, (linearEvaluation (a (s i)) (p u))^2) -
          m*mean w (fun x => (linearEvaluation (a x) (p u))^2)) (some s)
      change |(∑ i, (linearEvaluation (a (s i)) (b s))^2) -
        m*mean w (fun x => (linearEvaluation (a x) (b s))^2)| ≤ Z s at he
      rw [hiso (b s) hT, hunit, mul_one] at he
      have habs := neg_le_abs ((∑ i, (linearEvaluation (a (s i)) (b s))^2)-(m:ℝ))
      linarith
    · simp only [if_neg h, mul_zero]
      exact envelope_nonneg_finite _
  have hmean := mean_mono (iidWeight w m) (iidWeight_nonneg w hw m) hpoint
  rw [mean_mul] at hmean
  have hmr : 0 < (m:ℝ) := by exact_mod_cast hm
  have h := hmean.trans hZ
  have hd := (le_div_iff₀ (by positivity : 0 < (m:ℝ)/2)).mpr
    (show mean (iidWeight w m) (fun s => if badGramOn a T s then (1:ℝ) else 0) *
      ((m:ℝ)/2) ≤ _ by simpa only [mul_comm] using h)
  exact hd.trans_eq (by field_simp)

theorem weighted_badGramOn_probability_le (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hmass : ∑ x, w x = 1)
    {m D : ℕ} (hm : 0 < m) (a : α → Fin D → ℝ) (T : (Fin D → ℝ) → Prop)
    (V : ℝ) (hV : 0 < V) (ha : ∀ x, ∑ j, (a x j)^2 ≤ V)
    (hpop : ∀ v : Fin D → ℝ,
      mean w (fun x => (linearEvaluation (a x) v)^2) ≤ ∑ j, (v j)^2)
    (hiso : ∀ v : Fin D → ℝ, T v →
      mean w (fun x => (linearEvaluation (a x) v)^2) = ∑ j, (v j)^2)
    {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 256*(268435456:ℝ)^2*V*restrictionLog m D ≤ η^2*m) :
    mean (iidWeight w m) (fun s => if badGramOn a T s then (1:ℝ) else 0) ≤ η := by
  let A := 268435456*Real.sqrt (V*restrictionLog m D)
  have hA : 0 ≤ A := by dsimp [A]; positivity
  have hAsq : A^2 = (268435456:ℝ)^2*V*restrictionLog m D := by
    dsimp [A]
    rw [mul_pow, Real.sq_sqrt (mul_nonneg hV.le ((restrictionLog_ge_one hm).trans' (by norm_num)))]
    ring
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hq : 256*A^2 ≤ η^2*m := by rw [hAsq]; nlinarith only [hbudget]
  have hs0 := Real.sqrt_nonneg ((m:ℝ)+1)
  have hsq := Real.sq_sqrt (by positivity : 0 ≤ (m:ℝ)+1)
  have hηsq : η^2 ≤ η := by nlinarith
  have hlinear : 8*A^2 ≤ η*m/4 := by nlinarith
  have hcross : 4*A*Real.sqrt ((m:ℝ)+1) ≤ η*m/2 := by
    have h1 : 64*A^2*((m:ℝ)+1) ≤ η^2*m^2 := by
      nlinarith [mul_le_mul_of_nonneg_right hq (by positivity : (0:ℝ) ≤ m), sq_nonneg A]
    nlinarith [sq_nonneg (4*A*Real.sqrt ((m:ℝ)+1)),
      mul_nonneg hA hs0]
  have hh := weighted_badGramOn_probability w hw hmass hm a T V hV ha hpop hiso
  apply hh.trans
  change (2/(m:ℝ))*(4*A^2+2*A*Real.sqrt ((m:ℝ)+1)) ≤ η
  rw [div_mul_eq_mul_div]
  apply (div_le_iff₀ (by positivity : (0:ℝ) < m)).mpr
  nlinarith

/-- A homogeneous active-coordinate condition lets the good unit event
control every coefficient vector, including zero vectors. -/
theorem goodGramOn_coercivity {m D : ℕ} (a : α → Fin D → ℝ)
    (T : (Fin D → ℝ) → Prop)
    (hscale : ∀ v, T v → ∀ c : ℝ, T (fun j => c*v j))
    (s : Fin m → α) (hm : 0 < m) (hgood : ¬ badGramOn a T s)
    (v : Fin D → ℝ) (hv : T v) :
    (∑ j, (v j)^2) ≤ 2*((∑ i, (linearEvaluation (a (s i)) v)^2)/(m:ℝ)) := by
  let Q : ℝ := ∑ j, (v j)^2
  have hQ : 0 ≤ Q := Finset.sum_nonneg (fun _ _ => sq_nonneg _)
  by_cases hz : Q=0
  · rw [show (∑ j, (v j)^2)=0 from hz]
    positivity
  · have hQp : 0 < Q := lt_of_le_of_ne hQ (Ne.symm hz)
    let R := Real.sqrt Q
    have hRp : 0 < R := Real.sqrt_pos.mpr hQp
    have hR2 : R^2=Q := Real.sq_sqrt hQ
    let u := fun j => (R⁻¹)*v j
    have huT : T u := hscale v hv R⁻¹
    have hu : (∑ j, (u j)^2)=1 := by
      simp only [u,mul_pow,← Finset.mul_sum,inv_pow,hR2]
      exact inv_mul_cancel₀ hz
    have hl : (m:ℝ)/2 ≤ ∑ i, (linearEvaluation (a (s i)) u)^2 := by
      by_contra hh
      exact hgood ⟨u,huT,hu,lt_of_not_ge hh⟩
    have he (x : α) : (linearEvaluation (a x) v)^2 = Q*(linearEvaluation (a x) u)^2 := by
      have hvu : v = fun j => R*u j := by
        funext j
        simp [u,← mul_assoc,hRp.ne']
      have heval : linearEvaluation (a x) (fun j => R*u j) = R*linearEvaluation (a x) u := by
        simp [linearEvaluation,Finset.mul_sum,mul_comm,mul_left_comm]
      rw [hvu,heval,mul_pow,hR2]
    simp_rw [he]
    rw [← Finset.mul_sum]
    have hn : (0:ℝ) < m := by exact_mod_cast hm
    rw [← mul_div_assoc]
    apply (le_div_iff₀ hn).mpr
    change Q*(m:ℝ) ≤ _
    nlinarith only [mul_le_mul_of_nonneg_left hl hQ]

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
