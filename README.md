# vHEIR – HEIR Verification Plane Extension

This directory contains all files required to integrate the `vfhe` dialect and
`ValidateVFHE` passes described in *"vHEIR: A Proof-Carrying Compiler Architecture
for Fully Homomorphic Encryption with Integrated Verification"* into the HEIR
source tree.

## Directory Structure

```
VFHE/IR/
  VFHEDialect.td          – dialect definition (cppNamespace = mlir::heir::vfhe)
  VFHEEnums.td            – VFHEProofClass enum (ring_linear / ring_arith / maintenance)
  VFHEAttributes.td       – ProofClassAttr, WitnessTraceAttr
  VFHEOps.td              – vfhe.commit, vfhe.attest
  VFHEDialect.{h,cpp}     – C++ dialect implementation
  VFHEEnums.h             – enum header
  VFHEAttributes.h        – attribute header
  VFHEOps.{h,cpp}         – op implementation
  BUILD                   – Bazel build rules

ValidateVFHE/
  ValidateVFHE.td         – VFHEClassifyOps + VFHEValidateClassification pass definitions
  ValidateVFHE.{h,cpp}    – pass implementation (classification + validation)
  BUILD                   – Bazel build rules

validate_vfhe/ (lit tests)
  classify_mgmt_ops.mlir                   – classify-ops RUN test (FileCheck)
  validate_missing_witness_trace_fail.mlir – negative validation test
  full_pipeline_ok.mlir                    – full pipeline success test

heir_opt_integration.patch  – 4-line patch to tools/heir-opt.cpp (diff format)
vfhe_standalone_test.cpp    – standalone test verifiable without the MLIR library
```

## Integration Steps

1. Copy `VFHE/IR/` to `heir/lib/Dialect/VFHE/IR/`
2. Copy `ValidateVFHE/` to `heir/lib/Transforms/ValidateVFHE/`
3. Apply the patch:
   ```
   patch -p1 < heir_opt_integration.patch
   ```
4. Build with Bazel:
   ```
   bazel build //lib/Dialect/VFHE/IR:Dialect
   bazel build //lib/Transforms/ValidateVFHE:ValidateVFHE
   bazel build //tools:heir-opt
   ```
5. Run the tests:
   ```
   bazel test //tests/Transforms/validate_vfhe/...
   ```

## Validation Evidence

All TableGen steps (9 total) pass without errors under LLVM 18.1.3 (mlir-tblgen-18).
The standalone test program compiles and passes all 5/5 tests:
  - ProofClassEnum values
  - ProofClassAttr storage and retrieval
  - WitnessTraceAttr storage and retrieval
  - Classification logic (all 14 ops correctly classified)
  - Validation logic (well-formed and ill-formed modules handled correctly)
