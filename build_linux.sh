#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

export XDG_DATA_HOME="$PWD/.tools/xdg-data"
export XDG_CONFIG_HOME="$PWD/.tools/xdg-config"

engine="$PWD/.tools/Godot_v4.5.1-stable_linux.x86_64"
output="$PWD/build/linux/GiaiCuuNgoiLangHoa.x86_64"

if [[ ! -x "$engine" ]]; then
  echo "Không tìm thấy Godot cục bộ: $engine" >&2
  exit 1
fi

mkdir -p build/linux
"$engine" --headless --editor --path . --export-release Linux "$output"
if [[ ! -f "$output" ]]; then
  echo "Godot không tạo được executable Linux." >&2
  exit 1
fi
chmod +x "$output"
echo "Đã tạo bản Linux: $output"
