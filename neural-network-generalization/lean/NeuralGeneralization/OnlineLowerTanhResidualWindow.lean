import NeuralGeneralization.OnlineLowerTanhResidualSaddle
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! # Dominated Gaussian saddle windows for varying residual arrays -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma cosine_product_gaussian_domination {ι : Type*} [Fintype ι]
    (z : ι → ℝ) (hz : ∀ i, |z i| ≤ Real.pi/2) :
    |∏ i, Real.cos (z i)| ≤ Real.exp (-(2/Real.pi^2)*∑ i, (z i)^2) := by
  rw [Finset.abs_prod]
  calc
    _ ≤ ∏ i, Real.exp (-(2/Real.pi^2*(z i)^2)) := by
      apply Finset.prod_le_prod (fun i _ => abs_nonneg _)
      intro i _
      rw [abs_of_nonneg (Real.cos_nonneg_of_mem_Icc (abs_le.mp (hz i)))]
      exact cos_le_exp_square ((hz i).trans (by linarith [Real.pi_pos]))
    _ = _ := by
      rw [← Real.exp_sum]
      simp only [neg_mul, Finset.sum_neg_distrib, ← Finset.mul_sum]

lemma residual_saddle_gaussian_domination {ι : Type*} [Fintype ι]
    (q d : ι → ℝ) (A s t y : ℝ)
    (horth : ∑ i, q i*d i = 0)
    (hscale : A^2*(∑ i, (q i)^2)*s^2 = 1)
    (hz : ∀ i, |A*q i*(y*s)+d i*(t+y*s)| ≤ Real.pi/2) :
    |∏ i, Real.cos (A*q i*(y*s)+d i*(t+y*s))| ≤
      Real.exp (-(2/Real.pi^2)*y^2) := by
  apply (cosine_product_gaussian_domination _ hz).trans
  apply Real.exp_le_exp.mpr
  rw [residual_quadratic_identity _ _ _ _ _ horth]
  have he : A^2*(∑ i, (q i)^2)*(y*s)^2 = y^2 := by
    calc
      _ = y^2*(A^2*(∑ i, (q i)^2)*s^2) := by ring
      _ = _ := by rw [hscale]; ring
  rw [he]
  have hE : 0 ≤ ∑ i, (d i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hc : 0 < 2/Real.pi^2 := by positivity
  nlinarith [mul_nonneg hE (sq_nonneg (t+y*s))]

/-- The windowed cosine product is measurable even though the finite array
has a different dimension at each sequence index. -/
def residualWindow {n : ℕ} (q d : Fin n → ℝ) (A s t δ : ℝ) (K : ℝ → ℝ) (y : ℝ) : ℝ :=
  if |y*s| ≤ δ then (∏ i, Real.cos (A*q i*(y*s)+d i*(t+y*s)))*K (t+y*s) else 0

def residualWindowModel {n : ℕ} (d : Fin n → ℝ) (t : ℝ) (K : ℝ → ℝ) (y : ℝ) : ℝ :=
  Real.exp (-y^2/2)*Real.exp (-(∑ i, (d i)^2)*t^2/2)*K t

lemma residualWindow_measurable {n : ℕ} (q d : Fin n → ℝ) (A s t δ : ℝ)
    (K : ℝ → ℝ) (hK : Measurable K) : Measurable (residualWindow q d A s t δ K) := by
  unfold residualWindow
  apply Measurable.ite
  · exact measurableSet_le (by fun_prop) measurable_const
  · exact (by fun_prop : Measurable (fun y : ℝ => ∏ i, Real.cos (A*q i*(y*s)+d i*(t+y*s)))).mul
      (hK.comp (by fun_prop))
  · exact measurable_const

lemma residualWindowModel_continuous {n : ℕ} (d : Fin n → ℝ) (t : ℝ) (K : ℝ → ℝ) :
    Continuous (residualWindowModel d t K) := by unfold residualWindowModel; fun_prop

/-- A pointwise local limit with the original, varying lattice centers and
variance scale preserved. -/
theorem residualWindow_pointwise (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A s t D : ℕ → ℝ)
    {Q E t₀ δ : ℝ} (hδ : 0 < δ)
    (hq : ∀ k i, |q k i| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hAs : Tendsto (fun k => A k*s k) atTop (𝓝 0))
    (hs : Tendsto s atTop (𝓝 0)) (ht : Tendsto t atTop (𝓝 t₀))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hscale : ∀ k, (A k)^2*(∑ i, (q k i)^2)*(s k)^2 = 1)
    (K : ℝ → ℝ) (hK : ContinuousAt K t₀) (y : ℝ) :
    Tendsto (fun k => residualWindow (q k) (d k) (A k) (s k) (t k) δ K y -
      residualWindowModel (d k) (t k) K y) atTop (𝓝 0) := by
  have hys : Tendsto (fun k => y*s k) atTop (𝓝 0) := by simpa using hs.const_mul y
  have hprod := residual_cosine_product_limit N q d A (fun k => y*s k) t D
    (Q := max Q 0) (le_max_right _ _) (fun k i => (hq k i).trans (le_max_left _ _)) hd horth
    (by simpa only [mul_zero, mul_left_comm, mul_assoc] using hAs.const_mul y)
    hys ht hD hE
    (S := y^2) (by
      have he (k : ℕ) : (A k)^2*(∑ i, (q k i)^2)*(y*s k)^2 = y^2 := by
        calc
          _ = y^2*((A k)^2*(∑ i, (q k i)^2)*(s k)^2) := by ring
          _ = _ := by rw [hscale]; ring
      simp_rw [he]
      exact tendsto_const_nhds)
  have hphase : Tendsto (fun k => t k+y*s k) atTop (𝓝 t₀) := by simpa using ht.add hys
  have hwin : Tendsto (fun k => residualWindow (q k) (d k) (A k) (s k) (t k) δ K y)
      atTop (𝓝 (Real.exp (-(y^2+E*t₀^2)/2)*K t₀)) := by
    apply (hprod.mul (hK.tendsto.comp hphase)).congr'
    filter_upwards [hys.abs.eventually (gt_mem_nhds (by simpa using hδ))] with k hk
    simp only [residualWindow, if_pos hk.le, Function.comp_apply]
  have hmod : Tendsto (fun k => residualWindowModel (d k) (t k) K y)
      atTop (𝓝 (Real.exp (-y^2/2)*Real.exp (-E*t₀^2/2)*K t₀)) := by
    unfold residualWindowModel
    simpa only [Function.comp_apply, neg_mul] using
      ((tendsto_const_nhds (x := Real.exp (-y^2/2))).mul
        (Real.continuous_exp.continuousAt.tendsto.comp
          ((hE.mul (ht.pow 2)).neg.div_const 2))).mul (hK.tendsto.comp ht)
  have he : Real.exp (-(y^2+E*t₀^2)/2)*K t₀ =
      Real.exp (-y^2/2)*Real.exp (-E*t₀^2/2)*K t₀ := by
    rw [← Real.exp_add]
    congr 2
    ring
  rw [he] at hwin
  simpa using hwin.sub hmod

lemma residualWindow_bound {n : ℕ} (q d : Fin n → ℝ) (A s t δ M : ℝ) (K : ℝ → ℝ)
    (hM : 0 ≤ M) (horth : ∑ i, q i*d i = 0)
    (hscale : A^2*(∑ i, (q i)^2)*s^2 = 1)
    (hangle : ∀ y, |y*s| ≤ δ → ∀ i, |A*q i*(y*s)+d i*(t+y*s)| ≤ Real.pi/2)
    (hK : ∀ y, |y*s| ≤ δ → |K (t+y*s)| ≤ M) (y : ℝ) :
    |residualWindow q d A s t δ K y| ≤ M*Real.exp (-(2/Real.pi^2)*y^2) := by
  unfold residualWindow
  split_ifs with hy
  · rw [abs_mul]
    calc
      _ ≤ Real.exp (-(2/Real.pi^2)*y^2)*M :=
        mul_le_mul (residual_saddle_gaussian_domination q d A s t y horth hscale (hangle y hy))
          (hK y hy) (abs_nonneg _) (Real.exp_pos _).le
      _ = _ := mul_comm _ _
  · simp only [abs_zero]
    positivity

lemma residualWindowModel_bound {n : ℕ} (d : Fin n → ℝ) (t M : ℝ) (K : ℝ → ℝ)
    (hM : 0 ≤ M) (hK : |K t| ≤ M) (y : ℝ) :
    |residualWindowModel d t K y| ≤ M*Real.exp (-(2/Real.pi^2)*y^2) := by
  have hE : 0 ≤ ∑ i, (d i)^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have hdecay : Real.exp (-(∑ i, (d i)^2)*t^2/2) ≤ 1 := by
    apply Real.exp_le_one_iff.mpr
    have hh := mul_nonneg hE (sq_nonneg t)
    nlinarith
  have hc : 2/Real.pi^2 ≤ (1/2 : ℝ) := by
    apply (div_le_iff₀ (by positivity : 0 < Real.pi^2)).mpr
    nlinarith [Real.pi_gt_three]
  have hexp : Real.exp (-y^2/2) ≤ Real.exp (-(2/Real.pi^2)*y^2) := by
    apply Real.exp_le_exp.mpr
    nlinarith [mul_le_mul_of_nonneg_right hc (sq_nonneg y)]
  unfold residualWindowModel
  rw [abs_mul, abs_mul, abs_of_pos (Real.exp_pos _), abs_of_pos (Real.exp_pos _)]
  calc
    _ ≤ (Real.exp (-y^2/2)*1)*M :=
      mul_le_mul (mul_le_mul_of_nonneg_left hdecay (Real.exp_pos _).le) hK
        (abs_nonneg _) (by positivity)
    _ ≤ _ := by simpa only [mul_one, mul_comm M] using mul_le_mul_of_nonneg_right hexp hM

/-- Local L¹ saddle convergence, retaining the varying center and residual
energy in the comparison kernel. Consequently multiplication by any external
unit-modulus oscillation costs nothing in the error bound. -/
theorem residualWindow_L1 (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A s t D : ℕ → ℝ)
    {Q E t₀ δ M : ℝ} (hδ : 0 < δ) (hM : 0 ≤ M)
    (hq : ∀ k i, |q k i| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hAs : Tendsto (fun k => A k*s k) atTop (𝓝 0))
    (hs : Tendsto s atTop (𝓝 0)) (ht : Tendsto t atTop (𝓝 t₀))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hscale : ∀ k, (A k)^2*(∑ i, (q k i)^2)*(s k)^2 = 1)
    (K : ℝ → ℝ) (hKmeas : Measurable K) (hKcont : ContinuousAt K t₀)
    (hangle : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ → ∀ i,
      |A k*q k i*(y*s k)+d k i*(t k+y*s k)| ≤ Real.pi/2)
    (hKbound : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ → |K (t k+y*s k)| ≤ M) :
    Tendsto (fun k => ∫ y : ℝ,
      |residualWindow (q k) (d k) (A k) (s k) (t k) δ K y -
        residualWindowModel (d k) (t k) K y|) atTop (𝓝 0) := by
  have hint : Integrable (fun y : ℝ => (2*M)*Real.exp (-(2/Real.pi^2)*y^2)) :=
    (integrable_exp_neg_mul_sq (by positivity : 0 < 2/Real.pi^2)).const_mul (2*M)
  have hdct := tendsto_integral_filter_of_dominated_convergence
    (μ := volume) (f := fun _ : ℝ => (0:ℝ))
    (fun y : ℝ => (2*M)*Real.exp (-(2/Real.pi^2)*y^2))
    (F := fun k y => |residualWindow (q k) (d k) (A k) (s k) (t k) δ K y -
        residualWindowModel (d k) (t k) K y|)
    (Eventually.of_forall (fun k =>
      ((continuous_abs : Continuous (fun x : ℝ => |x|)).measurable.comp
        ((residualWindow_measurable (q k) (d k) (A k) (s k) (t k) δ K hKmeas).sub
          (residualWindowModel_continuous (d k) (t k) K).measurable)).aestronglyMeasurable))
    (by
      filter_upwards [hangle,hKbound] with k hangle hKb
      apply Eventually.of_forall
      intro y
      rw [Real.norm_eq_abs, abs_abs]
      have hKt : |K (t k)| ≤ M := by simpa using hKb 0 (by simpa using hδ.le)
      have hw := residualWindow_bound (q k) (d k) (A k) (s k) (t k) δ M K hM
        (horth k) (hscale k) hangle hKb y
      have hm := residualWindowModel_bound (d k) (t k) M K hM hKt y
      have htri := abs_sub_le (residualWindow (q k) (d k) (A k) (s k) (t k) δ K y) 0
        (residualWindowModel (d k) (t k) K y)
      simp only [sub_zero, zero_sub, abs_neg] at htri
      exact htri.trans (by linarith))
    hint
    (Eventually.of_forall (fun y => by
      have hh := (residualWindow_pointwise N q d A s t D hδ hq hd horth hAs hs ht hD hE hscale K hKcont y).abs
      simpa only [abs_zero] using hh))
  simpa only [integral_zero] using hdct

lemma residual_angle_bound {A q d x t Q D δ : ℝ}
    (hq : |q| ≤ Q) (hd : |d| ≤ D) (hD : 0 ≤ D) (hx : |x| ≤ δ) :
    |A*q*x+d*(t+x)| ≤ |A| *Q*δ+D*(|t|+δ) := by
  have hQ : 0 ≤ Q := (abs_nonneg q).trans hq
  calc
    _ ≤ |A*q*x|+|d*(t+x)| := abs_add_le _ _
    _ = |A| * |q| * |x|+|d| * |t+x| := by simp only [abs_mul]
    _ ≤ (|A| *Q)*δ+D*(|t|+δ) := add_le_add
      (mul_le_mul (mul_le_mul_of_nonneg_left hq (abs_nonneg A)) hx (abs_nonneg x)
        (mul_nonneg (abs_nonneg A) hQ))
      (mul_le_mul hd ((abs_add_le t x).trans (by linarith)) (abs_nonneg _) hD)

/-- Continuity at one peak and a bounded lattice alphabet suffice to choose
an actual window with all of the domination estimates proved automatically. -/
theorem residualWindow_exists_L1 (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A s t D : ℕ → ℝ)
    {Q E A₀ t₀ : ℝ} (hQ : 0 ≤ Q)
    (hq : ∀ k i, |q k i| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (hDnonneg : ∀ k, 0 ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hA : Tendsto A atTop (𝓝 A₀))
    (hs : Tendsto s atTop (𝓝 0)) (ht : Tendsto t atTop (𝓝 t₀))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hscale : ∀ k, (A k)^2*(∑ i, (q k i)^2)*(s k)^2 = 1)
    (K : ℝ → ℝ) (hKmeas : Measurable K) (hKcont : ContinuousAt K t₀) :
    ∃ δ > 0, ∀ δ' : ℝ, 0 < δ' → δ' ≤ δ →
      Tendsto (fun k => ∫ y : ℝ,
        |residualWindow (q k) (d k) (A k) (s k) (t k) δ' K y -
          residualWindowModel (d k) (t k) K y|) atTop (𝓝 0) := by
  rcases Metric.continuousAt_iff.mp hKcont 1 (by norm_num) with ⟨ε,hε,hKε⟩
  let δ : ℝ := min (ε/4) (Real.pi/(8*(|A₀| *Q+1)))
  have hδ : 0 < δ := by dsimp [δ]; positivity
  refine ⟨δ,hδ,?_⟩
  intro δ' hδ' hδ'δ
  have hδε : δ' ≤ ε/4 := hδ'δ.trans (min_le_left _ _)
  have hδπ : δ' ≤ Real.pi/(8*(|A₀| *Q+1)) := hδ'δ.trans (min_le_right _ _)
  have hlimit : |A₀| *Q*δ' < Real.pi/2 := by
    have hdpos : 0 < 8*(|A₀| *Q+1) := by positivity
    have hmul := (le_div_iff₀ hdpos).mp hδπ
    nlinarith [Real.pi_pos]
  have hlim : Tendsto (fun k => |A k| *Q*δ'+D k*(|t k|+δ')) atTop
      (𝓝 (|A₀| *Q*δ')) := by
    convert ((hA.abs.mul_const Q).mul_const δ').add
      (hD.mul (ht.abs.add_const δ')) using 1 <;> simp
  have hangles : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ' → ∀ i,
      |A k*q k i*(y*s k)+d k i*(t k+y*s k)| ≤ Real.pi/2 := by
    filter_upwards [hlim.eventually (gt_mem_nhds hlimit)] with k hk y hy i
    exact (residual_angle_bound (hq k i) (hd k i) (hDnonneg k) hy).trans hk.le
  have htclose : ∀ᶠ k in atTop, |t k-t₀| < ε/4 := by
    have hh := (ht.sub_const t₀).abs
    simp only [sub_self,abs_zero] at hh
    exact hh.eventually (gt_mem_nhds (by positivity))
  have hKb : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ' → |K (t k+y*s k)| ≤ |K t₀|+1 := by
    filter_upwards [htclose] with k hk y hy
    have hdist : dist (t k+y*s k) t₀ < ε := by
      rw [Real.dist_eq]
      have he : t k+y*s k-t₀ = (t k-t₀)+y*s k := by ring
      rw [he]
      exact (abs_add_le _ _).trans_lt (by linarith)
    have hh := hKε hdist
    rw [Real.dist_eq] at hh
    have htri := abs_add_le (K (t k+y*s k)-K t₀) (K t₀)
    simp only [sub_add_cancel] at htri
    linarith
  exact residualWindow_L1 N q d A s t D hδ' (by positivity) hq hd horth
    (by simpa using hA.mul hs) hs ht hD hE hscale K hKmeas hKcont hangles hKb

end NeuralGeneralization.OnlineLowerTanh
