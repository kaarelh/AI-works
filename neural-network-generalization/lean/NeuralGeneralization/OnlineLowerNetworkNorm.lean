import NeuralGeneralization.OnlineLowerCostSigns
import NeuralGeneralization.OnlineLowerGeometryProjection
import NeuralGeneralization.OnlineLowerModel
import NeuralGeneralization.OnlineLowerVariationWitness
import Mathlib.Analysis.InnerProductSpace.PiL2

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLower
open OnlineLowerGeometry ConcreteModel

/-- Weighted Cauchy combined with the triangle inequality. -/
theorem norm_sum_deficit {ι E : Type*} [Fintype ι] [NormedAddCommGroup E]
    [NormedSpace ℝ E] (a r δ : ι → ℝ) (v : ι → E) (K : ℝ)
    (hK : 0 ≤ K) (hr : ∀ i, 0 ≤ r i) (hδ : ∀ i, 0 ≤ δ i)
    (hv : ∀ i, ‖v i‖^2 ≤ K*r i*δ i) :
    ‖∑ i,a i • v i‖^2 ≤ K*(∑ i,|a i| *r i)*(∑ i,|a i| *δ i) := by
  have hpoint (i : ι) : |a i| *‖v i‖ ≤
      Real.sqrt K*(Real.sqrt (|a i| *r i)*Real.sqrt (|a i| *δ i)) := by
    have hn := Real.le_sqrt_of_sq_le (hv i)
    have hmul := mul_le_mul_of_nonneg_left hn (abs_nonneg (a i))
    rw [Real.sqrt_mul (mul_nonneg hK (hr i)), Real.sqrt_mul hK] at hmul
    calc
      _ ≤ |a i| *(Real.sqrt K*Real.sqrt (r i)*Real.sqrt (δ i)) := hmul
      _ = _ := by
        rw [Real.sqrt_mul (abs_nonneg (a i)), Real.sqrt_mul (abs_nonneg (a i))]
        have hs := Real.sq_sqrt (abs_nonneg (a i))
        calc
          _ = Real.sqrt (|a i|)^2*(Real.sqrt K*Real.sqrt (r i)*Real.sqrt (δ i)) := by rw [hs]
          _ = _ := by ring
  have hR : 0 ≤ ∑ i,|a i| *r i := Finset.sum_nonneg fun i _ => mul_nonneg (abs_nonneg _) (hr i)
  have hD : 0 ≤ ∑ i,|a i| *δ i := Finset.sum_nonneg fun i _ => mul_nonneg (abs_nonneg _) (hδ i)
  have hsum := Real.sum_sqrt_mul_sqrt_le (s := (Finset.univ : Finset ι))
    (fun i => mul_nonneg (abs_nonneg (a i)) (hr i))
    (fun i => mul_nonneg (abs_nonneg (a i)) (hδ i))
  have hnorm : ‖∑ i,a i • v i‖ ≤ Real.sqrt K*Real.sqrt (∑ i,|a i| *r i)*Real.sqrt (∑ i,|a i| *δ i) := by
    calc
      _ ≤ ∑ i,‖a i • v i‖ := norm_sum_le _ _
      _ = ∑ i,|a i| *‖v i‖ := by simp only [norm_smul,Real.norm_eq_abs]
      _ ≤ ∑ i,Real.sqrt K*(Real.sqrt (|a i| *r i)*Real.sqrt (|a i| *δ i)) :=
        Finset.sum_le_sum fun i _ => hpoint i
      _ = Real.sqrt K*∑ i,Real.sqrt (|a i| *r i)*Real.sqrt (|a i| *δ i) := by rw [Finset.mul_sum]
      _ ≤ _ := by simpa only [mul_assoc] using mul_le_mul_of_nonneg_left hsum (Real.sqrt_nonneg K)
  have hs := mul_self_le_mul_self (norm_nonneg _) hnorm
  simp only [← pow_two,mul_pow,Real.sq_sqrt hK,Real.sq_sqrt hR,Real.sq_sqrt hD] at hs
  exact hs

def cubeVector {d : ℕ} (F : ClippingCube d → ℝ) : EuclideanSpace ℝ (ClippingCube d) :=
  WithLp.toLp 2 F

theorem cubeVector_norm_sq {d : ℕ} (F : ClippingCube d → ℝ) :
    ‖cubeVector F‖^2 = Fintype.card (ClippingCube d)*uniformCubeMean (fun x => F x^2) := by
  rw [EuclideanSpace.real_norm_sq_eq]
  change (∑ x, F x ^ 2) = _
  unfold uniformCubeMean
  field_simp

theorem uniform_square_sum_deficit {d : ℕ} {ι : Type*} [Fintype ι]
    (a r δ : ι → ℝ) (F : ι → ClippingCube d → ℝ) (K : ℝ)
    (hK : 0 ≤ K) (hr : ∀ i, 0 ≤ r i) (hδ : ∀ i, 0 ≤ δ i)
    (hF : ∀ i, uniformCubeMean (fun x => F i x^2) ≤ K*r i*δ i) :
    uniformCubeMean (fun x => (∑ i,a i*F i x)^2) ≤
      K*(∑ i,|a i| *r i)*(∑ i,|a i| *δ i) := by
  let M : ℝ := Fintype.card (ClippingCube d)
  have hM : 0<M := Nat.cast_pos.mpr Fintype.card_pos
  have hv (i : ι) : ‖cubeVector (F i)‖^2 ≤ (M*K)*r i*δ i := by
    rw [cubeVector_norm_sq]
    have h := mul_le_mul_of_nonneg_left (hF i) hM.le
    simpa only [M,mul_assoc] using h
  have h := norm_sum_deficit a r δ (fun i => cubeVector (F i)) (M*K)
    (mul_nonneg hM.le hK) hr hδ hv
  have he : (∑ i,a i • cubeVector (F i)) = cubeVector (fun x => ∑ i,a i*F i x) := by
    ext x
    simp [cubeVector]
  rw [he,cubeVector_norm_sq] at h
  change M*uniformCubeMean (fun x => (∑ i,a i*F i x)^2) ≤ _ at h
  apply (_root_.mul_le_mul_iff_right₀ hM).mp
  simpa only [mul_assoc, mul_comm, mul_left_comm] using h


def retainedFourierMass {d : ℕ} {ν : Type*} [Fintype ν]
    (A : ν → Finset (Fin d)) (w : ν → ℝ) (F : ClippingCube d → ℝ) : ℝ :=
  ∑ s,w s*|walshCoefficients F (A s)|

theorem retainedFourierMass_nonneg {d : ℕ} {ν : Type*} [Fintype ν]
    (A : ν → Finset (Fin d)) (w : ν → ℝ) (hw : ∀ s,0≤w s) (F : ClippingCube d → ℝ) :
    0≤retainedFourierMass A w F := Finset.sum_nonneg fun s _ => mul_nonneg (hw s) (abs_nonneg _)

theorem retainedFourierMass_sum {d : ℕ} {ν ι : Type*} [Fintype ν] [Fintype ι]
    (A : ν → Finset (Fin d)) (w : ν → ℝ) (hw : ∀ s,0≤w s)
    (a : ι → ℝ) (F : ι → ClippingCube d → ℝ) :
    retainedFourierMass A w (fun x => ∑ j,a j*F j x) ≤
      ∑ j,|a j| *retainedFourierMass A w (F j) := by
  unfold retainedFourierMass
  simp_rw [coefficient_finset_sum, coefficient_const_mul]
  calc
    _ ≤ ∑ s,w s*(∑ j,|a j*walshCoefficients (F j) (A s)|) :=
      Finset.sum_le_sum fun s _ => mul_le_mul_of_nonneg_left (Finset.abs_sum_le_sum_abs _ _) (hw s)
    _ = _ := by
      simp_rw [abs_mul, Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro j _
      apply Finset.sum_congr rfl
      intro s _
      ring

theorem fourierProject_sum {d : ℕ} {ι : Type*} [Fintype ι]
    (D : Finset (Finset (Fin d))) (a : ι → ℝ) (F : ι → ClippingCube d → ℝ)
    (x : ClippingCube d) :
    fourierProject D (fun x => ∑ j,a j*F j x) x =
      ∑ j,a j*fourierProject D (F j) x := by
  unfold fourierProject walshExpansion
  simp_rw [coefficient_finset_sum,coefficient_const_mul]
  have he (S : Finset (Fin d)) :
      (if S∈D then ∑ j,a j*walshCoefficients (F j) S else 0)*walshCharacter S x =
      ∑ j,a j*((if S∈D then walshCoefficients (F j) S else 0)*walshCharacter S x) := by
    by_cases hS : S∈D
    · simp only [if_pos hS, Finset.sum_mul,mul_assoc]
    · simp [hS]
  simp_rw [he]
  rw [Finset.sum_comm]
  simp_rw [← Finset.mul_sum]

/-- The whole-function Fourier defect follows from actual neuron defects. -/
theorem network_fourier_deficit {d : ℕ} {ν ι : Type*} [Fintype ν] [Fintype ι]
    (A : ν → Finset (Fin d)) (w : ν → ℝ) (hw : ∀ s,0≤w s)
    (D : Finset (Finset (Fin d))) (a r : ι → ℝ) (F : ι → ClippingCube d → ℝ)
    (K B : ℝ) (hK : 0≤K) (hr : ∀ j,0≤r j)
    (hmass : ∀ j,retainedFourierMass A w (F j) ≤ r j)
    (herror : ∀ j,uniformCubeMean (fun x => (F j x-fourierProject D (F j) x)^2) ≤
      K*r j*(r j-retainedFourierMass A w (F j)))
    (hbudget : (∑ j,|a j| *r j) ≤ B) :
    retainedFourierMass A w (fun x => ∑ j,a j*F j x) ≤ B ∧
    uniformCubeMean (fun x => ((∑ j,a j*F j x)-fourierProject D (fun x => ∑ j,a j*F j x) x)^2) ≤
      K*B*(B-retainedFourierMass A w (fun x => ∑ j,a j*F j x)) := by
  let Q := fun j => retainedFourierMass A w (F j)
  let totalQ := retainedFourierMass A w (fun x => ∑ j,a j*F j x)
  let totalR := ∑ j,|a j| *r j
  let totalA := ∑ j,|a j| *Q j
  have hQR : totalA≤totalR := Finset.sum_le_sum fun j _ =>
    mul_le_mul_of_nonneg_left (hmass j) (abs_nonneg (a j))
  have hQ : totalQ≤totalA := retainedFourierMass_sum A w hw a F
  have hR : 0≤totalR := Finset.sum_nonneg fun j _ => mul_nonneg (abs_nonneg _) (hr j)
  have hsum := uniform_square_sum_deficit a r (fun j => r j-Q j)
    (fun j x => F j x-fourierProject D (F j) x) K hK hr
    (fun j => sub_nonneg.mpr (hmass j)) herror
  have hs : (∑ j,|a j| *(r j-Q j)) = totalR-totalA := by
    simp only [mul_sub,Finset.sum_sub_distrib,totalR,totalA]
  rw [hs] at hsum
  have he (x : ClippingCube d) :
      ((∑ j,a j*F j x)-fourierProject D (fun x => ∑ j,a j*F j x) x) =
        ∑ j,a j*(F j x-fourierProject D (F j) x) := by
    rw [fourierProject_sum]
    simp only [mul_sub,Finset.sum_sub_distrib]
  constructor
  · exact hQ.trans (hQR.trans hbudget)
  · simp_rw [he]
    apply hsum.trans
    have hprod : totalR*(totalR-totalA) ≤ B*(B-totalQ) :=
      mul_le_mul hbudget (by linarith) (sub_nonneg.mpr hQR) (hR.trans hbudget)
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_left hprod hK


def incomingEuclideanNorm {d N : ℕ} (w : Weights d N 0) (j : Fin N) : ℝ :=
  Real.sqrt (∑ i,(incomingAtoms w j i)^2)

def networkVariationBudget {d N : ℕ} (w : Weights d N 0) : ℝ :=
  weightedSquaredNorm w/(2*Real.sqrt d)

theorem actual_atomic_budget {d N : ℕ} (hd : 0<d) (hN : 0<N) (w : Weights d N 0) :
    (∑ j,|readoutAtoms w j| *incomingEuclideanNorm w j) ≤ networkVariationBudget w := by
  have hdR : 0<(d : ℝ) := by exact_mod_cast hd
  have hs : 0<2*Real.sqrt (d : ℝ) := mul_pos (by norm_num) (Real.sqrt_pos.mpr hdR)
  apply (le_div_iff₀ hs).mpr
  have h := atomicWeightedCost_le_weightedSquaredNorm hN w
  have he : atomicWeightedCost (incomingAtoms w) (readoutAtoms w) =
      (∑ j,|readoutAtoms w j| *incomingEuclideanNorm w j)*(2*Real.sqrt (d : ℝ)) := by
    unfold atomicWeightedCost incomingEuclideanNorm incomingAtomCost
    simp_rw [Real.sqrt_mul hdR.le]
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [he] at h
  exact h

/-- Literal shallow Gaussian network: analytic neuron inequalities imply
both the actual code-mass bound and population squared residual bound. -/
theorem actual_network_fourier_deficit {d N : ℕ} {ν : Type*} [Fintype ν]
    (hd : 0<d) (hN : 0<N) (A : ν → Finset (Fin d)) (weight : ν → ℝ)
    (hw : ∀ s,0≤weight s) (D : Finset (Finset (Fin d)))
    (φ : ℝ → ℝ) (w : Weights d N 0) (K : ℝ) (hK : 0≤K)
    (hmass : ∀ j,retainedFourierMass A weight (fun x => firstHidden φ w x j) ≤ incomingEuclideanNorm w j)
    (herror : ∀ j,uniformCubeMean (fun x =>
      (firstHidden φ w x j-fourierProject D (fun x => firstHidden φ w x j) x)^2) ≤
      K*incomingEuclideanNorm w j*(incomingEuclideanNorm w j-
        retainedFourierMass A weight (fun x => firstHidden φ w x j))) :
    retainedFourierMass A weight (networkOutput φ w) ≤ networkVariationBudget w ∧
    uniformCubeMean (fun x => (networkOutput φ w x-fourierProject D (networkOutput φ w) x)^2) ≤
      K*networkVariationBudget w*(networkVariationBudget w-retainedFourierMass A weight (networkOutput φ w)) := by
  have h := network_fourier_deficit A weight hw D (readoutAtoms w) (incomingEuclideanNorm w)
    (fun j x => firstHidden φ w x j) K (networkVariationBudget w) hK
    (fun j => Real.sqrt_nonneg _) hmass herror (actual_atomic_budget hd hN w)
  have he : (fun x => ∑ j,readoutAtoms w j*firstHidden φ w x j) = networkOutput φ w := by
    funext x
    simp [networkOutput,finalHidden,readoutAtoms]
  rw [he] at h
  exact h

end NeuralGeneralization.OnlineLower


