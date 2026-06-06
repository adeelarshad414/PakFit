# PakFit v0.36.0 Release Notes

## User-Facing Updates

- Adds hosted dependency advisory monitoring configuration for the release pipeline.
- Documents the dependency update surfaces for Android, iOS, and CI workflow dependencies.
- Keeps local release evidence clear that live vulnerability/advisory status depends on hosted scanning after push.

## QA And Release Evidence

- Adds a release gate that validates Dependabot coverage for Gradle, Swift Package Manager, and GitHub Actions.
- Blocks suppressed dependency update coverage unless a future supply-chain spec reviews it.
- Includes dependency advisory configuration status and checksum evidence in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.36.0 build 36.

## Store Submission Boundary

This slice proves advisory monitoring configuration. Live CVE/GHSA/advisory results still require GitHub-hosted dependency scanning or another network-enabled scanner after the branch is pushed.
