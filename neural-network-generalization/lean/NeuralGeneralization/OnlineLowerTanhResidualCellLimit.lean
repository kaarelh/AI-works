import NeuralGeneralization.OnlineLowerTanhResidualCell
import NeuralGeneralization.OnlineLowerTanhResidualOscillation

/-! # The whole-cell residual local limit, uniformly in external phase -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualCellWindow {n : ℕ} (q d : Fin n → ℝ) (A s : ℝ) (l : ℕ)
    (ρ : ℝ) (K : ℝ → ℝ) (y : ℝ) : ℝ :=
  if |y*s| ≤ Real.pi/(2*A) ∧ ρ ≤ residualPeak A l+y*s then
    (∏ i, Real.cos (A*q i*(y*s)+d i*(residualPeak A l+y*s)))*K (residualPeak A l+y*s)
  else 0

lemma residualCellWindow_measurable {n : ℕ} (q d : Fin n → ℝ) (A s : ℝ) (l : ℕ)
    (ρ : ℝ) (K : ℝ → ℝ) (hK : Measurable K) : Measurable (residualCellWindow q d A s l ρ K) := by
  unfold residualCellWindow
  apply Measurable.ite
  · exact (measurableSet_le (by fun_prop : Measurable (fun y : ℝ => |y*s|))
      (measurable_const (a := Real.pi/(2*A)))).inter
        (measurableSet_le (measurable_const (a := ρ))
          (by fun_prop : Measurable (fun y : ℝ => residualPeak A l+y*s)))
  · exact (by fun_prop : Measurable (fun y : ℝ =>
      ∏ i, Real.cos (A*q i*(y*s)+d i*(residualPeak A l+y*s)))).mul
        (hK.comp (by fun_prop))
  · exact measurable_const

lemma residualPeak_tendsto {A : ℕ → ℝ} {A₀ : ℝ} (hA : Tendsto A atTop (𝓝 A₀))
    (hA₀ : A₀ ≠ 0) (l : ℕ) :
    Tendsto (fun k => residualPeak (A k) l) atTop (𝓝 (residualPeak A₀ l)) := by
  unfold residualPeak periodicFrequency
  exact tendsto_const_nhds.mul (tendsto_const_nhds.div (tendsto_const_nhds.mul hA) (by positivity))

theorem residualCellWindow_pointwise (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A s D : ℕ → ℝ)
    {Q E A₀ ρ : ℝ} (hA₀ : 0 < A₀) (l : ℕ) (hρ : ρ < residualPeak A₀ l)
    (hq : ∀ k i, |q k i| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hA : Tendsto A atTop (𝓝 A₀)) (hs : Tendsto s atTop (𝓝 0))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hscale : ∀ k, (A k)^2*(∑ i, (q k i)^2)*(s k)^2 = 1)
    (K : ℝ → ℝ) (hK : ContinuousAt K (residualPeak A₀ l)) (y : ℝ) :
    Tendsto (fun k => residualCellWindow (q k) (d k) (A k) (s k) l ρ K y -
      residualWindowModel (d k) (residualPeak (A k) l) K y) atTop (𝓝 0) := by
  have ht := residualPeak_tendsto hA hA₀.ne' l
  have hys : Tendsto (fun k => y*s k) atTop (𝓝 0) := by simpa using hs.const_mul y
  have hAs : Tendsto (fun k => A k*s k) atTop (𝓝 0) := by simpa using hA.mul hs
  have hprod := residual_cosine_product_limit N q d A (fun k => y*s k)
    (fun k => residualPeak (A k) l) D
    (Q := max Q 0) (le_max_right _ _) (fun k i => (hq k i).trans (le_max_left _ _)) hd horth
    (by simpa only [mul_zero,mul_left_comm,mul_assoc] using hAs.const_mul y)
    hys ht hD hE (S := y^2) (by
      have he (k : ℕ) : (A k)^2*(∑ i, (q k i)^2)*(y*s k)^2=y^2 := by
        calc
          _ = y^2*((A k)^2*(∑ i, (q k i)^2)*(s k)^2) := by ring
          _ = _ := by rw [hscale,mul_one]
      simp_rw [he]
      exact tendsto_const_nhds)
  have hphase : Tendsto (fun k => residualPeak (A k) l+y*s k) atTop (𝓝 (residualPeak A₀ l)) := by
    simpa using ht.add hys
  have hband : Tendsto (fun k => Real.pi/(2*A k)) atTop (𝓝 (Real.pi/(2*A₀))) :=
    tendsto_const_nhds.div (tendsto_const_nhds.mul hA) (by positivity)
  have hbandpos : 0 < Real.pi/(2*A₀) := by positivity
  have hcut : ∀ᶠ k in atTop, |y*s k| ≤ Real.pi/(2*A k) ∧ ρ ≤ residualPeak (A k) l+y*s k := by
    filter_upwards [hys.abs.eventually (gt_mem_nhds (show |(0:ℝ)|<(Real.pi/(2*A₀))/2 by simpa only [abs_zero] using half_pos hbandpos)),
      hband.eventually (lt_mem_nhds (show (Real.pi/(2*A₀))/2<Real.pi/(2*A₀) by linarith)),
      hphase.eventually (lt_mem_nhds hρ)] with k hk hb ht
    exact ⟨hk.le.trans hb.le,ht.le⟩
  have hwin : Tendsto (fun k => residualCellWindow (q k) (d k) (A k) (s k) l ρ K y)
      atTop (𝓝 (Real.exp (-(y^2+E*(residualPeak A₀ l)^2)/2)*K (residualPeak A₀ l))) := by
    apply (hprod.mul (hK.tendsto.comp hphase)).congr'
    filter_upwards [hcut] with k hk
    simp only [residualCellWindow,if_pos hk,Function.comp_apply]
  have hmod : Tendsto (fun k => residualWindowModel (d k) (residualPeak (A k) l) K y)
      atTop (𝓝 (Real.exp (-y^2/2)*Real.exp (-E*(residualPeak A₀ l)^2/2)*K (residualPeak A₀ l))) := by
    unfold residualWindowModel
    simpa only [Function.comp_apply,neg_mul] using
      ((tendsto_const_nhds (x := Real.exp (-y^2/2))).mul
        (Real.continuous_exp.continuousAt.tendsto.comp ((hE.mul (ht.pow 2)).neg.div_const 2))).mul
          (hK.tendsto.comp ht)
  have he : Real.exp (-(y^2+E*(residualPeak A₀ l)^2)/2)*K (residualPeak A₀ l) =
      Real.exp (-y^2/2)*Real.exp (-E*(residualPeak A₀ l)^2/2)*K (residualPeak A₀ l) := by
    rw [← Real.exp_add]
    congr 2
    ring
  rw [he] at hwin
  simpa using hwin.sub hmod

lemma residualCellWindow_bound {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (q : ι → ℕ) (c : ι → ℤ)
    (hqOdd : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*(q j:ℤ) = 1)
    {α Q A s K₀ T ρ M : ℝ} (hα : 0 < α) (hQ : 0 < Q) (hA : 0 < A)
    (hK₀ : 0 ≤ K₀) (hT : 0 ≤ T) (hM : 0 ≤ M)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ))
    (hq : ∀ i, |(q (label i):ℝ)| ≤ Q)
    (d : Fin n → ℝ) (hE : (∑ i, (d i)^2) ≤ K₀)
    (hscale : A^2*(∑ i, (q (label i):ℝ)^2)*s^2 = 1)
    (l : ℕ) (K : ℝ → ℝ)
    (hTab : ∀ y, |y*s| ≤ Real.pi/(2*A) → ρ ≤ residualPeak A l+y*s → |residualPeak A l+y*s| ≤ T)
    (hKb : ∀ y, |y*s| ≤ Real.pi/(2*A) → ρ ≤ residualPeak A l+y*s → |K (residualPeak A l+y*s)| ≤ M)
    (y : ℝ) :
    |residualCellWindow (fun i => (q (label i):ℝ)) d A s l ρ K y| ≤
      (M*Real.exp (K₀*T^2/2))*Real.exp (-(α/((∑ j, (c j:ℝ)^2)*Real.pi^2*Q^2))*y^2) := by
  unfold residualCellWindow
  split_ifs with hy
  · rw [abs_mul]
    have hprod := residual_cell_gaussian_bound label (fun j => (q j:ℤ)) c
      (fun j => by exact_mod_cast hqOdd j) hbezout hα hQ hA hK₀ hT hfreq
      (by simpa only [Int.cast_natCast] using hq) d hE
      (by simpa only [Int.cast_natCast] using hscale) l y hy.1 (hTab y hy.1 hy.2)
    simp only [Int.cast_natCast] at hprod
    rw [residual_peak_product_abs hA.ne' (fun i => q (label i)) (fun i => hqOdd (label i))] at hprod
    have hh := mul_le_mul hprod (hKb y hy.1 hy.2) (abs_nonneg _) (by positivity)
    nlinarith
  · simp only [abs_zero]
    positivity

lemma residualCellWindow_integrable {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (q : ι → ℕ) (c : ι → ℤ)
    (hqOdd : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*(q j:ℤ) = 1)
    {α Q A s K₀ T ρ M : ℝ} (hα : 0 < α) (hQ : 0 < Q) (hA : 0 < A)
    (hK₀ : 0 ≤ K₀) (hT : 0 ≤ T) (hM : 0 ≤ M)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ))
    (hq : ∀ i, |(q (label i):ℝ)| ≤ Q)
    (d : Fin n → ℝ) (hE : (∑ i, (d i)^2) ≤ K₀)
    (hscale : A^2*(∑ i, (q (label i):ℝ)^2)*s^2 = 1)
    (l : ℕ) (K : ℝ → ℝ) (hKmeas : Measurable K)
    (hTab : ∀ y, |y*s| ≤ Real.pi/(2*A) → ρ ≤ residualPeak A l+y*s → |residualPeak A l+y*s| ≤ T)
    (hKb : ∀ y, |y*s| ≤ Real.pi/(2*A) → ρ ≤ residualPeak A l+y*s → |K (residualPeak A l+y*s)| ≤ M) :
    Integrable (residualCellWindow (fun i => (q (label i):ℝ)) d A s l ρ K) := by
  have hC := bezout_energy_pos (fun j => (q j:ℤ)) c hbezout
  have hr : 0 < α/((∑ j, (c j:ℝ)^2)*Real.pi^2*Q^2) := by positivity
  apply ((integrable_exp_neg_mul_sq hr).const_mul (M*Real.exp (K₀*T^2/2))).mono'
    (residualCellWindow_measurable _ _ _ _ _ _ _ hKmeas).aestronglyMeasurable
  exact Eventually.of_forall (fun y => by
    simpa only [Real.norm_eq_abs] using residualCellWindow_bound label q c hqOdd hbezout
      hα hQ hA hK₀ hT hM hfreq hq d hE hscale l K hTab hKb y)

lemma residualCellWindow_sine_error {n : ℕ} (q d : Fin n → ℝ) (A s ρ B θ : ℝ)
    (l : ℕ) (K : ℝ → ℝ)
    (hi : Integrable (residualCellWindow q d A s l ρ K)) :
    |(∫ y : ℝ, Real.sin (B*(residualPeak A l+y*s)+θ)*residualCellWindow q d A s l ρ K y) -
      Real.sqrt (2*Real.pi)*Real.exp (-(B*s)^2/2)*Real.sin (B*residualPeak A l+θ)*
        Real.exp (-(∑ i, (d i)^2)*(residualPeak A l)^2/2)*K (residualPeak A l)| ≤
      ∫ y : ℝ, |residualCellWindow q d A s l ρ K y-residualWindowModel d (residualPeak A l) K y| := by
  rw [← residualWindowModel_sine_integral d s (residualPeak A l) B θ K]
  exact oscillatory_L1_difference _ _ _ hi (residualWindowModel_integrable _ _ _)
    (by fun_prop : Continuous (fun y : ℝ => Real.sin (B*(residualPeak A l+y*s)+θ))).aestronglyMeasurable
    (fun y => Real.abs_sin_le_one _)

/-- Whole-cell L¹ convergence for the actual finite-alphabet residual
sequence. The Gaussian envelope is derived from Bezout coercivity, rather
than postulated as a local-limit premise. -/
theorem residualCellWindow_L1 {ι : Type*} [Fintype ι] [DecidableEq ι]
    (N : ℕ → ℕ) (label : (k : ℕ) → Fin (N k) → ι)
    (q : ι → ℕ) (c : ι → ℤ) (d : (k : ℕ) → Fin (N k) → ℝ)
    (A s D : ℕ → ℝ) {α Q E A₀ K₀ T ρ M : ℝ}
    (hqOdd : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*(q j:ℤ) = 1)
    (hα : 0 < α) (hQ : 0 < Q) (hApos : ∀ k, 0 < A k) (hA₀ : 0 < A₀)
    (hK₀ : 0 ≤ K₀) (hT : 0 ≤ T) (hM : 0 ≤ M)
    (hfreq : ∀ k j, α*(N k:ℝ) ≤ ((Finset.univ.filter (fun i => label k i=j)).card:ℝ))
    (hq : ∀ k i, |(q (label k i):ℝ)| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, (q (label k i):ℝ)*d k i = 0)
    (hA : Tendsto A atTop (𝓝 A₀)) (hs : Tendsto s atTop (𝓝 0))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hEbound : ∀ k, (∑ i, (d k i)^2) ≤ K₀)
    (hscale : ∀ k, (A k)^2*(∑ i, (q (label k i):ℝ)^2)*(s k)^2 = 1)
    (l : ℕ) (hρ : ρ < residualPeak A₀ l) (K : ℝ → ℝ)
    (hKmeas : Measurable K) (hKcont : ContinuousAt K (residualPeak A₀ l))
    (hTab : ∀ k y, |y*s k| ≤ Real.pi/(2*A k) → ρ ≤ residualPeak (A k) l+y*s k →
      |residualPeak (A k) l+y*s k| ≤ T)
    (hKb : ∀ k y, |y*s k| ≤ Real.pi/(2*A k) → ρ ≤ residualPeak (A k) l+y*s k →
      |K (residualPeak (A k) l+y*s k)| ≤ M)
    (hKcenter : ∀ k, |K (residualPeak (A k) l)| ≤ M) :
    Tendsto (fun k => ∫ y : ℝ,
      |residualCellWindow (fun i => (q (label k i):ℝ)) (d k) (A k) (s k) l ρ K y -
        residualWindowModel (d k) (residualPeak (A k) l) K y|) atTop (𝓝 0) := by
  let rate : ℝ := α/((∑ j, (c j:ℝ)^2)*Real.pi^2*Q^2)
  have hC := bezout_energy_pos (fun j => (q j:ℤ)) c hbezout
  have hrate : 0 < rate := by dsimp [rate]; positivity
  let rate' : ℝ := min rate (2/Real.pi^2)
  have hrate' : 0 < rate' := by dsimp [rate']; positivity
  let B : ℝ := M*Real.exp (K₀*T^2/2)+M
  have hB : 0 ≤ B := by dsimp [B]; positivity
  have hgauss (y : ℝ) :
      Real.exp (-rate*y^2) ≤ Real.exp (-rate'*y^2) ∧
        Real.exp (-(2/Real.pi^2)*y^2) ≤ Real.exp (-rate'*y^2) := by
    constructor <;> apply Real.exp_le_exp.mpr
    · have hh := min_le_left rate (2/Real.pi^2)
      dsimp [rate']
      nlinarith [mul_le_mul_of_nonneg_right hh (sq_nonneg y)]
    · have hh := min_le_right rate (2/Real.pi^2)
      dsimp [rate']
      nlinarith [mul_le_mul_of_nonneg_right hh (sq_nonneg y)]
  have hdom (k : ℕ) (y : ℝ) :
      |residualCellWindow (fun i => (q (label k i):ℝ)) (d k) (A k) (s k) l ρ K y -
        residualWindowModel (d k) (residualPeak (A k) l) K y| ≤ B*Real.exp (-rate'*y^2) := by
    have hw := residualCellWindow_bound (label k) q c hqOdd hbezout hα hQ (hApos k)
      hK₀ hT hM (hfreq k) (hq k) (d k) (hEbound k) (hscale k) l K (hTab k) (hKb k) y
    have hm := residualWindowModel_bound (d k) (residualPeak (A k) l) M K hM (hKcenter k) y
    have hw' := mul_le_mul_of_nonneg_left (hgauss y).1
      (show 0 ≤ M*Real.exp (K₀*T^2/2) by positivity)
    have hm' := mul_le_mul_of_nonneg_left (hgauss y).2 hM
    have htri := abs_sub_le
      (residualCellWindow (fun i => (q (label k i):ℝ)) (d k) (A k) (s k) l ρ K y) 0
      (residualWindowModel (d k) (residualPeak (A k) l) K y)
    simp only [sub_zero,zero_sub,abs_neg] at htri
    dsimp [rate,B] at *
    nlinarith
  have hh := tendsto_integral_of_dominated_convergence (μ := volume) (f := fun _ : ℝ => (0:ℝ))
    (fun y : ℝ => B*Real.exp (-rate'*y^2))
    (F := fun k y => |residualCellWindow (fun i => (q (label k i):ℝ)) (d k) (A k) (s k) l ρ K y -
        residualWindowModel (d k) (residualPeak (A k) l) K y|)
    (fun k => ((continuous_abs : Continuous (fun x : ℝ => |x|)).measurable.comp
      ((residualCellWindow_measurable _ _ _ _ _ _ _ hKmeas).sub
        (residualWindowModel_continuous _ _ _).measurable)).aestronglyMeasurable)
    ((integrable_exp_neg_mul_sq hrate').const_mul B)
    (fun k => Eventually.of_forall (fun y => by simpa only [Real.norm_eq_abs,abs_abs] using hdom k y))
    (Eventually.of_forall (fun y => by
      have hp := (residualCellWindow_pointwise N (fun k i => (q (label k i):ℝ)) d A s D hA₀ l hρ
        hq hd horth hA hs hD hE hscale K hKcont y).abs
      simpa only [abs_zero] using hp))
  simpa only [integral_zero] using hh

end NeuralGeneralization.OnlineLowerTanh
