import NeuralGeneralization.OnlineLowerTanhCodeColumns
import NeuralGeneralization.OnlineLowerTanhLaplaceWindow
import NeuralGeneralization.OnlineLowerTanhCodeWeightedHolder

/-! # Uniform Laplace moments for balanced rail columns -/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma even_power_half_rpow (x : ℝ) (hx : 0≤x) (p r : ℕ) :
    (x^(2*r))^((p:ℝ)/2) = x^(p*r) := by
  rw [← Real.rpow_natCast_mul hx]
  have he : ((2*r:ℕ):ℝ)*((p:ℝ)/2)=((p*r:ℕ):ℝ) := by push_cast; ring
  rw [he,Real.rpow_natCast]

theorem columnPair_half_power_bound (p r : ℕ) (hp : 2≤p) (hr : 1≤r) (a b t : ℝ) :
    (columnPair (2*r) a b t)^((p:ℝ)/2) ≤
      (|Real.sin ((a+b)*t)|^(p*r)+|Real.sin ((a-b)*t)|^(p*r))/2 := by
  have hq : (1:ℝ) ≤ (p:ℝ)/2 := by
    have hh : (2:ℝ) ≤ (p:ℝ) := by exact_mod_cast hp
    linarith
  have h := columnPair_rpow_bound (2*r) (by exact even_two_mul r) (by omega)
    a b t ((p:ℝ)/2) hq
  simpa only [even_power_half_rpow _ (abs_nonneg _)] using h

theorem columnPair_half_laplace_integrable (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (a b c : ℝ) (hc : 0<c) :
    IntegrableOn (fun t => Real.exp (-c*t)*(columnPair (2*r) a b t)^((p:ℝ)/2)) (Ioi 0) := by
  have hi := ((integrable_laplace_absSinePower (p*r) c (a+b) hc).add
    (integrable_laplace_absSinePower (p*r) c (a-b) hc)).div_const 2
  apply hi.mono'
  · exact (by
      unfold columnPair
      fun_prop : Measurable (fun t : ℝ =>
        Real.exp (-c*t)*(columnPair (2*r) a b t)^((p:ℝ)/2))).aestronglyMeasurable
  · exact Filter.Eventually.of_forall (fun t => by
      simp only [Real.norm_eq_abs]
      rw [abs_of_nonneg (mul_nonneg (Real.exp_pos _).le (Real.rpow_nonneg (columnPair_nonneg _ _ _ _) _))]
      have hh := mul_le_mul_of_nonneg_left (columnPair_half_power_bound p r hp hr a b t)
        (Real.exp_pos (-c*t)).le
      simp only [Pi.add_apply]
      nlinarith [hh])

/-- The same `1/sqrt(degree)` scale holds uniformly for every two rail
frequencies, including arbitrarily large and vanishing weights. -/
theorem columnPair_half_laplace_bound (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (a b c : ℝ) (hc : 0<c) :
    Real.sqrt ((p*r:ℕ):ℝ)*
      (∫ t : ℝ in Ioi 0, Real.exp (-c*t)*(columnPair (2*r) a b t)^((p:ℝ)/2)) ≤
        Real.pi/c := by
  have hia := integrable_laplace_absSinePower (p*r) c (a+b) hc
  have hib := integrable_laplace_absSinePower (p*r) c (a-b) hc
  have hiab := (hia.add hib).div_const 2
  have hci := columnPair_half_laplace_integrable p r hp hr a b c hc
  have him := integral_mono hci hiab (fun t => by
    have hh := mul_le_mul_of_nonneg_left (columnPair_half_power_bound p r hp hr a b t)
      (Real.exp_pos (-c*t)).le
    simp only [Pi.add_apply]
    nlinarith [hh])
  simp only [Pi.add_apply] at him
  rw [integral_div,integral_add hia hib] at him
  have hN : 1≤p*r := by nlinarith
  have ha := laplace_abs_sqrt_bound (p*r) hN c (a+b) hc
  have hb := laplace_abs_sqrt_bound (p*r) hN c (a-b) hc
  have hm := mul_le_mul_of_nonneg_left him (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  change Real.sqrt ((p*r:ℕ):ℝ)*(∫ t : ℝ in Ioi 0,
      Real.exp (-c*t)*|Real.sin ((a+b)*t)|^(p*r)) ≤ Real.pi/c at ha
  change Real.sqrt ((p*r:ℕ):ℝ)*(∫ t : ℝ in Ioi 0,
      Real.exp (-c*t)*|Real.sin ((a-b)*t)|^(p*r)) ≤ Real.pi/c at hb
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
