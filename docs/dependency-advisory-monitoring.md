# Dependency Advisory Monitoring

PakFit uses local dependency inventory gates plus GitHub Dependabot configuration for hosted advisory monitoring.

## Covered Surfaces

- Gradle dependencies at repository root.
- Swift Package Manager dependencies under `ios/PakFitIOS`.
- GitHub Actions workflow dependencies.

## Schedule

Dependabot is configured in `.github/dependabot.yml` with weekly checks on Monday morning in the `Asia/Karachi` timezone. Each ecosystem has a pull-request limit of five and receives dependency labels for triage.

## Validation

Run `bash scripts/validate-dependency-advisory-config.sh` directly or through `bash scripts/validate-release.sh`.

This gate proves the repository has a Dependabot advisory/update handoff configured for current dependency surfaces. It does not prove current CVE/GHSA status until the repository is pushed and GitHub's hosted dependency graph, Dependabot alerts, or another network-enabled scanner runs.
