# DocC Screenshot Plan

기준일: 2026-08-16

가짜 화면이나 placeholder를 사용하지 않는다. Instruction Screenshot은 검증된 `tutorial-starter-v2.3` Xcode source를 보여주고, Result Preview는 exact v2.3 Simulator checkpoint를 사용한다.

## Instruction Screenshot

각 Section 시작 Step에서 일반 `@Image`로 실제 수정 위치를 보여준다. 이어지는 `@Code(previousFile:)`가 정확한 변경 줄을 강조한다.

| Section | Resource | 실제 수정 위치 |
| --- | --- | --- |
| 1 | `v23-instruction-part1.jpeg` | `App/OnboardingViewController.swift`의 Get a CapturedRoom MARK |
| 2 | `v23-instruction-part2.jpeg` | `ObjectExplorerViewController.swift`의 Explore Objects MARK |
| 3 | `v23-instruction-part3.jpeg` | 같은 파일의 Selection MARK |
| 4 | `v23-instruction-part4.jpeg` | 같은 파일의 Visualize Objects MARK |
| 5 | `v23-instruction-part5.jpeg` | 같은 파일의 Replace with 3D Model MARK |
| 6 | `v23-instruction-part6.jpeg` | 같은 파일의 Rotate the 3D Model MARK |

여섯 장은 실제 Xcode 26.6 창을 1215 × 768로 촬영했다. Source 내용이나 UI를 합성하지 않았다.

## Code-linked Result Preview

결과 이미지는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩해 DocC `runtimePreview`로 생성한다.

| Section | Resource | 실제 결과 |
| --- | --- | --- |
| 1 | `v23-part1-sample-room-loaded.jpeg` | `Sample Room Loaded`, object pipeline 미연결 |
| 2 | `v23-part2-objects-detected.jpeg` | `11 Objects Detected`와 category 목록 |
| 3 | `v23-part3-chair2-selected.jpeg` | `Chair 2 Selected`, box 미렌더링 |
| 4 | `v23-part4-chair2-highlight.jpeg` | RoomPlan pose의 boxes와 Chair 2 Highlight |
| 5 | `v23-part5-chair2-replaced.png` | Chair 2 box를 project-original 3D Chair로 교체 |
| 6 | `v23-part6-chair2-rotated-90.png` | 같은 RoomPlan 위치에서 replacement를 Y축 90° 회전 |

Section 5와 6 PNG는 1206 × 2622 exact Simulator capture다. Sections 1~4 JPEG는 같은 전용 iOS 26.5 Simulator에서 v2.3 exact product를 단계별로 설치해 캡처했다.

## 검증 기준

1. 각 이미지의 MARK, 함수명, status와 control이 해당 Section snapshot과 일치하는가?
2. Result Preview가 독립 decoration이 아니라 결과를 만드는 `@Code`의 `runtimePreview`인가?
3. 다음 Section의 기능을 현재 checkpoint 이미지가 미리 보여주지 않는가?
4. Section 5에서는 Rotate 버튼이 숨겨지고 Section 6에서 replacement 후 처음 나타나는가?
5. `docc convert --analyze --warnings-as-errors`와 Xcode `docbuild`가 모든 image/code reference를 해석하는가?

Challenge는 물리 LiDAR 기기 evidence가 생기기 전까지 screenshot을 추가하지 않는다. Optional Editing도 별도 누적 snapshot이 검증되기 전에는 hands-on checkpoint로 표현하지 않는다.
