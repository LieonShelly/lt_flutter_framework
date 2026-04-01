# Tech Stack

## Core

- **Language**: Dart 3.8+
- **Framework**: Flutter 3.35.7 (managed via FVM)
- **SDK constraint**: `^3.8.1`

## State Management & DI

- **lt_app**: Riverpod (`flutter_riverpod` + `riverpod_annotation` + code generation via `riverpod_generator`)
- **compass_app**: Provider package (`provider`) with manual DI setup
- Both patterns coexist in the monorepo — match the existing pattern of the app you're working in.

## Routing

- GoRouter (`go_router`)

## Networking

- Dio (`dio`) — wrapped in a custom `ApiClientType` abstraction in `packages/core/network`
- Custom interceptors for auth tokens and token refresh

## Serialization & Code Generation

- Freezed (`freezed` + `freezed_annotation`) for immutable data models
- JSON Serializable (`json_serializable` + `json_annotation`) for JSON encoding/decoding
- Build Runner (`build_runner`) for all code generation

## Storage

- `flutter_secure_storage` for token storage
- `path_provider` for file system paths
- `flutter_cache_manager` for image caching

## Linting

- `flutter_lints` (via `analysis_options.yaml` with `include: package:flutter_lints/flutter.yaml`)

## Testing

- `flutter_test` (widget tests)
- `test` (unit tests)
- `mockito` for mocking

## Dependency Management

- Dart Workspace feature — all dependency versions are centralized in the root `pubspec.yaml`
- Sub-packages use `resolution: workspace` and inherit versions from root

## Common Commands

All commands assume FVM is installed. Run from the project root.

```bash
# Install all dependencies
make setup

# Clean all build artifacts
make clean

# Run code generation (Freezed, JSON, Riverpod generators)
make codegen

# Code generation in watch mode
make watch

# Full reset (clean + setup + codegen)
make reset

# Package-specific operations
make setup PACKAGE=reflection_data
make codegen PACKAGE=lt_app
make watch PACKAGE=user_data

# Manual code generation for a single package
cd packages/data/reflection_data
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run tests for a specific package
cd apps/algorithm_app
fvm flutter test

# Get dependencies manually
fvm flutter pub get
```

## Shell Scripts

Automation scripts live in `shell/bin/` (Dart scripts):
- `setup.dart` — installs dependencies
- `clean.dart` — cleans build artifacts
- `codegen.dart` — runs build_runner code generation (supports `--watch` and `--package` flags)
