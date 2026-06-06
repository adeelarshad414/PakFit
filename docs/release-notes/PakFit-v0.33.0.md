# PakFit v0.33.0 Release Notes

## User-Facing Updates

- Adds stronger release-signing hygiene for the Android production path.
- Documents how PakFit keeps upload keystores and signing passwords outside source control.
- Keeps local release builds usable as unsigned evidence until real Play signing assets are supplied externally.

## QA And Release Evidence

- Adds a release gate that blocks tracked or repo-local signing material.
- Validates that Android release signing uses either no signing environment for local evidence builds or a complete external `PAKFIT_RELEASE_*` environment.
- Includes Android release-signing hygiene status in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.33.0 build 33.

## Store Submission Boundary

This slice proves signing hygiene and external signing readiness. Play Console submission still requires a real upload keystore, Play App Signing setup, account ownership, and track validation.
