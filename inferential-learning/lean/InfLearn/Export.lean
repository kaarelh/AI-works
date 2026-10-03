import InfLearn.Prelude

/-!
# Export and certification: T3 §3.1 and §4

This file formalizes the "no free export" results of T3 §3.1 and the certification results
of T3 §4 (`research/theory/T3-contexts-idealization-export.md`, with its Verification log:
B2's corrected closure hypothesis `𝓒 + C^∞ ⊆ 𝓒` for Thm 3.3, B3's lazy bisection for
Thm 4.6, B11's "deterministic certifier" for Thm 4.4, B12's `γ > η` for Thm 4.5).

Conventions.  A *family* is its query function `Q : D → ℝ` (`D = ℝ`, `[0, Λ]` or an arbitrary
parameter type), a *family class* is `𝓒 : Set (D → ℝ)`, an *information map* is any
`I : (D → ℝ) → α`, and an *export rule* `E : α → D → Option (ℝ × ℝ)` returns `none`
(abstain) or `some (q, ε)`, the interval `[q - ε, q + ε]`.  `SoundAt 𝓒 I E λ*` is soundness at
the actual value `λ*`.  Real numbers `lam` stand for `λ*`.

## §3.1 No free export
* `invisible_perturbation`: **Lemma 3.2**, verbatim, for any parameter type.
* `no_free_export_perturbation`, `samples_do_not_determine`: for finite `S`, `λ* ∉ S`, any
  `Q` and any `ε`, `Q' = Q + A·∏_{s∈S}(λ - s)` agrees with `Q` on `S` and
  `|Q'(λ*) - Q(λ*)| > ε` (indeed `Q'(λ*)` can be any prescribed value).
* `no_free_export_samples` (+ `_everywhere`, `_emb`, `_Icc`, `no_free_export_from_samples`,
  `no_sound_committing_rule`): **Thm 3.3(d)**.  The closure hypothesis is closure under adding
  real multiples of the node polynomial, which `𝓒 + C^∞ ⊆ 𝓒` implies (the node polynomial is
  smooth) and so does closure under adding polynomials (`nodeClosed_of_addPolyClosed`).
* `no_free_export_samples_of_poly_subset`: Thm 3.3(d) under `𝓒 ⊇ polynomials` (hence under
  `𝓒 ⊇ C^∞`), for **every** `Q ∈ 𝓒`, via interpolation (`exists_poly_interp`).  This
  strengthens the paper's closing remark for case (d); its `√λ` counterexample concerns (b).
* `no_free_export_finite_jet`, `no_free_export_finite_jet'`: **Thm 3.3(c)** with `f = λ^{N+1}`,
  for every class containing the polynomials and every information map that reads only the
  coefficients `0..N` of a polynomial.  The identification of the derivative jet of an
  entire/`C^N` function with Taylor coefficients is not formalized (no calculus in the compiled
  Mathlib subset); it enters as the hypotheses `hjet`, `hrep`.
* `no_free_export_away`, `no_free_export_germ`: **Thm 3.3(b) with tents.**  The paper uses a
  `C^∞` bump under `𝓒 + C^∞ ⊆ 𝓒`; `ContDiff` is not in the compiled subset, so here the class
  is assumed closed under adding multiples of Lipschitz tents `max 0 (r - dist x c)` instead.
* `exists_interval_iff_radius_le`, `midrange_sound`, `optimalRule_sound`,
  `radius_le_of_sound`, `no_interval_of_unbounded`: **Prop 3.4** (minimax export = radius of
  information; the midrange rule is optimal).
* Thm 3.3(a) (full jet, flat function `e^{-1/λ²}`) is not formalized.

## §4 Learning validity regions
* `coherence_cannot_calibrate`, `_unbounded`: **Thm 4.1** (common shifts of size `β` force
  `ε̂_s ≥ β`; unbounded shifts rule out every sound coherence-only calibrator).
* `no_certification_without_regularity`: **Thm 4.4**, deterministic part, in any metric space,
  with tents as the continuous bumps.  The almost-sure randomized clause is not formalized.
* `lip_cert_sound_point`, `lip_cert_sound_indexed`, `lip_cert_sound`, `lip_cert_sound_noisy`:
  **Thm 4.5(a)** in any pseudometric space (so `|·|` on `ℝ` and the sup metric on
  `ℝ^d = Fin d → ℝ`, which is Mathlib's metric on `Fin d → ℝ`: `dist_le_iff_sup`).
* `lip_cert_complete_of_net`, `lip_cert_complete`, `lip_cert_complete'`: **Thm 4.5(b)** on
  `[0,1]^d` with the grid of `⌈1/h⌉^d = ⌈L/(γ-η)⌉^d` cell centres.
* `lip_lower_bound_of_packing`, `lip_lower_bound_cube`, `lip_lower_bound_cube_adaptive`,
  `lip_lower_bound_interval`: **Thm 4.5(c)**, `≥ ⌊L/(2γ')⌋^d` queries for every `γ' > γ`.
  A deterministic certifier with an exact oracle is modelled abstractly (`LocalCertifier`: the
  output depends on `e` only through `e` on the queried set) and concretely
  (`AdaptiveCertifier`: query `k+1` is a function of the first `k` answers, fixed budget);
  `AdaptiveCertifier.toLocal` shows the second is an instance of the first.  The certifier is
  required to be sound and complete only on points of the cube; the class is the globally
  `L`-Lipschitz functions on `ℝ^d`.  The randomized remark after Thm 4.5 is not formalized.
* `lazy_bisection_sound`, `lazy_bisection_miss`, `lazy_bisection_resolution`,
  `mono_lower_bound`, `mono_lower_bound_ceil`: **Thm 4.6** in one dimension (lazy bisection is
  sound with a validated upper oracle; with an exact oracle the missed part of `{e ≤ τ}` lies in
  an interval of length `2^{-k}`; any sound deterministic adaptive certifier with resolution `h`
  needs `2^q ≥ ⌈1/h⌉`, i.e. `q ≥ ⌈log₂(1/h)⌉`).  "Missing at most length `h`" is formalized as
  "the missed set contains no interval `[a, b)` with `b - a > h`", which is implied by
  "measure `≤ h`", so the lower bound covers the measure reading too.  The `d ≥ 2` sketch and
  the endpoint variant are not formalized.
-/

namespace InfLearn.Export

open Polynomial

/-! ## Part 1: export rules and Lemma 3.2 -/

section ExportRules

variable {D α : Type*}

/-- An export rule maps the information value and the actual parameter value `λ*` to
`none` ("abstain") or to `some (q, ε)`, meaning the interval `[q - ε, q + ε]`. -/
abbrev ExportRule (α D : Type*) := α → D → Option (ℝ × ℝ)

/-- `E` is sound on the family class `𝓒` at the actual value `lam`. -/
def SoundAt (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (E : ExportRule α D) (lam : D) : Prop :=
  ∀ Q ∈ 𝓒, ∀ q ε : ℝ, E (I Q) lam = some (q, ε) → Q lam ∈ Set.Icc (q - ε) (q + ε)

/-- `E` is sound on `𝓒` at every actual value. -/
def Sound (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (E : ExportRule α D) : Prop :=
  ∀ lam, SoundAt 𝓒 I E lam

/-- Core of the adversary argument: if the whole line `Q + A f` (`A ∈ ℝ`) lies in `𝓒` and
carries the same information `i`, and `f(λ*) ≠ 0`, a rule sound at `λ*` abstains on `i`. -/
theorem abstain_of_line {𝓒 : Set (D → ℝ)} {I : (D → ℝ) → α} {E : ExportRule α D} {lam : D}
    (hE : SoundAt 𝓒 I E lam) (Q f : D → ℝ) (hf : f lam ≠ 0)
    (hmem : ∀ A : ℝ, (fun x => Q x + A * f x) ∈ 𝓒) (i : α)
    (hI : ∀ A : ℝ, I (fun x => Q x + A * f x) = i) : E i lam = none := by
  rcases h : E i lam with _ | ⟨q, ε⟩
  · rfl
  · exfalso
    have h1 := hE _ (hmem ((q + ε + 1 - Q lam) / f lam)) q ε (by rw [hI]; exact h)
    have h2 : Q lam + (q + ε + 1 - Q lam) / f lam * f lam = q + ε + 1 := by
      rw [div_mul_cancel₀ _ hf]; ring
    simp only [Set.mem_Icc] at h1
    linarith [h1.2]

/-- **T3 Lemma 3.2 (invisible perturbation).** If `f(λ*) ≠ 0` and, for every `Q ∈ 𝓒` and
`A ∈ ℝ`, `Q + A f ∈ 𝓒` and `I(Q + A f) = I(Q)`, then every export rule sound on `𝓒` at `λ*`
abstains at `λ*` on every `Q ∈ 𝓒`.  The parameter space `D` is arbitrary (one or many
parameters). -/
theorem invisible_perturbation (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (E : ExportRule α D)
    (lam : D) (f : D → ℝ) (hf : f lam ≠ 0)
    (hcl : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * f x) ∈ 𝓒)
    (hI : ∀ Q ∈ 𝓒, ∀ A : ℝ, I (fun x => Q x + A * f x) = I Q)
    (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none :=
  fun Q hQ => abstain_of_line hE Q f hf (hcl Q hQ) (I Q) (hI Q hQ)

end ExportRules

/-! ## Part 2: finitely many samples (Thm 3.3(d)) -/

section Samples

variable {α : Type*}

/-- The node polynomial `∏_{s ∈ S} (x - s)`. -/
def nodePoly (S : Finset ℝ) (x : ℝ) : ℝ := ∏ s ∈ S, (x - s)

/-- The node polynomial vanishes on the sample set. -/
theorem nodePoly_eq_zero {S : Finset ℝ} {s : ℝ} (hs : s ∈ S) : nodePoly S s = 0 :=
  Finset.prod_eq_zero hs (sub_self s)

/-- The node polynomial is nonzero off the sample set. -/
theorem nodePoly_ne_zero {S : Finset ℝ} {x : ℝ} (hx : x ∉ S) : nodePoly S x ≠ 0 := by
  unfold nodePoly
  rw [Finset.prod_ne_zero_iff]
  intro s hs h
  exact hx (by rw [sub_eq_zero.mp h]; exact hs)

/-- The node polynomial as a polynomial. -/
noncomputable def nodePolynomial (S : Finset ℝ) : ℝ[X] := ∏ s ∈ S, (X - C s)

theorem eval_nodePolynomial (S : Finset ℝ) (x : ℝ) :
    (nodePolynomial S).eval x = nodePoly S x := by
  simp [nodePolynomial, nodePoly, eval_prod]

/-- Finitely many samples do not constrain `Q(λ*)`: for every target value `v` there is
`A` with `Q' = Q + A ∏_{s∈S}(λ - s)` equal to `Q` on `S` and `Q'(λ*) = v`. -/
theorem samples_do_not_determine (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S) (Q : ℝ → ℝ)
    (v : ℝ) : ∃ A : ℝ, (∀ s ∈ S, Q s + A * nodePoly S s = Q s) ∧
      Q lam + A * nodePoly S lam = v := by
  refine ⟨(v - Q lam) / nodePoly S lam, fun s hs => by simp [nodePoly_eq_zero hs], ?_⟩
  rw [div_mul_cancel₀ _ (nodePoly_ne_zero hlam)]; ring

/-- **The task's form of T3 Thm 3.3(d) / Lemma 3.2.** For finite `S`, `λ* ∉ S`, any
`Q : ℝ → ℝ` and any `ε`, some `Q' = Q + A ∏_{s∈S}(λ - s)` agrees with `Q` on `S` and has
`|Q'(λ*) - Q(λ*)| > ε`. -/
theorem no_free_export_perturbation (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S) (Q : ℝ → ℝ)
    (ε : ℝ) : ∃ A : ℝ, (∀ s ∈ S, Q s + A * nodePoly S s = Q s) ∧
      ε < |(Q lam + A * nodePoly S lam) - Q lam| := by
  obtain ⟨A, hS, hv⟩ := samples_do_not_determine S lam hlam Q (Q lam + (ε + 1))
  refine ⟨A, hS, ?_⟩
  rw [hv, add_sub_cancel_left]
  exact lt_of_lt_of_le (by linarith) (le_abs_self _)

/-- Polynomial interpolation through finitely many points (Newton form, by induction). -/
theorem exists_poly_interp (S : Finset ℝ) (Q : ℝ → ℝ) :
    ∃ p : ℝ[X], ∀ s ∈ S, p.eval s = Q s := by
  classical
  induction S using Finset.induction_on with
  | empty => exact ⟨0, by simp⟩
  | insert a T ha ih =>
    obtain ⟨p, hp⟩ := ih
    refine ⟨p + C ((Q a - p.eval a) / nodePoly T a) * nodePolynomial T, ?_⟩
    intro s hs
    rcases Finset.mem_insert.mp hs with rfl | hs
    · simp only [eval_add, eval_mul, eval_C, eval_nodePolynomial]
      rw [div_mul_cancel₀ _ (nodePoly_ne_zero ha)]; ring
    · simp [eval_nodePolynomial, nodePoly_eq_zero hs, hp s hs]

/-- `I` reads only the values of `Q` on `S`. -/
def SampleInfo {D : Type*} (S : Set D) (I : (D → ℝ) → α) : Prop :=
  ∀ Q Q' : D → ℝ, (∀ s ∈ S, Q s = Q' s) → I Q = I Q'

/-- The sample vector `(Q s)_{s ∈ S}`. -/
def sampleValues (S : Finset ℝ) (Q : ℝ → ℝ) : S → ℝ := fun s => Q s

theorem sampleInfo_sampleValues (S : Finset ℝ) : SampleInfo (↑S : Set ℝ) (sampleValues S) := by
  intro Q Q' h
  funext s
  exact h s s.2

/-- `g` is a polynomial function. -/
def IsPolyFun (g : ℝ → ℝ) : Prop := ∃ p : ℝ[X], ∀ x, g x = p.eval x

theorem isPolyFun_smul_nodePoly (S : Finset ℝ) (A : ℝ) :
    IsPolyFun (fun x => A * nodePoly S x) :=
  ⟨C A * nodePolynomial S, fun x => by simp [eval_nodePolynomial]⟩

/-- A class closed under adding polynomial functions (in particular, one closed under adding
`C^∞` functions) is closed under adding multiples of the node polynomial. -/
theorem nodeClosed_of_addPolyClosed {𝓒 : Set (ℝ → ℝ)}
    (h : ∀ Q ∈ 𝓒, ∀ g, IsPolyFun g → (fun x => Q x + g x) ∈ 𝓒) (S : Finset ℝ) :
    ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly S x) ∈ 𝓒 :=
  fun Q hQ A => h Q hQ _ (isPolyFun_smul_nodePoly S A)

/-- **T3 Thm 3.3(d) (no free export from finitely many samples).** If `I` reads only the values
of `Q` on the finite set `S`, `λ* ∉ S`, and `𝓒` is closed under adding real multiples of the
node polynomial `∏_{s∈S}(λ - s)` (implied by `𝓒 + C^∞ ⊆ 𝓒`, and by closure under adding
polynomials), then every rule sound on `𝓒` at `λ*` abstains on every `Q ∈ 𝓒`. -/
theorem no_free_export_samples (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S)
    (𝓒 : Set (ℝ → ℝ)) (I : (ℝ → ℝ) → α) (hI : SampleInfo (↑S : Set ℝ) I)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly S x) ∈ 𝓒)
    (E : ExportRule α ℝ) (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none :=
  invisible_perturbation 𝓒 I E lam (nodePoly S) (nodePoly_ne_zero hlam) h𝓒
    (fun Q _ A => hI _ _ (fun s hs => by simp [nodePoly_eq_zero hs])) hE

/-- Thm 3.3(d), all actual values at once: a rule sound on `𝓒` abstains at every `λ* ∉ S`. -/
theorem no_free_export_samples_everywhere (S : Finset ℝ)
    (𝓒 : Set (ℝ → ℝ)) (I : (ℝ → ℝ) → α) (hI : SampleInfo (↑S : Set ℝ) I)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly S x) ∈ 𝓒)
    (E : ExportRule α ℝ) (hE : Sound 𝓒 I E) :
    ∀ lam ∉ S, ∀ Q ∈ 𝓒, E (I Q) lam = none :=
  fun lam hlam => no_free_export_samples S lam hlam 𝓒 I hI h𝓒 E (hE lam)

/-- Thm 3.3(d) on any parameter domain `D` embedded in `ℝ` (e.g. `[0, Λ]`). -/
theorem no_free_export_samples_emb {D : Type*} (ι : D → ℝ) (hι : Function.Injective ι)
    (S : Finset D) (lam : D) (hlam : lam ∉ S)
    (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (hI : SampleInfo (↑S : Set D) I)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly (S.image ι) (ι x)) ∈ 𝓒)
    (E : ExportRule α D) (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  refine invisible_perturbation 𝓒 I E lam (fun x => nodePoly (S.image ι) (ι x))
    (nodePoly_ne_zero (fun h => hlam ?_)) h𝓒 ?_ hE
  · obtain ⟨s, hs, hs'⟩ := Finset.mem_image.mp h
    rw [← hι hs']; exact hs
  · intro Q _ A
    apply hI
    intro s hs
    simp [nodePoly_eq_zero (Finset.mem_image_of_mem ι hs)]

/-- Thm 3.3(d) literally on the paper's domain `[0, Λ]`, with families `Q : [0, Λ] → ℝ`. -/
theorem no_free_export_samples_Icc (Λ : ℝ) (S : Finset (Set.Icc (0 : ℝ) Λ))
    (lam : Set.Icc (0 : ℝ) Λ) (hlam : lam ∉ S)
    (𝓒 : Set (Set.Icc (0 : ℝ) Λ → ℝ)) (I : (Set.Icc (0 : ℝ) Λ → ℝ) → α)
    (hI : SampleInfo (↑S : Set (Set.Icc (0 : ℝ) Λ)) I)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ,
      (fun x => Q x + A * nodePoly (S.image Subtype.val) (x : ℝ)) ∈ 𝓒)
    (E : ExportRule α (Set.Icc (0 : ℝ) Λ)) (hE : SoundAt 𝓒 I E lam) :
    ∀ Q ∈ 𝓒, E (I Q) lam = none :=
  no_free_export_samples_emb Subtype.val Subtype.val_injective S lam hlam 𝓒 I hI h𝓒 E hE

/-- Thm 3.3(d) for export rules that are functions of the sample vector `(Q(s))_{s ∈ S}`. -/
theorem no_free_export_from_samples (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S)
    (𝓒 : Set (ℝ → ℝ)) (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly S x) ∈ 𝓒)
    (E : ExportRule (S → ℝ) ℝ) (hE : SoundAt 𝓒 (sampleValues S) E lam) :
    ∀ Q ∈ 𝓒, E (sampleValues S Q) lam = none :=
  no_free_export_samples S lam hlam 𝓒 (sampleValues S) (sampleInfo_sampleValues S) h𝓒 E hE

/-- No export rule that is a function of the samples and never abstains is sound. -/
theorem no_sound_committing_rule (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S)
    (𝓒 : Set (ℝ → ℝ)) (hne : 𝓒.Nonempty)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ A : ℝ, (fun x => Q x + A * nodePoly S x) ∈ 𝓒)
    (E : ExportRule (S → ℝ) ℝ) (hE : SoundAt 𝓒 (sampleValues S) E lam) :
    ¬ ∀ v : S → ℝ, (E v lam).isSome := by
  intro h
  obtain ⟨Q, hQ⟩ := hne
  have := no_free_export_from_samples S lam hlam 𝓒 h𝓒 E hE Q hQ
  have h2 := h (sampleValues S Q)
  rw [this] at h2
  exact absurd h2 (by simp)

/-- **T3 Thm 3.3(d) under `𝓒 ⊇ polynomials`.**  The paper's remark says that under
`𝓒 ⊇ C^∞` alone the conclusion is only guaranteed for smooth `Q`.  For *finitely many samples*
it holds for every `Q ∈ 𝓒`: the interpolating polynomial has the same samples, and the line
through it lies in `𝓒`. -/
theorem no_free_export_samples_of_poly_subset (S : Finset ℝ) (lam : ℝ) (hlam : lam ∉ S)
    (𝓒 : Set (ℝ → ℝ)) (I : (ℝ → ℝ) → α) (hI : SampleInfo (↑S : Set ℝ) I)
    (hpoly : ∀ p : ℝ[X], (fun x => p.eval x) ∈ 𝓒)
    (E : ExportRule α ℝ) (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  intro Q _
  obtain ⟨p, hp⟩ := exists_poly_interp S Q
  refine abstain_of_line hE (fun x => p.eval x) (nodePoly S) (nodePoly_ne_zero hlam) ?_ (I Q) ?_
  · intro A
    have := hpoly (p + C A * nodePolynomial S)
    simpa [eval_nodePolynomial] using this
  · intro A
    apply hI
    intro s hs
    simp [nodePoly_eq_zero hs, hp s hs]

/-- **T3 Thm 3.3(c) (finite jets), abstract form.**  `𝓒` contains every polynomial function,
the information map `I` reads only the coefficients `0..N` of a polynomial, and every
`Q ∈ 𝓒` shares its information with some polynomial (for the derivative `N`-jet of a
`C^N` function: its Taylor polynomial).  Then every rule sound on `𝓒` at `λ* ≠ 0` abstains.
The perturbation is `f(λ) = λ^{N+1}`. -/
theorem no_free_export_finite_jet (N : ℕ) (𝓒 : Set (ℝ → ℝ)) (I : (ℝ → ℝ) → α)
    (hpoly : ∀ p : ℝ[X], (fun x => p.eval x) ∈ 𝓒)
    (hjet : ∀ p q : ℝ[X], (∀ j ≤ N, p.coeff j = q.coeff j) →
      I (fun x => p.eval x) = I (fun x => q.eval x))
    (hrep : ∀ Q ∈ 𝓒, ∃ p : ℝ[X], I (fun x => p.eval x) = I Q)
    (lam : ℝ) (hlam : lam ≠ 0) (E : ExportRule α ℝ) (hE : SoundAt 𝓒 I E lam) :
    ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  intro Q hQ
  obtain ⟨p, hp⟩ := hrep Q hQ
  refine abstain_of_line hE (fun x => p.eval x) (fun x => x ^ (N + 1)) (pow_ne_zero _ hlam)
    ?_ (I Q) ?_
  · intro A
    have := hpoly (p + C A * X ^ (N + 1))
    simpa using this
  · intro A
    rw [← hp]
    have := hjet (p + C A * X ^ (N + 1)) p (fun j hj => by
      have : j ≠ N + 1 := by omega
      simp [coeff_X_pow, this])
    simpa using this

/-- T3 Thm 3.3(c) for the normalized coefficient jet `I(p) = (p_0, …, p_N)` on polynomials
(e.g. the Taylor coefficients `Q^{(j)}(0)/j!`): no representability hypothesis is needed. -/
theorem no_free_export_finite_jet' (N : ℕ) (𝓒 : Set (ℝ → ℝ))
    (I : (ℝ → ℝ) → (Fin (N + 1) → ℝ))
    (hpoly : ∀ p : ℝ[X], (fun x => p.eval x) ∈ 𝓒)
    (hjet : ∀ p : ℝ[X], I (fun x => p.eval x) = fun j : Fin (N + 1) => p.coeff (j : ℕ))
    (lam : ℝ) (hlam : lam ≠ 0) (E : ExportRule (Fin (N + 1) → ℝ) ℝ)
    (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  refine no_free_export_finite_jet N 𝓒 I hpoly ?_ ?_ lam hlam E hE
  · intro p q h
    rw [hjet, hjet]
    funext j
    exact h j (Nat.lt_succ_iff.mp j.2)
  · intro Q _
    refine ⟨∑ j : Fin (N + 1), C (I Q j) * X ^ (j : ℕ), ?_⟩
    rw [hjet]
    funext j
    rw [finsetSum_coeff]
    simp only [coeff_C_mul, coeff_X_pow]
    rw [Finset.sum_eq_single j]
    · simp
    · intro b _ hb
      have : (j : ℕ) ≠ b := fun h => hb (Fin.ext h.symm)
      simp [this]
    · simp

end Samples

/-! ## Part 2b: minimax export = radius of information (Prop 3.4) -/

section Radius

variable {D α : Type*}

/-- The values `Q(λ*)` over the families with information `i`. -/
def fibreValues (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (lam : D) (i : α) : Set ℝ :=
  {v | ∃ Q ∈ 𝓒, I Q = i ∧ Q lam = v}

/-- The radius of information `r(i) = (sup - inf) / 2`. -/
noncomputable def infoRadius (V : Set ℝ) : ℝ := (sSup V - sInf V) / 2

/-- The midrange `(sup + inf) / 2`. -/
noncomputable def midrange (V : Set ℝ) : ℝ := (sSup V + sInf V) / 2

/-- An output `[q - ε, q + ε]` at information `i` is sound iff it contains the fibre values. -/
theorem output_sound_iff (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (lam : D) (i : α) (q ε : ℝ) :
    (∀ Q ∈ 𝓒, I Q = i → Q lam ∈ Set.Icc (q - ε) (q + ε)) ↔
      fibreValues 𝓒 I lam i ⊆ Set.Icc (q - ε) (q + ε) := by
  constructor
  · rintro h v ⟨Q, hQ, hi, rfl⟩; exact h Q hQ hi
  · intro h Q hQ hi; exact h ⟨Q, hQ, hi, rfl⟩

/-- **T3 Prop 3.4 (minimax export = radius of information).** For a nonempty bounded fibre,
a sound interval of radius `ε` exists iff `r(i) ≤ ε`; the midrange attains it. -/
theorem exists_interval_iff_radius_le {V : Set ℝ} (hne : V.Nonempty) (ha : BddAbove V)
    (hb : BddBelow V) (ε : ℝ) :
    (∃ q, V ⊆ Set.Icc (q - ε) (q + ε)) ↔ infoRadius V ≤ ε := by
  constructor
  · rintro ⟨q, hq⟩
    have h1 : sSup V ≤ q + ε := csSup_le hne (fun v hv => (hq hv).2)
    have h2 : q - ε ≤ sInf V := le_csInf hne (fun v hv => (hq hv).1)
    unfold infoRadius; linarith
  · intro h
    refine ⟨midrange V, fun v hv => ?_⟩
    have h1 := le_csSup ha hv
    have h2 := csInf_le hb hv
    unfold infoRadius at h; unfold midrange
    constructor <;> linarith

/-- The midrange interval of radius `r(i)` contains the fibre (Prop 3.4, optimal rule). -/
theorem midrange_sound {V : Set ℝ} (ha : BddAbove V) (hb : BddBelow V) :
    V ⊆ Set.Icc (midrange V - infoRadius V) (midrange V + infoRadius V) := by
  intro v hv
  have h1 := le_csSup ha hv
  have h2 := csInf_le hb hv
  unfold midrange infoRadius
  constructor <;> linarith

/-- Prop 3.4: an unbounded fibre admits no sound finite interval. -/
theorem no_interval_of_unbounded {V : Set ℝ} (h : ¬ BddAbove V ∨ ¬ BddBelow V) (q ε : ℝ) :
    ¬ V ⊆ Set.Icc (q - ε) (q + ε) := by
  intro hV
  rcases h with h | h
  · exact h ⟨q + ε, fun v hv => (hV hv).2⟩
  · exact h ⟨q - ε, fun v hv => (hV hv).1⟩

open Classical in
/-- The optimal rule: midrange and radius on bounded fibres, abstention otherwise. -/
noncomputable def optimalRule (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) : ExportRule α D :=
  fun i lam => if BddAbove (fibreValues 𝓒 I lam i) ∧ BddBelow (fibreValues 𝓒 I lam i) then
    some (midrange (fibreValues 𝓒 I lam i), infoRadius (fibreValues 𝓒 I lam i)) else none

/-- Prop 3.4: the midrange rule (abstaining on unbounded fibres) is sound. -/
theorem optimalRule_sound (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) :
    Sound 𝓒 I (optimalRule 𝓒 I) := by
  intro lam Q hQ q ε h
  unfold optimalRule at h
  split_ifs at h with hb
  · simp only [Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact midrange_sound hb.1 hb.2 ⟨Q, hQ, rfl, rfl⟩

/-- Any sound rule's tolerance at an attained information value is at least the radius. -/
theorem radius_le_of_sound {𝓒 : Set (D → ℝ)} {I : (D → ℝ) → α} {E : ExportRule α D} {lam : D}
    (hE : SoundAt 𝓒 I E lam) {Q₀ : D → ℝ} (hQ₀ : Q₀ ∈ 𝓒) {q ε : ℝ}
    (h : E (I Q₀) lam = some (q, ε)) :
    BddAbove (fibreValues 𝓒 I lam (I Q₀)) ∧ BddBelow (fibreValues 𝓒 I lam (I Q₀)) ∧
      infoRadius (fibreValues 𝓒 I lam (I Q₀)) ≤ ε := by
  have hV : fibreValues 𝓒 I lam (I Q₀) ⊆ Set.Icc (q - ε) (q + ε) := by
    rintro v ⟨Q, hQ, hi, rfl⟩
    exact hE Q hQ q ε (by rw [hi]; exact h)
  have ha : BddAbove (fibreValues 𝓒 I lam (I Q₀)) := ⟨q + ε, fun v hv => (hV hv).2⟩
  have hb : BddBelow (fibreValues 𝓒 I lam (I Q₀)) := ⟨q - ε, fun v hv => (hV hv).1⟩
  have hne : (fibreValues 𝓒 I lam (I Q₀)).Nonempty := ⟨Q₀ lam, Q₀, hQ₀, rfl, rfl⟩
  exact ⟨ha, hb, (exists_interval_iff_radius_le hne ha hb ε).mp ⟨q, hV⟩⟩

end Radius

/-- A point outside a finite set has positive distance from it. -/
theorem exists_pos_le_dist {D : Type*} [MetricSpace D] (Qs : Finset D) (π : D) (hπ : π ∉ Qs) :
    ∃ r > 0, ∀ x ∈ Qs, r ≤ dist x π := by
  classical
  induction Qs using Finset.induction_on with
  | empty => exact ⟨1, one_pos, by simp⟩
  | insert a T ha ih =>
    have hπT : π ∉ T := fun h => hπ (Finset.mem_insert_of_mem h)
    have haπ : a ≠ π := fun h => hπ (h ▸ Finset.mem_insert_self a T)
    obtain ⟨r, hr, hT⟩ := ih hπT
    refine ⟨min r (dist a π), lt_min hr (dist_pos.mpr haπ), ?_⟩
    intro x hx
    rcases Finset.mem_insert.mp hx with rfl | hx
    · exact min_le_right _ _
    · exact (min_le_left _ _).trans (hT x hx)

/-! ## Part 3: tents, Lipschitz functions, and Thm 3.3(b) with tents -/

section Tents

variable {D α : Type*}

/-- The tent of height `r` and slope 1 centred at `c`. -/
def tent [PseudoMetricSpace D] (c : D) (r : ℝ) (x : D) : ℝ := max 0 (r - dist x c)

/-- `e` is `L`-Lipschitz. -/
def IsLip [PseudoMetricSpace D] (L : ℝ) (e : D → ℝ) : Prop :=
  ∀ x y, |e x - e y| ≤ L * dist x y

variable [PseudoMetricSpace D]

/-- `IsLip` agrees with Mathlib's `LipschitzWith` for nonnegative constants. -/
theorem isLip_iff_lipschitzWith (K : NNReal) (e : D → ℝ) :
    IsLip (K : ℝ) e ↔ LipschitzWith K e := by
  rw [lipschitzWith_iff_dist_le_mul]
  simp [IsLip, Real.dist_eq]

theorem tent_nonneg (c : D) (r : ℝ) (x : D) : 0 ≤ tent c r x := le_max_left _ _

theorem tent_self (c : D) {r : ℝ} (hr : 0 ≤ r) : tent c r c = r := by
  simp [tent, hr]

theorem tent_eq_zero {c x : D} {r : ℝ} (h : r ≤ dist x c) : tent c r x = 0 := by
  simp [tent]; linarith

/-- Tents are continuous bumps. -/
theorem continuous_tent (c : D) (r : ℝ) : Continuous (tent c r) :=
  continuous_const.max (continuous_const.sub (continuous_id.dist continuous_const))

/-- Tents are 1-Lipschitz. -/
theorem isLip_tent (c : D) (r : ℝ) : IsLip 1 (tent c r) := by
  intro x y
  have h1 := abs_max_sub_max_le_abs (r - dist x c) (r - dist y c) 0
  have h2 := abs_dist_sub_le x y c
  have h3 : |(r - dist x c) - (r - dist y c)| = |dist x c - dist y c| := by
    rw [← abs_neg]; congr 1; ring
  simp only [tent, max_comm (0 : ℝ)] at *
  rw [one_mul]
  linarith

theorem isLip_const_add_smul_tent {L : ℝ} (hL : 0 ≤ L) (b : ℝ) (c : D) (r : ℝ) :
    IsLip L (fun x => b + L * tent c r x) := by
  intro x y
  have h := isLip_tent c r x y
  have : b + L * tent c r x - (b + L * tent c r y) = L * (tent c r x - tent c r y) := by ring
  rw [this, abs_mul, abs_of_nonneg hL]
  rw [one_mul] at h
  exact mul_le_mul_of_nonneg_left h hL

/-- Thm 3.3(b) with tents: information read off a set whose closure omits `lam`. -/
theorem no_free_export_away (U : Set D) (lam : D) (hlam : lam ∉ closure U)
    (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α) (hI : SampleInfo U I)
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ (c : D) (r A : ℝ), (fun x => Q x + A * tent c r x) ∈ 𝓒)
    (E : ExportRule α D) (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  obtain ⟨r, hr, hball⟩ : ∃ r > 0, ∀ u ∈ U, r ≤ dist u lam := by
    rw [Metric.mem_closure_iff] at hlam
    push Not at hlam
    obtain ⟨r, hr, h⟩ := hlam
    exact ⟨r, hr, fun u hu => by rw [dist_comm]; exact h u hu⟩
  refine invisible_perturbation 𝓒 I E lam (tent lam r) (by rw [tent_self lam hr.le]; exact hr.ne')
    (fun Q hQ A => h𝓒 Q hQ lam r A) ?_ hE
  intro Q _ A
  apply hI
  intro u hu
  simp [tent_eq_zero (hball u hu)]

/-- Thm 3.3(b) with tents, germ form: information that depends only on the germ at `x₀`. -/
theorem no_free_export_germ (x₀ lam : D) (hlam : 0 < dist lam x₀)
    (𝓒 : Set (D → ℝ)) (I : (D → ℝ) → α)
    (hI : ∀ Q Q' : D → ℝ, Q =ᶠ[nhds x₀] Q' → I Q = I Q')
    (h𝓒 : ∀ Q ∈ 𝓒, ∀ (c : D) (r A : ℝ), (fun x => Q x + A * tent c r x) ∈ 𝓒)
    (E : ExportRule α D) (hE : SoundAt 𝓒 I E lam) : ∀ Q ∈ 𝓒, E (I Q) lam = none := by
  set r := dist lam x₀ / 2 with hr_def
  have hr : 0 < r := by positivity
  refine invisible_perturbation 𝓒 I E lam (tent lam r) (by rw [tent_self lam hr.le]; exact hr.ne')
    (fun Q hQ A => h𝓒 Q hQ lam r A) ?_ hE
  intro Q _ A
  apply hI
  have hball : Metric.ball x₀ r ∈ nhds x₀ := Metric.ball_mem_nhds x₀ hr
  filter_upwards [hball] with x hx
  rw [Metric.mem_ball] at hx
  have : r ≤ dist x lam := by
    have := dist_triangle lam x x₀
    rw [dist_comm lam x] at this
    linarith
  simp [tent_eq_zero this]

end Tents

/-! ## Part 4: the conservative Lipschitz certifier (Thm 4.5(a),(b)) -/

section LipCert

variable {D : Type*} [PseudoMetricSpace D]

/-- **T3 Thm 4.5(a), pointwise form (the task's statement).** If `e` is `L`-Lipschitz,
`|e(xᵢ) - êᵢ| ≤ η` and `êᵢ + η + L·dist(x, xᵢ) ≤ τ`, then `e(x) ≤ τ`.  Any (pseudo)metric:
`|·|` on `ℝ`, the sup metric on `Fin d → ℝ`, …. -/
theorem lip_cert_sound_point {L η τ ehat : ℝ} {e : D → ℝ} (he : IsLip L e) {xi x : D}
    (hq : |e xi - ehat| ≤ η) (hx : ehat + η + L * dist x xi ≤ τ) : e x ≤ τ := by
  have h1 := (abs_le.mp (he x xi)).2
  have h2 := (abs_le.mp hq).2
  linarith

/-- **T3 Thm 4.5(a), indexed form.** Queries `x i` with answers `ê i`, `|e(x i) - ê i| ≤ η`;
any `y` with `ê i + η + L·dist(y, x i) ≤ τ` for some `i` has `e(y) ≤ τ`. -/
theorem lip_cert_sound_indexed {n : ℕ} {L η τ : ℝ} {e : D → ℝ} (he : IsLip L e)
    (x : Fin n → D) (ehat : Fin n → ℝ) (hq : ∀ i, |e (x i) - ehat i| ≤ η) {y : D}
    (hy : ∃ i, ehat i + η + L * dist y (x i) ≤ τ) : e y ≤ τ := by
  obtain ⟨i, hi⟩ := hy
  exact lip_cert_sound_point he (hq i) hi

/-- The metric on `Fin d → ℝ` is the sup metric. -/
theorem dist_le_iff_sup {d : ℕ} (x y : Fin d → ℝ) {r : ℝ} (hr : 0 ≤ r) :
    dist x y ≤ r ↔ ∀ i, |x i - y i| ≤ r := by
  rw [dist_pi_le_iff hr]
  simp [Real.dist_eq]

/-- The output region of the conservative certifier. -/
def lipRegion (P : Set D) (L τ : ℝ) (Qs : Finset D) (u : D → ℝ) : Set D :=
  {π | π ∈ P ∧ ∃ x ∈ Qs, dist π x ≤ (τ - u x) / L}

/-- Membership in the certified region, in multiplicative form. -/
theorem mem_lipRegion_iff {P : Set D} {L τ : ℝ} (hL : 0 < L) {Qs : Finset D} {u : D → ℝ}
    {π : D} : π ∈ lipRegion P L τ Qs u ↔ π ∈ P ∧ ∃ x ∈ Qs, u x + L * dist π x ≤ τ := by
  unfold lipRegion
  simp only [Set.mem_setOf_eq]
  refine and_congr Iff.rfl (exists_congr fun x => and_congr Iff.rfl ?_)
  rw [le_div_iff₀ hL]
  constructor <;> intro h <;> linarith [mul_comm L (dist π x)]

/-- **T3 Thm 4.5(a) (soundness).** With a validated upper oracle (`e ≤ u` at the queried
points), the conservative region `V` satisfies `e ≤ τ` on `V`, for every `L`-Lipschitz `e`. -/
theorem lip_cert_sound {P : Set D} {L τ : ℝ} (hL : 0 < L) {Qs : Finset D} {u e : D → ℝ}
    (he : IsLip L e) (hu : ∀ x ∈ Qs, e x ≤ u x) : ∀ π ∈ lipRegion P L τ Qs u, e π ≤ τ := by
  intro π hπ
  obtain ⟨-, x, hx, hd⟩ := (mem_lipRegion_iff hL).mp hπ
  have h1 := (abs_le.mp (he π x)).2
  have h2 := hu x hx
  linarith

/-- Thm 4.5(a) with a two-sided oracle `|e(x) - ê(x)| ≤ η`, using `u = ê + η`. -/
theorem lip_cert_sound_noisy {P : Set D} {L τ η : ℝ} (hL : 0 < L) {Qs : Finset D}
    {ehat e : D → ℝ} (he : IsLip L e) (hq : ∀ x ∈ Qs, |e x - ehat x| ≤ η) :
    ∀ π ∈ lipRegion P L τ Qs (fun x => ehat x + η), e π ≤ τ :=
  lip_cert_sound hL he (fun x hx => by have := (abs_le.mp (hq x hx)).2; linarith)

/-- **T3 Thm 4.5(b) (completeness), net form.** If the queries form an `h/2`-net of `P`, the
oracle satisfies `e ≤ u ≤ e + η` and `L h ≤ γ - η`, then `V ⊇ {π ∈ P : e(π) ≤ τ - γ}`. -/
theorem lip_cert_complete_of_net {P : Set D} {L τ η γ h : ℝ} (hL : 0 < L) {Qs : Finset D}
    {u e : D → ℝ} (he : IsLip L e) (hu : ∀ x ∈ Qs, e x ≤ u x ∧ u x ≤ e x + η)
    (hnet : ∀ π ∈ P, ∃ x ∈ Qs, dist π x ≤ h / 2) (hh : L * h ≤ γ - η) :
    {π | π ∈ P ∧ e π ≤ τ - γ} ⊆ lipRegion P L τ Qs u := by
  rintro π ⟨hπP, hπ⟩
  obtain ⟨x, hx, hd⟩ := hnet π hπP
  rw [mem_lipRegion_iff hL]
  refine ⟨hπP, x, hx, ?_⟩
  have h1 := (abs_le.mp (he x π)).2
  rw [dist_comm] at h1
  have h2 := (hu x hx).2
  have h3 : L * dist π x ≤ L * (h / 2) := mul_le_mul_of_nonneg_left hd hL.le
  nlinarith

/-- The unit cube `[0,1]^d` with the sup metric. -/
def unitCube (d : ℕ) : Set (Fin d → ℝ) := {π | ∀ i, π i ∈ Set.Icc (0 : ℝ) 1}

/-- Centre of the grid cell `k`. -/
noncomputable def gridCenter {d : ℕ} (n : ℕ) (k : Fin d → Fin n) : Fin d → ℝ :=
  fun i => ((k i : ℝ) + 1 / 2) / n

/-- The grid `G` of the `n^d` cell centres. -/
noncomputable def grid (d n : ℕ) : Finset (Fin d → ℝ) :=
  Finset.univ.image (gridCenter n)

theorem gridCenter_injective {d n : ℕ} (hn : 0 < n) :
    Function.Injective (gridCenter (d := d) n) := by
  intro k k' h
  funext i
  have := congrFun h i
  simp only [gridCenter] at this
  have hn' : (n : ℝ) ≠ 0 := by positivity
  rw [div_left_inj' hn'] at this
  exact Fin.ext (by exact_mod_cast (add_right_cancel this))

/-- The grid has exactly `n^d` points. -/
theorem card_grid (d : ℕ) {n : ℕ} (hn : 0 < n) : (grid d n).card = n ^ d := by
  rw [grid, Finset.card_image_of_injective _ (gridCenter_injective hn)]
  simp

theorem coord_net {n : ℕ} (hn : 0 < n) {t : ℝ} (ht : t ∈ Set.Icc (0 : ℝ) 1) :
    ∃ k : Fin n, |t - ((k : ℝ) + 1 / 2) / n| ≤ 1 / (2 * n) := by
  have hnr : (0 : ℝ) < n := by exact_mod_cast hn
  obtain ⟨k, hk1, hk2⟩ : ∃ k : Fin n, (k : ℝ) ≤ t * n ∧ t * n ≤ k + 1 := by
    by_cases hlt : ⌊t * n⌋₊ < n
    · refine ⟨⟨_, hlt⟩, Nat.floor_le (by nlinarith [ht.1]), (Nat.lt_floor_add_one _).le⟩
    · refine ⟨⟨n - 1, by omega⟩, ?_, ?_⟩
      · simp only
        rw [Nat.cast_sub (by omega)]
        have : (n : ℝ) ≤ t * n := by
          push Not at hlt
          have := Nat.floor_le (a := t * n) (by nlinarith [ht.1])
          exact le_trans (by exact_mod_cast hlt) this
        push_cast; linarith
      · simp only
        rw [Nat.cast_sub (by omega)]
        push_cast; nlinarith [ht.2]
  refine ⟨k, ?_⟩
  have e1 : t - ((k : ℝ) + 1 / 2) / n = (t * n - k - 1 / 2) / n := by field_simp; ring
  rw [e1, abs_div, abs_of_pos hnr, div_le_div_iff₀ hnr (by positivity)]
  have : |t * n - k - 1 / 2| ≤ 1 / 2 := abs_le.mpr ⟨by linarith, by linarith⟩
  nlinarith

/-- Every point of `[0,1]^d` is within sup-distance `1/(2n)` of a grid centre. -/
theorem grid_net {d n : ℕ} (hn : 0 < n) :
    ∀ π ∈ unitCube d, ∃ x ∈ grid d n, dist π x ≤ 1 / (2 * n) := by
  intro π hπ
  choose k hk using fun i => coord_net hn (hπ i)
  refine ⟨gridCenter n k, Finset.mem_image_of_mem _ (Finset.mem_univ _), ?_⟩
  rw [dist_pi_le_iff (by positivity)]
  intro i
  rw [Real.dist_eq]
  exact hk i

/-- **T3 Thm 4.5(b) (completeness) on `[0,1]^d`.** With the grid `G_h` of `⌈1/h⌉^d` cell
centres and `h ≤ (γ - η)/L`, the certified region contains `{π : e(π) ≤ τ - γ}`. -/
theorem lip_cert_complete {d : ℕ} {L τ η γ h : ℝ} (hL : 0 < L) (hh : 0 < h)
    (hhγ : h ≤ (γ - η) / L) {u e : (Fin d → ℝ) → ℝ} (he : IsLip L e)
    (hu : ∀ x ∈ grid d ⌈1 / h⌉₊, e x ≤ u x ∧ u x ≤ e x + η) :
    {π | π ∈ unitCube d ∧ e π ≤ τ - γ} ⊆ lipRegion (unitCube d) L τ (grid d ⌈1 / h⌉₊) u ∧
      (grid d ⌈1 / h⌉₊).card = ⌈1 / h⌉₊ ^ d := by
  have hn : 0 < ⌈1 / h⌉₊ := Nat.ceil_pos.mpr (by positivity)
  refine ⟨lip_cert_complete_of_net hL he hu (h := h) ?_ ?_, card_grid d hn⟩
  · intro π hπ
    obtain ⟨x, hx, hd⟩ := grid_net hn π hπ
    refine ⟨x, hx, hd.trans ?_⟩
    have h1 : 1 / h ≤ (⌈1 / h⌉₊ : ℝ) := Nat.le_ceil _
    have h2 : (0 : ℝ) < ⌈1 / h⌉₊ := by exact_mod_cast hn
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    rw [div_le_iff₀ hh] at h1
    nlinarith
  · rw [le_div_iff₀ hL] at hhγ; linarith

/-- Thm 4.5(b) with `h = (γ - η)/L`: `N = ⌈L/(γ - η)⌉^d` oracle calls suffice. -/
theorem lip_cert_complete' {d : ℕ} {L τ η γ : ℝ} (hL : 0 < L) (hγη : η < γ)
    {u e : (Fin d → ℝ) → ℝ} (he : IsLip L e)
    (hu : ∀ x ∈ grid d ⌈L / (γ - η)⌉₊, e x ≤ u x ∧ u x ≤ e x + η) :
    {π | π ∈ unitCube d ∧ e π ≤ τ - γ} ⊆
        lipRegion (unitCube d) L τ (grid d ⌈L / (γ - η)⌉₊) u ∧
      (grid d ⌈L / (γ - η)⌉₊).card = ⌈L / (γ - η)⌉₊ ^ d := by
  have hh : 0 < (γ - η) / L := div_pos (by linarith) hL
  have h1 : ⌈1 / ((γ - η) / L)⌉₊ = ⌈L / (γ - η)⌉₊ := by rw [one_div_div]
  have := lip_cert_complete (τ := τ) (u := u) hL hh le_rfl he
  rw [h1] at this
  exact this hu

end LipCert

/-! ## Part 5: deterministic certifiers; Thm 4.4 and Thm 4.5(c) -/

section Certifiers

/-- A deterministic certifier with an exact oracle, described by what it outputs and what it
queries.  The output depends on `e` only through the values at the queried points. -/
structure LocalCertifier (D : Type*) where
  region : (D → ℝ) → Set D
  queries : (D → ℝ) → Finset D
  region_eq : ∀ e e' : D → ℝ, (∀ x ∈ queries e, e' x = e x) → region e' = region e

variable {D : Type*}

/-- Soundness on the class `𝓒` and the domain `P`. -/
def CertSound (𝓒 : Set (D → ℝ)) (P : Set D) (τ : ℝ) (A : LocalCertifier D) : Prop :=
  ∀ e ∈ 𝓒, ∀ π ∈ P, π ∈ A.region e → e π ≤ τ

/-- Completeness at margin `γ` on the class `𝓒` and the domain `P`. -/
def CertComplete (𝓒 : Set (D → ℝ)) (P : Set D) (τ γ : ℝ) (A : LocalCertifier D) : Prop :=
  ∀ e ∈ 𝓒, ∀ π ∈ P, e π ≤ τ - γ → π ∈ A.region e

/-- An adaptive deterministic certifier with a query budget.  `next` picks the next query point
from the answers so far, and `out` picks the output region from all answers. -/
structure AdaptiveCertifier (D : Type*) where
  budget : ℕ
  next : List ℝ → D
  out : List ℝ → Set D

/-- The answers after `k` queries on `e`. -/
def AdaptiveCertifier.answers (A : AdaptiveCertifier D) (e : D → ℝ) : ℕ → List ℝ
  | 0 => []
  | k + 1 => A.answers e k ++ [e (A.next (A.answers e k))]

theorem AdaptiveCertifier.answers_eq (A : AdaptiveCertifier D) (e e' : D → ℝ)
    (h : ∀ k < A.budget, e' (A.next (A.answers e k)) = e (A.next (A.answers e k))) :
    ∀ k ≤ A.budget, A.answers e' k = A.answers e k := by
  intro k
  induction k with
  | zero => intro _; rfl
  | succ k ih =>
    intro hk
    have ih' := ih (by omega)
    simp only [AdaptiveCertifier.answers, ih', h k (by omega)]

open Classical in
/-- An adaptive certifier is a local certifier. -/
noncomputable def AdaptiveCertifier.toLocal (A : AdaptiveCertifier D) : LocalCertifier D where
  region e := A.out (A.answers e A.budget)
  queries e := (Finset.range A.budget).image (fun k => A.next (A.answers e k))
  region_eq e e' h := by
    rw [A.answers_eq e e' (fun k hk => h _ (Finset.mem_image_of_mem _ (Finset.mem_range.mpr hk)))
      A.budget le_rfl]

/-- An adaptive certifier queries at most `budget` points. -/
theorem AdaptiveCertifier.card_queries_le (A : AdaptiveCertifier D) (e : D → ℝ) :
    (A.toLocal.queries e).card ≤ A.budget := by
  classical
  unfold AdaptiveCertifier.toLocal
  exact Finset.card_image_le.trans (by simp)

/-- **Thm 4.4** (no certification without regularity), deterministic part. -/
theorem no_certification_without_regularity [MetricSpace D] (𝓒 : Set (D → ℝ))
    (h𝓒 : ∀ e ∈ 𝓒, ∀ (c : D) (r A : ℝ), 0 < r → 0 < A → (fun x => e x + A * tent c r x) ∈ 𝓒)
    (P : Set D) (τ : ℝ) (A : LocalCertifier D) (hs : CertSound 𝓒 P τ A) :
    ∀ e ∈ 𝓒, P ∩ A.region e ⊆ ↑(A.queries e) := by
  rintro e he π ⟨hπP, hπV⟩
  by_contra hq
  obtain ⟨r, hr, hfar⟩ := exists_pos_le_dist (A.queries e) π hq
  have hτ := hs e he π hπP hπV
  set a := (τ - e π + 1) / r with ha
  have hapos : 0 < a := div_pos (by linarith) hr
  have hmem := h𝓒 e he π r a hr hapos
  have hreg : A.region (fun x => e x + a * tent π r x) = A.region e :=
    A.region_eq e _ (fun x hx => by simp [tent_eq_zero (hfar x hx)])
  have := hs _ hmem π hπP (by rw [hreg]; exact hπV)
  simp only [tent_self π hr.le] at this
  rw [ha, div_mul_cancel₀ _ hr.ne'] at this
  linarith

/-- **Thm 4.5(c)**, general form: a packing of `M` points of `P` at mutual distance
`≥ 2γ'/L` forces at least `M` queries on the constant function `τ - γ`. -/
theorem lip_lower_bound_of_packing [PseudoMetricSpace D] {L τ γ γ' : ℝ} (hL : 0 < L)
    (hγ' : 0 < γ') (hγγ' : γ < γ') (P : Set D) {ι : Type*} [Fintype ι] (c : ι → D)
    (hc : ∀ k, c k ∈ P) (hsep : ∀ k k', k ≠ k' → 2 * (γ' / L) ≤ dist (c k) (c k'))
    (A : LocalCertifier D) (hs : CertSound {e | IsLip L e} P τ A)
    (hcomp : CertComplete {e | IsLip L e} P τ γ A) :
    Fintype.card ι ≤ (A.queries (fun _ => τ - γ)).card := by
  classical
  set e₀ : D → ℝ := fun _ => τ - γ with he₀
  set ρ := γ' / L with hρ
  have hρpos : 0 < ρ := div_pos hγ' hL
  have he₀lip : IsLip L e₀ := fun x y => by simp [he₀]; positivity
  by_contra hlt
  push Not at hlt
  -- some packing ball contains no query
  obtain ⟨k, hk⟩ : ∃ k, ∀ x ∈ A.queries e₀, ρ ≤ dist x (c k) := by
    by_contra hall
    push Not at hall
    choose g hgQ hgd using hall
    have hinj : Set.InjOn g (Finset.univ : Finset ι) := by
      intro k _ k' _ hkk'
      by_contra hne
      have h1 := hsep k k' hne
      have h2 := dist_triangle (c k) (g k') (c k')
      rw [dist_comm (c k) (g k')] at h2
      have h3 := hgd k
      rw [hkk'] at h3
      have h4 := hgd k'
      linarith
    have := Finset.card_le_card_of_injOn g (fun k _ => hgQ k) hinj
    simp only [Finset.card_univ] at this
    omega
  set e₁ : D → ℝ := fun x => (τ - γ) + L * tent (c k) ρ x with he₁
  have he₁lip : IsLip L e₁ := isLip_const_add_smul_tent hL.le _ _ _
  have hreg : A.region e₁ = A.region e₀ :=
    A.region_eq e₀ e₁ (fun x hx => by simp [he₁, he₀, tent_eq_zero (hk x hx)])
  have hin : c k ∈ A.region e₀ := hcomp e₀ he₀lip (c k) (hc k) (by simp [he₀])
  have h5 := hs e₁ he₁lip (c k) (hc k) (by rw [hreg]; exact hin)
  have h6 : e₁ (c k) = τ - γ + γ' := by
    simp only [he₁]
    rw [tent_self (c k) hρpos.le, hρ, mul_div_cancel₀ _ hL.ne']
  linarith

/-- Packing centres `((2kᵢ + 1)ρ)ᵢ` in the cube. -/
noncomputable def packCenter {d m : ℕ} (ρ : ℝ) (k : Fin d → Fin m) : Fin d → ℝ :=
  fun i => (2 * (k i : ℝ) + 1) * ρ

theorem packCenter_mem {d m : ℕ} {ρ : ℝ} (hρ : 0 < ρ) (hm : 2 * (m : ℝ) * ρ ≤ 1)
    (k : Fin d → Fin m) : packCenter ρ k ∈ unitCube d := by
  intro i
  have hk : ((k i : ℕ) : ℝ) + 1 ≤ m := by exact_mod_cast (k i).2
  have hk0 : (0 : ℝ) ≤ (k i : ℕ) := by positivity
  constructor
  · unfold packCenter; positivity
  · unfold packCenter; nlinarith

theorem packCenter_sep {d m : ℕ} {ρ : ℝ} (hρ : 0 < ρ) (k k' : Fin d → Fin m) (hne : k ≠ k') :
    2 * ρ ≤ dist (packCenter ρ k) (packCenter ρ k') := by
  obtain ⟨i, hi⟩ : ∃ i, k i ≠ k' i := by
    by_contra h; push Not at h; exact hne (funext h)
  refine le_trans ?_ (dist_le_pi_dist _ _ i)
  rw [Real.dist_eq]
  unfold packCenter
  have hi' : (k i : ℕ) ≠ (k' i : ℕ) := fun h => hi (Fin.ext h)
  have : (1 : ℝ) ≤ |((k i : ℕ) : ℝ) - (k' i : ℕ)| := by
    rcases Nat.lt_or_gt_of_ne hi' with h | h
    · have : ((k i : ℕ) : ℝ) + 1 ≤ (k' i : ℕ) := by exact_mod_cast h
      rw [abs_sub_comm, abs_of_nonneg (by linarith)]
      linarith
    · have : ((k' i : ℕ) : ℝ) + 1 ≤ (k i : ℕ) := by exact_mod_cast h
      rw [abs_of_nonneg (by linarith)]
      linarith
  have e1 : (2 * ((k i : ℕ) : ℝ) + 1) * ρ - (2 * ((k' i : ℕ) : ℝ) + 1) * ρ =
      2 * ρ * (((k i : ℕ) : ℝ) - (k' i : ℕ)) := by ring
  rw [e1, abs_mul, abs_of_pos (by positivity)]
  nlinarith

/-- **Thm 4.5(c)** on `[0,1]^d` with the sup metric. -/
theorem lip_lower_bound_cube {d : ℕ} {L τ γ γ' : ℝ} (hL : 0 < L) (hγ' : 0 < γ') (hγγ' : γ < γ')
    (A : LocalCertifier (Fin d → ℝ)) (hs : CertSound {e | IsLip L e} (unitCube d) τ A)
    (hcomp : CertComplete {e | IsLip L e} (unitCube d) τ γ A) :
    ⌊L / (2 * γ')⌋₊ ^ d ≤ (A.queries (fun _ => τ - γ)).card := by
  set m := ⌊L / (2 * γ')⌋₊
  have hρ : 0 < γ' / L := div_pos hγ' hL
  have hm : 2 * (m : ℝ) * (γ' / L) ≤ 1 := by
    have h1 : (m : ℝ) ≤ L / (2 * γ') := Nat.floor_le (by positivity)
    rw [le_div_iff₀ (by positivity)] at h1
    rw [mul_div_assoc', div_le_one hL]
    linarith
  have := lip_lower_bound_of_packing hL hγ' hγγ' (unitCube d) (packCenter (γ' / L))
    (packCenter_mem hρ hm) (fun k k' hne => packCenter_sep hρ k k' hne) A hs hcomp
  simpa using this

/-- **Thm 4.5(c)** for adaptive certifiers with a query budget. -/
theorem lip_lower_bound_cube_adaptive {d : ℕ} {L τ γ γ' : ℝ} (hL : 0 < L) (hγ' : 0 < γ')
    (hγγ' : γ < γ') (A : AdaptiveCertifier (Fin d → ℝ))
    (hs : CertSound {e | IsLip L e} (unitCube d) τ A.toLocal)
    (hcomp : CertComplete {e | IsLip L e} (unitCube d) τ γ A.toLocal) :
    ⌊L / (2 * γ')⌋₊ ^ d ≤ A.budget :=
  (lip_lower_bound_cube hL hγ' hγγ' A.toLocal hs hcomp).trans (A.card_queries_le _)

/-- **Thm 4.5(c)** in one dimension, on `[0,1]` with `|·|`. -/
theorem lip_lower_bound_interval {L τ γ γ' : ℝ} (hL : 0 < L) (hγ' : 0 < γ') (hγγ' : γ < γ')
    (A : LocalCertifier ℝ) (hs : CertSound {e | IsLip L e} (Set.Icc 0 1) τ A)
    (hcomp : CertComplete {e | IsLip L e} (Set.Icc 0 1) τ γ A) :
    ⌊L / (2 * γ')⌋₊ ≤ (A.queries (fun _ => τ - γ)).card := by
  set m := ⌊L / (2 * γ')⌋₊
  set ρ := γ' / L
  have hρ : 0 < ρ := div_pos hγ' hL
  have hm : 2 * (m : ℝ) * ρ ≤ 1 := by
    have h1 : (m : ℝ) ≤ L / (2 * γ') := Nat.floor_le (by positivity)
    rw [le_div_iff₀ (by positivity)] at h1
    simp only [ρ]
    rw [mul_div_assoc', div_le_one hL]
    linarith
  have := lip_lower_bound_of_packing hL hγ' hγγ' (Set.Icc 0 1)
    (fun k : Fin m => packCenter ρ (fun _ : Fin 1 => k) 0)
    (fun k => packCenter_mem hρ hm _ 0)
    (fun k k' hne => by
      have h := packCenter_sep hρ (fun _ : Fin 1 => k) (fun _ : Fin 1 => k')
        (fun h => hne (congrFun h 0))
      refine le_trans h ?_
      rw [dist_pi_le_iff dist_nonneg]
      intro i
      fin_cases i
      exact le_rfl) A hs hcomp
  simpa using this

end Certifiers

/-! ## Part 6: coherence cannot calibrate tolerances (Thm 4.1) -/

section Coherence

variable {σ ι : Type*}

/-- The discrepancy data `(q_{s,i} - q_{s',i})`. -/
def discrepancies (q : σ → ι → ℝ) : σ → σ → ι → ℝ := fun s s' i => q s i - q s' i

/-- A coherence-only calibrator `ε̂ = cal (discrepancies q)` is sound on the environment class
`𝓔` of pairs `(q, V)`. -/
def CalSound (𝓔 : Set ((σ → ι → ℝ) × (ι → ℝ))) (cal : (σ → σ → ι → ℝ) → σ → ℝ) : Prop :=
  ∀ qV ∈ 𝓔, ∀ s i, |qV.2 i - qV.1 s i| ≤ cal (discrepancies qV.1) s

/-- **Thm 4.1.** Under closure under common shifts of size `≤ β`, every sound coherence-only
calibrator has `ε̂_s ≥ β` on the data of every environment (with at least one instance). -/
theorem coherence_cannot_calibrate (𝓔 : Set ((σ → ι → ℝ) × (ι → ℝ))) (β : ℝ)
    (hshift : ∀ q V, (q, V) ∈ 𝓔 → ∀ b : ℝ, |b| ≤ β → (q, fun i => V i + b) ∈ 𝓔)
    (cal : (σ → σ → ι → ℝ) → σ → ℝ) (hcal : CalSound 𝓔 cal)
    (q : σ → ι → ℝ) (V : ι → ℝ) (hqV : (q, V) ∈ 𝓔) (i : ι) (hβ : 0 ≤ β) :
    ∀ s, β ≤ cal (discrepancies q) s := by
  intro s
  have h1 := hcal _ (hshift q V hqV β (by rw [abs_of_nonneg hβ])) s i
  have h2 := hcal _ (hshift q V hqV (-β) (by rw [abs_neg, abs_of_nonneg hβ])) s i
  simp only at h1 h2
  have h3 := (abs_le.mp h1).2
  have h4 := (abs_le.mp h2).1
  linarith

/-- **Thm 4.1**, unbounded shifts: no sound coherence-only calibrator exists. -/
theorem coherence_cannot_calibrate_unbounded (𝓔 : Set ((σ → ι → ℝ) × (ι → ℝ)))
    (hshift : ∀ q V, (q, V) ∈ 𝓔 → ∀ b : ℝ, (q, fun i => V i + b) ∈ 𝓔)
    (q : σ → ι → ℝ) (V : ι → ℝ) (hqV : (q, V) ∈ 𝓔) (i : ι) (s : σ)
    (cal : (σ → σ → ι → ℝ) → σ → ℝ) : ¬ CalSound 𝓔 cal := by
  intro hcal
  set β := |cal (discrepancies q) s| + 1
  have := coherence_cannot_calibrate 𝓔 β (fun q V h b _ => hshift q V h b) cal hcal q V hqV i
    (by positivity) s
  have := le_abs_self (cal (discrepancies q) s)
  linarith

end Coherence

/-! ## Part 7: the monotone certifier (Thm 4.6, one dimension) -/

section Monotone

/-- State of lazy bisection: `lo`, `hi`, whether some query was accepted, whether some query
was rejected. -/
structure Bis where
  lo : ℝ
  hi : ℝ
  acc : Bool
  rej : Bool

/-- One lazy-bisection step with oracle `u`: query the midpoint. -/
noncomputable def bisStep (u : ℝ → ℝ) (τ : ℝ) (s : Bis) : Bis :=
  if u ((s.lo + s.hi) / 2) ≤ τ then ⟨(s.lo + s.hi) / 2, s.hi, true, s.rej⟩
  else ⟨s.lo, (s.lo + s.hi) / 2, s.acc, true⟩

/-- The state after `k` queries. -/
noncomputable def bisRun (u : ℝ → ℝ) (τ : ℝ) : ℕ → Bis
  | 0 => ⟨0, 1, false, false⟩
  | k + 1 => bisStep u τ (bisRun u τ k)

open Classical in
/-- The output region `[0, lo]` if some query was accepted, `∅` otherwise. -/
noncomputable def bisRegion (u : ℝ → ℝ) (τ : ℝ) (k : ℕ) : Set ℝ :=
  if (bisRun u τ k).acc = true then Set.Icc 0 (bisRun u τ k).lo else ∅

/-- Invariants of lazy bisection. -/
theorem bis_inv (u : ℝ → ℝ) (τ : ℝ) (k : ℕ) :
    (bisRun u τ k).hi - (bisRun u τ k).lo = (1 / 2) ^ k ∧ 0 ≤ (bisRun u τ k).lo ∧
      (bisRun u τ k).hi ≤ 1 ∧
      ((bisRun u τ k).acc = true → u (bisRun u τ k).lo ≤ τ) ∧
      ((bisRun u τ k).acc = false → (bisRun u τ k).lo = 0) ∧
      ((bisRun u τ k).rej = true → τ < u (bisRun u τ k).hi) ∧
      ((bisRun u τ k).rej = false → (bisRun u τ k).hi = 1) := by
  induction k with
  | zero => simp [bisRun]
  | succ k ih =>
    obtain ⟨h1, h2, h3, h4, h5, h6, h7⟩ := ih
    have hpos : (0 : ℝ) < (1 / 2) ^ k := by positivity
    simp only [bisRun, bisStep]
    split_ifs with hm
    · refine ⟨?_, ?_, h3, fun _ => hm, fun h => by simp at h, h6, h7⟩
      · rw [pow_succ]; linarith
      · linarith
    · refine ⟨?_, h2, ?_, h4, h5, fun _ => lt_of_not_ge hm, fun h => by simp at h⟩
      · rw [pow_succ]; linarith
      · linarith

/-- **Thm 4.6, soundness.** -/
theorem lazy_bisection_sound {e u : ℝ → ℝ} {τ : ℝ} (he : MonotoneOn e (Set.Icc 0 1))
    (hu : ∀ x, e x ≤ u x) (k : ℕ) : ∀ π ∈ bisRegion u τ k, e π ≤ τ := by
  intro π hπ
  obtain ⟨h1, h2, h3, h4, -, -, -⟩ := bis_inv u τ k
  have hpos : (0 : ℝ) < (1 / 2) ^ k := by positivity
  unfold bisRegion at hπ
  split_ifs at hπ with hacc
  · have hlo : (bisRun u τ k).lo ∈ Set.Icc (0 : ℝ) 1 := ⟨h2, by linarith⟩
    have hπ' : π ∈ Set.Icc (0 : ℝ) 1 := ⟨hπ.1, by linarith [hπ.2]⟩
    calc e π ≤ e (bisRun u τ k).lo := he hπ' hlo hπ.2
      _ ≤ u (bisRun u τ k).lo := hu _
      _ ≤ τ := h4 hacc
  · exact absurd hπ (Set.notMem_empty π)

/-- **Thm 4.6, miss bound** (exact oracle): after `k` queries, the part of `{e ≤ τ}` that `V`
misses lies in an interval of length `2^{-k}`. -/
theorem lazy_bisection_miss {e : ℝ → ℝ} {τ : ℝ} (he : MonotoneOn e (Set.Icc 0 1)) (k : ℕ) :
    ∀ π ∈ Set.Icc (0 : ℝ) 1, e π ≤ τ → π ∉ bisRegion e τ k →
      π ∈ Set.Icc (bisRun e τ k).lo ((bisRun e τ k).lo + (1 / 2) ^ k) := by
  intro π hπ hπτ hπV
  obtain ⟨h1, h2, h3, -, h5, h6, h7⟩ := bis_inv e τ k
  have hpos : (0 : ℝ) < (1 / 2) ^ k := by positivity
  have hhi : π ≤ (bisRun e τ k).hi := by
    cases hr : (bisRun e τ k).rej
    · rw [h7 hr]; exact hπ.2
    · by_contra hlt
      push Not at hlt
      have hhi01 : (bisRun e τ k).hi ∈ Set.Icc (0 : ℝ) 1 := ⟨by linarith, h3⟩
      have := he hhi01 hπ hlt.le
      linarith [h6 hr]
  refine ⟨?_, by linarith⟩
  unfold bisRegion at hπV
  split_ifs at hπV with hacc
  · by_contra hlt
    push Not at hlt
    exact hπV ⟨hπ.1, hlt.le⟩
  · rw [h5 (by simpa using hacc)]; exact hπ.1

/-- The step functions `e_t = 2τ·1[π ≥ t]` of the lower-bound adversary. -/
noncomputable def stepFn (τ t : ℝ) : ℝ → ℝ := fun π => if t ≤ π then 2 * τ else 0

theorem stepFn_monotone {τ : ℝ} (hτ : 0 ≤ τ) (t : ℝ) : Monotone (stepFn τ t) := by
  intro a b hab
  unfold stepFn
  split_ifs <;> linarith

theorem answers_stepFn_valid {τ : ℝ} (A : AdaptiveCertifier ℝ) (t : ℝ) (k : ℕ) :
    (A.answers (stepFn τ t) k).length = k ∧
      ∀ x ∈ A.answers (stepFn τ t) k, x = 0 ∨ x = 2 * τ := by
  induction k with
  | zero => simp [AdaptiveCertifier.answers]
  | succ k ih =>
    refine ⟨by simp [AdaptiveCertifier.answers, ih.1], ?_⟩
    intro x hx
    simp only [AdaptiveCertifier.answers, List.mem_append, List.mem_singleton] at hx
    rcases hx with hx | rfl
    · exact ih.2 x hx
    · unfold stepFn; split_ifs <;> simp

/-- Encoding of a `{0, 2τ}`-valued transcript as bits. -/
noncomputable def bitsOf (τ : ℝ) (q : ℕ) (L : List ℝ) : Fin q → Bool :=
  fun i => decide (L.getD i 0 = 2 * τ)

theorem bitsOf_inj {τ : ℝ} (hτ : τ ≠ 0) {q : ℕ} {L₁ L₂ : List ℝ} (h1 : L₁.length = q)
    (h2 : L₂.length = q) (v1 : ∀ x ∈ L₁, x = 0 ∨ x = 2 * τ) (v2 : ∀ x ∈ L₂, x = 0 ∨ x = 2 * τ)
    (h : bitsOf τ q L₁ = bitsOf τ q L₂) : L₁ = L₂ := by
  apply List.ext_getElem (h1.trans h2.symm)
  intro i hi1 hi2
  have hb := congrFun h ⟨i, h1 ▸ hi1⟩
  simp only [bitsOf, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hi1,
    List.getElem?_eq_getElem hi2, Option.getD_some, decide_eq_decide] at hb
  have hne : (0 : ℝ) ≠ 2 * τ := by intro h0; apply hτ; linarith
  rcases v1 _ (List.getElem_mem hi1) with ha | ha <;>
    rcases v2 _ (List.getElem_mem hi2) with hb' | hb'
  · rw [ha, hb']
  · rw [hb'] at hb; have := hb.mpr rfl; rw [ha] at this; exact absurd this hne
  · rw [ha] at hb; have := hb.mp rfl; rw [hb'] at this; exact absurd this hne
  · rw [ha, hb']

/-- `V` has resolution `h` on `e`: the missed part of `{e ≤ τ} ∩ [0,1]` contains no interval
`[a, b)` with `b - a > h`. -/
def HasResolution (V : Set ℝ) (e : ℝ → ℝ) (τ h : ℝ) : Prop :=
  ∀ a b : ℝ, h < b - a → ¬ Set.Ico a b ⊆ {π | π ∈ Set.Icc (0 : ℝ) 1 ∧ e π ≤ τ ∧ π ∉ V}

/-- Lazy bisection with `k` queries has resolution `2^{-k}` (exact oracle). -/
theorem lazy_bisection_resolution {e : ℝ → ℝ} {τ : ℝ} (he : MonotoneOn e (Set.Icc 0 1))
    (k : ℕ) : HasResolution (bisRegion e τ k) e τ ((1 / 2) ^ k) := by
  intro a b hab hsub
  have hk : (0 : ℝ) < (1 / 2) ^ k := by positivity
  set p := b - (b - a - (1 / 2) ^ k) / 2 with hp
  have ha : a ∈ Set.Ico a b := ⟨le_rfl, by linarith⟩
  have hpm : p ∈ Set.Ico a b := ⟨by linarith, by linarith⟩
  obtain ⟨ha1, ha2, ha3⟩ := hsub ha
  obtain ⟨hp1, hp2, hp3⟩ := hsub hpm
  have m1 := lazy_bisection_miss he k a ha1 ha2 ha3
  have m2 := lazy_bisection_miss he k p hp1 hp2 hp3
  simp only [Set.mem_Icc] at m1 m2
  linarith [m1.1, m2.2]

theorem mono_collision {τ h : ℝ} (hτ : 0 < τ) (A : AdaptiveCertifier ℝ)
    (hs : CertSound {e | MonotoneOn e (Set.Icc 0 1)} (Set.Icc 0 1) τ A.toLocal)
    (hres : ∀ e, MonotoneOn e (Set.Icc 0 1) → HasResolution (A.toLocal.region e) e τ h)
    {t t' : ℝ} (ht : 0 < t) (htt' : h < t' - t) (ht' : t' ≤ 1)
    (heq : A.answers (stepFn τ t) A.budget = A.answers (stepFn τ t') A.budget) : False := by
  have hreg : A.toLocal.region (stepFn τ t) = A.toLocal.region (stepFn τ t') := by
    simp only [AdaptiveCertifier.toLocal, heq]
  apply hres (stepFn τ t') ((stepFn_monotone hτ.le t').monotoneOn _) t t' htt'
  intro π hπ
  have hπ01 : π ∈ Set.Icc (0 : ℝ) 1 := ⟨by linarith [hπ.1], by linarith [hπ.2]⟩
  refine ⟨hπ01, ?_, ?_⟩
  · simp only [stepFn, if_neg (not_le.mpr hπ.2)]; exact hτ.le
  · intro hV
    rw [← hreg] at hV
    have := hs (stepFn τ t) ((stepFn_monotone hτ.le t).monotoneOn _) π hπ01 hV
    simp only [stepFn, if_pos hπ.1] at this
    linarith

/-- **Thm 4.6, lower bound.** A deterministic adaptive certifier that is sound on the
non-decreasing functions on `[0,1]` and has resolution `h` on all of them, with an exact oracle,
makes `q` queries with `2^q ≥ 1/h`, i.e. `q ≥ ⌈log₂(1/h)⌉`. -/
theorem mono_lower_bound {τ h : ℝ} (hτ : 0 < τ) (hh : 0 < h) (A : AdaptiveCertifier ℝ)
    (hs : CertSound {e | MonotoneOn e (Set.Icc 0 1)} (Set.Icc 0 1) τ A.toLocal)
    (hres : ∀ e, MonotoneOn e (Set.Icc 0 1) → HasResolution (A.toLocal.region e) e τ h) :
    1 / h ≤ 2 ^ A.budget := by
  set q := A.budget
  by_contra hlt
  push Not at hlt
  have hq : (0 : ℝ) < 2 ^ q := by positivity
  have hhq : h * 2 ^ q < 1 := by rw [lt_div_iff₀ hh] at hlt; linarith
  set c := (h + 1 / 2 ^ q) / 2 with hc
  have hch : h < c := by
    have : h < 1 / 2 ^ q := by rw [lt_div_iff₀ hq]; exact hhq
    linarith
  have hcq : c * 2 ^ q < 1 := by
    have : c < 1 / 2 ^ q := by
      have : h < 1 / 2 ^ q := by rw [lt_div_iff₀ hq]; exact hhq
      linarith
    rwa [lt_div_iff₀ hq] at this
  have hc0 : 0 < c := by linarith
  let thr : Fin (2 ^ q + 1) → ℝ := fun j => 1 - (j : ℕ) * c
  have hthr_pos : ∀ j, 0 < thr j := by
    intro j
    have hj : ((j : ℕ) : ℝ) ≤ 2 ^ q := by
      have := Nat.lt_succ_iff.mp j.2
      exact_mod_cast this
    simp only [thr]; nlinarith
  have hthr_le : ∀ j, thr j ≤ 1 := by
    intro j; simp only [thr]; have : (0 : ℝ) ≤ (j : ℕ) := by positivity
    nlinarith
  obtain ⟨j, j', hne, hjj'⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun j => bitsOf τ q (A.answers (stepFn τ (thr j)) q)) (by simp)
  have heq : A.answers (stepFn τ (thr j)) q = A.answers (stepFn τ (thr j')) q := by
    obtain ⟨l1, v1⟩ := answers_stepFn_valid (τ := τ) A (thr j) q
    obtain ⟨l2, v2⟩ := answers_stepFn_valid (τ := τ) A (thr j') q
    exact bitsOf_inj hτ.ne' l1 l2 v1 v2 hjj'
  have hne' : (j : ℕ) ≠ (j' : ℕ) := fun h => hne (Fin.ext h)
  rcases Nat.lt_or_gt_of_ne hne' with hlt' | hlt'
  · -- thr j' < thr j
    have hgap : h < thr j - thr j' := by
      have : ((j : ℕ) : ℝ) + 1 ≤ (j' : ℕ) := by exact_mod_cast hlt'
      simp only [thr]; nlinarith
    exact mono_collision hτ A hs hres (hthr_pos j') hgap (hthr_le j) heq.symm
  · have hgap : h < thr j' - thr j := by
      have : ((j' : ℕ) : ℝ) + 1 ≤ (j : ℕ) := by exact_mod_cast hlt'
      simp only [thr]; nlinarith
    exact mono_collision hτ A hs hres (hthr_pos j) hgap (hthr_le j') heq

/-- **Thm 4.6, lower bound**, integer form: `2^q ≥ ⌈1/h⌉`. -/
theorem mono_lower_bound_ceil {τ h : ℝ} (hτ : 0 < τ) (hh : 0 < h) (A : AdaptiveCertifier ℝ)
    (hs : CertSound {e | MonotoneOn e (Set.Icc 0 1)} (Set.Icc 0 1) τ A.toLocal)
    (hres : ∀ e, MonotoneOn e (Set.Icc 0 1) → HasResolution (A.toLocal.region e) e τ h) :
    ⌈1 / h⌉₊ ≤ 2 ^ A.budget :=
  Nat.ceil_le.mpr (by exact_mod_cast mono_lower_bound hτ hh A hs hres)

end Monotone

end InfLearn.Export

#print axioms InfLearn.Export.invisible_perturbation
#print axioms InfLearn.Export.samples_do_not_determine
#print axioms InfLearn.Export.no_free_export_perturbation
#print axioms InfLearn.Export.exists_poly_interp
#print axioms InfLearn.Export.no_free_export_samples
#print axioms InfLearn.Export.no_free_export_samples_everywhere
#print axioms InfLearn.Export.no_free_export_samples_emb
#print axioms InfLearn.Export.no_free_export_samples_Icc
#print axioms InfLearn.Export.no_free_export_from_samples
#print axioms InfLearn.Export.no_sound_committing_rule
#print axioms InfLearn.Export.nodeClosed_of_addPolyClosed
#print axioms InfLearn.Export.no_free_export_samples_of_poly_subset
#print axioms InfLearn.Export.no_free_export_finite_jet
#print axioms InfLearn.Export.no_free_export_finite_jet'
#print axioms InfLearn.Export.no_free_export_away
#print axioms InfLearn.Export.no_free_export_germ
#print axioms InfLearn.Export.exists_interval_iff_radius_le
#print axioms InfLearn.Export.midrange_sound
#print axioms InfLearn.Export.optimalRule_sound
#print axioms InfLearn.Export.radius_le_of_sound
#print axioms InfLearn.Export.no_interval_of_unbounded
#print axioms InfLearn.Export.coherence_cannot_calibrate
#print axioms InfLearn.Export.coherence_cannot_calibrate_unbounded
#print axioms InfLearn.Export.no_certification_without_regularity
#print axioms InfLearn.Export.lip_cert_sound_point
#print axioms InfLearn.Export.lip_cert_sound_indexed
#print axioms InfLearn.Export.dist_le_iff_sup
#print axioms InfLearn.Export.lip_cert_sound
#print axioms InfLearn.Export.lip_cert_sound_noisy
#print axioms InfLearn.Export.lip_cert_complete_of_net
#print axioms InfLearn.Export.lip_cert_complete
#print axioms InfLearn.Export.lip_cert_complete'
#print axioms InfLearn.Export.lip_lower_bound_of_packing
#print axioms InfLearn.Export.lip_lower_bound_cube
#print axioms InfLearn.Export.lip_lower_bound_cube_adaptive
#print axioms InfLearn.Export.lip_lower_bound_interval
#print axioms InfLearn.Export.lazy_bisection_sound
#print axioms InfLearn.Export.lazy_bisection_miss
#print axioms InfLearn.Export.lazy_bisection_resolution
#print axioms InfLearn.Export.mono_lower_bound
#print axioms InfLearn.Export.mono_lower_bound_ceil
