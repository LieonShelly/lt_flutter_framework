# Tech Stack & Build System

## Flutter & Dart
- Flutter 3.35.7 (managed via FVM — `.fvmrc`)
- Dart SDK ^3.8.1
- Dart Workspace for monorepo dependency resolution (`resolution: workspace` in each package's pubspec)
- Root `pubspec.yaml` defines shared dependency versions for all packages

## Key Libraries
- **State Management**: Riverpod (`flutter_riverpod` + `riverpod_annotation`) for lt_app; `provider` for compass_app
- **Routing**: GoRouter
- **Networking**: Dio (wrapped in `lt_network` core package)
- **Serialization**: Freezed + JSON Serializable (code-generated)
- **Storage**: Flutter Secure Storage
- **Logging**: `logging` package
- **Result type**: Custom `Result<T>` from `common` utility package (Ok/Error pattern matching)
- **Custom annotations**: `lt_annotation` package with `@ltDeserialization` for code generation

## Code Generation
Freezed, Riverpod Generator, and JSON Serializable all require `build_runner`. Generated files follow the pattern:
- `*.freezed.dart`
- `*.g.dart`

Never edit generated files. They are re-created by `build_runner`.

## Common Commands

All commands run from the project root:

```bash
# Setup (installs FVM, all deps)
make setup

# Clean all build artifacts
make clean

# Run code generation (Freezed, Riverpod, JSON Serializable)
make codegen

# Code generation in watch mode
make watch

# Full reset (clean + setup + codegen)
make reset

# Target a specific package
make setup PACKAGE=reflection_data
make codegen PACKAGE=booking_data

# Run an app
cd apps/compass_app && fvm flutter run
cd apps/lt_app && fvm flutter run

# Run tests for a package
cd packages/domain/booking_domain && fvm flutter test

# Run build_runner directly in a package
cd packages/data/reflection_data && fvm flutter pub run build_runner build --delete-conflicting-outputs
```

## Linting
- `flutter_lints` package used across the project
- Shared analysis options in `packages/core/analysis_defaults/lib/flutter.yaml`
- Per-app `analysis_options.yaml` files include the shared config

## Testing
- `flutter_test` and `test` for unit/widget tests
- `mockito` for mocking in lt_app packages
- `mocktail` for mocking in compass_app/booking packages
- `integration_test` SDK for integration tests
