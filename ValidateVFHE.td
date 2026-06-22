#ifndef LIB_TRANSFORMS_VALIDATEVFHE_VALIDATEVFHE_TD_
#define LIB_TRANSFORMS_VALIDATEVFHE_VALIDATEVFHE_TD_

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// VFHEClassifyOps
//
// Assigns a `#vfhe.proof_class` attribute to every ciphertext-level operation
// in a function, and inserts `vfhe.commit` / `vfhe.attest` markers at the
// function boundaries.
//
// Classification rules (mirroring Table 1 in the vHEIR paper):
//
//   Operations in `bgv`, `ckks`, `lwe` dialects:
//     bgv.add / bgv.add_plain / lwe.radd        -> ring_linear
//     bgv.mul / bgv.mul_plain / lwe.rmul        -> ring_arith
//     bgv.relinearize                            -> ring_arith
//     bgv.modulus_switch / mgmt.modreduce
//       mgmt.level_reduce / mgmt.level_reduce_min -> maintenance
//     mgmt.bootstrap / ckks.bootstrap            -> maintenance
//     (all others)                               -> ring_linear (conservative)
//
// The `commitment_scheme` string on the emitted `vfhe.commit` op mirrors the
// proof class of the first consuming op in the segment.
//===----------------------------------------------------------------------===//
def VFHEClassifyOps : Pass<"vfhe-classify-ops", "::mlir::func::FuncOp"> {
  let summary = "Assign vfhe.proof_class attributes to all ciphertext ops";
  let description = [{
    This pass walks the IR in execution order and attaches a
    `#vfhe.proof_class` attribute to every operation that operates on
    ciphertext-level types (i.e. any op in the `bgv`, `ckks`, `lwe`, or
    `mgmt` dialects that produces or consumes ciphertext-typed SSA values).

    It also inserts `vfhe.commit` at every function entry boundary and
    `vfhe.attest` at every function return, so that downstream proof-emission
    tools have well-defined segments over which to produce certificates.

    This pass is the first step of the vHEIR verification pipeline and must
    run before `--vfhe-validate-classification`.
  }];

  let dependentDialects = [
    "::mlir::heir::vfhe::VFHEDialect",
    "::mlir::heir::bgv::BGVDialect",
    "::mlir::heir::mgmt::MgmtDialect",
  ];

  let options = [
    Option<"conservativeDefault", "conservative-default", "bool",
           /*default=*/"true",
           "Classify unrecognised ops as ring_linear (conservative). "
           "Set to false to treat unrecognised ops as an error.">,
  ];
}

//===----------------------------------------------------------------------===//
// VFHEValidateClassification
//
// Checks that every ciphertext-level op has a `#vfhe.proof_class` attribute
// and that `#vfhe.witness_trace` is present on every `maintenance`-class op.
// Emits a pass failure (signalPassFailure) on violation.
//
// This pass models the per-pass translation-validation obligation from §5 of
// the vHEIR paper: it does not verify semantic equivalence between source and
// lowered IR (that is the job of an SMT-based validator), but it does verify
// that the annotation invariants the verification plane depends upon have not
// been silently dropped by an intervening lowering pass.
//===----------------------------------------------------------------------===//
def VFHEValidateClassification : Pass<"vfhe-validate-classification",
                                      "::mlir::ModuleOp"> {
  let summary = "Validate that vfhe proof-class annotations are complete";
  let description = [{
    Walks all operations in the module and emits an error for each of the
    following violations:

    1. A ciphertext-level op in `bgv`, `ckks`, `lwe`, or `mgmt` that is
       *missing* a `vfhe.proof_class` attribute.  Such an op was not reached
       by `--vfhe-classify-ops` (likely because it was introduced by a pass
       that ran after classification), which means it has no proof obligation
       and would silently escape verification.

    2. A `maintenance`-class op that is *missing* a `vfhe.witness_trace`
       attribute.  The downstream lattice-SNARK / IOP prover requires this
       trace; without it, the proof cannot be constructed.

    3. A `vfhe.commit` or `vfhe.attest` that has been removed or orphaned by
       a later pass without the corresponding proof obligation being resolved.

    On success the module is unchanged; the pass is purely diagnostic.
  }];

  let dependentDialects = [
    "::mlir::heir::vfhe::VFHEDialect",
    "::mlir::heir::bgv::BGVDialect",
    "::mlir::heir::mgmt::MgmtDialect",
  ];

  let options = [
    Option<"strict", "strict", "bool", /*default=*/"true",
           "If true (default), emit pass failure on any violation. "
           "If false, emit warnings only (useful for incremental adoption).">,
  ];
}

#endif  // LIB_TRANSFORMS_VALIDATEVFHE_VALIDATEVFHE_TD_
