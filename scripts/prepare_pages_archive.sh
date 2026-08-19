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
hosting_base_path=${DOCC_HOSTING_BASE_PATH:-2026TechMap_tutorial}
expected_base_url="/$hosting_base_path/"

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

touch "$archive_path/.nojekyll"

if [[ ! -f "$archive_path/.nojekyll" ]]; then
  echo "error: failed to create .nojekyll in the archive root" >&2
  exit 65
fi

# DocC can leave only the archive root pointing at `/` even when the deep
# tutorial routes use the requested static-hosting base path. GitHub Project
# Pages serves this site below the repository name, so fix the root shell too.
perl -0pi -e "s#var baseUrl = \"/\"#var baseUrl = \"$expected_base_url\"#g; s#(href|src)=\"/#\$1=\"$expected_base_url#g" "$archive_path/index.html"

if ! grep -Fq "var baseUrl = \"$expected_base_url\"" "$archive_path/index.html"; then
  echo "error: archive root does not use the expected base URL: $expected_base_url" >&2
  exit 65
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

  if ! grep -q 'id="roomplan-force-light-preload"' "$index_file"; then
    perl -0pi -e 's#</head>#<script id="roomplan-force-light-preload">try{localStorage.setItem("developer.setting.preferredColorScheme","light");localStorage.setItem("docs.setting.preferredColorScheme","light")}catch(e){}</script><style id="roomplan-force-light-style">body[data-color-scheme="light"]{--color-tutorials-overview-background:white;--color-tutorials-overview-content:rgb(17,17,17);--color-tutorials-overview-content-alt:rgb(51,51,51);--color-tutorials-overview-eyebrow:rgb(102,102,102);--color-tutorials-overview-icon:rgb(102,102,102);--color-tutorials-overview-link:rgb(0,102,204);--color-tutorials-overview-navigation-link:rgb(85,85,85);--color-tutorials-overview-navigation-link-active:rgb(17,17,17);--color-tutorials-overview-navigation-link-hover:rgb(0,102,204);--color-tutorial-hero-background:white;--color-tutorial-hero-text:rgb(17,17,17);--color-hero-eyebrow:rgb(102,102,102)}body[data-color-scheme="light"] .tutorials-overview .hero{--color-tutorials-overview-background:white!important;--color-tutorials-overview-content:rgb(17,17,17)!important;--color-tutorials-overview-content-alt:rgb(51,51,51)!important;--color-tutorials-overview-eyebrow:rgb(102,102,102)!important;--color-tutorials-overview-link:rgb(0,102,204)!important;background:white!important;color:rgb(17,17,17)!important}body[data-color-scheme="light"] .tutorials-overview .hero .title,body[data-color-scheme="light"] .tutorials-overview .hero .content,body[data-color-scheme="light"] .tutorials-overview .hero .content p,body[data-color-scheme="light"] .tutorials-overview .hero .content strong,body[data-color-scheme="light"] .tutorials-overview .hero .content code,body[data-color-scheme="light"] .tutorials-overview .hero .meta,body[data-color-scheme="light"] .tutorials-overview .hero .meta *{color:rgb(17,17,17)!important}body[data-color-scheme="light"] .tutorials-overview .hero a.inline-link{color:rgb(0,102,204)!important}body[data-color-scheme="light"] .tutorials-overview .hero .button-cta,body[data-color-scheme="light"] .tutorials-overview .hero .button-cta *{color:white!important}body[data-color-scheme="light"] .tutorials-overview .chapter{background:white!important;color:rgb(17,17,17)!important}body[data-color-scheme="light"] .tutorials-overview .chapter .name,body[data-color-scheme="light"] .tutorials-overview .chapter .name-text{color:rgb(17,17,17)!important}body[data-color-scheme="light"] .tutorials-overview .chapter .topic-icon{background:rgb(242,242,247)!important;color:rgb(85,85,85)!important}body[data-color-scheme="light"] .tutorials-overview .chapter .topic-icon svg{color:rgb(85,85,85)!important}</style></head>#' "$index_file"
  fi

  if ! grep -q 'id="roomplan-force-korean-light"' "$index_file"; then
    perl -0pi -e 's#</body>#<script id="roomplan-force-korean-light">\(\(\)=>{const force=\(\)=>{if\(document.documentElement.lang!=="ko"\)document.documentElement.lang="ko";if\(document.body&&document.body.dataset.colorScheme!=="light"\)document.body.dataset.colorScheme="light"};force\(\);new MutationObserver\(force\).observe\(document.documentElement,{attributes:true,subtree:true,attributeFilter:["lang","data-color-scheme"]}\)}\)\(\);</script></body>#' "$index_file"
  fi
done < <(find_index_files)

ko_count=0
en_us_count=0
light_count=0
auto_count=0
runtime_guard_count=0
preload_count=0
light_style_count=0

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

  if grep -q 'id="roomplan-force-light-preload"' "$index_file"; then
    preload_count=$((preload_count + 1))
  fi

  if grep -q 'id="roomplan-force-light-style"' "$index_file"; then
    light_style_count=$((light_style_count + 1))
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

if [[ $preload_count -ne $index_count ]]; then
  echo "error: expected $index_count early light-mode preferences, found $preload_count" >&2
  exit 65
fi

if [[ $light_style_count -ne $index_count ]]; then
  echo "error: expected $index_count light overview styles, found $light_style_count" >&2
  exit 65
fi

echo "Prepared DocC Pages archive: $index_count index files stay lang=ko with a white overview and light runtime"
