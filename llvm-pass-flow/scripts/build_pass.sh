#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -n "${LLVM_CONFIG:-}" ]]; then
  LLVM_DIR="$("${LLVM_CONFIG}" --cmakedir)"
elif command -v llvm-config >/dev/null 2>&1; then
  LLVM_DIR="$(llvm-config --cmakedir)"
else
  echo "missing llvm-config; cannot build LLVM pass plugin"
  echo "example: LLVM_CONFIG=/opt/homebrew/opt/llvm/bin/llvm-config $0"
  exit 1
fi

cmake -S "${ROOT}" -B "${ROOT}/build" -DLLVM_DIR="${LLVM_DIR}" -DCMAKE_BUILD_TYPE=Release
cmake --build "${ROOT}/build" --config Release
