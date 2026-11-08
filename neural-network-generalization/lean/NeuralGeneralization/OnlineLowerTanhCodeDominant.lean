import NeuralGeneralization.OnlineLowerTanhCodeColumns

/-! # A high rail-product peak lies on one retained orientation -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

theorem prod_difference_le_sum_difference {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (a b : ι→ℝ)
    (ha : ∀i∈s,0≤a i) (hab : ∀i∈s,a i≤b i) (hb : ∀i∈s,b i≤1) :
    (∏i∈s,b i)-(∏i∈s,a i)≤∑i∈s,(b i-a i) := by
  induction s using Finset.induction_on with
  | empty => simp
  | @insert i s hi ih =>
    have hi0 := ha i (Finset.mem_insert_self _ _)
    have hia := hab i (Finset.mem_insert_self _ _)
    have hib := hb i (Finset.mem_insert_self _ _)
    have has : ∀j∈s,0≤a j := fun j hj=>ha j (Finset.mem_insert_of_mem hj)
    have habs : ∀j∈s,a j≤b j := fun j hj=>hab j (Finset.mem_insert_of_mem hj)
    have hbs : ∀j∈s,b j≤1 := fun j hj=>hb j (Finset.mem_insert_of_mem hj)
    have hih := ih has habs hbs
    have hP0 : 0≤∏j∈s,b j := Finset.prod_nonneg fun j hj=>(has j hj).trans (habs j hj)
    have hP1 : (∏j∈s,b j)≤1 := Finset.prod_le_one (fun j hj=>(has j hj).trans (habs j hj)) hbs
    have hS : 0≤∑j∈s,(b j-a j) := Finset.sum_nonneg fun j hj=>sub_nonneg.mpr (habs j hj)
    have hsmall := mul_le_mul_of_nonneg_left hih hi0
    have hrest := mul_le_mul_of_nonneg_right (show a i≤1 by linarith) hS
    have hfirst := mul_le_mul_of_nonneg_left hP1 (sub_nonneg.mpr hia)
    simp only [Finset.prod_insert hi,Finset.sum_insert hi]
    nlinarith only [hsmall,hrest,hfirst]

def orientationTerm {p : ℕ} (a b : Fin p→ℝ) (θ : Fin p→Bool) : ℝ :=
  ∏i,if θ i then b i else a i

def dominantOrientation {p : ℕ} (a b : Fin p→ℝ) (i : Fin p) : Bool := decide (a i<b i)

theorem orientationTerm_nonneg {p : ℕ} (a b : Fin p→ℝ)
    (ha : ∀i,0≤a i) (hb : ∀i,0≤b i) (θ : Fin p→Bool) :
    0≤orientationTerm a b θ := by
  unfold orientationTerm
  exact Finset.prod_nonneg fun i _=>by split;exact hb i;exact ha i

theorem orientation_sum {p : ℕ} (a b : Fin p→ℝ) :
    (∑θ:Fin p→Bool,orientationTerm a b θ)=∏i,(a i+b i) := by
  have hh := Fintype.prod_sum (fun (i:Fin p) (s:Bool)=>if s then b i else a i)
  simpa only [Fintype.sum_bool,Bool.false_eq_true,if_false,if_true,orientationTerm,add_comm] using hh.symm

theorem dominantOrientation_term {p : ℕ} (a b : Fin p→ℝ) :
    orientationTerm a b (dominantOrientation a b)=∏i,max (a i) (b i) := by
  apply Finset.prod_congr rfl
  intro i _
  by_cases h:a i<b i
  · simp [dominantOrientation,h,max_eq_right h.le]
  · simp [dominantOrientation,h,max_eq_left (le_of_not_gt h)]

theorem min_le_of_product_le_square (a b ε : ℝ) (ha:0≤a) (hb:0≤b)
    (hε:0≤ε) (hprod:a*b≤ε^2) : min a b≤ε := by
  have hm0 : 0≤min a b := le_min ha hb
  have hma := min_le_left a b
  have hmb := min_le_right a b
  have hm := mul_le_mul hma hmb hm0 ha
  nlinarith

/-- Only p*epsilon mass can lie off the coordinatewise dominant orientation
when each pair has overlap at most epsilon squared. -/
theorem dominantOrientation_offmass {p : ℕ} (a b : Fin p→ℝ)
    (ha : ∀i,0≤a i) (hb : ∀i,0≤b i) (hs : ∀i,a i+b i≤1)
    (ε : ℝ) (hε:0≤ε) (hcross:∀i,a i*b i≤ε^2) :
    (∑θ∈Finset.univ.erase (dominantOrientation a b),orientationTerm a b θ)≤p*ε := by
  have hd := prod_difference_le_sum_difference Finset.univ
    (fun i=>max (a i) (b i)) (fun i=>a i+b i)
    (fun i _=>(ha i).trans (le_max_left _ _))
    (fun i _=>max_le (by linarith [hb i]) (by linarith [ha i])) (fun i _=>hs i)
  have hsplit : (∑θ∈Finset.univ.erase (dominantOrientation a b),orientationTerm a b θ)=
      (∑θ:Fin p→Bool,orientationTerm a b θ)-orientationTerm a b (dominantOrientation a b) := by
    rw [Finset.sum_erase_eq_sub (Finset.mem_univ _)]
  rw [hsplit,orientation_sum,dominantOrientation_term]
  apply hd.trans
  calc
    (∑i,(a i+b i-max (a i) (b i))) = ∑i,min (a i) (b i) := by
      apply Finset.sum_congr rfl
      intro i _
      nlinarith only [min_add_max (a i) (b i)]
    _ ≤ ∑_i:Fin p,ε := Finset.sum_le_sum fun i _=>min_le_of_product_le_square _ _ _ (ha i) (hb i) hε (hcross i)
    _ = _ := by simp

/-- A retained peak cannot be manufactured by many small non-dominant
orientations. The selected orientation is retained and has comparable mass. -/
theorem retained_dominant_peak {p : ℕ} (a b : Fin p→ℝ)
    (ha : ∀i,0≤a i) (hb : ∀i,0≤b i) (hs : ∀i,a i+b i≤1)
    (ε c μ : ℝ) (hε:0≤ε) (hc0:0≤c) (hc1:c≤1) (hμ:0<μ)
    (hcross:∀i,a i*b i≤ε^2) (hsmall:(p:ℝ)*ε≤μ/2)
    (A:Finset (Fin p→Bool)) (hpeak:μ≤c*(∑θ∈A,orientationTerm a b θ)) :
    dominantOrientation a b∈A ∧ μ/2≤c*orientationTerm a b (dominantOrientation a b) := by
  let θstar := dominantOrientation a b
  have hnon := orientationTerm_nonneg a b ha hb
  have hoff := dominantOrientation_offmass a b ha hb hs ε hε hcross
  have hsub : A.erase θstar⊆Finset.univ.erase θstar := by
    intro θ hθ
    exact Finset.mem_erase.mpr ⟨(Finset.mem_erase.mp hθ).1,Finset.mem_univ _⟩
  have herr : (∑θ∈A.erase θstar,orientationTerm a b θ)≤(p:ℝ)*ε :=
    (Finset.sum_le_sum_of_subset_of_nonneg hsub (fun θ _ _=>hnon θ)).trans hoff
  have hsum0 : 0≤∑θ∈A.erase θstar,orientationTerm a b θ := Finset.sum_nonneg fun θ _=>hnon θ
  have hcerr : c*(∑θ∈A.erase θstar,orientationTerm a b θ)≤μ/2 :=
    (mul_le_of_le_one_left hsum0 hc1).trans (herr.trans hsmall)
  have hmem : θstar∈A := by
    by_contra hnot
    rw [Finset.erase_eq_of_notMem hnot] at hcerr
    linarith
  have heq := Finset.sum_erase_add A (orientationTerm a b) hmem
  refine ⟨hmem,?_⟩
  have heqm := congrArg (fun v : ℝ=>c*v) heq
  change μ/2≤c*orientationTerm a b θstar
  nlinarith only [heqm,hpeak,hcerr]

end NeuralGeneralization.OnlineLowerTanh
