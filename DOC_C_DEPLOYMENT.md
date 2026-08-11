# DocC GitHub Pages Deployment

기준일: 2026-08-11  
검증 환경: Xcode 26.6 (`17F113`)  
예정 repository: `2026TechMap_tutorial`

이 문서는 repository를 만들거나 push하지 않는다. 실제 repository가 준비된 뒤 사용할 build와 Pages 설정만 고정한다.

## URL과 base path

GitHub Project Pages의 예상 주소는 다음과 같다.

```text
https://<owner>.github.io/2026TechMap_tutorial/
```

DocC hosting base path는 대소문자까지 정확히 다음 값이다.

```text
2026TechMap_tutorial
```

owner 이름, `.git`, 전체 URL은 base path에 넣지 않는다. GitHub Project Pages URL 구조는 [GitHub Pages 안내](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages)를 따른다.

## 로컬 Xcode DocC build

repository root에서 실행한다.

```bash
DOCBUILD_DIR="$PWD/.build/DocCDerivedData"

xcodebuild docbuild \
  -project RoomPlanExampleApp.xcodeproj \
  -scheme RoomPlanExampleApp \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DOCBUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  DOCC_HOSTING_BASE_PATH=2026TechMap_tutorial
```

현재 Xcode에서 이 명령은 app Swift compile과 `CompileDocumentation`을 실행하고 정적 hosting 변환까지 수행했다.

archive 위치를 고정 경로로 가정하지 않고 실제 결과를 찾는다.

```bash
ARCHIVE_PATH="$(find "$DOCBUILD_DIR" -type d -name '*.doccarchive' -print -quit)"

test -n "$ARCHIVE_PATH"
test -f "$ARCHIVE_PATH/index.html"
```

이 `.doccarchive` 디렉터리 자체가 GitHub Pages에 올릴 static-site root다. 별도의 `2026TechMap_tutorial/` 폴더로 한 번 더 감싸지 않는다.

## base path 확인

root와 deep page 모두 같은 base path를 가져야 한다.

```bash
rg 'baseUrl = "/2026TechMap_tutorial/"' "$ARCHIVE_PATH/index.html"

rg 'baseUrl = "/2026TechMap_tutorial/"' \
  "$ARCHIVE_PATH/tutorials/roomplanobjectexplorer/index.html"
```

튜토리얼 route도 확인한다.

```bash
find "$ARCHIVE_PATH/tutorials" -type f -name index.html -print
```

기대 route는 Overview, Part 1~4, Challenge, Optional의 7개다.

## explicit transform 명령

현재 DocC의 실제 subcommand는 다음 형태다.

```bash
xcrun docc process-archive transform-for-static-hosting \
  "$RAW_ARCHIVE_PATH" \
  --output-path "$STATIC_SITE_DIR" \
  --hosting-base-path 2026TechMap_tutorial
```

다만 Xcode 26.6에서 `--no-transform-for-static-hosting`으로 만든 raw archive에 이 명령을 적용했을 때 deep pages에는 base path가 적용됐지만 root `index.html`은 `/`를 유지하는 결과를 관찰했다. 그래서 이 프로젝트의 배포 기준은 위의 **one-step `xcodebuild docbuild` + `DOCC_HOSTING_BASE_PATH`** 방식이다. explicit transform을 사용할 때도 root와 deep page를 모두 검사한 뒤에만 배포한다.

## GitHub Actions 예시

repository root에 다음 workflow를 추가할 수 있다. 현재 Phase에서는 실제 파일 생성과 push를 하지 않는다.

```yaml
name: Deploy DocC to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: macos-26
    env:
      DEVELOPER_DIR: /Applications/Xcode_26.6.app/Contents/Developer

    steps:
      - uses: actions/checkout@v6
      - uses: actions/configure-pages@v5

      - name: Build DocC site
        shell: bash
        run: |
          set -euo pipefail

          DOCBUILD_DIR="$RUNNER_TEMP/DocCDerivedData"

          xcodebuild docbuild \
            -project RoomPlanExampleApp.xcodeproj \
            -scheme RoomPlanExampleApp \
            -destination 'generic/platform=iOS' \
            -derivedDataPath "$DOCBUILD_DIR" \
            CODE_SIGNING_ALLOWED=NO \
            DOCC_HOSTING_BASE_PATH=2026TechMap_tutorial

          ARCHIVE_PATH="$(find "$DOCBUILD_DIR" -type d -name '*.doccarchive' -print -quit)"
          test -n "$ARCHIVE_PATH"
          test -f "$ARCHIVE_PATH/index.html"
          rg 'baseUrl = "/2026TechMap_tutorial/"' "$ARCHIVE_PATH/index.html"

          echo "ARCHIVE_PATH=$ARCHIVE_PATH" >> "$GITHUB_ENV"

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v4
        with:
          path: ${{ env.ARCHIVE_PATH }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}

    steps:
      - name: Deploy
        id: deployment
        uses: actions/deploy-pages@v4
```

GitHub의 custom Pages workflow 구조는 [공식 Pages workflow 안내](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)를 따른다. Runner image와 Xcode 경로는 배포 시점에 [macOS runner manifest](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md)에서 다시 확인한다.

## GitHub에서 한 번만 할 설정

1. repository 이름을 정확히 `2026TechMap_tutorial`로 만든다.
2. Settings → Pages로 이동한다.
3. Build and deployment → Source에서 **GitHub Actions**를 선택한다.
4. workflow를 `main`에 push한다.
5. workflow가 알려주는 `page_url`에서 root와 Part 4 deep link를 각각 새로고침한다.

## 배포 전 acceptance

- `xcrun docc convert ... --analyze --warnings-as-errors` 통과
- Xcode `docbuild`에서 `CompileDocumentation`과 `BUILD DOCUMENTATION SUCCEEDED`
- root/deep page base path가 모두 `/2026TechMap_tutorial/`
- Overview에서 Part 1~4, Challenge, Optional 연결
- code와 image resource 누락 없음
- 브라우저 Network에 404 asset 없음
- Challenge/Optional의 아직 없는 screenshot을 참조하지 않음
