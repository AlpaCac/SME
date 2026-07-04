#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "${ROOT}/.." && pwd)"
OUT="${ROOT}/out"
mkdir -p "${OUT}"

CLANGXX="${CLANGXX:-clang++}"
OPT="${OPT:-opt}"
PASS_DYLIB="${PASS_DYLIB:-${ROOT}/build/StencilPrefetchPass.dylib}"
SDKROOT="${SDKROOT:-$(xcrun --show-sdk-path 2>/dev/null || true)}"
CLANG_SDK_FLAGS=()
if [[ -n "${SDKROOT}" ]]; then
  CLANG_SDK_FLAGS=(-isysroot "${SDKROOT}")
fi

if [[ ! -x "${PASS_DYLIB}" && ! -f "${PASS_DYLIB}" ]]; then
  echo "missing pass plugin: ${PASS_DYLIB}"
  echo "run scripts/build_pass.sh first"
  exit 1
fi

if ! command -v "${OPT}" >/dev/null 2>&1 && [[ ! -x "${OPT}" ]]; then
  echo "missing opt; set OPT=/path/to/opt"
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
