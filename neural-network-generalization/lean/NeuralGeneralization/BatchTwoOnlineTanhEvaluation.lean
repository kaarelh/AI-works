import NeuralGeneralization.BatchTwoOnlineTanhPerspective
import NeuralGeneralization.BatchTwoMergingGeluEvaluation

/-! Exact tanh population representation in normalized mass coordinates. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel CompressionSampling BatchTwoMerging

def perspectiveFirst {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (x : Cube d) : Fin Q→ℝ :=
  fun a=>tanhPerspective (mass 0 a) ((firstMatrix w *ᵥ inputVector x) a)

def perspectiveStep {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (h : Fin Q→ℝ) (s : Fin r) : Fin Q→ℝ :=
  fun a=>tanhPerspective (mass s.succ a) ((internalMatrix w s *ᵥ h) a)

def perspectivePrefix {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (x : Cube d) (m : ℕ) : Fin Q→ℝ :=
  ((List.finRange r).take m).foldl (perspectiveStep w mass) (perspectiveFirst w mass x)

def perspectiveOutput {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (x : Cube d) : ℝ :=
  readoutVector w ⬝ᵥ perspectivePrefix w mass x r

@[simp] theorem perspectivePrefix_zero {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (x : Cube d) :
    perspectivePrefix w mass x 0 = perspectiveFirst w mass x := by
  simp [perspectivePrefix]

theorem perspectivePrefix_succ {d Q r : ℕ} (w : Weights d Q r)
    (mass : Fin (r+1)→Fin Q→ℝ) (x : Cube d) (s : Fin r) :
    perspectivePrefix w mass x (s.val+1) =
      perspectiveStep w mass (perspectivePrefix w mass x s.val) s := by
  unfold perspectivePrefix
  rw [List.take_succ_eq_append_getElem (by simp)]
  simp

theorem tanh_population_lift {N Q : ℕ} (hN : 0<N) (p : PopulationPartition N)
    (hq : populationCount p≤Q) (h : Fin Q→ℝ) :
    (fun i=>Real.tanh ((Real.sqrt (N:ℝ) • (paddedBasis p hq *ᵥ h)) i)) =
      Real.sqrt (N:ℝ) • (paddedBasis p hq *ᵥ
        (fun a=>tanhPerspective (populationScale p hq a) (h a))) := by
  funext i
  simp only [Pi.smul_apply,smul_eq_mul,paddedBasis_mulVec,populationScale_label,
    tanhPerspective]
  have hn : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  have hk : Real.sqrt (populationSize p (populationLabel p i))≠0 :=
    (Real.sqrt_pos.mpr (populationSize_pos p _)).ne'
  have he : h (paddedLabel p hq i)/(Real.sqrt (populationSize p (populationLabel p i)) /
      Real.sqrt (N:ℝ)) = Real.sqrt (N:ℝ)*(h (paddedLabel p hq i) /
      Real.sqrt (populationSize p (populationLabel p i))) := by field_simp
  rw [he]
  field_simp


theorem tanh_compressed_firstHidden {d N r Q : ℕ} (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (x : Cube d) :
    firstHidden Real.tanh (mergedWeights p w) x =
      Real.sqrt (N:ℝ) • (paddedBasis (p 0) (hq 0) *ᵥ
        perspectiveFirst (compressedWeights p hq w) (populationScales p hq) x) := by
  have hs : Real.sqrt (N:ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  have hm : firstMatrix (compressedWeights p hq w) = (Real.sqrt (N:ℝ))⁻¹ •
      ((paddedBasis (p 0) (hq 0))ᵀ * firstMatrix w) := rfl
  change (fun i=>Real.tanh ((firstMatrix (mergedWeights p w) *ᵥ inputVector x) i)) = _
  have he : firstMatrix (mergedWeights p w) *ᵥ inputVector x =
      Real.sqrt (N:ℝ) • (paddedBasis (p 0) (hq 0) *ᵥ
        (firstMatrix (compressedWeights p hq w) *ᵥ inputVector x)) := by
    rw [merged_firstMatrix,←paddedBasis_mul_transpose (p 0) (hq 0),hm,
      Matrix.smul_mulVec,Matrix.mulVec_smul,smul_smul,mul_inv_cancel₀ hs,one_smul]
    simp only [Matrix.mulVec_mulVec,Matrix.mul_assoc]
  rw [he,tanh_population_lift hN]
  rfl

theorem tanh_compressed_hiddenStep {d N r Q : ℕ} (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (s : Fin r) (h : Fin Q→ℝ) :
    hiddenStep Real.tanh (mergedWeights p w)
      (Real.sqrt (N:ℝ) • (paddedBasis (p s.castSucc) (hq s.castSucc) *ᵥ h)) s =
      Real.sqrt (N:ℝ) • (paddedBasis (p s.succ) (hq s.succ) *ᵥ
        perspectiveStep (compressedWeights p hq w) (populationScales p hq) h s) := by
  have hm : internalMatrix (compressedWeights p hq w) s =
      (paddedBasis (p s.succ) (hq s.succ))ᵀ * internalMatrix w s *
        paddedBasis (p s.castSucc) (hq s.castSucc) := rfl
  change (fun i=>Real.tanh ((internalMatrix (mergedWeights p w) s *ᵥ
    (Real.sqrt (N:ℝ) • (paddedBasis (p s.castSucc) (hq s.castSucc) *ᵥ h))) i)) = _
  have he : internalMatrix (mergedWeights p w) s *ᵥ
      (Real.sqrt (N:ℝ) • (paddedBasis (p s.castSucc) (hq s.castSucc) *ᵥ h)) =
      Real.sqrt (N:ℝ) • (paddedBasis (p s.succ) (hq s.succ) *ᵥ
        (internalMatrix (compressedWeights p hq w) s *ᵥ h)) := by
    rw [Matrix.mulVec_smul,hm,merged_internalMatrix]
    congr 1
    rw [←Matrix.mulVec_mulVec,projection_paddedBasis_mulVec,
      ←paddedBasis_mul_transpose (p s.succ) (hq s.succ)]
    simp only [Matrix.mulVec_mulVec,Matrix.mul_assoc]
  rw [he,tanh_population_lift hN]
  rfl

theorem tanh_compressed_hiddenPrefix {d N r Q : ℕ} (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (x : Cube d) (s : Fin (r+1)) :
    hiddenPrefix Real.tanh (mergedWeights p w) x s.val =
      Real.sqrt (N:ℝ) • (paddedBasis (p s) (hq s) *ᵥ
        perspectivePrefix (compressedWeights p hq w) (populationScales p hq) x s.val) := by
  induction s using Fin.induction with
  | zero => simpa only [Fin.val_zero,hiddenPrefix_zero,perspectivePrefix_zero] using
      tanh_compressed_firstHidden hN p hq w x
  | succ s ih =>
    simp only [Fin.val_succ,hiddenPrefix_succ,perspectivePrefix_succ,Fin.val_castSucc] at ih ⊢
    rw [ih]
    exact tanh_compressed_hiddenStep hN p hq w s _

theorem tanh_compressed_networkOutput {d N r Q : ℕ} (hN : 0<N)
    (p : LayerPartitions N r) (hq : ∀s,populationCount (p s)≤Q)
    (w : Weights d N r) (x : Cube d) :
    networkOutput Real.tanh (mergedWeights p w) x =
      perspectiveOutput (compressedWeights p hq w) (populationScales p hq) x := by
  let F := paddedBasis (p (Fin.last r)) (hq (Fin.last r))
  let P := Matrix.of (populationProjection (p (Fin.last r)))
  let h := perspectivePrefix (compressedWeights p hq w) (populationScales p hq) x r
  let v := readoutVector w
  have hh := tanh_compressed_hiddenPrefix hN p hq w x (Fin.last r)
  simp only [Fin.val_last,hiddenPrefix_last] at hh
  have hp : Pᵀ=P := by ext i j; exact populationProjection_symm _ j i
  have hproj : P *ᵥ (F *ᵥ h)=F *ᵥ h := projection_paddedBasis_mulVec _ _ _
  have hdot : (F *ᵥ h) ⬝ᵥ (P *ᵥ v)=v ⬝ᵥ (F *ᵥ h) := by
    have he := Matrix.dotProduct_transpose_mulVec P (F *ᵥ h) v
    rwa [hp,hproj] at he
  change readoutVector (mergedWeights p w) ⬝ᵥ finalHidden Real.tanh (mergedWeights p w) x =
    readoutVector (compressedWeights p hq w) ⬝ᵥ h
  rw [hh,merged_readoutVector]
  change (P *ᵥ v) ⬝ᵥ (Real.sqrt (N:ℝ) • (F *ᵥ h)) =
    (Real.sqrt (N:ℝ) • (Fᵀ *ᵥ v)) ⬝ᵥ h
  rw [dotProduct_smul,smul_dotProduct]
  congr 1
  rw [dotProduct_comm (P *ᵥ v),hdot,dotProduct_comm (Fᵀ *ᵥ v)]
  exact (Matrix.dotProduct_transpose_mulVec F h v).symm

end NeuralGeneralization.BatchTwoOnlineTanhMerging
