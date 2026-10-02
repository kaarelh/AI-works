import Paulsen.Paper.ManyRowAux1

/-!
# Helpers for `lem:rowmoments`: the exact fourth moment of a Gaussian quadratic form

For a symmetric `A` and a standard Gaussian `g`,
`E (gᵀAg - tr A)⁴ = 12 (tr A²)² + 48 tr A⁴`.

Proof: in the eigenbasis the centred form is `∑ λ_k (g_k² - 1)` with independent summands;
for independent centred summands `E(∑ Y_k)⁴ = 3 (∑ E Y_k²)² + ∑ (E Y_k⁴ - 3 (E Y_k²)²)`
(induction on the index set), and `E (g²-1)² = 2`, `E (g²-1)⁴ = 60`
(from `E g⁶ = 15`, `E g⁸ = 105`, by differentiating the Gaussian MGF).
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators NNReal

noncomputable section

/-! ### Gaussian moments of order six and eight -/

theorem mrx_iteratedDeriv_eight_gaussian_mgf :
    iteratedDeriv 6 (fun t : ℝ => Real.exp (1 * t ^ 2 / 2)) 0 = 15 ∧
    iteratedDeriv 8 (fun t : ℝ => Real.exp (1 * t ^ 2 / 2)) 0 = 105 := by
  set e : ℝ → ℝ := fun t => Real.exp (1 * t ^ 2 / 2) with he
  have h0 (t : ℝ) : HasDerivAt e (t * e t) t := by
    convert! ((((hasDerivAt_id' t).pow 2).const_mul 1).div_const 2).exp using 1
    simp only [Pi.pow_apply, he]
    ring
  -- polynomial times `e`
  have hstep (p p' : ℝ → ℝ) (hp : ∀ t, HasDerivAt p (p' t) t) (t : ℝ) :
      HasDerivAt (fun s => p s * e s) ((p' t + t * p t) * e t) t := by
    convert! (hp t).mul (h0 t) using 1
    ring
  have hpoly (c : Fin 9 → ℝ) (t : ℝ) :
      HasDerivAt (fun s : ℝ => c 0 + c 1 * s + c 2 * s ^ 2 + c 3 * s ^ 3 + c 4 * s ^ 4 +
        c 5 * s ^ 5 + c 6 * s ^ 6 + c 7 * s ^ 7)
        (c 1 + 2 * c 2 * t + 3 * c 3 * t ^ 2 + 4 * c 4 * t ^ 3 + 5 * c 5 * t ^ 4 +
          6 * c 6 * t ^ 5 + 7 * c 7 * t ^ 6) t := by
    have h1 := (hasDerivAt_id' t).const_mul (c 1)
    have h2 := (hasDerivAt_pow 2 t).const_mul (c 2)
    have h3 := (hasDerivAt_pow 3 t).const_mul (c 3)
    have h4 := (hasDerivAt_pow 4 t).const_mul (c 4)
    have h5 := (hasDerivAt_pow 5 t).const_mul (c 5)
    have h6 := (hasDerivAt_pow 6 t).const_mul (c 6)
    have h7 := (hasDerivAt_pow 7 t).const_mul (c 7)
    have := (((((((hasDerivAt_const t (c 0)).add h1).add h2).add h3).add h4).add h5).add h6).add h7
    convert! this using 1
    norm_num
    ring
  -- the coefficient sequences of p₀,…,p₇
  let P : ℕ → Fin 9 → ℝ := fun k => match k with
    | 0 => ![1, 0, 0, 0, 0, 0, 0, 0, 0]
    | 1 => ![0, 1, 0, 0, 0, 0, 0, 0, 0]
    | 2 => ![1, 0, 1, 0, 0, 0, 0, 0, 0]
    | 3 => ![0, 3, 0, 1, 0, 0, 0, 0, 0]
    | 4 => ![3, 0, 6, 0, 1, 0, 0, 0, 0]
    | 5 => ![0, 15, 0, 10, 0, 1, 0, 0, 0]
    | 6 => ![15, 0, 45, 0, 15, 0, 1, 0, 0]
    | _ => ![0, 105, 0, 105, 0, 21, 0, 1, 0]
  let f : ℕ → ℝ → ℝ := fun k s => ((P k) 0 + (P k) 1 * s + (P k) 2 * s ^ 2 + (P k) 3 * s ^ 3 +
    (P k) 4 * s ^ 4 + (P k) 5 * s ^ 5 + (P k) 6 * s ^ 6 + (P k) 7 * s ^ 7) * e s
  have hderiv (k : ℕ) (hk : k < 7) : deriv (f k) = f (k + 1) := by
    funext t
    have h := hstep _ _ (hpoly (P k)) t
    rw [h.deriv]
    interval_cases k <;> (simp only [f]; congr 1; simp [P]; try ring_nf)
  have hf0 : (fun t : ℝ => Real.exp (1 * t ^ 2 / 2)) = f 0 := by
    funext t; simp [f, P, he]
  have hit (k : ℕ) (hk : k ≤ 7) : iteratedDeriv k (fun t : ℝ => Real.exp (1 * t ^ 2 / 2)) = f k := by
    induction k with
    | zero => rw [iteratedDeriv_zero, hf0]
    | succ k ih =>
      rw [iteratedDeriv_succ, ih (by omega), hderiv k (by omega)]
  constructor
  · rw [hit 6 (by norm_num)]
    simp [f, P, he]
  · rw [iteratedDeriv_succ, hit 7 (by norm_num)]
    have h := hstep _ _ (hpoly (P 7)) 0
    rw [h.deriv]
    simp [P, he]

theorem mrx_integral_pow_six_eight_gaussianReal :
    (∫ x : ℝ, x ^ 6 ∂gaussianReal 0 1) = 15 ∧ (∫ x : ℝ, x ^ 8 ∂gaussianReal 0 1) = 105 := by
  have h6 := iteratedDeriv_mgf_zero (X := id) (μ := gaussianReal 0 1) (by simp) 6
  have h8 := iteratedDeriv_mgf_zero (X := id) (μ := gaussianReal 0 1) (by simp) 8
  rw [mgf_id_gaussianReal] at h6 h8
  simp only [zero_mul, zero_add, Pi.pow_apply, id_eq, NNReal.coe_one] at h6 h8
  obtain ⟨e6, e8⟩ := mrx_iteratedDeriv_eight_gaussian_mgf
  exact ⟨h6 ▸ e6, h8 ▸ e8⟩

theorem mrx_integrable_pow_gaussianReal (k : ℕ) :
    Integrable (fun x : ℝ => x ^ k) (gaussianReal 0 1) := by
  have h := integrable_pow_of_mem_interior_integrableExpSet
    (X := id) (μ := gaussianReal 0 1) (by simp) k
  simpa only [id_eq] using h

/-- `E (g²-1)² = 2` and `E (g²-1)⁴ = 60` for a standard real Gaussian. -/
theorem mrx_centered_square_moments :
    (∫ x : ℝ, (x ^ 2 - 1) ^ 2 ∂gaussianReal 0 1) = 2 ∧
    (∫ x : ℝ, (x ^ 2 - 1) ^ 4 ∂gaussianReal 0 1) = 60 := by
  have i (k : ℕ) := mrx_integrable_pow_gaussianReal k
  have m2 : (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 1) = 1 := by
    simpa using integral_pow_two_gaussianReal 1
  have m4 : (∫ x : ℝ, x ^ 4 ∂gaussianReal 0 1) = 3 := by
    simpa using integral_pow_four_gaussianReal 1
  obtain ⟨m6, m8⟩ := mrx_integral_pow_six_eight_gaussianReal
  constructor
  · have e : (fun x : ℝ => (x ^ 2 - 1) ^ 2) = fun x => x ^ 4 - 2 * x ^ 2 + 1 := by
      funext x; ring
    have j1 : Integrable (fun x : ℝ => x ^ 4 - 2 * x ^ 2) (gaussianReal 0 1) :=
      (i 4).sub ((i 2).const_mul 2)
    rw [e, integral_add j1 (integrable_const _), integral_sub (i 4) ((i 2).const_mul 2),
      integral_const_mul, m4, m2]
    simp; norm_num
  · have e : (fun x : ℝ => (x ^ 2 - 1) ^ 4) =
        fun x => x ^ 8 - 4 * x ^ 6 + 6 * x ^ 4 - 4 * x ^ 2 + 1 := by
      funext x; ring
    have j1 : Integrable (fun x : ℝ => x ^ 8 - 4 * x ^ 6) (gaussianReal 0 1) :=
      (i 8).sub ((i 6).const_mul 4)
    have j2 : Integrable (fun x : ℝ => x ^ 8 - 4 * x ^ 6 + 6 * x ^ 4) (gaussianReal 0 1) :=
      j1.add ((i 4).const_mul 6)
    have j3 : Integrable (fun x : ℝ => x ^ 8 - 4 * x ^ 6 + 6 * x ^ 4 - 4 * x ^ 2)
        (gaussianReal 0 1) := j2.sub ((i 2).const_mul 4)
    rw [e, integral_add j3 (integrable_const _), integral_sub j2 ((i 2).const_mul 4),
      integral_add j1 ((i 4).const_mul 6), integral_sub (i 8) ((i 6).const_mul 4),
      integral_const_mul, integral_const_mul, integral_const_mul, m8, m6, m4, m2]
    simp; norm_num

/-! ### Fourth moment of a sum of independent centred variables -/

theorem mrx_integrable_pow_of_four {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω}
    [IsProbabilityMeasure P] {Y : Ω → ℝ} (hm : Measurable Y)
    (h4 : Integrable (fun ω => Y ω ^ 4) P) (k : ℕ) (hk : k ≤ 4) :
    Integrable (fun ω => Y ω ^ k) P := by
  refine ((integrable_const (1 : ℝ)).add h4).mono' (hm.pow_const k).aestronglyMeasurable
    (Filter.Eventually.of_forall fun ω => ?_)
  rw [Real.norm_eq_abs, abs_pow]
  have ha := abs_nonneg (Y ω)
  have h4' : Y ω ^ 4 = |Y ω| ^ 4 := by rw [← abs_pow, abs_of_nonneg (by positivity)]
  simp only [Pi.add_apply]
  rw [h4']
  rcases le_total (|Y ω|) 1 with h | h
  · have := pow_le_one₀ ha h (n := k)
    have := pow_nonneg ha 4
    linarith
  · have := pow_le_pow_right₀ h hk
    linarith

/-- `E(∑ Y_k)⁴ = 3(∑ E Y_k²)² + ∑ (E Y_k⁴ - 3(E Y_k²)²)` for independent centred summands. -/
theorem mrx_sum_indep_fourth_moment {Ω ι : Type*} [MeasurableSpace Ω] {P : Measure Ω}
    [IsProbabilityMeasure P] (Y : ι → Ω → ℝ) (hind : iIndepFun Y P)
    (hmeas : ∀ i, Measurable (Y i)) (h4 : ∀ i, Integrable (fun ω => Y i ω ^ 4) P)
    (hmean : ∀ i, ∫ ω, Y i ω ∂P = 0) (s : Finset ι) :
    Measurable (fun ω => ∑ i ∈ s, Y i ω) ∧
    Integrable (fun ω => (∑ i ∈ s, Y i ω) ^ 4) P ∧
    ∫ ω, ∑ i ∈ s, Y i ω ∂P = 0 ∧
    ∫ ω, (∑ i ∈ s, Y i ω) ^ 2 ∂P = ∑ i ∈ s, ∫ ω, Y i ω ^ 2 ∂P ∧
    ∫ ω, (∑ i ∈ s, Y i ω) ^ 4 ∂P = 3 * (∑ i ∈ s, ∫ ω, Y i ω ^ 2 ∂P) ^ 2 +
      ∑ i ∈ s, (∫ ω, Y i ω ^ 4 ∂P - 3 * (∫ ω, Y i ω ^ 2 ∂P) ^ 2) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s ha ih =>
    obtain ⟨hSm, hS4, hS1, hS2, hS4e⟩ := ih
    set S : Ω → ℝ := fun ω => ∑ i ∈ s, Y i ω with hSdef
    have hsum (ω : Ω) : ∑ i ∈ insert a s, Y i ω = Y a ω + S ω := Finset.sum_insert ha
    simp_rw [hsum]
    have hYm := hmeas a
    have hY (k : ℕ) (hk : k ≤ 4) := mrx_integrable_pow_of_four hYm (h4 a) k hk
    have hSk (k : ℕ) (hk : k ≤ 4) := mrx_integrable_pow_of_four (P := P) hSm hS4 k hk
    have hind' : IndepFun S (Y a) P := by
      have h := hind.indepFun_finsetSum_of_notMem hmeas ha
      have e : (∑ j ∈ s, Y j) = S := by funext ω; simp [hSdef, Finset.sum_apply]
      rwa [e] at h
    have hpow (p q : ℕ) : IndepFun (fun ω => S ω ^ p) (fun ω => Y a ω ^ q) P :=
      hind'.comp (measurable_id.pow_const p) (measurable_id.pow_const q)
    have hprod (p q : ℕ) (hp : p ≤ 4) (hq : q ≤ 4) :
        Integrable (fun ω => S ω ^ p * Y a ω ^ q) P :=
      (hpow p q).integrable_mul (hSk p hp) (hY q hq)
    have hmul (p q : ℕ) : ∫ ω, S ω ^ p * Y a ω ^ q ∂P =
        (∫ ω, S ω ^ p ∂P) * ∫ ω, Y a ω ^ q ∂P :=
      (hpow p q).integral_fun_mul_eq_mul_integral
        (hSm.pow_const p).aestronglyMeasurable (hYm.pow_const q).aestronglyMeasurable
    have hS1' : ∫ ω, S ω ^ 1 ∂P = 0 := by simpa using hS1
    have hY1 : ∫ ω, Y a ω ^ 1 ∂P = 0 := by simpa using hmean a
    refine ⟨hYm.add hSm, ?_, ?_, ?_, ?_⟩
    · have e : (fun ω => (Y a ω + S ω) ^ 4) = fun ω => Y a ω ^ 4 + 4 * (S ω ^ 1 * Y a ω ^ 3) +
          6 * (S ω ^ 2 * Y a ω ^ 2) + 4 * (S ω ^ 3 * Y a ω ^ 1) + S ω ^ 4 := by
        funext ω; ring
      rw [e]
      exact (((((h4 a).add ((hprod 1 3 (by norm_num) (by norm_num)).const_mul 4)).add
        ((hprod 2 2 (by norm_num) (by norm_num)).const_mul 6)).add
        ((hprod 3 1 (by norm_num) (by norm_num)).const_mul 4)).add hS4)
    · have i1 : Integrable (fun ω => Y a ω) P := by simpa using hY 1 (by norm_num)
      have i2 : Integrable (fun ω => S ω) P := by simpa using hSk 1 (by norm_num)
      rw [integral_add i1 i2, hmean a, hS1, add_zero]
    · have e : (fun ω => (Y a ω + S ω) ^ 2) = fun ω => Y a ω ^ 2 + 2 * (S ω ^ 1 * Y a ω ^ 1) +
          S ω ^ 2 := by
        funext ω; ring
      have j1 : Integrable (fun ω => Y a ω ^ 2 + 2 * (S ω ^ 1 * Y a ω ^ 1)) P :=
        (hY 2 (by norm_num)).add ((hprod 1 1 (by norm_num) (by norm_num)).const_mul 2)
      rw [e, integral_add j1 (hSk 2 (by norm_num)),
        integral_add (hY 2 (by norm_num)) ((hprod 1 1 (by norm_num) (by norm_num)).const_mul 2),
        integral_const_mul, hmul, hS1', zero_mul, mul_zero, add_zero, hS2,
        Finset.sum_insert ha]
    · have e : (fun ω => (Y a ω + S ω) ^ 4) = fun ω => Y a ω ^ 4 + 4 * (S ω ^ 1 * Y a ω ^ 3) +
          6 * (S ω ^ 2 * Y a ω ^ 2) + 4 * (S ω ^ 3 * Y a ω ^ 1) + S ω ^ 4 := by
        funext ω; ring
      have j1 : Integrable (fun ω => Y a ω ^ 4 + 4 * (S ω ^ 1 * Y a ω ^ 3)) P :=
        (h4 a).add ((hprod 1 3 (by norm_num) (by norm_num)).const_mul 4)
      have j2 : Integrable (fun ω => Y a ω ^ 4 + 4 * (S ω ^ 1 * Y a ω ^ 3) +
          6 * (S ω ^ 2 * Y a ω ^ 2)) P :=
        j1.add ((hprod 2 2 (by norm_num) (by norm_num)).const_mul 6)
      have j3 : Integrable (fun ω => Y a ω ^ 4 + 4 * (S ω ^ 1 * Y a ω ^ 3) +
          6 * (S ω ^ 2 * Y a ω ^ 2) + 4 * (S ω ^ 3 * Y a ω ^ 1)) P :=
        j2.add ((hprod 3 1 (by norm_num) (by norm_num)).const_mul 4)
      rw [e, integral_add j3 (hSk 4 (by norm_num)),
        integral_add j2 ((hprod 3 1 (by norm_num) (by norm_num)).const_mul 4),
        integral_add j1 ((hprod 2 2 (by norm_num) (by norm_num)).const_mul 6),
        integral_add (h4 a) ((hprod 1 3 (by norm_num) (by norm_num)).const_mul 4),
        integral_const_mul, integral_const_mul, integral_const_mul, hmul, hmul, hmul,
        hS1', hY1, Finset.sum_insert ha, Finset.sum_insert ha]
      have hS4e' : ∫ ω, S ω ^ 4 ∂P = 3 * (∑ i ∈ s, ∫ ω, Y i ω ^ 2 ∂P) ^ 2 +
          ∑ i ∈ s, (∫ ω, Y i ω ^ 4 ∂P - 3 * (∫ ω, Y i ω ^ 2 ∂P) ^ 2) := hS4e
      have hS2' : ∫ ω, S ω ^ 2 ∂P = ∑ i ∈ s, ∫ ω, Y i ω ^ 2 ∂P := hS2
      rw [hS4e', hS2']
      ring

/-! ### The fourth moment of a centred Gaussian quadratic form -/

/-- `E (gᵀAg - tr A)⁴ = 12 (tr A²)² + 48 tr A⁴` (exact Gaussian moment formula). -/
theorem mrx_fourth_moment_quadratic {κ : Type*} [Fintype κ] [DecidableEq κ]
    (A : Matrix κ κ ℝ) (hA : A.IsHermitian) :
    Integrable (fun g : EuclideanSpace ℝ κ => (euclideanQuadratic A g - A.trace) ^ 4)
      (stdGaussian (EuclideanSpace ℝ κ)) ∧
    ∫ g, (euclideanQuadratic A g - A.trace) ^ 4 ∂stdGaussian (EuclideanSpace ℝ κ) =
      12 * ((A ^ 2).trace) ^ 2 + 48 * (A ^ 4).trace := by
  set lam := hA.eigenvalues
  set γ : Measure (κ → ℝ) := Measure.pi fun _ : κ => gaussianReal 0 1
  have hg : Measurable (fun x : κ → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  have hfun : (fun x : EuclideanSpace ℝ κ => (euclideanQuadratic A x - A.trace) ^ 4) ∘
      (fun y : κ → ℝ => ∑ i, y i • hA.eigenvectorBasis i) =
      fun y : κ → ℝ => (∑ i, lam i * ((y i) ^ 2 - 1)) ^ 4 := by
    ext y
    simp only [Function.comp_apply]
    rw [centered_euclideanQuadratic_eigenbasis A hA y]
  -- the independent summands
  set Y : κ → (κ → ℝ) → ℝ := fun i y => lam i * ((y i) ^ 2 - 1) with hY
  have hind : iIndepFun Y γ := by
    have := iIndepFun_pi (μ := fun _ : κ => gaussianReal 0 1)
      (X := fun i (x : ℝ) => lam i * (x ^ 2 - 1)) (fun i => by fun_prop)
    exact this
  have hmeas (i : κ) : Measurable (Y i) := by simp only [hY]; fun_prop
  obtain ⟨c2, c4⟩ := mrx_centered_square_moments
  have hint1 (i : κ) (k : ℕ) : Integrable (fun x : ℝ => (lam i * (x ^ 2 - 1)) ^ k)
      (gaussianReal 0 1) := by
    have e : (fun x : ℝ => (lam i * (x ^ 2 - 1)) ^ k) =
        fun x => lam i ^ k * ((x ^ 2 - 1) ^ k) := by funext x; rw [mul_pow]
    rw [e]
    apply Integrable.const_mul
    have hp : (fun x : ℝ => (x ^ 2 - 1) ^ k) = fun x => ∑ j ∈ Finset.range (k + 1),
        ((-1 : ℝ) ^ (k - j) * (k.choose j : ℝ)) * x ^ (2 * j) := by
      funext x; rw [sub_eq_add_neg, add_pow]
      apply Finset.sum_congr rfl; intro j _
      rw [pow_mul]; ring
    rw [hp]
    exact integrable_finsetSum _ fun j _ => (mrx_integrable_pow_gaussianReal (2 * j)).const_mul _
  have hcomp (i : κ) (k : ℕ) : ∫ y, Y i y ^ k ∂γ =
      ∫ x : ℝ, (lam i * (x ^ 2 - 1)) ^ k ∂gaussianReal 0 1 :=
    integral_comp_eval (μ := fun _ : κ => gaussianReal 0 1) (i := i)
      (f := fun x : ℝ => (lam i * (x ^ 2 - 1)) ^ k) (by fun_prop)
  have h4 (i : κ) : Integrable (fun y => Y i y ^ 4) γ :=
    integrable_comp_eval (μ := fun _ : κ => gaussianReal 0 1) (i := i) (hint1 i 4)
  have hmean (i : κ) : ∫ y, Y i y ∂γ = 0 := by
    have := hcomp i 1
    simp only [pow_one] at this
    rw [this, integral_const_mul, integral_sub (mrx_integrable_pow_gaussianReal 2)
      (integrable_const _)]
    have m2 : (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 1) = 1 := by
      simpa using integral_pow_two_gaussianReal 1
    simp [m2]
  have hY2 (i : κ) : ∫ y, Y i y ^ 2 ∂γ = 2 * lam i ^ 2 := by
    rw [hcomp]
    have e : (fun x : ℝ => (lam i * (x ^ 2 - 1)) ^ 2) = fun x => lam i ^ 2 * (x ^ 2 - 1) ^ 2 := by
      funext x; ring
    rw [e, integral_const_mul, c2]; ring
  have hY4 (i : κ) : ∫ y, Y i y ^ 4 ∂γ = 60 * lam i ^ 4 := by
    rw [hcomp]
    have e : (fun x : ℝ => (lam i * (x ^ 2 - 1)) ^ 4) = fun x => lam i ^ 4 * (x ^ 2 - 1) ^ 4 := by
      funext x; ring
    rw [e, integral_const_mul, c4]; ring
  obtain ⟨-, hI, -, -, hE⟩ := mrx_sum_indep_fourth_moment Y hind hmeas h4 hmean Finset.univ
  have htr2 : (A ^ 2).trace = ∑ i, lam i ^ 2 := trace_pow_eq_sum_eigenvalues A hA 2
  have htr4 : (A ^ 4).trace = ∑ i, lam i ^ 4 := trace_pow_eq_sum_eigenvalues A hA 4
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis]
  have hmeasF : AEStronglyMeasurable
      (fun x : EuclideanSpace ℝ κ => (euclideanQuadratic A x - A.trace) ^ 4)
      ((Measure.pi fun _ : κ => gaussianReal 0 1).map
        (fun y : κ → ℝ => ∑ i, y i • hA.eigenvectorBasis i)) := by
    apply Continuous.aestronglyMeasurable
    unfold euclideanQuadratic
    fun_prop
  constructor
  · rw [integrable_map_measure hmeasF hg.aemeasurable, hfun]
    exact hI
  · rw [integral_map hg.aemeasurable hmeasF]
    change ∫ y, ((fun x : EuclideanSpace ℝ κ => (euclideanQuadratic A x - A.trace) ^ 4) ∘
      (fun y : κ → ℝ => ∑ i, y i • hA.eigenvectorBasis i)) y ∂γ = _
    rw [hfun]
    change ∫ y, (∑ i, Y i y) ^ 4 ∂γ = _
    rw [hE, htr2, htr4]
    simp_rw [hY2, hY4]
    have : ∀ i, 60 * lam i ^ 4 - 3 * (2 * lam i ^ 2) ^ 2 = 48 * lam i ^ 4 := fun i => by ring
    simp_rw [this]
    rw [← Finset.mul_sum, ← Finset.mul_sum]
    ring

end

end Paulsen.Paper
