# vHEIR – HEIR Verification Plane Extension

Bu dizin, *"vHEIR: A Proof-Carrying Compiler Architecture for Fully Homomorphic
Encryption with Integrated Verification"* makalesindeki vfhe dialect'ini ve
ValidateVFHE pass'lerini HEIR'ın gerçek kaynak ağacına eklemek için gereken
tüm dosyaları içerir.

## Dizin yapısı

```
VFHE/IR/
  VFHEDialect.td          – dialect tanımı (cppNamespace = mlir::heir::vfhe)
  VFHEEnums.td            – VFHEProofClass enum (ring_linear / ring_arith / maintenance)
  VFHEAttributes.td       – ProofClassAttr, WitnessTraceAttr
  VFHEOps.td              – vfhe.commit, vfhe.attest
  VFHEDialect.{h,cpp}     – C++ dialect implementasyonu
  VFHEEnums.h             – enum header
  VFHEAttributes.h        – attribute header
  VFHEOps.{h,cpp}         – op implementasyonu
  BUILD                   – Bazel build kuralları

ValidateVFHE/
  ValidateVFHE.td         – VFHEClassifyOps + VFHEValidateClassification pass tanımları
  ValidateVFHE.{h,cpp}    – pass implementasyonu (sınıflandırma + doğrulama)
  BUILD                   – Bazel build kuralları

validate_vfhe/ (lit testler)
  classify_mgmt_ops.mlir              – classify-ops RUN testi (FileCheck)
  validate_missing_witness_trace_fail.mlir – negatif doğrulama testi
  full_pipeline_ok.mlir               – tam pipeline başarı testi

heir_opt_integration.patch  – tools/heir-opt.cpp'e 4 satır ekleme (diff formatı)
vfhe_standalone_test.cpp    – MLIR kütüphanesi olmadan doğrulanabilir standalone test
```

## HEIR'a entegrasyon adımları

1. `VFHE/IR/` dizinini `heir/lib/Dialect/VFHE/IR/` altına kopyala
2. `ValidateVFHE/` dizinini `heir/lib/Transforms/ValidateVFHE/` altına kopyala
3. `heir_opt_integration.patch`'i uygula:
   ```
   patch -p1 < heir_opt_integration.patch
   ```
4. Bazel ile derle:
   ```
   bazel build //lib/Dialect/VFHE/IR:Dialect
   bazel build //lib/Transforms/ValidateVFHE:ValidateVFHE
   bazel build //tools:heir-opt
   ```
5. Testleri çalıştır:
   ```
   bazel test //tests/Transforms/validate_vfhe/...
   ```

## Doğrulama kanıtı

Tüm TableGen adımları (9 adet) LLVM 18.1.3 (mlir-tblgen-18) ile hatasız geçmiştir.
Standalone test programı derlenmiş ve 5/5 testi geçmiştir:
  - ProofClassEnum değerleri
  - ProofClassAttr depolama/getirme
  - WitnessTraceAttr depolama/getirme
  - Sınıflandırma mantığı (14 op'un tamamı doğru sınıflandırıldı)
  - Doğrulama mantığı (iyi biçimli ve kötü biçimli modüller doğru işlendi)
