import NeuralGeneralization.OnlineLowerCostPath

/-!
# Explicit realization of signed digits by triangular path blocks

The endpoint parity is fixed by the first free block. The remaining blocks
are constructed from any desired signed digit string, so this module checks
the boundary realization rather than assuming it.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLower

def signMul (a b : Bool) : Bool := a == b

theorem digitSign_signMul (a b : Bool) :
    digitSign (signMul a b) = digitSign a * digitSign b := by
  cases a <;> cases b <;> norm_num [signMul, digitSign]

theorem digitSign_sq (a : Bool) : digitSign a ^ 2 = 1 := by
  cases a <;> norm_num [digitSign]

def boolSignProduct : List Bool → Bool
  | [] => true
  | a :: as => signMul a (boolSignProduct as)

def graySeries (r : ℝ) : List Bool → ℝ
  | [] => 1
  | b :: bs => 1 + digitSign b * r * graySeries r bs

def encodeGray (previous : Bool) : List Bool → List Bool
  | [] => []
  | d :: ds => signMul previous d :: encodeGray d ds

theorem encodeGray_length (previous : Bool) (ds : List Bool) :
    (encodeGray previous ds).length = ds.length := by
  induction ds generalizing previous with
  | nil => rfl
  | cons d ds ih => simp [encodeGray, ih]

theorem graySeries_encodeGray (r : ℝ) (previous : Bool) (ds : List Bool) :
    graySeries r (encodeGray previous ds) =
      1 + digitSign previous * r * signedSeries r ds := by
  induction ds generalizing previous with
  | nil => simp [encodeGray, graySeries, signedSeries]
  | cons d ds ih =>
    simp only [encodeGray, graySeries, digitSign_signMul, ih, signedSeries]
    cases d <;> cases previous <;> norm_num [digitSign] <;> ring

/-- Upper-right and lower-right coefficients of a product of normalized
upper triangular matrices with upper-left coefficient one. -/
def triangularCoefficients (r b : ℝ) : List Bool → ℝ × ℝ
  | [] => (0, 1)
  | e :: es =>
    let z := triangularCoefficients r b es
    (z.1 + b * z.2, digitSign e * r * z.2)

theorem triangularCoefficients_snoc (r b : ℝ) (es : List Bool) (e : Bool) :
    triangularCoefficients r b (es ++ [e]) =
      (b + digitSign e * r * (triangularCoefficients r b es).1,
        digitSign e * r * (triangularCoefficients r b es).2) := by
  induction es with
  | nil => simp [triangularCoefficients]
  | cons a es ih =>
    simp only [List.cons_append, triangularCoefficients, ih]
    apply Prod.ext <;> ring

theorem triangularCoefficients_boundary (r b : ℝ) (first : Bool) (tail : List Bool) :
    triangularCoefficients r b (first :: tail.reverse) =
      (b * graySeries r tail,
        digitSign first * digitSign (boolSignProduct tail) * r ^ (tail.length + 1)) := by
  induction tail with
  | nil => simp [triangularCoefficients, graySeries, boolSignProduct, digitSign]
  | cons e es ih =>
    rw [List.reverse_cons]
    change triangularCoefficients r b ((first :: es.reverse) ++ [e]) = _
    rw [triangularCoefficients_snoc, ih]
    simp only [graySeries, boolSignProduct, digitSign_signMul, List.length_cons]
    apply Prod.ext
    · ring
    · rw [show es.length + 1 + 1 = (es.length + 1) + 1 by omega, pow_succ]
      ring

def fixedParityBlocks (endpoint : Bool) (digits : List Bool) : List Bool :=
  let tail := encodeGray true digits
  signMul endpoint (boolSignProduct tail) :: tail.reverse

theorem fixedParityBlocks_length (endpoint : Bool) (digits : List Bool) :
    (fixedParityBlocks endpoint digits).length = digits.length + 1 := by
  simp [fixedParityBlocks, encodeGray_length]

theorem fixedParityBlocks_coefficients (r b : ℝ) (endpoint : Bool) (digits : List Bool) :
    triangularCoefficients r b (fixedParityBlocks endpoint digits) =
      (b * (1 + r * signedSeries r digits),
        digitSign endpoint * r ^ (digits.length + 1)) := by
  unfold fixedParityBlocks
  rw [triangularCoefficients_boundary, graySeries_encodeGray, encodeGray_length]
  simp only [show digitSign true = 1 from rfl, one_mul]
  apply Prod.ext
  · rfl
  · simp only [digitSign_signMul]
    ring_nf
    simp only [digitSign_sq, mul_one]

def applyTriangularCoefficients (coeff z : ℝ × ℝ) : ℝ × ℝ :=
  (z.1 + coeff.1 * z.2, coeff.2 * z.2)

def triangularBlock (r b : ℝ) (e : Bool) (z : ℝ × ℝ) : ℝ × ℝ :=
  (z.1 + b * z.2, digitSign e * r * z.2)

def triangularBlocksApply (r b : ℝ) : List Bool → (ℝ × ℝ) → ℝ × ℝ
  | [], z => z
  | e :: es, z => triangularBlock r b e (triangularBlocksApply r b es z)

theorem triangularBlocksApply_eq (r b : ℝ) (es : List Bool) (z : ℝ × ℝ) :
    triangularBlocksApply r b es z =
      applyTriangularCoefficients (triangularCoefficients r b es) z := by
  induction es with
  | nil => simp [triangularBlocksApply, triangularCoefficients, applyTriangularCoefficients]
  | cons e es ih =>
    simp only [triangularBlocksApply, ih, triangularBlock, triangularCoefficients,
      applyTriangularCoefficients]
    apply Prod.ext <;> ring

def freePathBlock (x : ℝ) (e : Bool) (z : ℝ × ℝ) : ℝ × ℝ :=
  let middle := pathStep (x ^ 3) (x ^ 2) (pathFlip (pathStep x (x ^ 2) z))
  if e then pathFlip middle else middle

theorem freePathBlock_eq (x : ℝ) (e : Bool) (z : ℝ × ℝ) :
    freePathBlock x e z =
      ((1 - x ^ 6) * (triangularBlock (pathRatio x) (pathSlope x) e z).1,
        (1 - x ^ 6) * (triangularBlock (pathRatio x) (pathSlope x) e z).2) := by
  simp only [freePathBlock, path_two_step_triangular]
  cases e <;> simp [pathFlip, triangularBlock, digitSign] <;> ring

/-- The scalar boundary value used by the integral ordering is literally the
sum of the two final transformed coordinates, with the fixed endpoint sign. -/
theorem fixedParityBlocks_scalar (x : ℝ) (endpoint : Bool) (digits : List Bool) :
    let z := applyTriangularCoefficients
      (triangularCoefficients (pathRatio x) (pathSlope x)
        (fixedParityBlocks endpoint digits)) (1, x ^ 2)
    z.1 + z.2 = pathBoundaryScalar x (digits.length + 1) (digitSign endpoint) digits := by
  rw [fixedParityBlocks_coefficients]
  simp only [applyTriangularCoefficients, pathBoundaryScalar]
  ring

theorem triangularCoefficients_snd (r b : ℝ) (es : List Bool) :
    (triangularCoefficients r b es).2 = digitSign (boolSignProduct es) * r ^ es.length := by
  induction es with
  | nil => simp [triangularCoefficients, boolSignProduct, digitSign]
  | cons e es ih =>
    simp only [triangularCoefficients, boolSignProduct, digitSign_signMul, ih,
      List.length_cons, pow_succ]
    ring

theorem fixedParityBlocks_signProduct (endpoint : Bool) (digits : List Bool) :
    digitSign (boolSignProduct (fixedParityBlocks endpoint digits)) = digitSign endpoint := by
  have h := congrArg Prod.snd (fixedParityBlocks_coefficients 1 0 endpoint digits)
  rw [triangularCoefficients_snd] at h
  simpa using h

end NeuralGeneralization.OnlineLower
