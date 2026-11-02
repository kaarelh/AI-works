import NeuralGeneralization.BatchTwoOnlineNonuniformMain
import Mathlib.Analysis.SpecificLimits.Basic

/-! Exact first-arrival races under the actual infinite IID product law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoOnline.BiasedIID
variable {X : Type*} [MeasurableSpace X] [MeasurableSingletonClass X]

/-- At time n, y is the first of the two distinct points x,y to appear. -/
def raceAt (x y : X) (n : ℕ) : Set (ℕ → X) :=
  {s | s n = y ∧ ∀ k < n,s k ≠ x ∧ s k ≠ y}

def winsBefore (x y : X) : Set (ℕ → X) := ⋃ n,raceAt x y n

theorem measurableSet_raceAt (x y : X) (n : ℕ) : MeasurableSet (raceAt x y n) := by
  have he (k : ℕ) (z : X) : MeasurableSet {s : ℕ → X | s k = z} :=
    (measurableSet_singleton z).preimage (measurable_pi_apply k)
  have hn (k : ℕ) (z : X) : MeasurableSet {s : ℕ → X | s k ≠ z} := (he k z).compl
  simpa only [raceAt, Set.setOf_forall, Set.setOf_and] using
    (he n y).inter (MeasurableSet.iInter fun k : ℕ =>
      MeasurableSet.iInter fun _ : k < n => (hn k x).inter (hn k y))

theorem measurableSet_winsBefore (x y : X) : MeasurableSet (winsBefore x y) :=
  MeasurableSet.iUnion (measurableSet_raceAt x y)

theorem raceAt_disjoint (x y : X) : Pairwise (fun n m => Disjoint (raceAt x y n) (raceAt x y m)) := by
  intro n m hne
  apply Set.disjoint_left.mpr
  intro s hn hm
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact (hm.2 n hlt).2 hn.1
  · exact (hn.2 m hgt).2 hm.1

theorem raceAt_probability (μ : Measure X) [IsProbabilityMeasure μ]
    (x y : X) (n : ℕ) :
    (Measure.infinitePi (fun _ : ℕ => μ)) (raceAt x y n) = μ {y}*(μ {x,y}ᶜ)^n := by
  classical
  have he : raceAt x y n = Set.pi (Finset.range (n+1))
      (fun k : ℕ => if k=n then {y} else {x,y}ᶜ) := by
    ext s
    simp only [raceAt, Set.mem_setOf_eq, Set.mem_pi, Finset.mem_coe, Finset.mem_range]
    constructor
    · rintro ⟨hn,hpre⟩ k hk
      by_cases he : k=n
      · simpa only [he, if_true, Set.mem_singleton_iff] using hn
      · simpa [he] using hpre k (by omega)
    · intro h
      refine ⟨by simpa using h n (by omega),?_⟩
      intro k hk
      simpa [show k ≠ n by omega] using h k (by omega)
  rw [he, Measure.infinitePi_pi]
  · rw [Finset.prod_range_succ]
    have he' : (∏ k∈Finset.range n,μ (if k=n then {y} else {x,y}ᶜ)) = (μ {x,y}ᶜ)^n := by
      calc
        _ = ∏ _k∈Finset.range n,μ {x,y}ᶜ := by
          apply Finset.prod_congr rfl
          intro k hk
          rw [if_neg (by have := Finset.mem_range.mp hk; omega)]
        _ = _ := by simp
    rw [he']
    simp [mul_comm]
  · intro k _
    split_ifs <;> measurability

/-- Exact race probability p_y/(p_x+p_y), without a finite-horizon
approximation or a uniform-query assumption. -/
theorem winsBefore_probability (μ : Measure X) [IsProbabilityMeasure μ]
    (x y : X) (hxy : x ≠ y) :
    (Measure.infinitePi (fun _ : ℕ => μ)) (winsBefore x y) =
      μ {y}/(μ {x}+μ {y}) := by
  rw [winsBefore, measure_iUnion (raceAt_disjoint x y) (measurableSet_raceAt x y)]
  simp_rw [raceAt_probability μ x y]
  rw [ENNReal.tsum_mul_left, ENNReal.tsum_geometric]
  have he : μ {x,y} = μ {x}+μ {y} := by
    rw [show ({x,y} : Set X) = {x} ∪ {y} from rfl,
      measure_union (Set.disjoint_singleton.mpr hxy) (measurableSet_singleton _)]
  have hc : μ {x,y}ᶜ = 1-μ {x,y} := by
    rw [measure_compl (by measurability) (measure_ne_top _ _), measure_univ]
  rw [hc, ENNReal.sub_sub_cancel (by simp) (show μ {x,y} ≤ 1 by simpa only [measure_univ] using measure_mono (μ := μ) (Set.subset_univ {x,y})), he, div_eq_mul_inv]

/-- Adjacent geometric weights yield the paper's exact ρ/(1+ρ). -/
theorem geometric_race_probability (μ : Measure X) [IsProbabilityMeasure μ]
    (x y : X) (hxy : x ≠ y) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hx : 0 < μ.real {x}) (hratio : μ.real {y} = ρ*μ.real {x}) :
    (Measure.infinitePi (fun _ : ℕ => μ)).real (winsBefore x y) = ρ/(1+ρ) := by
  unfold Measure.real
  rw [winsBefore_probability μ x y hxy, ENNReal.toReal_div,
    ENNReal.toReal_add (measure_ne_top _ _) (measure_ne_top _ _)]
  change μ.real {y}/(μ.real {x}+μ.real {y}) = _
  rw [hratio]
  have hh : 1+ρ ≠ 0 := by positivity
  field_simp
  <;> ring

end NeuralGeneralization.BatchTwoOnline.BiasedIID
