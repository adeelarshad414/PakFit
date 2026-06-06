# PakFit v0.34.0 Release Notes

## User-Facing Updates

- Adds iOS signing hygiene checks for the App Store release path.
- Documents how PakFit keeps Apple certificates, provisioning profiles, export options, and App Store credentials outside source control.
- Keeps local Swift validation usable while full Xcode archive/signing remains an external submission step.

## QA And Release Evidence

- Adds a release gate that blocks tracked or repo-local iOS signing material.
- Validates that the Xcode project does not pin a development team, provisioning profile, manual signing mode, or signing identity in source.
- Includes iOS signing hygiene status in release validation, CI, and the generated release evidence report.
- Keeps Android and iOS version metadata aligned at version 0.34.0 build 34.

## Store Submission Boundary

This slice proves iOS signing hygiene and external signing readiness. App Store submission still requires full Xcode.app, Xcode 26+ SDK tooling, Apple Developer/App Store Connect access, signing assets, archive validation, and upload review.
