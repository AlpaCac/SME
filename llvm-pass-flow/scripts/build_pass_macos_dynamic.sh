#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "${ROOT}/.." && pwd)"
DEFAULT_LLVM_HOME="${REPO_ROOT}/toolchains/LLVM-22.1.8-macOS-ARM64"

if [[ -z "${LLVM_HOME:-}" && -x "${DEFAULT_LLVM_HOME}/bin/llvm-config" ]]; then
  LLVM_HOME="${DEFAULT_LLVM_HOME}"
fi

if [[ -n "${LLVM_CONFIG:-}" ]]; then
  LLVM_CONFIG_BIN="${LLVM_CONFIG}"
elif [[ -n "${LLVM_HOME:-}" && -x "${LLVM_HOME}/bin/llvm-config" ]]; then
  LLVM_CONFIG_BIN="${LLVM_HOME}/bin/llvm-config"
elif command -v llvm-config >/dev/null 2>&1; then
  LLVM_CONFIG_BIN="$(command -v llvm-config)"
else
  echo "missing llvm-config; cannot build LLVM pass plugin"
  exit 1
fi

CLANGXX="${CLANGXX:-clang++}"
OUT="${ROOT}/build/StencilPrefetchPass.dylib"
mkdir -p "${ROOT}/build"

"${CLANGXX}" -fPIC -shared -std=c++17 \
  $("${LLVM_CONFIG_BIN}" --cxxflags) \
  "${ROOT}/src/StencilPrefetchPass.cpp" \
  -o "${OUT}" \
  -Wl,-undefined,dynamic_lookup

echo "built ${OUT}"
