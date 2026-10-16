import NeuralGeneralization.SquaredResponseScaling
import NeuralGeneralization.RankOneRademacherBound

/-!
# Actual finite squared-loss sampling bound

The normalized rank-one chaining estimate is instantiated on the literal
sample rows. Its normalization is then removed using the proved quadratic
bootstrap. No empirical process or entropy bound remains as a hypothesis.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {U X : Type*} [Fintype U] [Nonempty U]

def squaredSamplingConstant (n D : ℕ) (V : ℝ) : ℝ :=
  268435456*Real.sqrt (V*(Real.log (8*(n:ℝ))+(dimensionCutoff D+1 : ℕ)))

lemma squaredSamplingConstant_nonneg (n D : ℕ) (V : ℝ) :
    0 ≤ squaredSamplingConstant n D V := by unfold squaredSamplingConstant; positivity

/-- The conditional empirical norm appears only through its actual
finite maximum; this estimate is the direct normalized-row application. -/
theorem finite_squared_response_rademacher_unnormalized
    (a : Fin m → Fin D → ℝ) (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀=0)
    (V : ℝ) (hm : 0 < m) (hV : 0 < V)
    (ha : ∀ i, (∑ j, a i j^2) ≤ V) (hp : ∀ u, (∑ j, p u j^2) ≤ 1)
    (ψ : ℝ → ℝ) (hψ0 : ψ 0=0) (hψ : ∀ x y, |ψ x-ψ y|≤|x-y|)
    (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i, cubeCoordinateSign (ε i)*ψ (linearEvaluation (a i) (p u))^2)) ≤
      squaredSamplingConstant m D V*Real.sqrt (empiricalSquareEnvelope a p+1) := by
  let R : ℝ := empiricalSquareEnvelope a p+1
  have hR : 0 < R := by dsimp only [R]; have hs := empiricalSquareEnvelope_nonneg a p; linarith
  have hn := finite_squared_response_rademacher (normalizedRows a p) p u₀ hroot (V/R) hm
    (div_pos hV hR) (normalizedRows_variance a p V ha) hp (normalizedRows_rowEnergy a p) ψ hψ0 hψ
  rw [squared_response_process_normalization ψ hscale a p]
  have hmul := mul_le_mul_of_nonneg_left hn hR.le
  let L : ℝ := Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ)
  have hL : 0 ≤ L := add_nonneg (rankGrowth_log_nonneg m hm) (Nat.cast_nonneg _)
  have he := sqrt_normalization_identity V L R hV.le hL hR
  change _ ≤ squaredSamplingConstant m D V*Real.sqrt R
  change _ ≤ R*(268435456*Real.sqrt ((V/R)*L)) at hmul
  have hid : R*(268435456*Real.sqrt ((V/R)*L)) =
      squaredSamplingConstant m D V*Real.sqrt R := by
    unfold squaredSamplingConstant
    change _ = 268435456*Real.sqrt (V*L)*Real.sqrt R
    nlinarith only [he]
  exact hmul.trans_eq hid

variable [Fintype X] [Nonempty X]

/-- The actual uniform expected deviation for any finite class of unit
coefficient vectors, under an explicit orthonormal feature identity. -/
theorem finite_squared_response_deviation (n : ℕ) (a : X → Fin D → ℝ)
    (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀=0)
    (V : ℝ) (hn : 0 < n) (hV : 0 < V)
    (ha : ∀ x, (∑ j, a x j^2) ≤ V) (hp : ∀ u, (∑ j, p u j^2) ≤ 1)
    (hiso : ∀ c, finiteMean (fun x => linearEvaluation (a x) c^2) = ∑ j, c j^2)
    (ψ : ℝ → ℝ) (hψ0 : ψ 0=0) (hψ : ∀ x y, |ψ x-ψ y|≤|x-y|)
    (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x) :
    finiteMean (fun s : Fin n → X => envelope (fun u =>
      sampleTotal (fun u => squaredResponse ψ a (p u)) s u-
        (n:ℝ)*finiteMean (squaredResponse ψ a (p u)))) ≤
      4*(squaredSamplingConstant n D V)^2+
        2*squaredSamplingConstant n D V*Real.sqrt ((n:ℝ)+1) := by
  let F := fun u => squaredResponse ψ a (p u)
  let G := fun u => squaredResponse id a (p u)
  apply finite_squared_process_bootstrap n F G (squaredSamplingConstant n D V)
    (squaredSamplingConstant_nonneg n D V) (fun u x => sq_nonneg _)
  · intro u
    change finiteMean (fun x => linearEvaluation (a x) (p u)^2) ≤ 1
    rw [hiso]
    exact hp u
  · intro s
    exact finite_squared_response_rademacher_unnormalized (fun i => a (s i)) p u₀ hroot V hn hV
      (fun i => ha (s i)) hp id rfl (fun x y => le_rfl) (fun t ht x => rfl)
  · intro s
    exact finite_squared_response_rademacher_unnormalized (fun i => a (s i)) p u₀ hroot V hn hV
      (fun i => ha (s i)) hp ψ hψ0 hψ hscale

/-- A fully explicit lower bound on the probability of simultaneous
coercivity for every coefficient vector. -/
theorem all_vector_squared_coercivity_probability (n : ℕ) (a : X → Fin D → ℝ)
    (V b q : ℝ) (hn : 0 < n) (hV : 0 < V) (hbq : q < b)
    (ha : ∀ x, (∑ j, a x j^2) ≤ V)
    (hiso : ∀ c, finiteMean (fun x => linearEvaluation (a x) c^2) = ∑ j, c j^2)
    (ψ : ℝ → ℝ) (hψ0 : ψ 0=0) (hψ : ∀ x y, |ψ x-ψ y|≤|x-y|)
    (hscale : ∀ t : ℝ, 0 ≤ t → ∀ x : ℝ, ψ (t*x)=t*ψ x)
    (hpop : ∀ c, b*(∑ j, c j^2) ≤ finiteMean (squaredResponse ψ a c)) :
    1-(4*(squaredSamplingConstant n D V)^2+
      2*squaredSamplingConstant n D V*Real.sqrt ((n:ℝ)+1))/((n:ℝ)*(b-q)) ≤
      finiteMean (fun s : Fin n → X => if
        (∀ c : Fin D → ℝ, q*(∑ j, c j^2) ≤ (∑ i, squaredResponse ψ a c (s i))/(n:ℝ))
        then 1 else 0) := by
  classical
  let p := coercivityWitnessClass ψ a q (n := n)
  have hd := finite_squared_response_deviation n a p none rfl V hn hV ha
    (coercivityWitnessClass_norm_le ψ a q) hiso ψ hψ0 hψ hscale
  have hb := coercivityFailure_probability_bound ψ a b q
    (4*(squaredSamplingConstant n D V)^2+
      2*squaredSamplingConstant n D V*Real.sqrt ((n:ℝ)+1)) hn hbq hpop hd
  have hpoint (s : Fin n → X) :
      1-(if unitCoercivityFailure ψ a q s then (1:ℝ) else 0) ≤
        if (∀ c : Fin D → ℝ, q*(∑ j, c j^2) ≤ (∑ i, squaredResponse ψ a c (s i))/(n:ℝ)) then 1 else 0 := by
    by_cases hs : unitCoercivityFailure ψ a q s
    · simp only [if_pos hs, sub_self]
      split_ifs <;> norm_num
    · rw [if_neg hs, sub_zero, if_pos (all_vector_coercivity_of_unit ψ a hψ0 hscale q s hn hs)]
  have hmean := finiteMean_mono hpoint
  rw [finiteMean_sub, finiteMean_const] at hmean
  linarith only [hb, hmean]

/-- A convenient explicit numerical sample budget. -/
lemma squared_sampling_error_small (A N : ℝ) (hA : 0 ≤ A) (hN : 1 ≤ N)
    (hlarge : 1048576*A^2 ≤ N) :
    (4*A^2+2*A*Real.sqrt (N+1))/(N/8) ≤ 1/16 := by
  have hNpos : 0 < N := by linarith only [hN]
  have hs : Real.sqrt (N+1)^2 = N+1 := Real.sq_sqrt (by linarith only [hN])
  have hmul := mul_le_mul_of_nonneg_right hlarge (show 0 ≤ N+1 by linarith only [hN])
  have hNmul : N*(N+1) ≤ 2*N^2 := by
    nlinarith only [mul_nonneg hNpos.le (sub_nonneg.mpr hN)]
  have hcross : A*Real.sqrt (N+1) ≤ N/512 := by
    apply (sq_le_sq₀ (mul_nonneg hA (Real.sqrt_nonneg _)) (by positivity : 0 ≤ N/512)).mp
    rw [mul_pow, hs]
    nlinarith only [hmul, hNmul, sq_nonneg N]
  apply (div_le_iff₀ (by positivity : 0 < N/8)).2
  nlinarith only [hlarge, hcross, hN]

end NeuralGeneralization.SquaredSampling
