import NeuralGeneralization.OnlineLowerTanhCodeColumnMoment

/-! # Uniform Laplace bound for the square root of a rail product -/

noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- A common moment upper bound simplifies weighted finite Hölder. -/
theorem weighted_holder_common_bound
    {α ι : Type*} [MeasurableSpace α] [Fintype ι]
    (μ : Measure α) (hn : 0<Fintype.card ι)
    (w : α→ℝ) (hw : ∀ x,0≤w x) (hwm : AEStronglyMeasurable w μ)
    (f : ι→α→ℝ) (hf : ∀ i x,0≤f i x)
    (hfm : ∀ i,AEStronglyMeasurable (f i) μ)
    (hfi : ∀ i,Integrable (fun x => w x*f i x^Fintype.card ι) μ)
    (M : ℝ) (hM : 0≤M)
    (hbound : ∀ i,(∫ x,w x*f i x^Fintype.card ι ∂μ)≤M) :
    Integrable (fun x => w x*∏ i,f i x) μ ∧
      (∫ x,w x*∏ i,f i x ∂μ) ≤ M := by
  have hh := weighted_holder_product μ hn w hw hwm f hf hfm hfi
  refine ⟨hh.1,hh.2.trans ?_⟩
  have hn0 : (Fintype.card ι:ℝ) ≠ 0 := by positivity
  calc
    _ ≤ ∏ _i : ι,M^(1/(Fintype.card ι:ℝ)) := Finset.prod_le_prod
      (fun _ _ => Real.rpow_nonneg (integral_nonneg fun x => mul_nonneg (hw x) (pow_nonneg (hf _ x) _)) _)
      (fun i _ => Real.rpow_le_rpow (integral_nonneg fun x => mul_nonneg (hw x) (pow_nonneg (hf _ x) _))
        (hbound i) (by positivity))
    _ = M := by
      simp only [Finset.prod_const,Finset.card_univ]
      rw [←Real.rpow_mul_natCast hM,one_div_mul_cancel hn0,Real.rpow_one]

def trimmedRailProduct (p R : ℕ) (a b : Fin p→Fin R→ℝ) (t : ℝ) : ℝ :=
  ∏ i, ((∏ k,|Real.sin (a i k*t)| *|Real.cos (b i k*t)|)+
    (∏ k,|Real.cos (a i k*t)| *|Real.sin (b i k*t)|))

theorem trimmedRailProduct_nonneg (p R : ℕ) (a b : Fin p→Fin R→ℝ) (t : ℝ) :
    0≤trimmedRailProduct p R a b t := by
  unfold trimmedRailProduct
  positivity

theorem sqrt_trimmedRailProduct_zip (p R : ℕ) (hR : 0<R)
    (a b : Fin p→Fin R→ℝ) (t : ℝ) :
    Real.sqrt (trimmedRailProduct p R a b t) ≤
      ∏ j : Fin p × Fin R,(columnPair R (a j.1 j.2) (b j.1 j.2) t)^(1/(2*(R:ℝ))) := by
  have hz := all_pairs_zip p R hR a b t
  have hs := Real.sqrt_le_sqrt hz
  simp only [Real.sqrt_eq_rpow] at hs ⊢
  rw [← Real.finsetProd_rpow Finset.univ _ (fun i _ => Finset.prod_nonneg fun k _ =>
      Real.rpow_nonneg (columnPair_nonneg R (a i k) (b i k) t) _) (1/(2:ℝ))] at hs
  have he (i : Fin p) :
      (∏ k,columnPair R (a i k) (b i k) t ^ (1/(R:ℝ))) ^ (1/(2:ℝ)) =
        ∏ k,columnPair R (a i k) (b i k) t ^ (1/(2*(R:ℝ))) := by
    rw [← Real.finsetProd_rpow Finset.univ _ (fun k _ => Real.rpow_nonneg (columnPair_nonneg _ _ _ _) _) (1/(2:ℝ))]
    apply Finset.prod_congr rfl
    intro k _
    rw [←Real.rpow_mul (columnPair_nonneg _ _ _ _)]
    congr 1
    ring
  simp only [he] at hs
  simpa only [trimmedRailProduct,Fintype.prod_prod_type] using hs


/-- A frequency-uniform bound for the square root of the entire rail product.
There is no boundedness hypothesis on any individual incoming coefficient. -/
theorem sqrt_trimmedRailProduct_laplace (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (a b : Fin p→Fin (2*r)→ℝ) (c : ℝ) (hc : 0<c) :
    IntegrableOn (fun t => Real.exp (-c*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t)) (Ioi 0) ∧
    Real.sqrt ((p*r:ℕ):ℝ)*(∫ t : ℝ in Ioi 0,
      Real.exp (-c*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t)) ≤ Real.pi/c := by
  let g : (Fin p × Fin (2*r))→ℝ→ℝ := fun j t =>
    (columnPair (2*r) (a j.1 j.2) (b j.1 j.2) t)^(1/(2*((2*r:ℕ):ℝ)))
  have hn : 0<Fintype.card (Fin p × Fin (2*r)) := by simp; omega
  have hg (j : Fin p × Fin (2*r)) (t : ℝ) : 0≤g j t :=
    Real.rpow_nonneg (columnPair_nonneg _ _ _ _) _
  have hgpow (j : Fin p × Fin (2*r)) (t : ℝ) :
      (g j t)^Fintype.card (Fin p × Fin (2*r)) =
        (columnPair (2*r) (a j.1 j.2) (b j.1 j.2) t)^((p:ℝ)/2) := by
    dsimp [g]
    rw [←Real.rpow_mul_natCast (columnPair_nonneg _ _ _ _)]
    congr 1
    simp only [Fintype.card_prod,Fintype.card_fin,Nat.cast_mul,Nat.cast_ofNat]
    have hr0 : (r:ℝ)≠0 := by positivity
    field_simp
    <;> ring
  have hgm (j : Fin p × Fin (2*r)) :
      AEStronglyMeasurable (g j) (volume.restrict (Ioi 0)) := by
    apply Measurable.aestronglyMeasurable
    dsimp [g,columnPair]
    fun_prop
  have hgi (j : Fin p × Fin (2*r)) :
      IntegrableOn (fun t => Real.exp (-c*t)*g j t^Fintype.card (Fin p × Fin (2*r))) (Ioi 0) := by
    simpa only [hgpow] using columnPair_half_laplace_integrable p r hp hr (a j.1 j.2) (b j.1 j.2) c hc
  have hsqrt : 0<Real.sqrt ((p*r:ℕ):ℝ) := by positivity
  let M : ℝ := (Real.pi/c)/Real.sqrt ((p*r:ℕ):ℝ)
  have hM : 0≤M := by dsimp [M]; positivity
  have hb (j : Fin p × Fin (2*r)) :
      (∫ t : ℝ in Ioi 0,Real.exp (-c*t)*g j t^Fintype.card (Fin p × Fin (2*r))) ≤ M := by
    dsimp [M]
    rw [le_div_iff₀ hsqrt]
    simp only [hgpow]
    simpa only [mul_comm] using columnPair_half_laplace_bound p r hp hr (a j.1 j.2) (b j.1 j.2) c hc
  have hh := weighted_holder_common_bound (volume.restrict (Ioi 0)) hn
    (fun t => Real.exp (-c*t)) (fun _ => (Real.exp_pos _).le)
    (by fun_prop) g hg hgm hgi M hM hb
  have hzip (t : ℝ) : Real.exp (-c*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t) ≤
      Real.exp (-c*t)*∏ j,g j t := by
    exact mul_le_mul_of_nonneg_left (sqrt_trimmedRailProduct_zip p (2*r) (by omega) a b t)
      (Real.exp_pos _).le
  have hi : IntegrableOn (fun t => Real.exp (-c*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t)) (Ioi 0) := by
    apply hh.1.mono'
    · apply Measurable.aestronglyMeasurable
      dsimp [trimmedRailProduct]
      fun_prop
    · exact Filter.Eventually.of_forall fun t => by
        rw [Real.norm_eq_abs,abs_of_nonneg (by positivity)]
        exact hzip t
  refine ⟨hi,?_⟩
  have hm := (integral_mono hi hh.1 hzip).trans hh.2
  have hmm := mul_le_mul_of_nonneg_left hm hsqrt.le
  dsimp [M] at hmm
  have he : Real.sqrt ((p*r:ℕ):ℝ)*((Real.pi/c)/Real.sqrt ((p*r:ℕ):ℝ)) = Real.pi/c := by
    field_simp
  simpa only [he] using hmm

end NeuralGeneralization.OnlineLowerTanh
