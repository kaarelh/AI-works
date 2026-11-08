import NeuralGeneralization.OnlineLowerCosineCutoff
import NeuralGeneralization.OnlineLowerGaussianFirstMoment

/-! Integration of a kernel Taylor expansion against the quantitative cosine saddle. -/
noncomputable section
open scoped Topology
open MeasureTheory Filter
namespace NeuralGeneralization.OnlineLowerTanh

def saddleTaylorMajorant (y:ℝ) : ℝ :=
  (y^2+2*(y^4+16*y^2)*(1+y^2))*Real.exp (-y^2/8)

lemma saddleTaylorMajorant_nonneg (y:ℝ) : 0≤saddleTaylorMajorant y := by
  unfold saddleTaylorMajorant
  positivity

lemma saddleTaylorMajorant_integrable : Integrable saddleTaylorMajorant := by
  have h2:=integrable_natPower_gaussian 2 (1/8) (by norm_num)
  have h4:=integrable_natPower_gaussian 4 (1/8) (by norm_num)
  have h6:=integrable_natPower_gaussian 6 (1/8) (by norm_num)
  convert! ((h2.const_mul 33).add (h4.const_mul 34)).add (h6.const_mul 2) using 1
  funext y
  change (y^2+2*(y^4+16*y^2)*(1+y^2))*Real.exp (-y^2/8)=
    (33*(y^2*Real.exp (-(1/8:ℝ)*y^2))+34*(y^4*Real.exp (-(1/8:ℝ)*y^2)))+
      2*(y^6*Real.exp (-(1/8:ℝ)*y^2))
  rw [show -y^2/8=-(1/8:ℝ)*y^2 by ring]
  ring

/-- A first-order Taylor term is retained explicitly, so the remaining error
really is O(1/n), even when the oscillatory bias grows with n. -/
lemma saddle_kernel_pointwise_error (n:ℕ) (hn:0<n) (a p ρ s y k₀ k₁ H M:ℝ)
    (ha:0<a) (hgap:1/4≤a*(p-ρ)) (hM:0≤M) (hs:0≤s) (hs1:s≤1)
    (hs2:s^2≤1/(n:ℝ)) (h0:|k₀|≤M) (h1:|k₁|≤M)
    (ht:cutoffCosinePower n a p ρ y≠0 → |H-(k₀+s*k₁*y)|≤M*s^2*y^2) :
    |cutoffCosinePower n a p ρ y*H-
       Real.exp (-y^2/2)*(k₀+s*k₁*y)|≤M/(n:ℝ)*saddleTaylorMajorant y := by
  let F:=cutoffCosinePower n a p ρ y
  let g:=Real.exp (-y^2/2)
  let g₈:=Real.exp (-y^2/8)
  let D:=y^4+16*y^2
  have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
  have hF0:0≤F := cutoffCosinePower_nonneg n a p ρ y
  have hF:F≤g₈ := cutoffCosinePower_bound n hn a p ρ y
  have hFg:|F-g|≤D*g₈/(n:ℝ) := cutoffCosinePower_error n hn a p ρ y ha hgap
  have hlin:|k₀+s*k₁*y|≤2*M*(1+y^2) := by
    have hy:|y|≤1+y^2 := by nlinarith [sq_nonneg (|y|-1),sq_abs y]
    calc
      _ ≤ |k₀|+|s*k₁*y| := abs_add_le _ _
      _ = |k₀|+s*|k₁| *|y| := by rw [abs_mul,abs_mul,abs_of_nonneg hs]
      _ ≤ M+M*|y| := by
        have hh:s*|k₁|≤M := (mul_le_mul hs1 h1 (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
        nlinarith [mul_le_mul_of_nonneg_right hh (abs_nonneg y)]
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_left hy hM,mul_nonneg hM (sq_nonneg y)]
  have herr:F*|H-(k₀+s*k₁*y)|≤M/(n:ℝ)*y^2*g₈ := by
    by_cases hzero:F=0
    · rw [hzero,zero_mul]; positivity
    · have hh:=ht hzero
      calc
        _ ≤ g₈*(M*s^2*y^2) := mul_le_mul hF hh (abs_nonneg _) (by dsimp [g₈]; positivity)
        _ ≤ g₈*(M*(1/(n:ℝ))*y^2) := by
          apply mul_le_mul_of_nonneg_left _ (by dsimp [g₈]; positivity)
          exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hs2 hM) (sq_nonneg y)
        _ = _ := by ring
  have he:F*H-g*(k₀+s*k₁*y)=F*(H-(k₀+s*k₁*y))+(F-g)*(k₀+s*k₁*y) := by ring
  change |F*H-g*(k₀+s*k₁*y)|≤_
  rw [he]
  calc
    _ ≤ |F*(H-(k₀+s*k₁*y))|+|(F-g)*(k₀+s*k₁*y)| := abs_add_le _ _
    _ = F*|H-(k₀+s*k₁*y)|+|F-g| *|k₀+s*k₁*y| := by rw [abs_mul,abs_mul,abs_of_nonneg hF0]
    _ ≤ M/(n:ℝ)*y^2*g₈+(D*g₈/(n:ℝ))*(2*M*(1+y^2)) :=
      add_le_add herr (mul_le_mul hFg hlin (abs_nonneg _) (by dsimp [D,g₈]; positivity))
    _ = _ := by dsimp [D,g₈,saddleTaylorMajorant]; ring

lemma saddle_error_integral_bound (E:ℝ→ℝ) (hE:AEStronglyMeasurable E)
    (c ξ θ:ℝ) (hc:0≤c) (hb:∀y,|E y|≤c*saddleTaylorMajorant y) :
    Integrable (fun y:ℝ=>E y*Real.sin (ξ*y+θ)) ∧
      |∫y:ℝ,E y*Real.sin (ξ*y+θ)|≤c*∫y:ℝ,saddleTaylorMajorant y := by
  have hm:Integrable (fun y:ℝ=>c*saddleTaylorMajorant y) :=
    saddleTaylorMajorant_integrable.const_mul c
  have hpoint (y:ℝ) : |E y*Real.sin (ξ*y+θ)|≤c*saddleTaylorMajorant y := by
    rw [abs_mul]
    exact (mul_le_of_le_one_right (abs_nonneg _) (Real.abs_sin_le_one _)).trans (hb y)
  have hi:Integrable (fun y:ℝ=>E y*Real.sin (ξ*y+θ)) := hm.mono'
    (hE.mul (by fun_prop)) (Eventually.of_forall (fun y=>by
      simpa only [Real.norm_eq_abs] using hpoint y))
  refine ⟨hi,?_⟩
  calc
    _ ≤ ∫y:ℝ,|E y*Real.sin (ξ*y+θ)| := abs_integral_le_integral_abs
    _ ≤ ∫y:ℝ,c*saddleTaylorMajorant y := integral_mono hi.abs hm hpoint
    _ = _ := integral_const_mul _ _

/-- Quantitative cell integral, with the complete first-order kernel term.
The frequency ξ is arbitrary: no bounded-bias assumption is hidden here. -/
theorem saddle_kernel_oscillatory_error (n:ℕ) (hn:0<n)
    (a p ρ s k₀ k₁ M ξ θ:ℝ) (H:ℝ→ℝ) (hH:Measurable H)
    (ha:0<a) (hgap:1/4≤a*(p-ρ)) (hM:0≤M) (hs:0≤s) (hs1:s≤1)
    (hs2:s^2≤1/(n:ℝ)) (h0:|k₀|≤M) (h1:|k₁|≤M)
    (ht:∀y,cutoffCosinePower n a p ρ y≠0 → |H y-(k₀+s*k₁*y)|≤M*s^2*y^2) :
    |(∫y:ℝ,cutoffCosinePower n a p ρ y*H y*Real.sin (ξ*y+θ))-
      (k₀*Real.sqrt (2*Real.pi)*Real.exp (-ξ^2/2)*Real.sin θ+
       s*k₁*Real.sqrt (2*Real.pi)*ξ*Real.exp (-ξ^2/2)*Real.cos θ)|≤
      M/(n:ℝ)*∫y:ℝ,saddleTaylorMajorant y := by
  let F:=cutoffCosinePower n a p ρ
  let model:ℝ→ℝ:=fun y=>Real.exp (-y^2/2)*(k₀+s*k₁*y)
  let E:ℝ→ℝ:=fun y=>F y*H y-model y
  have hEm:AEStronglyMeasurable E := by dsimp [E,F,model]; fun_prop
  have hEbound (y:ℝ) : |E y|≤M/(n:ℝ)*saddleTaylorMajorant y :=
    saddle_kernel_pointwise_error n hn a p ρ s y k₀ k₁ (H y) M ha hgap hM hs hs1 hs2 h0 h1 (ht y)
  obtain ⟨hEi,hEb⟩:=saddle_error_integral_bound E hEm (M/(n:ℝ)) ξ θ (by positivity) hEbound
  have hmodelfun:(fun y:ℝ=>model y*Real.sin (ξ*y+θ))=
      (fun y:ℝ=>k₀*(Real.exp (-y^2/2)*Real.sin (ξ*y+θ))+
        (s*k₁)*(y*Real.exp (-y^2/2)*Real.sin (ξ*y+θ))) := by
    funext y; dsimp [model]; ring
  have hmodeli:Integrable (fun y:ℝ=>model y*Real.sin (ξ*y+θ)) := by
    rw [hmodelfun]
    exact ((gaussian_sine_integrable ξ θ).const_mul k₀).add
      ((gaussian_first_sine_integrable ξ θ).const_mul (s*k₁))
  have hmodelint:(∫y:ℝ,model y*Real.sin (ξ*y+θ))=
      k₀*Real.sqrt (2*Real.pi)*Real.exp (-ξ^2/2)*Real.sin θ+
       s*k₁*Real.sqrt (2*Real.pi)*ξ*Real.exp (-ξ^2/2)*Real.cos θ := by
    rw [hmodelfun,integral_add ((gaussian_sine_integrable ξ θ).const_mul k₀)
      ((gaussian_first_sine_integrable ξ θ).const_mul (s*k₁)),integral_const_mul,
      integral_const_mul,gaussian_sine_integral,gaussian_first_sine_integral]
    ring
  have hactuali:Integrable (fun y:ℝ=>F y*H y*Real.sin (ξ*y+θ)) := by
    convert! hEi.add hmodeli using 1
    funext y
    change F y*H y*Real.sin (ξ*y+θ)=E y*Real.sin (ξ*y+θ)+model y*Real.sin (ξ*y+θ)
    dsimp [E]
    ring
  have heint:(∫y:ℝ,E y*Real.sin (ξ*y+θ))=
      (∫y:ℝ,F y*H y*Real.sin (ξ*y+θ))-(∫y:ℝ,model y*Real.sin (ξ*y+θ)) := by
    rw [←integral_sub hactuali hmodeli]
    apply integral_congr_ae
    filter_upwards [] with y
    dsimp [E]
    ring
  rw [heint,hmodelint] at hEb
  exact hEb

end NeuralGeneralization.OnlineLowerTanh
