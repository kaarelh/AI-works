import NeuralGeneralization.OnlineLowerCostPath
import Mathlib.Order.Monotone.Defs
import Mathlib.Logic.Function.Iterate

/-! # Path ordering from finite differences

A positive decreasing scalar function yields path digit weights which
shrink by a factor of at least three. This proves a common lexicographic
order directly, without an inverse Laplace representation.
-/
noncomputable section
open Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower

def weightedSignedSeries (w : ℕ → ℝ) : List Bool → ℝ
  | [] => 0
  | b::bs => digitSign b*w 0 + weightedSignedSeries (fun j => w (j+1)) bs

theorem weightedSignedSeries_abs_le (w : ℕ → ℝ) (bs : List Bool)
    (hw : ∀ j, 0 ≤ w j)
    (hstep : ∀ j < bs.length, 3*w (j+1) ≤ w j) :
    |weightedSignedSeries w bs| ≤ 3/2*w 0 := by
  induction bs generalizing w with
  | nil => simp only [weightedSignedSeries, abs_zero]; exact mul_nonneg (by norm_num) (hw 0)
  | cons b bs ih =>
      have ht := ih (fun j => w (j+1)) (fun j => hw (j+1))
        (fun j hj => hstep (j+1) (by simp only [List.length_cons]; omega))
      have hs := hstep 0 (by simp)
      calc
        |weightedSignedSeries w (b::bs)| ≤ |digitSign b*w 0| +
            |weightedSignedSeries (fun j => w (j+1)) bs| := abs_add_le _ _
        _ = w 0 + |weightedSignedSeries (fun j => w (j+1)) bs| := by
          rw [abs_mul, abs_digitSign, one_mul, abs_of_nonneg (hw 0)]
        _ ≤ w 0 + 3/2*w 1 := by simpa only [Nat.zero_add] using add_le_add le_rfl ht
        _ ≤ 3/2*w 0 := by linarith

theorem weightedSignedSeries_lt (w : ℕ → ℝ) {xs ys : List Bool}
    (hw : ∀ j, 0 < w j) (hlen : xs.length=ys.length)
    (hstep : ∀ j < xs.length, 3*w (j+1) ≤ w j)
    (hlex : digitLexLt xs ys) :
    weightedSignedSeries w xs < weightedSignedSeries w ys := by
  induction xs generalizing w ys with
  | nil => exact hlex.elim
  | cons a xs ih =>
      cases ys with
      | nil => simp at hlen
      | cons b ys =>
          have hlen' : xs.length=ys.length := by simpa using hlen
          have hsteps (j : ℕ) (hj : j < xs.length) : 3*w (j+1+1) ≤ w (j+1) :=
            hstep (j+1) (by simp only [List.length_cons]; omega)
          rcases hlex with ⟨ha,hb⟩ | ⟨hab,ht⟩
          · subst a
            subst b
            have hx := abs_le.mp (weightedSignedSeries_abs_le (fun j => w (j+1)) xs
              (fun j => (hw (j+1)).le) hsteps)
            have hy := abs_le.mp (weightedSignedSeries_abs_le (fun j => w (j+1)) ys
              (fun j => (hw (j+1)).le) (by simpa only [← hlen'] using hsteps))
            have hs := hstep 0 (by simp)
            simp only [weightedSignedSeries, digitSign, Bool.false_eq_true, if_false, if_true]
            nlinarith [hw 0]
          · subst b
            have hi := ih (fun j => w (j+1)) (fun j => hw (j+1)) hlen' hsteps ht
            exact add_lt_add_right hi _

theorem weightedSignedSeries_injective_on_length (w : ℕ → ℝ) (N : ℕ)
    (hw : ∀ j, 0 < w j) (hstep : ∀ j < N, 3*w (j+1) ≤ w j) :
    Set.InjOn (weightedSignedSeries w) {bs | bs.length=N} := by
  intro xs hx ys hy he
  change xs.length=N at hx
  change ys.length=N at hy
  by_contra hn
  have hlen : xs.length=ys.length := hx.trans hy.symm
  rcases digitLexLt_or_reverse hlen hn with h | h
  · exact (weightedSignedSeries_lt w hw hlen (by simpa only [hx] using hstep) h).ne he
  · exact (weightedSignedSeries_lt w hw hlen.symm (by simpa only [hy] using hstep) h).ne he.symm

def tripleShift (h : ℝ) (f : ℝ → ℝ) (x : ℝ) : ℝ :=
  f x + f (x+h) + f (x+2*h)

theorem tripleShift_pos (h a : ℝ) (f : ℝ → ℝ) (hh : 0 ≤ h)
    (hf : ∀ x ∈ Ici a, 0 < f x) : ∀ x ∈ Ici a, 0 < tripleShift h f x := by
  intro x hx
  exact add_pos (add_pos (hf x hx) (hf (x+h) (by simp only [mem_Ici] at *; linarith)))
    (hf (x+2*h) (by simp only [mem_Ici] at *; linarith))

theorem tripleShift_antitone (h a : ℝ) (f : ℝ → ℝ) (hh : 0 ≤ h)
    (hf : AntitoneOn f (Ici a)) : AntitoneOn (tripleShift h f) (Ici a) := by
  intro x hx y hy hxy
  apply add_le_add
  · exact add_le_add (hf hx hy hxy)
      (hf (by simp only [mem_Ici] at *; linarith)
        (by simp only [mem_Ici] at *; linarith) (by linarith))
  · exact hf (by simp only [mem_Ici] at *; linarith)
      (by simp only [mem_Ici] at *; linarith) (by linarith)

theorem tripleShift_iterate_pos (h a : ℝ) (f : ℝ → ℝ) (hh : 0 ≤ h)
    (hf : ∀ x ∈ Ici a, 0 < f x) (L : ℕ) :
    ∀ x ∈ Ici a, 0 < (tripleShift h)^[L] f x := by
  induction L with
  | zero => exact hf
  | succ L ih =>
      rw [Function.iterate_succ_apply']
      exact tripleShift_pos h a _ hh ih

theorem tripleShift_iterate_antitone (h a : ℝ) (f : ℝ → ℝ) (hh : 0 ≤ h)
    (hf : AntitoneOn f (Ici a)) (L : ℕ) :
    AntitoneOn ((tripleShift h)^[L] f) (Ici a) := by
  induction L with
  | zero => exact hf
  | succ L ih =>
      rw [Function.iterate_succ_apply']
      exact tripleShift_antitone h a _ hh ih

def pathDifferenceWeight (h : ℝ) (f : ℝ → ℝ) (L : ℕ) (x : ℝ) (j : ℕ) : ℝ :=
  (tripleShift h)^[L-j] f (x+2*j*h)

theorem pathDifferenceWeight_pos (h a x : ℝ) (f : ℝ → ℝ) (L : ℕ)
    (hh : 0 ≤ h) (hx : a ≤ x) (hf : ∀ x ∈ Ici a, 0 < f x) (j : ℕ) :
    0 < pathDifferenceWeight h f L x j := by
  apply tripleShift_iterate_pos h a f hh hf
  simp only [mem_Ici]
  have hj : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  nlinarith

theorem pathDifferenceWeight_step (h a x : ℝ) (f : ℝ → ℝ) (L : ℕ)
    (hh : 0 ≤ h) (hx : a ≤ x) (hf : AntitoneOn f (Ici a))
    (j : ℕ) (hj : j < L) :
    3*pathDifferenceWeight h f L x (j+1) ≤ pathDifferenceWeight h f L x j := by
  unfold pathDifferenceWeight
  rw [show L-j=(L-(j+1))+1 by omega, Function.iterate_succ_apply']
  let g := (tripleShift h)^[L-(j+1)] f
  change 3*g (x+2*(j+1 : ℕ)*h) ≤ tripleShift h g (x+2*j*h)
  have hg := tripleShift_iterate_antitone h a f hh hf (L-(j+1))
  change AntitoneOn g (Ici a) at hg
  have hxj : a ≤ x+2*j*h := by
    have hnonneg : 0 ≤ 2*(j : ℝ)*h := by positivity
    linarith
  have h₁ := hg (show x+2*j*h ∈ Ici a from hxj)
    (show x+2*(j+1 : ℕ)*h ∈ Ici a by simp only [mem_Ici]; push_cast; nlinarith)
    (show x+2*j*h ≤ x+2*(j+1 : ℕ)*h by push_cast; nlinarith)
  have h₂ := hg (show x+2*j*h+h ∈ Ici a by simp only [mem_Ici]; linarith)
    (show x+2*(j+1 : ℕ)*h ∈ Ici a by simp only [mem_Ici]; push_cast; nlinarith)
    (show x+2*j*h+h ≤ x+2*(j+1 : ℕ)*h by push_cast; nlinarith)
  have he : x+2*(j+1 : ℕ)*h = x+2*j*h+2*h := by push_cast; ring
  rw [he] at h₁ h₂ ⊢
  unfold tripleShift
  linarith

/-- A single ordering separates all signed path candidates simultaneously
for every positive decreasing finite-difference profile. -/
theorem finiteDifference_path_strict_order (h a x : ℝ) (f : ℝ → ℝ) (L : ℕ)
    (hh : 0 ≤ h) (hx : a ≤ x) (hf : ∀ x ∈ Ici a, 0 < f x)
    (hmono : AntitoneOn f (Ici a)) {xs ys : List Bool}
    (hlen : xs.length=ys.length) (hL : xs.length ≤ L) (hlex : digitLexLt xs ys) :
    weightedSignedSeries (pathDifferenceWeight h f L x) xs <
      weightedSignedSeries (pathDifferenceWeight h f L x) ys := by
  apply weightedSignedSeries_lt _ (pathDifferenceWeight_pos h a x f L hh hx hf) hlen
    (fun j hj => pathDifferenceWeight_step h a x f L hh hx hmono j (lt_of_lt_of_le hj hL)) hlex

/-- The finite estimate never asks for a comparison beyond the last digit. -/
theorem weightedSignedSeries_abs_le_finite (w:ℕ→ℝ) (bs:List Bool)
    (hw:∀j,0≤w j) (hstep:∀j,j+1<bs.length→3*w (j+1)≤w j) :
    |weightedSignedSeries w bs|≤3/2*w 0 := by
  induction bs generalizing w with
  | nil => simp only [weightedSignedSeries,abs_zero];exact mul_nonneg (by norm_num) (hw 0)
  | cons b bs ih =>
    cases bs with
    | nil =>
      simp only [weightedSignedSeries,add_zero,abs_mul,abs_digitSign,one_mul,abs_of_nonneg (hw 0)]
      linarith [hw 0]
    | cons c cs =>
      have ht:=ih (fun j=>w (j+1)) (fun j=>hw (j+1))
        (fun j hj=>hstep (j+1) (by simp only [List.length_cons] at *;omega))
      have hs:=hstep 0 (by simp)
      calc
        _≤|digitSign b*w 0|+|weightedSignedSeries (fun j=>w (j+1)) (c::cs)|:=abs_add_le _ _
        _=w 0+|weightedSignedSeries (fun j=>w (j+1)) (c::cs)|:=by
          rw [abs_mul,abs_digitSign,one_mul,abs_of_nonneg (hw 0)]
        _≤w 0+3/2*w 1:=by simpa only [Nat.zero_add] using add_le_add le_rfl ht
        _≤3/2*w 0:=by linarith

/-- Only ratios between actual consecutive digits are needed for separation. -/
theorem weightedSignedSeries_lt_finite (w:ℕ→ℝ) {xs ys:List Bool}
    (hw:∀j,0<w j) (hlen:xs.length=ys.length)
    (hstep:∀j,j+1<xs.length→3*w (j+1)≤w j) (hlex:digitLexLt xs ys) :
    weightedSignedSeries w xs<weightedSignedSeries w ys := by
  induction xs generalizing w ys with
  | nil => exact hlex.elim
  | cons a xs ih =>
    cases ys with
    | nil => simp at hlen
    | cons b ys =>
      have hlen':xs.length=ys.length:=by simpa using hlen
      have hsteps (j:ℕ) (hj:j+1<xs.length):3*w (j+1+1)≤w (j+1):=
        hstep (j+1) (by simp only [List.length_cons];omega)
      rcases hlex with ⟨ha,hb⟩|⟨hab,ht⟩
      · subst a;subst b
        by_cases hxs:xs=[]
        · subst xs
          have hys:ys=[]:=List.length_eq_zero_iff.mp (by simpa using hlen'.symm)
          subst ys
          simp only [weightedSignedSeries,digitSign,Bool.false_eq_true,if_false,if_true,add_zero,one_mul,neg_one_mul]
          linarith [hw 0]
        · have hx:=abs_le.mp (weightedSignedSeries_abs_le_finite (fun j=>w (j+1)) xs
            (fun j=>(hw (j+1)).le) hsteps)
          have hy:=abs_le.mp (weightedSignedSeries_abs_le_finite (fun j=>w (j+1)) ys
            (fun j=>(hw (j+1)).le) (by simpa only [←hlen'] using hsteps))
          have hlenpos:0<xs.length:=List.length_pos_iff.mpr hxs
          have hs:=hstep 0 (by simp only [List.length_cons];omega)
          simp only [weightedSignedSeries,digitSign,Bool.false_eq_true,if_false,if_true]
          nlinarith [hw 0]
      · subst b
        exact add_lt_add_right (ih (fun j=>w (j+1)) (fun j=>hw (j+1)) hlen' hsteps ht) _

/-- The final valid path weight is indexed by `L`; hence `L+1` free digits
are permitted. This is the sharp indexing used by the triangular family. -/
theorem finiteDifference_path_strict_order_succ (h a x:ℝ) (f:ℝ→ℝ) (L:ℕ)
    (hh:0≤h) (hx:a≤x) (hf:∀x∈Ici a,0<f x) (hmono:AntitoneOn f (Ici a))
    {xs ys:List Bool} (hlen:xs.length=ys.length) (hL:xs.length≤L+1)
    (hlex:digitLexLt xs ys) :
    weightedSignedSeries (pathDifferenceWeight h f L x) xs<
      weightedSignedSeries (pathDifferenceWeight h f L x) ys := by
  apply weightedSignedSeries_lt_finite _ (pathDifferenceWeight_pos h a x f L hh hx hf) hlen
    (fun j hj=>pathDifferenceWeight_step h a x f L hh hx hmono j (by omega)) hlex


end NeuralGeneralization.OnlineLowerTanh
