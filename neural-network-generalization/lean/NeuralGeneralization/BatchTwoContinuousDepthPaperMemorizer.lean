import NeuralGeneralization.BatchTwoContinuousDepthPaperSchedule
import Mathlib.Data.Finset.Sort

/-! The actual globally bounded memorizer at the manuscript's exact energy
budget, first for ordered projected coordinates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

/-- Ordered-coordinate version of the paper's bounded-label memorization
lemma. No condition is imposed on the query input in the global output bound. -/
theorem exists_ordered_paper_memorizer {d m k M N : ℕ}
    (hM : m+1 ≤ M) (hMN : M ≤ N) {δ : ℝ} (hδ : 0 < δ)
    (u : Fin d → ℝ) (hu : ∑ j,u j^2 ≤ 1)
    (s : Fin (m+1) → RealInput d) (y : Fin (m+1) → ℝ)
    (hs : ∀ i, |∑ j,u j*s i j| ≤ 1)
    (hmono : Monotone (fun i => ∑ j,u j*s i j))
    (hsep : ∀ i : Fin m, δ ≤ (∑ j,u j*s i.succ j)-(∑ j,u j*s i.castSucc j))
    (hy : ∀ i, |y i| ≤ 7/8)
    (hwidth : 3*(d : ℝ)*((m+1 : ℕ) : ℝ)*(max 2 (interpolationSlope (m+1) δ))^2 ≤ M) :
    ∃ w : Weights d N (k+1), (∀ i,output Real.tanh w (s i)=y i) ∧
      (∀ x : RealInput d, |output Real.tanh w x| ≤ 1) ∧
      weightedSquaredNorm w ≤ energyBudget (k+3) (4*(M : ℝ)*((m+1 : ℕ) : ℝ)) := by
  have hMp : 0 < M := by omega
  have hNp : 0 < N := by omega
  let T : ℝ := 4*(M : ℝ)*((m+1 : ℕ) : ℝ)
  have hMR : (1 : ℝ) ≤ M := by exact_mod_cast hMp
  have hmR : (1 : ℝ) ≤ (m+1 : ℕ) := by exact_mod_cast Nat.succ_pos m
  have hT : 2 ≤ T := by dsimp [T]; nlinarith
  let q := paperChannelQ k T
  have hq : 1 ≤ q := paperChannelQ_ge_one k hT
  let rs := tentRadius k q
  have hrs (i : Fin (k+1)) : rs i ∈ Set.Ioo (0 : ℝ) 1 :=
    ⟨tentRadius_pos hq i,lt_of_le_of_lt (tentRadius_le_half hq i) (by norm_num)⟩
  have hrsList : ∀ r ∈ radiusList rs, r ∈ Set.Ioo (0 : ℝ) 1 := by
    intro r hr
    obtain ⟨i,_,rfl⟩ := List.mem_map.mp hr
    exact hrs i
  let z : Fin (m+1) → ℝ := fun i => inverseChannelComposition (radiusList rs) (y i)
  have hz (i : Fin (m+1)) : |z i| ≤ 7/8 :=
    (inverseChannelComposition_bound _ hrsList ((hy i).trans (by norm_num))).trans (hy i)
  let p : Fin (m+1) → ℝ := fun i => ∑ j,u j*s i j
  obtain ⟨t,ht,hinterp,hglobal⟩ := exists_bounded_step_interpolator hδ p hmono hsep z hz
  let a := interpolationSlope (m+1) δ
  let R := max 2 a
  have ha : 0 < a := interpolationSlope_pos (Nat.succ_pos m) hδ
  obtain ⟨v,hv,hvfirst,hvlast⟩ := exists_padded_step_network hM a u (sampleCenters p) t hu
    (sampleCenters_bound p hs) ht (show 2 ≤ R from le_max_left _ _)
    (show |a| ≤ R by rw [abs_of_pos ha]; exact le_max_right _ _) hwidth
  obtain ⟨vN,hvN,hvNfirst,hvNlast⟩ := exists_real_clone_separate hMp hMN v
  let w := variableChannelWeights (radiusGains rs) (1/rs (Fin.last k)) vN
  refine ⟨w,?_,?_,?_⟩
  · intro i
    rw [show output Real.tanh w (s i)=channelComposition (radiusList rs)
      (output Real.tanh vN (s i)) from radiusChannel_output hNp rs (fun i => (hrs i).1.ne') vN (s i),
      hvN,hv,hinterp]
    exact channelComposition_inverse _ hrsList ((hy i).trans (by norm_num))
  · apply radiusChannel_global_bound hNp rs hrs vN
    intro x
    rw [hvN,hv]
    exact hglobal _
  · have hfirst : (d : ℝ)/N*(∑ i,∑ j,(vN (Sum.inl (i,j)))^2) ≤ 1 :=
      hvNfirst.trans hvfirst
    have hlast : (N : ℝ)*(∑ i,(vN (Sum.inr (Sum.inr i)))^2) ≤ channelReadoutBudget k q := by
      have h := mul_le_mul_of_nonneg_left hvlast (by norm_num : (0 : ℝ)≤2)
      have hD : channelReadoutBudget k q=2*T := paperChannelQ_readout k hT
      rw [hD]
      change _ ≤ 2*(4*(M : ℝ)*((m+1 : ℕ) : ℝ))
      nlinarith
    have hscalar := mul_le_mul_of_nonneg_left hlast (sq_nonneg (Real.artanh (rs 0)))
    have hcost : weightedSquaredNorm w ≤ 1+channelReadoutBudget k q*(Real.artanh (rs 0))^2+
        (∑ i : Fin k, (Real.artanh (rs i.succ)/rs i.castSucc)^2)+(1/rs (Fin.last k))^2 := by
      dsimp [w]
      rw [variableChannel_energy hNp]
      simp only [radiusGains,Fin.cases_zero,Fin.cases_succ]
      nlinarith
    exact hcost.trans ((tentRadius_total_cost hq).trans (paperChannelQ_energy k hT))

/-- Sorting is a permutation of the original finite sample indices; no
inputs or labels are discarded. -/
theorem exists_sorting_permutation {n : ℕ} (s : Fin n → ℝ) (hs : Function.Injective s) :
    ∃ e : Equiv.Perm (Fin n), StrictMono (fun i => s (e i)) := by
  classical
  let S : Finset ℝ := Finset.univ.image s
  have hcard : S.card=n := by simp only [S,Finset.card_image_of_injective _ hs,Finset.card_univ,Fintype.card_fin]
  let f := S.orderEmbOfFin hcard
  have hf (i : Fin n) : ∃ j : Fin n, s j=f i := by
    have hm := S.orderEmbOfFin_mem hcard i
    obtain ⟨j,_,hj⟩ := Finset.mem_image.mp hm
    exact ⟨j,hj⟩
  choose p hp using hf
  have hinj : Function.Injective p := by
    intro i j hij
    apply f.injective
    rw [← hp i,← hp j,hij]
  let e := Equiv.ofBijective p ⟨hinj,Finite.surjective_of_injective hinj⟩
  refine ⟨e,?_⟩
  intro i j hij
  change s (p i)<s (p j)
  rw [hp,hp]
  exact f.strictMono hij


/-- The globally bounded memorizer for an arbitrarily ordered sample. -/
theorem exists_paper_memorizer {d n k M N : ℕ} (hn : 0 < n)
    (hM : n ≤ M) (hMN : M ≤ N) {δ : ℝ} (hδ : 0 < δ)
    (u : Fin d → ℝ) (hu : ∑ j,u j^2 ≤ 1)
    (s : Fin n → RealInput d) (y : Fin n → ℝ)
    (hs : ∀ i, |∑ j,u j*s i j| ≤ 1)
    (hsep : ∀ i j, i≠j → δ ≤ |(∑ l,u l*s i l)-(∑ l,u l*s j l)|)
    (hy : ∀ i, |y i| ≤ 7/8)
    (hwidth : 3*(d : ℝ)*(n : ℝ)*(max 2 (interpolationSlope n δ))^2 ≤ M) :
    ∃ w : Weights d N (k+1), (∀ i,output Real.tanh w (s i)=y i) ∧
      (∀ x : RealInput d, |output Real.tanh w x| ≤ 1) ∧
      weightedSquaredNorm w ≤ energyBudget (k+3) (4*(M : ℝ)*(n : ℝ)) := by
  obtain ⟨m,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn.ne'
  let p : Fin (m+1) → ℝ := fun i => ∑ j,u j*s i j
  have hp : Function.Injective p := by
    intro i j hij
    by_contra hne
    have h := hsep i j hne
    change δ ≤ |p i-p j| at h
    rw [hij,sub_self,abs_zero] at h
    linarith
  obtain ⟨e,he⟩ := exists_sorting_permutation p hp
  have hsep' (i : Fin m) : δ ≤ p (e i.succ)-p (e i.castSucc) := by
    have hne : e i.succ≠e i.castSucc := by
      intro hh
      have hv := congrArg Fin.val (e.injective hh)
      simp only [Fin.val_succ,Fin.val_castSucc] at hv
      omega
    have h := hsep (e i.succ) (e i.castSucc) hne
    change δ ≤ |p (e i.succ)-p (e i.castSucc)| at h
    rw [abs_of_nonneg (sub_nonneg.mpr (he.monotone (Fin.castSucc_le_succ i)))] at h
    exact h
  obtain ⟨w,hw,hglobal,henergy⟩ := exists_ordered_paper_memorizer (k:=k) hM hMN hδ u hu
    (s ∘ e) (y ∘ e) (fun i => hs (e i)) he.monotone hsep' (fun i => hy (e i)) hwidth
  refine ⟨w,?_,hglobal,henergy⟩
  intro i
  simpa only [Function.comp_apply,e.apply_symm_apply] using hw (e.symm i)

def memorizerWidth (d n : ℕ) (δ : ℝ) : ℕ :=
  ⌈max (4 : ℝ) (max (n : ℝ) (3*(d : ℝ)*(n : ℝ)*(max 2 (interpolationSlope n δ))^2))⌉₊

theorem memorizerWidth_ge (d n : ℕ) (δ : ℝ) : n ≤ memorizerWidth d n δ ∧
    3*(d : ℝ)*(n : ℝ)*(max 2 (interpolationSlope n δ))^2 ≤ memorizerWidth d n δ := by
  have hc := Nat.le_ceil (max (4 : ℝ) (max (n : ℝ)
    (3*(d : ℝ)*(n : ℝ)*(max 2 (interpolationSlope n δ))^2)))
  constructor
  · have hn : (n : ℝ) ≤ memorizerWidth d n δ :=
      (le_max_left _ _).trans ((le_max_right _ _).trans hc)
    exact_mod_cast hn
  · exact (le_max_right _ _).trans ((le_max_right _ _).trans hc)

/-- The manuscript's exact bounded-label memorization lemma. The physical
network has depth L, including its linear readout, at every N>=M. -/
theorem exact_bounded_label_memorization {d n L N : ℕ} (hn : 0 < n) (hL : 3 ≤ L)
    {δ : ℝ} (hδ : 0 < δ) (u : Fin d → ℝ) (hu : ∑ j,u j^2 ≤ 1)
    (s : Fin n → RealInput d) (y : Fin n → ℝ)
    (hs : ∀ i, |∑ j,u j*s i j| ≤ 1)
    (hsep : ∀ i j, i≠j → δ ≤ |(∑ l,u l*s i l)-(∑ l,u l*s j l)|)
    (hy : ∀ i, |y i| ≤ 7/8) (hN : memorizerWidth d n δ ≤ N) :
    ∃ w : Weights d N (L-2), (∀ i,output Real.tanh w (s i)=y i) ∧
      (∀ x : RealInput d, |output Real.tanh w x| ≤ 1) ∧
      weightedSquaredNorm w ≤ energyBudget L (4*(memorizerWidth d n δ : ℝ)*(n : ℝ)) := by
  obtain ⟨k,hk⟩ : ∃ k : ℕ,L=k+3 := ⟨L-3,by omega⟩
  subst L
  have hM := memorizerWidth_ge d n δ
  rw [show k+3-2=k+1 by omega]
  exact exists_paper_memorizer (k:=k) hn hM.1 hN hδ u hu s y hs hsep hy hM.2

end NeuralGeneralization.BatchTwoContinuousDepthPaper
