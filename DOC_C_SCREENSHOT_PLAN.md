# DocC Screenshot Plan

기준일: 2026-08-16

가짜 화면이나 placeholder를 사용하지 않는다. 각 Instruction Screenshot은 해당 Section을 시작하기 직전의 exact v2.5 누적 snapshot을 Xcode에서 연 화면이고, Result Preview는 exact v2.5 Simulator checkpoint다. Section 1은 수정 위치가 v2.4와 동일하므로 검증된 기존 이미지를 재사용한다.

## Instruction Screenshot

각 Section 시작 Step에서 일반 `@Image`로 실제 수정 위치를 보여준다. 이어지는 `@Code(previousFile:)`가 정확한 변경 줄을 강조한다.

| Section | Resource | 실제 수정 위치 |
| --- | --- | --- |
| 1 | `v24-instruction-part1.jpg` | v2.5 Starter와 위치가 동일한 기존 이미지 — `App/OnboardingViewController.swift`의 Get a CapturedRoom MARK |
| 2 | `v25-instruction-part2.png` | Part 1 v2.5 완료 snapshot — Explore Objects MARK |
| 3 | `v25-instruction-part3.png` | Part 2 v2.5 완료 snapshot — Selection MARK |
| 4 | `v25-instruction-part4.png` | Part 3 v2.5 완료 snapshot — Visualize Objects의 두 빈 hook |
| 5 | `v25-instruction-part5.png` | Part 4 v2.5 완료 snapshot — Replace with 3D Model의 두 빈 hook |
| Bonus | `v25-instruction-bonus.png` | Main Solution v2.5 — Rotate the 3D Model의 두 빈 hook |

여섯 장은 실제 Xcode 26.6 창을 1215 × 768로 촬영했다. Source 내용이나 UI를 합성하지 않았다.

## Code-linked Result Preview

결과 이미지는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩해 DocC `runtimePreview`로 생성한다.

| Section | Resource | 실제 결과 |
| --- | --- | --- |
| 1 | `v25-part1-sample-room-loaded.png` | `Sample Room Loaded`, object pipeline 미연결 |
| 2 | `v25-part2-objects-detected.png` | `11 Objects Detected`와 category/dimensions 목록 |
| 3 | `v25-part3-chair2-selected.png` | `Chair 2 Selected`, box 미렌더링 |
| 4A | `v25-part4-all-boxes.png` | `dimensions`와 `transform`을 적용해 모든 box가 처음 나타남 |
| 4B | `v25-part4-chair2-highlight.png` | Chair 2와 같은 identifier의 box만 분홍 Highlight |
| 5A | `v25-part5-before-replacement.png` | 교체 전 Chair 2 Highlight와 Replace 버튼 |
| 5B | `v25-part5-after-replacement.png` | Chair 2 box를 프로젝트에서 제작해 CC0로 제공하는 3D Chair로 교체 |
| Bonus A | `v25-bonus-before-rotation.png` | 교체된 Chair와 Rotate 버튼이 처음 나타남 |
| Bonus B | `v25-bonus-after-rotation.png` | 같은 RoomPlan 위치에서 replacement를 Y축 90° 회전 |

아홉 결과 이미지는 모두 전용 iPhone 17 Pro / iOS 26.5 Simulator에서 exact v2.5 product를 단계별로 설치해 1206 × 2622 PNG로 캡처했다. 각 이미지는 다음 Section의 control을 미리 보여주지 않는다.

## 검증 기준

1. 각 이미지의 MARK, 함수명, status와 control이 해당 Section snapshot과 일치하는가?
2. Result Preview가 독립 decoration이 아니라 결과를 만드는 `@Code`의 `runtimePreview`인가?
3. 다음 Section의 기능을 현재 checkpoint 이미지가 미리 보여주지 않는가?
4. Section 5에서는 Rotate 버튼이 숨겨지고 Section 6에서 replacement 후 처음 나타나는가?
5. `docc convert --analyze --warnings-as-errors`와 Xcode `docbuild`가 모든 image/code reference를 해석하는가?

Challenge는 물리 LiDAR 기기 evidence가 생기기 전까지 screenshot을 추가하지 않는다. Optional Editing도 별도 누적 snapshot이 검증되기 전에는 hands-on checkpoint로 표현하지 않는다.
