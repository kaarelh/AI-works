import NeuralGeneralization.OnlineLowerTanhGlobalSaddle
import NeuralGeneralization.OnlineLowerTanhF0Bounds
import NeuralGeneralization.OnlineLowerTanhResidualBalanced
import NeuralGeneralization.OnlineLowerGaussianBiasCompactness

/-! Actual equal-bulk central candidates and the uniform bound on a maximizing bias. -/
noncomputable section
open scoped Topology
namespace NeuralGeneralization.OnlineLowerTanh

def bulkAmplitude (a:ℝ) : ℝ := Real.sqrt (2/Real.pi)*scalarF0 a
def bulkCentralBias (n:ℕ) (a:ℝ) : ℝ := if n%2=1 then 0 else a

lemma gaussianLeadingScale_pos : 0<Real.sqrt (2/Real.pi) := by positivity
lemma gaussianLeadingScale_le_one : Real.sqrt (2/Real.pi)≤1 := by
  apply Real.sqrt_le_one.mpr
  exact (div_le_one Real.pi_pos).mpr (by linarith [Real.pi_gt_three])

lemma bulkAmplitude_bounds (a:ℝ) (ha:1≤a) :
    Real.sqrt (2/Real.pi)/2≤bulkAmplitude a ∧ bulkAmplitude a≤1 := by
  have hl:=mul_le_mul_of_nonneg_left (scalarF0_ge_half a ha) (Real.sqrt_nonneg (2/Real.pi))
  have hu:=mul_le_mul_of_nonneg_left (scalarF0_le_one a (by linarith)) (Real.sqrt_nonneg (2/Real.pi))
  dsimp [bulkAmplitude]
  constructor <;> nlinarith [gaussianLeadingScale_le_one]

lemma bulkCentralBias_bounds (n:ℕ) (a:ℝ) (ha:0≤a) :
    0≤bulkCentralBias n a ∧ bulkCentralBias n a≤a ∧
      bulkCentralBias n a+(n%2:ℕ)*a=a := by
  unfold bulkCentralBias
  split_ifs with h
  · simp [h,ha]
  · have hz:n%2=0 := by omega
    simp [hz,ha]

lemma balancedLeading_abs_normalized {n:ℕ} (hn:0<n) {a:ℝ} (ha:0<a) (B:ℝ) :
    Real.sqrt (n:ℝ)*|residualLeading (fun _:Fin n=>1) (fun _=>0) a B|=
      Real.sqrt (2/Real.pi)*Real.exp (-B^2/(2*a^2*(n:ℝ)))*
        |periodicFourierResponse a (B+(n%2:ℕ)*a)| := by
  have h:=congrArg abs (balancedLeading_normalized hn ha B)
  simpa only [abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),Real.abs_exp] using h

lemma balancedLeading_central {n:ℕ} (hn:0<n) {a:ℝ} (ha:1≤a) :
    Real.sqrt (n:ℝ)*|residualLeading (fun _:Fin n=>1) (fun _=>0) a (bulkCentralBias n a)|=
      bulkAmplitude a*Real.exp (-(bulkCentralBias n a)^2/(2*a^2*(n:ℝ))) := by
  rw [balancedLeading_abs_normalized hn (by linarith), (bulkCentralBias_bounds n a (by linarith)).2.2]
  change Real.sqrt (2/Real.pi)*Real.exp _*|periodicFourierMaximum a|=_
  rw [periodicFourierMaximum_eq_scalarF0 (a:=a) (by linarith),abs_of_nonneg (by linarith [scalarF0_ge_half a ha])]
  unfold bulkAmplitude
  ring

lemma central_damping_lower {n:ℕ} (hn:0<n) {a:ℝ} (ha:0<a) :
    1-1/(2*(n:ℝ))≤Real.exp (-(bulkCentralBias n a)^2/(2*a^2*(n:ℝ))) := by
  have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
  obtain ⟨hc0,hca,_⟩:=bulkCentralBias_bounds n a ha.le
  have hsq:(bulkCentralBias n a)^2≤a^2 := by nlinarith
  have hz:(bulkCentralBias n a)^2/(2*a^2*(n:ℝ))≤1/(2*(n:ℝ)) := by
    apply (div_le_div_iff₀ (by positivity : 0<2*a^2*(n:ℝ)) (by positivity : 0<2*(n:ℝ))).mpr
    nlinarith [mul_le_mul_of_nonneg_right hsq (show 0≤2*(n:ℝ) by positivity)]
  have he:=Real.add_one_le_exp (-(bulkCentralBias n a)^2/(2*a^2*(n:ℝ)))
  rw [neg_div] at he ⊢
  linarith

def EqualBulkErrorBound (n:ℕ) (a K:ℝ) : Prop := ∀B:ℝ,
  Real.sqrt (n:ℝ)*|parityCorrelation (fun _:Fin n=>a) B-
    residualLeading (fun _:Fin n=>1) (fun _=>0) a B|≤
      K/(n:ℝ)+K*|B|/(n:ℝ)*Real.exp (-B^2/(2*a^2*(n:ℝ)))

lemma balanced_envelope {n:ℕ} (hn:0<n) {a K:ℝ} (ha:1≤a) (ha2:a≤2)
    (herr:EqualBulkErrorBound n a K) (B:ℝ) :
    Real.sqrt (n:ℝ)*|parityCorrelation (fun _:Fin n=>a) B|≤
      Real.exp (-B^2/(2*a^2*(n:ℝ)))*(bulkAmplitude a+K*|B|/(n:ℝ))+K/(n:ℝ) := by
  let C:=parityCorrelation (fun _:Fin n=>a) B
  let Z:=residualLeading (fun _:Fin n=>1) (fun _=>0) a B
  have htri:|C|≤|C-Z|+|Z| := by
    calc
      _ = |(C-Z)+Z| := by congr 1; ring
      _ ≤ _ := abs_add_le _ _
  have htm:=mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (n:ℝ))
  have hmodel:=balancedLeading_abs_normalized hn (show 0<a by linarith) B
  have hcap:=periodicFourierResponse_abs_le (show 0<a by linarith) ha2 (B+(n%2:ℕ)*a)
  rw [periodicFourierMaximum_eq_scalarF0 a (by linarith)] at hcap
  have hcm:=mul_le_mul_of_nonneg_left hcap
    (show 0≤Real.sqrt (2/Real.pi)*Real.exp (-B^2/(2*a^2*(n:ℝ))) by positivity)
  have he:=herr B
  dsimp [C,Z] at htm
  unfold bulkAmplitude
  nlinarith

lemma balanced_central_lower {n:ℕ} (hn:0<n) {a K:ℝ} (ha:1≤a) (ha2:a≤2)
    (hK:0≤K) (herr:EqualBulkErrorBound n a K) :
    bulkAmplitude a-(3*K+1)/(n:ℝ)≤
      Real.sqrt (n:ℝ)*|parityCorrelation (fun _:Fin n=>a) (bulkCentralBias n a)| := by
  have hn':0<(n:ℝ) := Nat.cast_pos.mpr hn
  let c:=bulkCentralBias n a
  let C:=parityCorrelation (fun _:Fin n=>a) c
  let Z:=residualLeading (fun _:Fin n=>1) (fun _=>0) a c
  let e:=Real.exp (-c^2/(2*a^2*(n:ℝ)))
  have hA:=bulkAmplitude_bounds a ha
  have hA0:0≤bulkAmplitude a := (by positivity : 0≤Real.sqrt (2/Real.pi)/2).trans hA.1
  have hc:=bulkCentralBias_bounds n a (by linarith)
  have hcabs:|c|≤2 := by dsimp [c]; rw [abs_of_nonneg hc.1]; linarith
  have he0:0≤e := (Real.exp_pos _).le
  have he1:e≤1 := Real.exp_le_one_iff.mpr
    (div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg c)) (by positivity))
  have hlin:K*|c|/(n:ℝ)*e≤2*K/(n:ℝ) := by
    calc
      _ ≤ (K*2/(n:ℝ))*1 := mul_le_mul
        (div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hcabs hK) hn'.le)
        he1 he0 (by positivity)
      _ = _ := by ring
  have herror:Real.sqrt (n:ℝ)*|C-Z|≤3*K/(n:ℝ) := by
    have hh:=herr c
    change Real.sqrt (n:ℝ)*|C-Z|≤K/(n:ℝ)+K*|c|/(n:ℝ)*e at hh
    calc
      _ ≤ K/(n:ℝ)+2*K/(n:ℝ) := hh.trans (add_le_add le_rfl hlin)
      _ = _ := by ring
  have hmodel:=balancedLeading_central hn ha
  have hdamp:=mul_le_mul_of_nonneg_left (central_damping_lower hn (show 0<a by linarith)) hA0
  have hsmall:bulkAmplitude a/(2*(n:ℝ))≤1/(n:ℝ) := by
    apply (div_le_div_iff₀ (by positivity : 0<2*(n:ℝ)) hn').mpr
    nlinarith [mul_le_mul_of_nonneg_right hA.2 hn'.le]
  have hlower:bulkAmplitude a-1/(n:ℝ)≤Real.sqrt (n:ℝ)*|Z| := by
    change Real.sqrt (n:ℝ)*|Z|=bulkAmplitude a*e at hmodel
    change bulkAmplitude a*(1-1/(2*(n:ℝ)))≤bulkAmplitude a*e at hdamp
    have hid:bulkAmplitude a*(1-1/(2*(n:ℝ)))=bulkAmplitude a-bulkAmplitude a/(2*(n:ℝ)) := by ring
    rw [hid] at hdamp
    linarith
  have htri:|Z|≤|C|+|C-Z| := by
    calc
      _ = |C-(C-Z)| := by congr 1; ring
      _ ≤ |C|+|C-Z| := abs_sub _ _
  have htm:=mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (n:ℝ))
  change bulkAmplitude a-(3*K+1)/(n:ℝ)≤Real.sqrt (n:ℝ)*|C|
  rw [add_div]
  nlinarith

/-- Every actual bias whose coefficient is at least the canonical central
candidate lies in a single compact interval, uniformly in degree and gain. -/
theorem equalBulk_competitive_bias_compact :
    ∃ R:ℝ,0<R ∧ ∃ N₀:ℕ,0<N₀ ∧ ∀n:ℕ,N₀≤n → ∀a:ℝ,1≤a → a≤2 → ∀B:ℝ,
      |parityCorrelation (fun _:Fin n=>a) (bulkCentralBias n a)|≤
        |parityCorrelation (fun _:Fin n=>a) B| → |B|≤R := by
  let K:=balancedGlobalConstant
  let K₁:=3*K+1
  let α:=Real.sqrt (2/Real.pi)/2
  have hK:0<K := balancedGlobalConstant_pos
  have hK₁:0<K₁ := by dsimp [K₁]; positivity
  have hα:0<α := by dsimp [α]; positivity
  have hKK:K≤K₁ := by dsimp [K₁]; linarith
  obtain ⟨N₀,hN₀,hglobal⟩:=balanced_global_error_uniform
  obtain ⟨N₁,hN₁⟩:=exists_nat_ge (4*K₁/α)
  refine ⟨1+64*K₁/α,by positivity,max N₀ N₁,lt_of_lt_of_le hN₀ (le_max_left _ _),?_⟩
  intro n hn a ha ha2 B hcomp
  have hn0:N₀≤n := (le_max_left _ _).trans hn
  have hn1:N₁≤n := (le_max_right _ _).trans hn
  have hnp:0<n := lt_of_lt_of_le hN₀ hn0
  have hnR:0<(n:ℝ) := Nat.cast_pos.mpr hnp
  have herr:EqualBulkErrorBound n a K := hglobal n hn0 a ha ha2
  have hlower:=balanced_central_lower hnp ha ha2 hK.le herr
  have hupper:=balanced_envelope hnp ha ha2 herr B
  have hc:=mul_le_mul_of_nonneg_left hcomp (Real.sqrt_nonneg (n:ℝ))
  have hcompare:bulkAmplitude a-K₁/(n:ℝ)≤
      Real.exp (-B^2/(2*a^2*(n:ℝ)))*(bulkAmplitude a+K₁*|B|/(n:ℝ))+K₁/(n:ℝ) := by
    apply (hlower.trans hc).trans
    apply hupper.trans
    apply add_le_add
    · apply mul_le_mul_of_nonneg_left _ (Real.exp_pos _).le
      exact add_le_add le_rfl (div_le_div_of_nonneg_right
        (mul_le_mul_of_nonneg_right hKK (abs_nonneg B)) hnR.le)
    · exact div_le_div_of_nonneg_right hKK hnR.le
  have hthreshold:4*K₁≤(n:ℝ)*α := by
    have hh:4*K₁/α≤(n:ℝ) := hN₁.trans (by exact_mod_cast hn1)
    exact (div_le_iff₀ hα).mp hh
  apply gaussian_bias_compact (n:ℝ) a (bulkAmplitude a) α K₁ B hnR
    (by linarith) ha2 hα (bulkAmplitude_bounds a ha).1 hK₁.le hthreshold
  simpa only [neg_div] using hcompare

end NeuralGeneralization.OnlineLowerTanh
