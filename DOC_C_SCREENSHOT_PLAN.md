# DocC Screenshot Plan

기준일: 2026-08-11

가짜 화면이나 placeholder를 사용하지 않는다. Xcode 위치 안내는 각 Section 직전의 검증된 source snapshot에서 촬영하고, 실행 결과는 해당 단계 Simulator checkpoint만 사용한다.

## Instruction Screenshot

Instruction Screenshot은 일반 `@Image`로 표시한다. 다음 기능을 미리 노출하지 않도록 각 Section 시작 직전 tag에서 촬영했다.

| Section | DocC resource | 촬영 기준 | 보여주는 행동 |
| --- | --- | --- | --- |
| 1 | `xcode-section1-onboarding-location.png` | `tutorial-starter-v1` (`f114349`) | Run 버튼과 destination, `OnboardingViewController.swift`, `showSampleRoom(_:)`, `Resources/Room.json` 위치 |
| 2 | `xcode-section2-captured-objects-location.png` | `tutorial-stage-part-1-v1` (`01f1782`) | `ObjectExplorerViewController.swift`의 Part 2 MARK와 두 개의 빈 hook |
| 3 | `xcode-section3-object-selection-location.png` | `tutorial-stage-part-2-v1` (`c6dfc0f`) | Part 3 MARK, `isObjectSelected(_:)`, `selectObject(at:)` 위치 |
| 4 | `xcode-section4-visualization-location.png` | `tutorial-stage-part-3-v1` (`3503c18`) | Part 4 MARK, `renderObjectBoxes()`, `updateHighlight()` 위치 |

네 이미지는 모두 실제 Xcode 창을 1215 × 768로 촬영했다. 개인 정보가 들어 있는 editor, console, 경로는 포함하지 않았다.

## Result Preview

Result Preview는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩한다. 이 구조가 코드 오른쪽의 Preview 패널을 만들며, 본문에 의미 없이 이미지를 붙이는 용도가 아니다.

| 단계 | DocC resource | 실제 결과 |
| --- | --- | --- |
| Section 1 | `part1-sample-room-loaded.png` | `Sample Room Loaded`, 목록과 object box는 아직 없음 |
| Section 2 | `part2-objects-detected.png` | `11 Objects Detected`, category와 dimensions 목록 |
| Section 3 | `part3-chair2-selected.png` | `Chair 2 Selected`와 checkmark, Highlight는 아직 없음 |
| Section 4 중간 | `part4-all-boxes.png` | dimensions와 transform을 적용한 모든 teal box |
| Section 4 완료 | `part4-chair2-highlight.png` | 선택된 Chair 2 box 하나만 노란색 Highlight |

Main Tutorial 시작의 Goal Preview는 완성 목표를 먼저 보여주기 위한 유일한 독립 결과 이미지다.

## 검증 기준

1. Instruction Screenshot은 실제 Xcode 위치와 현재 Section 시작 source가 일치하는가?
2. Result Preview는 결과를 만드는 `@Code`의 `runtimePreview`로 생성되는가?
3. 다음 Section의 학습 코드가 이미지에 미리 보이지 않는가?
4. 파일명, MARK, 함수명, Run 버튼, 결과 문구가 판독 가능한가?
5. `docc convert --analyze --warnings-as-errors`와 `docbuild`가 image reference를 모두 해석하는가?

Challenge는 물리 LiDAR 기기에서 검증된 실제 scan 이미지가 생길 때까지 screenshot을 참조하지 않는다. Optional Editing도 별도 누적 snapshot과 runtime checkpoint가 검증되기 전에는 Final Example 이미지를 hands-on 증거로 재사용하지 않는다.
