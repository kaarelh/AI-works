import NeuralGeneralization.OnlineLowerSoftplusBasic
import NeuralGeneralization.OnlineLowerReluSynthesisZero
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

/-! # Energy-preserving large-width softplus approximation of a strict ReLU witness -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLowerSoftplus
open ConcreteModel OnlineLower

lemma widthEnergy_atoms {d q : ℕ} (net : Weights d q 0) :
    (Finset.univ.sum (fun j : Fin q => incomingAtomCost (incomingAtoms net j) / (q:ℝ) +
      (q:ℝ) * (readoutAtoms (d:=d) (N:=q) net j)^2)) = weightedSquaredNorm net := by
  unfold incomingAtomCost incomingAtoms readoutAtoms weightedSquaredNorm
  simp only [Finset.univ_eq_empty, Finset.sum_empty, add_zero,
    Finset.sum_add_distrib]
  rw [← Finset.sum_div, ← Finset.mul_sum, ← Finset.mul_sum]
  ring

/-- The exact finite-width embedding includes disconnected zero-readout pads.
The softplus offset at zero therefore creates no additional output. -/
theorem embed_relu_witness {d q N : ℕ} (hq : 0 < q) (hN : q ≤ N)
    (net : Weights d q 0) :
    ∃ w : Weights d N 0,
      weightedSquaredNorm w = weightedSquaredNorm net ∧
      ∀ x, |networkOutput softplus w x - networkOutput (fun t => max 0 t) net x| ≤
        Real.log 2 * (∑ j, |readoutAtoms net j|) / Real.sqrt ((N:ℝ)/(q:ℝ)) := by
  have hqr : (0:ℝ) < q := by exact_mod_cast hq
  have hNr : (0:ℝ) < N := by exact_mod_cast (hq.trans_le hN)
  let s := Real.sqrt ((N:ℝ)/(q:ℝ))
  have hs : 0 < s := Real.sqrt_pos.mpr (div_pos hNr hqr)
  have hs2 : s^2 = (N:ℝ)/(q:ℝ) := Real.sq_sqrt (div_nonneg hNr.le hqr.le)
  let a := incomingAtoms net
  let c := readoutAtoms net
  let a' : Fin q → Fin (d+1) → ℝ := fun j k => s * a j k
  let c' : Fin q → ℝ := fun j => c j / s
  have hcap : (∑ _j : Fin q, (1:ℕ)) ≤ N := by simpa using hN
  let e := allocationEquiv (fun _j : Fin q => 1) hcap
  let w := allocatedWeights (fun _j : Fin q => 1) e a' c'
  refine ⟨w, ?_, ?_⟩
  · rw [weightedSquaredNorm_allocated _ (fun _ => by norm_num)]
    rw [← widthEnergy_atoms net]
    apply Finset.sum_congr rfl
    intro j _
    simp only [Nat.cast_one, mul_one, div_one]
    change incomingAtomCost (a' j)/(N:ℝ) + (N:ℝ)*(c j/s)^2 = _
    rw [incomingAtomCost_scale, div_pow, hs2]
    dsimp [a,c]
    field_simp
  · intro x
    rw [networkOutput_allocated _ (fun _ => by norm_num), networkOutput_eq_atomicScore]
    have hin (j : Fin q) : (∑ k, a' j k * inputVector x k) =
        s * ∑ k, a j k * inputVector x k := by
      dsimp [a']; rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intro k _; ring
    simp_rw [hin]
    change |(∑ j, c j / s * softplus (s * ∑ k, a j k * inputVector x k)) -
      ∑ j, c j * max 0 (∑ k, a j k * inputVector x k)| ≤ _
    rw [← Finset.sum_sub_distrib]
    calc
      _ ≤ ∑ j, |c j / s * softplus (s * ∑ k, a j k * inputVector x k) -
          c j * max 0 (∑ k, a j k * inputVector x k)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ j, |c j| * (Real.log 2 / s) := by
        apply Finset.sum_le_sum
        intro j _
        have he : c j/s*softplus (s*∑ k,a j k*inputVector x k)-
            c j*max 0 (∑ k,a j k*inputVector x k) =
            c j*(softplus (s*∑ k,a j k*inputVector x k)/s-
              max 0 (∑ k,a j k*inputVector x k)) := by ring
        rw [he,abs_mul]
        exact mul_le_mul_of_nonneg_left (scaled_softplus_relu_error s _ hs) (abs_nonneg _)
      _ = _ := by rw [← Finset.sum_mul]; dsimp [s,c]; ring

lemma embedding_error_tendsto {d q : ℕ} (hq : 0 < q) (net : Weights d q 0) :
    Tendsto (fun N : ℕ => Real.log 2 * (∑ j, |readoutAtoms net j|) /
      Real.sqrt ((N:ℝ)/(q:ℝ))) atTop (𝓝 0) := by
  have hqr : (0:ℝ) < q := by exact_mod_cast hq
  apply tendsto_const_nhds.div_atTop
  apply Real.tendsto_sqrt_atTop.comp
  exact tendsto_natCast_atTop_atTop.atTop_div_const hqr

/-- Every strict ReLU sign witness has softplus witnesses of exactly the same
Gaussian energy at every sufficiently large width. -/
theorem strict_relu_witness_all_large {d q : ℕ} (hq : 0 < q)
    (net : Weights d q 0) (g : BooleanFunction d)
    (hmargin : net ∈ marginEvent (fun t => max 0 t) (1/2) g) :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ N : ℕ, N₀ ≤ N →
      ∃ w : Weights d N 0, w ∈ marginEvent softplus (1/2) g ∧
        weightedSquaredNorm w = weightedSquaredNorm net := by
  have herr := embedding_error_tendsto hq net
  have he : ∀ᶠ N : ℕ in atTop, ∀ x : Cube d,
      Real.log 2 * (∑ j, |readoutAtoms net j|) / Real.sqrt ((N:ℝ)/(q:ℝ)) <
        labelReal (g x)*networkOutput (fun t=>max 0 t) net x - 1/2 := by
    apply Filter.eventually_all.2
    intro x
    exact (tendsto_order.1 herr).2 _ (by have hh:=hmargin x; linarith)
  obtain ⟨N₀,hN₀⟩ := eventually_atTop.mp he
  refine ⟨max q N₀, hq.trans_le (le_max_left _ _), ?_⟩
  intro N hN
  obtain ⟨w,hw,herror⟩ := embed_relu_witness hq ((le_max_left _ _).trans hN) net
  refine ⟨w,?_,hw⟩
  intro x
  have he := (hN₀ N ((le_max_right _ _).trans hN)) x
  have hdif := (herror x).trans_lt he
  have hab : |labelReal (g x)| = 1 := by cases g x <;> norm_num [labelReal]
  have hlabel : |labelReal (g x) * (networkOutput softplus w x -
      networkOutput (fun t=>max 0 t) net x)| <
      labelReal (g x)*networkOutput (fun t=>max 0 t) net x-1/2 := by
    rwa [abs_mul,hab,one_mul]
  have hh := (abs_lt.mp hlabel).1
  change (1/2:ℝ) < labelReal (g x)*networkOutput softplus w x
  nlinarith

end NeuralGeneralization.OnlineLowerSoftplus
