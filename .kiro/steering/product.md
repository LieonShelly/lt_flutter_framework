# Product Overview

Flutter-based enterprise "super app" framework using Clean Architecture and a Dart Workspace monorepo.

The project contains multiple apps sharing a common set of modular packages:

- **lt_app**: The primary app — a personal reflection/journaling tool with features for daily questions, threaded answers, calendar views, an AI copilot, user profiles, and a crypto wallet.
- **compass_app**: A travel booking app with destination search, itinerary configuration, and booking management. Uses the `provider` package for DI (unlike lt_app which uses Riverpod).
- **algorithm_app**: A standalone algorithm learning/practice app (sorting algorithms).

The codebase is primarily documented in Chinese (comments, README, commit messages). Code identifiers and API names are in English.
