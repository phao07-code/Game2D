#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

export JAVA_HOME="$PWD/.tools/jdk"
export ANDROID_HOME="$PWD/.tools/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export XDG_DATA_HOME="$PWD/.tools/xdg-data"
export XDG_CONFIG_HOME="$PWD/.tools/xdg-config"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"

engine="$PWD/.tools/Godot_v4.5.1-stable_linux.x86_64"
output="$PWD/build/GiaiCuuNgoiLangHoa.apk"

if [[ ! -x "$engine" ]]; then
  echo "Thiếu Godot cục bộ: $engine" >&2
  exit 1
fi

mkdir -p build
"$engine" --headless --editor --path . --export-debug Android "$output"
if [[ ! -f "$output" ]]; then
  echo "Godot không tạo được APK Android." >&2
  exit 1
fi
echo "Đã tạo APK: $output"
