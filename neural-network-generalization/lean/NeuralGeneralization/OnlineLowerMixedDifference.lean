import Mathlib.Analysis.Convex.Deriv
import Mathlib.Tactic

/-! Mean-value representation and sign bounds for actual mixed backward differences. -/
noncomputable section
open Set
namespace NeuralGeneralization.OnlineLowerTanh

def mixedBackwardDifference : List ℝ → (ℝ→ℝ) → ℝ→ℝ
  | [],f => f
  | h::hs,f => fun x=>mixedBackwardDifference hs f x-mixedBackwardDifference hs f (x+h)

lemma mixedBackwardDifference_hasDerivAt (hs:List ℝ) (f f':ℝ→ℝ) (a:ℝ)
    (hsteps:∀h∈hs,0≤h) (hder:∀t,a≤t → HasDerivAt f (f' t) t)
    (x:ℝ) (hx:a≤x) :
    HasDerivAt (mixedBackwardDifference hs f) (mixedBackwardDifference hs f' x) x := by
  induction hs generalizing x with
  | nil => exact hder x hx
  | cons h hs ih =>
    have hh:0≤h := hsteps h (by simp)
    have hrest:∀b∈hs,0≤b := fun b hb=>hsteps b (by simp [hb])
    have h1:=ih hrest x hx
    have h2:=ih hrest (x+h) (by linarith)
    convert! h1.sub (h2.comp x ((hasDerivAt_id x).add_const h)) using 1 <;> simp [mixedBackwardDifference]

/-- Exact mixed mean-value representation on the complete range of shifted
arguments. Each positive step contributes one actual derivative. -/
theorem mixedBackwardDifference_mean_value (hs:List ℝ) (F:ℕ→ℝ→ℝ) (a x:ℝ)
    (hsteps:∀h∈hs,0<h) (hx:a≤x)
    (hder:∀j<hs.length,∀t,a≤t → HasDerivAt (F j) (F (j+1) t) t) :
    ∃ξ∈Icc x (x+hs.sum),
      mixedBackwardDifference hs (F 0) x=hs.prod*((-1:ℝ)^hs.length*F hs.length ξ) := by
  induction hs generalizing F x with
  | nil => exact ⟨x,by simp,by simp [mixedBackwardDifference]⟩
  | cons h hs ih =>
    have hh:0<h := hsteps h (by simp)
    have hrest:∀b∈hs,0<b := fun b hb=>hsteps b (by simp [hb])
    have hd0:∀t,a≤t → HasDerivAt (F 0) (F 1 t) t :=
      hder 0 (by simp)
    have hdg (t:ℝ) (ht:a≤t) :
        HasDerivAt (mixedBackwardDifference hs (F 0))
          (mixedBackwardDifference hs (F 1) t) t :=
      mixedBackwardDifference_hasDerivAt hs (F 0) (F 1) a (fun b hb=>(hrest b hb).le) hd0 t ht
    obtain ⟨t,ht,htder⟩:=exists_hasDerivAt_eq_slope
      (mixedBackwardDifference hs (F 0)) (mixedBackwardDifference hs (F 1))
      (show x<x+h by linarith)
      (fun y hy=>(hdg y (hx.trans hy.1)).continuousAt.continuousWithinAt)
      (fun y hy=>hdg y (hx.trans hy.1.le))
    have hshift:∀j<hs.length,∀t,a≤t → HasDerivAt (F (j+1)) (F ((j+1)+1) t) t := by
      intro j hj t ht
      exact hder (j+1) (by simp only [List.length_cons]; omega) t ht
    obtain ⟨ξ,hξ,hvalue⟩:=ih (fun j=>F (j+1)) t hrest (hx.trans ht.1.le) hshift
    refine ⟨ξ,⟨le_trans ht.1.le hξ.1,?_⟩,?_⟩
    · simp only [List.sum_cons]
      linarith [hξ.2,ht.2]
    · simp only [mixedBackwardDifference,List.prod_cons,List.length_cons,pow_succ]
      have htEq: mixedBackwardDifference hs (F 1) t*h=
          mixedBackwardDifference hs (F 0) (x+h)-mixedBackwardDifference hs (F 0) x := by
        rw [show x+h-x=h by ring] at htder
        exact (eq_div_iff hh.ne').mp htder
      change mixedBackwardDifference hs (F 1) t=hs.prod*((-1:ℝ)^hs.length*F (hs.length+1) ξ) at hvalue
      rw [hvalue] at htEq
      nlinarith

lemma mixedBackwardDifference_bounds (hs:List ℝ) (F:ℕ→ℝ→ℝ) (a x L U:ℝ)
    (hsteps:∀h∈hs,0<h) (hx:a≤x)
    (hder:∀j<hs.length,∀t,a≤t → HasDerivAt (F j) (F (j+1) t) t)
    (hL:∀t∈Icc x (x+hs.sum),L≤(-1:ℝ)^hs.length*F hs.length t)
    (hU:∀t∈Icc x (x+hs.sum),(-1:ℝ)^hs.length*F hs.length t≤U) :
    hs.prod*L≤mixedBackwardDifference hs (F 0) x ∧
      mixedBackwardDifference hs (F 0) x≤hs.prod*U := by
  obtain ⟨ξ,hξ,he⟩:=mixedBackwardDifference_mean_value hs F a x hsteps hx hder
  have hp:0≤hs.prod := List.prod_nonneg (fun h hh=>(hsteps h hh).le)
  rw [he]
  exact ⟨mul_le_mul_of_nonneg_left (hL ξ hξ) hp,mul_le_mul_of_nonneg_left (hU ξ hξ) hp⟩

lemma mixedBackwardDifference_pos (hs:List ℝ) (F:ℕ→ℝ→ℝ) (a x:ℝ)
    (hsteps:∀h∈hs,0<h) (hx:a≤x)
    (hder:∀j<hs.length,∀t,a≤t → HasDerivAt (F j) (F (j+1) t) t)
    (hpos:∀t,a≤t → 0<(-1:ℝ)^hs.length*F hs.length t) :
    0<mixedBackwardDifference hs (F 0) x := by
  obtain ⟨ξ,hξ,he⟩:=mixedBackwardDifference_mean_value hs F a x hsteps hx hder
  rw [he]
  exact mul_pos (List.prod_pos hsteps) (hpos ξ (hx.trans hξ.1))

lemma mixedBackwardDifference_antitone (hs:List ℝ) (F:ℕ→ℝ→ℝ) (a:ℝ)
    (hsteps:∀h∈hs,0<h)
    (hder:∀j<hs.length+1,∀t,a≤t → HasDerivAt (F j) (F (j+1) t) t)
    (hpos:∀t,a≤t → 0<(-1:ℝ)^(hs.length+1)*F (hs.length+1) t) :
    AntitoneOn (mixedBackwardDifference hs (F 0)) (Ici a) := by
  intro x hx y hy hxy
  rcases eq_or_lt_of_le hxy with h|h
  · subst y; rfl
  · have hp:=mixedBackwardDifference_pos ((y-x)::hs) F a x
      (by intro b hb; rcases List.mem_cons.mp hb with hb|hb
          · subst b; linarith
          · exact hsteps b hb) hx (by simpa only [List.length_cons] using hder)
      (by simpa only [List.length_cons] using hpos)
    simp only [mixedBackwardDifference,show x+(y-x)=y by ring] at hp
    linarith

/-- Inverse-power derivative bounds transfer to mixed differences with the
exact product of step lengths and only the full interval length in the lower
endpoint. This is sufficient for the quantitative path construction. -/
theorem mixedBackwardDifference_inverse_power_bounds
    (hs:List ℝ) (F:ℕ→ℝ→ℝ) (a x cL cU:ℝ) (p:ℕ)
    (hsteps:∀h∈hs,0<h) (hx:a≤x) (hx0:0<x) (hcL:0≤cL) (hcU:0≤cU)
    (hder:∀j<hs.length,∀t,a≤t → HasDerivAt (F j) (F (j+1) t) t)
    (hL:∀t,x≤t → cL/t^p≤(-1:ℝ)^hs.length*F hs.length t)
    (hU:∀t,x≤t → (-1:ℝ)^hs.length*F hs.length t≤cU/t^p) :
    hs.prod*(cL/(x+hs.sum)^p)≤mixedBackwardDifference hs (F 0) x ∧
      mixedBackwardDifference hs (F 0) x≤hs.prod*(cU/x^p) := by
  apply mixedBackwardDifference_bounds hs F a x _ _ hsteps hx hder
  · intro t ht
    exact (div_le_div_of_nonneg_left hcL (pow_pos (hx0.trans_le ht.1) p)
      (pow_le_pow_left₀ (hx0.trans_le ht.1).le ht.2 p)).trans (hL t ht.1)
  · intro t ht
    exact (hU t ht.1).trans (div_le_div_of_nonneg_left hcU (pow_pos hx0 p)
      (pow_le_pow_left₀ hx0.le ht.1 p))

end NeuralGeneralization.OnlineLowerTanh
