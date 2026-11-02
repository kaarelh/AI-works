import NeuralGeneralization.SparsePatchCombinatorics
import NeuralGeneralization.FiniteSymmetrization

/-! The robust paper's distributional-only obstruction, for its explicitly
specified abstract prior. This is not a Gaussian neural-network counterexample. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.SparsePatches

abbrev Hypothesis (M r : ℕ) := Option (Patch M r)

def label {M r : ℕ} : Hypothesis M r → Fin M → Bool
  | none, _ => true
  | some B, x => decide (x ∈ B.val)

def exceptions {M r : ℕ} : Hypothesis M r → Finset (Fin M)
  | none => ∅
  | some B => B.val

/-- The two compression outputs are the two constant Boolean functions. -/
def compression {M r : ℕ} : Hypothesis M r → Bool
  | none => true
  | some _ => false

lemma exact_compression {M r : ℕ} (h : Hypothesis M r) (x : Fin M)
    (hx : x ∉ exceptions h) : label h x = compression h := by
  cases h with
  | none => rfl
  | some B => simpa [label, compression, exceptions] using hx

lemma population_exceptions_le {M r : ℕ} (h : Hypothesis M r) :
    ((exceptions h).card : ℝ)/M ≤ (r:ℝ)/M := by
  cases h with
  | none => simp [exceptions]; positivity
  | some B => simp [exceptions, patch_card]

def prior {M r : ℕ} (q : ℝ) : Hypothesis M r → ℝ
  | none => q
  | some _ => (1-q)/Nat.choose M r

lemma prior_nonneg {M r : ℕ} {q : ℝ} (hq : 0 ≤ q) (hq1 : q ≤ 1) :
    ∀ h : Hypothesis M r, 0 ≤ prior q h := by
  intro h
  cases h with
  | none => exact hq
  | some B => exact div_nonneg (by linarith) (by positivity)

lemma prior_sum {M r : ℕ} (hr : r ≤ M) (q : ℝ) :
    (∑ h : Hypothesis M r, prior q h) = 1 := by
  rw [Fintype.sum_option]
  simp only [prior, Finset.sum_const, Finset.card_univ, patch_count, nsmul_eq_mul]
  have hc : (Nat.choose M r : ℝ) ≠ 0 := by exact_mod_cast Nat.choose_ne_zero hr
  field_simp
  ring

/-- All observed labels are +1, with repetitions retained in the sample. -/
def consistent {M r n : ℕ} (sample : Fin n → Fin M) (h : Hypothesis M r) : Prop :=
  ∀ i, label h (sample i) = true

@[simp] lemma consistent_target {M r n : ℕ} (sample : Fin n → Fin M) :
    consistent sample (none : Hypothesis M r) := by simp [consistent, label]

@[simp] lemma consistent_patch {M r n : ℕ} (sample : Fin n → Fin M) (B : Patch M r) :
    consistent sample (some B) ↔ ∀ i, sample i ∈ B.val := by simp [consistent, label]

def survivingFraction {M r n : ℕ} (sample : Fin n → Fin M) : ℝ :=
  (∑ B : Patch M r, if ∀ i, sample i ∈ B.val then (1:ℝ) else 0) / Nat.choose M r

lemma survivingFraction_nonneg {M r n : ℕ} (sample : Fin n → Fin M) :
    0 ≤ survivingFraction (r := r) sample := by unfold survivingFraction; positivity

lemma normalizer_formula {M r n : ℕ} (sample : Fin n → Fin M) (q : ℝ) :
    normalizer (prior (r := r) q) (consistent sample) = q+(1-q)*survivingFraction (r := r) sample := by
  unfold normalizer
  rw [Fintype.sum_option]
  simp only [consistent_target, if_true, prior, consistent_patch]
  unfold survivingFraction
  rw [← mul_div_assoc, Finset.mul_sum, Finset.sum_div]
  congr 1
  apply Finset.sum_congr rfl
  intro B _
  split_ifs <;> simp

/-- Literal posterior mass assigned to the bad hypotheses. -/
def badPosteriorMass {M r n : ℕ} (q : ℝ) (sample : Fin n → Fin M) : ℝ :=
  ∑ B : Patch M r, posterior (prior q) (consistent sample) (some B)

lemma badPosteriorMass_formula {M r n : ℕ} (sample : Fin n → Fin M) (q : ℝ) :
    badPosteriorMass (r := r) q sample =
      (1-q)*survivingFraction (r := r) sample/(q+(1-q)*survivingFraction (r := r) sample) := by
  unfold badPosteriorMass posterior
  rw [← Finset.sum_div, normalizer_formula]
  congr 1
  simp only [consistent_patch, prior]
  unfold survivingFraction
  rw [← mul_div_assoc, Finset.mul_sum, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro B _
  split_ifs <;> simp

/-- The actual uniform-input error of a hypothesis against the positive target. -/
def risk {M r : ℕ} (h : Hypothesis M r) : ℝ :=
  ((Finset.univ.filter (fun x => label h x = false)).card : ℝ)/M

@[simp] lemma risk_target (M r : ℕ) : risk (none : Hypothesis M r) = 0 := by
  simp [risk, label]

lemma risk_patch {M r : ℕ} (hM : 0 < M) (B : Patch M r) :
    risk (some B) = 1-(r:ℝ)/M := by
  have hfilter : Finset.univ.filter (fun x => label (some B) x = false) = Finset.univ \ B.val := by
    ext x
    simp [label]
  have hr : r ≤ M := by
    simpa [patch_card] using Finset.card_le_card (Finset.subset_univ B.val)
  rw [risk, hfilter, Finset.card_sdiff_of_subset (Finset.subset_univ B.val), Finset.card_univ,
    Fintype.card_fin, patch_card, Nat.cast_sub hr]
  have hm : (M:ℝ) ≠ 0 := by positivity
  field_simp

lemma risk_eq_uniform_mean {M r : ℕ} (h : Hypothesis M r) :
    risk h = SquaredSampling.finiteMean (fun x => if label h x = false then (1:ℝ) else 0) := by
  simp [risk, SquaredSampling.finiteMean]

/-- Gibbs risk of the ordinary normalized consistency posterior. -/
def gibbsRisk {M r n : ℕ} (q : ℝ) (sample : Fin n → Fin M) : ℝ :=
  ∑ h : Hypothesis M r, posterior (prior q) (consistent sample) h * risk h

lemma gibbsRisk_formula {M r n : ℕ} (hM : 0 < M) (q : ℝ) (sample : Fin n → Fin M) :
    gibbsRisk (r := r) q sample = badPosteriorMass (r := r) q sample*(1-(r:ℝ)/M) := by
  unfold gibbsRisk
  rw [Fintype.sum_option]
  simp only [risk_target, mul_zero, zero_add, risk_patch hM]
  exact (Finset.sum_mul _ _ _).symm

/-- Every surviving bad hypothesis puts every training point in its exceptional
set. This includes repeated inputs. -/
theorem training_exceptions {M r n : ℕ} (sample : Fin n → Fin M) (B : Patch M r)
    (hB : consistent sample (some B)) : ∀ i, sample i ∈ exceptions (some B) :=
  (consistent_patch sample B).mp hB

/-- Sparse exceptional sets can absorb the entire sample. This is the paper's
literal posterior lower bound, with no injectivity premise on the sample. -/
theorem sparse_exception_obstruction {M r n : ℕ} (hr : 1 ≤ r) (hrM : 2*r ≤ M)
    (hn : 2*n ≤ r) {q : ℝ} (hq : 0 < q) (hq1 : q < 1)
    (hqsmall : q ≤ (1/2:ℝ)*((r:ℝ)/(2*M))^n) (sample : Fin n → Fin M) :
    (1-(r:ℝ)/M)/2 ≤ gibbsRisk (r := r) q sample := by
  have hM : 0 < M := by omega
  have hr' : r ≤ M := by omega
  have hp := sample_survival_lower hM hr' hn sample
  change ((r:ℝ)/(2*M))^n ≤ survivingFraction (r := r) sample at hp
  have hb : (r:ℝ)/(2*M) ≤ 1 := by
    apply (div_le_one (by positivity : (0:ℝ) < 2*M)).mpr
    have hh : (r:ℝ) ≤ M := by exact_mod_cast hr'
    linarith
  have hpow : ((r:ℝ)/(2*M))^n ≤ 1 := pow_le_one₀ (by positivity) hb
  have hqhalf : q ≤ 1/2 := by linarith
  have hqp : q ≤ survivingFraction (r := r) sample/2 := by linarith
  have hp0 := survivingFraction_nonneg (r := r) sample
  have hbad : q ≤ (1-q)*survivingFraction (r := r) sample := by nlinarith
  have hden : 0 < q+(1-q)*survivingFraction (r := r) sample := by nlinarith
  have hmass : (1/2:ℝ) ≤ badPosteriorMass (r := r) q sample := by
    rw [badPosteriorMass_formula]
    exact (le_div_iff₀ hden).mpr (by linarith)
  have herror : 0 ≤ 1-(r:ℝ)/M := by
    have : (r:ℝ)/M ≤ 1 := (div_le_one (by positivity)).mpr (by exact_mod_cast hr')
    linarith
  rw [gibbsRisk_formula hM]
  nlinarith

/-- The exponential target-mass parameterization used in the paper's discussion. -/
theorem exponential_target_mass_obstruction {M r n : ℕ} (hr : 1 ≤ r) (hrM : 2*r ≤ M)
    (hn : 2*n ≤ r) {A : ℝ}
    (hA : (n:ℝ)*Real.log (2*(M:ℝ)/r)+Real.log 2 ≤ A)
    (sample : Fin n → Fin M) :
    (1-(r:ℝ)/M)/2 ≤ gibbsRisk (r := r) (Real.exp (-A)) sample := by
  have hM : 0 < M := by omega
  have hrR : (0:ℝ) < r := by exact_mod_cast (show 0 < r by omega)
  have hMR : (0:ℝ) < M := by exact_mod_cast hM
  have hratio : 1 ≤ 2*(M:ℝ)/r := by
    apply (le_div_iff₀ hrR).mpr
    have hh : (2:ℝ)*r ≤ M := by exact_mod_cast hrM
    linarith
  have hlog : 0 ≤ Real.log (2*(M:ℝ)/r) := Real.log_nonneg hratio
  have hlog2 : 0 < Real.log (2:ℝ) := Real.log_pos (by norm_num)
  have hAp : 0 < A := by nlinarith [(Nat.cast_nonneg n : (0:ℝ) ≤ n)]
  apply sparse_exception_obstruction hr hrM hn (Real.exp_pos _) (Real.exp_lt_one_iff.mpr (by linarith)) _ sample
  calc
    Real.exp (-A) ≤ Real.exp (-((n:ℝ)*Real.log (2*(M:ℝ)/r)+Real.log 2)) := Real.exp_le_exp.mpr (by linarith)
    _ = (1/2:ℝ)*((r:ℝ)/(2*M))^n := by
      rw [Real.exp_neg,Real.exp_add,Real.exp_nat_mul,
        Real.exp_log (by positivity),Real.exp_log (by norm_num : (0:ℝ) < 2)]
      simp only [div_pow]
      field_simp

#print axioms sparse_exception_obstruction
end NeuralGeneralization.SparsePatches
