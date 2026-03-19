.PHONY: setup clean codegen watch reset help shell-deps

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
	@echo "  make shell-deps         - Install shell script dependencies"
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

# Install shell script dependencies
shell-deps:
	@echo "📦 Installing shell script dependencies..."
	@cd shell && fvm dart pub get
	@echo "✅ Shell dependencies installed"

setup: shell-deps
ifdef PACKAGE
	@dart shell/bin/setup.dart --package $(PACKAGE)
else
	@dart shell/bin/setup.dart
endif

clean: shell-deps
ifdef PACKAGE
	@dart shell/bin/clean.dart --package $(PACKAGE)
else
	@dart shell/bin/clean.dart
endif

codegen: shell-deps
ifdef PACKAGE
	@dart shell/bin/codegen.dart --package $(PACKAGE)
else
	@dart shell/bin/codegen.dart
endif

watch: shell-deps
ifdef PACKAGE
	@dart shell/bin/codegen.dart --package $(PACKAGE) --watch
else
	@dart shell/bin/codegen.dart --watch
endif

reset:
	@echo "🔄 Starting full reset..."
	@echo "📦 Installing shell script dependencies..."
	@cd shell && fvm dart pub get
	@echo ""
	@dart shell/bin/clean.dart
	@echo ""
	@echo "📦 Reinstalling shell script dependencies after clean..."
	@cd shell && fvm dart pub get
	@echo ""
	@dart shell/bin/setup.dart
	@dart shell/bin/codegen.dart
	@echo ""
	@echo "✅ Full reset completed!"
