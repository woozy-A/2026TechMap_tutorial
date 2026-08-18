# DocC GitHub Pages Deployment

기준일: 2026-08-11  
검증 환경: Xcode 26.6 (`17F113`)  
repository: `woozy-A/2026TechMap_tutorial`

## 현재 공개 상태

- Source: <https://github.com/woozy-A/2026TechMap_tutorial>
- Pages: <https://woozy-a.github.io/2026TechMap_tutorial/>
- Pages source: `gh-pages` branch의 `/`
- HTTPS enforced: true
- 최초 공개 static commit: `2b8a65d`

현재 배포는 검증된 로컬 `.doccarchive`를 `gh-pages` branch에 게시하는 방식이다. 아래 GitHub Actions 예시는 이후 자동화를 위한 대안이다.

## URL과 base path

GitHub Project Pages 공개 주소는 다음과 같다.

```text
https://woozy-a.github.io/2026TechMap_tutorial/
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

## 한국어 HTML language 준비

Xcode 26.6의 DocC render template은 static HTML을 `lang="en-US"`로 생성한다. 한국어 본문을 브라우저가 다시 자동 번역해 코드와 문장을 섞지 않도록, build가 끝난 archive에 배포 전용 후처리를 실행한다. 앱의 development language나 `project.pbxproj`는 변경하지 않는다.

```bash
./scripts/prepare_pages_archive.sh "$ARCHIVE_PATH"
```

이 스크립트는 archive 안의 모든 `index.html`을 `lang="ko"`, `data-color-scheme="light"`로 준비한다. DocC의 client script가 load 뒤 값을 `en-US` 또는 `auto`로 되돌리는 경우도 있으므로, 같은 값을 유지하는 작은 runtime guard도 각 page에 한 번만 넣는다. 전체 index 개수와 한국어·light·runtime guard 개수가 모두 같고 `lang="en-US"`와 `auto`가 0개인 경우에만 성공한다. archive 경로가 잘못됐거나 예상하지 않은 language declaration이 있으면 파일을 삭제하지 않고 nonzero로 종료한다.

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

source archive의 기대 route는 Overview, Main Sections 1~5와 Rotation Bonus가 합쳐진 Main Tutorial, Conditional Challenge, Further Exploration Article이다. 기존 Part 2~4 공개 deep link는 archive source가 아니라 아래 overlay 정책에 따라 `gh-pages`에 보존한다.

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

향후 `main` push마다 자동 배포하려면 repository root에 다음 workflow를 추가하고 Pages source를 GitHub Actions로 전환할 수 있다. 현재 공개 site는 이 workflow가 아니라 `gh-pages` branch source를 사용한다.

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

          ./scripts/prepare_pages_archive.sh "$ARCHIVE_PATH"

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

## 현재 GitHub Pages 설정

1. repository 이름: `2026TechMap_tutorial`
2. visibility: public
3. Build and deployment source: Deploy from a branch
4. branch/path: `gh-pages` / `/`
5. 공개 URL에서 root와 각 tutorial deep link를 직접 확인한다.

## v5 준비 및 기존 공개 route 보존 정책

- v5 archive는 현재 v4 `gh-pages` branch 위에 **overlay**한다. branch 전체를 지우거나 force push하지 않는다.
- 이미 공유된 legacy Part 2~4 route의 HTML, render JSON, 참조 이미지는 유지한다. v2.4 이미지는 `v24-` resource 이름을 사용해 legacy asset을 덮어쓰지 않는다.
- overlay가 끝난 Pages worktree에도 `./scripts/prepare_pages_archive.sh "$PAGES_WORKTREE"`를 실행한다. 그래야 새 archive뿐 아니라 보존된 legacy route의 HTML도 모두 `lang="ko"`가 된다.
- source revision은 새 `tutorial-docc-v5` tag로 고정한다. 기존 `v1.0.0`, `tutorial-docc-v2`, `tutorial-docc-v3`, `tutorial-docc-v4` tag를 이동하거나 다시 만들지 않는다.
- Starter **package 내용**이 동일한 동안에만 기존 release asset을 재사용한다. 앱 Swift가 같더라도 `START_HERE.md`, DocC catalog, code snapshot, screenshot이 바뀌면 새 package로 배포한다.
- v5는 v2.5 누적 snapshot, 프로젝트에서 제작해 CC0로 제공하는 밝은 Chair, Main Section 1~5와 Rotation Bonus를 사용하므로 `tutorial-docc-v5` release에 `RoomPlanTutorialStarter-v2.5.zip`과 `OriginalOfficeChair-CC0-v1.zip`을 새 asset으로 올린다. 기존 release asset은 교체하거나 삭제하지 않는다.

## 배포 acceptance

- `xcrun docc convert ... --analyze --warnings-as-errors` 통과
- Xcode `docbuild`에서 `CompileDocumentation`과 `BUILD DOCUMENTATION SUCCEEDED`
- root/deep page base path가 모두 `/2026TechMap_tutorial/`
- 모든 static `index.html`의 `lang="ko"`, `lang="en-US"` 0개
- Overview에서 Main Tutorial, Conditional Challenge, Further Exploration Article 연결
- Main Tutorial 한 페이지 안에 Main Section 1~5와 Rotation Bonus가 순서대로 존재
- checkpoint screenshot이 일반 삽입 이미지가 아니라 `@Code { @Image }`의 `runtimePreview`로 연결
- code와 image resource 누락 없음
- 브라우저 Network에 404 asset 없음
- Challenge/Optional의 아직 없는 screenshot을 참조하지 않음
- app bundle에 `Room.json`과 프로젝트에서 제작해 CC0로 제공하는 `Chair.usdz`가 있고 `Room.usdz`는 없음
- Starter에서 Main Section 5의 replacement 전까지 Rotate 버튼이 숨겨지고 Rotation Bonus에서만 표시

## v2 배포 기록 — 2026-08-11

- Main Tutorial source commit: `52122c3` (`Unify RoomPlan tutorial into one guided page`)
- GitHub Pages content commit: `cba8cea` (`Deploy RoomPlan DocC v2`)
- v1 deep-link preservation commit: `3995954` (`Preserve v1 tutorial deep links`)
- Pages workflow run: `31493436270` — build / deploy 모두 success
- revision tag: `tutorial-docc-v2`
- 기존 `v1.0.0` tag, release, `RoomPlanTutorialStarter.zip` asset은 변경하지 않았다.

v2 Overview는 하나의 Main Tutorial만 안내한다. Main page는 기존 Part 1 URL인 `/tutorials/roomplanexampleapp/01-getcapturedroom/`을 재사용하고 Section 1~4를 한 페이지에 담는다. source catalog에서는 이전 Part 2~4 tutorial 파일을 제거했지만, 이미 공유된 공개 deep link는 `gh-pages`에 legacy page로 보존했다.

공개 브라우저에서 다음을 확인했다.

- Overview → Main Tutorial → 한 페이지의 Section 1~4 → Challenge
- `@Code { @Image }`로 생성된 code + `Preview` 패널
- Part 1 `Sample Room Loaded`와 Part 4 `Chair 2 Highlight` runtime preview
- 390 × 844 좁은 viewport에서 단일 열 layout과 접히는 Preview 링크
- 공개 route와 기존 Part 2 legacy route HTTP 200
- Starter ZIP HTTP 200, 1,334,065 bytes, SHA-256 `c8655a8b10b9d3fa0e9c7f5cdc746a23e2545837382e4f59fb8cfcbc4c11f024`

## v4 배포 기록 — 2026-08-12

- visual-learning source commit: `59e9218` (`Improve RoomPlan tutorial visual guidance`)
- revision tag: `tutorial-docc-v4` — 기존 v1~v3 tag는 이동하거나 변경하지 않았다.
- GitHub Pages content commit: `879b991` (`Deploy RoomPlan DocC v4`)
- Pages workflow run: `31514483599` — build / deploy 모두 success
- release: <https://github.com/woozy-A/2026TechMap_tutorial/releases/tag/tutorial-docc-v4>
- Starter asset: `RoomPlanTutorialStarter-v4.zip`, 5,328,702 bytes
- Starter SHA-256: `ecdd8d484057019d476a3ff99a72e6d29c792b13716330f1e6c2eb7287008604`

공개 브라우저에서 다음을 확인했다.

- Overview의 Starter 설명과 Main Tutorial 링크
- Main Tutorial의 final-result Hero와 `CapturedRoom → objects → Select → 3D Highlight` 흐름
- Project open, scheme / Simulator / Run, `showSampleRoom(_:)`, Part 2~4 MARK를 안내하는 실제 Xcode screenshot 6개
- Part 1~3 checkpoint, all-box rendering, Highlight까지 5개의 code-linked runtime Preview
- Chair 2, Table 1, Table 2 실제 실행 화면에서 checkmark, status, 선명한 분홍색 Highlight의 일치
- Completion 다음에 중복 없이 한 번만 나타나는 Challenge CTA
- Overview, Main, Challenge, Optional, 기존 Part 2 legacy route HTTP 200
- 공개 Starter asset을 다시 내려받아 local archive와 동일한 SHA-256 및 정상 압축 상태 확인

## v5 배포 기록 — 2026-08-18

- source commit: `e3ea3e0` (`Synchronize RoomPlan DocC learning paths`)
- revision tag: `tutorial-docc-v5`
- GitHub Pages content commit: `2058565` (`Deploy RoomPlan DocC v5`)
- Pages workflow run: `32139915085` — success
- release: <https://github.com/woozy-A/2026TechMap_tutorial/releases/tag/tutorial-docc-v5>
- Starter asset: `RoomPlanTutorialStarter-v2.5.zip`, 379,958 bytes
- Starter SHA-256: `36c5f312352245a8f2e420575a0dc9012d4c2c034c4e1ed5fad278bba6bb69e5`
- DocC source asset: `RoomPlanDocC-v5-source.zip`
- source ZIP SHA-256: `d583dbf0cb90d221e6b9851b32526dda7411789ca35f2abf47af9feb4b2ab5ab`

공개 Pages에서 다음을 확인했다.

- v5 당시 Overview의 초급 난이도, 대상, hands-on 진행 방식
- Overview → Main Section 1~5와 Rotation Bonus
- LiDAR 조건을 명시한 Conditional Challenge
- `@Article`로 생성된 Further Exploration (`kind: article`, `role: article`)
- Section 2에서 학습자가 `object.category`와 `object.dimensions`를 직접 쓰는 안내와 code panel
- Starter/Chair ZIP 공개 Release 연결
- 기존 Part 2~4 legacy route를 포함한 검증 대상 route HTTP 200

`06-OptionalEditing`은 v5에서 top-level directive를 `@Tutorial`에서 `@Article`로 바꿨지만 기존 공개 route와 `<doc:06-OptionalEditing>` 참조를 보존하기 위해 파일 basename과 `.tutorial` 확장자를 유지했다. Xcode DocC build와 공개 render data에서 `kind: article`, `role: article`을 확인했으므로 파일 이름만을 위한 rename은 하지 않는다.

## v5.2 배포 기록 — 2026-08-18

- content source commit: `04e5254` (`Clarify RoomPlan tutorial provenance and requirements`)
- GitHub Pages content commit: `b0f755f` (`Deploy RoomPlan DocC v5.2`)
- Pages workflow run: `32150083342` — build / deploy 모두 success
- revision tag: `tutorial-docc-v5.2`
- 기존 `tutorial-docc-v5` release의 `RoomPlanTutorialStarter-v2.5.zip`과 `OriginalOfficeChair-CC0-v1.zip`은 내용이 바뀌지 않아 그대로 재사용했다.

v5.2에서는 앱 코드와 Section 1~5 / Rotation Bonus의 학습 구조를 바꾸지 않고 공개 설명과 유지보수 문서를 정리했다.

- 모호한 난이도 라벨 없이 대상 사용자와 필요한 Xcode / Swift / UIKit 경험을 유지
- Xcode 26.6 / iOS 26.5 Simulator는 **검증 환경**, iOS 17+ Simulator는 **권장 실행 환경**으로 구분
- Chair asset은 외부 mesh를 내려받은 것이 아니라 프로젝트에서 제작해 CC0로 제공하는 sample임을 명시
- `06-OptionalEditing.tutorial`의 `@Article` 구조와 기존 public route를 의도적으로 함께 보존
- `DOC_C_SCREENSHOT_PLAN.md`의 현재 screenshot / snapshot 기준을 v2.5로 동기화

공개 브라우저와 HTTP에서 다음을 확인했다.

- Overview → Main Tutorial 연결 및 Main 한 페이지의 Section 1~5 + Rotation Bonus
- Conditional Challenge와 Further Exploration Article 연결
- 공개 render data의 `검증 환경`, `권장 실행 환경`, Chair CC0 provenance 반영
- `06-OptionalEditing`의 `kind: article`
- root, Overview, Main, Challenge, Further Exploration, legacy Part 2~4 route 모두 HTTP 200
- Starter v2.5와 CC0 Chair ZIP 다운로드 링크 모두 HTTP 200

## v6 배포 기록 — 2026-08-19

v6는 v5.2의 공개 route를 유지하면서 다음 학습·시각 계약을 변경한다.

- Starter `v2.6`에는 furniture USDZ를 미리 넣지 않는다.
- Section 5에서 별도 `RoomPlanFurnitureAsset-Chair-v1.zip`을 받고 `Chair.usdz`를 Xcode target에 직접 추가한다.
- `FurnitureAsset`과 `category → asset` mapping을 사용해 Bed, Table 또는 다른 Chair asset으로 확장 가능한 구조를 보여준다.
- Intro hero background image를 제거하고, 완성 화면 설명 옆에 실제 result image를 놓는다.
- runtime result는 상태바/Dynamic Island를 제외한 실제 Simulator capture를 흰 가로형 canvas로 제공한다.
- generated static archive의 모든 `index.html`은 `data-color-scheme="light"`와 `lang="ko"`를 사용한다.

release asset:

- `RoomPlanTutorialStarter-v2.6.zip`
- `RoomPlanTutorialSolution-v2.6.zip`
- `RoomPlanTutorialBonus-v2.6.zip`
- `RoomPlanFinalExample-v1.6.zip`
- `RoomPlanFurnitureAsset-Chair-v1.zip`
- `RoomPlanDocC-v6-source.zip`
- `SHA256SUMS-v6.txt`

배포 결과:

- content source commit / tag: `be2dec0` / `tutorial-docc-v6`
- runtime light-mode source hotfix: `e9a67db`
- GitHub Pages content commit: `4c061c5` (`Deploy RoomPlan DocC v6`)
- runtime light-mode Pages hotfix: `fce2af1`
- Pages workflow runs: `32156561141`, `32158005035` — build / deploy success
- release: <https://github.com/woozy-A/2026TechMap_tutorial/releases/tag/tutorial-docc-v6>
- Release asset 7개와 SHA-256 manifest 공개
- root, Overview, Main, Conditional Challenge, Further Exploration, legacy Part 2 route HTTP 200
- 공개 render data에서 Main Section 1~5 + Bonus, 별도 Chair asset 링크, generic `FurnitureAsset` mapping 확인
- 공개 Starter와 Chair ZIP을 다시 받아 local manifest와 같은 SHA-256 확인
- 최종 공개 Starter SHA-256: `d3852f00f6a48b15d09e7a1ca5f495b1d2748e3a858c04e84fdae11e26c5f7f6`

첫 공개 확인에서 static HTML은 light였지만 DocC client가 runtime 값을 `auto`로 되돌리는 것을 발견했다. `prepare_pages_archive.sh`에 idempotent runtime guard를 추가해 한국어와 light mode를 load 이후에도 고정하고, Pages의 모든 148개 index에 적용했다. hotfix 공개 page의 load 이후 값은 `htmlLang=ko`, `bodyColorScheme=light`, body background `rgb(255, 255, 255)`, 본문 `rgb(0, 0, 0)`이었다. Intro hero에는 image가 없고 Section 1의 1440 × 900 goal image가 설명 옆에 표시됐다. 실제 macOS 창 screenshot은 Mac 잠금 때문에 이번 기록 시점에 추가하지 못했으며, DOM·computed style·public render data 검증과 구분한다.
