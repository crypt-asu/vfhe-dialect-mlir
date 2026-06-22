// RUN: heir-opt --vfhe-classify-ops %s | FileCheck %s
//
// vHEIR: Test that ciphertext operations in the mgmt dialect receive
// the correct #vfhe.proof_class annotation after --vfhe-classify-ops.
//
// This test file mirrors the IR pattern from validate_noise_fail.mlir
// (i.e. it uses secret.generic / mgmt ops over plain tensors) so that it
// runs on the same subset of HEIR dialects without requiring BGV scheme
// parameters.

// CHECK-LABEL: func.func @mul_then_modreduce
// CHECK:       arith.muli
// CHECK-SAME:  vfhe.proof_class = #vfhe.proof_class<ring_arith>
// CHECK:       mgmt.relinearize
// CHECK-SAME:  vfhe.proof_class = #vfhe.proof_class<ring_arith>
// CHECK:       mgmt.modreduce
// CHECK-SAME:  vfhe.proof_class = #vfhe.proof_class<maintenance>
// CHECK-SAME:  vfhe.witness_trace = #vfhe.witness_trace

module {
  func.func @mul_then_modreduce(
      %arg0: !secret.secret<tensor<8xi16>> {mgmt.mgmt = #mgmt.mgmt<level = 2>},
      %arg1: !secret.secret<tensor<8xi16>> {mgmt.mgmt = #mgmt.mgmt<level = 2>})
      -> !secret.secret<tensor<8xi16>> {

    %0 = secret.generic(
        %arg0 : !secret.secret<tensor<8xi16>>,
        %arg1 : !secret.secret<tensor<8xi16>>) {
    ^bb0(%in0: tensor<8xi16>, %in1: tensor<8xi16>):
      // ct*ct  -> ring_arith
      %mul  = arith.muli %in0, %in1
                  {mgmt.mgmt = #mgmt.mgmt<level = 2, dimension = 3>}
                  : tensor<8xi16>
      // relinearize -> ring_arith
      %relin = mgmt.relinearize %mul
                  {mgmt.mgmt = #mgmt.mgmt<level = 2>}
                  : tensor<8xi16>
      // modreduce -> maintenance
      %mod  = mgmt.modreduce %relin
                  {mgmt.mgmt = #mgmt.mgmt<level = 1>}
                  : tensor<8xi16>
      secret.yield %mod : tensor<8xi16>
    } -> !secret.secret<tensor<8xi16>>

    return %0 : !secret.secret<tensor<8xi16>>
  }
}
