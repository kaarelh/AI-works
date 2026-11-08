import NeuralGeneralization.OnlineLowerTanhCodePhysicalProduct
import NeuralGeneralization.OnlineLowerTanhCodeDominant

/-! # Dominant retained orientations for literal physical rail products -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

def physicalPairTerm {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (t : ℝ) (s : Bool) (i : Fin p) : ℝ :=
  physicalRailWave size u i false s t*physicalRailWave size u i true s t

theorem physicalPairTerm_nonneg {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (t : ℝ) (s : Bool) (i : Fin p) :
    0≤physicalPairTerm size u t s i :=
  mul_nonneg (physicalRailWave_nonneg _ _ _ _ _ _) (physicalRailWave_nonneg _ _ _ _ _ _)

theorem physicalPairTerm_sum_le_one {p : ℕ} (size : Fin p→Bool→ℕ)
    (hsize : ∀i s,0<size i s) (u : Fin (carrierDimension size)→ℝ) (t : ℝ) (i : Fin p) :
    physicalPairTerm size u t false i+physicalPairTerm size u t true i≤1 := by
  let hR : ∀i s,1≤size i s := hsize
  have hm (s : Bool) := mul_le_mul
    (physicalRailWave_trim size hR u i false s t) (physicalRailWave_trim size hR u i true s t)
    (physicalRailWave_nonneg _ _ _ _ _ _) (Finset.prod_nonneg fun _ _=>by split <;> positivity)
  have hfalse := hm false
  have htrue := hm true
  simp only [Fintype.prod_unique,Fin.default_eq_zero,Bool.false_eq_true,Bool.true_eq_false,
    if_true,if_false] at hfalse htrue
  have hsc := sine_cosine_pair_le_one
    (t*trimmedCarrierRailWeights size hR u false i 0)
    (t*trimmedCarrierRailWeights size hR u true i 0)
  dsimp [physicalPairTerm]
  nlinarith only [hfalse,htrue,hsc]

theorem abs_sin_mul_abs_cos_half (x : ℝ) : |Real.sin x| *|Real.cos x|≤(1:ℝ)/2 := by
  have hs := Real.sin_sq_add_cos_sq x
  have h := sq_nonneg (|Real.sin x|-|Real.cos x|)
  rw [sub_sq,sq_abs,sq_abs] at h
  nlinarith

theorem physicalRailWave_cross {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (i : Fin p) (s : Bool) (t : ℝ) :
    physicalRailWave size u i s false t*physicalRailWave size u i s true t≤(1/2:ℝ)^(size i s) := by
  unfold physicalRailWave
  rw [←Finset.prod_mul_distrib]
  calc
    _ ≤ ∏_k:Fin (size i s),(1/2:ℝ) := by
      apply Finset.prod_le_prod
      · intro k _;split <;> split <;> positivity
      · intro k _
        cases s with
        | false => simpa only [Bool.false_eq_true,Bool.true_eq_false,if_false,if_true,mul_comm]
            using abs_sin_mul_abs_cos_half (t*carrierRailWeights size u i false k)
        | true => simpa only [Bool.false_eq_true,Bool.true_eq_false,if_false,if_true,mul_comm]
            using abs_sin_mul_abs_cos_half (t*carrierRailWeights size u i true k)
    _ = _ := by simp

theorem physicalPairTerm_cross {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ) (t : ℝ) (i : Fin p) :
    physicalPairTerm size u t false i*physicalPairTerm size u t true i≤((1/2:ℝ)^R)^2 := by
  have hf := physicalRailWave_cross size u i false t
  have ht := physicalRailWave_cross size u i true t
  have hp := mul_le_mul hf ht
    (mul_nonneg (physicalRailWave_nonneg _ _ _ _ _ _) (physicalRailWave_nonneg _ _ _ _ _ _)) (by positivity)
  have hpow : (1/2:ℝ)^(size i false+size i true)≤(1/2:ℝ)^(2*R) :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) (by have := hR i false;have := hR i true;omega)
  rw [pow_add] at hpow
  dsimp [physicalPairTerm]
  have hh := hp.trans hpow
  simpa only [pow_mul,mul_comm,mul_left_comm,mul_assoc] using hh

theorem physical_orientationTerm {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (t : ℝ) (θ : Fin p→Bool) :
    |trigProduct (carrierTransversal size θ) (fun j=>t*u j)| =
      |Real.sin (t*u 0)| *orientationTerm (physicalPairTerm size u t false) (physicalPairTerm size u t true) θ := by
  rw [carrierTransversal_abs_trig_product]
  congr 1
  apply Finset.prod_congr rfl
  intro i _
  cases θ i <;> rfl

/-- Every sufficiently large retained product peak contains an actual
retained physical transversal with a comparable resonance. -/
theorem physical_retained_dominant_peak {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hRpos : 0<R) (hR : ∀i s,R≤size i s)
    (u : Fin (carrierDimension size)→ℝ) (t μ : ℝ) (hμ:0<μ)
    (A : Finset (Fin p→Bool))
    (hsmall : (p:ℝ)*(1/2:ℝ)^R≤μ/2)
    (hpeak : μ≤∑θ∈A,|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|) :
    ∃θ∈A,μ/2≤|trigProduct (carrierTransversal size θ) (fun j=>t*u j)| := by
  have hsize : ∀i s,0<size i s := fun i s=>hRpos.trans_le (hR i s)
  have hp : μ≤|Real.sin (t*u 0)| *(∑θ∈A,
      orientationTerm (physicalPairTerm size u t false) (physicalPairTerm size u t true) θ) := by
    simpa only [physical_orientationTerm,Finset.mul_sum] using hpeak
  obtain ⟨hmem,hlarge⟩ := retained_dominant_peak
    (physicalPairTerm size u t false) (physicalPairTerm size u t true)
    (physicalPairTerm_nonneg size u t false) (physicalPairTerm_nonneg size u t true)
    (physicalPairTerm_sum_le_one size hsize u t) ((1/2:ℝ)^R) |Real.sin (t*u 0)| μ
    (by positivity) (abs_nonneg _) (Real.abs_sin_le_one _) hμ
    (physicalPairTerm_cross size hR u t) hsmall A hp
  refine ⟨_,hmem,?_⟩
  simpa only [physical_orientationTerm] using hlarge

end NeuralGeneralization.OnlineLowerTanh
