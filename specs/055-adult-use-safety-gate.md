# Spec 055: Adult-Use Safety Gate

## Goal

Keep PakFit aligned with its Pakistani adult audience by preventing under-18 profiles from silently receiving adult calorie, nutrition, workout, BMI, lab-marker, diabetes, or mental wellness guidance without a clear guardian/clinician boundary.

## Functional Requirements

- Android profile setup must use 18 as the minimum age for new profile entry.
- Android sliders must safely clamp older out-of-range saved values while preserving restored profile evidence for safety warnings.
- Android recommendation output must include an adult-use safety warning for `age < 18`.
- iOS recommendation output must include an adult-use safety warning for `age < 18`.
- iOS Plan must display recommendation safety warnings.
- Store listing and release docs must state that PakFit is designed for adults 18 and older.
- The release gate must verify source, tests, UI, docs, and store listing adult-use posture.

## Non-Functional Requirements

- The gate must run locally and in CI without network access, backend services, signing secrets, Play Console, or App Store Connect.
- The implementation must not weaken medical caution warnings, privacy, accessibility, diagnostic privacy, signing, store, dependency, or security gates.
- Youth-specific support must remain out of scope until a pediatric clinical and consent design is reviewed.

## Acceptance Evidence

- `bash scripts/validate-adult-use-safety.sh` passes.
- Android unit tests cover the under-18 warning.
- Swift tests and smoke tests cover the under-18 warning.
- `bash scripts/validate-release.sh` runs the adult-use safety gate.
- Generated release evidence includes adult-use safety status and documentation checksum.
- Android and iOS versions remain aligned at the current release version.
