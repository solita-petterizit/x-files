SHELL:=/usr/bin/env bash

# The directory of this Makefile, regardless of current work directory
ROOT_DIR:=$(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Build paths
APP_DIR:=$(ROOT_DIR)/app
BUILD_DIR:=$(ROOT_DIR)/build

# Helpers
IN_APP_DIR:=cd $(APP_DIR) &&

# Go build environment settings
GOOS:=linux
GOARCH:=amd64
CGO_ENABLED:=0

all: test build

.PHONY:test
test:
	@$(IN_APP_DIR) go test $(APP_DIR) -v

.PHONY:build
build: export GOOS:=$(GOOS)
build: export GOARCH:=$(GOARCH)
build: export CGO_ENABLED:=$(CGO_ENABLED)
build: $(BUILD_DIR)/app $(BUILD_DIR)/*.html $(BUILD_DIR)/*.css
	@echo "Done. Build output:"
	@ls -laR "$(BUILD_DIR)"
	@echo "******************************************************"
	@echo "Run in debug mode: $(BUILD_DIR)/app"
	@echo "Run in production mode: GIN_MODE=release $(BUILD_DIR)/app"
	@echo "******************************************************"

$(BUILD_DIR)/app: $(APP_DIR)/*.go
	@echo "Ensuring $(BUILD_DIR) exists"
	mkdir -p $(BUILD_DIR)
	@echo "Building application ($(APP_DIR)/main.go) for: $(GOOS)/$(GOARCH) (Cgo: $(CGO_ENABLED))"
	$(IN_APP_DIR) go build -o "$(BUILD_DIR)/app" main.go

$(BUILD_DIR)/*.html $(BUILD_DIR)/*.css &: $(APP_DIR)/*.html $(APP_DIR)/*.css
	@echo "Ensuring $(BUILD_DIR) exists"
	mkdir -p $(BUILD_DIR)
	@echo "Copying assets from $(APP_DIR) to $(BUILD_DIR)"
	$(IN_APP_DIR) cp "index.html" "$(BUILD_DIR)/index.html"
	$(IN_APP_DIR) cp "styles.css" "$(BUILD_DIR)/styles.css"

.PHONY:clean
clean:
	@echo "Deleting $(BUILD_DIR)"
	@rm -r $(BUILD_DIR)

# Docker config
# Prevent pushing publicly by accident
DOCKER_REGISTRY:=no-registry.local
DOCKER_IMAGE:=hello-world
DOCKER_TAG:=latest
DOCKER_FULL:=$(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)
DOCKER_BUILD_ARGS:=
EXPOSED_AT:=3000

docker: docker-build docker-run
docker-dev: docker-build docker-run-dev

docker-build:
	docker build --tag $(DOCKER_FULL) $(DOCKER_BUILD_ARGS) .

docker-run:
	docker run -p $(EXPOSED_AT):3000 $(DOCKER_FULL)

docker-run-dev:
	docker run -p $(EXPOSED_AT):3000 -e "GIN_MODE=debug" $(DOCKER_FULL)

