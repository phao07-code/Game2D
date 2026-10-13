#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

adb="$PWD/.tools/android-sdk/platform-tools/adb"
apk="$PWD/build/GiaiCuuNgoiLangHoa.apk"

if [[ ! -f "$apk" ]]; then
  echo "Chưa có APK. Đang build..."
  ./build_android.sh
fi

if [[ ! -x "$adb" ]]; then
  echo "Không tìm thấy ADB cục bộ." >&2
  exit 1
fi

if ! "$adb" devices | tail -n +2 | grep -q $'\tdevice$'; then
  echo "Không thấy điện thoại. Hãy bật USB debugging, cắm cáp và chấp nhận khóa RSA trên điện thoại." >&2
  exit 1
fi

"$adb" install -r "$apk"
echo "Đã cài game. Mở ứng dụng 'Giải Cứu Ngôi Làng Hoa' trên điện thoại."
