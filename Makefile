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
build:
	@echo "Ensuring $(BUILD_DIR) exists"
	@mkdir -p $(BUILD_DIR)
	@echo "Building application ($(APP_DIR)/main.go) for: $(GOOS)/$(GOARCH) (Cgo: $(CGO_ENABLED))"
	@$(IN_APP_DIR) go build -o "$(BUILD_DIR)/app" main.go
	@echo "Copying assets from $(APP_DIR) to $(BUILD_DIR)"
	@$(IN_APP_DIR) cp "index.html" "$(BUILD_DIR)/index.html"
	@$(IN_APP_DIR) cp "styles.css" "$(BUILD_DIR)/styles.css"
	@echo "Done. Build output:"
	@ls -laR "$(BUILD_DIR)"
	@echo "******************************************************"
	@echo "Run in debug mode: $(BUILD_DIR)/app"
	@echo "Run in production mode: GIN_MODE=release $(BUILD_DIR)/app"
	@echo "******************************************************"

.PHONY:clean
clean:
	@echo "Deleting $(BUILD_DIR)"
	@rm -r $(BUILD_DIR)

