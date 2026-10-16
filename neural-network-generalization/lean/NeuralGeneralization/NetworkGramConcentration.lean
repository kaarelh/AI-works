import NeuralGeneralization.NetworkGramBasics
import NeuralGeneralization.ProductEventBound

/-!
# Exponential freezing of the actual subcritical neural Gram matrix

Every hidden layer is treated under the original independent Gaussian
parameter prior. The exponential estimate is uniform in width after a finite
threshold and holds for every real gamma below one.
-/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.NetworkGramConcentration
open ConcreteModel TowerNetwork NetworkLayerSplit NetworkGramBasics NetworkMomentUpdate

/-- Simultaneous deviation of the full empirical covariance matrix. -/
def gramBad {d N r : ℕ} (K : Cube d → Cube d → ℝ) (ε : ℝ) : Set (Weights d N r) :=
  {w | ∃ x y, ε ≤ |finalCovariance Real.tanh w x y - K x y|}

theorem measurableSet_gramBad {d N r : ℕ} (K : Cube d → Cube d → ℝ) (ε : ℝ) :
    MeasurableSet (gramBad (N := N) (r := r) K ε) := by
  have he : gramBad (N := N) (r := r) K ε =
      ⋃ x, ⋃ y, {w | ε ≤ |finalCovariance Real.tanh w x y - K x y|} := by
    ext w
    simp only [gramBad, Set.mem_setOf_eq, Set.mem_iUnion]
  rw [he]
  apply MeasurableSet.iUnion
  intro x
  apply MeasurableSet.iUnion
  intro y
  exact measurableSet_le measurable_const
    (((continuous_finalCovariance tanh_lipschitzWith.continuous x y).sub continuous_const).abs.measurable)

theorem not_mem_gramBad {d N r : ℕ} (K : Cube d → Cube d → ℝ) (ε : ℝ)
    (w : Weights d N r) : w ∉ gramBad K ε ↔
      ∀ x y, |finalCovariance Real.tanh w x y - K x y| < ε := by
  simp only [gramBad, Set.mem_setOf_eq, not_exists, not_le]

/-- Initial-layer sampling noise under the actual complete network prior. -/
theorem first_layer_centered_tail (d N : ℕ) (hN : 0 < N) (γ ε : ℝ) (hε : 0 ≤ ε) :
    (powerPrior d N 0 γ).real
      (gramBad (fun x y => LayerGramConcentration.covariance Real.tanh
        (fun j (x : Cube d) => inputVector x j)
        (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y) ε) ≤
      2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * ε ^ 2 / 2) := by
  let v := ((N : ℝ) ^ (1 - γ) / d).toNNReal
  let H := fun j (x : Cube d) => inputVector x j
  let B : Set (Fin N × Fin (d + 1) → ℝ) := {a | ∃ x y,
    ε ≤ |LayerGramConcentration.empiricalGram N Real.tanh H a x y -
      LayerGramConcentration.covariance Real.tanh H v x y|}
  have hB : MeasurableSet B := by
    unfold B
    simp only [Set.setOf_exists]
    apply MeasurableSet.iUnion
    intro x
    apply MeasurableSet.iUnion
    intro y
    apply measurableSet_le measurable_const
    apply Measurable.abs
    apply Measurable.sub _ measurable_const
    unfold LayerGramConcentration.empiricalGram LayerGramConcentration.rowFeature
    have hφ : Measurable Real.tanh := tanh_lipschitzWith.continuous.measurable
    fun_prop
  have he : (fun w : Weights d N 0 => fun ij : Fin N × Fin (d + 1) => w (.inl ij)) ⁻¹' B =
      gramBad (fun x y => LayerGramConcentration.covariance Real.tanh H v x y) ε := by
    ext w
    simp only [Set.mem_preimage, B, Set.mem_setOf_eq, gramBad, finalCovariance,
      finalHidden, List.finRange_zero, List.foldl_nil, firstHidden,
      LayerGramConcentration.empiricalGram, LayerGramConcentration.rowFeature, H]
  have hm := (measurePreserving_inputMatrix d N 0 γ).measure_preimage hB.nullMeasurableSet
  rw [he] at hm
  rw [Measure.real, hm]
  exact LayerGramConcentration.gaussian_layer_all_entries_tail N hN
    tanh_lipschitzWith.continuous tanh_admissible.1 H v ε hε

/-- The first actual hidden layer freezes exponentially around its limiting
arcsine covariance. -/
theorem first_layer_freezing {d : ℕ} (hd : 0 < d) {γ : ℝ} (hγ : γ < 1)
    {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ N : ℕ in atTop,
      (powerPrior d N 0 γ).real (gramBad (arcsineCovariance d 1) ε) ≤
      2 * (Fintype.card (Cube d) : ℝ) ^ 2 *
        Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2) := by
  have hnear : ∀ᶠ N : ℕ in atTop, ∀ x y : Cube d,
      |LayerGramConcentration.covariance Real.tanh
        (fun j (x : Cube d) => inputVector x j)
        (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y - arcsineCovariance d 1 x y| < ε / 2 := by
    apply eventually_all.mpr
    intro x
    apply eventually_all.mpr
    intro y
    have hz := ((first_covariance_tendsto hd hγ x y).sub_const (arcsineCovariance d 1 x y)).abs
    simp only [sub_self, abs_zero] at hz
    exact hz.eventually (Iio_mem_nhds (by linarith : 0 < ε / 2))
  filter_upwards [hnear, eventually_gt_atTop (0 : ℕ)] with N hn hN
  have hsub : gramBad (N := N) (r := 0) (arcsineCovariance d 1) ε ⊆
      gramBad (fun x y => LayerGramConcentration.covariance Real.tanh
        (fun j (x : Cube d) => inputVector x j)
        (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y) (ε / 2) := by
    rintro w ⟨x, y, hxy⟩
    refine ⟨x, y, ?_⟩
    have ht := abs_sub_le (finalCovariance Real.tanh w x y)
      (LayerGramConcentration.covariance Real.tanh (fun j (x : Cube d) => inputVector x j)
        (((N : ℝ) ^ (1 - γ) / d).toNNReal) x y) (arcsineCovariance d 1 x y)
    have hb := hn x y
    linarith
  exact (measureReal_mono hsub).trans (first_layer_centered_tail d N hN γ (ε / 2) (by linarith))

/-- Exact one-layer propagation of a Gram deviation bound. The preceding
layer may have any law coming from the actual shorter network. -/
theorem next_layer_freezing {d r : ℕ} {γ : ℝ} (hγ : γ < 1)
    (K : Cube d → Cube d → ℝ) (hdiag : ∀ x, K x x = 1)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ᶠ N : ℕ in atTop,
      (powerPrior d N (r + 1) γ).real (gramBad (fun x y => arcsineLink (K x y)) ε) ≤
      (powerPrior d N r γ).real (gramBad K δ) +
        2 * (Fintype.card (Cube d) : ℝ) ^ 2 *
          Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2) := by
  obtain ⟨δ, hδ, T, hT⟩ := uniform_layer_covariance_matrix K hdiag
    (by linarith : 0 < ε / 2)
  refine ⟨δ, hδ, ?_⟩
  filter_upwards [(subcritical_scale_tendsto hγ).eventually (eventually_ge_atTop T),
    eventually_gt_atTop (0 : ℕ)] with N hs hN
  let v : ℝ≥0 := ((N : ℝ) ^ (-γ)).toNNReal
  let A : Set (Weights d N r) := gramBad K δ
  let B : Set (Weights d N (r + 1)) := gramBad (fun x y => arcsineLink (K x y)) ε
  let E := (split d N r).symm ⁻¹' B
  let b := 2 * (Fintype.card (Cube d) : ℝ) ^ 2 * Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2)
  have hA : MeasurableSet A := measurableSet_gramBad K δ
  have hB : MeasurableSet B := measurableSet_gramBad _ ε
  have hE : MeasurableSet E := hB.preimage (split d N r).symm.measurable
  have hsections : ∀ w ∉ A, (matrixPrior N γ).real {a | (w,a) ∈ E} ≤ b := by
    intro w hw
    have hnear := (not_mem_gramBad K δ w).mp hw
    have hscale : T ≤ Real.sqrt ((N : ℝ) * v) := by
      simpa only [v, Real.toNNReal_of_nonneg (Real.rpow_nonneg (Nat.cast_nonneg N) _),
        NNReal.coe_mk] using hs
    have hmean := hT N hN (fun i x => finalHidden Real.tanh w x i) v hscale hnear
    have hsub : {a | (w,a) ∈ E} ⊆ {a | ∃ x y,
        ε / 2 ≤ |LayerGramConcentration.empiricalGram N Real.tanh
          (fun i x => finalHidden Real.tanh w x i) a x y -
          LayerGramConcentration.covariance Real.tanh
            (fun i x => finalHidden Real.tanh w x i) v x y|} := by
      intro a ha
      have hab : appendLayer w (fun i j => a (i,j)) ∈ B := by
        simpa only [E, Set.mem_preimage, Set.mem_setOf_eq, split_symm_apply] using ha
      obtain ⟨x,y,hxy⟩ := hab
      refine ⟨x,y,?_⟩
      rw [finalCovariance_appendLayer] at hxy
      have ht := abs_sub_le
        (LayerGramConcentration.empiricalGram N Real.tanh (fun i x => finalHidden Real.tanh w x i) a x y)
        (LayerGramConcentration.covariance Real.tanh (fun i x => finalHidden Real.tanh w x i) v x y)
        (arcsineLink (K x y))
      have hb := hmean x y
      linarith
    exact (measureReal_mono hsub).trans
      (LayerGramConcentration.gaussian_layer_all_entries_tail N hN
        tanh_lipschitzWith.continuous tanh_admissible.1
        (fun i x => finalHidden Real.tanh w x i) v (ε / 2) (by linarith))
  have hm : ((powerPrior d N r γ).prod (matrixPrior N γ)).real E =
      (powerPrior d N (r + 1) γ).real B :=
    congrArg ENNReal.toReal
      ((MeasurePreserving.symm (split d N r) (measurePreserving_split d N r γ)).measure_preimage
        hB.nullMeasurableSet)
  rw [← hm]
  exact product_event_mass_le (powerPrior d N r γ) (matrixPrior N γ) A hA E hE b
    (by dsimp [b]; positivity) hsections

/-- Exponential freezing of the actual final hidden Gram matrix at every
fixed depth, for the entire real subcritical regime. -/
theorem actual_gram_exponential_freezing {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧ ∃ c : ℝ, 0 < c ∧ ∀ᶠ N : ℕ in atTop,
      (powerPrior d N r γ).real (gramBad (arcsineCovariance d (r + 1)) ε) ≤
        C * Real.exp (-c * N) := by
  induction r generalizing ε with
  | zero =>
    refine ⟨2 * (Fintype.card (Cube d) : ℝ) ^ 2, by positivity,
      (ε / 2) ^ 2 / 2, by positivity, ?_⟩
    filter_upwards [first_layer_freezing hd hγ hε] with N hN
    convert hN using 1
    congr 2
    ring
  | succ r ih =>
    obtain ⟨δ, hδ, hstep⟩ := next_layer_freezing (r := r) hγ
      (arcsineCovariance d (r + 1)) (arcsineCovariance_diag d (r + 1)) hε
    obtain ⟨C, hC, c, hc, hprev⟩ := ih hδ
    let B : ℝ := 2 * (Fintype.card (Cube d) : ℝ) ^ 2
    let q : ℝ := (ε / 2) ^ 2 / 2
    have hB : 0 < B := by dsimp [B]; positivity
    have hq : 0 < q := by dsimp [q]; positivity
    refine ⟨C + B, by positivity, min c q, lt_min hc hq, ?_⟩
    filter_upwards [hstep, hprev] with N hn hp
    have hexp₁ : Real.exp (-c * N) ≤ Real.exp (-min c q * N) := by
      apply Real.exp_le_exp.mpr
      exact mul_le_mul_of_nonneg_right (neg_le_neg (min_le_left c q)) (Nat.cast_nonneg N)
    have hexp₂ : Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2) ≤ Real.exp (-min c q * N) := by
      apply Real.exp_le_exp.mpr
      calc
        _ = -q * N := by dsimp [q]; ring
        _ ≤ _ := mul_le_mul_of_nonneg_right (neg_le_neg (min_le_right c q)) (Nat.cast_nonneg N)
    change (powerPrior d N (r + 1) γ).real
      (gramBad (fun x y => arcsineLink (arcsineCovariance d (r + 1) x y)) ε) ≤ _
    calc
      _ ≤ (powerPrior d N r γ).real (gramBad (arcsineCovariance d (r + 1)) δ) +
          B * Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2) := hn
      _ ≤ C * Real.exp (-c * N) + B * Real.exp (-(N : ℝ) * (ε / 2) ^ 2 / 2) :=
        add_le_add hp le_rfl
      _ ≤ C * Real.exp (-min c q * N) + B * Real.exp (-min c q * N) :=
        add_le_add (mul_le_mul_of_nonneg_left hexp₁ hC.le) (mul_le_mul_of_nonneg_left hexp₂ hB.le)
      _ = _ := by ring

theorem actual_gram_bad_probability_tendsto_zero {d : ℕ} (hd : 0 < d) (r : ℕ)
    {γ : ℝ} (hγ : γ < 1) {ε : ℝ} (hε : 0 < ε) :
    Tendsto (fun N : ℕ => (powerPrior d N r γ).real
      (gramBad (arcsineCovariance d (r + 1)) ε)) atTop (𝓝 (0 : ℝ)) := by
  obtain ⟨C, _, c, hc, hbound⟩ := actual_gram_exponential_freezing hd r hγ hε
  have hlim : Tendsto (fun N : ℕ => C * Real.exp (-c * N)) atTop (𝓝 (0 : ℝ)) := by
    have h := (Real.tendsto_exp_neg_atTop_nhds_zero.comp
      (tendsto_natCast_atTop_atTop.const_mul_atTop hc)).const_mul C
    simpa only [Function.comp_def, neg_mul, mul_zero] using h
  exact squeeze_zero' (Eventually.of_forall fun _ => measureReal_nonneg) hbound hlim

end NeuralGeneralization.NetworkGramConcentration
