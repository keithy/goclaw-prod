# Makefile for building versioned picoclaw binaries for Alpine Linux (volume mounting)
#
#   make build              Build current arch → RELEASES/picoclaw/$GOARCH/$VERSION/picoclaw
#   make build-amd64       Build amd64 only
#   make build-arm64       Build arm64 only
#   make build-all         Build both amd64 + arm64, update latest symlinks
#   make clean             Remove RELEASES/picoclaw/
#
# Run from picoclaw-build/ directory:
#   cd picoclaw-build && make build
#
# Version is derived from the picoclaw submodule git tag:
#   cd ../picoclaw && git describe --tags --abbrev=0
#
# Output structure (at podclaws/RELEASES/picoclaw/):
#   picoclaw/amd64/
#     v0.9.0/picoclaw       ← binary
#     v0.9.0/picoclaw.sha256 ← checksum
#     latest -> v0.9.0      ← symlink
#   picoclaw/arm64/
#     v0.9.0/picoclaw
#     v0.9.0/picoclaw.sha256
#     latest -> v0.9.0

SHELL := /bin/bash
PICOCLAW_DIR := $(abspath $(CURDIR)/../picoclaw)
PODCLAWS_RELEASES ?= $(abspath $(CURDIR)/../RELEASES)
RELEASES_DIR := $(PODCLAWS_RELEASES)/picoclaw

VERSION := $(shell cd $(PICOCLAW_DIR) && git describe --tags --abbrev=0 2>/dev/null || echo dev)
GIT_COMMIT := $(shell cd $(PICOCLAW_DIR) && git rev-parse --short=8 HEAD 2>/dev/null || echo dev)
BUILD_TIME := $(shell date +%FT%T%z)
GO_VERSION := $(shell go version | awk '{print $$3}')
CONFIG_PKG := github.com/sipeed/picoclaw/pkg/config
LDFLAGS := -X $(CONFIG_PKG).Version=$(VERSION) -X $(CONFIG_PKG).GitCommit=$(GIT_COMMIT) -X $(CONFIG_PKG).BuildTime=$(BUILD_TIME) -X $(CONFIG_PKG).GoVersion=$(GO_VERSION) -s -w

GOOS := linux
GOARCH := $(shell go env GOARCH 2>/dev/null || echo amd64)
GO := CGO_ENABLED=0 go

.PHONY: build build-amd64 build-arm64 build-all clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

# --------------------------------------------------------------------
# Generate workspace/skills (required before build)
# --------------------------------------------------------------------

generate:
	@cd $(PICOCLAW_DIR) && rm -rf ./cmd/picoclaw/workspace 2>/dev/null || true
	@cd $(PICOCLAW_DIR) && $(GO) generate ./...

# --------------------------------------------------------------------
# Build current host architecture
# --------------------------------------------------------------------

build: generate build-$(GOARCH) latest-link

# --------------------------------------------------------------------
# Build amd64
# --------------------------------------------------------------------

build-amd64: $(RELEASES_DIR)/amd64/$(VERSION)/picoclaw

$(RELEASES_DIR)/amd64/$(VERSION)/picoclaw: generate
	@mkdir -p $(RELEASES_DIR)/amd64/$(VERSION)
	cd $(PICOCLAW_DIR) && GOOS=$(GOOS) GOARCH=amd64 $(GO) build -ldflags="$(LDFLAGS)" -o $(RELEASES_DIR)/amd64/$(VERSION)/picoclaw ./cmd/picoclaw
	@cd $(RELEASES_DIR)/amd64/$(VERSION) && sha256sum picoclaw > picoclaw.sha256
	@echo "  VERSION  $(VERSION)"
	@echo "  ARCH     $(GOOS)/amd64"
	@echo "  OUTPUT   $(RELEASES_DIR)/amd64/$(VERSION)/"
	@echo "Built: $(RELEASES_DIR)/amd64/$(VERSION)/picoclaw"

# --------------------------------------------------------------------
# Build arm64
# --------------------------------------------------------------------

build-arm64: $(RELEASES_DIR)/arm64/$(VERSION)/picoclaw

$(RELEASES_DIR)/arm64/$(VERSION)/picoclaw: generate
	@mkdir -p $(RELEASES_DIR)/arm64/$(VERSION)
	cd $(PICOCLAW_DIR) && GOOS=$(GOOS) GOARCH=arm64 $(GO) build -ldflags="$(LDFLAGS)" -o $(RELEASES_DIR)/arm64/$(VERSION)/picoclaw ./cmd/picoclaw
	@cd $(RELEASES_DIR)/arm64/$(VERSION) && sha256sum picoclaw > picoclaw.sha256
	@echo "  VERSION  $(VERSION)"
	@echo "  ARCH     $(GOOS)/arm64"
	@echo "  OUTPUT   $(RELEASES_DIR)/arm64/$(VERSION)/"
	@echo "Built: $(RELEASES_DIR)/arm64/$(VERSION)/picoclaw"

# --------------------------------------------------------------------
# Build all architectures
# --------------------------------------------------------------------

build-all: generate build-amd64 build-arm64 latest-link
	@echo ""
	@echo "All architectures built:"
	@find $(RELEASES_DIR) -type f -name "picoclaw*" | sort

# --------------------------------------------------------------------
# Symlinks: RELEASES/picoclaw/$GOARCH/latest → RELEASES/picoclaw/$GOARCH/$VERSION
# --------------------------------------------------------------------

latest-link:
	@ln -sfn $(VERSION) $(RELEASES_DIR)/$(GOARCH)/latest
	@echo "  $(GOARCH)/latest → $(VERSION)"

# --------------------------------------------------------------------
# Cleanup
# --------------------------------------------------------------------

clean: ## Remove all versioned releases
	rm -rf $(RELEASES_DIR)
	@echo "Removed $(RELEASES_DIR)/"