#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "${ROOT}/.." && pwd)"
OUT="${ROOT}/out"
mkdir -p "${OUT}"
METRICS_CSV="${METRICS_CSV:-${OUT}/metrics.csv}"
RUN_NX="${1:-${RUN_NX:-256}}"
RUN_NY="${2:-${RUN_NY:-256}}"
RUN_ITERATIONS="${3:-${RUN_ITERATIONS:-50}}"
RUN_WARMUP="${4:-${RUN_WARMUP:-5}}"

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
  "${OUT}/stencil_sme.before.ll" \
  -o "${OUT}/stencil_sme.baseline"

"${CLANGXX}" -O2 -std=c++17 "${CLANG_SDK_FLAGS[@]}" \
  "${OUT}/stencil_sme.after.ll" \
  -o "${OUT}/stencil_sme.prefetch"

record_run() {
  local label="$1"
  local exe="$2"
  local output status total_ms avg_ms mcells_per_s timestamp

  echo "== ${label} =="
  output="$("${exe}" "${RUN_NX}" "${RUN_NY}" "${RUN_ITERATIONS}" "${RUN_WARMUP}")"
  printf '%s\n' "${output}"

  status="UNKNOWN"
  if [[ "${output}" == *"PASSED:"* ]]; then
    status="PASSED"
  elif [[ "${output}" == *"FAILED:"* ]]; then
    status="FAILED"
  fi

  total_ms=""
  avg_ms=""
  mcells_per_s=""
  if [[ "${output}" =~ kernel_total_ms=([^[:space:]]+) ]]; then
    total_ms="${BASH_REMATCH[1]}"
  fi
  if [[ "${output}" =~ kernel_avg_ms=([^[:space:]]+) ]]; then
    avg_ms="${BASH_REMATCH[1]}"
  fi
  if [[ "${output}" =~ mcells_per_s=([^[:space:]]+) ]]; then
    mcells_per_s="${BASH_REMATCH[1]}"
  fi

  if [[ ! -f "${METRICS_CSV}" ]]; then
    echo "timestamp,label,nx,ny,warmup,iterations,total_ms,avg_ms,mcells_per_s,status" \
      > "${METRICS_CSV}"
  fi

  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "${timestamp},${label},${RUN_NX},${RUN_NY},${RUN_WARMUP},${RUN_ITERATIONS},${total_ms},${avg_ms},${mcells_per_s},${status}" \
    >> "${METRICS_CSV}"
}

record_run "baseline" "${OUT}/stencil_sme.baseline"
record_run "${RUN_LABEL:-prefetch}" "${OUT}/stencil_sme.prefetch"
echo "metrics written to ${METRICS_CSV}"
