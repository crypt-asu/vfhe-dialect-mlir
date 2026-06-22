// RUN: heir-opt --vfhe-validate-classification --verify-diagnostics %s
//
// vHEIR: Test that vfhe-validate-classification correctly rejects a module
// whose maintenance op is missing the required #vfhe.witness_trace attribute.
//
// This is the negative test: the pass should FAIL and emit the error below.

// expected-error@below {{[vHEIR] maintenance op 'mgmt.modreduce' has #vfhe.proof_class<maintenance> but is missing #vfhe.witness_trace}}
module {
  func.func @missing_witness_trace(
      %arg0: !secret.secret<tensor<8xi16>> {mgmt.mgmt = #mgmt.mgmt<level = 1>})
      -> !secret.secret<tensor<8xi16>> {

    %0 = secret.generic(
        %arg0 : !secret.secret<tensor<8xi16>>) {
    ^bb0(%in0: tensor<8xi16>):
      // This modreduce has proof_class = maintenance but NO witness_trace.
      // --vfhe-validate-classification must reject it.
      %mod = mgmt.modreduce %in0 {
          mgmt.mgmt = #mgmt.mgmt<level = 0>,
          vfhe.proof_class = #vfhe.proof_class<maintenance>
        } : tensor<8xi16>
      secret.yield %mod : tensor<8xi16>
    } -> !secret.secret<tensor<8xi16>>

    return %0 : !secret.secret<tensor<8xi16>>
  }
}
