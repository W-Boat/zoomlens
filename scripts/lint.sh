#!/usr/bin/env bash
# 静态分析入口（CI 与本地共用）
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
flutter analyze --fatal-infos
