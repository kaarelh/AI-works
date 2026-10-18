import NeuralGeneralization.RobustCompressionSourceBankReindex
import NeuralGeneralization.RobustCompressionSelectedBank
import NeuralGeneralization.RobustCompressionSelectedStateDraw
import NeuralGeneralization.RobustCompressionInductionQueries
import NeuralGeneralization.RobustCompressionInductionPath

/-! # Exact live-path cost of the selected canonical layer -/
noncomputable section
set_option maxHeartbeats 700000
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustCompressionSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionCanonicalLayer RobustCompressionReconstruction RobustCompressionSourceBank
open RobustCompressionLayerParameters
variable {d N m s q : ℕ} {Y : Type*} [MeasurableSpace Y]
local notation "P" => ActivePrefix d N m s
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)
variable [MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))] [MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

def indexedPrefixHidden (φ : ℝ → ℝ) (p : P) (i : Fin (Fintype.card (Cube d))) : Fin N → ℝ :=
  activeHidden φ p ((Fintype.equivFin (Cube d)).symm i)

theorem measurable_indexedPrefixHidden {φ : ℝ → ℝ} (hφ : Continuous φ) :
    Measurable (indexedPrefixHidden (d:=d) (N:=N) (m:=m) (s:=s) φ) :=
  measurable_pi_lambda _ (fun _ => measurable_activeHidden hφ _)

theorem sourceBankGood_indexed_iff (u : Fin N → EuclideanSpace ℝ (Fin q))
    (φ : ℝ → ℝ) (p : P) (a T : ℝ) (I : Fin m → Fin N) :
    sourceBankGood u (indexedPrefixHidden φ p) a T I ↔
      sourceBankGood u (activeHidden φ p) a T I :=
  sourceBankGood_cube_reindex u (activeHidden φ p) a T I

def selectedPathSuccess (φ : ℝ → ℝ) (J : P × Y → Finset (Fin (Fintype.card (Cube d))))
    (a T : ℝ) (θ : P × Y) (I : Fin m → Fin N) : Prop :=
  θ.1.1=true ∧ (J θ).card ≤ q ∧
    sourceBankGood (sourceRows (selectedMessageBasis (q:=q) (indexedPrefixQueries φ) J θ))
      (activeHidden φ θ.1) a T I

theorem measurableSet_selectedPathSuccess {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin (Fintype.card (Cube d)))) (hJ : Measurable J) (a T : ℝ) :
    MeasurableSet {θ : SelectedBankState P Y N m q | selectedPathSuccess (q:=q) φ J a T θ.1.1 θ.2} := by
  have hsource : Measurable (fun θ : SelectedBankState P Y N m q =>
      sourceRows (selectedMessageBasis (q:=q) (indexedPrefixQueries φ) J θ.1.1)) :=
    measurable_sourceRows.comp ((measurable_selectedMessageBasis (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) J hJ).comp (measurable_fst.comp measurable_fst))
  have hfeature : Measurable (fun θ : SelectedBankState P Y N m q => activeHidden φ θ.1.1.1) := by
    apply measurable_pi_lambda
    intro x
    exact (measurable_activeHidden hφ x).comp (measurable_fst.comp (measurable_fst.comp measurable_fst))
  have hbank := (measurableSet_sourceBankGood (N:=N) (m:=m) (q:=q) (X:=Cube d) a T).preimage
    ((hsource.prodMk hfeature).prodMk measurable_snd)
  have hcard : Measurable (fun θ : SelectedBankState P Y N m q => (J θ.1.1).card) :=
    (measurable_of_countable (fun S : Finset (Fin (Fintype.card (Cube d))) => S.card)).comp
      (hJ.comp (measurable_fst.comp measurable_fst))
  exact (measurableSet_eq_fun (by fun_prop) measurable_const).inter
    ((measurableSet_le hcard measurable_const).inter hbank)

theorem selectedPathSuccess_good_indexed (φ : ℝ → ℝ)
    (J : P × Y → Finset (Fin (Fintype.card (Cube d)))) (a T : ℝ)
    (θ : P × Y) (I : Fin m → Fin N)
    (hs : selectedPathSuccess (q:=q) φ J a T θ I) :
    sourceBankGood (sourceRows (selectedMessageBasis (q:=q) (indexedPrefixQueries φ) J θ))
      (indexedPrefixHidden φ θ.1) a T I :=
  (sourceBankGood_indexed_iff _ φ θ.1 a T I).mpr hs.2.2

theorem stepActive_alive_iff (p : P) (draw : PrefixDraw N m) (success : Bool) :
    (stepActive p draw success).1=true ↔ p.1=true ∧ success=true := by
  unfold stepActive
  split_ifs with hh
  · exact ⟨fun _ => Bool.and_eq_true_iff.mp hh,fun _ => rfl⟩
  · constructor
    · intro h; cases h
    · intro h; exact (hh (Bool.and_eq_true_iff.mpr h)).elim

theorem activeHidden_step_of_alive (φ : ℝ → ℝ) (x : Cube d)
    (p : P) (draw : PrefixDraw N m) (success : Bool)
    (hlive : (stepActive p draw success).1=true) :
    activeHidden φ (stepActive p draw success) x =
      fun i => φ (∑ j,draw.2 i j*activeHidden φ p x (draw.1 j)) := by
  obtain ⟨hp,hs⟩ := (stepActive_alive_iff p draw success).mp hlive
  unfold stepActive
  rw [if_pos (Bool.and_eq_true_iff.mpr ⟨hp,hs⟩)]
  unfold activeHidden
  rw [if_pos hp]
  exact payloadHidden_step d N m s φ x p.2 draw

theorem selectedStateFromH_alive_iff (φ : ℝ → ℝ)
    (J : P × Y → Finset (Fin (Fintype.card (Cube d)))) (a t T BH BG : ℝ) (θ : P × Y)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (ξ : Fin N → Fin m → ℝ) :
    (selectedStateFromH φ (indexedPrefixQueries φ) J a t T BH BG θ (H,(I,ξ))).1=true ↔
      selectedPathSuccess (q:=q) φ J a T θ I := by
  unfold selectedStateFromH
  rw [stepActive_alive_iff]
  unfold canonicalLayerSuccess selectedPathSuccess
  rw [decide_eq_true_eq]
  change (θ.1.1=true ∧ (abortQueryMessage q (J θ) ≠ none ∧ _)) ↔ _
  have hm : abortQueryMessage q (J θ) ≠ none ↔ (J θ).card ≤ q := by
    rw [ne_eq,abortQueryMessage_eq_none,not_lt]
  rw [hm]
  rfl

/-- The finite observable is the actual compact-row preactivation. This does
not require the good-bank hypothesis: totalization changes only covariance. -/
theorem selected_clippedFiniteObservable_eq_rows
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin (Fintype.card (Cube d)))) (hJ : Measurable J)
    (a t T BH BG : ℝ) (i : Fin (Fintype.card (Cube d)))
    (θ : P × Y) (H : Fin N → EuclideanSpace ℝ (Fin q))
    (I : Fin m → Fin N) (ξ : Fin N → Fin m → ℝ) (j : Fin N) :
    let data := selectedBankData (m:=m) (q:=q) (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
    let p := data.totalizedParameters a t T BH i
    p.clippedFiniteObservable BG (((θ,H),I),ξ) j =
      ∑ k, fixedSourceRowsDraw a t T BH BG
        ((sourceRows (selectedMessageBasis (q:=q) (indexedPrefixQueries φ) J θ),H),I) ξ j k *
          indexedPrefixHidden φ θ.1 i (I k) := by
  dsimp only
  rw [BankLayerData.totalizedParameters_clippedFiniteObservable,
    BankLayerData.clippedFiniteObservable_eq_rows]
  rfl

/-- Exact equality of the masked path increment and the analytic layer-error
integrand, with the original residual scalar retained from the H observation. -/
theorem selectedStateFromH_masked_path_cost [NeZero N]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin (Fintype.card (Cube d)))) (hJ : Measurable J)
    {t : ℝ} (ht : 0 ≤ t) (a T BH BG : ℝ) (i : Fin (Fintype.card (Cube d)))
    (θ : P × Y) (g : Rows) (dummy : Fin N → ℝ)
    (I : Fin m → Fin N) (ξ : Fin N → Fin m → ℝ) :
    let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
    let o := selectedHObservation (q:=q) b J t i (θ,(g,dummy))
    let next := selectedStateFromH φ b J a t T BH BG θ (o.1,(I,ξ))
    let data := selectedBankData (m:=m) (q:=q) b (measurable_indexedPrefixQueries hφ)
      J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
    let p := data.totalizedParameters a t T BH i
    let state : SelectedBankState P Y N m q := ((θ,o.1),I)
    (if next.1=true then localPathCost φ (fun j k => (t/Real.sqrt (N : ℝ))*g j k)
      (indexedPrefixHidden φ θ.1 i)
      (activeHidden φ next ((Fintype.equivFin (Cube d)).symm i)) else 0) =
    if selectedPathSuccess (q:=q) φ J a T θ I then
      (∑ j, (φ (⟪data.active state j,data.idealFeature i state⟫+
          Real.sqrt (p.idealVariance state j : ℝ)*o.2 j) -
        φ (p.clippedFiniteObservable BG (state,ξ) j))^2)/(N : ℝ) else 0 := by
  dsimp only
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
  let o := selectedHObservation (q:=q) b J t i (θ,(g,dummy))
  let next := selectedStateFromH φ b J a t T BH BG θ (o.1,(I,ξ))
  let data := selectedBankData (m:=m) (q:=q) b (measurable_indexedPrefixQueries hφ)
    J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
  have hlive := selectedStateFromH_alive_iff φ J a t T BH BG θ o.1 I ξ
  by_cases hs : selectedPathSuccess (q:=q) φ J a T θ I
  · rw [if_pos (hlive.mpr hs),if_pos hs]
    have hh := activeHidden_step_of_alive φ ((Fintype.equivFin (Cube d)).symm i)
      θ.1 (I,fixedSourceRowsDraw a t T BH BG
        ((sourceRows (selectedMessageBasis (q:=q) b J θ),o.1),I) ξ)
      (canonicalLayerSuccess φ b a T (selectedCanonicalInput (q:=q) J θ 0) (I,0))
      (hlive.mpr hs)
    change activeHidden φ (selectedStateFromH φ b J a t T BH BG θ (o.1,(I,ξ)))
      ((Fintype.equivFin (Cube d)).symm i) = _ at hh
    dsimp only [b,o] at hh
    unfold localPathCost
    rw [hh]
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    have hold := SelectedBank.original_preactivation b (measurable_indexedPrefixQueries hφ)
      J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ)
      (fun _ _ => rfl) ht a T BH i θ hs.2.1 g dummy I j
    have hpre : t*⟪b θ.1 i,g j⟫ =
        ∑ k,(t/Real.sqrt (N : ℝ))*g j k*indexedPrefixHidden φ θ.1 i k := by
      simp only [b,indexedPrefixQueries,prefixQueries,indexedPrefixHidden,
        EuclideanSpace.inner_eq_star_dotProduct,dotProduct,star_trivial,Pi.star_apply]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k hk
      ring
    have hnew := selected_clippedFiniteObservable_eq_rows hφ J hJ a t T BH BG i θ o.1 I ξ j
    have hold' : ⟪data.active ((θ,o.1),I) j,data.idealFeature i ((θ,o.1),I)⟫+
        Real.sqrt ((data.totalizedParameters a t T BH i).idealVariance ((θ,o.1),I) j : ℝ)*o.2 j =
        t*⟪b θ.1 i,g j⟫ := hold
    have hnew' : (data.totalizedParameters a t T BH i).clippedFiniteObservable BG (((θ,o.1),I),ξ) j =
        ∑ k,fixedSourceRowsDraw a t T BH BG ((sourceRows (selectedMessageBasis (q:=q) b J θ),o.1),I) ξ j k *
          indexedPrefixHidden φ θ.1 i (I k) := hnew
    have heq : (φ (∑ k,fixedSourceRowsDraw a t T BH BG
          ((sourceRows (selectedMessageBasis (q:=q) b J θ),o.1),I) ξ j k * indexedPrefixHidden φ θ.1 i (I k)) -
        φ (∑ k,(t/Real.sqrt (N : ℝ))*g j k*indexedPrefixHidden φ θ.1 i k))^2 =
      (φ (⟪data.active ((θ,o.1),I) j,data.idealFeature i ((θ,o.1),I)⟫+
        Real.sqrt ((data.totalizedParameters a t T BH i).idealVariance ((θ,o.1),I) j : ℝ)*o.2 j) -
        φ ((data.totalizedParameters a t T BH i).clippedFiniteObservable BG (((θ,o.1),I),ξ) j))^2 := by
      rw [hold',hpre,hnew']
      ring
    exact heq
  · rw [if_neg (fun hn => hs (hlive.mp hn)),if_neg hs]

end NeuralGeneralization.RobustCompressionSelectedBank
