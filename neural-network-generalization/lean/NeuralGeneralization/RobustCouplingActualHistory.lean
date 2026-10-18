import NeuralGeneralization.RobustCouplingStoppedHistory
import NeuralGeneralization.RobustCompressionInductionInitialHistory

/-!
# Actual original-history alignment and live path recursion

The invariant ties the canonical standardized future to the unchanged original
network and the last stored virtual activation to the canonical prefix. This
identifies the local matrix in the additive path-cost identity exactly.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionBlockMoments

/-- The unconsumed standardized coordinates of one fixed original network. -/
def originalFuture {d N r s k : ℕ} (h : s+k ≤ r) (σ : ℝ)
    (w : Weights d N r) : FutureWeights N k :=
  Sum.elim
    (fun lij => standardizedWeights σ w
      (Sum.inr (Sum.inl (⟨s+lij.1.val, by have := lij.1.isLt; omega⟩,lij.2))))
    (fun i => standardizedWeights σ w (Sum.inr (Sum.inr i)))

theorem originalFuture_tail {d N r s k : ℕ} (h : s+(k+1) ≤ r) (σ : ℝ)
    (w : Weights d N r) :
    (splitFuture N k (originalFuture h σ w)).2 =
      originalFuture (by omega : (s+1)+k ≤ r) σ w := by
  funext z
  rcases z with ⟨l,i,j⟩ | i
  · rw [splitFuture_later]
    unfold originalFuture
    simp only [Sum.elim_inl]
    congr 4
    apply Fin.ext
    simp only [Fin.val_succ]
    omega
  · rfl

theorem originalFuture_current_physical {d N r s k : ℕ} (h : s+(k+1) ≤ r)
    {σ : ℝ} (hσ : σ ≠ 0) (w : Weights d N r) (i j : Fin N) :
    σ * (splitFuture N k (originalFuture h σ w)).1 (i,j) =
      w (Sum.inr (Sum.inl (⟨s,by omega⟩,i,j))) := by
  rw [splitFuture_current]
  simp [originalFuture, standardizedWeights, whiten, coordinateScale, smallVariance]
  field_simp

theorem originalFuture_initial {d N m r : ℕ} (σ B : ℝ) (w : Weights d N r) :
    (initialState m σ B w).2 = originalFuture (by omega : 0+r ≤ r) σ w := by
  funext z
  rcases z with ⟨l,i,j⟩ | i
  · change standardizedWeights σ w (Sum.inr (Sum.inl (l,i,j))) =
      standardizedWeights σ w (Sum.inr (Sum.inl (⟨0+l.val,by omega⟩,i,j)))
    congr 4
    apply Fin.ext
    simp
  · rfl

/-- Both alignments are deterministic support invariants of the history law. -/
def HistoryAligned {d N m r s k : ℕ} (h : s+k ≤ r) (σ : ℝ)
    (φ : ℝ → ℝ) (x : Cube d)
    (history : OriginalHistory d N r s) (state : ActivePrefix d N m s × FutureWeights N k) : Prop :=
  state.2 = originalFuture h σ history.1 ∧
    history.2 (Fin.last s) = activeHidden φ state.1 x

def appendOriginalHistory {d N m r s k : ℕ} (φ : ℝ → ℝ) (x : Cube d)
    (history : OriginalHistory d N r s)
    (_oldState : ActivePrefix d N m s × FutureWeights N (k+1))
    (newState : ActivePrefix d N m (s+1) × FutureWeights N k) : OriginalHistory d N r (s+1) :=
  (history.1, appendPath history.2 (activeHidden φ newState.1 x))

@[simp] theorem appendOriginalHistory_original {d N m r s k : ℕ}
    (φ : ℝ → ℝ) (x : Cube d) (h : OriginalHistory d N r s)
    (old : ActivePrefix d N m s × FutureWeights N (k+1))
    (next : ActivePrefix d N m (s+1) × FutureWeights N k) :
    (appendOriginalHistory φ x h old next).1 = h.1 := rfl

theorem appendOriginalHistory_aligned {d N m r s k : ℕ} (h : s+(k+1) ≤ r)
    (σ : ℝ) (φ : ℝ → ℝ) (x : Cube d) (history : OriginalHistory d N r s)
    (old : ActivePrefix d N m s × FutureWeights N (k+1))
    (next : ActivePrefix d N m (s+1) × FutureWeights N k)
    (halign : HistoryAligned h σ φ x history old)
    (hfuture : next.2 = (splitFuture N k old.2).2) :
    HistoryAligned (by omega : (s+1)+k ≤ r) σ φ x
      (appendOriginalHistory φ x history old next) next := by
  constructor
  · change next.2 = originalFuture _ σ history.1
    rw [hfuture, halign.1, originalFuture_tail]
  · exact appendPath_last history.2 (activeHidden φ next.1 x)

theorem initialHistory_aligned {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (B : ℝ) (φ : ℝ → ℝ) (x : Cube d) (w : Weights d N r) :
    HistoryAligned (by omega : 0+r ≤ r) σ φ x
      (w, initialHistoryPath φ B x w) (initialState m σ B w) := by
  exact ⟨originalFuture_initial σ B w, (initialState_hidden hd hN hσ B φ w x).symm⟩

/-- The exact local cost uses the matrix actually stored in the canonical
future, after undoing its standardization. -/
theorem appendOriginalHistory_cost {d N m r s k : ℕ} (h : s+(k+1) ≤ r)
    {σ : ℝ} (hσ : σ ≠ 0) (φ : ℝ → ℝ) (x : Cube d)
    (history : OriginalHistory d N r s)
    (old : ActivePrefix d N m s × FutureWeights N (k+1))
    (next : ActivePrefix d N m (s+1) × FutureWeights N k)
    (halign : HistoryAligned h σ φ x history old) :
    originalPathCost (by omega : s+1 ≤ r) φ
      (appendOriginalHistory φ x history old next).1 x
      (appendOriginalHistory φ x history old next).2 =
    originalPathCost (by omega : s ≤ r) φ history.1 x history.2 +
      localPathCost φ (fun i j => σ * (splitFuture N k old.2).1 (i,j))
        (activeHidden φ old.1 x) (activeHidden φ next.1 x) := by
  rw [appendOriginalHistory, originalPathCost_succ, halign.2, halign.1]
  congr 2
  funext i j
  exact (originalFuture_current_physical h hσ history.1 i j).symm



theorem measurable_originalFuture {d N r s k : ℕ} (h : s+k ≤ r) (σ : ℝ) :
    Measurable (originalFuture (d:=d) (N:=N) h σ) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ⟨l,i,j⟩ | i
  · change Measurable (fun w : Weights d N r =>
      w (Sum.inr (Sum.inl (⟨s+l.val,by omega⟩,i,j))) /
        coordinateScale d N r (Sum.inr (Sum.inl (⟨s+l.val,by omega⟩,i,j))) / σ)
    fun_prop
  · change Measurable (fun w : Weights d N r =>
      w (Sum.inr (Sum.inr i)) / coordinateScale d N r (Sum.inr (Sum.inr i)) / σ)
    fun_prop

theorem measurableSet_historyAligned {d N m r s k : ℕ} (h : s+k ≤ r)
    (σ : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d) :
    MeasurableSet {z : OriginalHistory d N r s ×
      (ActivePrefix d N m s × FutureWeights N k) | HistoryAligned h σ φ x z.1 z.2} := by
  have hf : Measurable (fun z : OriginalHistory d N r s ×
      (ActivePrefix d N m s × FutureWeights N k) => originalFuture h σ z.1.1) :=
    (measurable_originalFuture h σ).comp (measurable_fst.comp measurable_fst)
  have ha : Measurable (fun z : OriginalHistory d N r s ×
      (ActivePrefix d N m s × FutureWeights N k) => activeHidden φ z.2.1 x) :=
    (measurable_activeHidden hφ x).comp (measurable_fst.comp measurable_snd)
  exact (measurableSet_eq_fun (measurable_snd.comp measurable_snd) hf).inter
    (measurableSet_eq_fun (measurable_snd.comp measurable_fst).eval ha)

theorem measurable_appendPath {A : Type*} [MeasurableSpace A] {N s : ℕ}
    (h : A → HiddenPath N s) (v : A → Fin N → ℝ)
    (hh : Measurable h) (hv : Measurable v) :
    Measurable (fun z => appendPath (h z) (v z)) := by
  apply measurable_pi_lambda
  intro j
  induction j using Fin.lastCases with
  | last => simpa using hv
  | cast j => simpa using (hh.eval : Measurable (fun z => h z j))

theorem measurable_appendOriginalHistory {d N m r s k : ℕ}
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun z : (OriginalHistory d N r s ×
        (ActivePrefix d N m s × FutureWeights N (k+1))) ×
        (ActivePrefix d N m (s+1) × FutureWeights N k) =>
      appendOriginalHistory φ x z.1.1 z.1.2 z.2) := by
  apply Measurable.prodMk (measurable_fst.comp (measurable_fst.comp measurable_fst))
  apply measurable_appendPath _ _
    (measurable_snd.comp (measurable_fst.comp measurable_fst))
  exact (measurable_activeHidden hφ x).comp (measurable_fst.comp measurable_snd)

theorem measurable_originalPathCost {d N r s : ℕ} (hs : s ≤ r)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun h : OriginalHistory d N r s => originalPathCost hs φ h.1 x h.2) := by
  have hφm : Measurable φ := hφ.measurable
  have hw : Measurable (fun h : OriginalHistory d N r s => originalPrefix hs h.1) :=
    (measurable_originalPrefix hs).comp measurable_fst
  unfold originalPathCost hiddenPathCost firstHidden hiddenStep
  fun_prop

/-- The concrete absorbing success flag masks the exact original-network
path recursion. The equality need hold only on the aligned history support. -/
theorem appendOriginalHistory_masked_cost_le {d N m r s k : ℕ}
    (h : s+(k+1) ≤ r) {σ : ℝ} (hσ : σ ≠ 0) (φ : ℝ → ℝ) (x : Cube d)
    (history : OriginalHistory d N r s)
    (old : ActivePrefix d N m s × FutureWeights N (k+1))
    (next : ActivePrefix d N m (s+1) × FutureWeights N k)
    (halign : HistoryAligned h σ φ x history old)
    (hlive : next.1.1=true → old.1.1=true) :
    (if next.1.1=true then originalPathCost (by omega : s+1 ≤ r) φ
      (appendOriginalHistory φ x history old next).1 x
      (appendOriginalHistory φ x history old next).2 else 0) ≤
    (if old.1.1=true then originalPathCost (by omega : s ≤ r) φ history.1 x history.2 else 0) +
    (if next.1.1=true then localPathCost φ
      (fun i j => σ * (splitFuture N k old.2).1 (i,j))
        (activeHidden φ old.1 x) (activeHidden φ next.1 x) else 0) := by
  by_cases hn : next.1.1=true
  · rw [if_pos hn, if_pos (hlive hn), if_pos hn]
    exact (appendOriginalHistory_cost h hσ φ x history old next halign).le
  · rw [if_neg hn, if_neg hn, add_zero]
    split
    · exact hiddenPathCost_nonneg _ _ _ _
    · exact le_rfl

end NeuralGeneralization.RobustCompressionInduction
