# Fitness App Makefile
.PHONY: help generate-go generate-dart build-server run-server clean

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

generate-go: ## Generate Go server code from OpenAPI spec
	@echo "Generating Go server code..."
	~/go/bin/oapi-codegen -package api -generate types,chi-server,spec -o server/api/generated.go api/openapi.yaml
	@echo "✅ Go code generated successfully"

generate-dart: ## Generate Dart client code from OpenAPI spec (requires openapi-generator-cli)
	@echo "Generating Dart client code..."
	@if command -v openapi-generator-cli >/dev/null 2>&1; then \
		openapi-generator-cli generate -i api/openapi.yaml -g dart-dio -o ascent/lib/api_client --additional-properties=pubName=fitness_api_client; \
		echo "✅ Dart code generated successfully"; \
	else \
		echo "❌ openapi-generator-cli not found. Install with: npm install -g @openapitools/openapi-generator-cli"; \
	fi

generate: generate-go ## Generate code for all platforms
	@echo "Code generation complete"

build-server: ## Build the Go server
	@echo "Building Go server..."
	cd server && go build -o bin/fitness-server .
	@echo "✅ Server built successfully"

run-server: ## Run the Go server
	@echo "Starting server..."
	cd server && go run .

clean: ## Clean generated files and build artifacts
	@echo "Cleaning generated files..."
	rm -f server/api/generated.go
	rm -rf server/bin/
	rm -rf ascent/lib/api_client/
	@echo "✅ Clean complete"

install-tools: ## Install required code generation tools
	@echo "Installing oapi-codegen..."
	go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest
	@echo "To install openapi-generator-cli, run: npm install -g @openapitools/openapi-generator-cli"
	@echo "✅ Tools installation complete"