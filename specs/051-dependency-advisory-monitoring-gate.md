# Spec 051 - Dependency Advisory Monitoring Gate

## Objective

Add a local release gate that proves PakFit has hosted dependency update/advisory monitoring configured for the current Android, iOS, and CI dependency surfaces.

## Functional Requirements

- Add `.github/dependabot.yml`.
- Configure Dependabot for Gradle dependencies at repository root.
- Configure Dependabot for Swift Package Manager dependencies under `ios/PakFitIOS`.
- Configure Dependabot for GitHub Actions workflow dependencies.
- Use weekly schedules in the Pakistan timezone.
- Label dependency PRs for triage.
- Block allow/ignore or other coverage-suppressing config unless a future supply-chain spec reviews it.
- Include the gate in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- The gate must run without GitHub network access, signing secrets, backend credentials, analytics keys, Play Console, or App Store Connect.
- The gate must distinguish configured advisory monitoring from actual live advisory results.
- Live CVE/GHSA status remains an external hosted-scanner result until the branch is pushed and GitHub or another network-enabled scanner runs.

## Acceptance Evidence

- `scripts/validate-dependency-advisory-config.sh` passes.
- `.github/dependabot.yml` includes Gradle, Swift, and GitHub Actions ecosystems.
- `scripts/validate-release.sh` runs the dependency advisory configuration gate.
- GitHub Actions runs the dependency advisory configuration gate.
- `scripts/generate-release-report.sh` records Dependabot config path, checksum, ecosystem count, and gate status.
- Android and iOS version metadata are bumped to `0.36.0` build `36`.
