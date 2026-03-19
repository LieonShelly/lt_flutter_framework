.PHONY: setup clean codegen watch reset help

PACKAGE ?=

help:
	@echo "Flutter Project Scripts"
	@echo "======================="
	@echo ""
	@echo "Available commands:"
	@echo "  make setup              - Install all dependencies (FVM + packages)"
	@echo "  make clean              - Clean all build artifacts"
	@echo "  make codegen            - Run code generation"
	@echo "  make watch              - Run code generation in watch mode"
	@echo "  make reset              - Clean, setup, and codegen (full reset)"
	@echo "  make help               - Show this help message"
	@echo ""
	@echo "Package-specific operations:"
	@echo "  make setup PACKAGE=name    - Setup specific package"
	@echo "  make clean PACKAGE=name    - Clean specific package"
	@echo "  make codegen PACKAGE=name  - Generate code for specific package"
	@echo "  make watch PACKAGE=name    - Watch mode for specific package"
	@echo ""
	@echo "Examples:"
	@echo "  make setup PACKAGE=reflection_data"
	@echo "  make codegen PACKAGE=lt_app"
	@echo "  make watch PACKAGE=user_data"

setup:
ifdef PACKAGE
	@dart shell/bin/setup.dart --package $(PACKAGE)
else
	@dart shell/bin/setup.dart
endif

clean:
ifdef PACKAGE
	@dart shell/bin/clean.dart --package $(PACKAGE)
else
	@dart shell/bin/clean.dart
endif

codegen:
ifdef PACKAGE
	@dart shell/bin/codegen.dart --package $(PACKAGE)
else
	@dart shell/bin/codegen.dart
endif

watch:
ifdef PACKAGE
	@dart shell/bin/codegen.dart --package $(PACKAGE) --watch
else
	@dart shell/bin/codegen.dart --watch
endif

reset: clean setup codegen
	@echo ""
	@echo "✅ Full reset completed!"
