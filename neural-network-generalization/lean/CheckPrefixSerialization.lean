import NeuralGeneralization.BatchTwoCircuitConverseStringPrior

open NeuralGeneralization.BatchTwoCircuitConverse
open NeuralGeneralization.BatchTwoCircuitConverse.Prefix

private def inverter : Circuit 1 := ⟨1,((),⟨0,by decide⟩,⟨2,by decide⟩)⟩
private def patched : Program 1 := Program.exception (fun _ => true) true (Program.base inverter)

private def check (name : String) (ok : Bool) : IO Unit := do
  if !ok then throw (IO.userError ("FAILED: "++name))
  IO.println ("PASS: "++name)

/-- These checks execute the compiled serializer/parser and the original
circuit evaluator. General correctness is proved in the imported modules. -/
def main : IO Unit := do
  check "constant zero tag" (serialize (Program.base (Circuit.empty 1))==[false,false])
  check "NAND address order and exact length"
    (serialize (Program.base inverter)==[false,true,true,false,false,false,false,true])
  check "decoded NAND semantics"
    ((deserialize 1 (serialize (Program.base inverter))).map
      (fun p => (p.length,p.eval (fun _ => false),p.eval (fun _ => true)))==some (8,true,false))
  check "exception tag and semantics"
    ((deserialize 1 (serialize patched)).map
      (fun p => (p.length,p.eval (fun _ => false),p.eval (fun _ => true)))==some (11,true,true))
  check "suffix preserved by streaming decoder"
    ((readProgramFuel 1 11 (serialize patched++[false,true])).map Prod.snd==some [false,true])
  check "trailing bits rejected" ((deserialize 1 [false,false,true]).isNone)
  check "zero-gate nonempty tag rejected" ((deserialize 1 [false,true,false]).isNone)
  check "out-of-range address rejected"
    ((deserialize 1 [false,true,true,false,true,true,false,false]).isNone)
  check "truncated address rejected" ((deserialize 1 [false,true,true,false,false]).isNone)
  check "truncated exception rejected" ((deserialize 1 [true,true,true]).isNone)
  check "empty string rejected" ((deserialize 1 []).isNone)
