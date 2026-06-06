# Store Metadata Readiness

This document records the committed app identity metadata used by PakFit release validation.

Public-facing store copy is maintained in `docs/store-listing.md`, with versioned release notes under `docs/release-notes/`. The release gate checks that those drafts match the current app identity/version, stay English-only, keep privacy boundaries explicit, and avoid unsafe medical or outcome claims.

## Android

- Display name: `PakFit`
- Namespace: `com.pakfit.app`
- Application ID: `com.pakfit.app`
- Manifest label: `@string/app_name`
- App theme: `@style/Theme.PakFit`

## iOS

- Display name: `PakFit`
- Bundle identifier: `com.pakfit.ios`
- Target device family: iPhone and iPad (`1,2`)
- Supported platforms: `iphoneos iphonesimulator`
- Mac Catalyst: disabled until a reviewed desktop UI/spec exists

## Validation

Run `bash scripts/validate-app-identity.sh` and `bash scripts/validate-store-listing.sh` directly or through `bash scripts/validate-release.sh`.

The gate intentionally treats identifier changes as release-channel changes. Any future rename, bundle ID migration, white-label build, Mac Catalyst target, or alternate distribution channel needs a spec update, store/privacy review, and new release evidence.
