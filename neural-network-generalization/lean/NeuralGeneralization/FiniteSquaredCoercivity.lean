import NeuralGeneralization.EmpiricalSquareBootstrap

/-!
# Finite witness reduction for uniform squared-loss coercivity

There are finitely many possible data sets. Selecting one failing unit
vector for each data set reduces the all-vector event to a single finite
class, without a net approximation or an uncountable supremum theorem.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {X : Type*} [Fintype X] [Nonempty X] {D n : ℕ}

def squaredResponse (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (c : Fin D → ℝ) (x : X) : ℝ :=
  ψ (linearEvaluation (a x) c)^2

def unitCoercivityFailure (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (q : ℝ) (s : Fin n → X) : Prop :=
  ∃ c : Fin D → ℝ, (∑ j, c j^2)=1 ∧ (∑ i, squaredResponse ψ a c (s i)) < (n:ℝ)*q

def coercivityWitness (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (q : ℝ) (s : Fin n → X) : Fin D → ℝ :=
  if h : unitCoercivityFailure ψ a q s then h.choose else 0

def coercivityWitnessClass (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (q : ℝ) :
    Option (Fin n → X) → Fin D → ℝ
  | none => 0
  | some s => coercivityWitness ψ a q s

lemma coercivityWitness_properties (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (q : ℝ)
    (s : Fin n → X) (hs : unitCoercivityFailure ψ a q s) :
    (∑ j, coercivityWitness ψ a q s j^2)=1 ∧
      (∑ i, squaredResponse ψ a (coercivityWitness ψ a q s) (s i)) < (n:ℝ)*q := by
  simp only [coercivityWitness, dif_pos hs]
  exact hs.choose_spec

lemma coercivityWitnessClass_norm_le (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (q : ℝ)
    (u : Option (Fin n → X)) : (∑ j, coercivityWitnessClass ψ a q u j^2) ≤ 1 := by
  cases u with
  | none => simp [coercivityWitnessClass]
  | some s =>
    by_cases hs : unitCoercivityFailure ψ a q s
    · exact (coercivityWitness_properties ψ a q s hs).1.le
    · simp [coercivityWitnessClass, coercivityWitness, hs]

lemma coercivityFailure_le_deviation (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (b q : ℝ)
    (hpopulation : ∀ c : Fin D → ℝ, b*(∑ j, c j^2) ≤ finiteMean (squaredResponse ψ a c))
    (s : Fin n → X) :
    (n:ℝ)*(b-q)*(if unitCoercivityFailure ψ a q s then 1 else 0) ≤
      envelope (fun u : Option (Fin n → X) =>
        sampleTotal (fun u => squaredResponse ψ a (coercivityWitnessClass ψ a q u)) s u -
          (n:ℝ)*finiteMean (squaredResponse ψ a (coercivityWitnessClass ψ a q u))) := by
  by_cases hs : unitCoercivityFailure ψ a q s
  · rw [if_pos hs, mul_one]
    let F := fun u : Option (Fin n → X) => squaredResponse ψ a (coercivityWitnessClass ψ a q u)
    have hw := coercivityWitness_properties ψ a q s hs
    have hp := hpopulation (coercivityWitness ψ a q s)
    rw [hw.1, mul_one] at hp
    have hpn := mul_le_mul_of_nonneg_left hp (Nat.cast_nonneg n : (0:ℝ)≤n)
    have he := le_envelope_finite (fun u => sampleTotal F s u-(n:ℝ)*finiteMean (F u)) (some s)
    have ha := neg_le_abs (sampleTotal F s (some s)-(n:ℝ)*finiteMean (F (some s)))
    change _ ≤ envelope (fun u => sampleTotal F s u-(n:ℝ)*finiteMean (F u))
    have hFs : sampleTotal F s (some s) = ∑ i, squaredResponse ψ a (coercivityWitness ψ a q s) (s i) := rfl
    have hFp : finiteMean (F (some s)) = finiteMean (squaredResponse ψ a (coercivityWitness ψ a q s)) := rfl
    rw [hFs, hFp] at he ha
    nlinarith only [hw.2, hpn, he, ha]
  · rw [if_neg hs, mul_zero]
    exact envelope_nonneg_finite _

/-- Failure probability for all unit vectors is controlled by one finite
empirical process. The finite class is defined explicitly above. -/
theorem coercivityFailure_probability_bound (ψ : ℝ → ℝ) (a : X → Fin D → ℝ) (b q R : ℝ)
    (hn : 0 < n) (hbq : q < b)
    (hpopulation : ∀ c : Fin D → ℝ, b*(∑ j, c j^2) ≤ finiteMean (squaredResponse ψ a c))
    (hdeviation : finiteMean (fun s : Fin n → X =>
      envelope (fun u : Option (Fin n → X) =>
        sampleTotal (fun u => squaredResponse ψ a (coercivityWitnessClass ψ a q u)) s u -
          (n:ℝ)*finiteMean (squaredResponse ψ a (coercivityWitnessClass ψ a q u)))) ≤ R) :
    finiteMean (fun s : Fin n → X => if unitCoercivityFailure ψ a q s then 1 else 0) ≤
      R/((n:ℝ)*(b-q)) := by
  have hh := finiteMean_mono (coercivityFailure_le_deviation ψ a b q hpopulation (n := n))
  rw [finiteMean_mul] at hh
  apply (le_div_iff₀ (mul_pos (Nat.cast_pos.mpr hn) (sub_pos.mpr hbq))).2
  nlinarith only [hh, hdeviation]

lemma linearEvaluation_scale (a c : Fin D → ℝ) (s : ℝ) :
    linearEvaluation a (fun j => s*c j) = s*linearEvaluation a c := by
  simp only [linearEvaluation, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- Positive homogeneity extends unit-vector coercivity to every vector. -/
theorem all_vector_coercivity_of_unit (ψ : ℝ → ℝ) (a : X → Fin D → ℝ)
    (hzero : ψ 0=0) (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x)
    (q : ℝ) (s : Fin n → X) (hn : 0 < n)
    (hunit : ¬ unitCoercivityFailure ψ a q s) :
    ∀ c : Fin D → ℝ, q*(∑ j, c j^2) ≤ (∑ i, squaredResponse ψ a c (s i))/(n:ℝ) := by
  intro c
  let Q : ℝ := ∑ j, c j^2
  have hQ : 0 ≤ Q := Finset.sum_nonneg (fun j _ => sq_nonneg _)
  by_cases hQzero : Q=0
  · have hc (j : Fin D) : c j=0 := by
      have ht : c j^2 ≤ Q := Finset.single_le_sum (fun k _ => sq_nonneg (c k)) (Finset.mem_univ j)
      rw [hQzero] at ht
      exact sq_eq_zero_iff.mp (le_antisymm ht (sq_nonneg _))
    rw [show (∑ j, c j^2)=0 from hQzero, mul_zero]
    exact div_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _)) (Nat.cast_nonneg _)
  · have hQpos : 0 < Q := lt_of_le_of_ne hQ (Ne.symm hQzero)
    let R : ℝ := Real.sqrt Q
    have hRpos : 0 < R := Real.sqrt_pos.2 hQpos
    have hRsq : R^2=Q := Real.sq_sqrt hQ
    let u : Fin D → ℝ := fun j => c j/R
    have hu : (∑ j, u j^2)=1 := by
      simp only [u, div_pow, ← Finset.sum_div]
      rw [hRsq]
      exact div_self hQzero
    have hl : (n:ℝ)*q ≤ ∑ i, squaredResponse ψ a u (s i) := by
      by_contra hh
      exact hunit ⟨u, hu, lt_of_not_ge hh⟩
    have he (x : X) : squaredResponse ψ a c x = Q*squaredResponse ψ a u x := by
      have hcu : c = fun j => R*u j := by ext j; dsimp only [u]; field_simp
      rw [hcu, squaredResponse, linearEvaluation_scale, hscale R hRpos.le, mul_pow, hRsq]
      rfl
    simp_rw [he]
    rw [← Finset.mul_sum]
    apply (le_div_iff₀ (Nat.cast_pos.mpr hn)).2
    change q*Q*(n:ℝ) ≤ Q*∑ i, squaredResponse ψ a u (s i)
    nlinarith only [mul_le_mul_of_nonneg_left hl hQ]

lemma negativePart_homogeneous (t x : ℝ) (ht : 0 ≤ t) :
    max 0 (-(t*x)) = t*max 0 (-x) := by
  rw [mul_max_of_nonneg _ _ ht]
  simp only [mul_zero, mul_neg]

end NeuralGeneralization.SquaredSampling
