# DocC Screenshot Plan

기준일: 2026-08-12

가짜 화면이나 placeholder를 사용하지 않는다. Xcode 위치 안내는 각 Section 직전의 검증된 source snapshot에서 촬영하고, 실행 결과는 해당 단계 Simulator checkpoint만 사용한다.

## Instruction Screenshot

Instruction Screenshot은 일반 `@Image`로 표시한다. 실제 Xcode 화면을 필요한 위치까지 crop하고, 파란 번호 박스로 클릭·검색할 지점을 표시한다. 다음 기능을 미리 노출하지 않도록 각 Section 시작 직전 tag에서 촬영한 원본만 사용한다.

| 위치 | DocC resource | 촬영 기준 | 보여주는 행동 |
| --- | --- | --- | --- |
| Section 1 / Open | `instruction-01-project-open.png` | `tutorial-starter-v1` (`f114349`) | Xcode에 열린 project와 Swift editor 확인 |
| Section 1 / Run | `instruction-02-run-controls.png` | `tutorial-starter-v1` (`f114349`) | scheme → Simulator → Run 순서 |
| Section 1 / Locate | `instruction-03-find-show-sample-room.png` | `tutorial-starter-v1` (`f114349`) | `OnboardingViewController.swift`와 `showSampleRoom(_:)` 위치 |
| Section 2 / Locate | `instruction-04-find-part2.png` | `tutorial-stage-part-1-v1` (`01f1782`) | `ObjectExplorerViewController.swift`의 Part 2 MARK와 두 hook |
| Section 3 / Locate | `instruction-05-find-part3.png` | `tutorial-stage-part-2-v1` (`c6dfc0f`) | Part 3 MARK, `isObjectSelected(_:)`, `selectObject(at:)` 위치 |
| Section 4 / Locate | `instruction-06-find-part4-render.png` | `tutorial-stage-part-3-v1` (`3503c18`) | Part 4 MARK, `renderObjectBoxes()`, `updateHighlight()` 위치 |

원본 여섯 장은 실제 Xcode 창을 1215 × 768로 촬영했다. crop과 번호 박스 외에는 코드와 UI를 편집하지 않았다. `@Code(previousFile:)`가 바뀐 줄을 정확히 보여주는 코드 Step에는 중복 screenshot을 넣지 않는다.

## Result Preview

Result Preview는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩한다. 이 구조가 코드 오른쪽의 Preview 패널을 만들며, 본문에 의미 없이 이미지를 붙이는 용도가 아니다.

| 단계 | DocC resource | 실제 결과 |
| --- | --- | --- |
| Section 1 | `part1-sample-room-loaded.png` | `Sample Room Loaded`, 목록과 object box는 아직 없음 |
| Section 2 | `part2-objects-detected.png` | `11 Objects Detected`, category와 dimensions 목록 |
| Section 3 | `part3-chair2-selected.png` | `Chair 2 Selected`와 checkmark, Highlight는 아직 없음 |
| Section 4 중간 | `part4-all-boxes.png` | dimensions와 transform을 적용한 모든 teal box |
| Highlight 구현 | `part4-chair2-highlight.png` | 선택된 Chair 2 box 하나만 선명한 분홍색 Highlight |
| Run and Test | `part4-table1-highlight-tested.png` | Table 1 선택 시 status, checkmark, Highlight가 함께 이동 |
| Completion | `completion-object-explorer.png` | Table 2를 선택한 완성 상태 |

Overview의 `overview-object-explorer.png`와 Main Tutorial Intro의 `goal-object-explorer.png`는 각각 해당 페이지에서 완성 목표를 먼저 보여주는 Goal Preview다. Main Tutorial 안에서는 같은 screenshot을 반복하지 않는다.

## 검증 기준

1. Instruction Screenshot은 실제 Xcode 위치와 현재 Section 시작 source가 일치하는가?
2. Result Preview는 결과를 만드는 `@Code`의 `runtimePreview`로 생성되는가?
3. 다음 Section의 학습 코드가 이미지에 미리 보이지 않는가?
4. 파일명, MARK, 함수명, Run 버튼, 결과 문구가 판독 가능한가?
5. `docc convert --analyze --warnings-as-errors`와 `docbuild`가 image reference를 모두 해석하는가?

Challenge는 물리 LiDAR 기기에서 검증된 실제 scan 이미지가 생길 때까지 screenshot을 참조하지 않는다. Optional Editing도 별도 누적 snapshot과 runtime checkpoint가 검증되기 전에는 Final Example 이미지를 hands-on 증거로 재사용하지 않는다.
