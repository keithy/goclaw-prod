# Makefile for building picoclaw binary for Alpine Linux (volume mounting)
#
#   make build              Build current arch → RELEASES/picoclaw/$VERSION/picoclaw
#   make clean              Remove RELEASES/picoclaw/
#   make image              Build image from Dockerfile
#
# Run from use/picoclaw/ directory:
#   cd use/picoclaw && make build
#
# Version is derived from the picoclaw submodule git tag:
#   cd ../picoclaw && git describe --tags --abbrev=0
#
# Output structure (at RELEASES/picoclaw/):
#   picoclaw/
#     v0.9.0/picoclaw        ← binary
#     v0.9.0/picoclaw.sha256 ← checksum
#     latest -> v0.9.0       ← symlink

SHELL := /bin/bash
PICOCLAW_DIR := $(abspath $(CURDIR)/../../picoclaw)
RELEASES_DIR := $(abspath $(CURDIR)/../../RELEASES/picoclaw)

VERSION := $(shell cd $(PICOCLAW_DIR) && git describe --tags --abbrev=0 2>/dev/null || echo dev)
GIT_COMMIT := $(shell cd $(PICOCLAW_DIR) && git rev-parse --short=8 HEAD 2>/dev/null || echo dev)
BUILD_TIME := $(shell date +%FT%T%z)
GO_VERSION := $(shell go version | awk '{print $$3}')
CONFIG_PKG := github.com/sipeed/picoclaw/pkg/config
LDFLAGS := -X $(CONFIG_PKG).Version=$(VERSION) -X $(CONFIG_PKG).GitCommit=$(GIT_COMMIT) -X $(CONFIG_PKG).BuildTime=$(BUILD_TIME) -X $(CONFIG_PKG).GoVersion=$(GO_VERSION) -s -w

GOOS := linux
GOARCH := $(shell go env GOARCH 2>/dev/null || echo amd64)
GO := CGO_ENABLED=0 go

.PHONY: build clean help

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

build: generate $(RELEASES_DIR)/$(VERSION)/picoclaw latest-link

$(RELEASES_DIR)/$(VERSION)/picoclaw: | generate
	@mkdir -p $(RELEASES_DIR)/$(VERSION)
	cd $(PICOCLAW_DIR) && GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build -ldflags="$(LDFLAGS)" -o $(RELEASES_DIR)/$(VERSION)/picoclaw ./cmd/picoclaw
	@cd $(RELEASES_DIR)/$(VERSION) && sha256sum picoclaw > picoclaw.sha256
	@echo "  VERSION  $(VERSION)"
	@echo "  ARCH     $(GOOS)/$(GOARCH)"
	@echo "  OUTPUT   $(RELEASES_DIR)/$(VERSION)/"
	@echo "Built: $(RELEASES_DIR)/$(VERSION)/picoclaw"

# --------------------------------------------------------------------
# Symlink: RELEASES/picoclaw/latest → RELEASES/picoclaw/$VERSION
# --------------------------------------------------------------------

latest-link:
	@ln -sfn $(VERSION) $(RELEASES_DIR)/latest
	@echo "  latest → $(VERSION)"

# --------------------------------------------------------------------
# Cleanup
# --------------------------------------------------------------------

clean: ## Remove all versioned releases
	rm -rf $(RELEASES_DIR)
	@echo "Removed $(RELEASES_DIR)/"