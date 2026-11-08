import NeuralGeneralization.OnlineLowerTanhResidualParameters

/-! # The local-limit theorem for concrete hyperbolic kernels and canonical scales -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem residual_concrete_cell_L1 {ι : Type*} [Fintype ι] [DecidableEq ι]
    (N : ℕ → ℕ) (hNpos : ∀ k, 0 < N k) (hN : Tendsto N atTop atTop)
    (label : (k : ℕ) → Fin (N k) → ι) (q : ι → ℕ) (c : ι → ℤ)
    (hqOdd : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*(q j:ℤ) = 1)
    (d : (k : ℕ) → Fin (N k) → ℝ) (A D : ℕ → ℝ)
    {α Q E A₀ lo hi K₀ ρ : ℝ} (hα : 0 < α) (hQ : 0 < Q) (hlo : 0 < lo)
    (hAlo : ∀ k, lo ≤ A k) (hAhi : ∀ k, A k ≤ hi)
    (hA₀lo : lo ≤ A₀) (hA₀hi : A₀ ≤ hi)
    (hK₀ : 0 ≤ K₀) (hρ : 0 < ρ) (hρhi : ρ < Real.pi/(2*hi))
    (hfreq : ∀ k j, α*(N k:ℝ) ≤ ((Finset.univ.filter (fun i => label k i=j)).card:ℝ))
    (hq : ∀ j, (q j:ℝ) ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, (q (label k i):ℝ)*d k i = 0)
    (hA : Tendsto A atTop (𝓝 A₀)) (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hEbound : ∀ k, (∑ i, (d k i)^2) ≤ K₀)
    (l j : ℕ) :
    Tendsto (fun k => ∫ y : ℝ,
      |residualCellWindow (fun i => (q (label k i):ℝ)) (d k) (A k)
          (residualScale (A k) (fun i => q (label k i))) l ρ (residualDerivativeKernel j) y -
        residualWindowModel (d k) (residualPeak (A k) l) (residualDerivativeKernel j) y|)
      atTop (𝓝 0) := by
  let T : ℝ := ((l:ℝ)+1)*Real.pi/lo
  let M : ℝ := T^j/Real.sinh (Real.pi*ρ/2)
  have hT : 0 < T := by dsimp [T]; positivity
  have hM : 0 ≤ M := by dsimp [M]; positivity
  have hApos (k : ℕ) : 0 < A k := hlo.trans_le (hAlo k)
  have hA₀pos : 0 < A₀ := hlo.trans_le hA₀lo
  have hqpos (i : ι) : 0 < q i := by
    rcases hqOdd i with ⟨r,hr⟩
    omega
  have hqbound (k : ℕ) (i : Fin (N k)) : |(q (label k i):ℝ)| ≤ Q := by
    rw [abs_of_nonneg (Nat.cast_nonneg _)]
    exact hq _
  have hs := residualScale_tendsto N (fun k i => q (label k i)) hN
    (fun k i => hqpos _) A hA hA₀pos.ne'
  have hscale (k : ℕ) : (A k)^2*(∑ i, (q (label k i):ℝ)^2)*
      (residualScale (A k) (fun i => q (label k i)))^2 = 1 :=
    residualScale_identity (hNpos k) _ (fun i => hqpos _) (hApos k)
  have hρcenter : ρ < residualPeak A₀ l :=
    hρhi.trans_le (residualPeak_lower hA₀pos hA₀hi l)
  apply residualCellWindow_L1 N label q c d A
    (fun k => residualScale (A k) (fun i => q (label k i))) D
    hqOdd hbezout hα hQ hApos hA₀pos hK₀ hT.le hM hfreq hqbound hd horth hA hs hD hE
    hEbound hscale l hρcenter (residualDerivativeKernel j)
    (residualDerivativeKernel_measurable j)
    (residualDerivativeKernel_continuousAt j (residual_peak_pos hA₀pos l))
  · intro k y hy hρy
    rw [abs_of_pos (hρ.trans_le hρy)]
    exact residualPeak_cell_upper hlo (hAlo k) l hy
  · intro k y hy hρy
    exact residualDerivativeKernel_interval_bound j hρ hρy
      (residualPeak_cell_upper hlo (hAlo k) l hy)
  · intro k
    have hlower : ρ ≤ residualPeak (A k) l :=
      hρhi.le.trans (residualPeak_lower (hApos k) (hAhi k) l)
    have hupper : residualPeak (A k) l ≤ T := by
      simpa only [add_zero] using residualPeak_cell_upper hlo (hAlo k) l
        (show |(0:ℝ)| ≤ Real.pi/(2*A k) by simpa only [abs_zero] using (div_pos Real.pi_pos (mul_pos (by norm_num) (hApos k))).le)
    exact residualDerivativeKernel_interval_bound j hρ hlower hupper

end NeuralGeneralization.OnlineLowerTanh
