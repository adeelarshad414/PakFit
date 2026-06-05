# Spec 027 - Release Evidence Report

## Objective

Add a repeatable release evidence report for PakFit so each Android APK and iOS validation pass can be audited with version metadata, checksum, git state, platform privacy status, and known release boundaries.

## Functional Requirements

- Generate a Markdown release report after the debug APK is built.
- Include Android application ID, variant, version name, version code, APK path, APK size, and APK SHA-256.
- Include git branch, git SHA, and worktree status.
- Include iOS Swift package/Xcode project paths and privacy manifest status.
- Include the exact release validation command and gates.
- State release boundaries for debug APK signing, iOS signing, and legal/privacy review.

## Non-Functional Requirements

- The report generator must work without backend credentials, signing secrets, analytics keys, or cloud services.
- The report should write to ignored output folders by default.
- CI should upload the report as an artifact when Android build output exists.

## Acceptance Evidence

- `scripts/generate-release-report.sh` creates a report after `scripts/validate-release.sh`.
- The report includes APK SHA-256 and vended metadata from `output-metadata.json`.
- GitHub Actions uploads release evidence reports as artifacts.
