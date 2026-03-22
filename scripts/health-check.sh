#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-dev}"
APP_LABEL="${APP_LABEL:-my-app}"

kubectl get namespace "${NAMESPACE}" >/dev/null
kubectl get pods -n "${NAMESPACE}" -l "app=${APP_LABEL}"
kubectl get endpoints -n "${NAMESPACE}" "${APP_LABEL}"
kubectl get hpa -n "${NAMESPACE}" "${APP_LABEL}" || true
