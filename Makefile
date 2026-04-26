.PHONY: setup clean codegen watch reset help shell-deps xcframework test coverage

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
	@echo "  make test               - Run tests for all packages"
	@echo "  make reset              - Clean, setup, and codegen (full reset)"
	@echo "  make shell-deps         - Install shell script dependencies"
	@echo "  make help               - Show this help message"
	@echo "  make xcframework MODULE=name          - Build XCFramework (Debug + Release)"
	@echo "  make xcframework MODULE=name MODE=debug   - Build Debug only (for simulator)"
	@echo "  make xcframework MODULE=name MODE=release  - Build Release only (for device)"
	@echo "  make build-ios          - Build iOS IPA and upload to TestFlight"
	@echo ""
	@echo "Package-specific operations:"
	@echo "  make setup PACKAGE=name    - Setup specific package"
	@echo "  make clean PACKAGE=name    - Clean specific package"
	@echo "  make codegen PACKAGE=name  - Generate code for specific package"
	@echo "  make watch PACKAGE=name    - Watch mode for specific package"
	@echo "  make test PACKAGE=name     - Run tests for specific package"
	@echo ""
	@echo "Examples:"
	@echo "  make setup PACKAGE=reflection_data"
	@echo "  make codegen PACKAGE=lt_app"
	@echo "  make watch PACKAGE=user_data"
	@echo "  make xcframework MODULE=answer_detail_module"
	@echo "  make xcframework MODULE=answer_detail_module MODE=debug"

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

test: shell-deps
ifdef PACKAGE
	@dart shell/bin/test.dart --package $(PACKAGE)
else
	@dart shell/bin/test.dart
endif

coverage: shell-deps
ifdef PACKAGE
	@dart shell/bin/test.dart --package $(PACKAGE) --coverage
else
	@dart shell/bin/test.dart --coverage
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

MODULE ?=
MODE ?= all

xcframework: shell-deps
ifndef MODULE
	@echo "❌ 缺少 MODULE 参数"
	@echo "用法: make xcframework MODULE=<module_name> [MODE=debug|release|all]"
	@echo "示例: make xcframework MODULE=answer_detail_module"
	@echo "      make xcframework MODULE=answer_detail_module MODE=debug"
	@exit 1
else
	@dart shell/bin/build_xcframework.dart --module $(MODULE) --mode $(MODE)
endif

build-ios: shell-deps
	@echo "🚀 Starting iOS Build..."
	@dart shell/bin/build_ios.dart $(if $(APPLE_ID),-u $(APPLE_ID)) $(if $(PASSWORD),-p $(PASSWORD)) $(if $(API_KEY),--api-key $(API_KEY)) $(if $(API_ISSUER),--api-issuer $(API_ISSUER))

