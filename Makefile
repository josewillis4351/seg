BIN_DIR = bin
BIN_NAME = sfui
BUILD_ARCH = amd64
BUILD_OS = linux
DATE=$(shell date -u)
HASH=$(shell git rev-parse --short HEAD)

.PHONY:	all
all: | filebrowser UI prod

dev: main.go
	@go build -o $(BIN_DIR)/$(BIN_NAME) -race -ldflags '-X "main.buildTime=$(DATE)" -X "main.buildHash=$(HASH)"'

.PHONY: prod
prod: main.go
	@echo "[+] Building SFUI...."
	@CGO_ENABLED=0 GOOS=$(BUILD_OS) GOARCH=$(BUILD_ARCH) go build -a -tags prod -ldflags '-w' -ldflags '-X "main.buildTime=$(DATE)" -X "main.buildHash=$(HASH)"' -o $(BIN_DIR)/$(BIN_NAME)
	@echo "[+] Stripping unnecessary symbols..."
	@strip $(BIN_DIR)/$(BIN_NAME)
	@echo "[+] Done Building"

.PHONY: UI
UI:
	@rm -rf ./ui/dist/sf-ui
	@mkdir ./ui/dist/sf-ui
	@npm run build --prefix ./ui/

clean:
	@rm -f $(BIN_DIR)/*
	@rm -rf ./ui/dist/sf-ui
	@rm -rf ./filebrowser-ui/dist/*

.PHONY: filebrowser
filebrowser:
	@cd filebrowser-ui && npm ci && NODE_OPTIONS=--openssl-legacy-provider npm run build
	@rm -rf ui/src/assets/filebrowser_client/*
	@cp -r filebrowser-ui/dist/* ui/src/assets/filebrowser_client/