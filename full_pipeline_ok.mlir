// RUN: heir-opt --vfhe-classify-ops --vfhe-validate-classification %s
//
// vHEIR: Test that the full pipeline
//   --vfhe-classify-ops | --vfhe-validate-classification
// succeeds on a well-formed mgmt-level circuit and produces no errors.
//
// --vfhe-classify-ops  assigns all proof_class and witness_trace attributes;
// --vfhe-validate-classification then verifies the invariants hold.

module {
  func.func @full_pipeline_ok(
      %arg0: !secret.secret<tensor<8xi16>> {mgmt.mgmt = #mgmt.mgmt<level = 2>},
      %arg1: !secret.secret<tensor<8xi16>> {mgmt.mgmt = #mgmt.mgmt<level = 2>})
      -> !secret.secret<tensor<8xi16>> {

    %0 = secret.generic(
        %arg0 : !secret.secret<tensor<8xi16>>,
        %arg1 : !secret.secret<tensor<8xi16>>) {
    ^bb0(%in0: tensor<8xi16>, %in1: tensor<8xi16>):
      %mul   = arith.muli %in0, %in1
                   {mgmt.mgmt = #mgmt.mgmt<level = 2, dimension = 3>}
                   : tensor<8xi16>
      %relin = mgmt.relinearize %mul
                   {mgmt.mgmt = #mgmt.mgmt<level = 2>}
                   : tensor<8xi16>
      %mod   = mgmt.modreduce %relin
                   {mgmt.mgmt = #mgmt.mgmt<level = 1>}
                   : tensor<8xi16>
      %add   = arith.addi %mod, %in0
                   {mgmt.mgmt = #mgmt.mgmt<level = 1>}
                   : tensor<8xi16>
      secret.yield %add : tensor<8xi16>
    } -> !secret.secret<tensor<8xi16>>

    return %0 : !secret.secret<tensor<8xi16>>
  }
}
