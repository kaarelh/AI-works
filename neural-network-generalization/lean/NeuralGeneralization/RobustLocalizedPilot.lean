import NeuralGeneralization.RobustLocalizedPolynomial

/-! Averaging over an independent pilot-selected exception family. A finite
pilot alphabet can encode all possible families on the finite Boolean cube. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel RobustConfidence

lemma finite_pilot_event {I Y : Type*} [Fintype I] [MeasurableSpace I]
    [MeasurableSingletonClass I] [MeasurableSpace Y]
    (P : Measure I) [IsProbabilityMeasure P] (μ : Measure Y) [IsProbabilityMeasure μ]
    (E : I → Set Y) (hE : ∀ i,MeasurableSet (E i)) {δ : ℝ}
    (hprob : ∀ i,1-δ ≤ μ.real (E i)) :
    MeasurableSet {p : I × Y | p.2 ∈ E p.1} ∧
      1-δ ≤ (P.prod μ).real {p : I × Y | p.2 ∈ E p.1} := by
  classical
  have hid : {p : I × Y | p.2 ∈ E p.1} = ⋃ i,({i} : Set I) ×ˢ E i := by
    ext p
    simp
  have hm : ∀ i,MeasurableSet (({i}:Set I) ×ˢ E i) := fun i => (measurableSet_singleton i).prod (hE i)
  have hd : Pairwise (fun i j => Disjoint (({i}:Set I) ×ˢ E i) (({j}:Set I) ×ˢ E j)) := by
    intro i j hij
    apply Set.disjoint_left.mpr
    intro p hi hj
    exact hij (hi.1.symm.trans hj.1)
  rw [hid]
  refine ⟨MeasurableSet.iUnion hm,?_⟩
  rw [measureReal_iUnion_fintype hd hm]
  simp_rw [measureReal_prod_prod]
  have hsum : (∑ i,P.real {i}) = 1 := by
    simpa using (sum_measureReal_singleton (μ := P) (Finset.univ : Finset I))
  calc
    _ = (∑ i,P.real {i})*(1-δ) := by rw [hsum,one_mul]
    _ = ∑ i,P.real {i}*(1-δ) := by rw [Finset.sum_mul]
    _ ≤ _ := Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hprob i) measureReal_nonneg)

/-- The family is selected from an independent finite-valued pilot, before
validation and labels. No union bound over the possible pilot outputs is paid. -/
theorem localized_independent_pilot {I : Type*} [Fintype I] [MeasurableSpace I]
    [MeasurableSingletonClass I] {d C r M : ℕ}
    (P : Measure I) [IsProbabilityMeasure P]
    (hd : 0 < d) (T : LayeredBooleanCircuit d C r)
    (B : I → Fin M → Set (Cube d)) (j0 : I → Fin M) (hzero : ∀ i,B i (j0 i) = ∅)
    {c ρ ε δ : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ)
    (hε : 0 < ε) (hε1 : ε < 1) (hδ : 0 < δ) (hδ1 : δ < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D] (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hvalidation : 2*(Real.log (M:ℝ)+Real.log (4/δ)) ≤ (m:ℝ)*(ε/12)^2)
    (hlabeled : 2*(Real.log (M:ℝ)+
      (RobustConditioned.resources d r (componentCost d C r M c ε) c ε).entropyBudget+
      Real.log (4/δ)) ≤ (n:ℝ)*(ε/12)^2) :
    ∃ E : Set (I × ((Fin m → Cube d) × (Fin n → Cube d))),MeasurableSet E ∧
      1-δ ≤ (P.prod ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D)))).real E ∧
      ∀ p ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        gibbsMarginRisk D (posterior (N := N) (r := r) (B p.1) c ρ σ T.computes p.2.1 p.2.2)
          (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  choose E hE hprob hrisk using fun i => localized_union_learning hd T (B i) (j0 i) (hzero i)
    hc hρ hε hε1 hδ hδ1 D m n hm hn hvalidation hlabeled
  have hh := finite_pilot_event P
    ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))) E hE hprob
  exact ⟨{p | p.2 ∈ E p.1},hh.1,hh.2,fun p hp => hrisk p.1 p.2 hp⟩

end NeuralGeneralization.RobustLocalized
