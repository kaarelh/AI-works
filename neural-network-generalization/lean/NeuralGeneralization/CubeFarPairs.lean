import NeuralGeneralization.LocalizedBumpSampling
import NeuralGeneralization.WalshMaskedMatrixGeometry
import NeuralGeneralization.ModelLearning

/-! Explicit near-pair counts and IID exceptional probabilities on the cube. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.CubeFarPairs
open scoped BigOperators
open LocalizedCubeBump SquaredSampling Classical
attribute [local instance] Classical.propDecidable
variable {d n : ℕ}

def far (x y : ClippingCube d) : Prop := d ≤ 4*hammingDist x y ∧ 4*hammingDist x y ≤ 3*d

lemma far_symm (x y : ClippingCube d) : far x y ↔ far y x := by
  simp only [far, hammingDist_comm x y]

lemma not_far_self (hd : 0 < d) (x : ClippingCube d) : ¬ far x x := by
  simp only [far, hammingDist_self, mul_zero]
  omega

lemma far_real_bounds {x y : ClippingCube d} (h : far x y) :
    (d:ℝ)/4 ≤ hammingDist x y ∧ (hammingDist x y:ℝ) ≤ 3*(d:ℝ)/4 := by
  have h₁ : (d:ℝ) ≤ 4*hammingDist x y := by exact_mod_cast h.1
  have h₂ : (4:ℝ)*hammingDist x y ≤ 3*d := by exact_mod_cast h.2
  constructor <;> linarith

lemma hammingDist_negate (x y : ClippingCube d) :
    hammingDist (cubeNegate x) y=d-hammingDist x y := by
  have he : (Finset.univ.filter (fun i : Fin d => cubeNegate x i ≠ y i)) =
      Finset.univ.filter (fun i : Fin d => ¬ x i ≠ y i) := by
    ext i
    cases hx : x i <;> cases hy : y i <;> simp [cubeNegate, hx, hy]
  unfold hammingDist
  rw [he]
  have hh := Finset.card_filter_add_card_filter_not (s:=Finset.univ) (fun i : Fin d => x i≠y i)
  simp only [Finset.card_univ, Fintype.card_fin] at hh
  omega

def nearProbe (x y : ClippingCube d) : ℝ :=
  (1/2:ℝ)^hammingDist y x+(1/2:ℝ)^hammingDist y (cubeNegate x)

def nearProbabilityBound (d : ℕ) : ℝ := 2*(3/4:ℝ)^d/(1/2:ℝ)^(d/4)

lemma nearProbe_nonneg (x y : ClippingCube d) : 0 ≤ nearProbe x y := by
  unfold nearProbe
  positivity

lemma nearProbe_mean (x : ClippingCube d) :
    uniformCubeMean (nearProbe x)=2*(3/4:ℝ)^d := by
  change finiteMean (fun y => (1/2:ℝ)^hammingDist y x+(1/2:ℝ)^hammingDist y (cubeNegate x))=_
  rw [finiteMean_add]
  change uniformCubeMean (fun y => (1/2:ℝ)^hammingDist y x)+
    uniformCubeMean (fun y => (1/2:ℝ)^hammingDist y (cubeNegate x))=_
  rw [distance_probe_mean, distance_probe_mean]
  ring

lemma nearProbe_lower {x y : ClippingCube d} (h : ¬ far x y) :
    (1/2:ℝ)^(d/4) ≤ nearProbe x y := by
  have hdist : hammingDist x y ≤ d := by simpa using hammingDist_le_card_fintype (x:=x) (y:=y)
  simp only [far, not_and_or, not_le] at h
  unfold nearProbe
  rcases h with h | h
  · have hh : hammingDist y x ≤ d/4 := by rw [hammingDist_comm]; omega
    exact (pow_le_pow_of_le_one (by norm_num : (0:ℝ)≤1/2) (by norm_num) hh).trans
      (le_add_of_nonneg_right (by positivity))
  · have hh : hammingDist y (cubeNegate x) ≤ d/4 := by
      rw [hammingDist_comm, hammingDist_negate]
      omega
    exact (pow_le_pow_of_le_one (by norm_num : (0:ℝ)≤1/2) (by norm_num) hh).trans
      (le_add_of_nonneg_left (by positivity))

lemma near_fraction_le (x : ClippingCube d) :
    uniformCubeMean (fun y => if ¬ far x y then (1:ℝ) else 0) ≤ nearProbabilityBound d := by
  have hq : (0:ℝ)<(1/2:ℝ)^(d/4) := by positivity
  have hp (y : ClippingCube d) : (if ¬ far x y then (1:ℝ) else 0) ≤ nearProbe x y/(1/2:ℝ)^(d/4) := by
    by_cases h : far x y
    · simpa [h] using div_nonneg (nearProbe_nonneg x y) hq.le
    · simpa [h] using (one_le_div hq).mpr (nearProbe_lower h)
  have hh := uniformCubeMean_mono hp
  have he : uniformCubeMean (fun y => nearProbe x y/(1/2:ℝ)^(d/4)) =
      uniformCubeMean (nearProbe x)/(1/2:ℝ)^(d/4) := by
    simp only [uniformCubeMean, Finset.sum_div, div_right_comm]
  rw [he, nearProbe_mean] at hh
  exact hh

lemma near_count_le (x : ClippingCube d) :
    ((Finset.univ.filter (fun y => ¬ far x y)).card:ℝ) ≤
      Fintype.card (ClippingCube d)*nearProbabilityBound d := by
  have hh := near_fraction_le x
  unfold uniformCubeMean at hh
  have he : (∑ y : ClippingCube d, if ¬ far x y then (1:ℝ) else 0) =
      ((Finset.univ.filter (fun y => ¬ far x y)).card:ℝ) := by
    rw [← Finset.sum_filter]
    simp
  rw [he] at hh
  exact ((div_le_iff₀ (by positivity : (0:ℝ)<Fintype.card (ClippingCube d))).mp hh).trans_eq
    (mul_comm _ _)

/-- Exact IID bound, including repeated inputs, on any non-far pair. -/
theorem sampled_near_probability (d n : ℕ) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ¬ ∀ i j, i≠j → far (s i) (s j)) ≤ (n:ℝ)^2*nearProbabilityBound d := by
  have hq : (0:ℝ)<(1/2:ℝ)^(d/4) := by positivity
  have hp := offDiagonalSum_bad_probability (n:=n) nearProbe nearProbe_nonneg
    (2*(3/4:ℝ)^d) (by positivity)
    (by simp_rw [nearProbe_mean]; rw [uniformCubeMean_const]) _ hq
  apply (ConcreteModel.sampleProbability_mono (ConcreteModel.uniformLaw d) n _ _ (fun s hs => ?_)).trans
    (hp.trans_eq (by unfold nearProbabilityBound; ring))
  push Not at hs
  obtain ⟨i,j,hij,hbad⟩ := hs
  have hji : j ∈ (Finset.univ : Finset (Fin n)).erase i := by simp [Ne.symm hij]
  have hinner := Finset.single_le_sum
    (fun j (_ : j ∈ (Finset.univ : Finset (Fin n)).erase i) => nearProbe_nonneg (s i) (s j)) hji
  have houter := Finset.single_le_sum
    (s:=(Finset.univ : Finset (Fin n)))
    (f:=fun i => ∑ j ∈ Finset.univ.erase i, nearProbe (s i) (s j))
    (fun i _ => Finset.sum_nonneg fun j _ => nearProbe_nonneg _ _) (Finset.mem_univ i)
  exact (nearProbe_lower hbad).trans (hinner.trans houter)

lemma nearProbabilityBound_nonneg (d : ℕ) : 0 ≤ nearProbabilityBound d := by
  unfold nearProbabilityBound
  positivity

/-- A convenient dimension-only exponential envelope; the constant is
chosen loosely so all finite dimensions are covered. -/
theorem nearProbabilityBound_le (d : ℕ) : nearProbabilityBound d ≤ 2*(15/16:ℝ)^d := by
  have hg : (2:ℝ)^(d/4) ≤ (5/4:ℝ)^d := by
    calc
      _ ≤ ((5/4:ℝ)^4)^(d/4) := pow_le_pow_left₀ (by norm_num) (by norm_num) _
      _ = (5/4:ℝ)^(4*(d/4)) := (pow_mul _ _ _).symm
      _ ≤ _ := pow_le_pow_right₀ (by norm_num) (by omega)
  have he : nearProbabilityBound d = 2*((3/4:ℝ)^d*(2:ℝ)^(d/4)) := by
    unfold nearProbabilityBound
    rw [div_eq_mul_inv, ← inv_pow, show (1/2:ℝ)⁻¹=2 by norm_num]
    ring
  rw [he]
  calc
    _ ≤ 2*((3/4:ℝ)^d*(5/4:ℝ)^d) := by gcongr
    _ = _ := by rw [← mul_pow]; norm_num

end NeuralGeneralization.CubeFarPairs
