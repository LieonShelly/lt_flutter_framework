.PHONY: setup clean codegen watch reset help

help:
	@echo "Flutter Project Scripts"
	@echo "======================="
	@echo ""
	@echo "Available commands:"
	@echo "  make setup    - Install all dependencies (FVM + packages)"
	@echo "  make clean    - Clean all build artifacts"
	@echo "  make codegen  - Run code generation"
	@echo "  make watch    - Run code generation in watch mode"
	@echo "  make reset    - Clean, setup, and codegen (full reset)"
	@echo "  make help     - Show this help message"

setup:
	@dart shell/bin/setup.dart

clean:
	@dart shell/bin/clean.dart

codegen:
	@dart shell/bin/codegen.dart

watch:
	@dart shell/bin/codegen.dart --watch

reset: clean setup codegen
	@echo ""
	@echo "✅ Full reset completed!"
