#include "lib/Dialect/VFHE/IR/VFHEDialect.h"

#include "lib/Dialect/VFHE/IR/VFHEAttributes.h"
#include "lib/Dialect/VFHE/IR/VFHEEnums.h"
#include "lib/Dialect/VFHE/IR/VFHEOps.h"
#include "llvm/include/llvm/ADT/TypeSwitch.h"              // from @llvm-project
#include "mlir/include/mlir/IR/Builders.h"                 // from @llvm-project
#include "mlir/include/mlir/IR/DialectImplementation.h"    // from @llvm-project

// Generated dialect .inc
#include "lib/Dialect/VFHE/IR/VFHEDialect.cpp.inc"

// Generated enum .inc
#define GET_ATTRDEF_CLASSES
#include "lib/Dialect/VFHE/IR/VFHEEnums.cpp.inc"

// Generated attribute .inc
#define GET_ATTRDEF_CLASSES
#include "lib/Dialect/VFHE/IR/VFHEAttributes.cpp.inc"

namespace mlir {
namespace heir {
namespace vfhe {

void VFHEDialect::initialize() {
  addAttributes<
#define GET_ATTRDEF_LIST
#include "lib/Dialect/VFHE/IR/VFHEAttributes.cpp.inc"
      >();
  addOperations<
#define GET_OP_LIST
#include "lib/Dialect/VFHE/IR/VFHEOps.cpp.inc"
      >();
}

}  // namespace vfhe
}  // namespace heir
}  // namespace mlir
