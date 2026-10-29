import CanonicalBlockGeometry

/-! Block covers store actual query indices. This avoids extending the
nonlinear block map away from the query trajectories or choosing inverses
of potentially noninjective state maps. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {X E F : Type*} [Nonempty X]
variable [NormedAddCommGroup E] [NormedAddCommGroup F]

 theorem indexed_actual_representatives_of_linear_cover
    (S : Set X) (u : X→E) (v : X→F) (a : E→F) (z : E)
    (r δ K : ℝ) (M : ℕ) (hS : ∀x∈S,dist (u x) z≤r) (hK : 0≤K)
    (hc : FiniteBallCover (a '' (u '' S)) M δ)
    (hn : ∀x∈S,∀y∈S,dist (v x-a (u x)) (v y-a (u y))≤K*dist (u x) (u y)) :
    ∃Y:Finset X,(↑Y:Set X)⊆S ∧Y.card≤M ∧
      ∀x∈S,∃y∈Y,dist (v x) (v y)≤2*δ+2*K*r := by
  classical
  obtain ⟨C,hCM,hC⟩ := hc
  let P : F→Prop := fun c=>∃x∈S,dist (a (u x)) c≤δ
  let D := C.filter P
  let rep : F→X := fun c=>if h:P c then Classical.choose h else Classical.arbitrary X
  have hs (c:F) (hc:c∈D) : rep c∈S ∧dist (a (u (rep c))) c≤δ := by
    have hp : P c := (Finset.mem_filter.mp hc).2
    simpa only [rep,dif_pos hp] using Classical.choose_spec hp
  refine ⟨D.image rep,?_,?_,?_⟩
  · intro y hy
    obtain ⟨c,hc,rfl⟩ := Finset.mem_image.mp hy
    exact (hs c hc).1
  · exact Finset.card_image_le.trans ((Finset.card_filter_le _ _).trans hCM)
  · intro x hx
    obtain ⟨c,hc,hxc⟩ := hC (a (u x)) ⟨u x,⟨x,hx,rfl⟩,rfl⟩
    have hcD : c∈D := Finset.mem_filter.mpr ⟨hc,x,hx,hxc⟩
    have hs' := hs c hcD
    refine ⟨rep c,Finset.mem_image_of_mem rep hcD,?_⟩
    have hxy : dist (u x) (u (rep c))≤2*r := by
      have hxz := hS x hx
      have hyz := hS (rep c) hs'.1
      have ht := dist_triangle (u x) z (u (rep c))
      rw [dist_comm z (u (rep c))] at ht
      linarith
    have ha : dist (a (u x)) (a (u (rep c)))≤2*δ := by
      have ht := dist_triangle (a (u x)) c (a (u (rep c)))
      rw [dist_comm c (a (u (rep c)))] at ht
      linarith [hs'.2]
    have hn' := (hn x hx (rep c) hs'.1).trans (mul_le_mul_of_nonneg_left hxy hK)
    have htri := dist_add_add_le (a (u x)) (v x-a (u x))
      (a (u (rep c))) (v (rep c)-a (u (rep c)))
    simp only [add_sub_cancel] at htri
    linarith

variable [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
  [InnerProductSpace ℝ F] [FiniteDimensional ℝ F]

/-- Actual query representatives for a good block, with dimension-independent
cardinality. The only nonlinear premise is a pair estimate on actual inputs. -/
theorem indexed_canonical_good_block_cover
    (S : Set X) (u : X→E) (v : X→F) (z:E)
    (r B σ ε:ℝ) (T K:ℕ) (U A:E→ₗ[ℝ] F)
    (hr:0<r) (hB:0≤B) (hσ:0≤σ) (hε:0<ε) (hT:0<T)
    (hS:∀x∈S,dist (u x) z≤r)
    (hU:∀x,‖U x‖≤σ*‖x‖)
    (hHS:frobeniusSq A≤ε^2*K)
    (hsmall:σ+Real.sqrt (frobeniusSq A/(T:ℝ)^2+ε^2)≤B/8)
    (hN:∀x∈S,∀y∈S,dist (v x-(U+A) (u x)) (v y-(U+A) (u y))≤(B/16)*dist (u x) (u y)) :
    ∃Y:Finset X,(↑Y:Set X)⊆S ∧Y.card≤(2*T+1)^K ∧
      ∀x∈S,∃y∈Y,dist (v x) (v y)≤B*r/2 := by
  obtain ⟨C,hCM,hC⟩ := bounded_perturbation_ball_cover U A z r σ ε T K hr hσ hε hT hU hHS
  have hc : FiniteBallCover ((U+A) '' (u '' S)) ((2*T+1)^K) (B*r/8) := by
    refine ⟨C,hCM,?_⟩
    rintro w ⟨ux,⟨x,hx,rfl⟩,rfl⟩
    obtain ⟨c,hc,hxc⟩ := hC ((U+A) (u x)) ⟨u x,hS x hx,rfl⟩
    refine ⟨c,hc,hxc.trans ?_⟩
    nlinarith [mul_le_mul_of_nonneg_left hsmall hr.le]
  obtain ⟨Y,hY,hYM,hcover⟩ := indexed_actual_representatives_of_linear_cover
    S u v (fun z=>(U+A) z) z r (B*r/8) (B/16) ((2*T+1)^K) hS (by positivity) hc hN
  refine ⟨Y,hY,hYM,?_⟩
  intro x hx
  obtain ⟨y,hy,hxy⟩ := hcover x hx
  refine ⟨y,hy,hxy.trans ?_⟩
  nlinarith [mul_nonneg hB hr.le]

#print axioms indexed_canonical_good_block_cover
end ConditionalNonpolynomial.Analytic
