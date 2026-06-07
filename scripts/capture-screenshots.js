#!/usr/bin/env node

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const rootDir = path.resolve(__dirname, "..");
const screenshotDir = process.env.PAKFIT_SCREENSHOT_DIR
  ? path.resolve(process.env.PAKFIT_SCREENSHOT_DIR)
  : path.join(rootDir, "docs", "screenshots");

fs.mkdirSync(screenshotDir, { recursive: true });

const env = {
  ...process.env,
  PAKFIT_SCREENSHOT_DIR: screenshotDir,
};

const result = spawnSync("bash", ["scripts/validate-store-screenshots.sh"], {
  cwd: rootDir,
  env,
  stdio: "inherit",
});

if (result.status !== 0) {
  process.exit(result.status || 1);
}

const screenshots = [
  ["Contact sheet", "00-pakfit-screen-contact-sheet.png"],
  ["Home, profile, and plan", "01-home-profile-plan.png"],
  ["Health markers, BMI, and reports", "02-health-markers-bmi-reports.png"],
  ["Clinical intelligence", "03-clinical-intelligence.png"],
  ["Mental wellness and crisis support", "04-mental-wellness-crisis.png"],
  ["Analysis dashboard", "05-analysis-dashboard.png"],
  ["Food logging and records", "06-food-logging-records.png"],
];

const indexPath = path.join(screenshotDir, "INDEX.md");
const lines = [
  "# PakFit Screenshot Gallery",
  "",
  "Generated from `work/render_pakfit_screens.py` through `scripts/capture-screenshots.js`.",
  "",
  "PakFit is a native Android/iOS app, so these are deterministic store-preview screens rather than browser route screenshots.",
  "",
];

for (const [title, file] of screenshots) {
  lines.push(`## ${title}`);
  lines.push("");
  lines.push(`![${title}](./${file})`);
  lines.push("");
}

fs.writeFileSync(indexPath, lines.join("\n"));
console.log(indexPath);
