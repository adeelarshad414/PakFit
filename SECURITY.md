# Security Policy

## Supported Versions

| Version | Status |
| --- | --- |
| 0.50.x | Current local release evidence |
| Earlier local evidence builds | Superseded by the latest release evidence |

## Reporting A Vulnerability

Please do not report sensitive vulnerabilities, exposed secrets, health-data privacy issues, signing-key issues, or account/store access issues in public GitHub issues.

For public release, PakFit should use GitHub private vulnerability reporting or a private GitHub Security Advisory workflow for coordinated disclosure. Until that hosted workflow is enabled and reviewed, security reporting remains an external release boundary.

When reporting privately, include:

- Affected platform: Android, iOS, release pipeline, documentation, or store metadata.
- Impacted data or asset: health data, food logs, photos, signing material, build output, or store disclosure.
- Reproduction steps and affected version.
- Whether exploitation requires physical device access, local file access, network access, or store account access.

## Response Expectations

- Triage privacy, health-data, signing-key, and account/store access reports as high priority.
- Do not request or share real user health data, signing secrets, API keys, Apple certificates, provisioning profiles, upload keystores, or store-console credentials.
- Record fixes through specs, tests, release gates, and release evidence before public distribution.

## Scope

In scope:

- Android app source, manifests, permissions, backup rules, and release artifacts.
- iOS Swift source, privacy manifest, purpose strings, and Xcode metadata.
- Local health snapshot storage and user-controlled export behavior.
- Store privacy, data safety, release metadata, signing hygiene, and CI/release scripts.

Out of scope:

- Attacks requiring access to a user's unlocked device without exploiting PakFit.
- Third-party websites opened by user-controlled online calorie search after the user leaves PakFit.
- Store-console configuration that is not represented in this repository.

## Clinical Safety Boundary

PakFit provides education, planning, screening, and habit support only. Security or safety reports involving medical wording, emergency guidance, mental wellness escalation, or clinical thresholds should be treated as product-safety issues and reviewed before release.
