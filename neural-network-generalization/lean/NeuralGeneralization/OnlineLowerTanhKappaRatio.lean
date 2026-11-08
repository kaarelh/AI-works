import NeuralGeneralization.OnlineLowerTanhScalarBounds

/-! Uniform second-order control of exact central-binomial ratios. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def kappaShiftProduct (n:ℝ) (j:ℕ) : ℝ :=
  ∏l∈Finset.range j,(n+2*(l:ℝ))/(n+2*(l:ℝ)+1)

lemma kappaShiftProduct_succ (n:ℝ) (j:ℕ) :
    kappaShiftProduct n (j+1)=kappaShiftProduct n j*((n+2*(j:ℝ))/(n+2*(j:ℝ)+1)) := by
  unfold kappaShiftProduct
  rw [Finset.prod_range_succ]

lemma kappaShiftProduct_bounds (n:ℝ) (hn:0<n) (j:ℕ) :
    0<kappaShiftProduct n j ∧ kappaShiftProduct n j≤1 := by
  unfold kappaShiftProduct
  constructor
  · apply Finset.prod_pos
    intro l _
    exact div_pos (by positivity) (by positivity)
  · apply Finset.prod_le_one
    · intro l _
      positivity
    · intro l _
      exact (div_le_one (by positivity)).mpr (by linarith)

lemma kappaShiftProduct_error (n:ℝ) (hn:0<n) (j:ℕ) :
    0≤kappaShiftProduct n j-(1-(j:ℝ)/n) ∧
      kappaShiftProduct n j-(1-(j:ℝ)/n)≤2*(j:ℝ)^2/n^2 := by
  induction j with
  | zero => simp [kappaShiftProduct]
  | succ j ih =>
    let p:=kappaShiftProduct n j
    let d:=n+2*(j:ℝ)+1
    have hp:=kappaShiftProduct_bounds n hn j
    change 0<p ∧ p≤1 at hp
    have hd:0<d := by dsimp [d]; positivity
    have hnd:n≤d := by dsimp [d]; nlinarith [Nat.cast_nonneg (α:=ℝ) j]
    have hid : kappaShiftProduct n (j+1)-(1-((j+1:ℕ):ℝ)/n)=
        (p-(1-(j:ℝ)/n))+(2*(j:ℝ)+1)/(n*d)+(1-p)/d := by
      rw [kappaShiftProduct_succ]
      dsimp [p,d]
      push_cast
      field_simp
      ring
    rw [hid]
    constructor
    · exact add_nonneg (add_nonneg ih.1 (by positivity)) (div_nonneg (sub_nonneg.mpr hp.2) hd.le)
    · have hfirst : (2*(j:ℝ)+1)/(n*d)≤(2*(j:ℝ)+1)/n^2 := by
        apply div_le_div_of_nonneg_left (by positivity) (sq_pos_of_pos hn)
        nlinarith
      have hsecond : (1-p)/d≤(j:ℝ)/n^2 := by
        calc
          _ ≤ ((j:ℝ)/n)/d := div_le_div_of_nonneg_right (by linarith [ih.1]) hd.le
          _ ≤ ((j:ℝ)/n)/n := div_le_div_of_nonneg_left (by positivity) hn hnd
          _ = _ := by ring
      have hsum:=add_le_add (add_le_add ih.2 hfirst) hsecond
      apply hsum.trans
      push_cast
      rw [←add_div,←add_div]
      apply (div_le_div_iff_of_pos_right (sq_pos_of_pos hn)).mpr
      nlinarith [Nat.cast_nonneg (α:=ℝ) j]

lemma oddParityKappa_ratio_recurrence (r:ℕ) :
    oddParityKappa (r+1)=oddParityKappa r*((2*(r:ℝ)+1)/(2*(r:ℝ)+2)) := by
  have h:=OnlineLowerRelu.evenReluKappa_recurrence r
  simp_rw [oddParityKappa_eq_twice_relu]
  have hd:2*(r:ℝ)+2≠0 := by positivity
  field_simp
  nlinarith

lemma oddParityKappa_shift_ratio (r j:ℕ) :
    oddParityKappa (r+j)/oddParityKappa r=kappaShiftProduct (2*(r:ℝ)+1) j := by
  induction j with
  | zero => simp [kappaShiftProduct,(oddParityKappa_pos r).ne']
  | succ j ih =>
    rw [show r+(j+1)=(r+j)+1 by omega,oddParityKappa_ratio_recurrence,kappaShiftProduct_succ]
    have hk:oddParityKappa r≠0 := (oddParityKappa_pos r).ne'
    rw [show oddParityKappa (r+j)*((2*((r+j:ℕ):ℝ)+1)/(2*((r+j:ℕ):ℝ)+2))/oddParityKappa r=
      (oddParityKappa (r+j)/oddParityKappa r)*((2*((r+j:ℕ):ℝ)+1)/(2*((r+j:ℕ):ℝ)+2)) by ring,ih]
    congr 1
    push_cast
    congr 1 <;> ring

end NeuralGeneralization.OnlineLowerTanh
