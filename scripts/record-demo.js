#!/usr/bin/env node

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const rootDir = path.resolve(__dirname, "..");
const clipDir = path.join(rootDir, "docs", "video-clips");
const screenshotDir = path.join(rootDir, "docs", "screenshots");
fs.mkdirSync(clipDir, { recursive: true });

const capture = spawnSync("node", ["scripts/capture-screenshots.js"], {
  cwd: rootDir,
  stdio: "inherit",
});
if (capture.status !== 0) {
  process.exit(capture.status || 1);
}

const ffmpegProbe = spawnSync("ffmpeg", ["-version"], { stdio: "ignore" });
const scenarioScreens = {
  "office-worker-demo.webm": [
    "01-home-profile-plan.png",
    "06-food-logging-records.png",
    "05-analysis-dashboard.png",
  ],
  "health-reviewer-demo.webm": [
    "02-health-markers-bmi-reports.png",
    "03-clinical-intelligence.png",
    "05-analysis-dashboard.png",
  ],
  "mental-wellness-demo.webm": [
    "04-mental-wellness-crisis.png",
    "05-analysis-dashboard.png",
  ],
  "full-demo.webm": [
    "01-home-profile-plan.png",
    "02-health-markers-bmi-reports.png",
    "03-clinical-intelligence.png",
    "04-mental-wellness-crisis.png",
    "05-analysis-dashboard.png",
    "06-food-logging-records.png",
  ],
};

function writeFileList(name, files) {
  const fileList = path.join(clipDir, `${name}.txt`);
  const rows = [];
  for (const file of files) {
    rows.push(`file '${path.join(screenshotDir, file).replace(/'/g, "'\\''")}'`);
    rows.push("duration 4");
  }
  rows.push(`file '${path.join(screenshotDir, files[files.length - 1]).replace(/'/g, "'\\''")}'`);
  fs.writeFileSync(fileList, rows.join("\n"));
  return fileList;
}

const generated = [];
if (ffmpegProbe.status === 0) {
  for (const [output, files] of Object.entries(scenarioScreens)) {
    const fileList = writeFileList(output, files);
    const destination = path.join(clipDir, output === "full-demo.webm" ? "FULL_DEMO.webm" : output);
    const result = spawnSync(
      "ffmpeg",
      [
        "-y",
        "-f",
        "concat",
        "-safe",
        "0",
        "-i",
        fileList,
        "-vf",
        "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,format=yuv420p",
        "-r",
        "30",
        destination,
      ],
      { cwd: rootDir, stdio: "inherit" }
    );
    if (result.status === 0) {
      generated.push(destination);
    }
  }
}

const planPath = path.join(clipDir, "DEMO_RECORDING_PLAN.md");
fs.writeFileSync(
  planPath,
  [
    "# PakFit Demo Recording Plan",
    "",
    "PakFit is a native Android/iOS app. This script uses deterministic screenshot previews to create silent video clips when `ffmpeg` is installed.",
    "",
    generated.length
      ? `Generated clips:\n${generated.map((item) => `- ${path.relative(rootDir, item)}`).join("\n")}`
      : "No video clips were generated because `ffmpeg` is unavailable. Use `docs/VIDEO_SCRIPT.md` with Android Studio, Xcode, QuickTime, or a device recorder.",
    "",
    "For narrated production video, record on-device Android/iOS flows, then use `scripts/assemble-video.sh` to assemble exported clips.",
    "",
  ].join("\n")
);

console.log(planPath);
