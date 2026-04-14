# Tech Stack

## Runtime & SDK
- **Flutter** 3.35.7 (managed via FVM)
- **Dart SDK** ^3.8.1
- **FVM** for Flutter version management (see `.fvmrc`)

## State Management & DI
- **Riverpod** (flutter_riverpod + riverpod_annotation + riverpod_generator)
- Providers are code-generated via `@riverpod` annotations

## Routing
- **GoRouter** for declarative navigation

## Networking
- **Dio** for HTTP requests
- Custom `ApiClient` abstraction in `packages/core/network`

## Serialization & Code Generation
- **Freezed** + **freezed_annotation** for immutable data models
- **json_serializable** + **json_annotation** for JSON serialization
- **build_runner** for all code generation
- Custom `@ltDeserialization` annotation (from `lt_annotation` package)

## Storage
- **flutter_secure_storage** for token/credential storage
- **path_provider** for file system paths

## UI
- **flutter_svg**, **cached_network_image**, **flutter_cache_manager**
- Custom UI component library: `packages/core/lt_uicomponent`

## Linting
- **flutter_lints** (shared via `packages/core/analysis_defaults`)

## Testing
- **flutter_test** (widget tests)
- **test** (unit tests for pure Dart packages)
- **mockito** for mocking

## Build Tooling
- **Makefile** at project root for common tasks
- **Dart shell scripts** in `shell/bin/` for setup, clean, codegen, and XCFramework builds
- **Dart Workspace** (`resolution: workspace`) for unified dependency version management

## Common Commands

All commands should be run from the project root.

```bash
# Install dependencies (all packages)
make setup

# Install dependencies for a specific package
make setup PACKAGE=reflection_data

# Run code generation (all packages)
make codegen

# Run code generation for a specific package
make codegen PACKAGE=lt_app

# Code generation in watch mode
make watch
make watch PACKAGE=calendar

# Clean build artifacts
make clean

# Full reset (clean + setup + codegen)
make reset

# Build iOS XCFramework from a Flutter module
make xcframework MODULE=answer_detail_module

# Run tests for a specific package
cd packages/domain/reflection_domain && fvm dart test
cd packages/features/calendar && fvm flutter test

# Run build_runner directly in a package
cd packages/data/reflection_data && fvm flutter pub run build_runner build --delete-conflicting-outputs
```

When using Flutter/Dart CLI commands, prefer prefixing with `fvm` to ensure the correct SDK version is used (e.g., `fvm flutter pub get`, `fvm dart test`).
