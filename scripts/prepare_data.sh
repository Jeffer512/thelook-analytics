#!/usr/bin/env bash
# Stream-extract the pinned TheLook Kaggle mirror straight to .csv.gz.
# The uncompressed CSV never touches disk (`unzip -p` pipes into gzip).
#
# The snapshot is pinned to 2024-01-21 (mirror: https://www.kaggle.com/datasets/mustafakeser4/looker-ecommerce-bigquery-dataset).
set -euo pipefail
cd "$(dirname "$0")/.."

ZIP="${1:-${THELOOK_ZIP:-}}"
if [[ -z "$ZIP" ]]; then
  echo "usage: $0 /path/to/looker-ecommerce-bigquery-dataset.zip" >&2
  echo "   or: THELOOK_ZIP=/path/to/zip $0" >&2
  exit 1
fi
if [[ ! -f "$ZIP" ]]; then
  echo "zip not found: $ZIP" >&2
  exit 1
fi
FILES=(distribution_centers events inventory_items order_items orders products users)

mkdir -p data
for f in "${FILES[@]}"; do
  if [ -f "data/${f}.csv.gz" ]; then
    echo "skip  data/${f}.csv.gz (exists)"
    continue
  fi
  echo "gzip  ${f}.csv"
  unzip -p "$ZIP" "${f}.csv" | gzip -9c > "data/${f}.csv.gz"
done

echo "done - snapshot:"
ls -lh data/
