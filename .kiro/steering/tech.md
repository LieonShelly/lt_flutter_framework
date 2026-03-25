# Tech Stack

## Core

- Language: Dart (SDK ^3.8.1)
- Framework: Flutter 3.35.7 (managed via FVM)
- Monorepo: Dart Workspace (root `pubspec.yaml` defines all workspace members and shared dependency versions)

## State Management & DI

The project uses two patterns depending on the app:

- `lt_app`: Riverpod (`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`)
- `compass_app`: Provider package + ChangeNotifier-based ViewModels with a custom `Command` pattern (see `packages/utls/common/lib/src/command.dart`)

## Routing

- GoRouter (`go_router: ^17.0.0`)

## Networking

- Dio (`dio: ^5.9.0`) — primary HTTP client in `lt_app`
- http package — used in `compass_app`
- Custom `ApiClient` abstraction in `packages/core/network`

## Serialization & Code Generation

- Freezed (`freezed_annotation` + `freezed`) — immutable data classes
- JSON Serializable (`json_annotation` + `json_serializable`)
- Build Runner (`build_runner: ^2.4.13`) — code generation orchestrator
- Custom annotation: `lt_annotation` package with `@ltDeserialization`

## Error Handling

- Sealed `Result<T>` type (`Ok<T>` / `Error<T>`) in `packages/utls/common`
- `Command` pattern wraps async operations with running/error/completed states and `ChangeNotifier` integration

## UI

- Material 3 (`useMaterial3: true`)
- Custom component library: `packages/core/lt_uicomponent`
- flutter_svg, cached_network_image

## Storage

- flutter_secure_storage (token storage)
- path_provider, flutter_cache_manager

## Testing

- flutter_test, test (^1.24.0)
- mockito (^5.4.4) — used in `lt_app`
- mocktail (^1.0.4) — used in `compass_app`
- mocktail_image_network

## Linting

- flutter_lints (^6.0.0)
- Shared analysis defaults: `packages/core/analysis_defaults`

## Common Commands

All commands run from the project root. Use FVM (`fvm flutter ...`) or the Makefile.

```bash
# Full setup (install shell deps + all package deps)
make setup

# Clean all build artifacts
make clean

# Run code generation (Freezed, JSON, Riverpod)
make codegen

# Code generation in watch mode
make watch

# Full reset (clean + setup + codegen)
make reset

# Target a specific package
make setup PACKAGE=reflection_data
make codegen PACKAGE=lt_app

# Manual flutter commands (use fvm)
fvm flutter pub get
fvm flutter test
fvm flutter run

# Run build_runner directly in a package
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Run tests for a specific package
cd packages/data/reflection_data && fvm flutter test
```
