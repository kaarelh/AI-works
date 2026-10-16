import NeuralGeneralization.NetworkSubcriticalWalshRate
import NeuralGeneralization.WeightedMarginMinimizers

/-! Closed global-margin field minimizers and their exact relation to the
finite full-sign function energies of the actual subcritical posterior. -/
noncomputable section
open Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.WalshMarginMinimizers
open ConcreteModel GaussianMarginGeometry GaussianMarginLaw WeightedMarginMinimizers
open NetworkSubcriticalWalshRate

def closedWalshMarginSet (d : ℕ) (a : ℝ) (f : BooleanFunction d) : Set (Finset (Fin d) → ℝ) :=
  {c | ∀ x, a ≤ labelReal (f x) * walshExpansion c x}

theorem closedLinearMargin_walsh_eq (d : ℕ) (a : ℝ) (f : BooleanFunction d) :
    closedLinearMargin (signedCoefficients walshCharacter (fun x => labelReal (f x))) a =
      closedWalshMarginSet d a f := by
  ext c
  apply forall_congr'
  intro x
  have he : (∑ i, signedCoefficients walshCharacter (fun x => labelReal (f x)) x i * c i) =
      labelReal (f x) * walshExpansion c x := by
    simp only [signedCoefficients, walshExpansion, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  exact he ▸ Iff.rfl

theorem walshMarginSet_nonempty (d : ℕ) (a : ℝ) (f : BooleanFunction d) :
    (walshMarginSet d a f).Nonempty := by
  refine ⟨walshCoefficients (fun x => labelReal (f x) * (a + 1)), fun x => ?_⟩
  rw [walshExpansion_coefficients]
  cases hf : f x <;> simp [labelReal]

theorem closedWalshMarginSet_nonempty (d : ℕ) (a : ℝ) (f : BooleanFunction d) :
    (closedWalshMarginSet d a f).Nonempty := by
  obtain ⟨c, hc⟩ := walshMarginSet_nonempty d a f
  exact ⟨c, fun x => (hc x).le⟩

/-- Every full-sign function's rate is attained as the half energy of a
closed full-cube margin field. -/
theorem exists_walsh_margin_minimizer (d r : ℕ) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) :
    ∃ c ∈ closedWalshMarginSet d a f,
      featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) c = 2 * walshMarginEnergy d r a f ∧
      ∀ z ∈ closedWalshMarginSet d a f,
        featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) c ≤
          featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) z := by
  let w := walshCoefficients (arcsineProfile d (r + 1))
  let P := signedCoefficients walshCharacter (fun x => labelReal (f x))
  have hne : (closedLinearMargin P a).Nonempty := by
    rw [closedLinearMargin_walsh_eq]
    exact closedWalshMarginSet_nonempty d a f
  obtain ⟨c, hc, hmin⟩ := exists_closed_margin_minimizer w (iterated_arcsine_coefficient_pos d r) P a hne
  have he := strict_inf_eq_minimum w (iterated_arcsine_coefficient_pos d r) P ha hc hmin
  rw [linearMargin_walsh_eq] at he
  rw [closedLinearMargin_walsh_eq] at hc hmin
  refine ⟨c, hc, ?_, hmin⟩
  change featureEnergy w c = 2 * (sInf (featureEnergy w '' walshMarginSet d a f) / 2)
  rw [he]
  ring

theorem closed_walsh_energy_lower (d r : ℕ) {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) {c : Finset (Fin d) → ℝ} (hc : c ∈ closedWalshMarginSet d a f) :
    2 * walshMarginEnergy d r a f ≤
      featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) c := by
  obtain ⟨z, _, he, hmin⟩ := exists_walsh_margin_minimizer d r ha f
  rw [← he]
  exact hmin c hc

/-- The exact feasible set in the paper: absolute margin on every cube input,
and the specified signed margins on training inputs. -/
def globalTrainingMarginSet {d n : ℕ} (a : ℝ) (f : BooleanFunction d)
    (sample : Fin n → Cube d) : Set (Finset (Fin d) → ℝ) :=
  {c | (∀ x, a ≤ |walshExpansion c x|) ∧
    ∀ i, a ≤ labelReal (f (sample i)) * walshExpansion c (sample i)}

/-- The global training event is exactly the union of the retained closed
full-sign orthants, including all unobserved inputs. -/
theorem globalTrainingMarginSet_iff {d n : ℕ} {a : ℝ} (ha : 0 < a)
    (f : BooleanFunction d) (sample : Fin n → Cube d) (c : Finset (Fin d) → ℝ) :
    c ∈ globalTrainingMarginSet a f sample ↔
      ∃ g : BooleanFunction d, consistent f sample g ∧ c ∈ closedWalshMarginSet d a g := by
  constructor
  · rintro ⟨hglobal, htrain⟩
    let g : BooleanFunction d := fun x => decide (0 ≤ walshExpansion c x)
    have hg : c ∈ closedWalshMarginSet d a g := by
      intro x
      by_cases hx : 0 ≤ walshExpansion c x
      · simpa only [g, hx, decide_true, labelReal_true, one_mul, abs_of_nonneg hx] using hglobal x
      · have hx' : walshExpansion c x < 0 := lt_of_not_ge hx
        simpa only [g, hx, decide_false, labelReal_false, neg_one_mul, abs_of_neg hx'] using hglobal x
    refine ⟨g, ?_, hg⟩
    intro i
    have hi := htrain i
    cases hf : f (sample i)
    · have hz : ¬ 0 ≤ walshExpansion c (sample i) := by
        simp only [hf, labelReal_false, neg_one_mul] at hi
        linarith
      simp only [g, hz, decide_false]
    · have hz : 0 ≤ walshExpansion c (sample i) := by
        simp only [hf, labelReal_true, one_mul] at hi
        linarith
      simp only [g, hz, decide_true]
  · rintro ⟨g, hkeep, hg⟩
    constructor
    · intro x
      calc
        a ≤ labelReal (g x) * walshExpansion c x := hg x
        _ ≤ |labelReal (g x) * walshExpansion c x| := le_abs_self _
        _ = |walshExpansion c x| := by rw [abs_mul, abs_labelReal, one_mul]
    · intro i
      simpa only [hkeep i] using hg (sample i)

/-- Any minimizing compatible function rate lifts to a genuine minimum-
energy field for the exact global-margin-plus-training feasible set. -/
theorem exists_global_minimizer_of_function_minimizer {d n : ℕ} (r : ℕ)
    {a : ℝ} (ha : 0 < a) (f target : BooleanFunction d) (sample : Fin n → Cube d)
    (ht : consistent f sample target)
    (hmin : ∀ g, consistent f sample g → walshMarginEnergy d r a target ≤ walshMarginEnergy d r a g) :
    ∃ c ∈ closedWalshMarginSet d a target,
      c ∈ globalTrainingMarginSet a f sample ∧
      featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) c = 2 * walshMarginEnergy d r a target ∧
      ∀ z ∈ globalTrainingMarginSet a f sample,
        featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) c ≤
          featureEnergy (walshCoefficients (arcsineProfile d (r + 1))) z := by
  obtain ⟨c, hc, he, _⟩ := exists_walsh_margin_minimizer d r ha target
  refine ⟨c, hc, (globalTrainingMarginSet_iff ha f sample c).mpr ⟨target, ht, hc⟩, he, ?_⟩
  intro z hz
  obtain ⟨g, hg, hzg⟩ := (globalTrainingMarginSet_iff ha f sample z).mp hz
  rw [he]
  exact (mul_le_mul_of_nonneg_left (hmin g hg) (by norm_num : (0 : ℝ) ≤ 2)).trans
    (closed_walsh_energy_lower d r ha g hzg)

end NeuralGeneralization.WalshMarginMinimizers
