# Project Structure

This is a Dart Workspace monorepo following Clean Architecture with strict unidirectional dependency flow:

```
Apps → Features → Domain ← Data → Core
```

Domain is the innermost layer — pure Dart, no Flutter dependency. Data implements Domain interfaces. Features depend on both Domain and Data. Apps aggregate Features.

## Top-Level Layout

```
├── apps/                    # Runnable applications
│   ├── lt_app/              # Main app (Riverpod-based)
│   ├── compass_app/         # Booking/travel app (Provider-based)
│   └── algorithm_app/       # Sorting algorithm learning app
│
├── packages/
│   ├── core/                # Infrastructure layer
│   │   ├── network/         # API client, interceptors, exceptions
│   │   ├── lt_uicomponent/  # Shared UI components, theme, icons
│   │   ├── analysis_defaults/ # Shared lint rules
│   │   └── storage/         # Local/secure storage
│   │
│   ├── domain/              # Business logic layer (pure Dart)
│   │   ├── reflection_domain/
│   │   ├── user_domain/
│   │   ├── wallet_domain/
│   │   └── booking_domain/
│   │
│   ├── data/                # Data access layer
│   │   ├── reflection_data/
│   │   ├── user_data/
│   │   ├── wallet_data/
│   │   └── booking_data/
│   │
│   ├── features/            # Presentation layer
│   │   ├── booking/         # Travel booking feature
│   │   ├── calendar/        # Calendar views
│   │   ├── thread/          # Question thread list
│   │   ├── today_question/  # Daily question
│   │   ├── add_answer/      # Answer submission
│   │   ├── answer_detail/   # Answer detail view
│   │   ├── copilot/         # AI assistant
│   │   ├── user/            # User profile/auth
│   │   ├── wallets/         # Wallet UI
│   │   └── feature_core/    # Shared feature utilities
│   │
│   └── utls/                # Shared utilities
│       ├── common/          # Result type, Command pattern
│       ├── date_utl/        # Date helpers
│       └── lt_annotation/   # Custom annotations
│
├── shell/                   # Dart CLI scripts for build automation
├── docs/                    # Documentation
├── Makefile                 # Build commands entry point
└── pubspec.yaml             # Workspace root (shared dependency versions)
```

## Package Internal Structure

### Domain packages
```
{name}_domain/lib/src/
├── entities/          # Pure Dart business objects
├── repositories/      # Abstract repository interfaces
└── usecases/          # Single-responsibility business operations
```

### Data packages
```
{name}_data/lib/src/
├── models/            # DTOs with Freezed, JSON serialization, toEntity()/fromEntity()
├── datasources/       # Remote/local data source interfaces + implementations
│   └── remote/
├── repositories/      # Repository interface implementations
└── providers/         # Riverpod providers for repositories and data sources
```

### Feature packages
```
{name}/lib/src/
├── {screen_name}/
│   ├── {screen}_screen.dart      # UI widget
│   ├── {screen}_viewmodel.dart   # ViewModel (ChangeNotifier) or Controller (Riverpod)
│   └── {screen}_*.dart           # Sub-widgets
├── routes/            # GoRouter route definitions
└── providers/         # UseCase providers (created per-feature, on demand)
```

## Key Conventions

- Each domain has a paired `{name}_domain` and `{name}_data` package
- Domain packages export via a barrel file: `lib/{name}_domain.dart`
- Data models include `toEntity()` and `fromEntity()` conversion methods
- UseCases follow the callable class pattern with a `call()` method
- UseCase providers are created in the feature that needs them, not in the data layer
- Repository interfaces use `abstract interface class`
- The `compass_app` booking feature uses `ChangeNotifier` + `Command` pattern; `lt_app` features use Riverpod annotations
- Each package uses `resolution: workspace` in its pubspec.yaml
