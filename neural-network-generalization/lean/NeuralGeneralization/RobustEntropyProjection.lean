import NeuralGeneralization.RobustEntropyQueries
import NeuralGeneralization.RobustGaussianGeometry

/-! # Exact entropy increments for orthogonal Gaussian queries -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal RealInnerProductSpace BigOperators

namespace NeuralGeneralization.RobustEntropy

theorem klDiv_map_eq_of_mutual_factorization
    {Ω X Y : Type*} [MeasurableSpace Ω] [MeasurableSpace X] [MeasurableSpace Y]
    [StandardBorelSpace X] [StandardBorelSpace Y] [Nonempty X] [Nonempty Y]
    (P Q : Measure Ω) [IsFiniteMeasure P] [IsFiniteMeasure Q]
    (F : Ω → X) (G : Ω → Y) (hF : Measurable F) (hG : Measurable G)
    (a : X → Y) (b : Y → X) (ha : Measurable a) (hb : Measurable b)
    (hFG : a ∘ F = G) (hGF : b ∘ G = F) :
    klDiv (P.map F) (Q.map F) = klDiv (P.map G) (Q.map G) := by
  apply le_antisymm
  · have h := klDiv_map_le (P.map G) (Q.map G) hb
    rwa [Measure.map_map hb hG, Measure.map_map hb hG, hGF] at h
  · have h := klDiv_map_le (P.map F) (Q.map F) ha
    rwa [Measure.map_map ha hF, Measure.map_map ha hF, hFG] at h

variable {N : ℕ}
local notation "E" => EuclideanSpace ℝ (Fin N)

theorem projection_sup_unit (K : Submodule ℝ E) (v : E)
    (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) (z : E) :
    (K ⊔ Submodule.span ℝ {v}).starProjection z =
      K.starProjection z + ⟪v,z⟫ • v := by
  apply Submodule.eq_starProjection_of_mem_of_inner_eq_zero
  · exact Submodule.add_mem_sup (K.starProjection_apply_mem z)
      (Submodule.smul_mem _ _ (Submodule.subset_span (by simp)))
  · intro w hw
    obtain ⟨a,ha,b,hb,rfl⟩ := Submodule.mem_sup.mp hw
    obtain ⟨t,rfl⟩ := Submodule.mem_span_singleton.mp hb
    have hva : ⟪v,a⟫ = 0 := Submodule.inner_left_of_mem_orthogonal ha hv
    have hKv : ⟪K.starProjection z,v⟫ = 0 :=
      Submodule.inner_right_of_mem_orthogonal (K.starProjection_apply_mem z) hv
    have hKa := K.starProjection_inner_eq_zero z a ha
    have hvv : ⟪v,v⟫ = 1 := by rw [real_inner_self_eq_norm_sq, hn]; norm_num
    simp only [inner_add_right, inner_smul_right, inner_sub_left, inner_add_left,
      inner_smul_left, RCLike.conj_to_real, hva, hKv, hvv, mul_zero, add_zero,
      mul_one, sub_zero]
    rw [real_inner_comm z v]
    simp only [inner_sub_left] at hKa
    nlinarith

theorem projection_sup_observation (K : Submodule ℝ E) (v : E)
    (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) (z : E) :
    (K.starProjection ((K ⊔ Submodule.span ℝ {v}).starProjection z),
      ⟪v,(K ⊔ Submodule.span ℝ {v}).starProjection z⟫) =
      (K.starProjection z,⟪v,z⟫) := by
  apply Prod.ext
  · exact congrArg (fun T : E →L[ℝ] E => T z)
      (Submodule.starProjection_comp_starProjection_of_le (show K ≤ K ⊔ Submodule.span ℝ {v} from le_sup_left))
  · change ⟪v,(K ⊔ Submodule.span ℝ {v}).starProjection z⟫ = ⟪v,z⟫
    rw [← (K ⊔ Submodule.span ℝ {v}).inner_starProjection_left_eq_right,
      (K ⊔ Submodule.span ℝ {v}).starProjection_eq_self_iff.mpr
        (Submodule.mem_sup_right (Submodule.subset_span (by simp)))]

/-- A new orthogonal unit direction is exactly a new independent Gaussian
coordinate under the reference law. -/
theorem projection_query_gaussian_law (K : Submodule ℝ E) (v : E)
    (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) :
    (GaussianOrthogonal.euclideanGaussian (ι := Fin N) 1).map
      (fun z => (K.starProjection z,⟪v,z⟫)) =
      ((GaussianOrthogonal.euclideanGaussian (ι := Fin N) 1).map K.starProjection).prod
        (gaussianReal 0 1) := by
  have hi := (GaussianResidualIndependence.orthogonal_projections_independent K).comp
    measurable_id (innerSL ℝ v).continuous.measurable
  have he : (fun z => ⟪v,z⟫) ∘ Kᗮ.starProjection = (fun z => ⟪v,z⟫) := by
    funext z
    dsimp
    rw [← Kᗮ.inner_starProjection_left_eq_right, Kᗮ.starProjection_eq_self_iff.mpr hv]
  change IndepFun (id ∘ K.starProjection)
    ((fun z => ⟪v,z⟫) ∘ Kᗮ.starProjection) _ at hi
  simp only [Function.id_comp, he] at hi
  rw [hi.map_prod_eq_prod_map_map K.starProjection.continuous.measurable.aemeasurable
    (by fun_prop), GaussianResidualIndependence.map_inner_eq_gaussian, hn]
  norm_num

/-- The full projection onto the enlarged active span and the pair consisting
of the old projection and new coordinate contain exactly the same information. -/
theorem klDiv_projection_sup_eq_pair (P Q : Measure E)
    [IsFiniteMeasure P] [IsFiniteMeasure Q]
    (K : Submodule ℝ E) (v : E) (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) :
    klDiv (P.map (K ⊔ Submodule.span ℝ {v}).starProjection)
      (Q.map (K ⊔ Submodule.span ℝ {v}).starProjection) =
    klDiv (P.map (fun z => (K.starProjection z,⟪v,z⟫)))
      (Q.map (fun z => (K.starProjection z,⟪v,z⟫))) := by
  apply klDiv_map_eq_of_mutual_factorization P Q _ _ (by fun_prop) (by fun_prop)
    (fun z => (K.starProjection z,⟪v,z⟫))
    (fun p : E × ℝ => p.1+p.2 • v) (by fun_prop) (by fun_prop)
  · funext z
    exact projection_sup_observation K v hv hn z
  · funext z
    exact (projection_sup_unit K v hv hn z).symm

def rowProjection (R : ℕ) (K : Submodule ℝ E) :
    (Fin R → E) → (Fin R → E) := fun g i => K.starProjection (g i)

def rowQuery (R : ℕ) (K : Submodule ℝ E) (v : E) :
    (Fin R → E) → (Fin R → E) × (Fin R → ℝ) :=
  fun g => (rowProjection R K g, fun i => ⟪v,g i⟫)

@[fun_prop] theorem measurable_rowProjection (R : ℕ) (K : Submodule ℝ E) :
    Measurable (rowProjection R K) := by unfold rowProjection; fun_prop

@[fun_prop] theorem measurable_rowQuery (R : ℕ) (K : Submodule ℝ E) (v : E) :
    Measurable (rowQuery R K v) := by unfold rowQuery; fun_prop

def rowGaussian (R N : ℕ) : Measure (Fin R → EuclideanSpace ℝ (Fin N)) :=
  Measure.pi fun _ => GaussianOrthogonal.euclideanGaussian 1

instance rowGaussian_probability (R N : ℕ) : IsProbabilityMeasure (rowGaussian R N) := by
  unfold rowGaussian
  infer_instance

theorem rowGaussian_map_projection (R : ℕ) (K : Submodule ℝ E) :
    (rowGaussian R N).map (rowProjection R K) =
      Measure.pi fun _ : Fin R =>
        (GaussianOrthogonal.euclideanGaussian (ι := Fin N) 1).map K.starProjection := by
  exact Measure.pi_map_pi (fun _ => K.starProjection.continuous.measurable.aemeasurable)

theorem rowGaussian_query_law (R : ℕ) (K : Submodule ℝ E) (v : E)
    (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) :
    (rowGaussian R N).map (rowQuery R K v) =
      ((rowGaussian R N).map (rowProjection R K)).prod
        (Measure.pi fun _ : Fin R => gaussianReal 0 1) := by
  let G := GaussianOrthogonal.euclideanGaussian (ι := Fin N) 1
  let F : E → E × ℝ := fun z => (K.starProjection z,⟪v,z⟫)
  have hF : Measurable F := by fun_prop
  letI : IsProbabilityMeasure (G.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  letI : IsProbabilityMeasure (G.map K.starProjection) :=
    Measure.isProbabilityMeasure_map K.starProjection.continuous.measurable.aemeasurable
  let e := MeasurableEquiv.arrowProdEquivProdArrow E ℝ (Fin R)
  have he : rowQuery R K v = e ∘ (fun g i => F (g i)) := rfl
  rw [he, ← Measure.map_map e.measurable (by fun_prop),
    rowGaussian_map_projection]
  unfold rowGaussian
  rw [Measure.pi_map_pi (fun _ => hF.aemeasurable)]
  have hrow : G.map F = (G.map K.starProjection).prod (gaussianReal 0 1) :=
    projection_query_gaussian_law K v hv hn
  change (Measure.pi (fun _ : Fin R => G.map F)).map e = _
  simp_rw [hrow]
  exact (measurePreserving_arrowProdEquivProdArrow E ℝ (Fin R)
    (fun _ => G.map K.starProjection) (fun _ => gaussianReal 0 1)).map_eq

theorem klDiv_row_projection_sup_eq_pair (R : ℕ)
    (P Q : Measure (Fin R → E)) [IsFiniteMeasure P] [IsFiniteMeasure Q]
    (K : Submodule ℝ E) (v : E) (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1) :
    klDiv (P.map (rowProjection R (K ⊔ Submodule.span ℝ {v})))
      (Q.map (rowProjection R (K ⊔ Submodule.span ℝ {v}))) =
    klDiv (P.map (rowQuery R K v)) (Q.map (rowQuery R K v)) := by
  apply klDiv_map_eq_of_mutual_factorization P Q _ _ (by fun_prop) (by fun_prop)
    (rowQuery R K v) (fun p : (Fin R → E) × (Fin R → ℝ) => fun i => p.1 i+p.2 i • v)
    (by fun_prop) (by fun_prop)
  · funext z
    apply Prod.ext
    · funext i
      exact congrArg Prod.fst (projection_sup_observation K v hv hn (z i))
    · funext i
      exact congrArg Prod.snd (projection_sup_observation K v hv hn (z i))
  · funext z i
    exact (projection_sup_unit K v hv hn (z i)).symm

/-- The precise averaged conditional KL left after an active Gaussian query.
Its bound is the actual difference of projected entropies, not an assumed
Gaussian-conditioning estimate. -/
theorem row_query_conditional_cost (R : ℕ) (Q : Measure (Fin R → E))
    [IsProbabilityMeasure Q] (hfin : klDiv Q (rowGaussian R N) ≠ ∞)
    (K : Submodule ℝ E) (v : E) (hv : v ∈ Kᗮ) (hn : ‖v‖ = 1)
    (δ : ℝ)
    (hinc :
      (klDiv (Q.map (rowProjection R (K ⊔ Submodule.span ℝ {v})))
        ((rowGaussian R N).map (rowProjection R (K ⊔ Submodule.span ℝ {v})))).toReal -
      (klDiv (Q.map (rowProjection R K))
        ((rowGaussian R N).map (rowProjection R K))).toReal ≤ δ) :
    klDiv (Q.map (rowQuery R K v))
      ((Q.map (rowProjection R K)).prod (Measure.pi fun _ : Fin R => gaussianReal 0 1))
      ≤ ENNReal.ofReal δ := by
  let ρ := Q.map (rowQuery R K v)
  let ν := (rowGaussian R N).map (rowProjection R K)
  let G : Measure (Fin R → ℝ) := Measure.pi fun _ => gaussianReal 0 1
  have hρfst : ρ.fst = Q.map (rowProjection R K) := by
    exact Measure.fst_map_prodMk (by fun_prop)
  have hreff : (rowGaussian R N).map (rowQuery R K v) = ν.prod G :=
    rowGaussian_query_law R K v hv hn
  have hfinρ : klDiv ρ (ν.prod G) ≠ ∞ := by
    rw [← hreff]
    exact ne_top_of_le_ne_top hfin (klDiv_map_le Q (rowGaussian R N) (by fun_prop))
  have hinc' : (klDiv ρ (ν.prod G)).toReal - (klDiv ρ.fst ν).toReal ≤ δ := by
    rw [hρfst, ← hreff]
    rwa [klDiv_row_projection_sup_eq_pair R Q (rowGaussian R N) K v hv hn] at hinc
  have hh := conditional_cost_le_of_increment ρ ν G hfinρ δ hinc'
  rwa [hρfst] at hh

end NeuralGeneralization.RobustEntropy
