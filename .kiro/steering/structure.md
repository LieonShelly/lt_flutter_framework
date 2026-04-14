# Project Structure

This is a **Dart Workspace monorepo** following **Clean Architecture** with strict unidirectional dependency flow.

## Top-Level Layout

```
├── apps/                    # Application entry points
├── packages/
│   ├── core/                # Infrastructure layer (lowest)
│   ├── domain/              # Business logic layer (pure Dart, no Flutter)
│   ├── data/                # Data access layer (implements domain interfaces)
│   ├── features/            # Presentation layer (UI + state management)
│   └── utls/                # Shared utilities
├── shell/                   # Dart CLI scripts for build automation
├── pubspec.yaml             # Workspace root — unified dependency versions
└── Makefile                 # Developer task runner
```

## Dependency Direction (strict)

```
Apps → Features → Domain ← Data → Core
                    ↑               ↑
                Features ───────────┘
```

- **Domain** has zero framework dependencies (pure Dart)
- **Data** implements Domain interfaces, depends on Core for networking
- **Features** depend on Domain (entities, use cases) and Data (providers)
- **Apps** aggregate Features and configure routing/DI

## Layer Details

### Core (`packages/core/`)
| Package | Purpose |
|---------|---------|
| `lt_network` (network/) | Dio-based API client, interceptors, exception handling |
| `lt_uicomponent` | Shared widgets, theme, image processing |
| `analysis_defaults` | Shared lint rules |
| `storage/` | Secure token storage |

### Domain (`packages/domain/`)
Pure Dart packages. Each business domain contains:
- `entities/` — Business entities (plain Dart classes)
- `repositories/` — Abstract repository interfaces
- `usecases/` — Business use cases (single-responsibility)

Domains: `reflection_domain`, `user_domain`, `wallet_domain`, `booking_domain`

### Data (`packages/data/`)
Each data package mirrors a domain and contains:
- `models/` — DTOs with Freezed, JSON serialization, and `toEntity()`/`fromEntity()` converters
- `datasources/remote/` — Remote data source implementations
- `repositories/` — Repository implementations (implements domain interfaces)
- `providers/` — Riverpod providers for DataSource and Repository

Packages: `reflection_data`, `user_data`, `wallet_data`, `booking_data`

### Features (`packages/features/`)
Each feature package contains:
- `*_page.dart` — UI page widgets
- `*_controller.dart` — Riverpod state controllers (`@riverpod` annotated)
- `providers/` — UseCase providers (each feature creates only what it needs)
- `*_route_config.dart` — GoRouter route definitions
- Barrel export file at `lib/<package_name>.dart`

Features: `calendar`, `thread`, `today_question`, `add_answer`, `answer_detail`, `copilot`, `user`, `wallets`, `booking`, `shop`, `feature_core`

### Utilities (`packages/utls/`)
| Package | Purpose |
|---------|---------|
| `date_utl` | Date formatting and helpers |
| `lt_annotation` | Custom annotations (e.g., `@ltDeserialization`) |
| `common` | Shared utilities |

### Apps (`apps/`)
| App | Purpose |
|-----|---------|
| `lt_app` | Main application shell — aggregates all features |
| `answer_detail_module` | Standalone Flutter module for iOS XCFramework export |
| `compass_app` | Reference/sample app |
| `shop_app` | Shop feature standalone app |
| `algorithm_app` | Algorithm learning app (pure Dart) |

## Package Conventions

- All sub-packages use `resolution: workspace` and `publish_to: none`
- Dependency versions are centralized in the root `pubspec.yaml`
- Each package has a barrel export file: `lib/<package_name>.dart`
- Generated files use `.g.dart` (Riverpod, JSON) and `.freezed.dart` suffixes
- Generated files are committed to the repo
