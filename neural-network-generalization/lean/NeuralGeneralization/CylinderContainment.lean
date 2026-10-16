import NeuralGeneralization.CylinderGeometry
import NeuralGeneralization.NetworkCylinderIndex
import NeuralGeneralization.NetworkCylinderScaling

/-!
# Containment of the actual rotated Gaussian cylinder in the target event

This is the final deterministic bridge: bounds in the exact independent prior
coordinates imply a global classification margin for the concrete network.
-/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.ConcreteModel

variable {d N r : ℕ}

@[simp] theorem rotated_whiten_internal
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (w : Weights d N r) (s : Fin r) (i j : Fin N) :
    rotateInternalRows b.repr (whiten w) (Sum.inr (Sum.inl (s,i,j))) =
      basisCoordinates b (fun a => w (Sum.inr (Sum.inl (s,i,a)))) j := by
  simp only [rotateInternalRows_internal, whiten_internal, basisCoordinates]

/-- Both hypotheses supplied by the Gaussian product event are expressed in
its exact coordinates: one constrained box and one free rectangular norm ball. -/
theorem margin_of_rotated_coordinate_cylinder (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (K G B σ : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hB : 0 ≤ B) (hσ : 0 ≤ σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hJ : (J.card:ℝ) ≤ G)
    (hmargin : v ∈ marginEvent φ (3/2) f) (hcost : weightedSquaredNorm v ≤ K)
    (hrows : ∀ s i j, j ∉ J →
      basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j = 0)
    (hhidden : ∀ (x : Cube d) (ss : List (Fin r)) j, j ∉ J →
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j = 0)
    (hbox : ∀ q, constrainedIndex J q →
      |rotateInternalRows b.repr (whiten w) q-
        rotateInternalRows b.repr (whiten v) q| ≤ cylinderRadius d r K G B*σ)
    (hfree : ‖coordinateMatrixOperator
      (fun p : (Fin r × Fin N) × {j : Fin N // j ∉ J} =>
        rotateInternalRows b.repr (whiten w)
          (Sum.inr (Sum.inl (p.1.1,p.1.2,p.2.val))))‖ ≤ B) :
    w ∈ marginEvent φ (1/2) f := by
  have hρ := (cylinderRadius_pos d r (B := B) hK hG).le
  apply margin_of_basis_cylinder hN φ hφ f w v b J K G B σ hK hG hB hσ
    hscale hJ hmargin hcost hrows hhidden
  · intro i j
    apply input_error_of_whitened hd hN hσ hρ hscale w v i j
    exact hbox (Sum.inl (i,j)) (constrainedIndex_input J i j)
  · intro i
    apply readout_error_of_whitened hd hN hσ hρ hscale w v i
    exact hbox (Sum.inr (Sum.inr i)) (constrainedIndex_readout J i)
  · intro s i j hj
    simpa only [rotated_whiten_internal] using
      hbox (Sum.inr (Sum.inl (s,i,j))) hj
  · simpa only [rotated_whiten_internal] using hfree

end NeuralGeneralization.ConcreteModel
