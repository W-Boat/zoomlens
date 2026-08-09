#!/usr/bin/env bash
# 单元测试入口（CI 与本地共用）
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
flutter test --coverage
