import NeuralGeneralization.OnlineLowerCostTransfer

/-!
# The actual path edge sum and its triangular block realization

`pathEdgeSum` sums the two choices of each successive edge. Its last Boolean
argument records the incoming edge. Thus it is a finite coset enumerator,
defined by explicit edge summation rather than by a desired closed formula.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLower

def loopFactor (a : ℝ) (bit : Bool) : ℝ := if bit then a else 1

def pathEdgeSum (a : ℝ) : List (Bool × ℝ) → Bool → Bool → ℝ
  | [], terminal, incoming => loopFactor a (Bool.xor terminal incoming)
  | (v, e) :: rest, terminal, incoming =>
      loopFactor a (Bool.xor v incoming) * pathEdgeSum a rest terminal false +
        e * loopFactor a (!(Bool.xor v incoming)) * pathEdgeSum a rest terminal true

def rawPathStep (a e : ℝ) (v : Bool) (z : ℝ × ℝ) : ℝ × ℝ :=
  if v then (a * z.1 + e * z.2, z.1 + a * e * z.2)
  else (z.1 + a * e * z.2, a * z.1 + e * z.2)

theorem pathEdgeSum_step (a e : ℝ) (v : Bool) (rest : List (Bool × ℝ))
    (terminal : Bool) :
    (pathEdgeSum a ((v, e) :: rest) terminal false,
      pathEdgeSum a ((v, e) :: rest) terminal true) =
      rawPathStep a e v
        (pathEdgeSum a rest terminal false, pathEdgeSum a rest terminal true) := by
  cases v <;> apply Prod.ext <;> dsimp [pathEdgeSum, loopFactor, rawPathStep] <;> ring

def pathLoop (x : ℝ) : ℝ := (1 - x ^ 2) / (1 + x ^ 2)
def pathEdgeSix (x : ℝ) : ℝ := (1 - x ^ 3) / (1 + x ^ 3)
def pathEdgeTwo (x : ℝ) : ℝ := (1 - x) / (1 + x)
def pathBlockScale (x : ℝ) : ℝ :=
  4 * (1 - x ^ 6) / ((1 + x ^ 2) ^ 2 * (1 + x ^ 3) * (1 + x))

def hadamardPair (z : ℝ × ℝ) : ℝ × ℝ := (z.1 + z.2, z.1 - z.2)
def scalePair (c : ℝ) (z : ℝ × ℝ) : ℝ × ℝ := (c * z.1, c * z.2)

def rawPathBlock (x : ℝ) (v : Bool) (z : ℝ × ℝ) : ℝ × ℝ :=
  rawPathStep (pathLoop x) (pathEdgeSix x) v
    (rawPathStep (pathLoop x) (pathEdgeTwo x) true z)

theorem rawPathBlock_hadamard (x : ℝ) (hx : 0 ≤ x) (v : Bool) (z : ℝ × ℝ) :
    hadamardPair (rawPathBlock x v z) =
      scalePair (pathBlockScale x)
        (triangularBlock (pathRatio x) (pathSlope x) v (hadamardPair z)) := by
  have h1 : 1 + x ≠ 0 := by linarith
  have h2 : 1 + x ^ 2 ≠ 0 := by nlinarith [sq_nonneg x]
  have h3 : 1 + x ^ 3 ≠ 0 := by positivity
  have hd := (pathDenominator_pos x).ne'
  cases v <;> apply Prod.ext <;>
    simp only [hadamardPair, rawPathBlock, rawPathStep, Bool.false_eq_true,
      if_false, if_true, scalePair, triangularBlock, digitSign, pathLoop,
      pathEdgeSix, pathEdgeTwo, pathBlockScale, pathRatio, pathSlope] <;>
    field_simp <;> ring

def rawPathBlocks (x : ℝ) : List Bool → (ℝ × ℝ) → ℝ × ℝ
  | [], z => z
  | v :: vs, z => rawPathBlock x v (rawPathBlocks x vs z)

theorem triangularBlock_scale (r b c : ℝ) (v : Bool) (z : ℝ × ℝ) :
    triangularBlock r b v (scalePair c z) =
      scalePair c (triangularBlock r b v z) := by
  apply Prod.ext <;> simp only [triangularBlock, scalePair] <;> ring

theorem rawPathBlocks_hadamard (x : ℝ) (hx : 0 ≤ x) (vs : List Bool)
    (z : ℝ × ℝ) :
    hadamardPair (rawPathBlocks x vs z) =
      scalePair (pathBlockScale x ^ vs.length)
        (triangularBlocksApply (pathRatio x) (pathSlope x) vs (hadamardPair z)) := by
  induction vs with
  | nil => simp [rawPathBlocks, triangularBlocksApply, scalePair]
  | cons v vs ih =>
    rw [rawPathBlocks, rawPathBlock_hadamard x hx, ih, triangularBlock_scale]
    simp only [List.length_cons, triangularBlocksApply, scalePair]
    apply Prod.ext <;> rw [pow_succ] <;> ring

def pathBlockData (x : ℝ) : List Bool → List (Bool × ℝ)
  | [] => []
  | v :: vs => (v, pathEdgeSix x) :: (true, pathEdgeTwo x) :: pathBlockData x vs

theorem rawPathBlocks_eq_edgeSum (x : ℝ) (vs : List Bool) :
    rawPathBlocks x vs (1, pathLoop x) =
      (pathEdgeSum (pathLoop x) (pathBlockData x vs) false false,
        pathEdgeSum (pathLoop x) (pathBlockData x vs) false true) := by
  induction vs with
  | nil => simp [rawPathBlocks, pathBlockData, pathEdgeSum, loopFactor]
  | cons v vs ih =>
    simp only [rawPathBlocks, pathBlockData, rawPathBlock]
    rw [ih, ← pathEdgeSum_step, ← pathEdgeSum_step]

def candidatePathEnumerator (x : ℝ) (endpoint : Bool) (digits : List Bool) : ℝ :=
  pathEdgeSum (pathLoop x) (pathBlockData x (fixedParityBlocks endpoint digits)) false false

theorem candidatePathEnumerator_formula (x : ℝ) (hx : 0 ≤ x)
    (endpoint : Bool) (digits : List Bool) :
    candidatePathEnumerator x endpoint digits =
      pathBlockScale x ^ (digits.length + 1) / (1 + x ^ 2) *
        pathBoundaryScalar x (digits.length + 1) (digitSign endpoint) digits := by
  have he := rawPathBlocks_hadamard x hx (fixedParityBlocks endpoint digits) (1, pathLoop x)
  rw [rawPathBlocks_eq_edgeSum, triangularBlocksApply_eq,
    fixedParityBlocks_coefficients, fixedParityBlocks_length] at he
  have hfst := congrArg Prod.fst he
  have hsnd := congrArg Prod.snd he
  simp only [hadamardPair, scalePair, applyTriangularCoefficients] at hfst hsnd
  unfold candidatePathEnumerator pathBoundaryScalar
  have h2 : 1 + x ^ 2 ≠ 0 := by nlinarith [sq_nonneg x]
  have hsum :
      2 * pathEdgeSum (pathLoop x) (pathBlockData x (fixedParityBlocks endpoint digits))
        false false =
      pathBlockScale x ^ (digits.length + 1) *
        (1 + pathLoop x + pathSlope x * (1 + pathRatio x * signedSeries (pathRatio x) digits) *
          (1 - pathLoop x) + digitSign endpoint * pathRatio x ^ (digits.length + 1) *
          (1 - pathLoop x)) := by linarith
  unfold pathLoop at hsum ⊢
  field_simp at hsum ⊢
  nlinarith [hsum]

theorem pathBlockScale_pos (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1) :
    0 < pathBlockScale x := by
  have h6 : x ^ 6 < 1 := pow_lt_one₀ hx0.le hx1 (by decide)
  unfold pathBlockScale
  positivity

theorem candidatePathEnumerator_lt (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hlex : digitLexLt xs ys) :
    candidatePathEnumerator x endpoint xs < candidatePathEnumerator x endpoint ys := by
  rw [candidatePathEnumerator_formula x hx0.le,
    candidatePathEnumerator_formula x hx0.le, ← hlen]
  have hs : 0 < pathBlockScale x ^ (xs.length + 1) / (1 + x ^ 2) := by
    exact div_pos (pow_pos (pathBlockScale_pos x hx0 hx1) _) (by positivity)
  exact mul_lt_mul_of_pos_left
    (pathBoundaryScalar_lt x hx0 hx1.le (xs.length + 1) (digitSign endpoint) hlex) hs

theorem candidatePathEnumerator_ne_of_ne (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hne : xs ≠ ys) :
    candidatePathEnumerator x endpoint xs ≠ candidatePathEnumerator x endpoint ys := by
  rcases digitLexLt_or_reverse hlen hne with h | h
  · exact (candidatePathEnumerator_lt x hx0 hx1 endpoint hlen h).ne
  · exact (candidatePathEnumerator_lt x hx0 hx1 endpoint hlen.symm h).ne'

end NeuralGeneralization.OnlineLower
