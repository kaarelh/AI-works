import NeuralGeneralization.CloneSubspace
import NeuralGeneralization.MarginRescaling
import NeuralGeneralization.PrunedNetwork
import NeuralGeneralization.ParameterStability

/-!
# Stability of the actual cloning cylinder

Only the row projections on the teacher hidden-state subspace need to be small.
The remaining matrix may have order-one operator norm: it annihilates the exact
teacher state. All conclusions below concern the concrete finite network.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.Compression NeuralGeneralization.CompressionSampling

variable {d N r : ℕ}

/-- Squared Euclidean action bound, equivalent to an operator-norm bound. -/
def matrixActionBound (A : Fin N → Fin N → ℝ) (B : ℝ) : Prop :=
  ∀ z : Fin N → ℝ, (∑ i, (∑ j, A i j * z j)^2) ≤ B^2 * ∑ j, z j^2

private theorem sum_sq_add_three_le (a b c : Fin N → ℝ) :
    (∑ i, (a i + b i + c i)^2) ≤
      3 * ((∑ i, a i^2) + (∑ i, b i^2) + ∑ i, c i^2) := by
  calc
    _ ≤ ∑ i, 3 * (a i^2 + b i^2 + c i^2) := by
      apply Finset.sum_le_sum
      intro i hi
      nlinarith [sq_nonneg (a i - b i), sq_nonneg (a i - c i),
        sq_nonneg (b i - c i)]
    _ = _ := by rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_add_distrib]

/-- The free matrix kills the teacher signal, so only the bounded actual
hidden vector enters the small projected perturbation. -/
theorem cylinder_hiddenStep_squaredDistance (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) (K G B ρ : ℝ)
    (_hK : 0 ≤ K) (hG : 0 ≤ G)
    (hdecomp : ∀ s i j, w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j))) + R s i j + E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s, (∑ i, ∑ j, R s i j^2) ≤ ρ^2 * G)
    (hE : ∀ s, matrixActionBound (E s) B)
    (u z : Fin N → ℝ) (hu : ∀ i, |u i| ≤ 1)
    (hEz : ∀ s i, (∑ j, E s i j * z j) = 0) (s : Fin r) :
    squaredDistance (hiddenStep φ w u s) (hiddenStep φ v z s) ≤
      3 * (K + B^2) * squaredDistance u z + 3 * ρ^2 * G * N := by
  have hdiff (i : Fin N) :
      (∑ j, w (Sum.inr (Sum.inl (s,i,j))) * u j) -
        (∑ j, v (Sum.inr (Sum.inl (s,i,j))) * z j) =
      (∑ j, v (Sum.inr (Sum.inl (s,i,j))) * (u j-z j)) +
      (∑ j, E s i j * (u j-z j)) + (∑ j, R s i j * u j) := by
    simp_rw [hdecomp, add_mul, mul_sub]
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib,
      Finset.sum_sub_distrib, Finset.sum_sub_distrib, hEz s i]
    ring
  have hnormu : (∑ i, u i^2) ≤ (N : ℝ) := by
    calc
      _ ≤ ∑ _ : Fin N, (1:ℝ) := Finset.sum_le_sum fun i _ => by
        have hh := (sq_le_sq₀ (abs_nonneg (u i)) (by norm_num : (0:ℝ) ≤ 1)).2 (hu i)
        simpa using hh
      _ = _ := by simp
  have hT := (matrix_action_squaredSum_le
    (fun i j => v (Sum.inr (Sum.inl (s,i,j)))) (fun i => u i-z i)).trans
    (mul_le_mul_of_nonneg_right (internal_squaredNorm_le_cost v s |>.trans hv)
      (Finset.sum_nonneg fun _ _ => sq_nonneg _))
  have hR' := (matrix_action_squaredSum_le (R s) u).trans
    (mul_le_mul (hR s) hnormu (Finset.sum_nonneg fun _ _ => sq_nonneg _)
      (mul_nonneg (sq_nonneg ρ) hG))
  have hE' := hE s (fun i => u i-z i)
  calc
    _ ≤ ∑ i, ((∑ j, w (Sum.inr (Sum.inl (s,i,j))) * u j) -
        (∑ j, v (Sum.inr (Sum.inl (s,i,j))) * z j))^2 :=
      lipschitz_activation_squaredDistance φ hφ.2 _ _
    _ = ∑ i, ((∑ j, v (Sum.inr (Sum.inl (s,i,j))) * (u j-z j)) +
      (∑ j, E s i j * (u j-z j)) + (∑ j, R s i j * u j))^2 := by
      simp_rw [hdiff]
    _ ≤ _ := by
      have hh := sum_sq_add_three_le
        (fun i => ∑ j, v (Sum.inr (Sum.inl (s,i,j))) * (u j-z j))
        (fun i => ∑ j, E s i j * (u j-z j)) (fun i => ∑ j, R s i j*u j)
      unfold squaredDistance
      nlinarith

/-- A simple polynomial recurrence coefficient; sharp constants are unnecessary. -/
def cylinderAmplification (K G B : ℝ) : ℝ := 3 * (K+B^2) + 3*G + 1

def cylinderInputFactor (d : ℕ) : ℝ := ((d:ℝ)+1)^2+1

theorem hiddenFold_bounded (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (ss : List (Fin r)) (x : Cube d) (i : Fin N) :
    |ss.foldl (hiddenStep φ w) (firstHidden φ w x) i| ≤ 1 := by
  cases ss using List.reverseRecOn with
  | nil => exact hφ.1 _
  | append_singleton tt t =>
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    exact hφ.1 _

/-- Input-row coordinate constraints imply the normalized squared-error bound. -/
theorem cylinder_firstHidden_error (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (x : Cube d) :
    squaredDistance (firstHidden φ w x) (firstHidden φ v x) ≤
      (N:ℝ)*ρ^2*cylinderInputFactor d := by
  have hpoint (i : Fin N) : |firstHidden φ w x i-firstHidden φ v x i| ≤
      ((d:ℝ)+1)*ρ := by
    apply (hφ.2 _ _).trans
    rw [← Finset.sum_sub_distrib]
    calc
      _ ≤ ∑ j, |w (Sum.inl (i,j))*inputVector x j -
        v (Sum.inl (i,j))*inputVector x j| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _ : Fin (d+1), ρ := Finset.sum_le_sum fun j _ => by
        rw [← sub_mul, abs_mul, abs_inputVector, mul_one]
        exact hfirst i j
      _ = _ := by simp
  calc
    _ ≤ ∑ _ : Fin N, (((d:ℝ)+1)*ρ)^2 := by
      apply Finset.sum_le_sum
      intro i hi
      have hh := (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (by positivity) hρ)).2 (hpoint i)
      simpa only [sq_abs] using hh
    _ ≤ _ := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      unfold cylinderInputFactor
      nlinarith [mul_nonneg (Nat.cast_nonneg N : (0:ℝ) ≤ N) (sq_nonneg ρ)]

/-- The actual hidden-state error, with no dependence on width after normalization. -/
theorem cylinder_hiddenFold_error (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) (K G B ρ : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ)
    (hdecomp : ∀ s i j, w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j))) + R s i j + E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s, (∑ i, ∑ j, R s i j^2) ≤ ρ^2 * G)
    (hE : ∀ s, matrixActionBound (E s) B)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N), (∑ j, E s i j *
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) j) = 0)
    (ss : List (Fin r)) (x : Cube d) :
    squaredDistance
      (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) ≤
    (N:ℝ)*ρ^2*cylinderInputFactor d*(cylinderAmplification K G B)^ss.length := by
  have hA : 1 ≤ cylinderAmplification K G B := by
    unfold cylinderAmplification
    nlinarith [sq_nonneg B]
  have hD : 1 ≤ cylinderInputFactor d := by
    unfold cylinderInputFactor
    nlinarith [sq_nonneg ((d:ℝ)+1)]
  induction ss using List.reverseRecOn with
  | nil => simpa using cylinder_firstHidden_error φ hφ w v ρ hρ hfirst x
  | append_singleton ss s ih =>
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil,
      List.length_append, List.length_singleton, pow_add, pow_one]
    have hs := cylinder_hiddenStep_squaredDistance φ hφ w v R E K G B ρ hK hG
      hdecomp hv hR hE _ _ (fun i => hiddenFold_bounded φ hφ w ss x i)
      (hkill x ss) s
    have hp : 1 ≤ (cylinderAmplification K G B)^ss.length := one_le_pow₀ hA
    have hscale : 0 ≤ (N:ℝ)*ρ^2 := mul_nonneg (Nat.cast_nonneg N) (sq_nonneg ρ)
    have hlarge : (N:ℝ)*ρ^2 ≤
        (N:ℝ)*ρ^2*cylinderInputFactor d*(cylinderAmplification K G B)^ss.length := by
      calc
        _ = (N:ℝ)*ρ^2*1*1 := by ring
        _ ≤ _ := mul_le_mul (mul_le_mul_of_nonneg_left hD hscale) hp
          (by positivity) (by positivity)
    have hstep := mul_le_mul_of_nonneg_left ih
      (by positivity : 0 ≤ 3*(K+B^2))
    have hrest := mul_le_mul_of_nonneg_left hlarge (by positivity : 0 ≤ 3*G)
    unfold cylinderAmplification at *
    nlinarith

/-- Final linear readout converts hidden squared error into a width-free bound. -/
theorem cylinder_networkOutput_error_sq (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) (K G B ρ : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hρ : 0 ≤ ρ)
    (hdecomp : ∀ s i j, w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j))) + R s i j + E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s, (∑ i, ∑ j, R s i j^2) ≤ ρ^2 * G)
    (hE : ∀ s, matrixActionBound (E s) B)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ ρ)
    (hread : ∀ i, |w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤ ρ/N)
    (hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N), (∑ j, E s i j *
      ss.foldl (hiddenStep φ v) (firstHidden φ v x) j) = 0)
    (x : Cube d) :
    (networkOutput φ w x-networkOutput φ v x)^2 ≤
      ρ^2*(2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r+2) := by
  have hNR : 0 < (N:ℝ) := by exact_mod_cast hN
  let u := finalHidden φ w x
  let z := finalHidden φ v x
  let a := ∑ i, v (Sum.inr (Sum.inr i))*(u i-z i)
  let b := ∑ i, (w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*u i
  have heq : networkOutput φ w x-networkOutput φ v x = a+b := by
    dsimp [networkOutput, a, b, u, z]
    simp_rw [mul_sub, sub_mul]
    simp only [Finset.sum_sub_distrib]
    ring
  have hb : |b| ≤ ρ := by
    calc
      _ ≤ ∑ i, |(w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i)))*u i| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _ : Fin N, ρ/(N:ℝ) := Finset.sum_le_sum fun i _ => by
        rw [abs_mul]
        have hu := hiddenFold_bounded φ hφ w (List.finRange r) x i
        exact (mul_le_mul (hread i) hu (abs_nonneg _) (div_nonneg hρ hNR.le)).trans_eq
          (mul_one _)
      _ = ρ := by simp [mul_div_cancel₀ ρ hNR.ne']
  have hb2 : b^2 ≤ ρ^2 := by
    simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg b) hρ).2 hb
  have hhidden := cylinder_hiddenFold_error φ hφ w v R E K G B ρ hK hG hρ
    hdecomp hv hR hE hfirst hkill (List.finRange r) x
  simp only [List.length_finRange] at hhidden
  have hreadnorm := output_squaredNorm_le_of_cost hN v hv
  have ha := (Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i => v (Sum.inr (Sum.inr i))) (fun i => u i-z i)).trans
    (mul_le_mul hreadnorm hhidden (by positivity)
      (div_nonneg hK hNR.le))
  have hcancel : (K/(N:ℝ))*((N:ℝ)*ρ^2*cylinderInputFactor d*
      (cylinderAmplification K G B)^r) =
      K*ρ^2*cylinderInputFactor d*(cylinderAmplification K G B)^r := by
    field_simp
  change a^2 ≤ _ at ha
  rw [hcancel] at ha
  rw [heq]
  nlinarith [sq_nonneg (a-b)]

/-- Its reciprocal is a polynomial in all complexity parameters at fixed depth. -/
def cylinderRadius (d r : ℕ) (K G B : ℝ) : ℝ :=
  (2 * (2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r+2))⁻¹

theorem cylinderRadius_pos (d r : ℕ) {K G B : ℝ} (hK : 0 ≤ K) (hG : 0 ≤ G) :
    0 < cylinderRadius d r K G B := by
  unfold cylinderRadius cylinderInputFactor cylinderAmplification
  positivity

theorem cylinderRadius_le_one (d r : ℕ) {K G B : ℝ} (hK : 0 ≤ K) (hG : 0 ≤ G) :
    cylinderRadius d r K G B ≤ 1 := by
  have hA : 0 ≤ cylinderAmplification K G B := by
    unfold cylinderAmplification
    positivity
  have hD : 0 ≤ cylinderInputFactor d := by
    unfold cylinderInputFactor
    positivity
  have hF : 1 ≤ 2 * (2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r+2) := by
    have ht : 0 ≤ 2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r := by positivity
    linarith
  exact inv_le_one_of_one_le₀ hF

/-- Choosing the explicit radius gives error at most one half at every input. -/
theorem cylinder_networkOutput_error (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : admissibleActivation φ) (w v : Weights d N r)
    (R E : Fin r → Fin N → Fin N → ℝ) (K G B : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G)
    (hdecomp : ∀ s i j, w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j))) + R s i j + E s i j)
    (hv : weightedSquaredNorm v ≤ K)
    (hR : ∀ s, (∑ i, ∑ j, R s i j^2) ≤ (cylinderRadius d r K G B)^2 * G)
    (hE : ∀ s, matrixActionBound (E s) B)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ cylinderRadius d r K G B)
    (hread : ∀ i, |w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤
      cylinderRadius d r K G B/N)
    (hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑ j, E s i j * ss.foldl (hiddenStep φ v) (firstHidden φ v x) j) = 0)
    (x : Cube d) : |networkOutput φ w x-networkOutput φ v x| ≤ 1/2 := by
  let F := 2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r+2
  have hF : 1 ≤ F := by
    have hA : 0 ≤ cylinderAmplification K G B := by
      unfold cylinderAmplification
      positivity
    have hD : 0 ≤ cylinderInputFactor d := by
      unfold cylinderInputFactor
      positivity
    have ht : 0 ≤ 2*K*cylinderInputFactor d*(cylinderAmplification K G B)^r := by positivity
    dsimp [F]
    linarith
  have hFp : 0 < F := lt_of_lt_of_le zero_lt_one hF
  have hnum : (cylinderRadius d r K G B)^2 * F ≤ 1/4 := by
    change (2*F)⁻¹^2 * F ≤ 1/4
    have heq : (2*F)⁻¹^2 * F = 1/(4*F) := by field_simp; norm_num
    rw [heq]
    apply (div_le_iff₀ (by positivity : 0 < 4*F)).2
    linarith
  have hh := cylinder_networkOutput_error_sq hN φ hφ w v R E K G B
    (cylinderRadius d r K G B) hK hG (cylinderRadius_pos d r hK hG).le
    hdecomp hv hR hE hfirst hread hkill x
  apply abs_le_of_sq_le_sq _ (by norm_num : (0:ℝ) ≤ 1/2)
  have he := hh.trans hnum
  nlinarith

/-- A strengthened-margin teacher and its shared hidden-state subspace at every
admissible width. The cost coefficient is explicit and polynomial. -/
theorem exists_cylinder_teacher {C : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ (v : Weights d N r) (S : Submodule ℝ (Fin N → ℝ)),
      v ∈ marginEvent φ (3/2) f ∧
      weightedSquaredNorm v ≤
        18*((d:ℝ)*(d+1)*C^2+(r+1)*C^4) ∧
      Module.finrank ℝ S ≤ C+1 ∧
      ∀ x (ss : List (Fin r)), ss.foldl (hiddenStep φ v) (firstHidden φ v x) ∈ S := by
  obtain ⟨hC,w,hmargin,hbounded⟩ := hf
  obtain ⟨u,S,hu,hcost,hS,hhidden⟩ := exists_clone_and_hidden_subspace_at_every_width
    (Nat.lt_of_lt_of_le Nat.zero_lt_one hC) hCN φ w
  refine ⟨rescaleReadout 3 u,S,?_,?_,hS,?_⟩
  · intro x
    rw [rescaleReadout_output, hu x]
    have hh := hmargin x
    nlinarith
  · have hh := rescaleReadout_cost_le (show (1:ℝ) ≤ 3 by norm_num) u
    have ht := weightedSquaredNorm_bounded_teacher
      (Nat.lt_of_lt_of_le Nat.zero_lt_one hC) w hbounded
    nlinarith
  · intro x ss
    exact hhidden x ss

/-- The cylinder teacher also has all its internal rows in the same subspace,
so orthogonal free-coordinate Gaussian centers are exactly zero. -/
theorem exists_supported_cylinder_teacher {C : ℕ} (φ : ℝ → ℝ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ (v : Weights d N r) (S : Submodule ℝ (Fin N → ℝ)),
      v ∈ marginEvent φ (3/2) f ∧
      weightedSquaredNorm v ≤
        18*((d:ℝ)*(d+1)*C^2+(r+1)*C^4) ∧
      Module.finrank ℝ S ≤ C+1 ∧
      (∀ x (ss : List (Fin r)), ss.foldl (hiddenStep φ v) (firstHidden φ v x) ∈ S) ∧
      (∀ s i, (fun j => v (Sum.inr (Sum.inl (s,i,j)))) ∈ S) ∧
      (fun j => v (Sum.inr (Sum.inr j))) ∈ S := by
  obtain ⟨hC,w,hmargin,hbounded⟩ := hf
  obtain ⟨u,S,hu,hcost,hS,hhidden,hrows,hread⟩ := exists_supported_clone_at_every_width
    (Nat.lt_of_lt_of_le Nat.zero_lt_one hC) hCN φ w
  refine ⟨rescaleReadout 3 u,S,?_,?_,hS,hhidden,hrows,?_⟩
  · intro x
    rw [rescaleReadout_output, hu x]
    have hh := hmargin x
    nlinarith
  · have hh := rescaleReadout_cost_le (show (1:ℝ) ≤ 3 by norm_num) u
    have ht := weightedSquaredNorm_bounded_teacher
      (Nat.lt_of_lt_of_le Nat.zero_lt_one hC) w hbounded
    nlinarith
  · exact S.smul_mem 3 hread

/-- Margin transfer itself uses no probabilistic or width-limit argument. -/
theorem cylinder_margin_transfer (φ : ℝ → ℝ) (f : BooleanFunction d)
    (w v : Weights d N r) (hv : v ∈ marginEvent φ (3/2) f)
    (herr : ∀ x, |networkOutput φ w x-networkOutput φ v x| ≤ 1/2) :
    w ∈ marginEvent φ (1/2) f := by
  intro x
  have hm := hv x
  have he : |labelReal (f x)*(networkOutput φ w x-networkOutput φ v x)| ≤ 1/2 := by
    simpa only [abs_mul, abs_labelReal, one_mul] using herr x
  have hl := (abs_le.mp he).1
  nlinarith

end NeuralGeneralization.ConcreteModel
