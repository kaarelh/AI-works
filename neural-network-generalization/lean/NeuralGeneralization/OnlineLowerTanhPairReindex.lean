import NeuralGeneralization.OnlineLowerTanhPairVariation
import NeuralGeneralization.OnlineLowerTanhCodeSupport
import NeuralGeneralization.OnlineLowerTanhBiasIntegral

/-! # Arbitrary-coordinate pair averaging for actual tanh parity neurons -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- Relabeling physical Boolean coordinates is an actual cube bijection. -/
def coordinateCubeEquiv {n m : ℕ} (e : Fin n ≃ Fin m) : Cube m ≃ Cube n where
  toFun x i := x (e i)
  invFun y j := y (e.symm j)
  left_inv x := by funext j; simp
  right_inv y := by funext i; simp

lemma paritySign_coordinateCubeEquiv {n m : ℕ} (e : Fin n ≃ Fin m) (x : Cube m) :
    paritySign (coordinateCubeEquiv e x)=paritySign x := by
  unfold paritySign coordinateCubeEquiv
  exact e.prod_comp (fun i => labelReal (x i))

lemma incomingLinear_coordinateCubeEquiv {n m : ℕ} (e : Fin n ≃ Fin m)
    (u : Fin m → ℝ) (x : Cube m) :
    incomingLinear (fun i => u (e i)) (coordinateCubeEquiv e x)=incomingLinear u x := by
  unfold incomingLinear coordinateCubeEquiv
  exact e.sum_comp (fun i => u i*labelReal (x i))

lemma incomingEnergy_equiv {n m : ℕ} (e : Fin n ≃ Fin m) (u : Fin m → ℝ) :
    incomingEnergy (fun i => u (e i))=incomingEnergy u := by
  exact e.sum_comp (fun i => (u i)^2)

lemma parityCorrelation_equiv {n m : ℕ} (e : Fin n ≃ Fin m) (u : Fin m → ℝ) (b : ℝ) :
    parityCorrelation (fun i => u (e i)) b=parityCorrelation u b := by
  have hs := (coordinateCubeEquiv e).sum_comp (fun x : Cube n =>
    paritySign x*Real.tanh (b+incomingLinear (fun i => u (e i)) x))
  simp_rw [paritySign_coordinateCubeEquiv,incomingLinear_coordinateCubeEquiv] at hs
  have hc := Fintype.card_congr (coordinateCubeEquiv e)
  unfold parityCorrelation
  rw [← hs,← hc]

/-- A concrete permutation putting the chosen pair first. -/
def pairCoordinateEquiv {n : ℕ} (i j : Fin (n+2)) : Equiv.Perm (Fin (n+2)) :=
  (Equiv.swap 0 i).trans (Equiv.swap ((Equiv.swap 0 i) 1) j)

lemma pairCoordinateEquiv_zero {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) :
    pairCoordinateEquiv i j 0=i := by
  have h0 : (0 : Fin (n+2)) ≠ 1 := by
    intro h
    have hv := congrArg Fin.val h
    norm_num at hv
  have ha : i ≠ (Equiv.swap 0 i) 1 := by
    intro h
    have he : (Equiv.swap 0 i) 0=(Equiv.swap 0 i) 1 := by simpa using h
    exact h0 ((Equiv.swap 0 i).injective he)
  simp only [pairCoordinateEquiv,Equiv.trans_apply,Equiv.swap_apply_left]
  exact Equiv.swap_apply_of_ne_of_ne ha hij

lemma pairCoordinateEquiv_one {n : ℕ} (i j : Fin (n+2)) :
    pairCoordinateEquiv i j 1=j := by
  simp only [pairCoordinateEquiv,Equiv.trans_apply,Equiv.swap_apply_left]

lemma pairCoordinateEquiv_rest_ne {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) (k : Fin n) :
    pairCoordinateEquiv i j k.succ.succ ≠ i ∧ pairCoordinateEquiv i j k.succ.succ ≠ j := by
  constructor
  · intro h
    have he := (pairCoordinateEquiv i j).injective (h.trans (pairCoordinateEquiv_zero i j hij).symm)
    have hv := congrArg Fin.val he
    simp at hv
  · intro h
    have he := (pairCoordinateEquiv i j).injective (h.trans (pairCoordinateEquiv_one i j).symm)
    have hv := congrArg Fin.val he
    simp at hv

def pairRest {n : ℕ} (u : Fin (n+2) → ℝ) (i j : Fin (n+2)) : Fin n → ℝ :=
  fun k => u (pairCoordinateEquiv i j k.succ.succ)

def pairMean {n : ℕ} (u : Fin n → ℝ) (i j : Fin n) : ℝ := (u i+u j)/2
def pairImbalance {n : ℕ} (u : Fin n → ℝ) (i j : Fin n) : ℝ := (u i-u j)/2

def averageIncomingPair {n : ℕ} (u : Fin n → ℝ) (i j : Fin n) : Fin n → ℝ :=
  fun k => if k=i ∨ k=j then pairMean u i j else u k

lemma reindexed_pairIncoming {n : ℕ} (u : Fin (n+2) → ℝ) (i j : Fin (n+2)) (hij : i ≠ j) :
    (fun k => u (pairCoordinateEquiv i j k)) =
      pairIncoming (pairRest u i j) (pairMean u i j) (pairImbalance u i j) := by
  funext k
  refine Fin.cases ?_ (fun k => Fin.cases ?_ (fun k => rfl) k) k
  · simp only [pairIncoming,Fin.cases_zero,pairCoordinateEquiv_zero i j hij,pairMean,pairImbalance]
    ring
  · change u (pairCoordinateEquiv i j 1)=pairMean u i j-pairImbalance u i j
    rw [pairCoordinateEquiv_one]
    unfold pairMean pairImbalance
    ring

lemma reindexed_averageIncomingPair {n : ℕ} (u : Fin (n+2) → ℝ)
    (i j : Fin (n+2)) (hij : i ≠ j) :
    (fun k => averageIncomingPair u i j (pairCoordinateEquiv i j k)) =
      pairIncoming (pairRest u i j) (pairMean u i j) 0 := by
  funext k
  refine Fin.cases ?_ (fun k => Fin.cases ?_ (fun k => ?_) k) k
  · simp only [pairIncoming,Fin.cases_zero,pairCoordinateEquiv_zero i j hij,averageIncomingPair]
    simp
  · change averageIncomingPair u i j (pairCoordinateEquiv i j 1)=pairMean u i j-0
    rw [pairCoordinateEquiv_one]
    simp [averageIncomingPair]
  · have hn := pairCoordinateEquiv_rest_ne i j hij k
    simp only [pairIncoming,Fin.cases_succ,averageIncomingPair,pairRest,hn.1,hn.2,false_or,ite_false]

lemma incomingEnergy_averageIncomingPair {n : ℕ} (u : Fin (n+2) → ℝ)
    (i j : Fin (n+2)) (hij : i ≠ j) :
    incomingEnergy (averageIncomingPair u i j)+2*(pairImbalance u i j)^2=incomingEnergy u := by
  rw [← incomingEnergy_equiv (pairCoordinateEquiv i j) u,reindexed_pairIncoming u i j hij]
  rw [← incomingEnergy_equiv (pairCoordinateEquiv i j) (averageIncomingPair u i j),
    reindexed_averageIncomingPair u i j hij]
  exact incomingEnergy_pair_balance _ _ _

/-- The strict pair-balancing improvement for any two distinct physical
coordinates, retaining the actual replacement vector and actual tanh gain. -/
theorem arbitrary_pair_balance_strictly_improves {n : ℕ} (hn : Odd n)
    (u : Fin (n+2) → ℝ) (i j : Fin (n+2)) (hij : i ≠ j) (δ s : ℝ) (hs : |s|=1)
    (hconc : StrictConcaveOn ℝ (Set.Icc (-δ) δ) (fun b => -s*parityCorrelation (pairRest u i j) b))
    (hwindow : |u i-u j| ≤ δ) (hne : u i ≠ u j)
    (hscore : 0 < s*parityCorrelation u 0)
    (henergy : 0 < incomingEnergy (averageIncomingPair u i j)) :
    |parityCorrelation u 0|/Real.sqrt (incomingEnergy u) <
      |parityCorrelation (averageIncomingPair u i j) 0|/Real.sqrt (incomingEnergy (averageIncomingPair u i j)) := by
  have h := pair_balance_strictly_improves hn (pairRest u i j) (pairMean u i j)
    (pairImbalance u i j) δ s hs hconc
    (by simpa only [pairImbalance,show 2*((u i-u j)/2)=u i-u j by ring] using hwindow)
    (by unfold pairImbalance; exact div_ne_zero (sub_ne_zero.mpr hne) (by norm_num))
  have hc : parityCorrelation (pairIncoming (pairRest u i j) (pairMean u i j) (pairImbalance u i j)) 0 =
      parityCorrelation u 0 := by
    rw [← reindexed_pairIncoming u i j hij,parityCorrelation_equiv]
  have hc0 : parityCorrelation (pairIncoming (pairRest u i j) (pairMean u i j) 0) 0 =
      parityCorrelation (averageIncomingPair u i j) 0 := by
    rw [← reindexed_averageIncomingPair u i j hij,parityCorrelation_equiv]
  have he : incomingEnergy (pairIncoming (pairRest u i j) (pairMean u i j) (pairImbalance u i j)) =
      incomingEnergy u := by rw [← reindexed_pairIncoming u i j hij,incomingEnergy_equiv]
  have he0 : incomingEnergy (pairIncoming (pairRest u i j) (pairMean u i j) 0) =
      incomingEnergy (averageIncomingPair u i j) := by
    rw [← reindexed_averageIncomingPair u i j hij,incomingEnergy_equiv]
  rw [hc,he0] at h
  exact (by simpa only [hc,hc0,he,he0] using h hscore henergy)

/-- The literal complement of the two selected physical coordinates. -/
def pairRestSet {n : ℕ} (i j : Fin (n+2)) : Finset (Fin (n+2)) :=
  (Finset.univ.erase i).erase j

lemma mem_pairRestSet {n : ℕ} (i j k : Fin (n+2)) :
    k ∈ pairRestSet i j ↔ k ≠ i ∧ k ≠ j := by
  simp only [pairRestSet,Finset.mem_erase,Finset.mem_univ,and_true]
  tauto

def pairRestSubtypeMap {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) (k : Fin n) : pairRestSet i j :=
  ⟨pairCoordinateEquiv i j k.succ.succ,(mem_pairRestSet i j _).mpr (pairCoordinateEquiv_rest_ne i j hij k)⟩

lemma pairRestSubtypeMap_bijective {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) :
    Function.Bijective (pairRestSubtypeMap i j hij) := by
  constructor
  · intro a b hab
    have he := (pairCoordinateEquiv i j).injective (congrArg Subtype.val hab)
    exact Fin.succ_injective n (Fin.succ_injective (n+1) he)
  · intro z
    let e := pairCoordinateEquiv i j
    let y : Fin (n+2) := e.symm z.val
    have hz := (mem_pairRestSet i j z.val).mp z.property
    have hy0 : y ≠ 0 := by
      intro h
      have he := congrArg e h
      have he0 : e 0=i := pairCoordinateEquiv_zero i j hij
      have hey : e y=z.val := e.apply_symm_apply z.val
      rw [hey,he0] at he
      exact hz.1 he
    have hy1 : y ≠ 1 := by
      intro h
      have he := congrArg e h
      have he1 : e 1=j := pairCoordinateEquiv_one i j
      have hey : e y=z.val := e.apply_symm_apply z.val
      rw [hey,he1] at he
      exact hz.2 he
    have hyval0 : y.val ≠ 0 := by
      intro h
      exact hy0 (Fin.ext h)
    have hyval1 : y.val ≠ 1 := by
      intro h
      exact hy1 (Fin.ext h)
    have hyge : 2 ≤ y.val := by omega
    let k : Fin n := ⟨y.val-2,by have hylt:=y.isLt; omega⟩
    have hky : k.succ.succ=y := by
      apply Fin.ext
      dsimp [k]
      omega
    refine ⟨k,?_⟩
    apply Subtype.ext
    change e k.succ.succ=z.val
    rw [hky]
    exact e.apply_symm_apply _

noncomputable def pairRestSubtypeEquiv {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) :
    Fin n ≃ pairRestSet i j := Equiv.ofBijective _ (pairRestSubtypeMap_bijective i j hij)

lemma pairRestSet_card {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) :
    (pairRestSet i j).card=n := by
  have h := Fintype.card_congr (pairRestSubtypeEquiv i j hij)
  simpa only [Fintype.card_fin,Fintype.card_coe] using h.symm

noncomputable def pairRestFinEquiv {n : ℕ} (i j : Fin (n+2)) (hij : i ≠ j) :
    Fin n ≃ Fin (pairRestSet i j).card :=
  (pairRestSubtypeEquiv i j hij).trans (pairRestSet i j).equivFin

lemma pairRest_subsetWeights_reindex {n : ℕ} (u : Fin (n+2) → ℝ)
    (i j : Fin (n+2)) (hij : i ≠ j) :
    (fun k => subsetWeights (pairRestSet i j) u (pairRestFinEquiv i j hij k))=pairRest u i j := by
  funext k
  unfold subsetWeights pairRestFinEquiv
  simp only [Equiv.trans_apply,Equiv.symm_apply_apply]
  rfl

lemma parityCorrelation_pairRest {n : ℕ} (u : Fin (n+2) → ℝ)
    (i j : Fin (n+2)) (hij : i ≠ j) (b : ℝ) :
    parityCorrelation (pairRest u i j) b=parityCorrelation (subsetWeights (pairRestSet i j) u) b := by
  rw [← pairRest_subsetWeights_reindex u i j hij,parityCorrelation_equiv]

lemma incomingEnergy_pairRest {n : ℕ} (u : Fin (n+2) → ℝ)
    (i j : Fin (n+2)) (hij : i ≠ j) :
    incomingEnergy (pairRest u i j)=incomingEnergy (subsetWeights (pairRestSet i j) u) := by
  rw [← pairRest_subsetWeights_reindex u i j hij,incomingEnergy_equiv]

lemma averageIncomingPair_energy_pos {n : ℕ} (u : Fin n → ℝ) (i j : Fin n)
    (hi : 0 < u i) (hj : 0 < u j) : 0 < incomingEnergy (averageIncomingPair u i j) := by
  have hμ : 0 < pairMean u i j := by unfold pairMean; positivity
  have he : averageIncomingPair u i j i=pairMean u i j := by simp [averageIncomingPair]
  have hsum := Finset.single_le_sum (s:=Finset.univ)
    (fun k (_ : k ∈ Finset.univ) => sq_nonneg (averageIncomingPair u i j k)) (Finset.mem_univ i)
  rw [he] at hsum
  exact lt_of_lt_of_le (sq_pos_of_pos hμ) hsum

/-- The same arbitrary-pair improvement stated with the canonical physical
complement and with positivity discharging the replacement-energy premise. -/
theorem arbitrary_pair_balance_strictly_improves_canonical {n : ℕ} (hn : Odd n)
    (u : Fin (n+2) → ℝ) (i j : Fin (n+2)) (hij : i ≠ j) (δ s : ℝ) (hs : |s|=1)
    (hconc : StrictConcaveOn ℝ (Set.Icc (-δ) δ)
      (fun b => -s*parityCorrelation (subsetWeights (pairRestSet i j) u) b))
    (hwindow : |u i-u j| ≤ δ) (hne : u i ≠ u j)
    (hi : 0 < u i) (hj : 0 < u j) (hscore : 0 < s*parityCorrelation u 0) :
    |parityCorrelation u 0|/Real.sqrt (incomingEnergy u) <
      |parityCorrelation (averageIncomingPair u i j) 0|/Real.sqrt (incomingEnergy (averageIncomingPair u i j)) := by
  apply arbitrary_pair_balance_strictly_improves hn u i j hij δ s hs _ hwindow hne hscore
    (averageIncomingPair_energy_pos u i j hi hj)
  simpa only [parityCorrelation_pairRest u i j hij] using hconc

lemma strictConcave_parity_of_biasSecond_neg {n : ℕ} (u : Fin n → ℝ) (δ s : ℝ)
    (hcurv : ∀ b : ℝ, |b| ≤ δ → -s*parityBiasSecond u b < 0) :
    StrictConcaveOn ℝ (Set.Icc (-δ) δ) (fun b => -s*parityCorrelation u b) := by
  have hd (b : ℝ) := (hasDerivAt_parityCorrelation u b).const_mul (-s)
  have hd' : deriv (fun b => -s*parityCorrelation u b)=(fun b => -s*parityBiasFirst u b) := by
    funext b
    exact (hd b).deriv
  have hc : Continuous (fun b => -s*parityCorrelation u b) :=
    continuous_iff_continuousAt.mpr (fun b => (hd b).continuousAt)
  apply strictConcaveOn_of_deriv2_neg' (convex_Icc _ _) hc.continuousOn
  intro b hb
  change deriv (deriv (fun b => -s*parityCorrelation u b)) b < 0
  rw [hd',(hasDerivAt_parityBiasFirst u b).const_mul (-s) |>.deriv]
  exact hcurv b (abs_le.mpr hb)

theorem arbitrary_pair_balance_of_curvature {n : ℕ} (hn : Odd n)
    (u : Fin (n+2) → ℝ) (i j : Fin (n+2)) (hij : i ≠ j) (δ s : ℝ) (hs : |s|=1)
    (hcurv : ∀ b : ℝ, |b| ≤ δ →
      -s*parityBiasSecond (subsetWeights (pairRestSet i j) u) b < 0)
    (hwindow : |u i-u j| ≤ δ) (hne : u i ≠ u j)
    (hi : 0 < u i) (hj : 0 < u j) (hscore : 0 < s*parityCorrelation u 0) :
    |parityCorrelation u 0|/Real.sqrt (incomingEnergy u) <
      |parityCorrelation (averageIncomingPair u i j) 0|/Real.sqrt (incomingEnergy (averageIncomingPair u i j)) :=
  arbitrary_pair_balance_strictly_improves_canonical hn u i j hij δ s hs
    (strictConcave_parity_of_biasSecond_neg _ δ s hcurv) hwindow hne hi hj hscore

end NeuralGeneralization.OnlineLowerTanh
