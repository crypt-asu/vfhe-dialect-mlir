#include "lib/Dialect/VFHE/IR/VFHEOps.h"

#include "lib/Dialect/VFHE/IR/VFHEAttributes.h"
#include "lib/Dialect/VFHE/IR/VFHEDialect.h"
#include "mlir/include/mlir/IR/Builders.h"             // from @llvm-project
#include "mlir/include/mlir/IR/BuiltinAttributes.h"    // from @llvm-project
#include "mlir/include/mlir/IR/OpImplementation.h"     // from @llvm-project

#define GET_OP_CLASSES
#include "lib/Dialect/VFHE/IR/VFHEOps.cpp.inc"
