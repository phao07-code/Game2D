#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

game="$PWD/build/linux/GiaiCuuNgoiLangHoa.x86_64"
if [[ ! -x "$game" ]]; then
  echo "Chưa có bản Linux. Đang build..."
  ./build_linux.sh
fi

exec "$game"
