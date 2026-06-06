# Spec 050 - Store Privacy Disclosure Consistency Gate

## Objective

Add a local release gate that keeps PakFit's privacy policy draft, Google Play Data safety draft, App Store privacy draft, store listing privacy summary, platform manifests, and declared permissions consistent with the current local-first app behavior.

## Functional Requirements

- Validate Android permissions match the current privacy disclosure scope: internet and optional camera only.
- Validate Android backup/data-extraction files exclude the sensitive local snapshot.
- Validate iOS privacy manifest declares no tracking, no collected data, and the UserDefaults required-reason API.
- Validate iOS camera and photo purpose strings remain food-photo scoped.
- Validate privacy docs and store listing consistently state no account, no cloud sync, no remote analytics, no remote health upload, no remote photo upload, and local-first storage.
- Validate Google Play and App Store privacy drafts match the no-remote-collection posture.
- Validate privacy docs keep food-photo, encryption, user-control, and clinical-boundary disclosures present.
- Block unsupported privacy claims such as enabled analytics, advertising SDKs, tracking, cloud sync, app-driven sharing, or remote photo upload.
- Include the gate in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- The gate must run without Play Console, App Store Connect, signing secrets, backend credentials, analytics keys, or network access.
- The gate must not replace legal/privacy review or public privacy-policy hosting.
- The gate should fail loudly when app behavior, permissions, manifests, or store drafts drift apart.

## Acceptance Evidence

- `scripts/validate-store-privacy-disclosures.sh` passes for the current app and docs.
- `scripts/validate-release.sh` runs the store privacy disclosure gate.
- GitHub Actions runs the store privacy disclosure gate.
- `scripts/generate-release-report.sh` records the store privacy disclosure gate status.
- Android and iOS version metadata are bumped to `0.35.0` build `35`.
