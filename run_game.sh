#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ -x .tools/Godot_v4.5.1-stable_linux.x86_64 ]]; then
  exec .tools/Godot_v4.5.1-stable_linux.x86_64 --path .
fi

if command -v godot >/dev/null 2>&1; then
  exec godot --path .
fi

if command -v godot4 >/dev/null 2>&1; then
  exec godot4 --path .
fi

echo "Không tìm thấy Godot 4. Hãy tải Godot Standard tại https://godotengine.org/download/" >&2
exit 1
