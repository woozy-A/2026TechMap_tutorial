# DocC Screenshot Plan

기준일: 2026-08-19

가짜 화면이나 placeholder를 사용하지 않는다. Instruction Screenshot은 해당 Section의 실제 Xcode 수정 위치를 보여주고, Result Preview는 exact v2.6 Simulator checkpoint를 사용한다. 기존 Xcode instruction image는 v2.6에서도 MARK와 수정 위치가 같음을 source diff로 확인한 뒤 재사용한다.

## Instruction Screenshot

각 Section 시작 Step에서 일반 `@Image`로 실제 수정 위치를 보여준다. 이어지는 `@Code(previousFile:)`가 정확한 변경 줄을 강조한다.

| Section | Resource | 실제 수정 위치 |
| --- | --- | --- |
| 1 | `v24-instruction-part1.jpg` | v2.6 Starter의 `App/OnboardingViewController.swift`와 같은 Get a CapturedRoom MARK |
| 2 | `v25-instruction-part2.png` | Part 1 v2.6 완료 snapshot과 같은 Explore Objects MARK |
| 3 | `v25-instruction-part3.png` | Part 2 v2.6 완료 snapshot과 같은 Selection MARK |
| 4 | `v25-instruction-part4.png` | Part 3 v2.6 완료 snapshot과 같은 Visualize Objects hook |
| 5 | `v25-instruction-part5.png` | Part 4 v2.6 완료 snapshot과 같은 Replace with 3D Model MARK |
| Bonus | `v25-instruction-bonus.png` | Main Solution v2.6과 같은 Rotate the 3D Model MARK |

여섯 장은 실제 Xcode 26.6 창을 1215 × 768로 촬영했다. Source 내용이나 UI를 합성하지 않았다.

## Code-linked Result Preview

결과 이미지는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩해 DocC `runtimePreview`로 생성한다.

| Section | Resource | 실제 결과 |
| --- | --- | --- |
| Goal | `v6-goal-object-explorer.png` | 설명 옆에 놓는 흰 가로형 최종 결과. Hero 배경으로 사용하지 않음 |
| 1 | `v6-section1-sample-loaded.png` | `Sample Room Loaded`, object pipeline 미연결 |
| 2 | `v6-section2-objects-detected.png` | 3D Overview와 category/dimensions 목록을 가로로 병치 |
| 3 | `v6-section3-object-selected.png` | Overview와 selected row를 가로로 병치 |
| 4A | `v6-section4-all-boxes.png` | `dimensions`와 `transform`을 적용한 모든 box |
| 4B | `v6-section4-highlight.png` | 같은 identifier의 box만 분홍 Highlight |
| 5A | `v6-section5-asset-ready.png` | asset mapping 후 Replace 버튼이 보이는 상태 |
| 5B | `v6-section5-before-after.png` | 직접 추가한 `Chair.usdz`의 교체 전후 비교 |
| Bonus A | `v6-bonus-rotation-ready.png` | Rotate 버튼이 처음 나타난 상태 |
| Bonus B | `v6-bonus-before-after.png` | 같은 RoomPlan 위치에서 replacement를 Y축 90° 회전한 전후 비교 |

원본은 전용 iPhone 17 Pro / iOS 26.5 Simulator의 실제 v2.6 product에서 캡처했다. 상태바와 Dynamic Island를 제거하고 비율을 늘이지 않은 채 흰색 1440 × 900 또는 1440 × 820 가로 캔버스에 배치했다. 교체와 회전 이미지는 전후를 같은 크기로 나란히 비교한다.

## 검증 기준

1. 각 이미지의 MARK, 함수명, status와 control이 해당 Section snapshot과 일치하는가?
2. Result Preview가 독립 decoration이 아니라 결과를 만드는 `@Code`의 `runtimePreview`인가?
3. 다음 Section의 기능을 현재 checkpoint 이미지가 미리 보여주지 않는가?
4. Section 5에서는 Rotate 버튼이 숨겨지고 Section 6에서 replacement 후 처음 나타나는가?
5. `docc convert --analyze --warnings-as-errors`와 Xcode `docbuild`가 모든 image/code reference를 해석하는가?

Challenge는 물리 LiDAR 기기 evidence가 생기기 전까지 screenshot을 추가하지 않는다. Optional Editing도 별도 누적 snapshot이 검증되기 전에는 hands-on checkpoint로 표현하지 않는다.
