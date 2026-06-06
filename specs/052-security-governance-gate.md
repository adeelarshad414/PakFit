# Spec 052 - Security Governance Gate

## Objective

Add a local release gate that proves PakFit has a security policy, vulnerability-reporting boundary, CODEOWNERS review coverage, and low-risk CI permission posture before release evidence is accepted.

## Functional Requirements

- Add `SECURITY.md` with supported versions tied to the current release minor version.
- Document sensitive vulnerability reporting boundaries and discourage public reports for health-data, signing, store, or secret issues.
- Add `.github/CODEOWNERS` covering app, iOS, scripts, Gradle, docs, specs, workflow, and security-policy surfaces.
- Add security governance documentation under `docs/`.
- Validate CI workflow uses read-only repository contents permission and does not use high-risk triggers or write permissions.
- Include the gate in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- The gate must run without GitHub admin access, signing secrets, backend credentials, analytics keys, Play Console, or App Store Connect.
- The gate must not pretend hosted private vulnerability reporting, branch protection, or public security contact review is complete.
- The gate must not publish an unreviewed bounty promise or sensitive public issue workflow.

## Acceptance Evidence

- `scripts/validate-security-governance.sh` passes.
- `SECURITY.md`, `.github/CODEOWNERS`, and `docs/security-governance.md` exist.
- `scripts/validate-release.sh` runs the security governance gate.
- GitHub Actions runs the security governance gate.
- `scripts/generate-release-report.sh` records security governance gate status.
- Android and iOS version metadata are bumped to `0.37.0` build `37`.
