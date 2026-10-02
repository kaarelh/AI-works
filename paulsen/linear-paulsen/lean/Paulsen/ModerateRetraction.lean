import Paulsen.ModerateSeedGraph
import Paulsen.HorizontalTaylor

/-! One actual Parseval retraction with all moderate seed estimates. -/

namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

theorem moderate_retraction_numerics {a t : ℝ} (ha : 0≤a) (ht : 0≤t)
    (htsmall : t^2≤1/(10^24:ℝ)) :
    t^2*(16384:ℝ)≤1/2 ∧ t^2≤1 ∧
    ((48*16384^2+2*16384:ℝ)*(600*a)*t^4)≤a*t^2/320000000 ∧
    (600*a)*((2*16384:ℝ)*|t|^3+(16384^2+16384)*t^4)≤10^12*a*t^3 := by
  have htone : t≤1 := by nlinarith [sq_nonneg t]
  have h₁ := mul_le_mul_of_nonneg_left htsmall (mul_nonneg ha (sq_nonneg t))
  have h₂ := mul_le_mul_of_nonneg_left htone (mul_nonneg ha (pow_nonneg ht 3))
  have hnn : 0≤a*t^2 := mul_nonneg ha (sq_nonneg t)
  rw [abs_of_nonneg ht]
  constructor
  · nlinarith only [htsmall]
  constructor
  · linarith only [htsmall]
  constructor
  · nlinarith only [h₁, hnn]
  · nlinarith only [h₂, mul_nonneg ha (pow_nonneg ht 3)]

theorem exists_moderate_retraction {n d : ℕ} [NeZero n]
    (U H : Frame n d) (hU : IsParseval U) (hUH : U.transpose*H=0)
    (hH : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖≤128)
    (hUrow : ∀ i, rowNormSq U i≤2*((d:ℝ)/(n:ℝ)))
    (hHrow : ∀ i, rowNormSq H i≤600*((d:ℝ)/(n:ℝ)))
    {t : ℝ} (ht : 0≤t) (htsmall : t^2≤1/(10^24:ℝ)) :
    ∃ (W : Frame n d) (r : Fin n → ℝ), IsParseval W ∧
      sqDistance U W≤20000*t^2*(d:ℝ) ∧
      (∀ i, rowNormSq (frameProjection W-frameProjection U-
        t • (H*U.transpose+U*H.transpose)) i≤((d:ℝ)/(n:ℝ))*t^2/320000000) ∧
      (∀ i, rowNormSq W i=rowNormSq U i+2*t*(H*U.transpose) i i+
        t^2*horizontalQuadraticDiagonal U H i+r i) ∧
      (∀ i, |r i|≤10^12*((d:ℝ)/(n:ℝ))*t^3) ∧
      (IsFullSpark (U+t • H) → IsFullSpark W) := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have ha : (0:ℝ)≤(d:ℝ)/(n:ℝ) := by positivity
  have hnum := moderate_retraction_numerics ha ht htsmall
  have hK : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖^2≤(16384:ℝ) := by
    nlinarith [norm_nonneg (Matrix.toEuclideanLin H).toContinuousLinearMap]
  obtain ⟨W,r,hW,hcost,hgram,htaylor,hremainder,_hcanonical,hspark⟩ :=
    exists_horizontal_polar_retraction_taylor_uniform U H t 16384 (600*((d:ℝ)/(n:ℝ)))
      hU hUH hK hnum.1 hnum.2.1 (fun i => (hUrow i).trans (by nlinarith only [ha])) hHrow
  have hsum : (∑ i, rowNormSq H i)≤600*(d:ℝ) := by
    calc
      _ ≤ ∑ _i : Fin n, 600*((d:ℝ)/(n:ℝ)) := Finset.sum_le_sum fun i _ => hHrow i
      _ = _ := by simp; field_simp
  have hc₁ := mul_le_mul_of_nonneg_left hsum (show (0:ℝ)≤2*t^2 by positivity)
  have hc₂ := mul_le_mul_of_nonneg_right hnum.1
    (show (0:ℝ)≤2*t^2*16384*(d:ℝ) by positivity)
  refine ⟨W,r,hW,?_,(fun i => (hgram i).trans hnum.2.2.1),htaylor,
    (fun i => (hremainder i).trans hnum.2.2.2),hspark⟩
  nlinarith only [hcost,hc₁,hc₂, mul_nonneg (sq_nonneg t) (Nat.cast_nonneg d)]

theorem moderate_retracted_graph_comparison {n d : ℕ}
    {U W : Frame n d} (hU : IsParseval U) (hW : IsParseval W)
    (Y : Frame n n) (hsym : ∀ i j, Y i j=Y j i) (t : ℝ)
    (hrow : ∀ i, rowNormSq (frameProjection W-frameProjection U-t • Y) i≤
      ((d:ℝ)/(n:ℝ))*t^2/320000000)
    (x : Fin n → ℝ)
    (hlow : (1/8)*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
      ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x)≤
      graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x)
    (hupp : graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x≤
      8000*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
        ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x)) :
    (1/32)*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
      ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x)≤
      matrixQuadratic (projectionLaplacian (frameProjection W)) x ∧
    matrixQuadratic (projectionLaplacian (frameProjection W)) x≤
      16001*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
        ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x) := by
  let A := frameProjection U+t • Y
  let β := ((d:ℝ)/(n:ℝ))*t^2/320000000
  have hsymA : ∀ i j, A i j=A j i := by
    intro i j
    simp only [A, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
      frameProjection_symm U i j, hsym i j]
  have herr (i : Fin n) : rowNormSq (A-frameProjection W) i≤β := by
    have he : rowNormSq (A-frameProjection W) i=
        rowNormSq (frameProjection W-frameProjection U-t • Y) i := by
      simp only [rowNormSq, A, Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [he]
    exact hrow i
  have hs := squared_graphEnergy_stability A (frameProjection W) β hsymA
    (frameProjection_symm W) herr x
  have he : graphEnergy (fun i j => (frameProjection W i j)^2) x=
      matrixQuadratic (projectionLaplacian (frameProjection W)) x := (hW.laplacian_energy x).symm
  rw [he] at hs
  obtain ⟨hsl,hsu⟩ := hs
  have hL : 0≤matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hU.laplacian_energy]
    exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ =>
      Finset.sum_nonneg fun j _ => mul_nonneg (sq_nonneg _) (sq_nonneg _))
  have hN : 0≤((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x :=
    mul_nonneg (by positivity) (vectorNormSq_nonneg x)
  change (1/2)*graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x-
      2*β*vectorNormSq x≤_ at hsl
  change _≤2*graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x+
      4*β*vectorNormSq x at hsu
  dsimp only [β] at hsl hsu
  constructor <;> nlinarith only [hsl,hsu,hlow,hupp,hL,hN]

theorem moderate_retracted_graph_upper {n d : ℕ}
    {U W : Frame n d} (hU : IsParseval U) (hW : IsParseval W)
    (Y : Frame n n) (hsym : ∀ i j, Y i j=Y j i) (t : ℝ)
    (hrow : ∀ i, rowNormSq (frameProjection W-frameProjection U-t • Y) i≤
      ((d:ℝ)/(n:ℝ))*t^2/320000000)
    (hYrow : ∀ i, rowNormSq Y i≤2000*((d:ℝ)/(n:ℝ))) (x : Fin n → ℝ) :
    matrixQuadratic (projectionLaplacian (frameProjection W)) x≤
      16001*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
        ((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x) := by
  let A := frameProjection U+t • Y
  let β := ((d:ℝ)/(n:ℝ))*t^2/320000000
  have hsymA : ∀ i j, A i j=A j i := by
    intro i j
    simp only [A, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
      frameProjection_symm U i j, hsym i j]
  have herr (i : Fin n) : rowNormSq (A-frameProjection W) i≤β := by
    have he : rowNormSq (A-frameProjection W) i=
        rowNormSq (frameProjection W-frameProjection U-t • Y) i := by
      simp only [rowNormSq, A, Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
      apply Finset.sum_congr rfl
      intro j _
      ring
    rw [he]
    exact hrow i
  have hs := (squared_graphEnergy_stability A (frameProjection W) β hsymA
    (frameProjection_symm W) herr x).2
  have he : graphEnergy (fun i j => (frameProjection W i j)^2) x=
      matrixQuadratic (projectionLaplacian (frameProjection W)) x := (hW.laplacian_energy x).symm
  rw [he] at hs
  change _≤2*graphEnergy (fun i j => (frameProjection U i j+t*Y i j)^2) x+
      4*β*vectorNormSq x at hs
  have hupp := moderate_affine_seed_graph_upper hU Y hsym hYrow t x
  have hL : 0≤matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [hU.laplacian_energy]
    exact mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ =>
      Finset.sum_nonneg fun j _ => mul_nonneg (sq_nonneg _) (sq_nonneg _))
  have hN : 0≤((d:ℝ)/(n:ℝ))*t^2*vectorNormSq x :=
    mul_nonneg (by positivity) (vectorNormSq_nonneg x)
  dsimp only [β] at hs
  nlinarith only [hs,hupp,hL,hN]

theorem rowNormSq_sub_le_sqDistance {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    rowNormSq (A-B) i≤sqDistance A B := by
  exact Finset.single_le_sum
    (fun j _ => Finset.sum_nonneg fun k _ => sq_nonneg (A j k-B j k)) (Finset.mem_univ i)

/-- The initial 95% dense rows remain 80% dense through retraction and the
restricted correction. A total projection movement bound suffices, so no
new exceptional rows are introduced. -/
theorem moderate_dense_core_after_correction {n d : ℕ} [NeZero n]
    (hd : 0<d) (U W V : Frame n d) (Y : Frame n n) {t : ℝ} (ht : 0<t)
    (B : Finset (Fin n))
    (hseed : ∀ i∉B, 19*n≤20*(largeNeighbors
      (fun i j => (frameProjection U i j+t*Y i j)^2)
      (t^2*((d:ℝ)/(n:ℝ))/1000000) i).card)
    (hrow : ∀ i, rowNormSq (frameProjection W-frameProjection U-t • Y) i≤
      ((d:ℝ)/(n:ℝ))*t^2/320000000)
    (hmove : sqDistance (frameProjection W) (frameProjection V)≤
      ((d:ℝ)/(n:ℝ))*t^2/320000000) :
    ∀ i∉B, 4*n≤5*(largeNeighbors (fun i j => (frameProjection V i j)^2)
      (((d:ℝ)/(n:ℝ))*t^2/16000000) i).card := by
  have hn : (0:ℝ)<n := Nat.cast_pos.mpr (NeZero.pos n)
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  let A := frameProjection U+t • Y
  have hsymmrow (i : Fin n) : rowNormSq (A-frameProjection W) i=
      rowNormSq (frameProjection W-frameProjection U-t • Y) i := by
    simp only [rowNormSq, A, Matrix.sub_apply, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
    apply Finset.sum_congr rfl
    intro j _
    ring
  have hτ : (0:ℝ)<((d:ℝ)/(n:ℝ))*t^2/4000000 := by positivity
  have hfour : 4*(((d:ℝ)/(n:ℝ))*t^2/4000000)=t^2*((d:ℝ)/(n:ℝ))/1000000 := by ring
  intro i hi
  have hninety : 9*n≤10*(largeNeighbors (fun i j => (frameProjection W i j)^2)
      (((d:ℝ)/(n:ℝ))*t^2/4000000) i).card := by
    apply dense_neighbors_ninetyfive_to_ninety A (frameProjection W) hτ i
    · simpa only [hfour, A, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul] using hseed i hi
    · rw [hsymmrow]
      have hh := hrow i
      have hnonneg : (0:ℝ)≤((d:ℝ)/(n:ℝ))*t^2 := by positivity
      nlinarith only [hh,hnonneg]
  have hfour' : 4*(((d:ℝ)/(n:ℝ))*t^2/16000000)=((d:ℝ)/(n:ℝ))*t^2/4000000 := by ring
  have hγ : (0:ℝ)<((d:ℝ)/(n:ℝ))*t^2/16000000 := by positivity
  have hdense : 17*Fintype.card (Fin n)≤20*(largeNeighbors
      (fun i j => (frameProjection W i j)^2) (4*(((d:ℝ)/(n:ℝ))*t^2/16000000)) i).card := by
    rw [hfour']
    simp only [Fintype.card_fin]
    omega
  have he : (∑ j, (frameProjection W i j-frameProjection V i j)^2)≤
      (((d:ℝ)/(n:ℝ))*t^2/16000000)/20 := by
    have hh := (rowNormSq_sub_le_sqDistance (frameProjection W) (frameProjection V) i).trans hmove
    have hden : ((d:ℝ)/(n:ℝ))*t^2/320000000=
      (((d:ℝ)/(n:ℝ))*t^2/16000000)/20 := by ring
    rw [hden] at hh
    exact hh
  simpa only [Fintype.card_fin] using
    dense_neighbors_survive_perturbation (frameProjection W) (frameProjection V)
      (((d:ℝ)/(n:ℝ))*t^2/16000000) hγ i hdense he

end
end Paulsen
