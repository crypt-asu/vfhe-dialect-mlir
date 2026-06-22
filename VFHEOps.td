#ifndef LIB_DIALECT_VFHE_IR_VFHEOPS_TD_
#define LIB_DIALECT_VFHE_IR_VFHEOPS_TD_

include "lib/Dialect/VFHE/IR/VFHEDialect.td"
include "lib/Dialect/VFHE/IR/VFHEAttributes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

class VFHE_Op<string mnemonic, list<Trait> traits = []>
    : Op<VFHE_Dialect, mnemonic, traits> {}

//===----------------------------------------------------------------------===//
// vfhe.commit
//
// Marks the point at which a ciphertext value enters the vfhe verification
// plane.  The --vfhe-classify-ops pass inserts a commit immediately before
// the first ciphertext-consuming op in each function body.
//
// `commitment_scheme` names the encoding / commitment to be used for the
// downstream proof (one of "hmac", "ring_snark", "lattice_snark").
//===----------------------------------------------------------------------===//
def VFHE_CommitOp : VFHE_Op<"commit", [Pure, AllTypesMatch<["input", "output"]>]> {
  let summary = "Marks a ciphertext value entering the vfhe verification plane";
  let description = [{
    Inserted by the `--vfhe-classify-ops` pass immediately before the first
    use of each ciphertext-typed SSA value.  The result is the same value
    with an identity semantics; the only effect is that the value is now
    tracked by the vfhe verification plane.

    `commitment_scheme` selects the encoding / commitment to be used for the
    downstream proof emission:
      - "hmac"          : linearly homomorphic MAC (ring_linear class)
      - "ring_snark"    : ring-SNARK / Rinocchio  (ring_arith class)
      - "lattice_snark" : lattice-SNARK or IOP    (maintenance class)

    This is a pure (no-side-effect) identity op over the IR value and is
    removed during proof-emission lowering once the verification metadata
    has been consumed.

    Example:
    ```mlir
    %c0_tracked = vfhe.commit %c0 {commitment_scheme = "ring_snark"}
        : !lwe.rlwe_ciphertext<encoding = #lwe.polynomial_evaluation_encoding<...>>
    ```
  }];

  let arguments = (ins
    AnyType:$input,
    StrAttr:$commitment_scheme
  );
  let results = (outs AnyType:$output);
  let assemblyFormat =
    "$input attr-dict `:` type($input)";
}

//===----------------------------------------------------------------------===//
// vfhe.attest
//
// Marks the point at which the evaluator must produce a proof that the
// preceding chain of classified operations was evaluated correctly.
// Inserted by --vfhe-emit-proof-obligations at function return boundaries.
//
// `proof_obligation_id`  : stable numeric id linking this attestation to the
//                          accumulation of proof obligations produced for the
//                          same segment.
//===----------------------------------------------------------------------===//
def VFHE_AttestOp : VFHE_Op<"attest", [
    MemoryEffects<[MemWrite]>
  ]> {
  let summary = "Requests a proof of correct evaluation from the evaluator";
  let description = [{
    Inserted by the `--vfhe-emit-proof-obligations` pass at each function
    return boundary (and at each segment boundary separating proof classes).
    During actual evaluation, the evaluator is expected to produce a proof
    π and the client's verifier checks (output_ct, π) via the appropriate
    `Vfy` algorithm for the segment's proof class.

    This op has a side effect (MemWrite) to prevent dead-code elimination
    from removing it.

    `proof_obligation_id` is a non-negative integer that the pass assigns
    uniquely per segment, so that an external verifier tool can match each
    `vfhe.attest` to its accumulated classification metadata.

    Example:
    ```mlir
    vfhe.attest %c_out {proof_obligation_id = 0 : i64}
        : !lwe.rlwe_ciphertext<...>
    ```
  }];

  let arguments = (ins
    AnyType:$input,
    I64Attr:$proof_obligation_id
  );
  let results = (outs);
  let assemblyFormat =
    "$input attr-dict `:` type($input)";
}

#endif  // LIB_DIALECT_VFHE_IR_VFHEOPS_TD_
