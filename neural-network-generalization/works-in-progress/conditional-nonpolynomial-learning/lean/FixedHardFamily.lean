import ClosedConditionalImpossibility
import NeuralGeneralization.GaussianOutputSymmetry

/-! A fixed hard family and one input law common to all sample lengths
from zero up to the budget, all eligible widths, and every canonical scale.
The zero-sample case follows from exact Gaussian output-sign symmetry. -/
noncomputable section
open scoped BigOperators
attribute [local instance] Classical.propDecidable
namespace ConditionalNonpolynomial
open NeuralGeneralization.ConcreteModel

def MajorityClass (b : CeilingConstants) (d n r : ℕ) (f : BooleanFunction d) : Prop :=
  ∃ gs : Fin (400*(d+1)) → BooleanFunction d,
    (∀ i, gs i ∈ ceilingClass b d n r) ∧ ∀ x, 0 < ∑ i, signedVote f (gs i) x

private theorem log2_mono {a b : ℕ} (h : a ≤ b) : Nat.log2 a ≤ Nat.log2 b := by
  simpa only [Nat.log2_eq_log_two] using Nat.log_mono_right h

private theorem resource_mono (b : CeilingConstants) (d r : ℕ) {m n : ℕ} (hm : m ≤ n) :
    ceilingResource d m r ≤ ceilingResource d n r ∧
    ceilingWidth b d m r ≤ ceilingWidth b d n r ∧
    ceilingClass b d m r ⊆ ceilingClass b d n r := by
  have hR : ceilingResource d m r ≤ ceilingResource d n r := by
    unfold ceilingResource
    omega
  refine ⟨hR, ?_, ?_⟩
  · unfold ceilingWidth
    exact Nat.add_le_add_right (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hR _)) _
  · rintro g ⟨c, hs, hd, he⟩
    exact ⟨c, hs.trans (Nat.pow_le_pow_left hR _),
      hd.trans (Nat.mul_le_mul_left _ (log2_mono hR)), he⟩

/-- A single law precedes the choice of sample length, width, and scale. -/
theorem hard_law_uniform_of_no_majority (b : CeilingConstants) (hceil : CeilingAt b)
    {d n r C : ℕ} (hd : 1 ≤ d) (hr : 1 ≤ r)
    (hpad : b.padding*Nat.log2 (ceilingResource d n r) ≤ r+2)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r := r) Real.tanh f C)
    (hno : ¬ MajorityClass b d n r f) :
    ∃ D : InputLaw d, ∀ m : ℕ, m ≤ n → ∀ N : ℕ,
      C ≤ N → ceilingWidth b d n r ≤ N → ∀ T : CanonicalSchedule,
      ∀ s : Fin m → Cube d,
      (1/16 : ℝ) < confidenceFailure D f
        (networkPosterior Real.tanh (1/2) (canonicalPrior T d N r) f s) := by
  obtain ⟨D, hD⟩ := exists_hard_inputLaw_of_no_majority f (ceilingClass b d n r) hno
  refine ⟨D, ?_⟩
  intro m hmn N hCN hwidth T s
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hσ : 0 < T.scale d (r+2) N / Real.sqrt N :=
    div_pos (T.positive d (r+2) N (by omega) (by omega) hN)
      (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN))
  have hmass := small_functionMass_pos (by omega : 0 < d) tanh_continuous f hf hCN hσ
  by_cases hmzero : m = 0
  · subst m
    change (1/16 : ℝ) < confidenceFailure D f
      (networkPosterior Real.tanh (1/2)
        (productGaussian d N r (smallVariance d N r (T.scale d (r+2) N / Real.sqrt N))) f s)
    rw [gaussian_empty_confidenceFailure tanh_continuous (1/2) _ f s hmass D]
    norm_num
  have hm : 1 ≤ m := by omega
  have hmono := resource_mono b d r hmn
  have hsmall := hceil T d m r C N hd hm hr
    ((Nat.mul_le_mul_left _ (log2_mono hmono.1)).trans hpad)
    (hmono.2.1.trans hwidth) hCN f hf s
  have hlarge : (5/6 : ℝ) ≤ ∑ g, if g ∈ ceilingClass b d n r then
      networkPosterior Real.tanh (1/2) (canonicalPrior T d N r) f s g else 0 := by
    apply hsmall.trans
    apply Finset.sum_le_sum
    intro g _
    by_cases hg : g ∈ ceilingClass b d m r
    · simp only [if_pos hg, if_pos (hmono.2.2 hg), le_refl]
    · simp only [if_neg hg]
      split_ifs
      · exact actualPosterior_nonneg _ _ _ f s hmass g
      · exact le_refl _
  by_contra hh
  obtain ⟨g, hg, he⟩ := actualPosterior_extract_weak Real.tanh (1/2)
    (canonicalPrior T d N r) f s hmass D (ceilingClass b d n r) hlarge (le_of_not_gt hh)
  exact (not_le_of_gt (hD g hg)) he

/-- The hard family and its polynomial-resource teachers are chosen before
any sample budget. Infinitely many dimensions admit one common hard law,
with no posterior-ceiling premise in this closed theorem. -/
theorem fixed_hard_family (hsep : PPoly ≠ TC1) :
    ∃ b : CeilingConstants, ∃ f : Family, f ∈ PPoly ∧
      ∃ C r : ℕ → ℕ, (∃ D e : ℕ, ∀ d,
        d+C d+(r d+2)+1 ≤ D*(d+2)^e) ∧
      (∀ d, 1 ≤ r d ∧ d ≤ r d+2 ∧
        realizesAtComplexity (r := r d) Real.tanh (f d) (C d)) ∧
      ∀ n : ℕ → ℕ, (∃ A k : ℕ, ∀ d, n d ≤ A*(d+2)^k) →
      ∀ d₀ : ℕ, ∃ d ≥ d₀, ∃ D : InputLaw d,
        ∀ m : ℕ, m ≤ n d → ∀ N : ℕ,
        C d ≤ N → ceilingWidth b d (n d) (r d) ≤ N →
        ∀ T : CanonicalSchedule, ∀ s : Fin m → Cube d,
        (1/16 : ℝ) < confidenceFailure D (f d)
          (networkPosterior Real.tanh (1/2) (canonicalPrior T d N (r d)) (f d) s) := by
  classical
  obtain ⟨b, hceil⟩ := analyticPosteriorCeiling
  have hhard : ∃ f, f ∈ PPoly ∧ f ∉ TC1 := by
    by_contra hh
    push Not at hh
    exact hsep (Set.Subset.antisymm (fun f hf => hh f hf) TC1_subset_PPoly)
  obtain ⟨f, hf, hnot⟩ := hhard
  obtain ⟨D, e, hteacher⟩ := PPoly_has_polynomial_teachers hf
  choose C r hr hdL hres hreal using hteacher
  refine ⟨b, f, hf, C, r, ⟨D, e, hres⟩, fun d => ⟨hr d, hdL d, hreal d⟩, ?_⟩
  intro n hn
  obtain ⟨A, k, hn⟩ := hn
  let B := A+D+1
  let m := max k e
  have hR (d : ℕ) : ceilingResource d (n d) (r d) ≤ B*(d+2)^m := by
    have hk : (d+2)^k ≤ (d+2)^m := Nat.pow_le_pow_right (by omega) (le_max_left _ _)
    have he : (d+2)^e ≤ (d+2)^m := Nat.pow_le_pow_right (by omega) (le_max_right _ _)
    have hp : 1 ≤ (d+2)^m := Nat.one_le_pow _ _ (by omega)
    have ha := (hn d).trans (Nat.mul_le_mul_left A hk)
    have hb := (hres d).trans (Nat.mul_le_mul_left D he)
    dsimp only [ceilingResource, B]
    nlinarith
  have hbad (j : ℕ) : ∃ d ≥ j, ¬ MajorityClass b d (n d) (r d) (f d) := by
    by_contra hh
    push Not at hh
    apply hnot
    apply mem_TC1_of_PPoly_eventually f hf
    refine ⟨400*(B^b.circuit+1)+1, m*b.circuit+1,
      b.circuit*(Nat.log2 B+1+2*m)+1, j, ?_⟩
    intro d hd
    obtain ⟨gs, hgs, hv⟩ := hh d hd
    obtain ⟨c, hs, hdepth, heval⟩ := compile_exact_majority (f d) gs hv _ _ hgs
    exact ⟨c, majority_size_polynomial (hR d) hs,
      majority_depth_logarithmic
        (FamilyResources.polynomial_log2_bound B m d _ (hR d)) hdepth, heval⟩
  intro d₀
  obtain ⟨d, hd, hno⟩ := hbad (max d₀ (2^(b.padding*(Nat.log2 B+1+2*m)+4)))
  have hcut : 2^(b.padding*(Nat.log2 B+1+2*m)+4) ≤ d := (le_max_right _ _).trans hd
  have hdpos : 1 ≤ d := (Nat.one_le_pow _ _ (by omega : 1 ≤ (2 : ℕ))).trans hcut
  have hpad := (FamilyResources.polynomial_padding b.padding B m d _ hcut (hR d)).trans (hdL d)
  obtain ⟨law, hlaw⟩ := hard_law_uniform_of_no_majority b hceil hdpos (hr d) hpad (f d) (hreal d) hno
  exact ⟨d, (le_max_left _ _).trans hd, law, hlaw⟩

#print axioms hard_law_uniform_of_no_majority
#print axioms fixed_hard_family
end ConditionalNonpolynomial
