import FarStrongNormalizedDynamics

noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

theorem opposite_label_output_gap {X:Type*} (f:X→Bool) (out:X→ℝ) {μ:ℝ}
    (hmargin:∀x,μ≤labelReal (f x)*out x) {x y:X} (hxy:f x≠f y) :
    2*μ≤|out x-out y| := by
  have hx:=hmargin x
  have hy:=hmargin y
  cases hfx:f x <;> cases hfy:f y <;> simp_all [labelReal]
    <;> linarith [le_abs_self (out x-out y),neg_le_abs (out x-out y)]

theorem actual_cover_with_labels {X E:Type*} [PseudoMetricSpace E]
    (u:X→E) (f:X→Bool) (out:X→ℝ) (N:ℕ) {r L μ:ℝ}
    (hcover:ActualBallCover (Set.range u) N r)
    (hmargin:∀x,μ≤labelReal (f x)*out x)
    (hlip:∀x y,|out x-out y|≤L*dist (u x) (u y))
    (hsmall:L*r<2*μ) (hL:0≤L) :
    ∃C:Finset E, C.card≤N ∧ (↑C:Set E)⊆Set.range u ∧
      ∃labels:C→Bool,
        (∀x,∃c:C,labels c=f x ∧ dist (u x) c≤r) ∧
        (∀x,∀c:C,labels c≠f x→2*μ≤L*dist (u x) c) := by
  classical
  obtain ⟨C,hCS,hcard,hC⟩:=hcover
  have hrep (c:C) : ∃x:X,u x=c := hCS c.property
  choose rep hrep using hrep
  let labels:C→Bool:=fun c=>f (rep c)
  refine ⟨C,hcard,hCS,labels,?_,?_⟩
  · intro x
    obtain ⟨c,hc,hxc⟩:=hC (u x) ⟨x,rfl⟩
    let c':C:=⟨c,hc⟩
    refine ⟨c',?_,hxc⟩
    by_contra he
    have hg:=opposite_label_output_gap f out hmargin (x:=x) (y:=rep c') (fun h=>he h.symm)
    have hh:=hlip x (rep c')
    rw [hrep] at hh
    have hcL:=mul_le_mul_of_nonneg_left hxc hL
    dsimp [c'] at *
    linarith
  · intro x c hne
    have hg:=opposite_label_output_gap f out hmargin (x:=x) (y:=rep c) hne.symm
    have hh:=hlip x (rep c)
    rw [hrep] at hh
    exact hg.trans hh

theorem labeled_cover_stable_distances {X E:Type*}
    [PseudoMetricSpace E] (u:X→E) (C:Finset E) (labels:C→Bool) (f:X→Bool)
    {μ L r δ:ℝ} (hL:0<L) (hμ:0<μ)
    (hcover:∀x,∃c:C,labels c=f x ∧ dist (u x) c≤r)
    (hsep:∀x,∀c:C,labels c≠f x→2*μ≤L*dist (u x) c)
    (hr:L*r≤μ/8) (hδ:L*δ≤μ/8)
    (approx:X→E) (happrox:∀x,dist (approx x) (u x)≤δ) :
    (∀x,∃c:C,labels c=f x ∧ dist (approx x) c≤μ/(4*L)) ∧
    (∀x,∀c:C,labels c≠f x→μ/L≤dist (approx x) c) := by
  constructor
  · intro x
    obtain ⟨c,hc,hd⟩:=hcover x
    refine ⟨c,hc,?_⟩
    have htri:dist (approx x) c≤δ+r :=
      (dist_triangle _ _ _).trans (add_le_add (happrox x) hd)
    apply (le_div_iff₀ (by positivity : 0<4*L)).mpr
    have hm:=mul_le_mul_of_nonneg_left htri hL.le
    nlinarith
  · intro x c hc
    have hs:=hsep x c hc
    have ht:dist (u x) c≤δ+dist (approx x) c := by
      have hh:=dist_triangle (u x) (approx x) c
      rw [dist_comm (u x) (approx x)] at hh
      exact hh.trans (add_le_add (happrox x) le_rfl)
    have hm:=mul_le_mul_of_nonneg_left ht hL.le
    apply (div_le_iff₀ hL).mpr
    nlinarith

#print axioms actual_cover_with_labels
#print axioms labeled_cover_stable_distances
end ConditionalNonpolynomial.Analytic
