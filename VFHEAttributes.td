#ifndef LIB_DIALECT_VFHE_IR_VFHEATTRIBUTES_TD_
#define LIB_DIALECT_VFHE_IR_VFHEATTRIBUTES_TD_

include "lib/Dialect/VFHE/IR/VFHEDialect.td"
include "lib/Dialect/VFHE/IR/VFHEEnums.td"
include "mlir/IR/OpBase.td"

class VFHE_Attr<string name, string attrMnemonic, list<Trait> traits = []>
    : AttrDef<VFHE_Dialect, name, traits> {
  let mnemonic = attrMnemonic;
}

//===----------------------------------------------------------------------===//
// ProofClassAttr
//
// Annotated on every ciphertext operation that enters the vfhe verification
// plane.  The value determines which downstream proof-emission backend is
// responsible for certifying the operation:
//
//   ring_linear  -> ct+ct addition, pt*ct scaling  (homomorphic MAC)
//   ring_arith   -> ct*ct multiplication, relin     (ring-SNARK / Rinocchio)
//   maintenance  -> modulus_switch, keyswitch,
//                   bootstrap                       (lattice-SNARK / IOP)
//
// The --vfhe-classify-ops pass assigns proof_class automatically based on
// the operation's type.  Users should not set this attribute manually.
//===----------------------------------------------------------------------===//
def VFHE_ProofClassAttr : VFHE_Attr<"ProofClass", "proof_class"> {
  let summary = "Classifies a ciphertext op into its verification proof class";
  let description = [{
    Attach this attribute to a ciphertext-level op (e.g. `bgv.mul`,
    `mgmt.modreduce`, `bgv.relinearize`) to declare which proof system is
    responsible for certifying its correct evaluation.

    Example:
    ```mlir
    %c2 = bgv.mul %c0, %c1
        {vfhe.proof_class = #vfhe.proof_class<ring_arith>}
        : (!lwe.rlwe_ciphertext<...>, !lwe.rlwe_ciphertext<...>)
          -> !lwe.rlwe_ciphertext<...>
    %c3 = mgmt.modreduce %c2
        {vfhe.proof_class = #vfhe.proof_class<maintenance>}
        : !lwe.rlwe_ciphertext<...>
    ```
  }];

  let parameters = (ins
    "VFHEProofClass":$proof_class
  );

  let assemblyFormat = "`<` $proof_class `>`";
}

//===----------------------------------------------------------------------===//
// WitnessTraceAttr
//
// Carries the RNS/digit-decomposition bookkeeping emitted for maintenance
// operations (mgmt.modreduce, bgv.relinearize, ckks.bootstrap) at the point
// where the --vfhe-classify-ops pass determines their exact parameter context.
//
// Fields (all optional; unused fields default to 0 / empty):
//   rns_channels      : number of RNS limbs of the *input* ciphertext
//   output_channels   : number of RNS limbs of the *output* ciphertext
//   decomp_base_bits  : log2 of the decomposition base used by key switching
//   is_bootstrap      : whether this trace covers a bootstrap operation
//
// The downstream lattice-SNARK / IOP prover (e.g. Atapoor et al., Heliopolis)
// reads these fields so it does not need to reconstruct the structure from the
// compiled binary.
//===----------------------------------------------------------------------===//
def VFHE_WitnessTraceAttr : VFHE_Attr<"WitnessTrace", "witness_trace"> {
  let summary = "RNS/digit-decomposition witness for a maintenance operation";
  let description = [{
    Attached alongside `#vfhe.proof_class<maintenance>` on every maintenance
    op, this attribute records the data the downstream proof system needs to
    construct its witness without re-inspecting the compiled circuit.

    Example:
    ```mlir
    %c3 = mgmt.modreduce %c2 {
        vfhe.proof_class  = #vfhe.proof_class<maintenance>,
        vfhe.witness_trace = #vfhe.witness_trace<
            rns_channels    = 3,
            output_channels = 2,
            decomp_base_bits = 0,
            is_bootstrap    = false>
        } : !lwe.rlwe_ciphertext<...>
    ```
  }];

  let parameters = (ins
    DefaultValuedParameter<"int64_t", "0">:$rns_channels,
    DefaultValuedParameter<"int64_t", "0">:$output_channels,
    DefaultValuedParameter<"int64_t", "0">:$decomp_base_bits,
    DefaultValuedParameter<"bool",    "false">:$is_bootstrap
  );

  let assemblyFormat = "`<` struct(params) `>`";
}

#endif  // LIB_DIALECT_VFHE_IR_VFHEATTRIBUTES_TD_
