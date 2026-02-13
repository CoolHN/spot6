#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR/Spot6/Spot6.xcodeproj"
TARGET_NAME="Spot6"
CONFIGURATION="Release"
SDK="iphoneos"
BUILD_DIR="$SCRIPT_DIR/build"
APP_DIR="$BUILD_DIR/${CONFIGURATION}-iphoneos/${TARGET_NAME}.app"
PAYLOAD_DIR="$BUILD_DIR/Payload"
IPA_PATH="$BUILD_DIR/${TARGET_NAME}.ipa"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "error: xcodebuild not found. Run this script on macOS with Xcode installed." >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "error: zip not found. Install command line tools." >&2
  exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo "error: project not found at $PROJECT_PATH" >&2
  exit 1
fi

echo "==> Building $TARGET_NAME ($CONFIGURATION, $SDK)"
cd "$SCRIPT_DIR"
xcodebuild \
  -project "$PROJECT_PATH" \
  -target "$TARGET_NAME" \
  -configuration "$CONFIGURATION" \
  -sdk "$SDK" \
  SYMROOT="$BUILD_DIR" \
  clean build

if [ ! -d "$APP_DIR" ]; then
  echo "error: expected app bundle not found at $APP_DIR" >&2
  exit 1
fi

echo "==> Packaging IPA"
rm -rf "$PAYLOAD_DIR"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_DIR" "$PAYLOAD_DIR/"

rm -f "$IPA_PATH"
(
  cd "$BUILD_DIR"
  zip -qry "${TARGET_NAME}.ipa" Payload
)

echo "==> Done: $IPA_PATH"
