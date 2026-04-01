# Project Structure

Monorepo using Dart Workspaces. All packages are registered in the root `pubspec.yaml` under `workspace:`.

```
├── apps/                        # Application entry points (thin shells)
│   ├── lt_app/                  # Main reflection/journaling app (Riverpod)
│   ├── compass_app/             # Travel booking app (Provider)
│   ├── shop_app/                # E-commerce app
│   └── algorithm_app/           # Sorting algorithm demos
│
├── packages/
│   ├── core/                    # Infrastructure layer (no business logic)
│   │   ├── network/             # Dio-based API client, interceptors, exceptions
│   │   ├── lt_uicomponent/      # Shared UI widgets, themes, image processing
│   │   ├── analysis_defaults/   # Shared lint rules
│   │   └── storage/             # Secure token storage
│   │
│   ├── domain/                  # Business logic layer (pure Dart, no Flutter imports)
│   │   ├── reflection_domain/   # Questions, answers, calendar entities + use cases
│   │   ├── user_domain/         # User entity + auth use cases
│   │   ├── wallet_domain/       # Wallet, transactions, contracts
│   │   └── booking_domain/      # Booking, destinations, activities, itineraries
│   │
│   ├── data/                    # Data access layer (implements domain interfaces)
│   │   ├── reflection_data/     # Remote data sources, models (DTOs), repository impls
│   │   ├── user_data/
│   │   ├── wallet_data/
│   │   └── booking_data/
│   │
│   ├── features/                # Presentation layer (UI + state management)
│   │   ├── calendar/            # Calendar views
│   │   ├── thread/              # Question thread list
│   │   ├── today_question/      # Daily question
│   │   ├── add_answer/          # Answer submission
│   │   ├── answer_detail/       # Answer detail view
│   │   ├── copilot/             # AI assistant
│   │   ├── user/                # User profile
│   │   ├── wallets/             # Wallet management
│   │   ├── booking/             # Booking flow (compass_app)
│   │   ├── shop/                # Shop flow (shop_app)
│   │   └── feature_core/        # Shared feature utilities (image processing providers)
│   │
│   └── utls/                    # Utility packages
│       ├── date_utl/            # Date helpers
│       ├── lt_annotation/       # Custom annotations
│       └── common/              # Shared types (Result, Command patterns)
│
├── shell/                       # Dart automation scripts (setup, clean, codegen)
├── Makefile                     # Build commands (delegates to shell scripts)
└── pubspec.yaml                 # Root workspace config + centralized dependency versions
```

## Clean Architecture Layers & Dependency Rules

Dependencies flow inward only: `Apps → Features → Domain ← Data ← Core`

| Layer | Location | Depends On | Contains |
|-------|----------|------------|----------|
| Core | `packages/core/` | Nothing | API client, storage, UI components |
| Domain | `packages/domain/` | Nothing (pure Dart) | Entities, repository interfaces, use cases |
| Data | `packages/data/` | Domain, Core | Models (DTOs), data sources, repository implementations, providers |
| Features | `packages/features/` | Domain, Data, Core | Pages, controllers/viewmodels, use case providers |
| Apps | `apps/` | Features, Core | App shell, routing, DI wiring |

## Key Conventions

- Each business domain has a paired `domain` + `data` package (e.g., `reflection_domain` / `reflection_data`)
- Domain layer entities are plain Dart classes; Data layer models use Freezed + JSON serialization
- Data models provide `toEntity()` and `fromEntity()` conversion methods
- Repository interfaces are defined in Domain; implementations live in Data
- Each feature creates only the UseCase providers it needs (no global UseCase provider registry)
- Each package has a barrel export file at `lib/<package_name>.dart`
- Generated files use `.g.dart` (JSON/Riverpod) and `.freezed.dart` suffixes
