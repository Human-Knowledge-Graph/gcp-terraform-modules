.PHONY: docs docs-check fmt fmt-check validate install-terraform-docs help

# Generate documentation for all modules using terraform-docs
docs:
	@echo "Generating documentation for all modules..."
	@for dir in modules/*/; do \
		if [ -f "$$dir/README.md" ]; then \
			echo "Processing $$dir"; \
			terraform-docs markdown table --output-file README.md --output-mode inject "$$dir"; \
		fi \
	done
	@echo "Done!"

# Check if documentation is up to date (for CI)
docs-check:
	@echo "Checking if documentation is up to date..."
	@for dir in modules/*/; do \
		if [ -f "$$dir/README.md" ]; then \
			terraform-docs markdown table --output-file README.md --output-mode inject --output-check "$$dir" || exit 1; \
		fi \
	done
	@echo "Documentation is up to date!"

# Format all Terraform files
fmt:
	terraform fmt -recursive

# Check formatting (for CI)
fmt-check:
	terraform fmt -check -recursive

# Validate all modules
validate:
	@echo "Validating all modules..."
	@for dir in modules/*/; do \
		echo "Validating $$dir"; \
		(cd "$$dir" && terraform init -backend=false -input=false > /dev/null && terraform validate) || exit 1; \
	done
	@echo "All modules valid!"

# Install terraform-docs (macOS)
install-terraform-docs:
	brew install terraform-docs

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make docs                  - Generate README documentation for all modules"
	@echo "  make docs-check            - Check if documentation is up to date (CI)"
	@echo "  make fmt                   - Format all Terraform files"
	@echo "  make fmt-check             - Check Terraform formatting (CI)"
	@echo "  make validate              - Validate all modules"
	@echo "  make install-terraform-docs - Install terraform-docs (macOS)"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - terraform-docs: brew install terraform-docs"
