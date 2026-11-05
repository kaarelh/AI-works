import NeuralGeneralization.ValidHiddenPath
import NeuralGeneralization.RobustModelContinuity
import NeuralGeneralization.RobustModelBounds

/-! The literal support restricting every noisy hidden activation to [-1,1].
A finite-path characterization keeps the state constraint explicit. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ValidState
open ConcreteModel RobustCompressionInduction
variable {d N r : ℕ}

def trajectory (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) : HiddenPath N r := fun s =>
  ((List.finRange r).take s.val).foldl (noisyHiddenStep φ w η) (noisyFirstHidden φ w x η)

lemma trajectory_zero (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) : trajectory φ w x η 0=noisyFirstHidden φ w x η := by
  simp [trajectory]

lemma trajectory_succ (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (s : Fin r) :
    trajectory φ w x η s.succ = noisyHiddenStep φ w η (trajectory φ w x η s.castSucc) s := by
  unfold trajectory
  simp only [Fin.val_succ,Fin.val_castSucc]
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

lemma trajectory_last (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) : trajectory φ w x η (Fin.last r)=noisyFinalHidden φ w x η := by
  simp only [trajectory,Fin.val_last,noisyFinalHidden]
  rw [show (List.finRange r).take r=List.finRange r by simp]

lemma trajectory_path (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (h : HiddenPath N r) (z : ℝ) : trajectory φ w x (pathDisturbance φ w x h z)=h := by
  funext s
  induction s using Fin.induction with
  | zero => rw [trajectory_zero,pathDisturbance_first]
  | succ s ih => rw [trajectory_succ,ih,pathDisturbance_step]

lemma disturbance_trajectory (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    pathDisturbance φ w x (trajectory φ w x η) (noisyNetworkOutput φ w x η)=η := by
  apply Prod.ext
  · funext s i
    induction s using Fin.cases with
    | zero => simp [pathDisturbance,trajectory_zero,noisyFirstHidden]
    | succ s => simp [pathDisturbance,trajectory_succ,noisyHiddenStep]
  · simp [pathDisturbance,trajectory_last,noisyNetworkOutput]

def atInput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (robustRadius c w)^2 →
    validHiddenPath (trajectory φ w x η) →
      |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/16

def support (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) := {w | ∀ x,atInput φ c w x}

lemma atInput_iff_path (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) :
    atInput φ c w x ↔ ∀ h : HiddenPath N r,validHiddenPath h → ∀ z : ℝ,
      noiseBudgetSq (pathDisturbance φ w x h z) ≤ (robustRadius c w)^2 →
        |clippedScore z-clippedScore (networkOutput φ w x)| ≤ 1/16 := by
  constructor
  · intro hw h hh z hz
    simpa only [pathDisturbance_output] using hw (pathDisturbance φ w x h z) hz
      (by rwa [trajectory_path])
  · intro hw η hη hv
    exact hw _ hv _ (by rwa [disturbance_trajectory])

lemma original_support_subset (φ : ℝ → ℝ) (c : ℝ) :
    robustEvent (d := d) (N := N) (r := r) φ c ⊆ support φ c :=
  fun _ hw x η hη _ => hw x η hη

def pathOutput (w : Weights d N r) (h : HiddenPath N r) (t : ℝ) : ℝ :=
  (∑ i,w (.inr (.inr i))*h (Fin.last r) i)+t

lemma pathOutput_budget (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    (h : HiddenPath N r) (t : ℝ) :
    noiseBudgetSq (pathDisturbance φ w x h (pathOutput w h t))=hiddenPathCost φ w x h+t^2 := by
  rw [pathDisturbance_budget_eq_hiddenPathCost]
  simp only [pathOutput,add_sub_cancel_left]

lemma atInput_iff_pathOutput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) :
    atInput φ c w x ↔ ∀ h : HiddenPath N r,validHiddenPath h → ∀ t : ℝ,
      hiddenPathCost φ w x h+t^2 ≤ (robustRadius c w)^2 →
        |clippedScore (pathOutput w h t)-clippedScore (networkOutput φ w x)| ≤ 1/16 := by
  rw [atInput_iff_path]
  constructor
  · intro hw h hh t ht
    apply hw h hh (pathOutput w h t)
    rwa [pathOutput_budget]
  · intro hw h hh z hz
    have ht := hw h hh (z-(∑ i,w (.inr (.inr i))*h (Fin.last r) i))
    have he : pathOutput w h (z-(∑ i,w (.inr (.inr i))*h (Fin.last r) i))=z := by
      unfold pathOutput
      ring
    rw [he] at ht
    apply ht
    rwa [pathDisturbance_budget_eq_hiddenPathCost] at hz

lemma robustRadius_le_calibration {c : ℝ} (hc : 0 ≤ c) (w : Weights d N r) : robustRadius c w ≤ c := by
  have he := readoutEnergy_nonneg w
  have hd : 1 ≤ Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) :=
    (Real.le_sqrt (by norm_num) (by positivity)).mpr (by nlinarith [Nat.cast_nonneg (α := ℝ) r])
  exact div_le_self hc hd

end NeuralGeneralization.ValidState
