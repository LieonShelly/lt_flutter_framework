# Project Structure & Architecture

## Monorepo Layout

```
├── apps/                        # Application entry points (shells)
│   ├── lt_app/                  # Main reflection/journaling app (Riverpod)
│   ├── compass_app/             # Travel booking app (Provider)
│   └── algorithm_app/           # Algorithm learning app
│
├── packages/
│   ├── core/                    # Infrastructure layer (lowest level)
│   │   ├── network/             # Dio-based API client, interceptors, token management
│   │   ├── lt_uicomponent/      # Shared UI components, theme, fonts, icons
│   │   ├── analysis_defaults/   # Shared lint rules
│   │   └── storage/             # Local secure storage (placeholder)
│   │
│   ├── domain/                  # Business logic layer (pure Dart, no Flutter dependency)
│   │   ├── reflection_domain/   # Questions, answers, calendar entities & use cases
│   │   ├── user_domain/         # User entity & use cases
│   │   ├── wallet_domain/       # Wallet & transaction entities & use cases
│   │   └── booking_domain/      # Booking, destination, activity entities & use cases
│   │
│   ├── data/                    # Data access layer (implements domain interfaces)
│   │   ├── reflection_data/     # Reflection API models, datasources, repository impls
│   │   ├── user_data/           # User data access
│   │   ├── wallet_data/         # Wallet data access
│   │   └── booking_data/        # Booking data access (local JSON + remote)
│   │
│   ├── features/                # Presentation layer (UI + state management)
│   │   ├── booking/             # Booking feature (screens, viewmodels, routes)
│   │   ├── calendar/            # Calendar feature
│   │   ├── thread/              # Question thread list
│   │   ├── today_question/      # Daily question
│   │   ├── add_answer/          # Answer submission
│   │   ├── answer_detail/       # Answer detail view
│   │   ├── copilot/             # AI assistant
│   │   ├── user/                # User profile
│   │   ├── wallets/             # Wallet feature
│   │   └── feature_core/        # Shared feature utilities (tab bar, etc.)
│   │
│   └── utls/                    # Utility packages
│       ├── common/              # Result type, Command pattern, shared utilities
│       ├── date_utl/            # Date formatting helpers
│       └── lt_annotation/       # Custom code generation annotations
│
├── shell/                       # Dart CLI scripts for build automation
│   └── bin/                     # setup.dart, clean.dart, codegen.dart
│
└── Makefile                     # Convenience commands wrapping shell scripts
```

## Clean Architecture Dependency Rules

Dependencies flow strictly inward — outer layers depend on inner layers, never the reverse.

```
Apps → Features → Domain ← Data → Core
```

1. **Domain** is pure Dart. It defines entities, repository interfaces (`abstract class`), and use cases. It has zero Flutter or framework dependencies.
2. **Data** implements domain repository interfaces. Contains API models (DTOs with Freezed), datasources (remote/local), and repository implementations. Depends on Domain + Core.
3. **Features** contain UI (pages/widgets), state management (controllers/viewmodels), and routes. Each feature creates only the UseCase providers it needs. Depends on Domain + Data.
4. **Apps** are thin shells: `main.dart`, DI wiring, router config, and `ProviderScope`/`MultiProvider`.
5. **Core** provides infrastructure: network client, storage, UI components. No business logic.

## Package Internal Structure Conventions

### Domain package (`packages/domain/{name}_domain/`)
```
lib/src/
  entities/          # or models/ — pure Dart business objects
  repositories/      # or repostories/ — abstract interface classes
  usecases/          # one class per use case, single `call()` method
lib/{name}_domain.dart  # barrel export file
```

### Data package (`packages/data/{name}_data/`)
```
lib/src/
  models/            # or model/ — Freezed DTOs with toEntity()/fromEntity()
  datasources/       # or data_source/ — remote and local data sources
  repositories/      # or repostories/ — concrete implementations of domain interfaces
  providers/         # Riverpod providers for repositories & datasources (lt_app style)
lib/{name}_data.dart    # barrel export file
```

### Feature package (`packages/features/{name}/`)
```
lib/src/
  {screen_name}/     # screen folder with screen.dart, viewmodel.dart
  routes/            # GoRouter route definitions
  localization/      # i18n (if needed)
  providers/         # UseCase providers (created per-feature, not globally)
lib/{name}.dart         # barrel export file
```

## Key Patterns
- Each package has a single barrel export file at `lib/{package_name}.dart`
- Repository interfaces use `abstract class` (some use `abstract interface class`)
- Use cases take repository via constructor injection
- Result type uses sealed class pattern: `Result.ok(value)` / `Result.error(exception)` with `switch` pattern matching
- ViewModels extend `ChangeNotifier` (compass_app) or use Riverpod `@riverpod` annotations (lt_app)
- Command pattern (`Command0`, `Command1`) wraps async operations in viewmodels
- Note: the folder name `repostories` (typo for "repositories") exists in some packages — maintain consistency with existing naming when editing those packages
