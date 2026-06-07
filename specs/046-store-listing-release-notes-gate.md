# Spec 046 - Store Listing And Release Notes Gate

## Objective

Add a locally verifiable store-listing and release-notes gate so PakFit's public-facing release copy stays aligned with app identity, version metadata, privacy posture, and clinical-safety boundaries before store submission.

## Functional Requirements

- Maintain a draft store listing under `docs/store-listing.md`.
- Maintain versioned release notes under `docs/release-notes/PakFit-v<version>.md`.
- Validate that listing copy references the current Android package, iOS bundle identifier, app name, and version.
- Validate that release notes exist for the current Android/iOS aligned version.
- Validate that listing copy is English-only.
- Validate that listing copy states PakFit is educational, non-diagnostic, and not a clinician replacement.
- Validate that listing copy documents local-first privacy boundaries for photos, health snapshots, analytics, cloud sync, and permissions.
- Block unsafe public medical-claim language such as guaranteed weight loss, disease cures, diagnosis, prescriptions, or clinician replacement claims.
- Include the gate in local release validation, CI, and release evidence reports.

## Non-Functional Requirements

- The gate must run without Play Console, App Store Connect, signing secrets, backend credentials, analytics keys, or network access.
- The listing draft must avoid promises that exceed current app behavior.
- The listing draft must clearly mark external submission needs such as public privacy-policy hosting, screenshots, account ownership, ratings forms, and legal/privacy review.

## Acceptance Evidence

- `scripts/validate-store-listing.sh` passes for the current store listing and release notes.
- `scripts/validate-release.sh` runs the store-listing gate.
- GitHub Actions runs the store-listing gate.
- `scripts/generate-release-report.sh` records store listing, release notes, checksum, and gate status evidence.
- Android and iOS version metadata are bumped to the current aligned release version before validation.
