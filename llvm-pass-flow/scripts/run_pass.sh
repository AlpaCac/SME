#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "${ROOT}/.." && pwd)"
OUT="${ROOT}/out"
mkdir -p "${OUT}"

DEFAULT_LLVM_HOME="${REPO_ROOT}/toolchains/LLVM-22.1.8-macOS-ARM64"
if [[ -z "${LLVM_HOME:-}" && -x "${DEFAULT_LLVM_HOME}/bin/opt" ]]; then
  LLVM_HOME="${DEFAULT_LLVM_HOME}"
fi

CLANGXX="${CLANGXX:-${LLVM_HOME:-}/bin/clang++}"
OPT="${OPT:-${LLVM_HOME:-}/bin/opt}"
PASS_DYLIB="${PASS_DYLIB:-${ROOT}/build/StencilPrefetchPass.dylib}"
SDKROOT="${SDKROOT:-$(xcrun --show-sdk-path 2>/dev/null || true)}"
CLANG_SDK_FLAGS=()
if [[ -n "${SDKROOT}" ]]; then
  CLANG_SDK_FLAGS=(-isysroot "${SDKROOT}")
fi

if [[ ! -x "${PASS_DYLIB}" && ! -f "${PASS_DYLIB}" ]]; then
  echo "missing pass plugin: ${PASS_DYLIB}"
  echo "run llvm-pass-flow/scripts/build_pass_macos_dynamic.sh first"
  exit 1
fi

if [[ -z "${OPT}" ]] || { ! command -v "${OPT}" >/dev/null 2>&1 && [[ ! -x "${OPT}" ]]; }; then
  echo "missing opt; set OPT=/path/to/opt"
  exit 1
fi

if [[ -z "${CLANGXX}" ]] || { ! command -v "${CLANGXX}" >/dev/null 2>&1 && [[ ! -x "${CLANGXX}" ]]; }; then
  echo "missing clang++; set CLANGXX=/path/to/clang++"
  exit 1
fi

"${CLANGXX}" -O2 -std=c++17 "${CLANG_SDK_FLAGS[@]}" -S -emit-llvm \
  "${REPO_ROOT}/stencil_sme.cpp" \
  -o "${OUT}/stencil_sme.before.ll"

"${OPT}" -S \
  -load-pass-plugin "${PASS_DYLIB}" \
  -passes=stencil-prefetch \
  "${OUT}/stencil_sme.before.ll" \
  -o "${OUT}/stencil_sme.after.ll"

"${CLANGXX}" -O2 -std=c++17 "${CLANG_SDK_FLAGS[@]}" \
  "${OUT}/stencil_sme.after.ll" \
  -o "${OUT}/stencil_sme.prefetch"

"${OUT}/stencil_sme.prefetch"
