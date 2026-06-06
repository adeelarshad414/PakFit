#!/usr/bin/env node
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { deflateSync } from "node:zlib";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const iconSetDir = join(repoRoot, "ios/PakFitIOS/Assets.xcassets/AppIcon.appiconset");

const iconSlots = [
  ["iphone", "20x20", "2x"],
  ["iphone", "20x20", "3x"],
  ["iphone", "29x29", "2x"],
  ["iphone", "29x29", "3x"],
  ["iphone", "40x40", "2x"],
  ["iphone", "40x40", "3x"],
  ["iphone", "60x60", "2x"],
  ["iphone", "60x60", "3x"],
  ["ipad", "20x20", "1x"],
  ["ipad", "20x20", "2x"],
  ["ipad", "29x29", "1x"],
  ["ipad", "29x29", "2x"],
  ["ipad", "40x40", "1x"],
  ["ipad", "40x40", "2x"],
  ["ipad", "76x76", "1x"],
  ["ipad", "76x76", "2x"],
  ["ipad", "83.5x83.5", "2x"],
  ["ios-marketing", "1024x1024", "1x"]
];

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data = Buffer.alloc(0)) {
  const typeBuffer = Buffer.from(type);
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE(crc32(Buffer.concat([typeBuffer, data])), 0);
  return Buffer.concat([length, typeBuffer, data, checksum]);
}

function encodePng(width, height, rgba) {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8;
  header[9] = 6;
  header[10] = 0;
  header[11] = 0;
  header[12] = 0;

  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y += 1) {
    const rowStart = y * (width * 4 + 1);
    raw[rowStart] = 0;
    Buffer.from(rgba.buffer, y * width * 4, width * 4).copy(raw, rowStart + 1);
  }

  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(raw, { level: 9 })),
    chunk("IEND")
  ]);
}

function blend(from, to, amount) {
  return from.map((value, index) => Math.round(value + (to[index] - value) * amount));
}

function setPixel(data, width, x, y, color) {
  if (x < 0 || y < 0 || x >= width || y >= width) return;
  const offset = (y * width + x) * 4;
  data[offset] = color[0];
  data[offset + 1] = color[1];
  data[offset + 2] = color[2];
  data[offset + 3] = color[3] ?? 255;
}

function fillRect(data, width, x0, y0, x1, y1, color) {
  const minX = Math.max(0, Math.floor(x0 * width));
  const maxX = Math.min(width, Math.ceil(x1 * width));
  const minY = Math.max(0, Math.floor(y0 * width));
  const maxY = Math.min(width, Math.ceil(y1 * width));
  for (let y = minY; y < maxY; y += 1) {
    for (let x = minX; x < maxX; x += 1) {
      setPixel(data, width, x, y, color);
    }
  }
}

function fillEllipse(data, width, cx, cy, rx, ry, color) {
  const minX = Math.max(0, Math.floor((cx - rx) * width));
  const maxX = Math.min(width, Math.ceil((cx + rx) * width));
  const minY = Math.max(0, Math.floor((cy - ry) * width));
  const maxY = Math.min(width, Math.ceil((cy + ry) * width));
  for (let y = minY; y < maxY; y += 1) {
    for (let x = minX; x < maxX; x += 1) {
      const nx = ((x + 0.5) / width - cx) / rx;
      const ny = ((y + 0.5) / width - cy) / ry;
      if (nx * nx + ny * ny <= 1) {
        setPixel(data, width, x, y, color);
      }
    }
  }
}

function drawIcon(size) {
  const data = new Uint8Array(size * size * 4);
  const top = [12, 104, 93, 255];
  const bottom = [43, 148, 98, 255];
  const cream = [247, 252, 244, 255];
  const teal = [8, 82, 76, 255];
  const green = [35, 132, 75, 255];
  const mint = [155, 231, 190, 255];

  for (let y = 0; y < size; y += 1) {
    for (let x = 0; x < size; x += 1) {
      const amount = (x + y) / (size * 2);
      setPixel(data, size, x, y, blend(top, bottom, amount));
    }
  }

  fillEllipse(data, size, 0.5, 0.5, 0.35, 0.35, cream);
  fillEllipse(data, size, 0.5, 0.5, 0.31, 0.31, [232, 248, 237, 255]);
  fillRect(data, size, 0.24, 0.54, 0.76, 0.595, teal);
  fillRect(data, size, 0.20, 0.50, 0.30, 0.64, teal);
  fillRect(data, size, 0.70, 0.50, 0.80, 0.64, teal);

  fillRect(data, size, 0.32, 0.30, 0.39, 0.72, teal);
  fillRect(data, size, 0.39, 0.30, 0.53, 0.37, teal);
  fillRect(data, size, 0.50, 0.37, 0.57, 0.49, teal);
  fillRect(data, size, 0.39, 0.49, 0.53, 0.56, teal);

  fillRect(data, size, 0.61, 0.30, 0.68, 0.72, green);
  fillRect(data, size, 0.68, 0.30, 0.81, 0.37, green);
  fillRect(data, size, 0.68, 0.49, 0.78, 0.56, green);
  fillEllipse(data, size, 0.69, 0.24, 0.12, 0.065, mint);

  return encodePng(size, size, data);
}

function pixelSize(size, scale) {
  return Math.round(Number.parseFloat(size.split("x")[0]) * Number.parseInt(scale, 10));
}

mkdirSync(iconSetDir, { recursive: true });

const images = iconSlots.map(([idiom, size, scale]) => {
  const pixels = pixelSize(size, scale);
  const safeSize = size.replace(".", "_").replace("x", "-");
  const filename = `pakfit-${idiom}-${safeSize}-${scale}.png`;
  writeFileSync(join(iconSetDir, filename), drawIcon(pixels));
  return { filename, idiom, scale, size };
});

writeFileSync(
  join(iconSetDir, "Contents.json"),
  `${JSON.stringify({ images, info: { author: "xcode", version: 1 } }, null, 2)}\n`
);
