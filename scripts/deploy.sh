#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-my-app}"
REGISTRY="${REGISTRY:-ghcr.io/medindev}"
IMAGE="${IMAGE:-${REGISTRY}/${APP_NAME}}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
VERSION="${VERSION:-0.1.0}"
GIT_SHA="$(git rev-parse --short HEAD)"
DEV_TAG="${GIT_SHA}"
ENV_TAG="${ENVIRONMENT}-${VERSION}"
LATEST_TAG="latest"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f application/Dockerfile \
  -t "${IMAGE}:${DEV_TAG}" \
  -t "${IMAGE}:${ENV_TAG}" \
  -t "${IMAGE}:${LATEST_TAG}" \
  ./application

kubectl apply -f kubernetes/base/namespace.yaml
kubectl apply -f kubernetes/base/configmap.yaml
kubectl apply -f kubernetes/base/secret.yaml
kubectl apply -f kubernetes/base/pvc.yaml
kubectl apply -f kubernetes/base/deployment.yaml
kubectl apply -f kubernetes/base/service.yaml
kubectl apply -f kubernetes/base/ingress.yaml
kubectl apply -f kubernetes/base/hpa.yaml
