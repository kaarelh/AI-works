import InfLearn.Steps

namespace InfLearn
namespace CoherenceGames

open Formula

/-! ## Part 1: the doctrinal paradox (T2 Theorem 2.4) -/

section Doctrinal

/-- The atom `p`. -/
abbrev p : Formula := var 0
/-- The atom `q`. -/
abbrev q : Formula := var 1

/-- The three theories `T₁ = {p, q}`, `T₂ = {p, ¬q}`, `T₃ = {¬p, q}` (indexed `0, 1, 2`). -/
def T : Fin 3 → Set Formula
  | 0 => {p, q}
  | 1 => {p, neg q}
  | 2 => {neg p, q}

theorem satisfies_union {v : Valuation} {X Y : Set Formula} :
    Satisfies v (X ∪ Y) ↔ Satisfies v X ∧ Satisfies v Y := by
  constructor
  · intro h
    exact ⟨fun ψ hψ => h ψ (Or.inl hψ), fun ψ hψ => h ψ (Or.inr hψ)⟩
  · rintro ⟨hX, hY⟩ ψ (hψ | hψ)
    · exact hX ψ hψ
    · exact hY ψ hψ

end Doctrinal

end CoherenceGames
end InfLearn
