load("@heir//lib/Dialect:dialect.bzl", "add_heir_dialect_library")
load("@llvm-project//mlir:tblgen.bzl", "td_library")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(
    default_applicable_licenses = ["@heir//:license"],
    default_visibility = ["//visibility:public"],
)

td_library(
    name = "td_files",
    srcs = [
        "VFHEDialect.td",
        "VFHEEnums.td",
        "VFHEAttributes.td",
        "VFHEOps.td",
    ],
    includes = ["../../../.."],
    deps = [
        "@llvm-project//mlir:BuiltinDialectTdFiles",
        "@llvm-project//mlir:OpBaseTdFiles",
        "@llvm-project//mlir:SideEffectInterfacesTdFiles",
        "@llvm-project//mlir:EnumAttrTdFiles",
    ],
)

add_heir_dialect_library(
    name = "dialect_inc_gen",
    dialect = "VFHE",
    dialect_doc_name = "vfhe",
    kind = "dialect",
    td_file = "VFHEDialect.td",
    deps = [":td_files"],
)

add_heir_dialect_library(
    name = "enum_inc_gen",
    dialect = "VFHE",
    dialect_doc_name = "vfhe",
    kind = "enum",
    td_file = "VFHEEnums.td",
    deps = [
        ":dialect_inc_gen",
        ":td_files",
    ],
)

add_heir_dialect_library(
    name = "attrs_inc_gen",
    dialect = "VFHE",
    dialect_doc_name = "vfhe",
    kind = "attr",
    td_file = "VFHEAttributes.td",
    deps = [
        ":dialect_inc_gen",
        ":enum_inc_gen",
        ":td_files",
    ],
)

add_heir_dialect_library(
    name = "ops_inc_gen",
    dialect = "VFHE",
    dialect_doc_name = "vfhe",
    kind = "op",
    td_file = "VFHEOps.td",
    deps = [
        ":attrs_inc_gen",
        ":dialect_inc_gen",
        ":td_files",
    ],
)

cc_library(
    name = "Dialect",
    srcs = [
        "VFHEDialect.cpp",
        "VFHEOps.cpp",
    ],
    hdrs = [
        "VFHEAttributes.h",
        "VFHEDialect.h",
        "VFHEEnums.h",
        "VFHEOps.h",
    ],
    deps = [
        ":attrs_inc_gen",
        ":dialect_inc_gen",
        ":enum_inc_gen",
        ":ops_inc_gen",
        "@llvm-project//llvm:Support",
        "@llvm-project//mlir:Dialect",
        "@llvm-project//mlir:IR",
        "@llvm-project//mlir:Support",
    ],
)
