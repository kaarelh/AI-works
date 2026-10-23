import NeuralGeneralization.BatchTwoMergingPaddedBasis
import NeuralGeneralization.SamplingNetwork

/-! # The averaged ReLU network is exactly a bounded-width network -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel CompressionSampling

abbrev firstMatrix {d N r : ℕ} (w : Weights d N r) : Matrix (Fin N) (Fin (d+1)) ℝ :=
  Matrix.of (fun i j => w (Sum.inl (i,j)))
abbrev internalMatrix {d N r : ℕ} (w : Weights d N r) (s : Fin r) :
    Matrix (Fin N) (Fin N) ℝ := Matrix.of (fun i j => w (Sum.inr (Sum.inl (s,i,j))))
abbrev readoutVector {d N r : ℕ} (w : Weights d N r) : Fin N → ℝ :=
  fun i => w (Sum.inr (Sum.inr i))

def compressedWeights {d N r Q : ℕ} (p : LayerPartitions N r)
    (hq : ∀ s, populationCount (p s) ≤ Q) (w : Weights d N r) : Weights d Q r
  | Sum.inl (a,j) => (Real.sqrt (N : ℝ))⁻¹ *
      ((paddedBasis (p 0) (hq 0))ᵀ * firstMatrix w) a j
  | Sum.inr (Sum.inl (s,a,b)) =>
      ((paddedBasis (p s.succ) (hq s.succ))ᵀ * internalMatrix w s *
        paddedBasis (p s.castSucc) (hq s.castSucc)) a b
  | Sum.inr (Sum.inr a) => Real.sqrt (N : ℝ) *
      ((paddedBasis (p (Fin.last r)) (hq (Fin.last r)))ᵀ *ᵥ readoutVector w) a

theorem merged_firstMatrix {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) : firstMatrix (mergedWeights p w) =
      Matrix.of (populationProjection (p 0)) * firstMatrix w := by rfl

theorem merged_internalMatrix {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) (s : Fin r) : internalMatrix (mergedWeights p w) s =
      Matrix.of (populationProjection (p s.succ)) * internalMatrix w s *
        Matrix.of (populationProjection (p s.castSucc)) := by
  ext i j
  simp only [internalMatrix, Matrix.of_apply, mergedWeights, Matrix.mul_apply,
    Finset.sum_mul]
  rw [Finset.sum_comm]

theorem merged_readoutVector {d N r : ℕ} (p : LayerPartitions N r)
    (w : Weights d N r) : readoutVector (mergedWeights p w) =
      populationProjection (p (Fin.last r)) *ᵥ readoutVector w := by rfl

theorem relu_smul {I : Type*} (a : ℝ) (ha : 0 ≤ a) (u : I → ℝ) :
    (fun i => relu ((a • u) i)) = a • (fun i => relu (u i)) := by
  funext i
  exact relu_mul_nonneg a (u i) ha

theorem compressed_firstHidden {d N r Q : ℕ} (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (x : Cube d) :
    firstHidden relu (mergedWeights p w) x =
      Real.sqrt (N : ℝ) • (paddedBasis (p 0) (hq 0) *ᵥ
        firstHidden relu (compressedWeights p hq w) x) := by
  have hs : Real.sqrt (N : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  have hm : firstMatrix (compressedWeights p hq w) = (Real.sqrt (N : ℝ))⁻¹ •
      ((paddedBasis (p 0) (hq 0))ᵀ * firstMatrix w) := by rfl
  change (fun i => relu ((firstMatrix (mergedWeights p w) *ᵥ inputVector x) i)) =
    Real.sqrt (N : ℝ) • (paddedBasis (p 0) (hq 0) *ᵥ
      fun a => relu ((firstMatrix (compressedWeights p hq w) *ᵥ inputVector x) a))
  rw [merged_firstMatrix, ← paddedBasis_mul_transpose (p 0) (hq 0), hm,
    Matrix.smul_mulVec, relu_smul _ (by positivity), Matrix.mulVec_smul,
    smul_smul, mul_inv_cancel₀ hs, one_smul, ← relu_paddedBasis_mulVec]
  simp only [Matrix.mulVec_mulVec, Matrix.mul_assoc]

theorem compressed_hiddenStep {d N r Q : ℕ}
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (s : Fin r) (h : Fin Q → ℝ) :
    hiddenStep relu (mergedWeights p w)
      (Real.sqrt (N : ℝ) • (paddedBasis (p s.castSucc) (hq s.castSucc) *ᵥ h)) s =
    Real.sqrt (N : ℝ) • (paddedBasis (p s.succ) (hq s.succ) *ᵥ
      hiddenStep relu (compressedWeights p hq w) h s) := by
  have hm : internalMatrix (compressedWeights p hq w) s =
      (paddedBasis (p s.succ) (hq s.succ))ᵀ * internalMatrix w s *
        paddedBasis (p s.castSucc) (hq s.castSucc) := rfl
  change (fun i => relu ((internalMatrix (mergedWeights p w) s *ᵥ
    (Real.sqrt (N : ℝ) • (paddedBasis (p s.castSucc) (hq s.castSucc) *ᵥ h))) i)) =
    Real.sqrt (N : ℝ) • (paddedBasis (p s.succ) (hq s.succ) *ᵥ
      fun a => relu ((internalMatrix (compressedWeights p hq w) s *ᵥ h) a))
  rw [Matrix.mulVec_smul, relu_smul _ (by positivity),
    ← relu_paddedBasis_mulVec, hm, merged_internalMatrix]
  congr 2
  rw [← Matrix.mulVec_mulVec, projection_paddedBasis_mulVec,
    ← paddedBasis_mul_transpose (p s.succ) (hq s.succ)]
  simp only [Matrix.mulVec_mulVec, Matrix.mul_assoc]


theorem compressed_hiddenPrefix {d N r Q : ℕ} (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (x : Cube d) (s : Fin (r+1)) :
    hiddenPrefix relu (mergedWeights p w) x s.val =
      Real.sqrt (N : ℝ) • (paddedBasis (p s) (hq s) *ᵥ
        hiddenPrefix relu (compressedWeights p hq w) x s.val) := by
  induction s using Fin.induction with
  | zero =>
      simpa only [Fin.val_zero, hiddenPrefix_zero] using compressed_firstHidden hN p hq w x
  | succ s ih =>
      simp only [Fin.val_succ, hiddenPrefix_succ, Fin.val_castSucc] at ih ⊢
      rw [ih]
      exact compressed_hiddenStep p hq w s _

theorem compressed_networkOutput {d N r Q : ℕ} (hN : 0 < N)
    (p : LayerPartitions N r) (hq : ∀ s, populationCount (p s) ≤ Q)
    (w : Weights d N r) (x : Cube d) :
    networkOutput relu (mergedWeights p w) x =
      networkOutput relu (compressedWeights p hq w) x := by
  let F := paddedBasis (p (Fin.last r)) (hq (Fin.last r))
  let P := Matrix.of (populationProjection (p (Fin.last r)))
  let h := finalHidden relu (compressedWeights p hq w) x
  let v := readoutVector w
  have hh := compressed_hiddenPrefix hN p hq w x (Fin.last r)
  simp only [Fin.val_last, hiddenPrefix_last] at hh
  have hp : Pᵀ = P := by
    ext i j
    exact populationProjection_symm _ j i
  have hproj : P *ᵥ (F *ᵥ h) = F *ᵥ h := projection_paddedBasis_mulVec _ _ _
  have hdot : (F *ᵥ h) ⬝ᵥ (P *ᵥ v) = v ⬝ᵥ (F *ᵥ h) := by
    have he := Matrix.dotProduct_transpose_mulVec P (F *ᵥ h) v
    rwa [hp,hproj] at he
  change readoutVector (mergedWeights p w) ⬝ᵥ finalHidden relu (mergedWeights p w) x =
    readoutVector (compressedWeights p hq w) ⬝ᵥ h
  rw [hh, merged_readoutVector]
  change (P *ᵥ v) ⬝ᵥ (Real.sqrt (N : ℝ) • (F *ᵥ h)) =
    (Real.sqrt (N : ℝ) • (Fᵀ *ᵥ v)) ⬝ᵥ h
  rw [dotProduct_smul, smul_dotProduct]
  congr 1
  rw [dotProduct_comm (P *ᵥ v), hdot, dotProduct_comm (Fᵀ *ᵥ v)]
  exact (Matrix.dotProduct_transpose_mulVec F h v).symm

end NeuralGeneralization.BatchTwoMerging
