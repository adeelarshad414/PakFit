# Spec 060: iOS Analysis Dashboard Parity Gate

## Goal

Bring iOS closer to Android Dashboard parity by adding the analysis dashboard workflow for summaries, progress, charts, trends, todos, and history.

## Functional Requirements

- Add Swift analysis dashboard models for trend status, todo type, chart point, trend insight, todo, history entry, and dashboard report.
- Add a Swift `AnalysisDashboardEngine` that calculates today, weekly, and monthly summaries.
- Add progress values for calorie target, burn target, and protein progress.
- Add adherence score, health flag count, calorie trend, burn trend, chart points, todos, and newest-first history.
- Add Swift smoke-test coverage for weekly/monthly summaries, chart points, todos, and history ordering.
- Add iOS Dashboard UI for analysis summary, charts/graphs, trends, todos, and history.
- Document the iOS analysis dashboard parity posture and release boundary.

## Non-Functional Requirements

- The gate must run locally and in CI without simulators, signing, Play Console, or App Store Connect.
- The implementation must not weaken adult-use safety, privacy, diagnostic privacy, accessibility, signing, store, dependency, security, setup parity, health marker parity, lifestyle coach parity, or clinical/mental parity gates.
- Charts and progress must include numeric text and accessibility labels.

## Acceptance Evidence

- `bash scripts/validate-ios-analysis-dashboard-parity.sh` passes.
- `bash scripts/validate-release.sh` runs the iOS analysis dashboard parity gate.
- Swift smoke/app compile passes.
- Generated release evidence includes iOS analysis dashboard parity status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
