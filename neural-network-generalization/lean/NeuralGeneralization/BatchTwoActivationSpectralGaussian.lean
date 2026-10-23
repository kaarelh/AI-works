import NeuralGeneralization.BatchTwoActivationConvexProjection
import NeuralGeneralization.BatchTwoMergingSharpBulk
import NeuralGeneralization.GaussianApproximationTail

/-! Dimension-free Gaussian approximation by a bounded-Frobenius matrix plus a
small-operator-norm remainder, via projection onto an operator norm ball. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

abbrev spectralMatrixCoordinates (N:ℕ):
    (Fin (N*N)→ℝ)≃ᵐ(Fin N×Fin N→ℝ):=
  MeasurableEquiv.piCongrLeft (fun _:Fin N×Fin N=>ℝ) finProdFinEquiv.symm

@[simp] theorem spectralMatrixCoordinates_apply (N:ℕ) (x:Fin (N*N)→ℝ) (ij:Fin N×Fin N):
    spectralMatrixCoordinates N x ij=x (finProdFinEquiv ij):=by
  simpa using MeasurableEquiv.piCongrLeft_apply_apply (β:=fun _:Fin N×Fin N=>ℝ) finProdFinEquiv.symm x (finProdFinEquiv ij)

def spectralSourceOperator (N:ℕ):
    EuclideanSpace ℝ (Fin (N*N))→ₗ[ℝ](EuclideanN N→L[ℝ]EuclideanN N) where
  toFun x:=coordinateMatrixOperator (fun ij=>x (finProdFinEquiv ij))
  map_add' := by
    intro a b
    ext x i
    simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,add_mul,Finset.sum_add_distrib]
  map_smul' := by
    intro c a
    ext x i
    simp [coordinateMatrixOperator,Matrix.toLpLin_apply,Matrix.mulVec,dotProduct,mul_assoc,Finset.mul_sum]

def spectralSourceBody (N:ℕ):Set (EuclideanSpace ℝ (Fin (N*N))):=
  (spectralSourceOperator N)⁻¹'Metric.closedBall 0 (16*Real.sqrt N)

theorem spectralSourceBody_closed (N:ℕ):IsClosed (spectralSourceBody N):=
  Metric.isClosed_closedBall.preimage (spectralSourceOperator N).continuous_of_finiteDimensional

theorem spectralSourceBody_convex (N:ℕ):Convex ℝ (spectralSourceBody N):=
  (convex_closedBall (0:EuclideanN N→L[ℝ]EuclideanN N) (16*Real.sqrt N)).linear_preimage (spectralSourceOperator N)

theorem spectralSourceBody_nonempty (N:ℕ):(spectralSourceBody N).Nonempty:=by
  refine ⟨0,?_⟩
  simp [spectralSourceBody,Metric.mem_closedBall,dist_eq_norm]

theorem spectralMatrixCoordinates_measurePreserving (N:ℕ):
    MeasurePreserving (spectralMatrixCoordinates N) (standardGaussian (N*N))
      (Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 1)) :=
  measurePreserving_piCongrLeft (fun _:Fin N×Fin N=>gaussianReal 0 1) finProdFinEquiv.symm

theorem spectralSourceBody_mass {N:ℕ} (hN:1≤N):
    (1/2:ℝ)≤(standardGaussian (N*N)).real ((WithLp.toLp 2)⁻¹'spectralSourceBody N):=by
  have ht:=GaussianTail.gaussian_square_matrix_good_mass N hN 1 (by norm_num)
  simp only [NNReal.coe_one,mul_one] at ht
  have he: (standardGaussian (N*N)).real
      ((spectralMatrixCoordinates N)⁻¹'{z|‖coordinateMatrixOperator z‖≤16*Real.sqrt (N:ℝ)})=
      (Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 1)).real
      {z|‖coordinateMatrixOperator z‖≤16*Real.sqrt (N:ℝ)}:=by
    exact congrArg ENNReal.toReal ((spectralMatrixCoordinates_measurePreserving N).measure_preimage_emb
      (spectralMatrixCoordinates N).measurableEmbedding _)
  rw [←he] at ht
  have hset:((spectralMatrixCoordinates N)⁻¹'{z|‖coordinateMatrixOperator z‖≤16*Real.sqrt (N:ℝ)})=
      ((WithLp.toLp 2)⁻¹'spectralSourceBody N):=by
    ext x
    have hefun:(spectralMatrixCoordinates N) x=(fun ij=>x (finProdFinEquiv ij)):=
      funext (spectralMatrixCoordinates_apply N x)
    simp [spectralSourceBody,Metric.mem_closedBall,dist_eq_norm,spectralSourceOperator,hefun]
  rw [hset] at ht
  exact ht

/-- Frobenius distance from the Gaussian operator ball has a dimension-free tail. -/
theorem spectralSourceDistance_tail {N:ℕ} (hN:1≤N) (s:ℝ):
    (standardGaussian (N*N)).real
      {x|s≤(gaussianSetDistance (spectralSourceBody N) x)^2}≤2*Real.exp (-s/4):=
  gaussian_zeroSet_square_tail (gaussianSetDistance (spectralSourceBody N))
    (gaussianSetDistance_measurable _) (gaussianSetDistance_squareLipschitz _)
    ((WithLp.toLp 2)⁻¹'spectralSourceBody N)
    ((spectralSourceBody_closed N).measurableSet.preimage (PiLp.continuous_toLp 2 _).measurable)
    (spectralSourceBody_mass hN) (fun x hx=>Metric.infDist_zero_of_mem hx) s

theorem matrixOperator_scaled_source (N:ℕ) (σ:ℝ) (x:EuclideanSpace ℝ (Fin (N*N))):
    matrixOperator (fun ij=>σ*x (finProdFinEquiv ij))=σ•spectralSourceOperator N x:=by
  ext v i
  simp [matrixOperator,spectralSourceOperator,coordinateMatrixOperator,Matrix.toLpLin_apply,
    Matrix.mulVec,dotProduct,mul_assoc,Finset.mul_sum]

def spectralScaledCoordinates (N:ℕ) (σ:ℝ) (hσ:σ≠0):
    (Fin (N*N)→ℝ)≃ᵐ(Fin N×Fin N→ℝ):=
  (spectralMatrixCoordinates N).trans (MeasurableEquiv.smul (Units.mk0 σ hσ))

@[simp] theorem spectralScaledCoordinates_apply (N:ℕ) (σ:ℝ) (hσ:σ≠0)
    (x:Fin (N*N)→ℝ) (ij:Fin N×Fin N):
    spectralScaledCoordinates N σ hσ x ij=σ*x (finProdFinEquiv ij):=by
  simp [spectralScaledCoordinates,Units.smul_def]

theorem spectralScaledCoordinates_law (N:ℕ) (σ:ℝ) (hσ:σ≠0):
    (standardGaussian (N*N)).map (spectralScaledCoordinates N σ hσ)=
      Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal):=by
  have he:(spectralScaledCoordinates N σ hσ: (Fin (N*N)→ℝ)→(Fin N×Fin N→ℝ))=
      (fun z ij=>σ*z ij)∘spectralMatrixCoordinates N:=by
    funext x ij
    simp
  rw [he,←Measure.map_map (by fun_prop) (spectralMatrixCoordinates N).measurable,
    (spectralMatrixCoordinates_measurePreserving N).map_eq,
    Measure.pi_map_pi (f:=fun (_:Fin N×Fin N) (x:ℝ)=>σ*x) (fun _=>by fun_prop)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero,mul_one]
  congr 1
  exact NNReal.eq (by simp [Real.coe_toNNReal (σ^2) (sq_nonneg σ)])


theorem spectral_approximation_failure_subset {N:ℕ} {σ a K:ℝ} (hσ:0<σ)
    (ha:16*σ*Real.sqrt (N:ℝ)≤a):
    (spectralScaledCoordinates N σ hσ.ne')⁻¹'matrixApproximationFailure N a K ⊆
      {x|K/σ^2≤(gaussianSetDistance (spectralSourceBody N) x)^2}:=by
  intro x hbad
  by_contra hn
  have hlt:(gaussianSetDistance (spectralSourceBody N) x)^2<K/σ^2:=lt_of_not_ge hn
  let z:EuclideanSpace ℝ (Fin (N*N)):=WithLp.toLp 2 x
  let p:=convexProjection (spectralSourceBody N) (spectralSourceBody_nonempty N)
    (spectralSourceBody_closed N) (spectralSourceBody_convex N) z
  have hp:p∈spectralSourceBody N:=convexProjection_mem _ _ _ _ z
  have hd:‖z-p‖=gaussianSetDistance (spectralSourceBody N) x:=
    convexProjection_distance _ _ _ _ z
  let H:Fin N×Fin N→ℝ:=fun ij=>σ*(z-p) (finProdFinEquiv ij)
  have hsum:LowRankGrid.squaredSum H=σ^2*‖z-p‖^2:=by
    unfold LowRankGrid.squaredSum
    dsimp [H]
    simp only [mul_pow]
    rw [←Finset.mul_sum]
    have he:(∑ij:Fin N×Fin N,(z (finProdFinEquiv ij)-p (finProdFinEquiv ij))^2)=
        ∑i:Fin (N*N),(z i-p i)^2:=finProdFinEquiv.sum_comp (fun i=>(z i-p i)^2)
    rw [he,EuclideanSpace.real_norm_sq_eq]
    rfl
  have henergy:LowRankGrid.squaredSum H≤K:=by
    rw [hsum,hd]
    have hh:=(lt_div_iff₀ (sq_pos_of_pos hσ)).mp hlt
    nlinarith only [hh]
  have hop:matrixOperator (spectralScaledCoordinates N σ hσ.ne' x)-matrixOperator H=
      σ•spectralSourceOperator N p:=by
    have he:(spectralScaledCoordinates N σ hσ.ne' x)=(fun ij=>σ*z (finProdFinEquiv ij)):=by
      funext ij
      exact spectralScaledCoordinates_apply N σ hσ.ne' x ij
    rw [he,matrixOperator_scaled_source]
    change σ•spectralSourceOperator N z-matrixOperator (fun ij=>σ*(z-p) (finProdFinEquiv ij))=_
    rw [matrixOperator_scaled_source,map_sub,smul_sub]
    abel
  have hbound:‖spectralSourceOperator N p‖≤16*Real.sqrt (N:ℝ):=by
    simpa only [spectralSourceBody,Set.mem_preimage,Metric.mem_closedBall,dist_zero_right] using hp
  have hr:‖matrixOperator (spectralScaledCoordinates N σ hσ.ne' x)-matrixOperator H‖≤a:=by
    rw [hop,norm_smul,Real.norm_eq_abs,abs_of_pos hσ]
    exact (mul_le_mul_of_nonneg_left hbound hσ.le).trans (by nlinarith only [ha])
  exact hbad ⟨H,henergy,hr⟩

/-- Uniform all-width matrix tail. Unlike a coordinate-grid bound, its exponent
has no logarithmic dependence on matrix size. The remainder cutoff is 16σ√N. -/
theorem gaussian_matrix_spectral_tail {N:ℕ} (hN:1≤N) {σ a K:ℝ} (hσ:0<σ)
    (ha:16*σ*Real.sqrt (N:ℝ)≤a):
    (Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal)).real
      (matrixApproximationFailure N a K)≤2*Real.exp (-K/(4*σ^2)):=by
  have he:(standardGaussian (N*N)).real
      ((spectralScaledCoordinates N σ hσ.ne')⁻¹'matrixApproximationFailure N a K)=
      (Measure.pi (fun _:Fin N×Fin N=>gaussianReal 0 (σ^2).toNNReal)).real
        (matrixApproximationFailure N a K):=by
    rw [←spectralScaledCoordinates_law N σ hσ.ne']
    exact (congrArg ENNReal.toReal ((spectralScaledCoordinates N σ hσ.ne').map_apply _)).symm
  rw [←he]
  have ht:=(measureReal_mono (spectral_approximation_failure_subset hσ ha)
    (measure_ne_top (standardGaussian (N*N)) _)).trans (spectralSourceDistance_tail hN (K/σ^2))
  exact ht.trans_eq (by congr 2;ring)

end NeuralGeneralization.BatchTwoActivation
