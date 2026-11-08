import NeuralGeneralization.OnlineLowerTanhEmpiricalCompact

/-! # Exact least-squares refitting of a finite odd-lattice bulk -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def latticeRefitSlope {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) : ℝ :=
  (∑ i, (q i:ℝ)*d i)/(∑ i, (q i:ℝ)^2)

def latticeRefitResidual {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) (i : Fin n) : ℝ :=
  d i-(q i:ℝ)*latticeRefitSlope q d

lemma positive_lattice_square_sum {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) : 0 < ∑ i, (q i:ℝ)^2 := by
  apply Finset.sum_pos' (fun _ _ => sq_nonneg _)
  refine ⟨⟨0,hn⟩,Finset.mem_univ _,?_⟩
  exact sq_pos_of_pos (by exact_mod_cast hq ⟨0,hn⟩)

lemma latticeRefit_orthogonal {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (hV : (∑ i, (q i:ℝ)^2) ≠ 0) :
    (∑ i, (q i:ℝ)*latticeRefitResidual q d i)=0 := by
  simp only [latticeRefitResidual,mul_sub,Finset.sum_sub_distrib]
  have he : (∑ i, (q i:ℝ)*((q i:ℝ)*latticeRefitSlope q d))=
      (∑ i, (q i:ℝ)^2)*latticeRefitSlope q d := by
    rw [Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he,latticeRefitSlope,mul_div_cancel₀ _ hV,sub_self]

lemma latticeRefit_energy_identity {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) :
    (∑ i, (latticeRefitResidual q d i)^2)=
      (∑ i, (d i)^2)-2*latticeRefitSlope q d*(∑ i,(q i:ℝ)*d i)+
        (latticeRefitSlope q d)^2*(∑ i,(q i:ℝ)^2) := by
  simp only [latticeRefitResidual]
  have he (i : Fin n) : (d i-(q i:ℝ)*latticeRefitSlope q d)^2=
      (d i)^2-2*latticeRefitSlope q d*((q i:ℝ)*d i)+
        (latticeRefitSlope q d)^2*(q i:ℝ)^2 := by ring
  simp_rw [he]
  rw [Finset.sum_add_distrib,Finset.sum_sub_distrib,←Finset.mul_sum,←Finset.mul_sum]

lemma latticeRefit_energy_le {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (hV : 0 < ∑ i, (q i:ℝ)^2) :
    (∑ i, (latticeRefitResidual q d i)^2) ≤ ∑ i, (d i)^2 := by
  rw [latticeRefit_energy_identity]
  have hs : latticeRefitSlope q d*(∑ i,(q i:ℝ)^2)=∑ i,(q i:ℝ)*d i := by
    exact div_mul_cancel₀ _ (ne_of_gt hV)
  have hn := mul_nonneg (sq_nonneg (latticeRefitSlope q d)) hV.le
  have hs2 := congrArg (fun x : ℝ => latticeRefitSlope q d*x) hs
  nlinarith only [hs2,hn]

lemma latticeRefit_decomposition {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (a : ℝ) (i : Fin n) :
    a*(q i:ℝ)+d i=(a+latticeRefitSlope q d)*(q i:ℝ)+latticeRefitResidual q d i := by
  unfold latticeRefitResidual
  ring

/-- On a positive integer alphabet, the refit changes the spacing by at
most the largest original coordinate residual. -/
lemma latticeRefitSlope_abs_le {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) (ε : ℝ)
    (hd : ∀ i, |d i| ≤ ε) : |latticeRefitSlope q d| ≤ ε := by
  have hV := positive_lattice_square_sum hn q hq
  have hε : 0 ≤ ε := (abs_nonneg (d ⟨0,hn⟩)).trans (hd ⟨0,hn⟩)
  rw [latticeRefitSlope,abs_div,abs_of_pos hV]
  apply (div_le_iff₀ hV).mpr
  calc
    |∑ i, (q i:ℝ)*d i| ≤ ∑ i, |(q i:ℝ)*d i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ε*(q i:ℝ)^2 := by
      apply Finset.sum_le_sum
      intro i _
      rw [abs_mul,abs_of_nonneg (Nat.cast_nonneg _)]
      have hqi : (1:ℝ) ≤ q i := by exact_mod_cast hq i
      have hterm := mul_le_mul_of_nonneg_left (hd i) (Nat.cast_nonneg (q i))
      have hqq : (q i:ℝ) ≤ (q i:ℝ)^2 := by nlinarith
      exact hterm.trans (by nlinarith [mul_le_mul_of_nonneg_right hqq hε])
    _ = ε*(∑ i,(q i:ℝ)^2) := (Finset.mul_sum _ _ _).symm

lemma latticeRefitResidual_abs_le {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) (ε Q : ℝ)
    (hd : ∀ i, |d i| ≤ ε) (hQ : ∀ i, (q i:ℝ) ≤ Q) (i : Fin n) :
    |latticeRefitResidual q d i| ≤ (1+Q)*ε := by
  have hε : 0 ≤ ε := (abs_nonneg (d i)).trans (hd i)
  have hs := latticeRefitSlope_abs_le hn q hq d ε hd
  calc
    |latticeRefitResidual q d i| ≤ |d i|+|(q i:ℝ)*latticeRefitSlope q d| := abs_sub _ _
    _ = |d i|+(q i:ℝ)*|latticeRefitSlope q d| := by rw [abs_mul,show |(q i:ℝ)|=(q i:ℝ) from abs_of_nonneg (Nat.cast_nonneg _)]
    _ ≤ ε+(q i:ℝ)*ε := add_le_add (hd i) (mul_le_mul_of_nonneg_left hs (Nat.cast_nonneg _))
    _ ≤ (1+Q)*ε := by nlinarith [mul_le_mul_of_nonneg_right (hQ i) hε]

/-- Refit spacing converges to the same limit whenever all residuals tend
uniformly to zero. The dimension is allowed to vary arbitrarily. -/
theorem latticeRefit_spacing_tendsto
    (N : ℕ → ℕ) (hN : ∀ k, 0 < N k) (q : ∀ k, Fin (N k) → ℕ)
    (hq : ∀ k i, 0 < q k i) (d : ∀ k, Fin (N k) → ℝ)
    (a ε : ℕ → ℝ) (a₀ : ℝ)
    (hd : ∀ k i, |d k i| ≤ ε k)
    (ha : Tendsto a atTop (𝓝 a₀)) (hε : Tendsto ε atTop (𝓝 0)) :
    Tendsto (fun k => a k+latticeRefitSlope (q k) (d k)) atTop (𝓝 a₀) := by
  have hs : Tendsto (fun k => latticeRefitSlope (q k) (d k)) atTop (𝓝 0) :=
    squeeze_zero_norm' (Eventually.of_forall (fun k => by
      simpa only [Real.norm_eq_abs] using latticeRefitSlope_abs_le (hN k) (q k) (hq k) (d k) (ε k) (hd k))) hε
  simpa only [add_zero] using ha.add hs


/-- Empty finite bulks are harmless before the eventual positive-size tail. -/
lemma latticeRefit_orthogonal_positive {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ)
    (hq : ∀ i, 0 < q i) : (∑ i,(q i:ℝ)*latticeRefitResidual q d i)=0 := by
  by_cases hn : 0 < n
  · exact latticeRefit_orthogonal q d (positive_lattice_square_sum hn q hq).ne'
  · have hn0 : n=0 := by omega
    subst n
    simp

lemma latticeRefit_energy_le_all {n : ℕ} (q : Fin n → ℕ) (d : Fin n → ℝ) :
    (∑ i,(latticeRefitResidual q d i)^2) ≤ ∑ i,(d i)^2 := by
  by_cases hV : (∑ i,(q i:ℝ)^2)=0
  · simp [latticeRefitResidual,latticeRefitSlope,hV]
  · exact latticeRefit_energy_le q d (lt_of_le_of_ne
      (Finset.sum_nonneg (fun _ _ => sq_nonneg _)) (Ne.symm hV))

lemma latticeRefitSlope_abs_le_all {n : ℕ} (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) (d : Fin n → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (hd : ∀ i, |d i| ≤ ε) : |latticeRefitSlope q d| ≤ ε := by
  by_cases hn : 0 < n
  · exact latticeRefitSlope_abs_le hn q hq d ε hd
  · have hn0 : n=0 := by omega
    subst n
    simpa [latticeRefitSlope] using hε

end NeuralGeneralization.OnlineLowerTanh
