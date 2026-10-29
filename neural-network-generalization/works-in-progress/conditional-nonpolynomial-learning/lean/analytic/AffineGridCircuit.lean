import ParallelGridCircuits

/-! A genuine constant-depth grid circuit for arbitrary real affine maps.
Offsets are in the fixed scalar lookup table, not an assumed arithmetic oracle. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ : Type*} [Fintype ι] [Fintype κ]

def affineRealMap (c : κ→ι→ℝ) (b : κ→ℝ) (x : EuclideanSpace ℝ ι) :
    EuclideanSpace ℝ κ := WithLp.toLp 2 (fun j=>b j+∑i,c j i*x i)

def affineGridCircuit (c : κ→ι→ℝ) (b : κ→ℝ) (Q Ni No : ℕ) :=
  quantizedLayer (fun j i=>c ((Fintype.equivFin κ).symm j) ((Fintype.equivFin ι).symm i))
    (fun j s=>b ((Fintype.equivFin κ).symm j)+s) Q Ni No

def affineGridUpdate (c : κ→ι→ℝ) (b : κ→ℝ) (Q Ni No : ℕ)
    (a : ι→ScalarCode Q Ni) : κ→ScalarCode Q No :=
  fun j=>scalarEncode Q No (b j+∑i,gridRound Q (c j i)*scalarDecode Q Ni (a i))

@[simp] theorem affineGridCircuit_eval (c : κ→ι→ℝ) (b : κ→ℝ) (Q Ni No : ℕ)
    (a : ι→ScalarCode Q Ni) :
    (affineGridCircuit c b Q Ni No).eval (encodeCoordinateState Q Ni a)=
      encodeCoordinateState Q No (affineGridUpdate c b Q Ni No a) := by
  rw [affineGridCircuit,encodeCoordinateState,quantizedLayer_eval]
  congr 1
  funext j
  simp only [quantizedUpdate,coordinateCodes,affineGridUpdate]
  rw [sum_equivFin_symm (fun i=>gridRound Q (c ((Fintype.equivFin κ).symm j) i)*scalarDecode Q Ni (a i))]

theorem affineGridCircuit_depth (c : κ→ι→ℝ) (b : κ→ℝ) (Q Ni No : ℕ) :
    (affineGridCircuit c b Q Ni No).depth≤5 := quantizedLayer_depth _ _ _ _ _

theorem affineGridCircuit_size (c : κ→ι→ℝ) (b : κ→ℝ) (Q B Ni No : ℕ)
    (hc : ∀j i,|c j i|≤(B:ℝ)) :
    (affineGridCircuit c b Q Ni No).size≤
      arithmeticLayerSize (Fintype.card ι) (Fintype.card κ) Q B Ni No :=
  quantizedLayer_size _ _ _ _ _ _ (fun j i=>hc _ _)

theorem affineGridCircuit_approximates (c : κ→ι→ℝ) (b : κ→ℝ) (Q B Ni No : ℕ)
    (hQ : 0<Q) (hc : ∀j i,|c j i|≤(B:ℝ)) (hb : ∀j,|b j|≤(B:ℝ))
    (hNo : B+Fintype.card ι*(B+1)*(Ni+1)≤No) :
    GridApproximates Q Ni Q No (affineRealMap c b) (affineGridCircuit c b Q Ni No)
      (((Fintype.card κ:ℝ)+1)*(((Fintype.card ι:ℝ)*((Ni:ℝ)+1)+1)/(2*(Q:ℝ)))) := by
  intro a
  refine ⟨affineGridUpdate c b Q Ni No a,affineGridCircuit_eval _ _ _ _ _ _,?_⟩
  apply euclidean_norm_of_coordinate_bounds _ (by positivity)
  intro j
  let z:=b j+∑i,gridRound Q (c j i)*scalarDecode Q Ni (a i)
  have hrange : |z|≤(No:ℝ) := by
    have hs : |∑i,gridRound Q (c j i)*scalarDecode Q Ni (a i)|≤
        (Fintype.card ι:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1) := by
      calc
        _ ≤ ∑i,|gridRound Q (c j i)*scalarDecode Q Ni (a i)| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑_i:ι,((B:ℝ)+1)*((Ni:ℝ)+1) := Finset.sum_le_sum fun i _=>by
          rw [abs_mul]
          exact mul_le_mul (gridRound_range Q B hQ _ (hc j i)) (scalarDecode_bound Q Ni hQ _) (abs_nonneg _) (by positivity)
        _ = _ := by simp;ring
    have hn : (B:ℝ)+(Fintype.card ι:ℝ)*((B:ℝ)+1)*((Ni:ℝ)+1)≤No := by exact_mod_cast hNo
    exact (abs_add_le _ _).trans ((add_le_add (hb j) hs).trans hn)
  have hround := scalarEncode_error Q No hQ z hrange
  have hcoeff : |(b j+∑i,c j i*scalarDecode Q Ni (a i))-z|≤
      (Fintype.card ι:ℝ)*(((Ni:ℝ)+1)/(2*(Q:ℝ))) := by
    have he : (b j+∑i,c j i*scalarDecode Q Ni (a i))-z=
        ∑i,(c j i-gridRound Q (c j i))*scalarDecode Q Ni (a i) := by
      dsimp [z]
      simp only [sub_mul,Finset.sum_sub_distrib]
      ring
    rw [he]
    calc
      _ ≤ ∑i,|(c j i-gridRound Q (c j i))*scalarDecode Q Ni (a i)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑_i:ι,((Ni:ℝ)+1)/(2*(Q:ℝ)) := Finset.sum_le_sum fun i _=>by
        rw [abs_mul]
        have hh:=mul_le_mul (gridRound_error Q hQ (c j i)) (scalarDecode_bound Q Ni hQ (a i))
          (abs_nonneg (scalarDecode Q Ni (a i))) (by positivity : 0≤1/(2*(Q:ℝ)))
        convert hh using 1 <;> ring
      _ = _ := by simp
  have ht:=abs_sub_le (b j+∑i,c j i*scalarDecode Q Ni (a i)) z
    (scalarDecode Q No (scalarEncode Q No z))
  change |(b j+∑i,c j i*scalarDecode Q Ni (a i))-scalarDecode Q No (scalarEncode Q No z)|≤_
  calc
    _ ≤ (Fintype.card ι:ℝ)*(((Ni:ℝ)+1)/(2*(Q:ℝ)))+1/(2*(Q:ℝ)) := ht.trans (add_le_add hcoeff hround)
    _ = _ := by ring

#print axioms affineGridCircuit_approximates
end ConditionalNonpolynomial.AnalyticLookup
