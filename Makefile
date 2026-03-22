.PHONY: check-tools minikube-start minikube-stop namespaces-delete namespaces-create k8s-apply skaffold-dev image-buildx image-tags load-test

APP_NAME ?= my-app
REGISTRY ?= ghcr.io/medindev
IMAGE ?= $(REGISTRY)/$(APP_NAME)
ENV ?= dev
VERSION ?= 0.1.0
GIT_SHA := $(shell git rev-parse --short HEAD)
DEV_TAG := $(GIT_SHA)
ENV_TAG := $(ENV)-$(VERSION)
LATEST_TAG := latest
PLATFORMS ?= linux/amd64,linux/arm64

check-tools:
	@docker --version
	@kubectl version --client=true
	@helm version
	@skaffold version
	@k6 version
	@minikube version

minikube-start:
	@minikube start --cpus=4 --memory=8192 --driver=docker
	@minikube addons enable ingress
	@minikube addons enable metrics-server
	@minikube addons enable dashboard

minikube-stop:
	@minikube stop

namespaces-delete:
	@kubectl delete namespace dev staging monitoring logging --ignore-not-found=true

namespaces-create:
	@kubectl apply -f kubernetes/base/namespace.yaml

k8s-apply:
	@kubectl apply -f kubernetes/base/configmap.yaml
	@kubectl apply -f kubernetes/base/secret.yaml
	@kubectl apply -f kubernetes/base/pvc.yaml
	@kubectl apply -f kubernetes/base/deployment.yaml
	@kubectl apply -f kubernetes/base/service.yaml
	@kubectl apply -f kubernetes/base/ingress.yaml
	@kubectl apply -f kubernetes/base/hpa.yaml

skaffold-dev:
	@skaffold dev --port-forward --tail

image-tags:
	@echo $(IMAGE):$(DEV_TAG)
	@echo $(IMAGE):$(ENV_TAG)
	@echo $(IMAGE):$(LATEST_TAG)

image-buildx:
	@docker buildx build \
		--platform $(PLATFORMS) \
		-f application/Dockerfile \
		-t $(IMAGE):$(DEV_TAG) \
		-t $(IMAGE):$(ENV_TAG) \
		-t $(IMAGE):$(LATEST_TAG) \
		./application

load-test:
	@k6 run --config tests/performance/k6-config.json tests/performance/k6-script.js
