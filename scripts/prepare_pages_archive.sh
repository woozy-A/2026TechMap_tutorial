#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 <path-to-static-docc-archive>" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 64
fi

archive_path=$1

find_index_files() {
  find "$archive_path" -type d -name .git -prune -o -type f -name index.html -print0
}

if [[ ! -d "$archive_path" ]]; then
  echo "error: archive directory does not exist: $archive_path" >&2
  exit 66
fi

if [[ ! -f "$archive_path/index.html" ]]; then
  echo "error: archive root is missing index.html: $archive_path" >&2
  exit 66
fi

index_count=0
invalid_count=0

while IFS= read -r -d '' index_file; do
  index_count=$((index_count + 1))

  if ! grep -Eq '<html lang="(en-US|ko)"' "$index_file"; then
    echo "error: unsupported or missing html language declaration: $index_file" >&2
    invalid_count=$((invalid_count + 1))
  fi
done < <(find_index_files)

if [[ $index_count -eq 0 ]]; then
  echo "error: archive contains no index.html files: $archive_path" >&2
  exit 65
fi

if [[ $invalid_count -ne 0 ]]; then
  echo "error: refusing to modify an archive with invalid language declarations" >&2
  exit 65
fi

while IFS= read -r -d '' index_file; do
  perl -pi -e 's/<html lang="en-US"/<html lang="ko"/g' "$index_file"
  perl -pi -e 's/data-color-scheme="auto"/data-color-scheme="light"/g' "$index_file"

  if ! grep -q 'id="roomplan-force-korean-light"' "$index_file"; then
    perl -0pi -e 's#</body>#<script id="roomplan-force-korean-light">\(\(\)=>{const force=\(\)=>{if\(document.documentElement.lang!=="ko"\)document.documentElement.lang="ko";if\(document.body&&document.body.dataset.colorScheme!=="light"\)document.body.dataset.colorScheme="light"};force\(\);new MutationObserver\(force\).observe\(document.documentElement,{attributes:true,subtree:true,attributeFilter:["lang","data-color-scheme"]}\)}\)\(\);</script></body>#' "$index_file"
  fi
done < <(find_index_files)

ko_count=0
en_us_count=0
light_count=0
auto_count=0
runtime_guard_count=0

while IFS= read -r -d '' index_file; do
  if grep -q '<html lang="ko"' "$index_file"; then
    ko_count=$((ko_count + 1))
  fi

  if grep -q '<html lang="en-US"' "$index_file"; then
    en_us_count=$((en_us_count + 1))
  fi

  if grep -q 'data-color-scheme="light"' "$index_file"; then
    light_count=$((light_count + 1))
  fi

  if grep -q 'data-color-scheme="auto"' "$index_file"; then
    auto_count=$((auto_count + 1))
  fi

  if grep -q 'id="roomplan-force-korean-light"' "$index_file"; then
    runtime_guard_count=$((runtime_guard_count + 1))
  fi
done < <(find_index_files)

if [[ $ko_count -ne $index_count ]]; then
  echo "error: expected $index_count Korean index files, found $ko_count" >&2
  exit 65
fi

if [[ $en_us_count -ne 0 ]]; then
  echo "error: $en_us_count index files still declare lang=en-US" >&2
  exit 65
fi

if [[ $light_count -ne $index_count ]]; then
  echo "error: expected $index_count light index files, found $light_count" >&2
  exit 65
fi

if [[ $auto_count -ne 0 ]]; then
  echo "error: $auto_count index files still use the automatic color scheme" >&2
  exit 65
fi

if [[ $runtime_guard_count -ne $index_count ]]; then
  echo "error: expected $index_count runtime language/color guards, found $runtime_guard_count" >&2
  exit 65
fi

echo "Prepared DocC Pages archive: $index_count index files stay lang=ko and light at runtime"
