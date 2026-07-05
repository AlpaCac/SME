#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${ROOT}/out"
mkdir -p "${OUT}"

EXE="${1:-${OUT}/stencil_sme.prefetch}"
RUN_NX="${2:-${RUN_NX:-256}}"
RUN_NY="${3:-${RUN_NY:-256}}"
RUN_ITERATIONS="${4:-${RUN_ITERATIONS:-50}}"
RUN_WARMUP="${5:-${RUN_WARMUP:-5}}"

TRACE_TEMPLATE="${TRACE_TEMPLATE:-Counters}"
TRACE_OUT="${TRACE_OUT:-${OUT}/stencil_sme_counters.trace}"
TRACE_TOC="${TRACE_TOC:-${OUT}/stencil_sme_counters_toc.xml}"

if ! command -v xctrace >/dev/null 2>&1; then
  echo "xctrace not found; hardware counter profiling is only available with Xcode tools"
  exit 1
fi

if [[ ! -x "${EXE}" ]]; then
  echo "executable not found or not executable: ${EXE}"
  echo "run llvm-pass-flow/scripts/run_pass.sh first"
  exit 1
fi

echo "recording hardware counters with xctrace template: ${TRACE_TEMPLATE}"
echo "trace output: ${TRACE_OUT}"

xctrace record \
  --template "${TRACE_TEMPLATE}" \
  --output "${TRACE_OUT}" \
  --target-stdout - \
  --launch -- "${EXE}" "${RUN_NX}" "${RUN_NY}" "${RUN_ITERATIONS}" "${RUN_WARMUP}"

if xctrace export --input "${TRACE_OUT}" --toc --output "${TRACE_TOC}"; then
  echo "trace table of contents written to ${TRACE_TOC}"
else
  echo "trace was recorded, but exporting table of contents failed"
fi

echo "open ${TRACE_OUT} in Instruments to inspect cache/miss counter events"
