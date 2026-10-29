import Mathlib.Analysis.Matrix.PosDef
import Mathlib.Analysis.Matrix.HermitianFunctionalCalculus
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

open Matrix
open scoped BigOperators Matrix
namespace ConditionalNonpolynomial.Analytic

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

structure OrthogonalSpectrum (A : Matrix ι ι ℝ) where
  basis : Matrix ι ι ℝ
  values : ι → ℝ
  nonneg : ∀ i, 0 ≤ values i
  left_inv : basisᵀ * basis = 1
  right_inv : basis * basisᵀ = 1
  reconstruct : A = basis * diagonal values * basisᵀ

noncomputable def psdSpectrum {A : Matrix ι ι ℝ} (hA : A.PosSemidef) :
    OrthogonalSpectrum A where
  basis := hA.isHermitian.eigenvectorUnitary
  values := hA.isHermitian.eigenvalues
  nonneg := hA.eigenvalues_nonneg
  left_inv := by
    simpa only [star_eq_conjTranspose, conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_star_mul_self hA.isHermitian.eigenvectorUnitary
  right_inv := by
    simpa only [Unitary.coe_star, star_eq_conjTranspose,
      conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_mul_star_self hA.isHermitian.eigenvectorUnitary
  reconstruct := by
    simpa only [Unitary.conjStarAlgAut_apply, star_eq_conjTranspose,
      conjTranspose_eq_transpose_of_trivial, Function.comp_def, RCLike.ofReal_real_eq_id,
      id_eq] using hA.isHermitian.spectral_theorem

namespace OrthogonalSpectrum
variable {A : Matrix ι ι ℝ} (s : OrthogonalSpectrum A)
noncomputable def root : Matrix ι ι ℝ :=
  s.basis * diagonal (fun i => Real.sqrt (s.values i)) * s.basisᵀ

lemma root_transpose : s.rootᵀ = s.root := by
  simp only [root, transpose_mul, transpose_transpose, diagonal_transpose, Matrix.mul_assoc]

lemma root_mul_root : s.root * s.root = A := by
  apply Eq.trans _ s.reconstruct.symm
  unfold root
  simp only [Matrix.mul_assoc, ← Matrix.mul_assoc s.basisᵀ s.basis, s.left_inv,
    Matrix.one_mul]
  rw [← Matrix.mul_assoc (diagonal _) (diagonal _), diagonal_mul_diagonal]
  simp only [Real.mul_self_sqrt (s.nonneg _)]

lemma root_gram : s.root * s.rootᵀ = A := by
  rw [s.root_transpose, s.root_mul_root]
end OrthogonalSpectrum

lemma orthogonal_entry_bound {U : Matrix ι ι ℝ} (hU : U*Uᵀ=1) (i j : ι) :
    |U i j| ≤ 1 := by
  have hsum : ∑ k, (U i k)^2 = 1 := by
    have h := congrFun (congrFun hU i) i
    simpa only [Matrix.mul_apply, transpose_apply, one_apply_eq, pow_two] using h
  have h := Finset.single_le_sum (fun k (_ : k ∈ (Finset.univ : Finset ι)) =>
      sq_nonneg (U i k)) (Finset.mem_univ j)
  apply abs_le_of_sq_le_sq _ (by norm_num)
  simpa [hsum] using h

omit [DecidableEq ι] in
lemma matrix_mul_entry_bound {U V : Matrix ι ι ℝ} {a b : ℝ}
    (ha : ∀ i j, |U i j| ≤ a) (hb : ∀ i j, |V i j| ≤ b)
    (ha0 : 0 ≤ a) (_hb0 : 0 ≤ b) (i j : ι) :
    |(U*V) i j| ≤ (Fintype.card ι : ℝ)*a*b := by
  calc
    |(U*V) i j| ≤ ∑ k, |U i k * V k j| := by
      rw [Matrix.mul_apply]; exact Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _k : ι, a*b := by
      apply Finset.sum_le_sum
      intro k hk
      rw [abs_mul]
      exact mul_le_mul (ha i k) (hb k j) (abs_nonneg _) ha0
    _ = _ := by simp; ring

omit [DecidableEq ι] in
lemma matrix_triple_entry_bound {U E V : Matrix ι ι ℝ} {a : ℝ}
    (hU : ∀ i j, |U i j| ≤ 1) (hE : ∀ i j, |E i j| ≤ a)
    (hV : ∀ i j, |V i j| ≤ 1) (ha : 0 ≤ a) (i j : ι) :
    |(U*E*V) i j| ≤ (Fintype.card ι : ℝ)^2*a := by
  have hUE := matrix_mul_entry_bound hU hE (by norm_num) ha
  have h := matrix_mul_entry_bound hUE hV (by positivity) (by norm_num) i j
  convert h using 1
  ring

lemma sqrt_difference_sq (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (Real.sqrt a - Real.sqrt b)^2 ≤ |a-b| := by
  have ha2 := Real.sq_sqrt ha
  have hb2 := Real.sq_sqrt hb
  have ha0 := Real.sqrt_nonneg a
  have hb0 := Real.sqrt_nonneg b
  rcases le_total a b with h | h
  · rw [abs_of_nonpos (sub_nonpos.mpr h)]
    have hsq := Real.sqrt_le_sqrt h
    have hmul := mul_nonneg ha0 (sub_nonneg.mpr hsq)
    nlinarith
  · rw [abs_of_nonneg (sub_nonneg.mpr h)]
    have hsq := Real.sqrt_le_sqrt h
    have hmul := mul_nonneg hb0 (sub_nonneg.mpr hsq)
    nlinarith

lemma overlap_sqrt_difference_sq (a b u : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hu : |u| ≤ 1) :
    ((Real.sqrt a - Real.sqrt b)*u)^2 ≤ |(a-b)*u| := by
  have h := mul_le_mul_of_nonneg_right (sqrt_difference_sq a b ha hb) (sq_nonneg u)
  have hu2 : u^2 ≤ |u| := by nlinarith [sq_abs u, abs_nonneg u]
  have h' := mul_le_mul_of_nonneg_left hu2 (abs_nonneg (a-b))
  rw [abs_mul]
  nlinarith

lemma spectrum_mixed_difference {A B : Matrix ι ι ℝ}
    (s : OrthogonalSpectrum A) (t : OrthogonalSpectrum B) (i j : ι) :
    (s.basisᵀ * (A-B) * t.basis) i j =
      (s.values i-t.values j)*(s.basisᵀ*t.basis) i j := by
  have hA : s.basisᵀ*A = diagonal s.values*s.basisᵀ := by
    calc
      _ = s.basisᵀ*(s.basis*diagonal s.values*s.basisᵀ) :=
        congrArg (fun X => s.basisᵀ*X) s.reconstruct
      _ = _ := by simp only [← Matrix.mul_assoc, s.left_inv, Matrix.one_mul]
  have hB : B*t.basis = t.basis*diagonal t.values := by
    calc
      _ = (t.basis*diagonal t.values*t.basisᵀ)*t.basis :=
        congrArg (fun X => X*t.basis) t.reconstruct
      _ = _ := by simp only [Matrix.mul_assoc, t.left_inv, Matrix.mul_one]
  rw [Matrix.mul_sub, Matrix.sub_mul, hA, Matrix.mul_assoc s.basisᵀ B t.basis, hB,
    ← Matrix.mul_assoc s.basisᵀ t.basis, Matrix.mul_assoc (diagonal s.values),
    Matrix.sub_apply, diagonal_mul, mul_diagonal]
  ring

lemma spectrum_mixed_root_difference {A B : Matrix ι ι ℝ}
    (s : OrthogonalSpectrum A) (t : OrthogonalSpectrum B) (i j : ι) :
    (s.basisᵀ * (s.root-t.root) * t.basis) i j =
      (Real.sqrt (s.values i)-Real.sqrt (t.values j))*(s.basisᵀ*t.basis) i j := by
  have hA : s.basisᵀ*s.root = diagonal (fun i => Real.sqrt (s.values i))*s.basisᵀ := by
    unfold OrthogonalSpectrum.root
    simp only [← Matrix.mul_assoc, s.left_inv, Matrix.one_mul]
  have hB : t.root*t.basis = t.basis*diagonal (fun i => Real.sqrt (t.values i)) := by
    unfold OrthogonalSpectrum.root
    simp only [Matrix.mul_assoc, t.left_inv, Matrix.mul_one]
  rw [Matrix.mul_sub, Matrix.sub_mul, hA,
    Matrix.mul_assoc s.basisᵀ t.root t.basis, hB,
    ← Matrix.mul_assoc s.basisᵀ t.basis, Matrix.mul_assoc (diagonal _),
    Matrix.sub_apply, diagonal_mul, mul_diagonal]
  ring

lemma spectrum_overlap_orthogonal {A B : Matrix ι ι ℝ}
    (s : OrthogonalSpectrum A) (t : OrthogonalSpectrum B) :
    (s.basisᵀ*t.basis)*(s.basisᵀ*t.basis)ᵀ=1 := by
  rw [transpose_mul, transpose_transpose]
  simp only [Matrix.mul_assoc, ← Matrix.mul_assoc t.basis t.basisᵀ,
    t.right_inv, Matrix.one_mul, s.left_inv]

/-- The spectral square roots are close whenever their Gram matrices are close.
The deliberately coarse dimension factor avoids any hidden operator-norm hypothesis. -/
lemma spectrum_root_close {A B : Matrix ι ι ℝ}
    (s : OrthogonalSpectrum A) (t : OrthogonalSpectrum B) (ε : ℝ) (hε : 0 ≤ ε)
    (hAB : ∀ i j, |A i j-B i j| ≤ ε^2) (i j : ι) :
    |s.root i j-t.root i j| ≤ (Fintype.card ι : ℝ)^3*ε := by
  have hU := orthogonal_entry_bound s.right_inv
  have hV := orthogonal_entry_bound t.right_inv
  have hUt : ∀ i j, |s.basisᵀ i j| ≤ 1 := fun i j => hU j i
  have hVt : ∀ i j, |t.basisᵀ i j| ≤ 1 := fun i j => hV j i
  have hE : ∀ i j, |(s.basisᵀ*(A-B)*t.basis) i j| ≤
      (Fintype.card ι : ℝ)^2*ε^2 :=
    matrix_triple_entry_bound hUt hAB hV (sq_nonneg ε)
  have hR := orthogonal_entry_bound (spectrum_overlap_orthogonal s t)
  have hD : ∀ i j, |(s.basisᵀ*(s.root-t.root)*t.basis) i j| ≤
      (Fintype.card ι : ℝ)*ε := by
    intro i j
    apply abs_le_of_sq_le_sq _ (by positivity)
    rw [spectrum_mixed_root_difference]
    have hh := overlap_sqrt_difference_sq (s.values i) (t.values j)
      ((s.basisᵀ*t.basis) i j) (s.nonneg i) (t.nonneg j) (hR i j)
    have he := hE i j
    rw [spectrum_mixed_difference] at he
    nlinarith
  have h := matrix_triple_entry_bound hU hD hVt (by positivity) i j
  have hback : s.basis*(s.basisᵀ*(s.root-t.root)*t.basis)*t.basisᵀ = s.root-t.root := by
    simp only [← Matrix.mul_assoc, s.right_inv, Matrix.one_mul]
    rw [Matrix.mul_assoc, t.right_inv, Matrix.mul_one]
  rw [hback, Matrix.sub_apply] at h
  convert h using 1
  ring

/-- Actual common-dimensional features for two positive semidefinite matrices.
No positive definiteness or lower eigenvalue bound is required. -/
theorem psd_close_features {A B : Matrix ι ι ℝ} (hA : A.PosSemidef) (hB : B.PosSemidef)
    (ε : ℝ) (hε : 0 ≤ ε) (hAB : ∀ i j, |A i j-B i j| ≤ ε^2) :
    ∃ F G : Matrix ι ι ℝ, F*Fᵀ=A ∧ G*Gᵀ=B ∧
      ∀ i j, |F i j-G i j| ≤ (Fintype.card ι : ℝ)^3*ε := by
  exact ⟨(psdSpectrum hA).root, (psdSpectrum hB).root,
    (psdSpectrum hA).root_gram, (psdSpectrum hB).root_gram,
    spectrum_root_close (psdSpectrum hA) (psdSpectrum hB) ε hε hAB⟩

/-- The same coupling with the squared Euclidean distance of each pair of feature rows. -/
theorem psd_close_feature_rows {A B : Matrix ι ι ℝ}
    (hA : A.PosSemidef) (hB : B.PosSemidef) (ε : ℝ) (hε : 0 ≤ ε)
    (hAB : ∀ i j, |A i j-B i j| ≤ ε^2) :
    ∃ F G : Matrix ι ι ℝ,
      (∀ i j, ∑ k, F i k*F j k = A i j) ∧
      (∀ i j, ∑ k, G i k*G j k = B i j) ∧
      ∀ i, ∑ k, (F i k-G i k)^2 ≤ (Fintype.card ι : ℝ)^7*ε^2 := by
  obtain ⟨F,G,hF,hG,hclose⟩ := psd_close_features hA hB ε hε hAB
  refine ⟨F,G,?_,?_,?_⟩
  · intro i j
    exact congrFun (congrFun hF i) j
  · intro i j
    exact congrFun (congrFun hG i) j
  · intro i
    calc
      ∑ k, (F i k-G i k)^2 ≤ ∑ _k : ι, ((Fintype.card ι : ℝ)^3*ε)^2 := by
        apply Finset.sum_le_sum
        intro k hk
        have h := (sq_le_sq₀ (abs_nonneg (F i k-G i k))
          (show 0 ≤ (Fintype.card ι : ℝ)^3*ε by positivity)).mpr (hclose i k)
        simpa only [sq_abs] using h
      _ = _ := by simp; ring

end ConditionalNonpolynomial.Analytic
