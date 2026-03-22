#!/usr/bin/env bash
set -euo pipefail

k6 run --config tests/performance/k6-config.json tests/performance/k6-script.js
