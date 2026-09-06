# 튜토리얼 작업 그림 안내

## 이번 보강의 원칙

코드를 입력하지 않는 Step도 학습자가 해야 할 행동 또는 이해할 관계를 보여줍니다.
Main 25개·Challenge 9개 Step 모두 이미지가 연결됩니다. 원래 9개 실행 Preview는 보존하고,
Recap 3개와 Challenge 읽기 코드 2개에는 설명 도식을 연결합니다.

새 SVG 14개는 **설명용 도식 · 실제 캡처 아님** 표시가 있습니다.
Xcode UI를 촬영한 것처럼 꾸미지 않고 파일·이름·화살표·box의 관계를 그렸습니다.
기존 Simulator 캡처를 Challenge에서 다시 사용할 때도 Sample Room 비교용임을 명시합니다.
새로운 실기기 검증이나 사용자 모델 실행 결과를 증명하는 자료가 아닙니다.

DocC의 [Step](https://www.swift.org/documentation/docc/step)은 코드 또는 이미지로 작업을 설명합니다.
코드가 없는 단계는 Step의 `@Image`, Recap과 읽기 코드는 `@Code` 안의 `@Image`를 사용합니다.
별도 웹 위젯이나 스타일 변경 없이 기존 DocC 학습 화면에 표시합니다.

## 파일명과 의도

모든 파일은 `RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images/`에 있습니다.
SVG는 글자를 고칠 수 있는 원본이며 외부 폰트·이미지·스크립트를 다운로드하지 않습니다.

| 파일명 | 연결 위치 | 그림에서 확인할 것 |
| --- | --- | --- |
| `guide-starter-path.svg` | Main Section 1 · Step 1 | ZIP 안에서 열 프로젝트, Simulator 첫 실행 순서 |
| `guide-visualization-map.svg` | Main Section 4 · Recap | dimensions·transform·identifier 각각의 역할 |
| `guide-add-usdz.svg` | Main Section 5 · Step 1 | Assets → Resources, 복사와 Target Membership |
| `guide-swap-file.svg` | Main Section 5 · Step 5 | 방법 A: 새 파일을 Chair.usdz로 교체, mapping 유지 |
| `guide-asset-mapping.svg` | Main Section 5 · Step 6 | 방법 B: category → resourceName → USDZ 파일명 |
| `guide-model-fitting.svg` | Main Section 5 · Step 7 | 같은 배율, box 안의 여백, 바닥 정렬 |
| `guide-replacement-pipeline.svg` | Main Section 5 · 도입부와 Recap | await → 선택 재확인 → 장면 교체 → 상태 갱신 |
| `guide-rotation-cycle.svg` | Bonus · 도입부와 Recap | 위치 유지, local Y축, 4번 후 원래 방향 |
| `guide-scan-callbacks.svg` | Challenge 첫 Section · Step 1 / 두 번째 Section · Step 3 | Done → 결과 처리 → didPresent |
| `guide-result-handoff.svg` | Challenge 첫 Section · Step 2 | configure의 데이터 전달과 화면 전환의 차이 |
| `guide-shared-explorer.svg` | Challenge 첫 Section · Step 3 | 다른 두 입력이 같은 Explorer에 합류 |
| `guide-device-setup.svg` | Challenge 두 번째 Section · Step 1 | 완료한 프로젝트 유지, 실제 기기·서명·실행 대상 |
| `guide-scan-room.svg` | Challenge 두 번째 Section · Step 2 | 스캔 선택·카메라 허용·LiDAR 확인·안전한 이동 |
| `guide-optional-checks.svg` | Challenge 세 번째 Section · Step 3 | 필수 완료와 USDZ·회전의 추가 조건 구별 |

Main 및 Bonus 완료 Step에는 기존 교체·회전 전후 캡처를 연결합니다.
Challenge의 목록·선택 Step은 기존 `v6-section4-all-boxes.png`와
`v6-section4-highlight.png`를 **Sample Room 비교 자료**로 보여줍니다.

## 내가 그림이나 캡처를 바꾸려면

1. **도식 문구만 고치기:** 위 SVG의 `<text>` 내용을 수정하거나 같은 파일명으로 새 SVG를 저장합니다.
2. **실제 Xcode 캡처로 바꾸기:** 예를 들어 파일 추가 창을 찍어 `guide-add-usdz.png`로 이 폴더에 저장합니다.
   Main의 Section 5 Step 1에서 `source: "guide-add-usdz.svg"`를 `source: "guide-add-usdz.png"`로 바꾸고,
   `alt`도 실제 사진의 내용으로 바꿉니다. 이미지는 새로 추가하지 말고 기존 `@Image`를 교체합니다.
   처음 연결한 뒤에는 같은 이름의 PNG를 덮어쓰면 됩니다.
3. **실제 방 스캔 캡처:** [CHALLENGE_CAPTURE_GUIDE.md](CHALLENGE_CAPTURE_GUIDE.md)의 파일명·두 Step을 사용합니다.
4. 원본 SVG는 다시 활용할 수 있게 남겨두고, 연결 변경에 맞춰 이미지 목록 검사도 갱신합니다.
5. 문서를 재빌드하고 로컬 화면을 확인한 다음 배포해야 공개 사이트에 반영됩니다.

이미지 크기는 도식 기준 1000×680입니다. 작은 Preview에서는 확대해서 읽을 수 있게 핵심 라벨을 크게 배치했습니다.
실제 캡처는 내용을 임의로 그려 넣거나 성공한 것처럼 합성하지 말고, 개인정보를 제외한 관찰 가능한 상태를 사용하세요.

## 검증 상태

2026-09-06 로컬 검증 결과:

- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`: 20개 통과.
  Step별 이미지 연결, SVG 접근성·외부 의존성, 실제 코드와 도식의 대응, 기존 학습 코드·실습 ZIP 보존을 검사합니다.
- `docc convert --analyze --warnings-as-errors`: 통과. 정적 호스팅 준비도 통과했습니다.
- 빌드된 문서 데이터에서도 Main 25/25, Challenge 9/9 Step의 이미지 또는 코드 Preview 연결을 확인했습니다.
- 1280×720 로컬 브라우저: Section 5의 파일 추가·방법 A·방법 B·크기 맞춤 도식과 스크롤 시 전환을 확인했습니다.
  Challenge의 읽기 코드 Preview 표시 및 열기/닫기도 확인했습니다. 14개 SVG의 텍스트 경계 검사를 수행했습니다.
- 앱 Swift 코드, Chair USDZ, 기존 캡처, 실습 ZIP, 사이트 스타일은 변경하지 않았습니다.
  이번 작업에서 앱 빌드·실기기 스캔·모바일 화면 검증을 새로 수행한 것은 아닙니다.
- 위 검증 당시에는 로컬 체크포인트 상태였습니다. 이후 공개 반영 결과는 아래에 기록합니다.

## 공개 배포 완료 — 2026-09-06

- 시각화 소스 `649e1ca`를 기존 `main`에 반영했습니다.
- Xcode `docbuild` 성공. 별도 임시 DerivedData를 사용했고 서명·Simulator 실행은 하지 않았습니다.
- 공개 파일 커밋: `6dbf077`. 기존 `gh-pages` 위에 overlay하여 예전 route를 삭제하지 않았습니다.
- [Pages 배포 34038986776](https://github.com/woozy-A/2026TechMap_tutorial/actions/runs/34038986776): build·deploy 성공.
- 공개 문서·이미지·실습 ZIP 40개 모두 HTTP 200이며 배포 파일과 SHA-256이 같습니다.
  새 SVG 14개는 검증한 소스와 동일하며, Main·Bonus 25/25 및 Challenge 9/9 Step의 미디어 연결을 확인했습니다.
- 새 공개 브라우저에서 Section 5의 파일 추가 작업 그림이 본문 옆에 표시되는 것을 확인했습니다.
- 기존 이미지·CSS·JavaScript·실습 ZIP은 변경하지 않았습니다. JSON의 실질적 내용 변경은 Main과 Challenge뿐이며,
  나머지 JSON 136개는 직렬화 순서 차이입니다. 한국어·다크 소개·라이트 학습 화면을 유지한 HTML은 138개입니다.
- [Section 5 바로 보기](https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanexampleapp/01-getcapturedroom/#Section-5-Add-and-Place-a-3D-Asset)
