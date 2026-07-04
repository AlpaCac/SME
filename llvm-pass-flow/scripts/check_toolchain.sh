#!/usr/bin/env bash
set -euo pipefail

if command -v llvm-config >/dev/null 2>&1; then
  LLVM_CONFIG="$(command -v llvm-config)"
elif [[ -n "${LLVM_CONFIG:-}" && -x "${LLVM_CONFIG}" ]]; then
  LLVM_CONFIG="${LLVM_CONFIG}"
else
  echo "missing llvm-config"
  echo "set LLVM_CONFIG=/path/to/llvm-config or install a full LLVM toolchain"
  exit 1
fi

if command -v opt >/dev/null 2>&1; then
  OPT="$(command -v opt)"
elif [[ -n "${OPT:-}" && -x "${OPT}" ]]; then
  OPT="${OPT}"
else
  echo "missing opt"
  echo "set OPT=/path/to/opt or install a full LLVM toolchain"
  exit 1
fi

echo "llvm-config: ${LLVM_CONFIG}"
"${LLVM_CONFIG}" --version
echo "opt: ${OPT}"
"${OPT}" --version | head -n 1
