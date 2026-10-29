import MaureyLayerCompression
import NetworkBallCover

open scoped BigOperators RealInnerProductSpace

namespace BooleanDepthResearch

noncomputable section

lemma frobeniusNorm_nonneg {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] (A : E →ₗ[ℝ] F) : 0 ≤ frobeniusNorm A := Real.sqrt_nonneg _

/-- Frobenius norm bounds the operator norm, with no assumptions on rank. -/
theorem norm_linear_le_frobenius {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] (A : E →ₗ[ℝ] F) (x : E) : ‖A x‖ ≤ frobeniusNorm A * ‖x‖ := by
  let b := stdOrthonormalBasis ℝ E
  have hexp : A x = ∑ i, ⟪b i, x⟫ • A (b i) := by
    simpa only [map_sum, map_smul] using (congrArg A (b.sum_repr' x)).symm
  rw [hexp]
  calc
    _ ≤ ∑ i, ‖⟪b i, x⟫ • A (b i)‖ := norm_sum_le _ _
    _ = ∑ i, |⟪b i, x⟫| * ‖A (b i)‖ := by simp [norm_smul, Real.norm_eq_abs]
    _ ≤ Real.sqrt (∑ i, |⟪b i, x⟫| ^ 2) * Real.sqrt (∑ i, ‖A (b i)‖ ^ 2) :=
      Real.sum_mul_le_sqrt_mul_sqrt Finset.univ _ _
    _ = frobeniusNorm A * ‖x‖ := by
      simp_rw [sq_abs]
      rw [b.sum_sq_inner_right, Real.sqrt_sq (norm_nonneg x), ← frobeniusSq_eq_sum_norm_sq A b]
      exact mul_comm _ _

theorem linear_lipschitz_frobenius {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] (A : E →ₗ[ℝ] F) :
    LipschitzWith (NNReal.mk (frobeniusNorm A) (frobeniusNorm_nonneg A)) A := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simpa only [dist_eq_norm, ← map_sub, NNReal.coe_mk] using norm_linear_le_frobenius A (x - y)

lemma coordinateActivation_zero {I : Type*} [Fintype I] (φ : I → ℝ → ℝ)
    (hφ0 : ∀ i, φ i 0 = 0) : coordinateActivation φ 0 = 0 := by
  ext i
  simp [hφ0]

lemma coordinateActivation_lipschitz {I : Type*} [Fintype I] (φ : I → ℝ → ℝ)
    (hφ : ∀ i, LipschitzWith 1 (φ i)) : LipschitzWith 1 (coordinateActivation φ) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  simp only [NNReal.coe_one, one_mul, dist_eq_norm]
  apply (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
  simp only [EuclideanSpace.real_norm_sq_eq, PiLp.sub_apply, coordinateActivation_apply]
  apply Finset.sum_le_sum
  intro i _
  have h := (hφ i).dist_le_mul (x i) (y i)
  simp only [NNReal.coe_one, one_mul, Real.dist_eq] at h
  simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr h

lemma norm_coordinateActivation_le {I : Type*} [Fintype I] (φ : I → ℝ → ℝ)
    (hφ0 : ∀ i, φ i 0 = 0) (hφ : ∀ i, LipschitzWith 1 (φ i)) (x : EuclideanSpace ℝ I) :
    ‖coordinateActivation φ x‖ ≤ ‖x‖ := by
  simpa only [coordinateActivation_zero φ hφ0, NNReal.coe_one, one_mul, dist_zero_right] using
    (coordinateActivation_lipschitz φ hφ).dist_le_mul x 0

lemma frobeniusNorm_zero {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [NormedAddCommGroup F] [InnerProductSpace ℝ F]
    [FiniteDimensional ℝ F] : frobeniusNorm (0 : E →ₗ[ℝ] F) = 0 := by
  simp [frobeniusNorm, frobeniusSq]

abbrev Euclid (n : ℕ) := EuclideanSpace ℝ (Fin n)

/-- A finite layered network, including its genuine scalar activation hypotheses. -/
inductive ScalarNetwork : ℕ → Type
  | output {n : ℕ} (W : Euclid n →ₗ[ℝ] ℝ) : ScalarNetwork n
  | layer {n q : ℕ} (W : Euclid n →ₗ[ℝ] Euclid q) (φ : Fin q → ℝ → ℝ)
      (hφ0 : ∀ i, φ i 0 = 0) (hφ : ∀ i, LipschitzWith 1 (φ i))
      (tail : ScalarNetwork q) : ScalarNetwork n

namespace ScalarNetwork

def eval {n : ℕ} : ScalarNetwork n → Euclid n → ℝ
  | .output W, x => W x
  | .layer W φ _ _ tail, x => tail.eval (coordinateActivation φ (W x))

def product {n : ℕ} : ScalarNetwork n → ℝ
  | .output W => frobeniusNorm W
  | .layer W _ _ _ tail => frobeniusNorm W * tail.product

def hiddenDepth {n : ℕ} : ScalarNetwork n → ℕ
  | .output _ => 0
  | .layer _ _ _ _ tail => 1 + tail.hiddenDepth

def PrefixWidth (m : ℕ) : (h : ℕ) → {n : ℕ} → ScalarNetwork n → Prop
  | 0, _, _ => True
  | _ + 1, _, .output _ => True
  | h + 1, _, @ScalarNetwork.layer _ q _ _ _ _ tail => q ≤ m ∧ PrefixWidth m h tail

lemma product_nonneg {n : ℕ} (N : ScalarNetwork n) : 0 ≤ N.product := by
  induction N with
  | output W => exact frobeniusNorm_nonneg W
  | layer W φ hφ0 hφ tail ih => exact mul_nonneg (frobeniusNorm_nonneg W) ih

lemma eval_zero {n : ℕ} (N : ScalarNetwork n) : N.eval 0 = 0 := by
  induction N with
  | output W => exact map_zero W
  | layer W φ hφ0 hφ tail ih => simpa only [eval, map_zero, coordinateActivation_zero φ hφ0] using ih

lemma lipschitz {n : ℕ} (N : ScalarNetwork n) :
    LipschitzWith (NNReal.mk N.product N.product_nonneg) N.eval := by
  induction N with
  | output W => exact linear_lipschitz_frobenius W
  | layer W φ hφ0 hφ tail ih =>
    apply LipschitzWith.of_dist_le_mul
    intro x y
    have h1 := ih.dist_le_mul (coordinateActivation φ (W x)) (coordinateActivation φ (W y))
    have h2 := (coordinateActivation_lipschitz φ hφ).dist_le_mul (W x) (W y)
    have h3 := (linear_lipschitz_frobenius W).dist_le_mul x y
    simp only [NNReal.coe_mk, NNReal.coe_one, one_mul] at h1 h2 h3 ⊢
    change dist (tail.eval (coordinateActivation φ (W x)))
      (tail.eval (coordinateActivation φ (W y))) ≤ (frobeniusNorm W * tail.product) * dist x y
    calc
      _ ≤ tail.product * dist (coordinateActivation φ (W x)) (coordinateActivation φ (W y)) := h1
      _ ≤ tail.product * (frobeniusNorm W * dist x y) :=
        mul_le_mul_of_nonneg_left (h2.trans h3) tail.product_nonneg
      _ = _ := by ring

lemma norm_eval_le {n : ℕ} (N : ScalarNetwork n) (x : Euclid n) :
    ‖N.eval x‖ ≤ N.product * ‖x‖ := by
  simpa only [N.eval_zero, dist_zero_right, NNReal.coe_mk] using N.lipschitz.dist_le_mul x 0

lemma eval_eq_zero_of_product_zero {n : ℕ} (N : ScalarNetwork n) (hN : N.product = 0)
    (x : Euclid n) : N.eval x = 0 := by
  apply norm_eq_zero.mp
  exact le_antisymm (by simpa [hN] using N.norm_eval_le x) (norm_nonneg _)

/-- Sequential finite-prefix Maurey compression. The original network depth and
widths are unrestricted. Every retained hidden width is at most m, the total
Frobenius product does not increase, and final-output error is at most h ε.
Zero-product cases may shorten the network; hidden depth never increases. -/
theorem compress_prefix {K : Type*} [Fintype K] [Nonempty K] (h : ℕ)
    {n : ℕ} (N : ScalarNetwork n) (x : K → Euclid n)
    (R ε : ℝ) (hR : 0 < R) (hε : 0 < ε) (hx : ∀ k, ‖x k‖ ≤ R)
    (m : ℕ) (hm : 0 < m)
    (hbudget : 64 * (N.product * R) ^ 2 * (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2) :
    ∃ N' : ScalarNetwork n, N'.product ≤ N.product ∧ N'.hiddenDepth ≤ N.hiddenDepth ∧
      N'.PrefixWidth m h ∧ ∀ k, dist (N'.eval (x k)) (N.eval (x k)) ≤ (h : ℝ) * ε := by
  induction h generalizing n R ε with
  | zero => exact ⟨N, le_rfl, le_rfl, trivial, fun k ↦ by simp⟩
  | succ h ih =>
    by_cases hN : N.product = 0
    · refine ⟨.output 0, ?_, ?_, trivial, ?_⟩
      · simp [product, frobeniusNorm_zero, hN]
      · exact Nat.zero_le _
      · intro k
        simp only [eval, LinearMap.zero_apply, N.eval_eq_zero_of_product_zero hN, dist_self]
        positivity
    cases N with
    | output W =>
      refine ⟨.output W, le_rfl, le_rfl, trivial, fun k ↦ ?_⟩
      simp only [dist_self]
      positivity
    | @layer n q W φ hφ0 hφ tail =>
      cases tail with
      | output V =>
        obtain ⟨W', V', ψ, hψ0, hψ, hprod, herr⟩ :=
          maurey_linear_pair W V φ hφ0 hφ x R ε hR hε hx m hm hbudget
        refine ⟨.layer W' ψ hψ0 hψ (.output V'), hprod, le_rfl, ⟨le_rfl, ?_⟩, ?_⟩
        · cases h <;> trivial
        · intro k
          have he : dist (V' (coordinateActivation ψ (W' (x k))))
              (V (coordinateActivation φ (W (x k)))) ≤ ε := by
            simpa only [dist_eq_norm] using (herr k).le
          change dist (V' (coordinateActivation ψ (W' (x k))))
            (V (coordinateActivation φ (W (x k)))) ≤ ((h + 1 : ℕ) : ℝ) * ε
          exact he.trans (by push_cast; nlinarith [Nat.cast_nonneg (α := ℝ) h])
      | @layer q r V χ hχ0 hχ tail =>
        have hT : 0 < tail.product := lt_of_le_of_ne tail.product_nonneg (by
          intro hz
          apply hN
          simp only [product, ← hz, mul_zero])
        have hbpair : 64 * (frobeniusNorm W * frobeniusNorm V * R) ^ 2 *
            (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * (ε / tail.product) ^ 2 := by
          calc
            _ = (64 * ((ScalarNetwork.layer W φ hφ0 hφ
                (.layer V χ hχ0 hχ tail)).product * R) ^ 2 *
                (1 + Real.log (Fintype.card K))) / tail.product ^ 2 := by
              dsimp [product]
              field_simp
            _ ≤ ((m : ℝ) * ε ^ 2) / tail.product ^ 2 :=
              div_le_div_of_nonneg_right hbudget (sq_nonneg _)
            _ = _ := by rw [div_pow, mul_div_assoc]
        obtain ⟨W', V', ψ, hψ0, hψ, hprod, herr⟩ :=
          maurey_linear_pair W V φ hφ0 hφ x R (ε / tail.product) hR
            (div_pos hε hT) hx m hm hbpair
        let T' : ScalarNetwork m := .layer V' χ hχ0 hχ tail
        let y : K → Euclid m := fun k ↦ coordinateActivation ψ (W' (x k))
        have hmid : ∀ k, dist (T'.eval (y k))
            ((ScalarNetwork.layer W φ hφ0 hφ (.layer V χ hχ0 hχ tail)).eval (x k)) ≤ ε := by
          intro k
          have ha := (coordinateActivation_lipschitz χ hχ).dist_le_mul
            (V' (coordinateActivation ψ (W' (x k)))) (V (coordinateActivation φ (W (x k))))
          have hb := tail.lipschitz.dist_le_mul
            (coordinateActivation χ (V' (coordinateActivation ψ (W' (x k)))))
            (coordinateActivation χ (V (coordinateActivation φ (W (x k)))))
          simp only [NNReal.coe_one, one_mul] at ha
          simp only [NNReal.coe_mk] at hb
          have he : dist (V' (coordinateActivation ψ (W' (x k))))
              (V (coordinateActivation φ (W (x k)))) ≤ ε / tail.product := by
            simpa only [dist_eq_norm] using (herr k).le
          apply hb.trans
          apply (mul_le_mul_of_nonneg_left (ha.trans he) tail.product_nonneg).trans_eq
          field_simp
        have hy : ∀ k, ‖y k‖ ≤ frobeniusNorm W' * R := by
          intro k
          exact (norm_coordinateActivation_le ψ hψ0 hψ (W' (x k))).trans
            ((norm_linear_le_frobenius W' (x k)).trans
              (mul_le_mul_of_nonneg_left (hx k) (frobeniusNorm_nonneg W')))
        by_cases hW' : frobeniusNorm W' = 0
        · refine ⟨.output 0, ?_, Nat.zero_le _, trivial, ?_⟩
          · simpa only [product, frobeniusNorm_zero] using
              (ScalarNetwork.layer W φ hφ0 hφ (.layer V χ hχ0 hχ tail)).product_nonneg
          · intro k
            have hy0 : y k = 0 := norm_eq_zero.mp (le_antisymm (by simpa [hW'] using hy k) (norm_nonneg _))
            have he := hmid k
            rw [hy0, T'.eval_zero] at he
            change dist 0 _ ≤ ((h + 1 : ℕ) : ℝ) * ε
            exact he.trans (by push_cast; nlinarith [Nat.cast_nonneg (α := ℝ) h])
        · have hW'pos : 0 < frobeniusNorm W' :=
            lt_of_le_of_ne (frobeniusNorm_nonneg W') (Ne.symm hW')
          have hcost : T'.product * (frobeniusNorm W' * R) ≤
              (ScalarNetwork.layer W φ hφ0 hφ (.layer V χ hχ0 hχ tail)).product * R := by
            calc
              _ = (frobeniusNorm W' * frobeniusNorm V') * tail.product * R := by dsimp [T', product]; ring
              _ ≤ (frobeniusNorm W * frobeniusNorm V) * tail.product * R :=
                mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hprod tail.product_nonneg) hR.le
              _ = _ := by dsimp [product]; ring
          have hN1 : (1 : ℝ) ≤ Fintype.card K := by exact_mod_cast Fintype.card_pos
          have hL : 0 ≤ 1 + Real.log (Fintype.card K) := by linarith [Real.log_nonneg hN1]
          have hbrec : 64 * (T'.product * (frobeniusNorm W' * R)) ^ 2 *
              (1 + Real.log (Fintype.card K)) ≤ (m : ℝ) * ε ^ 2 := by
            apply le_trans _ hbudget
            apply mul_le_mul_of_nonneg_right _ hL
            apply mul_le_mul_of_nonneg_left _ (by norm_num)
            exact (sq_le_sq₀ (mul_nonneg T'.product_nonneg (mul_nonneg hW'pos.le hR.le))
              (mul_nonneg (ScalarNetwork.layer W φ hφ0 hφ (.layer V χ hχ0 hχ tail)).product_nonneg hR.le)).mpr hcost
          obtain ⟨T'', hTprod, hTdepth, hTwidth, hTerr⟩ :=
            ih T' y (frobeniusNorm W' * R) ε (mul_pos hW'pos hR) hε hy hbrec
          refine ⟨.layer W' ψ hψ0 hψ T'', ?_, ?_, ⟨le_rfl, hTwidth⟩, ?_⟩
          · change frobeniusNorm W' * T''.product ≤ _
            calc
              _ ≤ frobeniusNorm W' * T'.product := mul_le_mul_of_nonneg_left hTprod hW'pos.le
              _ = (frobeniusNorm W' * frobeniusNorm V') * tail.product := by dsimp [T', product]; ring
              _ ≤ (frobeniusNorm W * frobeniusNorm V) * tail.product :=
                mul_le_mul_of_nonneg_right hprod tail.product_nonneg
              _ = _ := by dsimp [product]; ring
          · exact Nat.add_le_add_left hTdepth 1
          · intro k
            change dist (T''.eval (y k)) _ ≤ _
            apply (dist_triangle _ (T'.eval (y k)) _).trans
            have h1 := hTerr k
            have h2 := hmid k
            push_cast
            linarith

#print axioms compress_prefix

end ScalarNetwork
end
end BooleanDepthResearch
