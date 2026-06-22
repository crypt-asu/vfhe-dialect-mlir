#ifndef LIB_DIALECT_VFHE_IR_VFHEENUMS_TD_
#define LIB_DIALECT_VFHE_IR_VFHEENUMS_TD_

include "mlir/IR/EnumAttr.td"
include "lib/Dialect/VFHE/IR/VFHEDialect.td"

// The proof-class assignment routes an operation to the verification
// technique best suited to certify it, following the division of labor in
// Table 1 of the vHEIR paper:
//
//   ring_linear  -> homomorphic MACs (Catalano-Fiore, Gennaro-Wichs)
//   ring_arith   -> ring-SNARKs (e.g. Rinocchio)
//   maintenance  -> lattice-SNARKs / IOPs for modswitch, keyswitch,
//                   bootstrap (e.g. Atapoor et al., Heliopolis)
def VFHE_ProofClassEnum : I32EnumAttr<"VFHEProofClass",
    "An enum attribute classifying an operation's verification technique", [
  I32EnumAttrCase<"ring_linear", 0>,
  I32EnumAttrCase<"ring_arith", 1>,
  I32EnumAttrCase<"maintenance", 2>
]> {
  let cppNamespace = "::mlir::heir::vfhe";
}

#endif  // LIB_DIALECT_VFHE_IR_VFHEENUMS_TD_
