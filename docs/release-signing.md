# Release Signing Readiness

PakFit keeps production signing material outside source control.

## Android

Release signing is intentionally externalized through these environment variables:

- `PAKFIT_RELEASE_STORE_FILE`
- `PAKFIT_RELEASE_STORE_PASSWORD`
- `PAKFIT_RELEASE_KEY_ALIAS`
- `PAKFIT_RELEASE_KEY_PASSWORD`

Local validation passes without these variables and clearly labels artifacts as unsigned evidence. When production signing is configured, all four variables must be present and `PAKFIT_RELEASE_STORE_FILE` must point to a nonempty external keystore file outside the repository.

## Source-Control Policy

The repository ignores common signing material extensions:

- `*.jks`
- `*.keystore`
- `*.p12`
- `*.pfx`
- `*.pem`
- `*.key`
- `*.cer`
- `*.certSigningRequest`
- `*.csr`
- `*.developerprofile`
- `*.mobileprovision`
- `*.provisionprofile`
- `*.ipa`
- `*.xcarchive`
- `ExportOptions.plist`

The release signing gate fails if signing material is tracked or placed in the repository worktree.

## iOS

iOS signing assets are intentionally external while this repository uses local SwiftPM validation and an unsigned Xcode project posture. The iOS gate fails if Apple certificates, provisioning profiles, export options, or App Store credential values are committed or placed in the worktree.

The Xcode project must not pin `DEVELOPMENT_TEAM`, provisioning profiles, signing identities, or manual signing mode until signing assets, Apple Developer account access, and archive/export settings are reviewed externally.

## Validation

Run `bash scripts/validate-android-release-signing.sh` and `bash scripts/validate-ios-signing-hygiene.sh` directly or through `bash scripts/validate-release.sh`.

These gates prove signing hygiene and external signing readiness. They do not prove Play upload-key ownership, Play App Signing enrollment, Play Console track acceptance, iOS signing, or App Store Connect archive upload.
