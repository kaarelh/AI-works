import BlockRepresentativeCover

/-! Combining actual representative covers across clusters and layers. -/

namespace ConditionalNonpolynomial.Analytic

def ActualBallCover {E : Type*} [PseudoMetricSpace E]
    (S : Set E) (N : ℕ) (r : ℝ) : Prop :=
  ∃ C : Finset E, (↑C : Set E) ⊆ S ∧ C.card ≤ N ∧
    ∀ x ∈ S, ∃ c ∈ C, dist x c ≤ r

/-- The union of actual representatives selected separately in old clusters
is an actual representative cover of the full image. -/
theorem actual_cover_step {E F : Type*} [PseudoMetricSpace E] [PseudoMetricSpace F]
    (S : Set E) (f : E → F) (N M : ℕ) (r R : ℝ)
    (hc : ActualBallCover S N r)
    (hstep : ∀ z ∈ S, ∃ Y : Finset E,
      (↑Y : Set E) ⊆ S ∩ Metric.closedBall z r ∧ Y.card ≤ M ∧
      ∀ x ∈ S ∩ Metric.closedBall z r,
        ∃ y ∈ Y, dist (f x) (f y) ≤ R) :
    ActualBallCover (f '' S) (N * M) R := by
  classical
  obtain ⟨C, hCS, hCN, hC⟩ := hc
  let Y : E → Finset E := fun z => if hz : z ∈ S then Classical.choose (hstep z hz) else ∅
  have hY (z : E) (hz : z ∈ S) :
      (↑(Y z) : Set E) ⊆ S ∩ Metric.closedBall z r ∧ (Y z).card ≤ M ∧
      ∀ x ∈ S ∩ Metric.closedBall z r, ∃ y ∈ Y z, dist (f x) (f y) ≤ R := by
    simpa only [Y, dif_pos hz] using Classical.choose_spec (hstep z hz)
  refine ⟨C.biUnion (fun z => (Y z).image f), ?_, ?_, ?_⟩
  · intro v hv
    obtain ⟨z, hz, hv⟩ := Finset.mem_biUnion.mp hv
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hv
    exact ⟨y, (hY z (hCS hz)).1 hy |>.1, rfl⟩
  · apply (Finset.card_biUnion_le_card_mul C (fun z => (Y z).image f) M ?_).trans
    · exact Nat.mul_le_mul_right M hCN
    · intro z hz
      exact Finset.card_image_le.trans (hY z (hCS hz)).2.1
  · rintro v ⟨x, hx, rfl⟩
    obtain ⟨z, hz, hxz⟩ := hC x hx
    obtain ⟨y, hy, hxy⟩ := (hY z (hCS hz)).2.2 x ⟨hx, hxz⟩
    exact ⟨f y, Finset.mem_biUnion.mpr ⟨z, hz, Finset.mem_image_of_mem f hy⟩, hxy⟩

/-- A one-ball step propagates an actual center, using Lipschitz control only
on pairs in the actual state set. -/
theorem actual_cover_lipschitz {E F : Type*} [PseudoMetricSpace E] [PseudoMetricSpace F]
    (S : Set E) (f : E → F) (N : ℕ) (r K : ℝ) (hK : 0 ≤ K)
    (hc : ActualBallCover S N r)
    (hf : ∀ x ∈ S, ∀ y ∈ S, dist (f x) (f y) ≤ K * dist x y) :
    ActualBallCover (f '' S) N (K * r) := by
  classical
  obtain ⟨C, hCS, hCN, hC⟩ := hc
  refine ⟨C.image f, ?_, Finset.card_image_le.trans hCN, ?_⟩
  · intro v hv
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hv
    exact ⟨y, hCS hy, rfl⟩
  · rintro v ⟨x, hx, rfl⟩
    obtain ⟨c, hc, hxc⟩ := hC x hx
    exact ⟨f c, Finset.mem_image_of_mem f hc,
      (hf x hx c (hCS hc)).trans (mul_le_mul_of_nonneg_left hxc hK)⟩

section Iteration
variable {H : ℕ → Type*} [∀ j, PseudoMetricSpace (H j)]

/-- Iterating actual cluster covers multiplies their cardinality bounds.
The spaces may change dimension at each block. -/
theorem actual_cover_iteration (S : ∀ j, Set (H j)) (f : ∀ j, H j → H (j+1))
    (r : ℕ → ℝ) (N M : ℕ)
    (himage : ∀ j, S (j+1) = f j '' S j)
    (h0 : ActualBallCover (S 0) N (r 0))
    (hstep : ∀ j, ∀ z ∈ S j, ∃ Y : Finset (H j),
      (↑Y : Set (H j)) ⊆ S j ∩ Metric.closedBall z (r j) ∧ Y.card ≤ M ∧
      ∀ x ∈ S j ∩ Metric.closedBall z (r j),
        ∃ y ∈ Y, dist (f j x) (f j y) ≤ r (j+1)) :
    ∀ j, ActualBallCover (S j) (N * M^j) (r j) := by
  intro j
  induction j with
  | zero => simpa using h0
  | succ j ih =>
    rw [himage j]
    have hh := actual_cover_step (S j) (f j) (N*M^j) M (r j) (r (j+1)) ih (hstep j)
    simpa [pow_succ, Nat.mul_assoc] using hh

end Iteration

#print axioms actual_cover_step
#print axioms actual_cover_lipschitz
#print axioms actual_cover_iteration
end ConditionalNonpolynomial.Analytic
