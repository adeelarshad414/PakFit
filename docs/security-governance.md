# Security Governance

PakFit security governance is documented in `SECURITY.md` and enforced locally by `scripts/validate-security-governance.sh`.

## Repository Ownership

`.github/CODEOWNERS` assigns review ownership to `@adeelarshad414` across app, iOS, scripts, Gradle, docs, specs, workflow, and security-policy surfaces.

## Vulnerability Reporting

Sensitive vulnerabilities must not be reported in public GitHub issues. Before public release, GitHub private vulnerability reporting or a private GitHub Security Advisory workflow should be enabled and reviewed for the repository.

## Release Validation

Run `bash scripts/validate-security-governance.sh` directly or through `bash scripts/validate-release.sh`.

The gate proves local security policy, ownership, CI permissions, and disclosure-boundary posture. It does not prove hosted GitHub private vulnerability reporting is enabled, branch protection is configured, or a public security contact has completed legal/privacy review.
