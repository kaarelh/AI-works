import IndexedBlockCover
import ActualCoverIteration

/-! Iteration of representative covers indexed by the original inputs.
Different inputs may have identical states; no inverse state map is needed. -/
noncomputable section
namespace ConditionalNonpolynomial.Analytic
variable {X E F : Type*} [PseudoMetricSpace E] [PseudoMetricSpace F]

def IndexedActualBallCover (u : X→E) (N : ℕ) (r : ℝ) : Prop :=
  ∃C:Finset X,C.card≤N ∧∀x,∃c∈C,dist (u x) (u c)≤r

theorem indexed_cover_step (u : X→E) (v : X→F) (N M:ℕ) (r R:ℝ)
    (hc:IndexedActualBallCover u N r)
    (hstep:∀z:X,∃Y:Finset X,(∀y∈Y,dist (u y) (u z)≤r) ∧Y.card≤M ∧
      ∀x,dist (u x) (u z)≤r→∃y∈Y,dist (v x) (v y)≤R) :
    IndexedActualBallCover v (N*M) R := by
  classical
  obtain ⟨C,hCN,hC⟩ := hc
  let Y := fun z=>Classical.choose (hstep z)
  have hY (z:X) := Classical.choose_spec (hstep z)
  refine ⟨C.biUnion Y,?_,?_⟩
  · exact (Finset.card_biUnion_le_card_mul C Y M (fun z _=>(hY z).2.1)).trans
      (Nat.mul_le_mul_right M hCN)
  · intro x
    obtain ⟨z,hz,hxz⟩ := hC x
    obtain ⟨y,hy,hxy⟩ := (hY z).2.2 x hxz
    exact ⟨y,Finset.mem_biUnion.mpr ⟨z,hz,hy⟩,hxy⟩

theorem indexed_cover_one_ball (u : X→E) (v:X→F) (r K:ℝ) (hK:0≤K)
    (hpair:∀x y,dist (v x) (v y)≤K*dist (u x) (u y)) (z:X) (hr:0≤r) :
    ∃Y:Finset X,(∀y∈Y,dist (u y) (u z)≤r) ∧Y.card≤1 ∧
      ∀x,dist (u x) (u z)≤r→∃y∈Y,dist (v x) (v y)≤K*r := by
  classical
  refine ⟨{z},?_,by simp,?_⟩
  · intro y hy
    have hyz : y=z := Finset.mem_singleton.mp hy
    subst y
    simpa using hr
  · intro x hx
    exact ⟨z,by simp,(hpair x z).trans (mul_le_mul_of_nonneg_left hx hK)⟩

theorem IndexedActualBallCover.to_actual (u:X→E) (N:ℕ) (r:ℝ)
    (hc:IndexedActualBallCover u N r) : ActualBallCover (Set.range u) N r := by
  classical
  obtain ⟨C,hC,hcover⟩ := hc
  refine ⟨C.image u,?_,Finset.card_image_le.trans hC,?_⟩
  · intro y hy
    obtain ⟨x,hx,rfl⟩ := Finset.mem_image.mp hy
    exact ⟨x,rfl⟩
  · rintro y ⟨x,rfl⟩
    obtain ⟨c,hc,hxc⟩ := hcover x
    exact ⟨u c,Finset.mem_image_of_mem u hc,hxc⟩

section Iteration
variable {V : ℕ→Type*} [∀j,PseudoMetricSpace (V j)]

theorem indexed_cover_iteration (u:∀j,X→V j) (r:ℕ→ℝ) (N M H:ℕ)
    (h0:IndexedActualBallCover (u 0) N (r 0))
    (hstep:∀j<H,∀z:X,∃Y:Finset X,(∀y∈Y,dist (u j y) (u j z)≤r j) ∧Y.card≤M ∧
      ∀x,dist (u j x) (u j z)≤r j→∃y∈Y,dist (u (j+1) x) (u (j+1) y)≤r (j+1)) :
    IndexedActualBallCover (u H) (N*M^H) (r H) := by
  induction H with
  | zero=>simpa using h0
  | succ H ih=>
    have hp := ih (fun j hj=>hstep j (by omega))
    have hh := indexed_cover_step (u H) (u (H+1)) (N*M^H) M (r H) (r (H+1)) hp
      (hstep H (by omega))
    simpa [pow_succ,Nat.mul_assoc] using hh

end Iteration
#print axioms indexed_cover_iteration
end ConditionalNonpolynomial.Analytic
