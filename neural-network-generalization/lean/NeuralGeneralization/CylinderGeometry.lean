import NeuralGeneralization.CylinderStability
import NeuralGeneralization.GaussianMatrixGeometry
import NeuralGeneralization.AdaptedBasis

/-! # Orthogonal-coordinate geometry for the actual network cylinder -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
open WithLp
namespace NeuralGeneralization.ConcreteModel

variable {N r : ℕ}

/-- Ordinary orthogonal coordinates of one actual matrix row. -/
def basisCoordinates (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z : Fin N → ℝ) : EuclideanSpace ℝ (Fin N) := b.repr (toLp 2 z)

/-- Reconstruct the coordinates indexed by the constrained set. -/
def selectedRow (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) : Fin N → ℝ :=
  ofLp (b.repr.symm (toLp 2 (fun i => if i ∈ J then basisCoordinates b z i else 0)))

/-- Reconstruct the free, orthogonal coordinates. -/
def freeRow (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) : Fin N → ℝ :=
  ofLp (b.repr.symm (toLp 2 (fun i => if i ∈ J then 0 else basisCoordinates b z i)))

@[simp] theorem basisCoordinates_selectedRow
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) (i : Fin N) :
    basisCoordinates b (selectedRow b J z) i = if i ∈ J then basisCoordinates b z i else 0 := by
  simp [basisCoordinates, selectedRow]

@[simp] theorem basisCoordinates_freeRow
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) (i : Fin N) :
    basisCoordinates b (freeRow b J z) i = if i ∈ J then 0 else basisCoordinates b z i := by
  simp [basisCoordinates, freeRow]

@[simp] theorem basisCoordinates_add
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z u : Fin N → ℝ) (i : Fin N) :
    basisCoordinates b (z+u) i = basisCoordinates b z i+basisCoordinates b u i := by
  simp [basisCoordinates]

@[simp] theorem basisCoordinates_sub
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z u : Fin N → ℝ) (i : Fin N) :
    basisCoordinates b (z-u) i = basisCoordinates b z i-basisCoordinates b u i := by
  simp [basisCoordinates]

/-- Parseval's identity for the exact finite-coordinate convention. -/
theorem basisCoordinates_energy
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z : Fin N → ℝ) : (∑ i, basisCoordinates b z i^2) = ∑ i, z i^2 := by
  have hh := congrArg (fun t : ℝ => t^2) (b.repr.norm_map (toLp 2 z))
  simpa only [EuclideanSpace.real_norm_sq_eq, basisCoordinates] using hh

theorem basisCoordinates_inner
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z u : Fin N → ℝ) :
    (∑ i, basisCoordinates b z i*basisCoordinates b u i) = ∑ i, z i*u i := by
  have hh := b.repr.inner_map_map (toLp 2 u) (toLp 2 z)
  simpa only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial,
    basisCoordinates] using hh

/-- Coordinates outside the spanning basis set vanish on the teacher subspace. -/
theorem basisCoordinates_zero_of_mem_span
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ)
    (hz : toLp 2 z ∈ Submodule.span ℝ (b '' (J : Set (Fin N)))) :
    ∀ i, i ∉ J → basisCoordinates b z i = 0 := by
  intro i hi
  change b.repr (toLp 2 z) i = 0
  refine Submodule.span_induction (p := fun y _ => b.repr y i = 0) ?_ ?_ ?_ ?_ hz
  · intro y hy
    obtain ⟨j,hj,rfl⟩ := hy
    have hji : j ≠ i := by intro he; subst j; exact hi hj
    simp [b.repr_self, hji]
  · simp
  · intro x y hx hy ihx ihy
    simp [map_add, ihx, ihy]
  · intro a x hx ih
    simp [ih]

/-- Exact decomposition around a supported teacher row. -/
theorem row_cylinder_decomposition
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z v : Fin N → ℝ)
    (hv : ∀ i, i ∉ J → basisCoordinates b v i = 0) :
    z = v + selectedRow b J (z-v) + freeRow b J z := by
  have he : basisCoordinates b z = basisCoordinates b
      (v+selectedRow b J (z-v)+freeRow b J z) := by
    ext i
    simp only [basisCoordinates_add, basisCoordinates_selectedRow, basisCoordinates_sub,
      basisCoordinates_freeRow]
    by_cases hi : i ∈ J
    · simp [hi]
    · simp [hi, hv i hi]
  exact congrArg ofLp (b.repr.injective he)

/-- The residual row annihilates every supported teacher hidden state. -/
theorem freeRow_annihilates
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z h : Fin N → ℝ)
    (hh : ∀ i, i ∉ J → basisCoordinates b h i = 0) :
    (∑ i, freeRow b J z i*h i) = 0 := by
  rw [← basisCoordinates_inner b]
  apply Finset.sum_eq_zero
  intro i hi
  rw [basisCoordinates_freeRow]
  by_cases hJ : i ∈ J
  · simp [hJ]
  · simp [hJ, hh i hJ]

/-- A row constrained in `|J|` orthogonal coordinates pays exactly that dimension. -/
theorem selectedRow_energy_le
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) (η : ℝ) (hη : 0 ≤ η)
    (hz : ∀ i ∈ J, |basisCoordinates b z i| ≤ η) :
    (∑ i, selectedRow b J z i^2) ≤ (J.card:ℝ)*η^2 := by
  rw [← basisCoordinates_energy b]
  simp only [basisCoordinates_selectedRow]
  calc
    _ = ∑ i ∈ J, basisCoordinates b z i^2 := by simp
    _ ≤ ∑ _i ∈ J, η^2 := Finset.sum_le_sum fun i hi => by
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) hη).2 (hz i hi)
    _ = _ := by simp

/-- All row-projection errors together have a width-independent Frobenius bound
when the common internal variance satisfies `N σ² ≤ 1`. -/
theorem selected_matrix_energy_le
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (Z : Fin N → Fin N → ℝ) (ρ σ : ℝ)
    (hρ : 0 ≤ ρ) (hσ : 0 ≤ σ) (hscale : (N:ℝ)*σ^2 ≤ 1)
    (hz : ∀ i j, j ∈ J → |basisCoordinates b (Z i) j| ≤ ρ*σ) :
    (∑ i, ∑ j, selectedRow b J (Z i) j^2) ≤ ρ^2*J.card := by
  calc
    _ ≤ ∑ _ : Fin N, (J.card:ℝ)*(ρ*σ)^2 :=
      Finset.sum_le_sum fun i _ => selectedRow_energy_le b J (Z i) (ρ*σ)
        (mul_nonneg hρ hσ) (hz i)
    _ = ρ^2*(J.card:ℝ)*((N:ℝ)*σ^2) := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      ring
    _ ≤ _ := by
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hscale
        (by positivity : 0 ≤ ρ^2*(J.card:ℝ))

/-- Translate the actual Euclidean operator norm to the squared-coordinate API. -/
theorem matrixActionBound_of_operatorNorm (A : Fin N → Fin N → ℝ)
    (B : ℝ) (hB : 0 ≤ B)
    (hA : ‖coordinateMatrixOperator (fun ij => A ij.1 ij.2)‖ ≤ B) :
    matrixActionBound A B := by
  intro z
  have hh := (coordinateMatrixOperator (fun ij => A ij.1 ij.2)).le_opNorm (toLp 2 z)
  have hb := hh.trans (mul_le_mul_of_nonneg_right hA (norm_nonneg _))
  have hs := (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hB (norm_nonneg _))).2 hb
  simpa only [mul_pow, EuclideanSpace.real_norm_sq_eq, coordinateMatrixOperator,
    LinearMap.coe_toContinuousLinearMap', Matrix.toLpLin_apply, Matrix.mulVec,
    dotProduct] using hs

/-- The rectangular operator version in the same concrete coordinate convention. -/
theorem coordinateMatrix_action_squared_le {m n : Type*} [Fintype m] [Fintype n]
    (Z : m × n → ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hZ : ‖coordinateMatrixOperator Z‖ ≤ B) (z : n → ℝ) :
    (∑ i, (∑ j, Z (i,j)*z j)^2) ≤ B^2*∑ j,z j^2 := by
  have hh := (coordinateMatrixOperator Z).le_opNorm (toLp 2 z)
  have hb := hh.trans (mul_le_mul_of_nonneg_right hZ (norm_nonneg _))
  have hs := (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hB (norm_nonneg _))).2 hb
  simpa only [mul_pow, EuclideanSpace.real_norm_sq_eq, coordinateMatrixOperator,
    LinearMap.coe_toContinuousLinearMap', Matrix.toLpLin_apply, Matrix.mulVec,
    dotProduct] using hs

theorem basisCoordinates_as_sum
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (z : Fin N → ℝ) (i : Fin N) :
    basisCoordinates b z i = ∑ j, b i j*z j := by
  rw [basisCoordinates, b.repr_apply_apply]
  simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial]
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- Reconstruction from any subset of orthonormal coordinates, including an
empty complement or an empty collection of layers. -/
def basisReconstructRow {κ : Type*} [Fintype κ]
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (e : κ → Fin N) (z : κ → ℝ) : Fin N → ℝ :=
  fun j => ∑ a, z a*b (e a) j

theorem basisReconstructRow_action {κ : Type*} [Fintype κ]
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (e : κ → Fin N) (z : κ → ℝ) (h : Fin N → ℝ) :
    (∑ j, basisReconstructRow b e z j*h j) =
      ∑ a, z a*basisCoordinates b h (e a) := by
  simp only [basisReconstructRow, Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro a ha
  rw [basisCoordinates_as_sum, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem basisCoordinates_subset_energy_le {κ : Type*} [Fintype κ]
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (e : κ → Fin N) (he : Function.Injective e) (z : Fin N → ℝ) :
    (∑ a, basisCoordinates b z (e a)^2) ≤ ∑ j,z j^2 := by
  classical
  calc
    _ = ∑ j ∈ Finset.univ.image e, basisCoordinates b z j^2 := by
      rw [Finset.sum_image]
      intro a ha c hc hac
      exact he hac
    _ ≤ ∑ j, basisCoordinates b z j^2 :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun j hj hj' => sq_nonneg _
    _ = _ := basisCoordinates_energy b z

/-- A single norm bound for all stacked free coefficients bounds every actual
layer after orthogonal column reconstruction. -/
theorem reconstructed_stack_matrixActionBound {κ : Type*} [Fintype κ]
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (e : κ → Fin N) (he : Function.Injective e)
    (Z : (Fin r × Fin N) × κ → ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hZ : ‖coordinateMatrixOperator Z‖ ≤ B) (s : Fin r) :
    matrixActionBound
      (fun i => basisReconstructRow b e (fun a => Z ((s,i),a))) B := by
  intro z
  simp only [basisReconstructRow_action]
  calc
    _ ≤ ∑ si : Fin r × Fin N, (∑ a, Z (si,a)*basisCoordinates b z (e a))^2 := by
      rw [Fintype.sum_prod_type]
      exact Finset.single_le_sum
        (f := fun t : Fin r => ∑ i : Fin N,
          (∑ a, Z ((t,i),a)*basisCoordinates b z (e a))^2)
        (fun t ht => Finset.sum_nonneg fun i hi => sq_nonneg _)
        (Finset.mem_univ s)
    _ ≤ B^2*∑ a, basisCoordinates b z (e a)^2 :=
      coordinateMatrix_action_squared_le Z B hB hZ _
    _ ≤ _ := mul_le_mul_of_nonneg_left (basisCoordinates_subset_energy_le b e he z) (sq_nonneg B)

/-- The free-row definition agrees exactly with reconstruction from the
complement subtype, matching the independent Gaussian coordinate block. -/
theorem freeRow_eq_basisReconstructRow
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (z : Fin N → ℝ) :
    freeRow b J z = basisReconstructRow b
      (fun a : {j : Fin N // j ∉ J} => a.val)
      (fun a => basisCoordinates b z a.val) := by
  classical
  funext j
  have hr := congrArg (fun u : EuclideanSpace ℝ (Fin N) => u j)
    (b.sum_repr (toLp 2 (freeRow b J z)))
  simp only [WithLp.ofLp_sum, WithLp.ofLp_smul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul] at hr
  change (∑ a, basisCoordinates b (freeRow b J z) a*b a j) = freeRow b J z j at hr
  rw [← hr]
  simp only [basisCoordinates_freeRow]
  unfold basisReconstructRow
  rw [← Finset.sum_subtype Jᶜ (by simp : ∀ a : Fin N, a ∈ Jᶜ ↔ a ∉ J)
    (fun a => basisCoordinates b z a*b a j)]
  calc
    _ = ∑ a, if a ∈ Jᶜ then basisCoordinates b z a*b a j else 0 := by
      apply Finset.sum_congr rfl
      intro a ha
      by_cases hJ : a ∈ J <;> simp [hJ]
    _ = _ := by rw [Finset.sum_ite_mem, Finset.univ_inter]

/-- The complement-coordinate stack controls the exact free rows. -/
theorem freeRow_stack_matrixActionBound
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (Z : Fin r → Fin N → Fin N → ℝ)
    (B : ℝ) (hB : 0 ≤ B)
    (hZ : ‖coordinateMatrixOperator
      (fun p : (Fin r × Fin N) × {j : Fin N // j ∉ J} =>
        basisCoordinates b (Z p.1.1 p.1.2) p.2.val)‖ ≤ B) (s : Fin r) :
    matrixActionBound (fun i => freeRow b J (Z s i)) B := by
  simp_rw [freeRow_eq_basisReconstructRow]
  exact reconstructed_stack_matrixActionBound b
    (fun a : {j : Fin N // j ∉ J} => a.val) Subtype.val_injective _ B hB hZ s

/-- A direct containment theorem for the actual orthogonal-coordinate cylinder.
All geometric hypotheses are finite coordinate inequalities or exact teacher
support identities; the conclusion is the actual global margin event. -/
theorem margin_of_basis_cylinder {d : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (K G B σ : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hB : 0 ≤ B) (hσ : 0 ≤ σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hJ : (J.card:ℝ) ≤ G)
    (hmargin : v ∈ marginEvent φ (3/2) f) (hcost : weightedSquaredNorm v ≤ K)
    (hrows : ∀ s i j, j ∉ J →
      basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j = 0)
    (hhidden : ∀ (x : Cube d) (ss : List (Fin r)) j, j ∉ J →
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j = 0)
    (hfirst : ∀ i j, |w (Sum.inl (i,j))-v (Sum.inl (i,j))| ≤ cylinderRadius d r K G B)
    (hread : ∀ i, |w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))| ≤
      cylinderRadius d r K G B/N)
    (hproj : ∀ s i j, j ∈ J →
      |basisCoordinates b (fun a => w (Sum.inr (Sum.inl (s,i,a)))) j -
       basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j| ≤
        cylinderRadius d r K G B*σ)
    (hfree : ‖coordinateMatrixOperator
      (fun p : (Fin r × Fin N) × {j : Fin N // j ∉ J} =>
        basisCoordinates b (fun a => w (Sum.inr (Sum.inl (p.1.1,p.1.2,a)))) p.2.val)‖ ≤ B) :
    w ∈ marginEvent φ (1/2) f := by
  let R : Fin r → Fin N → Fin N → ℝ := fun s i =>
    selectedRow b J (fun a => w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
  let E : Fin r → Fin N → Fin N → ℝ := fun s i =>
    freeRow b J (fun a => w (Sum.inr (Sum.inl (s,i,a))))
  have hdecomp : ∀ s i j, w (Sum.inr (Sum.inl (s,i,j))) =
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j := by
    intro s i j
    exact congrFun (row_cylinder_decomposition b J
      (fun a => w (Sum.inr (Sum.inl (s,i,a))))
      (fun a => v (Sum.inr (Sum.inl (s,i,a)))) (hrows s i)) j
  have hR : ∀ s, (∑ i, ∑ j, R s i j^2) ≤ (cylinderRadius d r K G B)^2*G := by
    intro s
    have hh := selected_matrix_energy_le b J
      (fun i a => w (Sum.inr (Sum.inl (s,i,a)))-v (Sum.inr (Sum.inl (s,i,a))))
      (cylinderRadius d r K G B) σ (cylinderRadius_pos d r hK hG).le hσ hscale
      (fun i j hj => by
        change |basisCoordinates b
          ((fun a => w (Sum.inr (Sum.inl (s,i,a))))-
           (fun a => v (Sum.inr (Sum.inl (s,i,a))))) j| ≤ _
        rw [basisCoordinates_sub]
        exact hproj s i j hj)
    exact hh.trans (mul_le_mul_of_nonneg_left hJ (sq_nonneg _))
  have hE : ∀ s, matrixActionBound (E s) B :=
    freeRow_stack_matrixActionBound b J
      (fun s i a => w (Sum.inr (Sum.inl (s,i,a)))) B hB hfree
  have hkill : ∀ (x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑ j,E s i j*ss.foldl (hiddenStep φ v) (firstHidden φ v x) j) = 0 := by
    intro x ss s i
    exact freeRow_annihilates b J
      (fun a => w (Sum.inr (Sum.inl (s,i,a)))) _ (hhidden x ss)
  apply cylinder_margin_transfer φ f w v hmargin
  exact cylinder_networkOutput_error hN φ hφ w v R E K G B hK hG
    hdecomp hcost hR hE hfirst hread hkill

/-- All-width teacher existence in the exact coordinates used by the cylinder
probability calculation. No premise about an already adapted basis is needed. -/
theorem exists_adapted_cylinder_teacher {d C : ℕ}
    (φ : ℝ → ℝ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    ∃ (v : Weights d N r)
      (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
      (J : Finset (Fin N)),
      v ∈ marginEvent φ (3/2) f ∧
      weightedSquaredNorm v ≤ 18*((d:ℝ)*(d+1)*C^2+(r+1)*C^4) ∧
      J.card ≤ C+1 ∧
      (∀ s i j, j ∉ J →
        basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j = 0) ∧
      (∀ (x : Cube d) (ss : List (Fin r)) j, j ∉ J →
        basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j = 0) := by
  obtain ⟨v,S,hmargin,hcost,hdim,hhidden,hrows,_hread⟩ :=
    exists_supported_cylinder_teacher φ f hf hCN
  let e : (Fin N → ℝ) ≃ₗ[ℝ] EuclideanSpace ℝ (Fin N) :=
    (WithLp.linearEquiv 2 ℝ (Fin N → ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)) := S.map e.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩ := NeuralGeneralization.AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard : J.card ≤ C+1 := by
    rw [hJ]
    change Module.finrank ℝ (S.map e.toLinearMap) ≤ C+1
    rw [LinearEquiv.finrank_map_eq]
    exact hdim
  have hsupport (z : Fin N → ℝ) (hz : z ∈ S) :
      ∀ j, j ∉ J → basisCoordinates b z j = 0 := by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [← hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  exact ⟨v,b,J,hmargin,hcost,hcard,
    fun s i => hsupport _ (hrows s i),
    fun x ss => hsupport _ (hhidden x ss)⟩

end NeuralGeneralization.ConcreteModel
