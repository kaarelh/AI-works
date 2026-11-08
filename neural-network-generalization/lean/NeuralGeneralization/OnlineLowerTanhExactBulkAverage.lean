import NeuralGeneralization.OnlineLowerTanhConditioningMixture
import NeuralGeneralization.OnlineLowerTanhGlobalSaddle

/-! # Quantitative conditioning of an exactly equal tanh bulk

For either parity of the bulk dimension, the literal full coefficient is a
signed periodic average over the outside input cube, with error proportional
to one plus the outside squared norm divided by the bulk dimension.
-/
noncomputable section
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def exactBulkAverageConstant : ℝ := 2*balancedGlobalConstant+1

lemma exactBulkAverageConstant_pos : 0 < exactBulkAverageConstant := by
  unfold exactBulkAverageConstant
  linarith [balancedGlobalConstant_pos]

lemma gaussianLeadingHeight_le_one : Real.sqrt (2/Real.pi) ≤ 1 := by
  apply Real.sqrt_le_one.mpr
  exact (div_le_one Real.pi_pos).mpr (by linarith [Real.pi_gt_three])

lemma balanced_undamped_error {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 1 ≤ a) (_ha2 : a ≤ 2)
    (herr : ∀ B : ℝ,
      Real.sqrt (n : ℝ)*|parityCorrelation (fun _ : Fin n => a) B-
        residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B| ≤
      balancedGlobalConstant/(n : ℝ)+balancedGlobalConstant*|B|/(n : ℝ)*
        Real.exp (-B^2/(2*a^2*(n : ℝ)))) (B : ℝ) :
    |Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B-
      (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*periodicFourierResponse a (B+(n%2 : ℕ)*a)| ≤
      exactBulkAverageConstant*(1+B^2)/(n : ℝ) := by
  have ha0 : 0 < a := by linarith
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  let z := B^2/(2*a^2*(n : ℝ))
  let T := periodicFourierResponse a (B+(n%2 : ℕ)*a)
  let H := Real.sqrt (2/Real.pi)
  let σ := (-1 : ℝ)^(n/2)
  have hz : 0 ≤ z := by dsimp [z];positivity
  have he : Real.exp (-z) ≤ 1 := Real.exp_le_one_iff.mpr (by linarith)
  have he0 : 0 ≤ 1-Real.exp (-z) := by linarith
  have hgap : 1-Real.exp (-z) ≤ z := by linarith [Real.add_one_le_exp (-z)]
  have hzbound : z ≤ B^2/(n : ℝ) := by
    apply div_le_div_of_nonneg_left (sq_nonneg B) hnR
    have hs : 1 ≤ a^2 := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_right hs hnR.le]
  have hT : |T| ≤ 1 := periodicFourierResponse_abs_le_one a ha0 _
  have hH : 0 ≤ H := Real.sqrt_nonneg _
  have hH1 : H ≤ 1 := gaussianLeadingHeight_le_one
  have hσ : |σ|=1 := by simp [σ]
  have hdamp : |σ*H*Real.exp (-z)*T-σ*H*T| ≤ B^2/(n : ℝ) := by
    have heq : σ*H*Real.exp (-z)*T-σ*H*T=-(σ*H*(1-Real.exp (-z))*T) := by ring
    rw [heq,abs_neg,abs_mul,abs_mul,abs_mul,hσ,abs_of_nonneg hH,one_mul,
      abs_of_nonneg he0]
    calc
      _ ≤ H*(1-Real.exp (-z))*1 := mul_le_mul_of_nonneg_left hT (mul_nonneg hH he0)
      _ ≤ 1-Real.exp (-z) := by nlinarith [mul_le_mul_of_nonneg_right hH1 he0]
      _ ≤ z := hgap
      _ ≤ _ := hzbound
  have hfirst : |Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B-
      σ*H*Real.exp (-z)*T| ≤ balancedGlobalConstant/(n : ℝ)+
        balancedGlobalConstant*(1+B^2)/(n : ℝ) := by
    have hh := herr B
    have heq := balancedLeading_normalized hn ha0 B
    rw [neg_div] at heq
    change Real.sqrt (n : ℝ)*residualLeading _ _ a B=σ*H*Real.exp (-z)*T at heq
    rw [←heq,←mul_sub,abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)]
    apply hh.trans
    have hlin := mul_le_of_le_one_right
      (div_nonneg (mul_nonneg balancedGlobalConstant_pos.le (abs_nonneg B)) hnR.le) he
    have habs : |B| ≤ 1+B^2 := by nlinarith [sq_nonneg (|B|-1),sq_abs B]
    have hpoly := div_le_div_of_nonneg_right
      (mul_le_mul_of_nonneg_left habs balancedGlobalConstant_pos.le) hnR.le
    simp only [z,←neg_div] at hlin
    linarith
  have ht := abs_sub_le (Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B)
    (σ*H*Real.exp (-z)*T) (σ*H*T)
  change |Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B-σ*H*T| ≤ _
  apply (ht.trans (add_le_add hfirst hdamp)).trans
  rw [←add_div,←add_div]
  apply div_le_div_of_nonneg_right _ hnR.le
  unfold exactBulkAverageConstant
  have hK := balancedGlobalConstant_pos.le
  nlinarith [mul_nonneg hK (sq_nonneg B)]

/-- A common threshold works at every real bias and every gain in `[1,2]`. -/
theorem balanced_undamped_error_uniform :
    ∃ N₀ : ℕ,0 < N₀ ∧ ∀ n : ℕ,N₀ ≤ n → ∀ a : ℝ,1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      |Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B-
        (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*periodicFourierResponse a (B+(n%2 : ℕ)*a)| ≤
      exactBulkAverageConstant*(1+B^2)/(n : ℝ) := by
  obtain ⟨N₀,hN₀,herr⟩ := balanced_global_error_uniform
  refine ⟨N₀,hN₀,?_⟩
  intro n hn a ha ha2 B
  exact balanced_undamped_error (hN₀.trans_le hn) ha ha2 (herr n hn a ha ha2) B

/-- Literal signed periodic expectation over all complementary Boolean inputs. -/
def exactBulkPeriodicAverage {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) (a b : ℝ) : ℝ :=
  cubeMean (fun y => paritySign y*periodicFourierResponse a
    (incomingLinear (subsetWeights Aᶜ u) y+b+(A.card%2 : ℕ)*a))

lemma exactBulkPeriodicAverage_eq_uniformCubeMean {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (a : ℝ) :
    exactBulkPeriodicAverage A u a 0=uniformCubeMean (fun y => paritySign y*
      periodicFourierResponse a ((A.card%2 : ℕ)*a+incomingLinear (subsetWeights Aᶜ u) y)) := by
  simp [exactBulkPeriodicAverage,cubeMean,uniformCubeMean,Cube,ClippingCube,
    div_eq_mul_inv,mul_comm,add_comm]

lemma exactBulk_outside_phase_odd {d : ℕ} (hd : Odd d) (A : Finset (Fin d)) :
    Odd (A.card%2+Aᶜ.card) := by
  have hcard : A.card+Aᶜ.card=d := by simpa using Finset.card_add_card_compl A
  rw [Nat.odd_iff] at hd ⊢
  omega

/-- The finite-width approximation is uniform over the physical dimension,
the selected subset, the outside incoming vector, and the full real bias. -/
theorem exact_bulk_periodic_average_uniform :
    ∃ N₀ : ℕ,0 < N₀ ∧ ∀ d : ℕ,∀ A : Finset (Fin d),N₀ ≤ A.card →
      ∀ u : Fin d → ℝ,∀ a : ℝ,1 ≤ a → a ≤ 2 →
      (∀ i ∈ A,u i=a) → ∀ b : ℝ,
      |Real.sqrt (A.card : ℝ)*parityCorrelation u b-
        (-1 : ℝ)^(A.card/2)*Real.sqrt (2/Real.pi)*exactBulkPeriodicAverage A u a b| ≤
      exactBulkAverageConstant*(1+b^2+incomingEnergy (subsetWeights Aᶜ u))/(A.card : ℝ) := by
  obtain ⟨N₀,hN₀,herr⟩ := balanced_undamped_error_uniform
  refine ⟨N₀,hN₀,?_⟩
  intro d A hA u a ha ha2 hbulk b
  have hsel : subsetWeights A u=(fun _ => a) := by
    funext i
    exact hbulk _ (A.equivFin.symm i).property
  have hpoint (y : Cube Aᶜ.card) := herr A.card hA a ha ha2
    (incomingLinear (subsetWeights Aᶜ u) y+b)
  have hpoint' (y : Cube Aᶜ.card) :
      |Real.sqrt (A.card : ℝ)*(paritySign y*parityCorrelation (subsetWeights A u)
          (incomingLinear (subsetWeights Aᶜ u) y+b))-
        (-1 : ℝ)^(A.card/2)*Real.sqrt (2/Real.pi)*(paritySign y*
          periodicFourierResponse a (incomingLinear (subsetWeights Aᶜ u) y+b+(A.card%2 : ℕ)*a))| ≤
      exactBulkAverageConstant*(1+(b+incomingLinear (subsetWeights Aᶜ u) y)^2)/(A.card : ℝ) := by
    rw [hsel]
    have he : Real.sqrt (A.card : ℝ)*(paritySign y*parityCorrelation (fun _ : Fin A.card => a)
          (incomingLinear (subsetWeights Aᶜ u) y+b))-
        (-1 : ℝ)^(A.card/2)*Real.sqrt (2/Real.pi)*(paritySign y*
          periodicFourierResponse a (incomingLinear (subsetWeights Aᶜ u) y+b+(A.card%2 : ℕ)*a))=
      paritySign y*(Real.sqrt (A.card : ℝ)*parityCorrelation (fun _ : Fin A.card => a)
          (incomingLinear (subsetWeights Aᶜ u) y+b)-(-1 : ℝ)^(A.card/2)*Real.sqrt (2/Real.pi)*
          periodicFourierResponse a (incomingLinear (subsetWeights Aᶜ u) y+b+(A.card%2 : ℕ)*a)) := by ring
    rw [he,abs_mul,abs_paritySign,one_mul]
    simpa only [add_comm b] using hpoint y
  rw [parityCorrelation_conditioning A u b]
  unfold exactBulkPeriodicAverage
  rw [←cubeMean_const_mul,←cubeMean_const_mul,←cubeMean_sub]
  apply (abs_cubeMean_le _).trans
  apply (cubeMean_mono _ _ hpoint').trans_eq
  have he (y : Cube Aᶜ.card) :
      exactBulkAverageConstant*(1+(b+incomingLinear (subsetWeights Aᶜ u) y)^2)/(A.card : ℝ)=
      (exactBulkAverageConstant/(A.card : ℝ))*(1+(b+incomingLinear (subsetWeights Aᶜ u) y)^2) := by ring
  simp_rw [he]
  rw [cubeMean_const_mul,cubeMean_add,cubeMean_const,affine_secondMoment]
  ring

/-- An exact bulk with a vanishing relative outside energy has vanishing
periodic-average error along the original sequence, without a new subsequence. -/
theorem exact_bulk_periodic_average_tendsto
    (d : ℕ → ℕ) (A : (k : ℕ) → Finset (Fin (d k)))
    (u : (k : ℕ) → Fin (d k) → ℝ) (a : ℕ → ℝ)
    (hsize : Tendsto (fun k => (A k).card) atTop atTop)
    (ha : ∀ᶠ k in atTop,1 ≤ a k ∧ a k ≤ 2)
    (hbulk : ∀ᶠ k in atTop,∀ i ∈ A k,u k i=a k)
    (henergy : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ (u k))/
      ((A k).card : ℝ)) atTop (𝓝 0)) :
    Tendsto (fun k => Real.sqrt ((A k).card : ℝ)*parityCorrelation (u k) 0-
      (-1 : ℝ)^((A k).card/2)*Real.sqrt (2/Real.pi)*exactBulkPeriodicAverage (A k) (u k) (a k) 0)
      atTop (𝓝 0) := by
  have hone : Tendsto (fun k => (1 : ℝ)/((A k).card : ℝ)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_natCast_atTop_atTop.comp hsize)
  have hbound : Tendsto (fun k => exactBulkAverageConstant*
      (1+incomingEnergy (subsetWeights (A k)ᶜ (u k)))/((A k).card : ℝ)) atTop (𝓝 0) := by
    have ht := (hone.add henergy).const_mul exactBulkAverageConstant
    simp only [add_zero,mul_zero] at ht
    convert ht using 1
    funext k
    ring
  obtain ⟨N₀,hN₀,huniform⟩ := exact_bulk_periodic_average_uniform
  apply squeeze_zero_norm' _ hbound
  filter_upwards [hsize.eventually (eventually_ge_atTop N₀),ha,hbulk] with k hk hak hbk
  have hh := huniform (d k) (A k) hk (u k) (a k) hak.1 hak.2 hbk 0
  simpa only [Real.norm_eq_abs,zero_pow (by decide : (2 : ℕ) ≠ 0),add_zero] using hh

/-- Absolute coefficients have the corresponding unsigned limiting relation;
the parity-dependent bulk phase disappears exactly. -/
theorem exact_bulk_periodic_average_abs_tendsto
    (d : ℕ → ℕ) (A : (k : ℕ) → Finset (Fin (d k)))
    (u : (k : ℕ) → Fin (d k) → ℝ) (a : ℕ → ℝ)
    (hsize : Tendsto (fun k => (A k).card) atTop atTop)
    (ha : ∀ᶠ k in atTop,1 ≤ a k ∧ a k ≤ 2)
    (hbulk : ∀ᶠ k in atTop,∀ i ∈ A k,u k i=a k)
    (henergy : Tendsto (fun k => incomingEnergy (subsetWeights (A k)ᶜ (u k))/
      ((A k).card : ℝ)) atTop (𝓝 0)) :
    Tendsto (fun k => Real.sqrt ((A k).card : ℝ)*|parityCorrelation (u k) 0|-
      Real.sqrt (2/Real.pi)*|exactBulkPeriodicAverage (A k) (u k) (a k) 0|)
      atTop (𝓝 0) := by
  have ht := (exact_bulk_periodic_average_tendsto d A u a hsize ha hbulk henergy).abs
  simp only [abs_zero] at ht
  apply squeeze_zero_norm' _ ht
  exact Eventually.of_forall (fun k => by
    have hh := abs_abs_sub_abs_le_abs_sub
      (Real.sqrt ((A k).card : ℝ)*parityCorrelation (u k) 0)
      ((-1 : ℝ)^((A k).card/2)*Real.sqrt (2/Real.pi)*exactBulkPeriodicAverage (A k) (u k) (a k) 0)
    simpa only [Real.norm_eq_abs,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul,
      abs_of_nonneg (Real.sqrt_nonneg _)] using hh)

end NeuralGeneralization.OnlineLowerTanh
