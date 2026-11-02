import NeuralGeneralization.BatchTwoOnlineBiasedRace
import Mathlib.Order.Fin.Basic

/-! The biased-IID adverse first-appearance order with the paper's exact
failure budget (m-1)ρ. All probabilities are under an infinite IID law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnline.BiasedIID
variable {X : Type*} [MeasurableSpace X] [MeasurableSingletonClass X]

theorem self_race_eq_hit (x : X) : winsBefore x x = {s | ∃ n,s n = x} := by
  classical
  ext s
  constructor
  · intro hs
    obtain ⟨n,hn⟩ := Set.mem_iUnion.mp hs
    exact ⟨n,hn.1⟩
  · intro hs
    refine Set.mem_iUnion.mpr ⟨Nat.find hs, Nat.find_spec hs,?_⟩
    intro k hk
    exact ⟨Nat.find_min hs hk,Nat.find_min hs hk⟩

theorem ae_hits (μ : Measure X) [IsProbabilityMeasure μ] (x : X) (hx : μ {x} ≠ 0) :
    ∀ᵐ s ∂Measure.infinitePi (fun _ : ℕ => μ), ∃ n,s n=x := by
  have hh : (Measure.infinitePi (fun _ : ℕ => μ)) (winsBefore x x) = 1 := by
    rw [winsBefore, measure_iUnion (raceAt_disjoint x x) (measurableSet_raceAt x x)]
    simp_rw [raceAt_probability μ x x]
    rw [ENNReal.tsum_mul_left, ENNReal.tsum_geometric]
    rw [show ({x,x} : Set X) = {x} by ext z; simp]
    have hc : μ {x}ᶜ = 1-μ {x} := by
      rw [measure_compl (measurableSet_singleton _) (measure_ne_top _ _), measure_univ]
    rw [hc, ENNReal.sub_sub_cancel (by simp) (show μ {x} ≤ 1 by
      simpa only [measure_univ] using measure_mono (μ := μ) (Set.subset_univ {x}))]
    exact ENNReal.mul_inv_cancel hx (measure_ne_top _ _)
  change ∀ᵐ s ∂Measure.infinitePi (fun _ : ℕ => μ),s ∈ {s | ∃ n,s n=x}
  rw [← self_race_eq_hit x]
  rw [ae_iff]
  change (Measure.infinitePi (fun _ : ℕ => μ)) (winsBefore x x)ᶜ = 0
  rw [measure_compl (measurableSet_winsBefore x x) (measure_ne_top _ _), measure_univ, hh, tsub_self]

/-- Absence of adjacent inversions forces the entire first-appearance
permutation, once all finitely many inputs appear. -/
theorem ordered_first_hits {m : ℕ} (s : ℕ → Fin (m+1))
    (hhit : ∀ x,∃ n,s n=x)
    (horder : ∀ i : Fin m,s ∉ winsBefore i.castSucc i.succ) :
    ∃ t : Fin (m+1) → ℕ, StrictMono t ∧
      ∀ x,s (t x)=x ∧ ∀ k < t x,s k≠x := by
  classical
  let t : Fin (m+1) → ℕ := fun x => Nat.find (hhit x)
  have ht (x : Fin (m+1)) : s (t x)=x ∧ ∀ k < t x,s k≠x :=
    ⟨Nat.find_spec (hhit x),fun k hk => Nat.find_min (hhit x) hk⟩
  refine ⟨t,Fin.strictMono_iff_lt_succ.mpr ?_,ht⟩
  intro i
  by_contra hn
  have hne : t i.castSucc ≠ t i.succ := by
    intro he
    have he' : i.castSucc=i.succ := (ht _).1.symm.trans ((congrArg s he).trans (ht _).1)
    have hv := congrArg Fin.val he'
    simp at hv
  have hlt : t i.succ < t i.castSucc := by omega
  apply horder i
  refine Set.mem_iUnion.mpr ⟨t i.succ,(ht _).1,?_⟩
  intro k hk
  exact ⟨(ht _).2 k (hk.trans hlt),(ht _).2 k hk⟩

/-- m+1 points, so the displayed mρ is exactly (support size-1)ρ.
The distribution may have arbitrarily separated probability scales. -/
theorem biased_iid_first_appearance {m : ℕ} (μ : Measure (Fin (m+1)))
    [IsProbabilityMeasure μ] {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hpos : ∀ x,0 < μ.real {x})
    (hratio : ∀ i : Fin m,μ.real {i.succ}=ρ*μ.real {i.castSucc}) :
    ∃ E : Set (ℕ → Fin (m+1)), MeasurableSet E ∧
      1-(m:ℝ)*ρ ≤ (Measure.infinitePi (fun _ : ℕ => μ)).real E ∧
      ∀ s ∈ E,∃ t : Fin (m+1) → ℕ, StrictMono t ∧
        ∀ x,s (t x)=x ∧ ∀ k < t x,s k≠x := by
  classical
  let P := Measure.infinitePi (fun _ : ℕ => μ)
  let bad : Set (ℕ → Fin (m+1)) := ⋃ i : Fin m,winsBefore i.castSucc i.succ
  let cover : Set (ℕ → Fin (m+1)) := {s | ∀ x,∃ n,s n=x}
  have hbad : MeasurableSet bad := MeasurableSet.iUnion fun i => measurableSet_winsBefore _ _
  have hcover : MeasurableSet cover := by
    simp only [cover, Set.setOf_forall, Set.setOf_exists]
    exact MeasurableSet.iInter fun x => MeasurableSet.iUnion fun n =>
      (measurableSet_singleton x).preimage (measurable_pi_apply n)
  have hcov : ∀ᵐ s ∂P,s ∈ cover := by
    change ∀ᵐ s ∂P,∀ x,∃ n,s n=x
    rw [ae_all_iff]
    intro x
    exact ae_hits μ x (by intro hz; have hh := hpos x; simp [Measure.real,hz] at hh)
  have hprob : P.real bad ≤ (m:ℝ)*ρ := by
    apply (measureReal_iUnion_fintype_le _).trans
    calc
      (∑ i : Fin m,P.real (winsBefore i.castSucc i.succ)) = ∑ _i : Fin m,ρ/(1+ρ) := by
        apply Finset.sum_congr rfl
        intro i _
        exact geometric_race_probability μ _ _ (by intro he; have := congrArg Fin.val he; simp at this)
          hρ (hpos _) (hratio i)
      _ ≤ ∑ _i : Fin m,ρ := Finset.sum_le_sum fun _ _ => by
        apply (div_le_iff₀ (show 0 < 1+ρ by positivity)).mpr
        nlinarith [sq_nonneg ρ]
      _ = _ := by simp
  refine ⟨cover ∩ badᶜ,hcover.inter hbad.compl,?_,?_⟩
  · have he : (fun s => s ∈ cover ∩ badᶜ) =ᵐ[P] (fun s => s ∈ badᶜ) :=
      hcov.mono (fun s hs => by simp only [Set.mem_inter_iff, hs, true_and])
    change 1-(m:ℝ)*ρ ≤ P.real (cover ∩ badᶜ)
    have heR : P.real (cover ∩ badᶜ) = P.real badᶜ := measureReal_congr he
    rw [heR, measureReal_compl hbad, probReal_univ]
    linarith
  · intro s hs
    apply ordered_first_hits s hs.1
    intro i hi
    exact hs.2 (Set.mem_iUnion.mpr ⟨i,hi⟩)

end NeuralGeneralization.BatchTwoOnline.BiasedIID
