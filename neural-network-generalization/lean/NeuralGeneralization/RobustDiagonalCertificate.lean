import NeuralGeneralization.RobustSpectralCertificate

/-! Diagonal positive-semidefinite certificates, expressed by their exact
quadratic-form inequalities. The bound controls finite disturbances. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel BatchTwoNeuralConverse
variable {d N r : ℕ}

/-- Coordinate form of M_H ≥ vvᵀ and W_sᵀ M_s W_s ≤ M_(s-1).
Diagonality is essential for the coordinatewise tanh contraction below. -/
structure DiagonalCertificate (w : Weights d N r) where
  metric : Fin (r+1) → Fin N → ℝ
  nonneg : ∀ s i,0 ≤ metric s i
  readout : ∀ u : Fin N → ℝ,
    (∑ i,w (.inr (.inr i))*u i)^2 ≤ ∑ i,metric (Fin.last r) i*u i^2
  transition : ∀ (s : Fin r) (u : Fin N → ℝ),
    (∑ i,metric s.succ i*(∑ j,w (.inr (.inl (s,i,j)))*u j)^2) ≤
      ∑ i,metric s.castSucc i*u i^2

/-- The certificate bounds every possible diagonal slope in [0,1], hence
also the secant slopes realized by a finite perturbation. -/
theorem diagonal_path_bound (w : Weights d N r) (M : DiagonalCertificate w)
    (D : Slopes N r) (hD : D ∈ slopeCube N r) (j : Fin (r+1)) (u : Fin N → ℝ) :
    (∑ i,pathRow w D ((List.finRange r).drop j.val) i*u i)^2 ≤
      ∑ i,M.metric j i*u i^2 := by
  have haux (n : ℕ) (hn : n ≤ r) : ∀ u : Fin N → ℝ,
      (∑ i,pathRow w D ((List.finRange r).drop n) i*u i)^2 ≤
        ∑ i,M.metric ⟨n,by omega⟩ i*u i^2 := by
    induction hn using Nat.decreasingInduction with
    | self =>
      intro u
      have hd : (List.finRange r).drop r = [] := by
        simpa only [List.length_finRange] using List.drop_length (l := List.finRange r)
      simpa only [hd, pathRow, Fin.last] using M.readout u
    | of_succ n hn ih =>
      intro u
      let s : Fin r := ⟨n,hn⟩
      let v : Fin N → ℝ := fun i => ∑ k,w (.inr (.inl (s,i,k)))*u k
      have he : (∑ i,pathRow w D ((List.finRange r).drop n) i*u i) =
          ∑ i,pathRow w D ((List.finRange r).drop (n+1)) i*(D s i*v i) := by
        simp_rw [show n = s.val from rfl, pathRow_drop w D s, Finset.sum_mul]
        rw [Finset.sum_comm]
        simp only [v, Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        apply Finset.sum_congr rfl
        intro k _
        ring
      rw [he]
      apply (ih (fun i => D s i*v i)).trans
      calc
        _ ≤ ∑ i,M.metric s.succ i*(v i)^2 := by
          apply Finset.sum_le_sum
          intro i _
          change M.metric s.succ i*(D s i*v i)^2 ≤ M.metric s.succ i*(v i)^2
          have h0 : 0 ≤ D s i := hD.1 s i
          have h1 : D s i ≤ 1 := hD.2 s i
          have hs : (D s i)^2 ≤ 1 := by nlinarith
          have hh := mul_le_mul_of_nonneg_left hs
            (mul_nonneg (M.nonneg s.succ i) (sq_nonneg (v i)))
          convert hh using 1 <;> ring
        _ ≤ _ := M.transition s u
  exact haux j.val (by omega) u

theorem diagonal_row_norm_bound (w : Weights d N r) (M : DiagonalCertificate w)
    (D : Slopes N r) (hD : D ∈ slopeCube N r) (b : Fin (r+1) → ℝ)
    (hb : ∀ s,0 ≤ b s) (hM : ∀ s i,M.metric s i ≤ b s) (j : Fin (r+1)) :
    (∑ i,(pathRow w D ((List.finRange r).drop j.val) i)^2) ≤ b j := by
  let u := pathRow w D ((List.finRange r).drop j.val)
  let S : ℝ := ∑ i,(u i)^2
  have hh := diagonal_path_bound w M D hD j u
  have hm : (∑ i,M.metric j i*(u i)^2) ≤ b j*S := by
    dsimp [S]
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (hM j i) (sq_nonneg _)
  have he : (∑ i,pathRow w D ((List.finRange r).drop j.val) i*u i) = S := by
    simp only [S,u,pow_two]
  rw [he] at hh
  change S ≤ b j
  have hS : 0 ≤ S := by dsimp [S]; positivity
  by_cases hz : S = 0
  · simpa only [hz] using hb j
  · have hp : 0 < S := lt_of_le_of_ne hS (Ne.symm hz)
    apply (mul_le_mul_iff_right₀ hp).mp
    nlinarith only [hh.trans hm]

theorem diagonal_gain_bound (w : Weights d N r) (M : DiagonalCertificate w)
    (b : Fin (r+1) → ℝ) (hb : ∀ s,0 ≤ b s) (hM : ∀ s i,M.metric s i ≤ b s) :
    gainSq w ≤ (N:ℝ)*∑ s,b s := by
  unfold gainSq
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  unfold gainEnergy
  exact mul_le_mul_of_nonneg_left
    (Finset.sum_le_sum fun j _ => diagonal_row_norm_bound w M D hD b hb hM j)
    (Nat.cast_nonneg N)

/-- Squared form of |Δz| ≤ sqrt(1+Q_M) ‖η‖_*, Q_M=N sum_s b_s.
Taking b_s=max_i M_s(i,i) is exactly the printed eigenvalue expression. -/
theorem diagonal_noise_sq (hN : 0 < N) (w : Weights d N r) (M : DiagonalCertificate w)
    (b : Fin (r+1) → ℝ) (hb : ∀ s,0 ≤ b s) (hM : ∀ s i,M.metric s i ≤ b s)
    (x : Cube d) (η : NetworkDisturbance N r) :
    (noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x)^2 ≤
      (1+(N:ℝ)*∑ s,b s)*noiseBudgetSq η := by
  exact (noisy_difference_sq_le hN w x η).trans
    (mul_le_mul_of_nonneg_right (by linarith [diagonal_gain_bound w M b hb hM])
      (noiseBudgetSq_nonneg η))

theorem diagonal_support (hN : 0 < N) (w : Weights d N r) (M : DiagonalCertificate w)
    (b : Fin (r+1) → ℝ) (hb : ∀ s,0 ≤ b s) (hM : ∀ s i,M.metric s i ≤ b s)
    {c : ℝ} (hc : c^2*(1+(N:ℝ)*∑ s,b s)/(1+((r:ℝ)+1)*readoutEnergy w) ≤ 1/256) :
    w ∈ robustEvent Real.tanh c := by
  intro x η hη
  have hE := readoutEnergy_nonneg w
  have hden : 0 < 1+((r:ℝ)+1)*readoutEnergy w := by positivity
  have hbs : 0 ≤ ∑ s,b s := Finset.sum_nonneg (fun s _ => hb s)
  have hcoeff : 0 ≤ 1+(N:ℝ)*∑ s,b s := by positivity
  have hh := (diagonal_noise_sq hN w M b hb hM x η).trans
    (mul_le_mul_of_nonneg_left hη hcoeff)
  have he : (1+(N:ℝ)*∑ s,b s)*(robustRadius c w)^2 =
      c^2*(1+(N:ℝ)*∑ s,b s)/(1+((r:ℝ)+1)*readoutEnergy w) := by
    rw [robustRadius, div_pow, Real.sq_sqrt hden.le]
    ring
  rw [he] at hh
  have hr : |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ (1:ℝ)/16 := by
    apply (sq_le_sq₀ (abs_nonneg _) (by norm_num)).mp
    rw [sq_abs]
    exact (hh.trans hc).trans_eq (by norm_num)
  exact (RobustStatistics.clippedScore_lipschitz _ _).trans hr


/-- For a diagonal PSD matrix, its largest eigenvalue is its largest entry. -/
def diagonalMetricMaximum (w : Weights d N r) (M : DiagonalCertificate w)
    (s : Fin (r+1)) : ℝ := sSup (Set.range (M.metric s))

def diagonalMetricCost (w : Weights d N r) (M : DiagonalCertificate w) : ℝ :=
  (N:ℝ)*∑ s,diagonalMetricMaximum w M s

/-- The literal Q_M=N sum_s lambda_max(M_s), with no separately supplied
entrywise upper-bound parameters. -/
theorem diagonal_metric_certificate (hN : 0<N) (w : Weights d N r)
    (M : DiagonalCertificate w) (x : Cube d) (η : NetworkDisturbance N r) :
    |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤
      Real.sqrt (1+diagonalMetricCost w M)*Real.sqrt (noiseBudgetSq η) := by
  have hmax (s : Fin (r+1)) (i : Fin N) : M.metric s i ≤ diagonalMetricMaximum w M s :=
    le_csSup (Set.finite_range _).bddAbove (Set.mem_range_self i)
  have h0 (s : Fin (r+1)) : 0 ≤ diagonalMetricMaximum w M s :=
    (M.nonneg s ⟨0,hN⟩).trans (hmax s ⟨0,hN⟩)
  have hh := diagonal_noise_sq hN w M (diagonalMetricMaximum w M) h0 hmax x η
  have hcost : 0 ≤ diagonalMetricCost w M :=
    mul_nonneg (Nat.cast_nonneg N) (Finset.sum_nonneg (fun s _ => h0 s))
  apply (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))).mp
  rw [sq_abs,mul_pow,Real.sq_sqrt (by linarith : 0≤1+diagonalMetricCost w M),
    Real.sq_sqrt (noiseBudgetSq_nonneg η)]
  exact hh

end NeuralGeneralization.RobustCertificates
