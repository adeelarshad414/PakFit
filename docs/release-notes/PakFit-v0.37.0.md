# PakFit v0.37.0 Release Notes

## User-Facing Updates

- Adds a security policy and vulnerability-reporting boundary for the PakFit repository.
- Adds CODEOWNERS review ownership for app, iOS, scripts, Gradle, docs, specs, workflow, and security-policy surfaces.
- Documents that hosted private vulnerability reporting and branch protection remain external repository settings before public release.

## QA And Release Evidence

- Adds a release gate that validates `SECURITY.md`, `.github/CODEOWNERS`, security governance docs, and CI permission posture.
- Blocks high-risk workflow triggers or write permissions unless a future CI security spec reviews them.
- Includes security governance status in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.37.0 build 37.

## Store Submission Boundary

This slice proves local security governance posture. Hosted GitHub private vulnerability reporting, branch protection, and a public security contact still require repository settings and policy review outside this local build.
