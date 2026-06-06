# PakFit Diagnostic Privacy

PakFit handles sensitive health data for Pakistani users, including food logs, calories, body metrics, lab markers, diabetes status, mental wellness inputs, clinical risk factors, and local consent state. Diagnostic behavior must therefore stay minimal and explicit.

## Current Build Policy

No diagnostic logs, crash reports, analytics events, or health-data telemetry are emitted in this build.

- Android runtime source must not call platform logging, stack-trace printing, Timber, analytics SDKs, crash SDKs, or telemetry SDKs.
- iOS runtime source must not call `print`, `debugPrint`, `NSLog`, `os_log`, `Logger`, analytics SDKs, crash SDKs, or telemetry SDKs.
- Build manifests must not include Firebase Analytics, Crashlytics, Sentry, Bugsnag, Datadog, New Relic, Mixpanel, Amplitude, Segment, App Center, or similar SDK dependencies.
- Local release validation must keep privacy docs and store drafts aligned with the no-diagnostic-telemetry posture.

## Future SDK Boundary

Any future SDK for crash reporting, product analytics, telemetry, model monitoring, or remote diagnostics requires a new spec, updated threat model, reviewed event schema, explicit consent behavior, privacy policy updates, store disclosure updates, and security review before implementation.

## Manual Release Boundary

The static gate prevents obvious source and dependency regressions. Final production review should still inspect signed binaries, generated dependency reports, Play/App Store SDK declarations, and any external monitoring configuration before public release.
