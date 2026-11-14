import NeuralGeneralization.OnlineLowerReluCoverageEquality
import NeuralGeneralization.OnlineLowerReluSynthesisZero

/-! # The literal finite-representation variation norm

The infimum is over all finite shallow affine ReLU representations of the
actual Boolean-cube function. It is not defined to be a Fourier norm.
-/

set_option maxHeartbeats 800000
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry ConcreteModel

/-- Sum of absolute readouts times Euclidean incoming norms, including bias. -/
def finiteVariationCost {d q : ℕ} (a : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ) : ℝ :=
  ∑ j, |c j| * Real.sqrt (∑ i, a j i ^ 2)

/-- Costs of all exact finite affine ReLU representations of a cube function. -/
def reluVariationCosts {d : ℕ} (F : Cube d → ℝ) : Set ℝ :=
  {B | ∃ (q : ℕ) (a : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ),
    (∀ x, atomicScore (fun t => max t 0) a c x = F x) ∧ B = finiteVariationCost a c}

/-- The manuscript's variation infimum, taken over actual representations. -/
def reluVariation {d : ℕ} (F : Cube d → ℝ) : ℝ := sInf (reluVariationCosts F)

lemma finiteVariationCost_nonneg {d q : ℕ} (a : Fin q → Fin (d+1) → ℝ)
    (c : Fin q → ℝ) : 0 ≤ finiteVariationCost a c :=
  Finset.sum_nonneg (fun _ _ => mul_nonneg (abs_nonneg _) (Real.sqrt_nonneg _))

lemma atomicWeightedCost_eq_variation {d q : ℕ} (a : Fin q → Fin (d+1) → ℝ)
    (c : Fin q → ℝ) : atomicWeightedCost a c = 2 * Real.sqrt (d : ℝ) * finiteVariationCost a c := by
  unfold atomicWeightedCost finiteVariationCost incomingAtomCost
  simp_rw [Real.sqrt_mul (Nat.cast_nonneg d)]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

lemma atomOutput_eq_affine {d : ℕ} (a : Fin (d+1) → ℝ) :
    atomOutput (fun t => max t 0) a =
      fun x => max (cubeAffine (a 0) (fun i => a i.succ) x) 0 := by
  funext x
  unfold atomOutput
  rw [Fin.sum_univ_succ]
  simp only [inputVector,Fin.cases_zero,Fin.cases_succ,mul_one]
  rfl

/-- Every finite representation obeys an established affine atomic dual bound. -/
theorem retained_mass_le_finiteVariationCost {d q : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w : ι → ℝ) (hw : ∀ i, 0 ≤ w i)
    (hatom : ∀ (u : Fin d → ℝ) (b : ℝ),
      retainedFourierMass A w (fun x => max (cubeAffine b u x) 0) ≤
        Real.sqrt (b^2 + ∑ i,u i^2))
    (a : Fin q → Fin (d+1) → ℝ) (c : Fin q → ℝ) :
    retainedFourierMass A w (atomicScore (fun t => max t 0) a c) ≤ finiteVariationCost a c := by
  apply (retainedFourierMass_sum A w hw c (fun j => atomOutput (fun t => max t 0) (a j))).trans
  apply Finset.sum_le_sum
  intro j _
  apply mul_le_mul_of_nonneg_left _ (abs_nonneg _)
  rw [atomOutput_eq_affine,Fin.sum_univ_succ]
  exact hatom (fun i => a j i.succ) (a j 0)

lemma retained_mass_fourier_series {d : ℕ} {ι : Type*} [Fintype ι]
    (A : ι → Finset (Fin d)) (w c : ι → ℝ) (hA : Function.Injective A) :
    retainedFourierMass A w (fun x => ∑ i,c i * walshCharacter (A i) x) =
      ∑ i,w i * |c i| := by
  classical
  unfold retainedFourierMass
  simp_rw [coefficient_finset_sum,coefficient_const_mul,walshCoefficients_character,hA.eq_iff]
  simp

/-- Exact variation cost of an even-support Fourier series whenever its
weighted atomic inequality has been proved. Both inequalities concern the
literal infimum over all finite affine ReLU networks. -/
theorem reluVariation_fourier_of_atom_bound {d : ℕ} {ι : Type*} [Fintype ι]
    (hd : 0 < d) (A : ι → Finset (Fin d)) (r : ι → ℕ) (c : ι → ℝ)
    (hA : Function.Injective A) (hcard : ∀ i,(A i).card = 2*r i+2)
    (hatom : ∀ (u : Fin d → ℝ) (b : ℝ),
      retainedFourierMass A (fun i => evenReluCost (r i))
        (fun x => max (cubeAffine b u x) 0) ≤ Real.sqrt (b^2 + ∑ i,u i^2)) :
    reluVariation (fun x => ∑ i,c i * walshCharacter (A i) x) =
      ∑ i,evenReluCost (r i) * |c i| := by
  classical
  let F : Cube d → ℝ := fun x => ∑ i,c i * walshCharacter (A i) x
  let W : ℝ := ∑ i,evenReluCost (r i)*|c i|
  have hw (i : ι) : 0 ≤ evenReluCost (r i) :=
    div_nonneg (Real.sqrt_nonneg _) (evenReluKappa_pos _).le
  have hlower (B : ℝ) (hB : B ∈ reluVariationCosts F) : W ≤ B := by
    obtain ⟨q,a,b,hscore,rfl⟩ := hB
    have h := retained_mass_le_finiteVariationCost A (fun i => evenReluCost (r i)) hw hatom a b
    have heq : atomicScore (fun t => max t 0) a b = F := funext hscore
    rw [heq] at h
    exact (retained_mass_fourier_series A (fun i => evenReluCost (r i)) c hA).symm.trans_le h
  let N : ℕ := Fintype.card ι * Fintype.card (Cube d) + 1
  have hN : 0 < N := by dsimp [N]; omega
  obtain ⟨v,hv,henergy⟩ := relu_fourier_score_exact_at_width (N:=N) hd A r c hcard hN
    (by dsimp [N]; omega)
  have hconventions : (fun t : ℝ => max 0 t) = (fun t : ℝ => max t 0) := funext (fun t => max_comm 0 t)
  have hscore (x : Cube d) :
      atomicScore (fun t => max t 0) (incomingAtoms v) (readoutAtoms v) x = F x := by
    rw [← networkOutput_eq_atomicScore]
    simpa only [hconventions] using hv x
  have hmem : finiteVariationCost (incomingAtoms v) (readoutAtoms v) ∈ reluVariationCosts F :=
    ⟨N,incomingAtoms v,readoutAtoms v,hscore,rfl⟩
  have hcost : finiteVariationCost (incomingAtoms v) (readoutAtoms v) ≤ W := by
    have h := atomicWeightedCost_le_weightedSquaredNorm hN v
    rw [atomicWeightedCost_eq_variation,henergy] at h
    have hsum : (∑ i,|c i| * evenReluCost (r i)) = W := by dsimp [W]; simp_rw [mul_comm]
    rw [hsum] at h
    exact (mul_le_mul_iff_right₀ (by positivity : 0 < 2 * Real.sqrt (d : ℝ))).mp h
  have heq : finiteVariationCost (incomingAtoms v) (readoutAtoms v) = W :=
    le_antisymm hcost (hlower _ hmem)
  change sInf (reluVariationCosts F) = W
  apply IsLeast.csInf_eq
  constructor
  · rwa [heq] at hmem
  · exact hlower

lemma mem_fullRailSupport {p : ℕ} (size : Fin p → Bool → ℕ)
    (τ : Finset (Fin p)) (j : Fin (railDimension size)) :
    j ∈ fullRailSupport size τ ↔
      ((railIndex size).symm j).2.1 = decide (((railIndex size).symm j).1 ∈ τ) := by
  simp [fullRailSupport,mem_physicalRail]

lemma fullRailSupport_injective {p : ℕ} (size : Fin p → Bool → ℕ)
    (htwo : ∀ i side,2 ≤ size i side) : Function.Injective (fullRailSupport size) := by
  classical
  intro τ υ heq
  ext i
  let j : Fin (railDimension size) := railIndex size ⟨i,true,⟨0,by have := htwo i true; omega⟩⟩
  have hmem : j ∈ fullRailSupport size τ ↔ j ∈ fullRailSupport size υ := by rw [heq]
  have hj : (railIndex size).symm j = ⟨i,true,⟨0,by have := htwo i true; omega⟩⟩ :=
    (railIndex size).symm_apply_apply _
  have hjfst := congrArg (fun q : RailCoord size => q.1) hj
  have hjsnd := congrArg (fun q : RailCoord size => q.2.1) hj
  simp only [mem_fullRailSupport,hjfst,hjsnd] at hmem
  simpa using hmem

/-- The exact variation-infimum formula of the unequal-rail theorem, for
arbitrary real coefficients and all finite representations in the infimum. -/
theorem full_rail_variation_eq {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side,2 ≤ size i side)
    (heven : ∀ i side,Even (size i side))
    (R Δ : ℝ) (hΔ : 0 ≤ Δ) (hR : 6*Δ ≤ R)
    (hmin : ∀ i side,R ≤ (size i side : ℝ))
    (hdiff : ∀ i,|(size i true : ℝ)-size i false| ≤ Δ)
    (c : Finset (Fin p) → ℝ) :
    reluVariation (fun x => ∑ τ,c τ * walshCharacter (fullRailSupport size τ) x) =
      ∑ τ,fullRailCost size τ * |c τ| := by
  have hd : 0 < railDimension size := by
    let i : Fin p := ⟨0,by omega⟩
    let j : Fin (railDimension size) := railIndex size ⟨i,false,⟨0,by have := htwo i false; omega⟩⟩
    exact Nat.zero_lt_of_lt j.isLt
  apply reluVariation_fourier_of_atom_bound hd (fullRailSupport size)
    (fun τ => ((fullRailSupport size τ).card-2)/2) c
    (fullRailSupport_injective size htwo)
  · intro τ
    have ht := fullRailSupport_two_le (by omega) size htwo τ
    obtain ⟨n,hn⟩ := fullRailSupport_even size heven τ
    omega
  · exact full_rail_norm_of_size hp size htwo heven R Δ hΔ hR hmin hdiff

namespace Family

/-- Exact variation-infimum formula for the retained path-code Fourier space. -/
theorem retained_variation_eq (R k : ℕ) (hR : 36 ≤ R) (heven : Even R)
    (c : Finset (Fin (logicalDim k)) → ℝ) :
    reluVariation (fun x => ∑ s,c s * walshCharacter (targetSupport R k s) x) =
      ∑ s,weight R k s * |c s| := by
  have hR2 : 2 ≤ R := by omega
  have hd : 0 < railDimension (size R k) := by
    rw [physicalDimension_eq]
    have hp : 0 < pairDim k := by rw [pairDim_eq]; omega
    positivity
  have hweight : weight R k = fun s => evenReluCost (degreeIndex R k s) :=
    funext (weight_eq_evenReluCost R k hR2 heven)
  rw [hweight]
  apply reluVariation_fourier_of_atom_bound hd (targetSupport R k) (degreeIndex R k) c
    (physicalCode R k (by omega)).support_injective (degreeIndex_card R k hR2 heven)
  intro u bias
  rw [← hweight]
  exact affine_atom_retained_norm R k hR heven u bias

end Family
end NeuralGeneralization.OnlineLowerRelu
