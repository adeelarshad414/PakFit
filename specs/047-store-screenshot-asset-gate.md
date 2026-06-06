# Spec 047 - Store Screenshot Asset Gate

## Objective

Add deterministic, English-only store screenshot preview evidence so PakFit can review key workflows before Play Console or App Store Connect submission without committing generated image artifacts.

## Functional Requirements

- Render screenshot previews for onboarding/plan, health markers, clinical screening, mental wellness, analysis dashboard, and food logging.
- Render one contact sheet that summarizes the generated screens.
- Keep screenshot source copy English-only for the current release direction.
- Validate every generated image is PNG, has the expected dimensions, and is not blank.
- Allow screenshot output to be redirected with `PAKFIT_SCREENSHOT_DIR`.
- Include screenshot validation in local release validation, CI, and release evidence reports.
- Bump Android and iOS version metadata for the generated release artifacts.

## Non-Functional Requirements

- Generated screenshots must stay outside tracked source by default.
- The renderer must not require backend services, signing secrets, Play Console access, App Store Connect access, analytics keys, or cloud health data.
- The renderer should use local fonts and a portable fallback so it can run on macOS and Linux CI.

## Acceptance Evidence

- `scripts/validate-store-screenshots.sh` renders and validates seven PNGs.
- `work/render_pakfit_screens.py` contains no Urdu or Arabic-script copy.
- `scripts/validate-release.sh` runs the screenshot gate.
- GitHub Actions runs the screenshot gate with Pillow installed.
- `scripts/generate-release-report.sh` records screenshot count, contact sheet checksum, and screenshot gate status.
- Android and iOS version metadata are bumped to `0.32.0` build `32`.
