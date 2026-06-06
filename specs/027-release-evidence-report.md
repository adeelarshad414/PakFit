# Spec 027 - Release Evidence Report

## Objective

Add a repeatable release evidence report for PakFit so each Android debug APK, release APK, release Android App Bundle, and iOS validation pass can be audited with version metadata, checksums, git state, platform privacy status, signing posture, and known release boundaries.

## Functional Requirements

- Generate a Markdown release report after debug and release Android artifacts are built.
- Include Android application ID, debug/release variants, version name, version code, artifact paths, sizes, and SHA-256 checksums.
- Include Android source version, iOS project version, built APK metadata, and version alignment gate status.
- Include Android source application ID, Android namespace/display name, iOS bundle ID/display name, target device family, and app identity gate status.
- Include Android adaptive launcher icon status, iOS AppIcon asset status, and app icon gate status.
- Include release APK signing verification status when `apksigner` is available.
- Include release minification, resource shrinking, ProGuard/R8 rules, and mapping file checksum evidence.
- Include release AAB path, size, and SHA-256.
- Include git branch, git SHA, and worktree status.
- Include Gradle Wrapper distribution URL, distribution SHA-256, wrapper JAR SHA-256, and script checksums.
- Include Gradle dependency verification metadata path, checksum, component count, checksum count, and strict mode status.
- Include Android Auto Backup and backup/data-extraction sensitive snapshot exclusion status.
- Include Android declared permission count, permission policy, and camera hardware feature posture.
- Include Android exported component count, exported component policy, and exported surface gate status.
- Include Android cleartext traffic status and network security gate status.
- Include iOS camera/photo purpose-string status and permission privacy gate status.
- Include iOS runtime URL policy and network security gate status.
- Include food photo capture mode and photo privacy gate status.
- Include dependency inventory report path, checksums, and dynamic/SNAPSHOT dependency gate status.
- Include iOS Swift package/Xcode project paths and privacy manifest status.
- Include the exact release validation command and gates.
- State release boundaries for Android upload-key signing, Play Console validation, iOS signing, and legal/privacy review.

## Non-Functional Requirements

- The report generator must work without backend credentials, signing secrets, analytics keys, or cloud services.
- The report should write to ignored output folders by default.
- CI should upload the report as an artifact when Android debug and release build outputs exist.

## Acceptance Evidence

- `scripts/generate-release-report.sh` creates a report after `scripts/validate-release.sh`.
- The report includes debug APK, release APK, and release AAB SHA-256 values plus vended metadata from `output-metadata.json`.
- The report includes Android/iOS version alignment status.
- The report includes app identity metadata status.
- The report includes app icon asset status.
- The report includes R8/resource shrinking status and mapping checksum when a mapping file exists.
- The report includes Gradle Wrapper reproducibility evidence.
- The report includes Gradle dependency verification evidence.
- The report includes Android backup privacy status.
- The report includes Android permission privacy status.
- The report includes Android exported surface status.
- The report includes Android network security status.
- The report includes iOS permission privacy status.
- The report includes iOS network security status.
- The report includes food photo privacy status.
- The report includes dependency inventory status and checksums.
- GitHub Actions uploads release evidence reports as artifacts.
