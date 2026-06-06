# Spec 048 - Android Release Signing Hygiene Gate

## Objective

Add a local release gate that keeps Android signing material out of source control, validates external signing input shape, and records signing hygiene in release evidence.

## Functional Requirements

- Ignore common signing material extensions in `.gitignore`.
- Fail if signing material is tracked by git.
- Fail if signing material is placed anywhere inside the repository worktree.
- Fail if a partial Android release signing environment is provided.
- Pass local unsigned evidence builds when no signing environment is provided.
- When a full signing environment is provided, require `PAKFIT_RELEASE_STORE_FILE` to be an absolute, nonempty, external keystore path.
- Block hardcoded Android release signing passwords in source/docs/scripts.
- Include the gate in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- The gate must not echo signing passwords or require Play Console access.
- The gate must run without backend services, analytics keys, cloud health data, or production signing secrets.
- The gate must not commit or generate keystores.

## Acceptance Evidence

- `scripts/validate-android-release-signing.sh` passes in unsigned local release mode.
- `.gitignore` protects common signing material extensions.
- `scripts/validate-release.sh` runs the signing hygiene gate.
- GitHub Actions runs the signing hygiene gate.
- `scripts/generate-release-report.sh` records the signing hygiene gate status.
- Android and iOS version metadata are bumped to `0.33.0` build `33`.
