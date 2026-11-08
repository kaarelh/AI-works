import NeuralGeneralization.OnlineLowerTanhPathShift

/-! Homogeneous signed-digit realization by the actual finite shift transfer. -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower

lemma tripleShift_iterate_add (h:ℝ) (L:ℕ) (f g:ℝ→ℝ) :
    (tripleShift h)^[L] (fun x=>f x+g x)=
      fun x=>(tripleShift h)^[L] f x+(tripleShift h)^[L] g x := by
  induction L with
  | zero => rfl
  | succ L ih =>
    simp only [Function.iterate_succ_apply',ih]
    funext x
    simp only [tripleShift]
    ring

lemma tripleShift_iterate_mul (h c:ℝ) (L:ℕ) (f:ℝ→ℝ) :
    (tripleShift h)^[L] (fun x=>c*f x)=fun x=>c*((tripleShift h)^[L] f x) := by
  induction L with
  | zero => rfl
  | succ L ih =>
    rw [Function.iterate_succ_apply',ih]
    funext x
    change c*((tripleShift h)^[L] f x)+c*((tripleShift h)^[L] f (x+h))+
      c*((tripleShift h)^[L] f (x+2*h))=c*((tripleShift h)^[L+1] f x)
    rw [Function.iterate_succ_apply']
    unfold tripleShift
    ring

lemma tripleShift_iterate_shift (h q:ℝ) (L:ℕ) (f:ℝ→ℝ) :
    (tripleShift h)^[L] (scalarShift q f)=scalarShift q ((tripleShift h)^[L] f) := by
  induction L with
  | zero => rfl
  | succ L ih =>
    rw [Function.iterate_succ_apply',ih]
    funext x
    rw [Function.iterate_succ_apply']
    simp only [tripleShift,scalarShift]
    congr 2 <;> congr 1 <;> ring

def pathBridge (f:ℝ→ℝ) (x:ℝ):ℝ:=f (x+2)+f (x+6)

lemma tripleShift_iterate_bridge (L:ℕ) (f:ℝ→ℝ) :
    (tripleShift 4)^[L] (pathBridge f)=pathBridge ((tripleShift 4)^[L] f) := by
  change (tripleShift 4)^[L] (fun x=>scalarShift 2 f x+scalarShift 6 f x)=_
  rw [tripleShift_iterate_add,tripleShift_iterate_shift,tripleShift_iterate_shift]
  rfl

def homogeneousGrayProfile : List Bool → (ℝ→ℝ) → (ℝ→ℝ)
  | [],f=>f
  | e::es,f=>fun x=>(tripleShift 4)^[es.length+1] f x+
      digitSign e*homogeneousGrayProfile es f (x+8)

def homogeneousSignedProfile : List Bool → (ℝ→ℝ) → (ℝ→ℝ)
  | [],_=>fun _=>0
  | d::ds,f=>fun x=>digitSign d*((tripleShift 4)^[ds.length] f x)+
      homogeneousSignedProfile ds f (x+8)

lemma homogeneousGrayProfile_mul (es:List Bool) (c:ℝ) (f:ℝ→ℝ) :
    homogeneousGrayProfile es (fun x=>c*f x)=fun x=>c*homogeneousGrayProfile es f x := by
  induction es with
  | nil => rfl
  | cons e es ih =>
    simp only [homogeneousGrayProfile,tripleShift_iterate_mul,ih]
    funext x
    ring

lemma homogeneousGrayProfile_shift (es:List Bool) (q:ℝ) (f:ℝ→ℝ) :
    homogeneousGrayProfile es (scalarShift q f)=scalarShift q (homogeneousGrayProfile es f) := by
  induction es with
  | nil => rfl
  | cons e es ih =>
    simp only [homogeneousGrayProfile,tripleShift_iterate_shift,ih]
    funext x
    simp only [scalarShift]
    congr 2
    congr 1
    ring

lemma triangularShiftBlocks_append (xs ys:List Bool) (z:(ℝ→ℝ)×(ℝ→ℝ)) :
    triangularShiftBlocks (xs++ys) z=triangularShiftBlocks xs (triangularShiftBlocks ys z) := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp only [List.cons_append,triangularShiftBlocks,ih]

lemma triangularShiftBlocks_boundary (first:Bool) (tail:List Bool)
    (z:(ℝ→ℝ)×(ℝ→ℝ)) :
    triangularShiftBlocks (first::tail.reverse) z=
      (fun x=>(tripleShift 4)^[tail.length+1] z.1 x+pathBridge (homogeneousGrayProfile tail z.2) x,
       fun x=>digitSign first*digitSign (boolSignProduct tail)*
         z.2 (x+8*(tail.length+1:ℕ))) := by
  induction tail generalizing z with
  | nil =>
    apply Prod.ext <;> funext x
    · simp [triangularShiftBlocks,triangularShiftBlock,homogeneousGrayProfile,pathBridge,Function.iterate_one]
      ring
    · simp [triangularShiftBlocks,triangularShiftBlock,boolSignProduct,digitSign]
  | cons e es ih =>
    rw [List.reverse_cons]
    change triangularShiftBlocks ((first::es.reverse)++[e]) z=_
    rw [triangularShiftBlocks_append]
    change triangularShiftBlocks (first::es.reverse) (triangularShiftBlock e z)=_
    rw [ih]
    apply Prod.ext <;> funext x
    · have hfst:(triangularShiftBlock e z).1=(fun y=>tripleShift 4 z.1 y+pathBridge z.2 y):=by
        funext y
        simp only [triangularShiftBlock,pathBridge]
        ring
      have hsnd:(triangularShiftBlock e z).2=(fun y=>digitSign e*scalarShift 8 z.2 y):=rfl
      simp only [Prod.fst] at *
      rw [hfst,hsnd]
      change (tripleShift 4)^[es.length+1]
        (fun x=>tripleShift 4 z.1 x+pathBridge z.2 x) x+
        pathBridge (homogeneousGrayProfile es (fun x=>digitSign e*scalarShift 8 z.2 x)) x=_
      rw [tripleShift_iterate_add,tripleShift_iterate_bridge,
        homogeneousGrayProfile_mul,homogeneousGrayProfile_shift]
      simp only [pathBridge,homogeneousGrayProfile,List.length_cons,scalarShift]
      have heq:(tripleShift 4)^[es.length+1] (tripleShift 4 z.1)=
          (tripleShift 4)^[es.length+1+1] z.1:=by
        exact (Function.iterate_succ_apply (tripleShift 4) (es.length+1) z.1).symm
      rw [heq]
      ring
    · simp only [triangularShiftBlock,boolSignProduct,digitSign_signMul,List.length_cons]
      have heq:x+8*(es.length+1:ℕ)+8=x+8*(es.length+1+1:ℕ):=by push_cast;ring
      rw [heq]
      ring

lemma homogeneousGrayProfile_encodeGray (previous:Bool) (ds:List Bool) (f:ℝ→ℝ) :
    homogeneousGrayProfile (encodeGray previous ds) f=
      fun x=>(tripleShift 4)^[ds.length] f x+
        digitSign previous*homogeneousSignedProfile ds f (x+8) := by
  induction ds generalizing previous with
  | nil => simp [encodeGray,homogeneousGrayProfile,homogeneousSignedProfile]
  | cons d ds ih =>
    simp only [encodeGray,homogeneousGrayProfile,encodeGray_length,List.length_cons,
      digitSign_signMul,ih,homogeneousSignedProfile]
    funext x
    have hs:=digitSign_sq d
    linear_combination digitSign previous*homogeneousSignedProfile ds f (x+8+8)*hs

lemma homogeneousSignedProfile_bridge (ds:List Bool) (f:ℝ→ℝ) :
    homogeneousSignedProfile ds (pathBridge f)=pathBridge (homogeneousSignedProfile ds f) := by
  induction ds with
  | nil => funext x;simp [homogeneousSignedProfile,pathBridge]
  | cons d ds ih =>
    simp only [homogeneousSignedProfile,tripleShift_iterate_bridge,ih]
    funext x
    simp only [pathBridge]
    have h2:x+8+2=x+2+8:=by ring
    have h6:x+8+6=x+6+8:=by ring
    rw [h2,h6]
    ring

lemma homogeneousSignedProfile_weighted (ds:List Bool) (f:ℝ→ℝ) (x:ℝ) :
    homogeneousSignedProfile ds f x=
      weightedSignedSeries (pathDifferenceWeight 4 f (ds.length-1) x) ds := by
  induction ds generalizing x with
  | nil => rfl
  | cons d ds ih =>
    simp only [homogeneousSignedProfile,weightedSignedSeries]
    rw [ih]
    simp only [pathDifferenceWeight,List.length_cons,Nat.add_sub_cancel,Nat.sub_zero,
      Nat.cast_zero,mul_zero,zero_mul,add_zero]
    congr 1
    congr 1
    funext j
    have hnat:ds.length-1-j=ds.length-(j+1):=by omega
    unfold pathDifferenceWeight
    rw [hnat]
    congr 1
    push_cast
    ring

/-- The fixed endpoint cancels from all free signed digits. This is an
identity for arbitrary scalar functions, not a Laplace-model substitute. -/
theorem triangularShiftBlocks_fixedParity (endpoint:Bool) (ds:List Bool)
    (z:(ℝ→ℝ)×(ℝ→ℝ)) (x:ℝ) :
    (triangularShiftBlocks (fixedParityBlocks endpoint ds) z).1 x=
      (tripleShift 4)^[ds.length+1] z.1 x+
        pathBridge ((tripleShift 4)^[ds.length] z.2) x+
        weightedSignedSeries (pathDifferenceWeight 4 (pathBridge z.2) (ds.length-1) (x+8)) ds := by
  unfold fixedParityBlocks
  rw [triangularShiftBlocks_boundary,homogeneousGrayProfile_encodeGray,encodeGray_length]
  simp only [digitSign,if_true,one_mul,pathBridge]
  rw [←homogeneousSignedProfile_weighted]
  rw [homogeneousSignedProfile_bridge]
  simp only [pathBridge]
  have h2:x+2+8=x+8+2:=by ring
  have h6:x+6+8=x+8+6:=by ring
  rw [h2,h6]
  ring

lemma triangularShiftBlocks_fixedParity_snd (endpoint:Bool) (ds:List Bool)
    (z:(ℝ→ℝ)×(ℝ→ℝ)) (x:ℝ) :
    (triangularShiftBlocks (fixedParityBlocks endpoint ds) z).2 x=
      digitSign endpoint*z.2 (x+8*(ds.length+1:ℕ)) := by
  unfold fixedParityBlocks
  rw [triangularShiftBlocks_boundary,encodeGray_length]
  simp only [digitSign_signMul]
  have hs:=digitSign_sq (boolSignProduct (encodeGray true ds))
  linear_combination digitSign endpoint*z.2 (x+8*(ds.length+1:ℕ))*hs

end NeuralGeneralization.OnlineLowerTanh
