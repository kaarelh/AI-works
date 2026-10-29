import SequentialMaurey

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch

noncomputable section
set_option backward.isDefEq.respectTransparency false

/-- Replacing each occupied covering ball by one actual point doubles the radius
and preserves the upper bound on the number of centers. -/
theorem FiniteBallCover.actual_centers {X : Type*} [PseudoMetricSpace X]
    {S : Set X} {N : ℕ} {r : ℝ} (hS : FiniteBallCover S N r) :
    ∃ C : Finset X, C.card ≤ N ∧ (∀ c ∈ C, c ∈ S) ∧
      ∀ x ∈ S, ∃ c ∈ C, dist x c ≤ 2 * r := by
  classical
  obtain ⟨C, hCcard, hC⟩ := hS
  let D : Finset X := C.filter fun c ↦ ∃ x ∈ S, dist x c ≤ r
  have hD (c : D) : ∃ x ∈ S, dist x (c : X) ≤ r := (Finset.mem_filter.mp c.property).2
  let rep : D → X := fun c ↦ Classical.choose (hD c)
  have hrep (c : D) : rep c ∈ S ∧ dist (rep c) (c : X) ≤ r := Classical.choose_spec (hD c)
  refine ⟨D.attach.image rep, (Finset.card_image_le.trans ?_), ?_, ?_⟩
  · simpa only [Finset.card_attach] using (Finset.card_le_card (Finset.filter_subset _ _)).trans hCcard
  · intro c hc
    obtain ⟨d, _, rfl⟩ := Finset.mem_image.mp hc
    exact (hrep d).1
  · intro x hx
    obtain ⟨c, hc, hxc⟩ := hC x hx
    have hcD : c ∈ D := Finset.mem_filter.mpr ⟨hc, x, hx, hxc⟩
    refine ⟨rep ⟨c, hcD⟩, Finset.mem_image.mpr ⟨⟨c, hcD⟩, Finset.mem_attach _ _, rfl⟩, ?_⟩
    have hcr := (hrep ⟨c, hcD⟩).2
    have htri := dist_triangle x c (rep ⟨c, hcD⟩)
    rw [dist_comm c] at htri
    linarith

lemma frobeniusNorm_smul {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] (a : ℝ) (A : E →ₗ[ℝ] F) :
    frobeniusNorm (a • A) = |a| * frobeniusNorm A := by
  have hs : frobeniusSq (a • A) = a ^ 2 * frobeniusSq A := by
    let b := stdOrthonormalBasis ℝ E
    rw [frobeniusSq_eq_sum_norm_sq _ b, frobeniusSq_eq_sum_norm_sq _ b]
    simp only [LinearMap.smul_apply, norm_smul, mul_pow, Real.norm_eq_abs, sq_abs, Finset.mul_sum]
  apply (sq_eq_sq₀ (frobeniusNorm_nonneg _) (mul_nonneg (abs_nonneg _) (frobeniusNorm_nonneg _))).mp
  rw [frobeniusNorm_sq, mul_pow, sq_abs, frobeniusNorm_sq, hs]

namespace ScalarNetwork

def prefixDim {n : ℕ} (N : ScalarNetwork n) : ℕ → ℕ
  | 0 => n
  | h + 1 => match N with
    | .output _ => n
    | .layer _ _ _ _ tail => tail.prefixDim h
termination_by structural h => h

def prefixEval {n : ℕ} (N : ScalarNetwork n) : (h : ℕ) → Euclid n → Euclid (N.prefixDim h)
  | 0, x => x
  | h + 1, x => match N with
    | .output _ => x
    | .layer W φ _ _ tail => tail.prefixEval h (coordinateActivation φ (W x))
termination_by structural h _ => h

def prefixProduct {n : ℕ} (N : ScalarNetwork n) : ℕ → ℝ
  | 0 => 1
  | h + 1 => match N with
    | .output _ => 1
    | .layer W _ _ _ tail => frobeniusNorm W * tail.prefixProduct h
termination_by structural h => h

def suffixEval {n : ℕ} (N : ScalarNetwork n) : (h : ℕ) → Euclid (N.prefixDim h) → ℝ
  | 0, x => N.eval x
  | h + 1, x => match N with
    | .output W => W x
    | .layer _ _ _ _ tail => tail.suffixEval h x
termination_by structural h _ => h

def suffixProduct {n : ℕ} (N : ScalarNetwork n) : ℕ → ℝ
  | 0 => N.product
  | h + 1 => match N with
    | .output W => frobeniusNorm W
    | .layer _ _ _ _ tail => tail.suffixProduct h
termination_by structural h => h

lemma prefixProduct_nonneg {n : ℕ} (N : ScalarNetwork n) (h : ℕ) : 0 ≤ N.prefixProduct h := by
  induction h generalizing n with
  | zero => exact zero_le_one
  | succ h ih =>
    cases N with
    | output W => exact zero_le_one
    | layer W φ hφ0 hφ tail => exact mul_nonneg (frobeniusNorm_nonneg W) (ih tail)

lemma suffixProduct_nonneg {n : ℕ} (N : ScalarNetwork n) (h : ℕ) : 0 ≤ N.suffixProduct h := by
  induction h generalizing n with
  | zero => exact N.product_nonneg
  | succ h ih =>
    cases N with
    | output W => exact frobeniusNorm_nonneg W
    | layer W φ hφ0 hφ tail => exact ih tail

lemma product_factor {n : ℕ} (N : ScalarNetwork n) (h : ℕ) :
    N.product = N.prefixProduct h * N.suffixProduct h := by
  induction h generalizing n with
  | zero => simp [prefixProduct, suffixProduct]
  | succ h ih =>
    cases N with
    | output W => simp [product, prefixProduct, suffixProduct]
    | layer W φ hφ0 hφ tail =>
      simp only [product, prefixProduct, suffixProduct, ih tail]
      ring

lemma eval_factor {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (x : Euclid n) :
    N.eval x = N.suffixEval h (N.prefixEval h x) := by
  induction h generalizing n with
  | zero => rfl
  | succ h ih =>
    cases N with
    | output W => rfl
    | layer W φ hφ0 hφ tail => exact ih tail (coordinateActivation φ (W x))

lemma suffix_lipschitz {n : ℕ} (N : ScalarNetwork n) (h : ℕ) :
    LipschitzWith (NNReal.mk (N.suffixProduct h) (N.suffixProduct_nonneg h)) (N.suffixEval h) := by
  induction h generalizing n with
  | zero => exact N.lipschitz
  | succ h ih =>
    cases N with
    | output W => exact linear_lipschitz_frobenius W
    | layer W φ hφ0 hφ tail => exact ih tail

lemma norm_prefix_le {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (x : Euclid n) :
    ‖N.prefixEval h x‖ ≤ N.prefixProduct h * ‖x‖ := by
  induction h generalizing n with
  | zero => simpa only [prefixDim, prefixEval, prefixProduct, one_mul] using (le_rfl : ‖x‖ ≤ ‖x‖)
  | succ h ih =>
    cases N with
    | output W => simpa only [prefixDim, prefixEval, prefixProduct, one_mul] using (le_rfl : ‖x‖ ≤ ‖x‖)
    | layer W φ hφ0 hφ tail =>
      have ha := norm_coordinateActivation_le φ hφ0 hφ (W x)
      have hb := norm_linear_le_frobenius W x
      calc
        _ ≤ tail.prefixProduct h * ‖coordinateActivation φ (W x)‖ := ih tail _
        _ ≤ tail.prefixProduct h * (frobeniusNorm W * ‖x‖) :=
          mul_le_mul_of_nonneg_left (ha.trans hb) (tail.prefixProduct_nonneg h)
        _ = _ := by simp only [prefixProduct]; ring

lemma prefixDim_le {n : ℕ} (N : ScalarNetwork n) (m h : ℕ)
    (hh : 0 < h) (hdepth : h ≤ N.hiddenDepth) (hwidth : N.PrefixWidth m h) : N.prefixDim h ≤ m := by
  induction h generalizing n with
  | zero => exact False.elim (Nat.lt_irrefl 0 hh)
  | succ h ih =>
    cases N with
    | output W => simp [hiddenDepth] at hdepth
    | @layer n q W φ hφ0 hφ tail =>
      cases h with
      | zero => exact hwidth.1
      | succ h =>
        apply ih tail (by omega) _ hwidth.2
        simpa only [hiddenDepth, Nat.add_comm 1, Nat.add_le_add_iff_right] using hdepth

/-- The previously proved two-ball cover iterated through an actual network prefix. -/
theorem prefix_finite_cover {n : ℕ} (N : ScalarNetwork n) (h : ℕ)
    (hdepth : h ≤ N.hiddenDepth) {S : Set (Euclid n)} {M : ℕ} {R : ℝ}
    (hS : FiniteBallCover S M R) (hR : 0 ≤ R) :
    FiniteBallCover (N.prefixEval h '' S) (M * 2 ^ h)
      (R * N.prefixProduct h / (Real.sqrt 2) ^ h) := by
  induction h generalizing n M R with
  | zero => simpa only [prefixDim, prefixEval, prefixProduct, pow_zero, mul_one, div_one, Set.image_id'] using hS
  | succ h ih =>
    cases N with
    | output W => simp [hiddenDepth] at hdepth
    | layer W φ hφ0 hφ tail =>
      have htail : h ≤ tail.hiddenDepth := by
        simpa only [hiddenDepth, Nat.add_comm 1, Nat.add_le_add_iff_right] using hdepth
      have hfirst := hS.image_layer hR W 0 (coordinateActivation φ) (coordinateActivation_lipschitz φ hφ)
      simp only [add_zero] at hfirst
      have hrad : 0 ≤ R * frobeniusNorm W / Real.sqrt 2 := by
        exact div_nonneg (mul_nonneg hR (frobeniusNorm_nonneg W)) (Real.sqrt_nonneg _)
      have hcover := ih tail htail hfirst hrad
      have hcount : (M * 2) * 2 ^ h = M * 2 ^ (h + 1) := by rw [pow_succ]; ring
      have hradius : (R * frobeniusNorm W / Real.sqrt 2) * tail.prefixProduct h /
          Real.sqrt 2 ^ h = R * (frobeniusNorm W * tail.prefixProduct h) / Real.sqrt 2 ^ (h + 1) := by
        rw [pow_succ]
        ring
      simpa only [prefixDim, Set.image_image, Function.comp_def, prefixEval, prefixProduct, hcount, hradius] using hcover

def normalizedPrefix {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (x : Euclid n) : Euclid (N.prefixDim h) :=
  (N.prefixProduct h)⁻¹ • N.prefixEval h x

def normalizedSuffix {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (x : Euclid (N.prefixDim h)) : ℝ :=
  N.suffixEval h (N.prefixProduct h • x)

lemma prefixProduct_pos {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hN : 0 < N.product) :
    0 < N.prefixProduct h := by
  apply lt_of_le_of_ne (N.prefixProduct_nonneg h)
  intro hz
  have hf := N.product_factor h
  rw [← hz, zero_mul] at hf
  linarith

lemma normalized_eval_factor {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hN : 0 < N.product)
    (x : Euclid n) : N.normalizedSuffix h (N.normalizedPrefix h x) = N.eval x := by
  simp only [normalizedSuffix, normalizedPrefix, smul_smul,
    mul_inv_cancel₀ (ne_of_gt (N.prefixProduct_pos h hN)), one_smul, ← N.eval_factor]

lemma norm_normalizedPrefix_le {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hN : 0 < N.product)
    (x : Euclid n) : ‖N.normalizedPrefix h x‖ ≤ ‖x‖ := by
  have hS := N.prefixProduct_pos h hN
  rw [normalizedPrefix, norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hS]
  have hh := mul_le_mul_of_nonneg_left (N.norm_prefix_le h x) (inv_nonneg.mpr hS.le)
  simpa only [← mul_assoc, inv_mul_cancel₀ (ne_of_gt hS), one_mul] using hh

lemma normalizedSuffix_lipschitz {n : ℕ} (N : ScalarNetwork n) (h : ℕ) :
    LipschitzWith (NNReal.mk N.product N.product_nonneg) (N.normalizedSuffix h) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  have hb := (N.suffix_lipschitz h).dist_le_mul (N.prefixProduct h • x) (N.prefixProduct h • y)
  simp only [NNReal.coe_mk, dist_eq_norm, ← smul_sub, norm_smul, Real.norm_eq_abs,
    abs_of_nonneg (N.prefixProduct_nonneg h)] at hb
  simp only [NNReal.coe_mk, normalizedSuffix, dist_eq_norm]
  apply hb.trans_eq
  rw [N.product_factor h]
  ring

/-- The normalized prefix has a dimension-free finite cover independent of all
individual layer magnitudes and of the unretained suffix. -/
theorem normalized_prefix_cover {n : ℕ} (N : ScalarNetwork n) (h : ℕ)
    (hN : 0 < N.product) (hdepth : h ≤ N.hiddenDepth) (R : ℝ) (hR : 0 ≤ R) :
    FiniteBallCover (N.normalizedPrefix h '' Metric.closedBall (0 : Euclid n) R) (2 ^ h)
      (R / (Real.sqrt 2) ^ h) := by
  have hS := N.prefixProduct_pos h hN
  have hc := N.prefix_finite_cover h hdepth (finiteBallCover_closedBall (0 : Euclid n) R) hR
  have hs : LipschitzWith (NNReal.mk ((N.prefixProduct h)⁻¹) (inv_nonneg.mpr hS.le))
      (fun x : Euclid (N.prefixDim h) ↦ (N.prefixProduct h)⁻¹ • x) := by
    apply LipschitzWith.of_dist_le_mul
    intro x y
    simp only [NNReal.coe_mk, dist_eq_norm, ← smul_sub, norm_smul, Real.norm_eq_abs,
      abs_inv, abs_of_pos hS]
    exact le_rfl
  have hh := hc.image_lipschitz hs
  have hr : (N.prefixProduct h)⁻¹ * (R * N.prefixProduct h / Real.sqrt 2 ^ h) =
      R / Real.sqrt 2 ^ h := by field_simp
  simpa only [NNReal.coe_mk, one_mul, Set.image_image, Function.comp_def, hr, normalizedPrefix] using hh

/-- Actual normalized prototypes, with same-sign decoding, bounded norms, and at
most 2^h stored vectors. This theorem is entirely about a concrete finite network. -/
theorem normalized_prototypes {K : Type*} [Fintype K] [Nonempty K]
    {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hN : 0 < N.product) (hdepth : h ≤ N.hiddenDepth)
    (x : K → Euclid n) (R : ℝ) (hR : 0 ≤ R) (hx : ∀ k, ‖x k‖ ≤ R)
    (hmargin : ∀ k, 1 ≤ |N.eval (x k)|)
    (hsmall : (2 * (R / (Real.sqrt 2) ^ h)) * N.product < 1) :
    ∃ C : Finset (Euclid (N.prefixDim h)), C.card ≤ 2 ^ h ∧
      (∀ c ∈ C, ∃ k, N.normalizedPrefix h (x k) = c) ∧
      (∀ c ∈ C, ‖c‖ ≤ R) ∧
      (∀ k, ∃ c ∈ C, dist (N.normalizedPrefix h (x k)) c ≤ 2 * (R / (Real.sqrt 2) ^ h)) ∧
      (∀ c ∈ C, ∀ k,
        dist (N.normalizedPrefix h (x k)) c ≤ 2 * (R / (Real.sqrt 2) ^ h) →
        (0 ≤ N.eval (x k) ↔ 0 ≤ N.normalizedSuffix h c)) := by
  have hc : FiniteBallCover (Set.range (fun k ↦ N.normalizedPrefix h (x k))) (2 ^ h)
      (R / (Real.sqrt 2) ^ h) := by
    apply (N.normalized_prefix_cover h hN hdepth R hR).mono
    rintro y ⟨k, rfl⟩
    exact ⟨x k, by simpa only [Metric.mem_closedBall, dist_zero_right] using hx k, rfl⟩
  obtain ⟨C, hCcard, hCactual, hC⟩ := hc.actual_centers
  refine ⟨C, hCcard, hCactual, ?_, ?_, ?_⟩
  · intro c hc
    obtain ⟨k, rfl⟩ := hCactual c hc
    exact (N.norm_normalizedPrefix_le h hN (x k)).trans (hx k)
  · intro k
    exact hC _ ⟨k, rfl⟩
  · intro c _ k hkc
    have hm : 1 ≤ |N.normalizedSuffix h (N.normalizedPrefix h (x k))| := by
      rw [N.normalized_eval_factor h hN]
      exact hmargin k
    have hsign := unit_margin_sign_center (N.normalizedSuffix_lipschitz h) hkc hm
      (by simpa only [NNReal.coe_mk] using hsmall)
    simpa only [N.normalized_eval_factor h hN] using hsign

def scaleOutput {n : ℕ} (a : ℝ) : ScalarNetwork n → ScalarNetwork n
  | .output W => .output (a • W)
  | .layer W φ hφ0 hφ tail => .layer W φ hφ0 hφ (tail.scaleOutput a)

lemma scaleOutput_eval {n : ℕ} (N : ScalarNetwork n) (a : ℝ) (x : Euclid n) :
    (N.scaleOutput a).eval x = a * N.eval x := by
  induction N with
  | output W => rfl
  | layer W φ hφ0 hφ tail ih => exact ih _

lemma scaleOutput_product {n : ℕ} (N : ScalarNetwork n) (a : ℝ) :
    (N.scaleOutput a).product = |a| * N.product := by
  induction N with
  | output W => exact frobeniusNorm_smul a W
  | layer W φ hφ0 hφ tail ih => simp only [scaleOutput, product, ih]; ring

lemma scaleOutput_hiddenDepth {n : ℕ} (N : ScalarNetwork n) (a : ℝ) :
    (N.scaleOutput a).hiddenDepth = N.hiddenDepth := by
  induction N with
  | output W => rfl
  | layer W φ hφ0 hφ tail ih => simp only [scaleOutput, hiddenDepth, ih]

lemma scaleOutput_prefixWidth {n : ℕ} (N : ScalarNetwork n) (a : ℝ) (m h : ℕ) :
    (N.scaleOutput a).PrefixWidth m h ↔ N.PrefixWidth m h := by
  induction h generalizing n with
  | zero => rfl
  | succ h ih =>
    cases N with
    | output W => rfl
    | layer W φ hφ0 hφ tail => simp only [scaleOutput, PrefixWidth, ih]

/-- Sequential compression with one prescribed total error budget. -/
theorem compress_prefix_total {K : Type*} [Fintype K] [Nonempty K]
    {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hh : 0 < h)
    (x : K → Euclid n) (R ε : ℝ) (hR : 0 < R) (hε : 0 < ε) (hx : ∀ k, ‖x k‖ ≤ R)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * (N.product * R * (h : ℝ)) ^ 2 * (1 + Real.log (Fintype.card K)) ≤
      (m : ℝ) * ε ^ 2) :
    ∃ N' : ScalarNetwork n, N'.product ≤ N.product ∧ N'.hiddenDepth ≤ N.hiddenDepth ∧
      N'.PrefixWidth m h ∧ ∀ k, dist (N'.eval (x k)) (N.eval (x k)) ≤ ε := by
  have hhR : 0 < (h : ℝ) := Nat.cast_pos.mpr hh
  have hb : 64 * (N.product * R) ^ 2 * (1 + Real.log (Fintype.card K)) ≤
      (m : ℝ) * (ε / h) ^ 2 := by
    calc
      _ = (64 * (N.product * R * (h : ℝ)) ^ 2 * (1 + Real.log (Fintype.card K))) / (h : ℝ) ^ 2 := by
        field_simp
      _ ≤ ((m : ℝ) * ε ^ 2) / (h : ℝ) ^ 2 := div_le_div_of_nonneg_right hbudget (sq_nonneg _)
      _ = _ := by rw [div_pow, mul_div_assoc]
  obtain ⟨N', hp, hd, hw, he⟩ := N.compress_prefix h x R (ε / h) hR (div_pos hε hhR) hx m hm hb
  refine ⟨N', hp, hd, hw, fun k ↦ ?_⟩
  have hcancel : (h : ℝ) * (ε / h) = ε := by field_simp
  simpa only [hcancel] using he k

/-- Compression preserves a global Boolean margin after doubling only the final
readout. The product increases by at most a factor two. -/
theorem compress_prefix_margin {K : Type*} [Fintype K] [Nonempty K]
    {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hh : 0 < h)
    (x : K → Euclid n) (f : K → ℝ) (hf : ∀ k, |f k| = 1)
    (hmargin : ∀ k, 1 ≤ f k * N.eval (x k))
    (R : ℝ) (hR : 0 < R) (hx : ∀ k, ‖x k‖ ≤ R) (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * (N.product * R * (h : ℝ)) ^ 2 * (1 + Real.log (Fintype.card K)) ≤
      (m : ℝ) * (1 / 4 : ℝ) ^ 2) :
    ∃ N' : ScalarNetwork n, 0 < N'.product ∧ N'.product ≤ 2 * N.product ∧
      N'.hiddenDepth ≤ N.hiddenDepth ∧ N'.PrefixWidth m h ∧
      (∀ k, (3 / 2 : ℝ) ≤ f k * N'.eval (x k)) ∧ (∀ k, 1 ≤ |N'.eval (x k)|) := by
  classical
  obtain ⟨M, hMp, hMd, hMw, hMe⟩ := N.compress_prefix_total h hh x R (1 / 4) hR (by norm_num) hx m hm hbudget
  have hMM : ∀ k, (3 / 2 : ℝ) ≤ f k * (M.scaleOutput 2).eval (x k) := by
    intro k
    have he : |f k * (M.eval (x k) - N.eval (x k))| ≤ 1 / 4 := by
      rw [abs_mul, hf k, one_mul]
      simpa only [Real.dist_eq] using hMe k
    have hlo := neg_le_abs (f k * (M.eval (x k) - N.eval (x k)))
    rw [scaleOutput_eval]
    nlinarith [hmargin k]
  have hAbs : ∀ k, 1 ≤ |(M.scaleOutput 2).eval (x k)| := by
    intro k
    have ha := le_abs_self (f k * (M.scaleOutput 2).eval (x k))
    rw [abs_mul, hf k, one_mul] at ha
    linarith [hMM k]
  have hpos : 0 < (M.scaleOutput 2).product := by
    apply lt_of_le_of_ne (M.scaleOutput 2).product_nonneg
    intro hz
    have he := (M.scaleOutput 2).eval_eq_zero_of_product_zero hz.symm (x (Classical.choice (inferInstance : Nonempty K)))
    have ha := hAbs (Classical.choice (inferInstance : Nonempty K))
    rw [he, abs_zero] at ha
    norm_num at ha
  refine ⟨M.scaleOutput 2, hpos, ?_, ?_, ?_, hMM, hAbs⟩
  · simpa only [scaleOutput_product, abs_of_pos (by norm_num : (0 : ℝ) < 2)] using
      mul_le_mul_of_nonneg_left hMp (by norm_num : (0 : ℝ) ≤ 2)
  · simpa only [scaleOutput_hiddenDepth] using hMd
  · exact (M.scaleOutput_prefixWidth 2 m h).mpr hMw

/-- The complete analytic prefix reduction, before discretization into gates.
It gives either an entirely short bounded-width network or actual bounded-width
normalized prototypes with the proved count, radius, and decoding guarantees. -/
theorem analytic_prefix_reduction {K : Type*} [Fintype K] [Nonempty K]
    {n : ℕ} (N : ScalarNetwork n) (h : ℕ) (hh : 0 < h)
    (x : K → Euclid n) (f : K → ℝ) (hf : ∀ k, |f k| = 1)
    (hmargin : ∀ k, 1 ≤ f k * N.eval (x k))
    (R : ℝ) (hR : 0 < R) (hx : ∀ k, ‖x k‖ ≤ R) (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * (N.product * R * (h : ℝ)) ^ 2 * (1 + Real.log (Fintype.card K)) ≤
      (m : ℝ) * (1 / 4 : ℝ) ^ 2)
    (hsmall : (2 * (R / (Real.sqrt 2) ^ h)) * (2 * N.product) < 1) :
    ∃ N' : ScalarNetwork n, 0 < N'.product ∧ N'.product ≤ 2 * N.product ∧
      N'.hiddenDepth ≤ N.hiddenDepth ∧ N'.PrefixWidth m h ∧
      (∀ k, (3 / 2 : ℝ) ≤ f k * N'.eval (x k)) ∧
      (N'.hiddenDepth < h ∨ (N'.prefixDim h ≤ m ∧
        ∃ C : Finset (Euclid (N'.prefixDim h)), C.card ≤ 2 ^ h ∧
          (∀ c ∈ C, ∃ k, N'.normalizedPrefix h (x k) = c) ∧
          (∀ c ∈ C, ‖c‖ ≤ R) ∧
          (∀ k, ∃ c ∈ C, dist (N'.normalizedPrefix h (x k)) c ≤ 2 * (R / (Real.sqrt 2) ^ h)) ∧
          (∀ c ∈ C, ∀ k,
            dist (N'.normalizedPrefix h (x k)) c ≤ 2 * (R / (Real.sqrt 2) ^ h) →
            (0 ≤ N'.eval (x k) ↔ 0 ≤ N'.normalizedSuffix h c)))) := by
  obtain ⟨N', hpos, hp, hd, hw, hmargin', hAbs⟩ :=
    N.compress_prefix_margin h hh x f hf hmargin R hR hx m hm hbudget
  refine ⟨N', hpos, hp, hd, hw, hmargin', ?_⟩
  rcases lt_or_ge N'.hiddenDepth h with hshort | hlong
  · exact Or.inl hshort
  · right
    refine ⟨N'.prefixDim_le m h hh hlong hw, ?_⟩
    apply N'.normalized_prototypes h hpos hlong x R hR.le hx hAbs
    exact (mul_le_mul_of_nonneg_left hp (by positivity)).trans_lt hsmall

#print axioms analytic_prefix_reduction

#print axioms normalized_prototypes

end ScalarNetwork
end
end BooleanDepthResearch
