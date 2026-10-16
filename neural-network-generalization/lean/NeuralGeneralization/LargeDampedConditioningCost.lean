import NeuralGeneralization.NeuralDampedComparatorProbability
import NeuralGeneralization.UniformAdaptiveCutoff
import NeuralGeneralization.ArcsineTraceReal
import NeuralGeneralization.ModelLearning

/-! Actual fixed-margin conditioning costs in the large-sample regime. -/
noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.LocalizedCubeBump
open ConcreteModel CompressionSampling FieldPosteriorBridge GaussianFieldTilt

def dampingExponent (k : ℕ) : ℝ := 1/(2:ℝ)^(k+1)
def cutoffDamping (k r : ℕ) : ℝ≥0 := ⟨(r:ℝ)^(-dampingExponent k), Real.rpow_nonneg (Nat.cast_nonneg _) _⟩
def sharpDampedConstant (k : ℕ) : ℝ := 40000/sharpLowConstant k+2

def dampingBuffer (d k r : ℕ) : ℝ := Real.sqrt (40*((d:ℝ)+1)*(cutoffDamping k r:ℝ))

lemma dampingExponent_pos (k : ℕ) : 0<dampingExponent k := by unfold dampingExponent; positivity
lemma dampingExponent_le_one (k : ℕ) : dampingExponent k≤1 := by
  unfold dampingExponent
  exact (div_le_one (by positivity)).mpr (one_le_pow₀ (by norm_num))
lemma cutoffDamping_pos {r : ℕ} (hr : 0<r) (k : ℕ) : 0<cutoffDamping k r :=
  Real.rpow_pos_of_pos (Nat.cast_pos.mpr hr) _
lemma cutoffDamping_le_one {r : ℕ} (hr : 0<r) (k : ℕ) : cutoffDamping k r≤1 := by
  change (r:ℝ)^(-dampingExponent k)≤1
  have hr1 : (1:ℝ)≤r := by exact_mod_cast hr
  simpa only [Real.rpow_zero] using Real.rpow_le_rpow_of_exponent_le hr1 (neg_nonpos.mpr (dampingExponent_pos k).le)
lemma cutoffDamping_inv_le {d r : ℕ} (hr : 0<r) (hrd : r≤d) (k : ℕ) :
    1/(cutoffDamping k r:ℝ)≤(d:ℝ)+1 := by
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr hr
  have hr1 : (1:ℝ)≤r := by exact_mod_cast hr
  change 1/((r:ℝ)^(-dampingExponent k))≤_
  rw [Real.rpow_neg hr0.le,one_div,inv_inv]
  have hh := Real.rpow_le_rpow_of_exponent_le hr1 (dampingExponent_le_one k)
  rw [Real.rpow_one] at hh
  have hdr : (r:ℝ)≤d := by exact_mod_cast hrd
  linarith
lemma cutoffDamping_scale_ge_one {d r : ℕ} (hr : 0<r) (hrd : r≤d) (k : ℕ) :
    1≤((d:ℝ)+1)*(cutoffDamping k r:ℝ) := by
  have h := cutoffDamping_inv_le hr hrd k
  exact (div_le_iff₀ (show (0:ℝ)<(cutoffDamping k r:ℝ) from cutoffDamping_pos hr k)).mp h

lemma sharpDampedConstant_pos (k : ℕ) : 0<sharpDampedConstant k := by
  unfold sharpDampedConstant
  have := sharpLowConstant_pos k
  positivity

/-- Exponential coordinate decay makes damping inexpensive even uniformly
across exponentially many samples. -/
theorem eventually_damped_energy_sharp (k : ℕ) :
    ∀ᶠ d : ℕ in atTop, ∀ r n : ℕ, ∀ tau : ℝ≥0,
      1/(tau:ℝ)≤(d:ℝ)+1 → (lowModes d r).card≤n →
      (n:ℝ)≤Real.exp ((d:ℝ)/1000) →
      dampedEnergyBudget d k r tau ≤ sharpDampedConstant k*((d:ℝ)+1)^dampingExponent k := by
  have hrem : Tendsto (fun d : ℕ=>(24/(2/Real.pi)^k)*((d:ℝ)+1)^3*Real.exp (-(d:ℝ)/100)) atTop (𝓝 0) := by
    simpa only [mul_zero,zero_mul,one_mul,neg_mul,mul_neg,div_eq_mul_inv,mul_comm,mul_left_comm,mul_assoc] using
      (shifted_polynomial_exp_neg_tendsto 3 (1/100) (by norm_num)).const_mul (24/(2/Real.pi)^k)
  have hcor : Tendsto (fun d : ℕ=>(24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp (-(d:ℝ)/4)) atTop (𝓝 0) := by
    simpa only [mul_zero,zero_mul,one_mul,neg_mul,mul_neg,div_eq_mul_inv,mul_comm,mul_left_comm,mul_assoc] using
      (shifted_polynomial_exp_neg_tendsto 4 (1/4) (by norm_num)).const_mul (24/(2/Real.pi)^k)
  filter_upwards [hrem.eventually (eventually_le_nhds (by norm_num : (0:ℝ)<1)),
    hcor.eventually (eventually_le_nhds (by norm_num : (0:ℝ)<1))] with d hrem hcor r n tau hinv hmodes hn
  have hD : 1≤(d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hpow : 1≤((d:ℝ)+1)^dampingExponent k := Real.one_le_rpow hD (dampingExponent_pos k).le
  have htail : (99/100:ℝ)^d/neuralFloor d k≤1 := by
    have hlog := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<99/100)
    have he : (99/100:ℝ)^d≤Real.exp (-(d:ℝ)/100) := by
      rw [positive_pow_eq_exp _ (by norm_num)]
      apply Real.exp_le_exp.mpr
      have hh := mul_le_mul_of_nonneg_left hlog (Nat.cast_nonneg d : (0:ℝ)≤d)
      nlinarith
    apply le_trans _ hrem
    unfold neuralFloor
    calc
      _ = (24/(2/Real.pi)^k)*((d:ℝ)+1)^3*(99/100:ℝ)^d := by field_simp
      _ ≤ _ := by gcongr
  have hc := damped_coordinate_envelope d k tau hinv
  have hm : ((lowModes d r).card:ℝ)≤n := by exact_mod_cast hmodes
  have hcorr : ((lowModes d r).card:ℝ)*(neuralCoordinateBudget d k/(tau:ℝ))≤1 := by
    apply le_trans _ hcor
    calc
      _ ≤ Real.exp ((d:ℝ)/1000)*((24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp (-7*(d:ℝ)/25)) :=
        mul_le_mul (hm.trans hn) hc (div_nonneg (neuralCoordinateBudget_pos d k).le tau.coe_nonneg) (Real.exp_pos _).le
      _ = (24/(2/Real.pi)^k)*((d:ℝ)+1)^4*Real.exp ((d:ℝ)/1000-7*(d:ℝ)/25) := by
        rw [show (d:ℝ)/1000-7*(d:ℝ)/25=(d:ℝ)/1000+(-7*(d:ℝ)/25) by ring,Real.exp_add]
        ring
      _ ≤ _ := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        apply Real.exp_le_exp.mpr
        nlinarith [Nat.cast_nonneg (α:=ℝ) d]
  unfold dampedEnergyBudget sharpEnergyBudget sharpDampedConstant
  change (40000/sharpLowConstant k)*((d:ℝ)+1)^dampingExponent k+_+_≤_
  rw [mul_div_assoc]
  nlinarith only [htail,hcorr,hpow]

lemma dampingBuffer_strip {d r : ℕ} (hr : 0<r) (k : ℕ) :
    4*(Fintype.card (ClippingCube d):ℝ)*Real.exp
      (-(dampingBuffer d k r)^2/(2*((cutoffDamping k r:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r)))≤1 := by
  have htau := cutoffDamping_pos hr k
  have hT := iterated_arcsine_spectral_tail_upper d (k+1) r hr
  change walshSpectralTail (arcsineProfile d (k+1)) r≤4*(cutoffDamping k r:ℝ) at hT
  have hT0 : 0≤walshSpectralTail (arcsineProfile d (k+1)) r :=
    Finset.sum_nonneg fun S hS=>(iterated_arcsine_coefficient_pos d k S).le
  have hden : 0<2*((cutoffDamping k r:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r) := by positivity
  have hsq : dampingBuffer d k r^2=40*((d:ℝ)+1)*(cutoffDamping k r:ℝ) := by
    exact Real.sq_sqrt (by positivity)
  have harg : -(dampingBuffer d k r)^2/(2*((cutoffDamping k r:ℝ)+walshSpectralTail (arcsineProfile d (k+1)) r))≤ -4*((d:ℝ)+1) := by
    apply (div_le_iff₀ hden).mpr
    rw [hsq]
    have hh := mul_le_mul_of_nonneg_left hT (show 0≤(d:ℝ)+1 by positivity)
    nlinarith only [hh]
  have he : (2:ℝ)≤Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
  have h2 : (4:ℝ)≤Real.exp 2 := by
    rw [show (2:ℝ)=1+1 by norm_num,Real.exp_add]
    nlinarith [Real.exp_pos (1:ℝ)]
  have hd : (2:ℝ)^d≤Real.exp (d:ℝ) := by
    simpa only [←Real.exp_nat_mul,mul_one] using pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) he d
  have hcard : (Fintype.card (ClippingCube d):ℝ)=(2:ℝ)^d := by simp [ClippingCube]
  rw [hcard]
  calc
    _ ≤ (Real.exp 2*Real.exp (d:ℝ))*Real.exp (-4*((d:ℝ)+1)) := by gcongr
    _ = Real.exp (2+(d:ℝ)-4*((d:ℝ)+1)) := by rw [←Real.exp_add,←Real.exp_add]; congr 1; ring
    _ ≤ 1 := Real.exp_le_one_iff.mpr (by nlinarith [Nat.cast_nonneg (α:=ℝ) d])

/-- The sharp comparator energy has the advertised depth-dependent power. -/
theorem eventually_sharpEnergyBudget_le (k : ℕ) :
    ∀ᶠ d : ℕ in atTop, sharpEnergyBudget d k≤
      (2*sharpDampedConstant k)*(d:ℝ)^dampingExponent k := by
  filter_upwards [eventually_damped_energy_sharp k,eventually_ge_atTop 1] with d hd hd1
  have hraw := hd 0 0 1 (by simp) (by simp [lowModes]) (by simpa only [Nat.cast_zero] using (Real.exp_pos ((d:ℝ)/1000)).le)
  have hsharp : sharpEnergyBudget d k≤sharpDampedConstant k*((d:ℝ)+1)^dampingExponent k := by
    simpa [dampedEnergyBudget,lowModes] using hraw
  have hdR : (1:ℝ)≤d := by exact_mod_cast hd1
  have hpow : ((d:ℝ)+1)^dampingExponent k≤2*(d:ℝ)^dampingExponent k := by
    calc
      _ ≤ (2*(d:ℝ))^dampingExponent k := Real.rpow_le_rpow (by positivity) (by linarith) (dampingExponent_pos k).le
      _ = (2:ℝ)^dampingExponent k*(d:ℝ)^dampingExponent k := Real.mul_rpow (by norm_num) (by positivity)
      _ ≤ _ := by
        apply mul_le_mul_of_nonneg_right _ (by positivity)
        simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le (by norm_num : (1:ℝ)≤2) (dampingExponent_le_one k)
  exact hsharp.trans (by nlinarith only [mul_le_mul_of_nonneg_left hpow (sharpDampedConstant_pos k).le])

def largeConditioningConstant (k : ℕ) (a : ℝ) : ℝ :=
  2+4*(2*(a+1)^2+80)*(1/(2/Real.pi)^(k+1)+4*sharpDampedConstant k+4)

lemma largeConditioningConstant_pos (k : ℕ) (a : ℝ) : 0<largeConditioningConstant k a := by
  unfold largeConditioningConstant
  have := sharpDampedConstant_pos k
  positivity

lemma cutoffDamping_log_bound {d r n : ℕ} (hr : 0<r) (hrd : r≤d)
    (hpoly : ((d:ℝ)+1)^2≤n) (k : ℕ) :
    -Real.log (cutoffDamping k r:ℝ)≤Real.log (8*(n:ℝ)) := by
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr hr
  have hr1 : (1:ℝ)≤r := by exact_mod_cast hr
  have hdr : (r:ℝ)≤d := by exact_mod_cast hrd
  have hn1 : (1:ℝ)≤n := by nlinarith [Nat.cast_nonneg (α:=ℝ) d]
  have hn0 : (0:ℝ)<n := by linarith
  change -Real.log ((r:ℝ)^(-dampingExponent k))≤_
  rw [Real.log_rpow hr0]
  have hlog0 : 0≤Real.log (r:ℝ) := Real.log_nonneg hr1
  have hlog : Real.log (r:ℝ)≤Real.log (8*(n:ℝ)) :=
    Real.log_le_log hr0 (by nlinarith [Nat.cast_nonneg (α:=ℝ) d])
  have hh := mul_le_mul_of_nonneg_right (dampingExponent_le_one k) hlog0
  nlinarith only [hh,hlog]

/-- The displayed damping choice gives the sharp conditioning budget using
only the actual sample threshold and the proved neural energy estimate. -/
theorem dampedCostBudget_large_bound {d r n : ℕ} (hr : 0<r) (hrd : r≤d)
    (hpoly : ((d:ℝ)+1)^2≤n) (k : ℕ) (a : ℝ)
    (henergy : dampedEnergyBudget d k r (cutoffDamping k r)≤
      sharpDampedConstant k*((d:ℝ)+1)^dampingExponent k)
    (hmodes : ((lowModes d r).card:ℝ)*Real.log (8*(n:ℝ))≤n) :
    dampedCostBudget d k r n (cutoffDamping k r) a (dampingBuffer d k r) 1≤
      largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^(1+dampingExponent k)*(cutoffDamping k r:ℝ) := by
  let D : ℝ := (d:ℝ)+1
  let P : ℝ := D^dampingExponent k
  let T : ℝ := (cutoffDamping k r:ℝ)
  let H : ℝ := 2*(a+1)^2+80
  let C : ℝ := 1/(2/Real.pi)^(k+1)+4*sharpDampedConstant k+4
  have hD : 1≤D := by dsimp [D]; linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hD0 : 0<D := by linarith
  have hP : 1≤P := Real.one_le_rpow hD (dampingExponent_pos k).le
  have hT : 0<T := cutoffDamping_pos hr k
  have hDT : 1≤D*T := cutoffDamping_scale_ge_one hr hrd k
  have hn : (1:ℝ)≤n := by change D^2≤n at hpoly; nlinarith
  have hC0 : 0<C := by dsimp [C]; have := sharpDampedConstant_pos k; positivity
  have hH0 : 0≤H := by dsimp [H]; positivity
  have hE0 := (dampedEnergyBudget_pos d k r (cutoffDamping k r)).le
  have hw := iterated_arcsine_coefficient_pos d k (∅ : Finset (Fin d))
  have hinv : 1/walshCoefficients (arcsineProfile d (k+1)) ∅≤(1/(2/Real.pi)^(k+1))*D := by
    have hlo := arcsineProfile_coefficient_empty_lower d (k+1)
    have hh := one_div_le_one_div_of_le (by positivity : 0<(2/Real.pi)^(k+1)/D) hlo
    calc
      _ ≤ 1/((2/Real.pi)^(k+1)/D) := hh
      _ = _ := by field_simp
  have hconst : 1/(walshCoefficients (arcsineProfile d (k+1)) ∅*T)≤(1/(2/Real.pi)^(k+1))*(n:ℝ)*P := by
    have hTi : 1/T≤D := cutoffDamping_inv_le hr hrd k
    have hh := mul_le_mul hinv hTi (by positivity : 0≤1/T) (by positivity : 0≤(1/(2/Real.pi)^(k+1))*D)
    have hNP : (n:ℝ)≤(n:ℝ)*P := by nlinarith only [hP,hn]
    calc
      _ = (1/walshCoefficients (arcsineProfile d (k+1)) ∅)*(1/T) := by ring
      _ ≤ ((1/(2/Real.pi)^(k+1))*D)*D := hh
      _ ≤ (1/(2/Real.pi)^(k+1))*(n:ℝ)*P := by
        have hh' := mul_le_mul_of_nonneg_left (hpoly.trans hNP) (show 0≤1/(2/Real.pi)^(k+1) by positivity)
        nlinarith only [hh']
  have hbracket : 1/(walshCoefficients (arcsineProfile d (k+1)) ∅*T)+
      4*((n:ℝ)*dampedEnergyBudget d k r (cutoffDamping k r)+1)≤C*(n:ℝ)*P := by
    have hh := mul_le_mul_of_nonneg_left henergy (Nat.cast_nonneg n : (0:ℝ)≤n)
    have hnp : 1≤(n:ℝ)*P := one_le_mul_of_one_le_of_one_le hn hP
    dsimp [C,P,D] at *
    nlinarith only [hconst,hh,hnp]
  have hbuf : (a+dampingBuffer d k r+1)^2≤H*D*T := by
    have hsq : dampingBuffer d k r^2=40*D*T := Real.sq_sqrt (by positivity)
    have hh := mul_le_mul_of_nonneg_left hDT (show 0≤2*(a+1)^2 by positivity)
    dsimp [H]
    nlinarith only [hsq,hh,sq_nonneg (a+1-dampingBuffer d k r)]
  have hdet : -(((lowModes d r).card:ℝ)/2*Real.log T)≤n := by
    have hh := mul_le_mul_of_nonneg_left (cutoffDamping_log_bound hr hrd hpoly k)
      (show 0≤((lowModes d r).card:ℝ) by positivity)
    change _≤_ at hh
    nlinarith only [hh,hmodes,hn]
  have hunit : 1≤(n:ℝ)*D*T*P := by
    have hh := one_le_mul_of_one_le_of_one_le (one_le_mul_of_one_le_of_one_le hn hDT) hP
    nlinarith only [hh]
  have hprod := mul_le_mul hbuf hbracket (by positivity : 0≤1/(walshCoefficients (arcsineProfile d (k+1)) ∅*T)+4*((n:ℝ)*dampedEnergyBudget d k r (cutoffDamping k r)+1)) (by positivity : 0≤H*D*T)
  have hlog : Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  have hnscale : (n:ℝ)≤(n:ℝ)*D*T*P := by
    have hp := one_le_mul_of_one_le_of_one_le hDT hP
    have hh := mul_le_mul_of_nonneg_left hp (Nat.cast_nonneg n : (0:ℝ)≤n)
    nlinarith only [hh]
  have hpower : D^(1+dampingExponent k)=D*P := by rw [Real.rpow_add hD0,Real.rpow_one]
  change _≤largeConditioningConstant k a*(n:ℝ)*D^(1+dampingExponent k)*T
  rw [hpower]
  unfold dampedCostBudget
  change Real.log 2+4*(a+dampingBuffer d k r+1)^2*(1/(walshCoefficients (arcsineProfile d (k+1)) ∅*T)+4*((n:ℝ)*dampedEnergyBudget d k r (cutoffDamping k r)+1))-((lowModes d r).card:ℝ)/2*Real.log T≤_
  change _≤(2+4*H*C)*(n:ℝ)*(D*P)*T
  nlinarith only [hprod,hdet,hlog,hunit,hnscale]

lemma lowModes_card_le_lowDimension (d r : ℕ) : (lowModes d r).card≤lowDimension d r := by
  classical
  unfold lowDimension DegreeIndices
  rw [Fintype.card_subtype]
  apply Finset.card_le_card
  intro S hS
  simpa only [Finset.mem_filter,Finset.mem_univ,true_and] using
    (show S.card≤r from (by simpa only [lowModes,Finset.mem_filter,Finset.mem_univ,true_and] using hS : S.card<r).le)

lemma lowModes_threshold {d r n : ℕ} (hn : 0<n)
    (hthreshold : (lowDimension d r:ℝ)*Real.log (8*(n:ℝ))≤n) :
    (lowModes d r).card≤n ∧ ((lowModes d r).card:ℝ)*Real.log (8*(n:ℝ))≤n := by
  have hL := AdaptiveCutoff.log_eight_sample_ge_one hn
  have hM : ((lowModes d r).card:ℝ)≤lowDimension d r := by exact_mod_cast lowModes_card_le_lowDimension d r
  have hh := (mul_le_mul_of_nonneg_right hM (by linarith only [hL])).trans hthreshold
  have hM0 : (0:ℝ)≤(lowModes d r).card := Nat.cast_nonneg _
  have hbound : ((lowModes d r).card:ℝ)≤n := by nlinarith only [hh,hL,hM0]
  exact ⟨by exact_mod_cast hbound,hh⟩

/-- On an actual IID sample event of arbitrarily high fixed probability,
the fixed-margin Gaussian conditioning cost has the sharp damped scale. -/
theorem eventually_large_conditioning_cost_probability (k : ℕ) (a δ : ℝ)
    (ha : 0≤a) (hδ : 0<δ) :
    ∀ᶠ d : ℕ in atTop, ∀ r n : ℕ, 0<r → r≤d →
      ((d:ℝ)+1)^2≤n → (lowDimension d r:ℝ)*Real.log (8*(n:ℝ))≤n →
      (n:ℝ)≤Real.exp ((d:ℝ)/1000) →
      1-δ≤sampleProbability (uniformLaw d) n (fun s=>∀ f : BooleanFunction d,
        Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
          (conditioningEvent (fun z : ClippingCube d → ℝ=>z) a f s))≤
          largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^(1+dampingExponent k)*(cutoffDamping k r:ℝ)) := by
  have hsep : Tendsto (fun d : ℕ=>Real.exp (-(d:ℝ)/25)) atTop (𝓝 0) := by
    simpa only [pow_zero,one_mul,neg_mul,mul_neg,div_eq_mul_inv,mul_comm] using
      shifted_polynomial_exp_neg_tendsto 0 (1/25) (by norm_num)
  let C := (24/(2/Real.pi)^k)*(energyPolyConstant k+24/(2/Real.pi)^k)
  have hraw : Tendsto (fun d : ℕ=>C*((d:ℝ)+1)^8*Real.exp (-(d:ℝ)/4)) atTop (𝓝 0) := by
    simpa only [mul_zero,zero_mul,one_mul,mul_assoc,neg_mul,mul_neg,div_eq_mul_inv,mul_comm,mul_left_comm] using
      (shifted_polynomial_exp_neg_tendsto 8 (1/4) (by norm_num)).const_mul C
  have hcross := Real.continuous_sqrt.continuousAt.tendsto.comp hraw
  simp only [Real.sqrt_zero] at hcross
  have hsum := hsep.add hcross
  simp only [zero_add] at hsum
  filter_upwards [eventually_ge_atTop 101,eventually_damped_energy_sharp k,
    eventually_neuralComparatorGood_probability k δ hδ,
    hsum.eventually (eventually_le_nhds hδ)] with d hd henergy hscalar herror r n hr hrd hpoly hthreshold hn
  have hn0 : 0<n := by
    have hh : (0:ℝ)<n := lt_of_lt_of_le (by positivity : (0:ℝ)<((d:ℝ)+1)^2) hpoly
    exact Nat.cast_pos.mp hh
  obtain ⟨hmodes,hmlog⟩ := lowModes_threshold hn0 hthreshold
  obtain ⟨hR,hsmall,_⟩ := hscalar n hn
  have hinv := cutoffDamping_inv_le hr hrd k
  have hb := dampedCostBudget_large_bound hr hrd hpoly k a
    (henergy r n (cutoffDamping k r) hinv hmodes hn) hmlog
  have hp := neural_damped_conditioning_cost_probability hd k r n (d/10) hr hR
    (cutoffDamping k r) (cutoffDamping_pos hr k) (cutoffDamping_le_one hr k)
    a (dampingBuffer d k r) 1 ha (Real.sqrt_nonneg _) (by norm_num)
    (dampingBuffer_strip hr k) hsmall
  simp only [div_one] at hp
  have herr := add_le_add (comparator_separation_envelope d n hn)
    (damped_cross_envelope d k r n (cutoffDamping k r) hinv hmodes hn)
  have he : (n:ℝ)^2*(3/4:ℝ)^d/(1/2:ℝ)^(2*(d/10))+
      (n:ℝ)^2*Real.sqrt ((neuralCoordinateBudget d k/(cutoffDamping k r:ℝ))*dampedEnergyBudget d k r (cutoffDamping k r))≤δ := herr.trans herror
  have hp' : 1-δ≤sampleProbability (uniformLaw d) n (fun s=>∀ f : BooleanFunction d,
      Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
        (conditioningEvent (fun z : ClippingCube d → ℝ=>z) a f s))≤
        dampedCostBudget d k r n (cutoffDamping k r) a (dampingBuffer d k r) 1) := by
    linarith only [hp,he]
  apply hp'.trans
  apply sampleProbability_mono
  intro s hs f
  exact (hs f).trans hb

/-- The same explicit cost is exponentially small compared with the
auxiliary amplitude sample count, after reducing the training exponent. -/
theorem eventually_large_conditioning_budget_exp (k : ℕ) (a b : ℝ) (hb : 0<b) :
    ∀ᶠ d : ℕ in atTop, ∀ r n : ℕ, 0<r →
      (n:ℝ)≤Real.exp ((b/2)*(d:ℝ)) →
      largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^(1+dampingExponent k)*(cutoffDamping k r:ℝ)≤Real.exp (b*(d:ℝ)) := by
  have hlim : Tendsto (fun d : ℕ=>largeConditioningConstant k a*((d:ℝ)+1)^2*Real.exp (-(b/2)*(d:ℝ))) atTop (𝓝 0) := by
    simpa only [mul_zero,mul_assoc] using
      (shifted_polynomial_exp_neg_tendsto 2 (b/2) (by linarith only [hb])).const_mul (largeConditioningConstant k a)
  filter_upwards [hlim.eventually (eventually_le_nhds (by norm_num : (0:ℝ)<1))] with d hd r n hr hn
  have hC := largeConditioningConstant_pos k a
  have hD : 1≤(d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hp : ((d:ℝ)+1)^(1+dampingExponent k)≤((d:ℝ)+1)^2 := by
    have hh := Real.rpow_le_rpow_of_exponent_le hD (show 1+dampingExponent k≤2 by linarith only [dampingExponent_le_one k])
    simpa only [Real.rpow_two] using hh
  have hscale : largeConditioningConstant k a*((d:ℝ)+1)^2≤Real.exp ((b/2)*(d:ℝ)) := by
    rw [neg_mul,Real.exp_neg,←div_eq_mul_inv] at hd
    exact (div_le_one (Real.exp_pos _)).mp hd
  calc
    _ ≤ largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^2*1 := by
      apply mul_le_mul _ (show (cutoffDamping k r:ℝ)≤1 from cutoffDamping_le_one hr k) (by positivity) (by positivity)
      exact mul_le_mul_of_nonneg_left hp (by positivity)
    _ = (largeConditioningConstant k a*((d:ℝ)+1)^2)*(n:ℝ) := by ring
    _ ≤ Real.exp ((b/2)*(d:ℝ))*Real.exp ((b/2)*(d:ℝ)) := mul_le_mul hscale hn (Nat.cast_nonneg n) (Real.exp_pos _).le
    _ = Real.exp (b*(d:ℝ)) := by rw [←Real.exp_add]; congr 1; ring

end NeuralGeneralization.LocalizedCubeBump
