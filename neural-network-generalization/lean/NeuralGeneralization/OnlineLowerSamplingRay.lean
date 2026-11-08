import NeuralGeneralization.OnlineLowerSamplingChoice

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

def scalarRailDefect {p:ℕ} (v:Fin p×Bool→ℝ) : ℝ :=
  (∑ i,min (v (i,false)^2) (v (i,true)^2))+
    scalarSpread (fun i=>max (v (i,false)) (v (i,true)))

def scalarRayError {p:ℕ} (v:Fin p×Bool→ℝ) (θ:Fin p→Bool) (c:ℝ) : ℝ :=
  ∑ i,((v (i,θ i)-c)^2+v (i,!(θ i))^2)

def weightedRayError {p:ℕ} (w:Fin p×Bool→ℝ) (v:Fin p×Bool→ℝ)
    (θ:Fin p→Bool) (c:ℝ) : ℝ :=
  ∑ i,(w (i,θ i)*(v (i,θ i)-c)^2+w (i,!(θ i))*v (i,!(θ i))^2)

theorem scalarRailDefect_nonneg {p:ℕ} (v:Fin p×Bool→ℝ) : 0≤scalarRailDefect v :=
  add_nonneg (Finset.sum_nonneg (fun i _=>le_min (sq_nonneg _) (sq_nonneg _)))
    (scalarSpread_nonneg _)

theorem pair_min_max_error (z t c:ℝ) (hz:0≤z) (ht:0≤t) (hc:0≤c) :
    min (z^2) (t^2)+(max z t-c)^2≤(z-c)^2+t^2 := by
  by_cases h:z≤t
  · have hs:z^2≤t^2 := by nlinarith
    rw [min_eq_left hs,max_eq_right h]
    nlinarith [mul_nonneg (sub_nonneg.mpr h) hc]
  · have h' := le_of_not_ge h
    have hs:t^2≤z^2 := by nlinarith
    rw [min_eq_right hs,max_eq_left h']
    ring_nf
    rfl

theorem scalarRailDefect_le_error {p:ℕ} (hp:0<p) (v:Fin p×Bool→ℝ)
    (hv:∀j,0≤v j) (θ:Fin p→Bool) (c:ℝ) (hc:0≤c) :
    scalarRailDefect v≤scalarRayError v θ c := by
  have hs := scalarSpread_le_shift hp (fun i=>max (v (i,false)) (v (i,true))) c
  unfold scalarRailDefect scalarRayError
  calc
    _ ≤ (∑ i,min (v (i,false)^2) (v (i,true)^2))+
        ∑ i,(max (v (i,false)) (v (i,true))-c)^2 := by linarith
    _ = ∑ i,(min (v (i,false)^2) (v (i,true)^2)+
        (max (v (i,false)) (v (i,true))-c)^2) := (Finset.sum_add_distrib).symm
    _ ≤ _ := by
      apply Finset.sum_le_sum
      intro i _
      cases hθ:θ i
      · simp only [hθ,Bool.not_false]
        exact pair_min_max_error _ _ c (hv _) (hv _) hc
      · simp only [hθ,Bool.not_true]
        simpa only [min_comm,max_comm] using pair_min_max_error (v (i,true)) (v (i,false)) c (hv _) (hv _) hc

theorem weightedRayError_nonneg {p:ℕ} (w:Fin p×Bool→ℝ) (hw:∀j,0≤w j)
    (v:Fin p×Bool→ℝ) (θ:Fin p→Bool) (c:ℝ) : 0≤weightedRayError w v θ c := by
  exact Finset.sum_nonneg (fun i _=>add_nonneg
    (mul_nonneg (hw _) (sq_nonneg _)) (mul_nonneg (hw _) (sq_nonneg _)))

theorem weightedRayError_lower {p:ℕ} (w:Fin p×Bool→ℝ) (r:ℝ)
    (hw:∀j,r≤w j) (v:Fin p×Bool→ℝ) (θ:Fin p→Bool) (c:ℝ) :
    r*scalarRayError v θ c≤weightedRayError w v θ c := by
  unfold scalarRayError weightedRayError
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have h1:=mul_le_mul_of_nonneg_right (hw (i,θ i)) (sq_nonneg (v (i,θ i)-c))
  have h2:=mul_le_mul_of_nonneg_right (hw (i,!(θ i))) (sq_nonneg (v (i,!(θ i))))
  nlinarith

section Actual
variable {p:ℕ} {β:(Fin p×Bool)→Type*}
variable [∀j,Fintype (β j)] [∀j,Nonempty (β j)]

def deterministicGain (u:(j:Fin p×Bool)→β j→ℝ) : ℝ :=
  scalarMean (fun i=>finiteAverage (fun pick:(j:Fin p×Bool)→β j=>chosenSample u pick i))

def originalRayError (u:(j:Fin p×Bool)→β j→ℝ) (θ:Fin p→Bool) (c:ℝ) : ℝ :=
  ∑ i,((∑ a:β (i,θ i),(u (i,θ i) a-c)^2)+
    ∑ a:β (i,!(θ i)),u (i,!(θ i)) a^2)

theorem deterministicGain_nonneg (u:(j:Fin p×Bool)→β j→ℝ) (hu:∀j a,0≤u j a) :
    0≤deterministicGain u := by
  unfold deterministicGain scalarMean
  apply div_nonneg
  · apply Finset.sum_nonneg
    intro i _
    apply finiteAverage_nonneg
    intro pick
    exact hu _ _
  · exact Nat.cast_nonneg _

theorem chosen_defect_eq (u:(j:Fin p×Bool)→β j→ℝ) (pick:(j:Fin p×Bool)→β j) :
    (∑ i,min (chosenSample u pick i^2) (discardedSample u pick i^2))+
      scalarSpread (fun i=>max (chosenSample u pick i) (discardedSample u pick i)) =
      scalarRailDefect (fun j=>u j (pick j)) := by
  unfold scalarRailDefect
  congr 1
  · apply Finset.sum_congr rfl
    intro i _
    unfold chosenSample discardedSample
    cases secondMomentChoice u i
    · rfl
    · exact min_comm _ _
  · congr 1
    funext i
    unfold chosenSample discardedSample
    cases secondMomentChoice u i
    · rfl
    · exact max_comm _ _

theorem sum_eq_card_average {α:Type*} [Fintype α] [Nonempty α] (f:α→ℝ) :
    (∑a,f a)=(Fintype.card α:ℝ)*finiteAverage f := by
  have hn:(Fintype.card α:ℝ)≠0 := by exact_mod_cast Fintype.card_ne_zero
  unfold finiteAverage
  field_simp

theorem originalRayError_le_average (u:(j:Fin p×Bool)→β j→ℝ) (θ:Fin p→Bool) (c R:ℝ)
    (hR:∀j,(Fintype.card (β j):ℝ)≤R) :
    originalRayError u θ c≤R*finiteAverage (fun pick:(j:Fin p×Bool)→β j=>
      scalarRayError (fun j=>u j (pick j)) θ c) := by
  unfold originalRayError scalarRayError
  rw [finiteAverage_sum,Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  rw [finiteAverage_add]
  rw [finiteAverage_coordinate (i,θ i) (fun a=>(u (i,θ i) a-c)^2),
    finiteAverage_coordinate (i,!(θ i)) (fun a=>u (i,!(θ i)) a^2)]
  rw [sum_eq_card_average (fun a:β (i,θ i)=>(u (i,θ i) a-c)^2),
    sum_eq_card_average (fun a:β (i,!(θ i))=>u (i,!(θ i)) a^2)]
  have h1:=mul_le_mul_of_nonneg_right (hR (i,θ i))
    (finiteAverage_nonneg _ (fun a=>sq_nonneg (u (i,θ i) a-c)))
  have h2:=mul_le_mul_of_nonneg_right (hR (i,!(θ i)))
    (finiteAverage_nonneg _ (fun a=>sq_nonneg (u (i,!(θ i)) a)))
  nlinarith

/-- The deterministic witness has at most `R(4+10R)` times the scalar defect
of the literal independent coordinate-copying experiment. -/
theorem originalRayError_le_defect (hp:2≤p)
    (u:(j:Fin p×Bool)→β j→ℝ) (hu:∀j a,0≤u j a) (R:ℝ) (hR0:0≤R)
    (hR:∀j,(Fintype.card (β j):ℝ)≤R) :
    originalRayError u (secondMomentChoice u) (deterministicGain u)≤
      R*(4+10*R)*finiteAverage (fun pick:(j:Fin p×Bool)→β j=>scalarRailDefect (fun j=>u j (pick j))) := by
  have h:=actual_deterministic_rail_rounding hp u hu R hR
  simp_rw [chosen_defect_eq] at h
  have he : finiteAverage (fun pick:(j:Fin p×Bool)→β j=>scalarRayError (fun j=>u j (pick j))
      (secondMomentChoice u) (deterministicGain u)) =
      finiteAverage (fun pick:(j:Fin p×Bool)→β j=>∑i,(chosenSample u pick i-deterministicGain u)^2)+
      finiteAverage (fun pick:(j:Fin p×Bool)→β j=>∑i,discardedSample u pick i^2) := by
    unfold scalarRayError
    simp_rw [Finset.sum_add_distrib]
    rw [finiteAverage_add]
    rfl
  have hh:=originalRayError_le_average u (secondMomentChoice u) (deterministicGain u) R hR
  rw [he] at hh
  have hm:=mul_le_mul_of_nonneg_left h hR0
  dsimp [deterministicGain] at hh ⊢
  nlinarith

/-- Actual finite sampling stability for the union of positive balanced
transversal rays. The sampled comparison ray can be chosen separately for
**every** sample. The deterministic output ray is explicitly specified. -/
theorem sampling_ray_stability (hp:2≤p)
    (u:(j:Fin p×Bool)→β j→ℝ) (hu:∀j a,0≤u j a) (r R:ℝ)
    (hr:0<r) (hR:2≤R) (hrR:R≤2*r)
    (hsize:∀j,r≤(Fintype.card (β j):ℝ)∧(Fintype.card (β j):ℝ)≤R)
    (θ:((j:Fin p×Bool)→β j)→Fin p→Bool)
    (c:((j:Fin p×Bool)→β j)→ℝ) (hc:∀pick,0≤c pick) :
    originalRayError u (secondMomentChoice u) (deterministicGain u)≤
      24*R*finiteAverage (fun pick:(j:Fin p×Bool)→β j=>weightedRayError
        (fun j=>(Fintype.card (β j):ℝ)) (fun j=>u j (pick j)) (θ pick) (c pick)) := by
  have hupper:=originalRayError_le_defect hp u hu R (by linarith) (fun j=>(hsize j).2)
  have hpoint (pick:(j:Fin p×Bool)→β j) :
      r*scalarRailDefect (fun j=>u j (pick j))≤weightedRayError
        (fun j=>(Fintype.card (β j):ℝ)) (fun j=>u j (pick j)) (θ pick) (c pick) := by
    exact (mul_le_mul_of_nonneg_left
      (scalarRailDefect_le_error (by omega) _ (fun j=>hu j (pick j)) (θ pick) (c pick) (hc pick)) hr.le).trans
      (weightedRayError_lower _ r (fun j=>(hsize j).1) _ _ _)
  have havg:=finiteAverage_mono _ _ hpoint
  rw [finiteAverage_mul_left] at havg
  have hdef:=finiteAverage_nonneg (fun pick:(j:Fin p×Bool)→β j=>scalarRailDefect (fun j=>u j (pick j)))
    (fun pick:(j:Fin p×Bool)→β j=>scalarRailDefect_nonneg _)
  have hcoef : R*(4+10*R)≤24*R*r := by nlinarith
  have hmul:=mul_le_mul_of_nonneg_right hcoef hdef
  have hmul2:=mul_le_mul_of_nonneg_left havg (by positivity : 0≤24*R)
  nlinarith

end Actual
end NeuralGeneralization.OnlineLowerRelu
