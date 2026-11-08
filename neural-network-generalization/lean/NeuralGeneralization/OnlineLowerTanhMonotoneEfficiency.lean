import NeuralGeneralization.OnlineLowerTanhConditionedEfficiency
import NeuralGeneralization.OnlineLowerTanhMonotone

/-! A uniform cap for arbitrary even or odd selected dimensions, with its
sharp central-binomial limiting constant. -/
noncomputable section
open scoped Topology BigOperators
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerRelu

theorem parityCorrelation_allsize_cap_nonneg (n : ℕ) (u : Fin (n+1) → ℝ)
    (hu : ∀ i, 0 ≤ u i) (b : ℝ) :
    |parityCorrelation u b| ≤ (n.choose (n/2):ℝ)/2^n := by
  let score : Finset (Fin (n+1)) → ℝ :=
    fun S => b+(∑ i, u i)-2*∑ i ∈ S, u i
  let f : Finset (Fin (n+1)) → ℝ := fun S => (1-Real.tanh (score S))/2
  have hmono : Monotone f := by
    intro S T hST
    have hsum : (∑ i ∈ S, u i) ≤ ∑ i ∈ T, u i :=
      Finset.sum_le_sum_of_subset_of_nonneg hST (fun i _ _ => hu i)
    have hscore : score T ≤ score S := by dsimp [score]; linarith
    have h := tanh_monotone hscore
    dsimp [f]
    linarith
  have hzero (S) : 0 ≤ f S := by
    have h := (abs_lt.mp (Real.abs_tanh_lt_one (score S))).2
    dsimp [f]
    linarith
  have hone (S) : f S ≤ 1 := by
    have h := (abs_lt.mp (Real.abs_tanh_lt_one (score S))).1
    dsimp [f]
    linarith
  have hcap := monotone_subset_parity_bound n f hmono hzero hone
  have hsum : (∑ S : Finset (Fin (n+1)), (-1:ℝ)^S.card * Real.tanh (score S)) =
      -2 * ∑ S : Finset (Fin (n+1)), (-1:ℝ)^S.card * f S := by
    have hp := sum_subset_parity_zero n
    rw [Finset.mul_sum]
    have hpoint (S : Finset (Fin (n+1))) :
        -2*((-1:ℝ)^S.card*f S) = (-1:ℝ)^S.card*Real.tanh (score S)-
          (-1:ℝ)^S.card := by dsimp [f]; ring
    simp_rw [hpoint]
    rw [Finset.sum_sub_distrib, hp]
    ring
  rw [parityCorrelation_negativeSet]
  change |(∑ S : Finset (Fin (n+1)), (-1:ℝ)^S.card*Real.tanh (score S))/2^(n+1)| ≤ _
  rw [hsum, abs_div, abs_mul]
  rw [abs_of_pos (by positivity : (0:ℝ)<2^(n+1))]
  norm_num only [abs_neg, abs_of_pos (by norm_num : (0:ℝ)<2)]
  rw [pow_succ]
  calc
    2*|∑ S, (-1:ℝ)^S.card*f S|/(2^n*2) ≤
        2*(n.choose (n/2):ℝ)/(2^n*2) := by
      exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hcap (by norm_num)) (by positivity)
    _ = (n.choose (n/2):ℝ)/2^n := by field_simp

theorem parityCorrelation_allsize_cap (n : ℕ) (u : Fin (n+1) → ℝ) (b : ℝ) :
    |parityCorrelation u b| ≤ (n.choose (n/2):ℝ)/2^n := by
  rw [parityCorrelation_abs_weights]
  exact parityCorrelation_allsize_cap_nonneg n _ (fun i => abs_nonneg _) b

lemma central_choose_odd_le (r : ℕ) : (2*r+1).choose r ≤ 2*Nat.centralBinom r := by
  have h := Nat.choose_mul_succ_eq (2*r) r
  have hh : 2*r+1-r = r+1 := by omega
  rw [hh] at h
  unfold Nat.centralBinom
  nlinarith

lemma allsize_cap_le_kappa (n : ℕ) :
    (n.choose (n/2):ℝ)/2^n ≤ oddParityKappa (n/2) := by
  have hn : n=2*(n/2) ∨ n=2*(n/2)+1 := by omega
  rcases hn with hn | hn
  · have hp : (2:ℝ)^n=4^(n/2) := by nth_rw 1 [hn]; rw [pow_mul]; norm_num
    rw [hp]
    unfold oddParityKappa Nat.centralBinom
    have he : n.choose (n/2)=(2*(n/2)).choose (n/2) := congrArg (fun t => t.choose (n/2)) hn
    rw [he]
  · have hc : (n.choose (n/2):ℝ)≤2*(Nat.centralBinom (n/2):ℝ) := by
      have h := central_choose_odd_le (n/2)
      rw [← hn] at h
      exact_mod_cast h
    have hp : (2:ℝ)^n=2*4^(n/2) := by nth_rw 1 [hn]; rw [pow_add,pow_mul]; norm_num; ring
    rw [hp]
    unfold oddParityKappa
    calc
      _ ≤ 2*(Nat.centralBinom (n/2):ℝ)/(2*4^(n/2)) :=
        div_le_div_of_nonneg_right hc (by positivity)
      _ = _ := by field_simp

/-- In dimension n+1 the same odd central-binomial cap with index floor(n/2)
works; losing at most one coordinate has no asymptotic effect. -/
theorem parityCorrelation_kappa_cap (n : ℕ) (u : Fin (n+1) → ℝ) (b : ℝ) :
    |parityCorrelation u b| ≤ oddParityKappa (n/2) :=
  (parityCorrelation_allsize_cap n u b).trans (allsize_cap_le_kappa n)

lemma halfIndex_tendsto : Tendsto (fun n:ℕ => n/2) atTop atTop := by
  apply tendsto_atTop.mpr
  intro b
  filter_upwards [eventually_ge_atTop (2*b)] with n hn
  omega

lemma oddHalfDegree_tendsto :
    Tendsto (fun n:ℕ => 2*(n/2:ℕ)+1) atTop atTop := by
  apply tendsto_atTop.mpr
  intro b
  filter_upwards [eventually_ge_atTop b] with n hn
  omega

lemma oddHalfDegree_ratio_tendsto :
    Tendsto (fun n:ℕ => ((n:ℝ)+1)/(2*(n/2:ℕ)+1)) atTop (𝓝 1) := by
  have ht : Tendsto (fun n:ℕ => (2*(n/2:ℕ)+1:ℝ)) atTop atTop := by
    simpa only [Function.comp_def,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one] using
      (tendsto_natCast_atTop_atTop (R:=ℝ)).comp oddHalfDegree_tendsto
  have hi := tendsto_inv_atTop_zero.comp ht
  simp only [Function.comp_def] at hi
  have he : Tendsto (fun n:ℕ => ((n:ℝ)+1)/(2*(n/2:ℕ)+1)-1) atTop (𝓝 0) := by
    apply squeeze_zero' _ _ hi
    · filter_upwards [] with n
      have hn : 2*(n/2) ≤ n := by omega
      have hn' : 2*(n/2:ℕ) ≤ (n:ℝ) := by exact_mod_cast hn
      have hd : (0:ℝ)<2*(n/2:ℕ)+1 := by positivity
      have hh := (le_div_iff₀ hd).mpr (by linarith : (1:ℝ)*(2*(n/2:ℕ)+1)≤(n:ℝ)+1)
      linarith
    · filter_upwards [] with n
      have hn : n ≤ 2*(n/2)+1 := by omega
      have hn' : (n:ℝ) ≤ 2*(n/2:ℕ)+1 := by exact_mod_cast hn
      have hd : (0:ℝ)<2*(n/2:ℕ)+1 := by positivity
      rw [sub_le_iff_le_add,inv_eq_one_div]
      apply (div_le_iff₀ hd).mpr
      field_simp
      linarith
  simpa only [sub_add_cancel,zero_add] using he.add_const 1

/-- The cap in either parity of dimension has the same Gaussian constant. -/
theorem allsize_scaled_kappa_tendsto :
    Tendsto (fun n:ℕ => Real.sqrt ((n:ℝ)+1)*oddParityKappa (n/2)) atTop
      (𝓝 (Real.sqrt (2/Real.pi))) := by
  have hr := Real.continuous_sqrt.continuousAt.tendsto.comp oddHalfDegree_ratio_tendsto
  have hk := scaled_oddParityKappa_tendsto.comp halfIndex_tendsto
  have ht := hr.mul hk
  simp only [Real.sqrt_one,one_mul] at ht
  convert ht using 1
  funext n
  simp only [Function.comp_def]
  rw [Real.sqrt_div (by positivity)]
  have hpos : 0 < Real.sqrt (2*(n/2:ℕ)+1) := by positivity
  field_simp

theorem parityCorrelation_dimension_cap {n:ℕ} (hn:0<n) (u:Fin n→ℝ) (b:ℝ) :
    |parityCorrelation u b|≤oddParityKappa ((n-1)/2) := by
  cases n with
  | zero => omega
  | succ n => simpa only [Nat.succ_sub_one] using parityCorrelation_kappa_cap n u b

lemma predecessor_tendsto : Tendsto (fun n:ℕ => n-1) atTop atTop := by
  apply tendsto_atTop.mpr
  intro b
  filter_upwards [eventually_ge_atTop (b+1)] with n hn
  omega

theorem dimension_scaled_kappa_tendsto :
    Tendsto (fun n:ℕ => Real.sqrt (n:ℝ)*oddParityKappa ((n-1)/2)) atTop
      (𝓝 (Real.sqrt (2/Real.pi))) := by
  have ht := allsize_scaled_kappa_tendsto.comp predecessor_tendsto
  apply ht.congr'
  filter_upwards [eventually_ge_atTop 1] with n hn
  simp only [Function.comp_def]
  have he : ((n-1:ℕ):ℝ)+1=(n:ℝ) := by exact_mod_cast (show n-1+1=n by omega)
  rw [he]

/-- Arbitrary even or odd retained subsets give the monotone Gaussian cap,
with the energy of the full original incoming vector in the denominator. -/
theorem monotone_conditioned_efficiency_upper_bound
    (N : ℕ → ℕ) (u : (k : ℕ) → Fin (N k) → ℝ) (bias : ℕ → ℝ)
    (A : (k : ℕ) → Finset (Fin (N k)))
    (ρ e : ℝ) (hρ : 0 < ρ) (he : 0 < e)
    (hN : ∀ᶠ k in atTop, 0 < N k)
    (hM : Tendsto (fun k => (A k).card) atTop atTop)
    (hρlim : Tendsto (fun k => ((A k).card:ℝ)/(N k:ℝ)) atTop (𝓝 ρ))
    (hE : Tendsto (fun k => incomingEnergy (u k)/(N k:ℝ)) atTop (𝓝 e)) :
    ∀ ε > 0, ∀ᶠ k in atTop,
      (N k:ℝ)*|parityCorrelation (u k) (bias k)|/Real.sqrt (incomingEnergy (u k)) ≤
      Real.sqrt (2/Real.pi)/Real.sqrt (ρ*e)+ε := by
  apply normalized_efficiency_upper_bound (fun k => (N k:ℝ))
    (fun k => ((A k).card:ℝ)) (fun k => incomingEnergy (u k))
    (fun k => parityCorrelation (u k) (bias k)) ρ e _ hρ he
  · filter_upwards [hN] with k hk
    exact_mod_cast hk
  · exact hρlim
  · exact hE
  · intro δ hδ
    have ht := dimension_scaled_kappa_tendsto.comp hM
    filter_upwards [hM.eventually (eventually_ge_atTop 1),
      ht.eventually (gt_mem_nhds (by linarith : Real.sqrt (2/Real.pi)<Real.sqrt (2/Real.pi)+δ))]
      with k hk hbound
    have hc := parityCorrelation_le_uniform_subset_cap (A k) (u k) (bias k)
      (oddParityKappa (((A k).card-1)/2))
      (fun B => parityCorrelation_dimension_cap (by omega) (subsetWeights (A k) (u k)) B)
    exact (mul_le_mul_of_nonneg_left hc (Real.sqrt_nonneg _)).trans hbound.le

/-- The primitive-lattice normalization displays both the selected and full
second moments, and the gcd factor, without discarding escaped energy. -/
lemma primitive_efficiency_constant (a g Q T : ℝ) (ha:0<a) (hg:0<g)
    (hQ:0<Q) (hT:0<T) :
    (Real.sqrt (2/Real.pi)*scalarF0 (a*g))/Real.sqrt ((Q/g^2)*(a^2*T)) =
      Real.sqrt (2/Real.pi)*(scalarF0 (a*g)/(a*g))*g^2/Real.sqrt (Q*T) := by
  have he : (Q/g^2)*(a^2*T)=(a/g)^2*(Q*T) := by field_simp
  rw [he,Real.sqrt_mul (sq_nonneg _),Real.sqrt_sq (div_pos ha hg).le]
  field_simp

end NeuralGeneralization.OnlineLowerTanh
