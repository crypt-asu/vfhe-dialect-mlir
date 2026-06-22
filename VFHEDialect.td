#ifndef LIB_DIALECT_VFHE_IR_VFHEDIALECT_TD_
#define LIB_DIALECT_VFHE_IR_VFHEDIALECT_TD_

include "mlir/IR/OpBase.td"

def VFHE_Dialect : Dialect {
  let name = "vfhe";
  let summary = "A dialect for proof-carrying verification metadata over FHE dialects";
  let description = [{
    The `vfhe` dialect is a verification-plane dialect that runs alongside
    HEIR's existing scheme dialects (`bgv`, `ckks`, `mgmt`, `lwe`). It does
    not introduce new ciphertext computation; instead it annotates
    already-lowered operations with the metadata required to later emit a
    proof of correct evaluation to an untrusted server, and to discharge a
    translation-validation obligation for the lowering pass that produced
    them.

    The `vfhe` dialect provides:

    - A `#vfhe.proof_class` attribute that classifies an operation into one
      of `ring_linear`, `ring_arith`, or `maintenance`, determining which
      proof system (homomorphic MAC, ring-SNARK, or lattice-SNARK/IOP
      respectively) is responsible for certifying it.
    - A `#vfhe.witness_trace` attribute that records the RNS/digit-decomposition
      structure of a maintenance operation (modulus switch, key switch,
      bootstrap), so that this structure does not need to be reconstructed
      from the compiled circuit by a downstream proof system.
    - Operations `vfhe.commit` and `vfhe.attest` that mark, respectively, the
      point at which a ciphertext enters the verification plane and the
      point at which an evaluator-produced ciphertext is checked against an
      accumulated proof obligation.

    This dialect is the IR-level realization of the `vHEIR` architecture
    described in "vHEIR: A Proof-Carrying Compiler Architecture for Fully
    Homomorphic Encryption with Integrated Verification".
  }];

  let cppNamespace = "::mlir::heir::vfhe";
}

#endif  // LIB_DIALECT_VFHE_IR_VFHEDIALECT_TD_
