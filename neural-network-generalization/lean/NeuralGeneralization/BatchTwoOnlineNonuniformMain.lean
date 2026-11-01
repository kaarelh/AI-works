import NeuralGeneralization.BatchTwoOnlineNonuniformBudget
import NeuralGeneralization.BatchTwoOnlineIIDMeasure

/-! The nonuniform extension for the actual infinite IID query law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Classical MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnline
variable {X H : Type*} [Fintype X] [Nonempty X] [Fintype H] [DecidableEq H]

def finiteRoundRisk (w : H→ℝ) (good : H→X→Prop) {n : ℕ} (s : Fin (n+1)→X) : ℝ := by
  classical
  exact ∑ g,if good g (s (Fin.last n)) then 0 else
    posterior w (fun g => ∀ i : Fin n,good g (s i.castSucc)) g

theorem onlineError_eq_finiteRound (w : H→ℝ) (good : H→X→Prop) (s : ℕ→X) (n : ℕ) :
    onlineError w good s n=finiteRoundRisk w good (sequencePrefix (n+1) s) := by
  classical
  have hk : history good s n=(fun g => ∀ i : Fin n,good g (s i.val)) := by
    funext g
    apply propext
    exact ⟨fun h i => h i.val i.isLt,fun h i hi => h ⟨i,hi⟩⟩
  simp only [onlineError,finiteRoundRisk,sequencePrefix,Fin.val_last,Fin.coe_castSucc,onlinePosterior,hk]

theorem finiteRoundRisk_expected (D : X→ℝ) (w : H→ℝ) (good : H→X→Prop) (n : ℕ) :
    (∑ s : Fin (n+1)→X,iidWeight D (n+1) s*finiteRoundRisk w good s)=iidExpectedRisk D w good n := by
  classical
  let e := Fin.snocEquiv (fun _ : Fin (n+1) => X)
  rw [← e.sum_comp]
  change (∑ z : X × (Fin n→X),iidWeight D (n+1) (Fin.snoc z.2 z.1)*
    finiteRoundRisk w good (Fin.snoc z.2 z.1))=_
  have hw (s : Fin n→X) (x : X) : iidWeight D (n+1) (Fin.snoc s x)=iidWeight D n s*D x := by
    classical
    simp [iidWeight,Fin.prod_univ_castSucc]
  have hr (s : Fin n→X) (x : X) : finiteRoundRisk w good (Fin.snoc s x)=
      ∑ g,if good g x then 0 else posterior w (fun g => allObservations (good g) n s) g := by
    classical
    simp only [finiteRoundRisk,Fin.snoc_last,Fin.snoc_castSucc,allObservations]
    apply Finset.sum_congr rfl
    intro g _
    split_ifs
    · rfl
    · congr 1
  simp only [Fintype.sum_prod_type,hw,hr]
  rw [Finset.sum_comm]
  unfold iidExpectedRisk
  apply Finset.sum_congr rfl
  intro s _
  simp_rw [mul_assoc,← Finset.mul_sum]
  congr 1
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro g _
  unfold eventError
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  split_ifs <;> ring

variable [MeasurableSpace X] [MeasurableSingletonClass X]

def nonuniformIIDLaw (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1) : Measure (ℕ→X) :=
  Measure.infinitePi (fun _ => finiteWeightLaw D hD hDs)

theorem nonuniformIID_prefix_lintegral (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    (n : ℕ) (F : (Fin n→X)→ℝ) (hF : ∀ s,0≤F s) :
    (∫⁻ s,ENNReal.ofReal (F (sequencePrefix n s)) ∂nonuniformIIDLaw D hD hDs)=
      ENNReal.ofReal (∑ s,iidWeight D n s*F s) := by
  classical
  have he := lintegral_map (μ:=nonuniformIIDLaw D hD hDs)
    (f:=fun s : Fin n→X => ENNReal.ofReal (F s))
    (measurable_of_finite _) (measurable_sequencePrefix n)
  have hp := infinitePi_map_sequencePrefix (fun _ => finiteWeightLaw D hD hDs) n
  change (nonuniformIIDLaw D hD hDs).map (sequencePrefix n)=_ at hp
  rw [hp] at he
  apply he.symm.trans
  convert productWeightLaw_lintegral (fun _ : Fin n => D) (fun _ => hD) (fun _ => hDs) F hF using 1 <;> congr 3
  exact Subsingleton.elim _ _

theorem nonuniformIID_round_expectation
    (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target) (n : ℕ) :
    (∫⁻ s,ENNReal.ofReal (onlineError w good s n) ∂nonuniformIIDLaw D hD hDs)=
      ENNReal.ofReal (iidExpectedRisk D w good n) := by
  classical
  simp_rw [onlineError_eq_finiteRound]
  rw [nonuniformIID_prefix_lintegral D hD hDs (n+1) (finiteRoundRisk w good) (fun s => by
    apply Finset.sum_nonneg
    intro g _
    split_ifs
    · exact le_refl _
    · exact posterior_nonneg w (fun g => ∀ i : Fin n,good g (s i.castSucc)) hw target (fun i => ht (s i.castSucc)) hwt g)]
  rw [finiteRoundRisk_expected]

/-- The exact displayed nonuniform expectation bound, for the entire
infinite sequence of Bayesian prediction errors and the actual IID law.
No finite stopping time or uniform-query assumption is used. -/
theorem nonuniform_iid_expected_total
    (D : X→ℝ) (hD : ∀ x,0≤D x) (hDs : ∑ x,D x=1)
    {p : ℝ} (hp : 0<p) (hmin : ∀ x,p≤D x)
    (w : H→ℝ) (hw : ∀ g,0≤w g) (good : H→X→Prop)
    (target : H) (ht : ∀ x,good target x) (hwt : 0<w target)
    (A : Finset H) (h β : ℝ) (hh : 0≤h)
    (hcard : (A.card:ℝ)≤Real.exp h)
    (htail : (∑ g∈Finset.univ \ A,w g)/w target≤β) :
    (∫⁻ s,totalError w good s ∂nonuniformIIDLaw D hD hDs)≤
      ENNReal.ofReal (3+(h+1)*(1+Real.log (nonuniformCutoff p))+(Fintype.card X:ℝ)*β) := by
  classical
  have hmeas (n : ℕ) : Measurable (fun s : ℕ→X => onlineError w good s n) := by
    classical
    simp_rw [onlineError_eq_finiteRound]
    exact (measurable_of_finite (finiteRoundRisk w good (n:=n))).comp (measurable_sequencePrefix (n+1))
  unfold totalError
  rw [lintegral_tsum (fun n => (hmeas n).ennreal_ofReal.aemeasurable)]
  simp_rw [nonuniformIID_round_expectation D hD hDs w hw good target ht hwt]
  rw [ENNReal.tsum_eq_iSup_nat]
  apply iSup_le
  intro M
  rw [← ENNReal.ofReal_sum_of_nonneg (fun n _ => iidExpectedRisk_nonneg D hD w hw good target ht hwt n)]
  exact ENNReal.ofReal_le_ofReal
    (nonuniform_expected_partial_sum D hD hDs hp hmin w hw good target ht hwt A h β hh hcard htail M)

#print axioms nonuniform_iid_expected_total
end NeuralGeneralization.BatchTwoOnline
