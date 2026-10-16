import NeuralGeneralization.NetworkGaussianCylinder

/-!
# Orthogonal rotations of every internal row

Only internal incoming rows are rotated. Input weights and readout weights
retain their original coordinates. The resulting transformation is a genuine
Euclidean isometry on the full, weighted-whitened parameter space.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators RealInnerProductSpace NNReal

namespace NeuralGeneralization.ConcreteModel

variable {d N r : ℕ}

def rotateInternalRows
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) : Weights d N r := fun q =>
  match q with
  | Sum.inl ij => w (Sum.inl ij)
  | Sum.inr (Sum.inl (s, i, j)) =>
      U (toLp 2 (fun k => w (Sum.inr (Sum.inl (s, i, k))))) j
  | Sum.inr (Sum.inr i) => w (Sum.inr (Sum.inr i))

@[simp] theorem rotateInternalRows_input
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) (i : Fin N) (j : Fin (d+1)) :
    rotateInternalRows U w (Sum.inl (i,j)) = w (Sum.inl (i,j)) := rfl

@[simp] theorem rotateInternalRows_internal
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) (s : Fin r) (i j : Fin N) :
    rotateInternalRows U w (Sum.inr (Sum.inl (s,i,j))) =
      U (toLp 2 (fun k => w (Sum.inr (Sum.inl (s,i,k))))) j := rfl

@[simp] theorem rotateInternalRows_readout
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) (i : Fin N) :
    rotateInternalRows U w (Sum.inr (Sum.inr i)) = w (Sum.inr (Sum.inr i)) := rfl

@[simp] theorem rotateInternalRows_symm_apply
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) : rotateInternalRows U.symm (rotateInternalRows U w) = w := by
  funext q
  rcases q with ij | (⟨s,i,j⟩ | i)
  · rfl
  · simp only [rotateInternalRows_internal]
    exact congrArg (fun x : EuclideanSpace ℝ (Fin N) => x j) (U.symm_apply_apply _)
  · rfl

def rotateInternalRowsLinearEquiv
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N)) :
    Weights d N r ≃ₗ[ℝ] Weights d N r where
  toFun := rotateInternalRows U
  invFun := rotateInternalRows U.symm
  left_inv := rotateInternalRows_symm_apply U
  right_inv := by intro w; simpa using rotateInternalRows_symm_apply U.symm w
  map_add' := by
    intro w v
    funext q
    rcases q with ij | (⟨s,i,j⟩ | i)
    · rfl
    · simp only [rotateInternalRows_internal, Pi.add_apply]
      exact congrArg (fun x : EuclideanSpace ℝ (Fin N) => x j) (U.map_add (toLp 2 (fun k => w (Sum.inr (Sum.inl (s,i,k)))))
        (toLp 2 (fun k => v (Sum.inr (Sum.inl (s,i,k))))))
    · rfl
  map_smul' := by
    intro a w
    funext q
    rcases q with ij | (⟨s,i,j⟩ | i)
    · rfl
    · simp only [rotateInternalRows_internal, Pi.smul_apply, smul_eq_mul,
        RingHom.id_apply]
      exact congrArg (fun x : EuclideanSpace ℝ (Fin N) => x j) (U.map_smul a (toLp 2 (fun k => w (Sum.inr (Sum.inl (s,i,k))))))
    · rfl

theorem rotateInternalRows_squareSum
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) :
    ∑ q, (rotateInternalRows U w q) ^ 2 = ∑ q, w q ^ 2 := by
  classical
  simp only [Fintype.sum_sum_type, Fintype.sum_prod_type,
    rotateInternalRows_input, rotateInternalRows_internal, rotateInternalRows_readout]
  congr 1
  congr 1
  apply Finset.sum_congr rfl
  intro s hs
  apply Finset.sum_congr rfl
  intro i hi
  let row : EuclideanSpace ℝ (Fin N) := toLp 2 (fun k => w (Sum.inr (Sum.inl (s,i,k))))
  calc
    _ = ‖U row‖ ^ 2 := (EuclideanSpace.real_norm_sq_eq (U row)).symm
    _ = ‖row‖ ^ 2 := by rw [U.norm_map]
    _ = _ := EuclideanSpace.real_norm_sq_eq row

/-- The full-coordinate Euclidean isometry induced by rotating all internal rows. -/
def internalRowIsometry
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N)) :
    EuclideanSpace ℝ (WeightIndex d N r) ≃ₗᵢ[ℝ]
      EuclideanSpace ℝ (WeightIndex d N r) where
  toLinearEquiv := (WithLp.linearEquiv 2 ℝ (Weights d N r)).trans
    ((rotateInternalRowsLinearEquiv U).trans
      (WithLp.linearEquiv 2 ℝ (Weights d N r)).symm)
  norm_map' := by
    intro w
    apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    simp only [LinearEquiv.trans_apply, WithLp.coe_linearEquiv,
      WithLp.coe_symm_linearEquiv, EuclideanSpace.real_norm_sq_eq]
    exact rotateInternalRows_squareSum U (ofLp w)

@[simp] theorem coordinateMap_internalRowIsometry
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N))
    (w : Weights d N r) :
    GaussianOrthogonal.coordinateMap (internalRowIsometry U) w =
      rotateInternalRows U w := rfl

/-- The actual network prior becomes independent equal-variance Gaussian
coordinates after layer whitening and simultaneous rotation of incoming rows. -/
theorem map_smallPrior_rotatedRows (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ)
    (U : EuclideanSpace ℝ (Fin N) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin N)) :
    (smallPrior d N r σ).map (rotateInternalRows U ∘ whiten) =
      Measure.pi (fun _ : WeightIndex d N r => gaussianReal 0 (σ ^ 2).toNNReal) :=
  map_smallPrior_orthogonalWhiten hd hN hσ (internalRowIsometry U)

end NeuralGeneralization.ConcreteModel
