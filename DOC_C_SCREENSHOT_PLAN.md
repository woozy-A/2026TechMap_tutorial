# DocC Screenshot Plan

기준일: 2026-08-16

가짜 화면이나 placeholder를 사용하지 않는다. 각 Instruction Screenshot은 해당 Section을 시작하기 직전의 exact v2.4 누적 snapshot을 Xcode에서 연 화면이고, Result Preview는 exact v2.4 Simulator checkpoint다.

## Instruction Screenshot

각 Section 시작 Step에서 일반 `@Image`로 실제 수정 위치를 보여준다. 이어지는 `@Code(previousFile:)`가 정확한 변경 줄을 강조한다.

| Section | Resource | 실제 수정 위치 |
| --- | --- | --- |
| 1 | `v24-instruction-part1.jpg` | Starter의 `App/OnboardingViewController.swift` — Get a CapturedRoom MARK |
| 2 | `v24-instruction-part2.jpg` | Part 1 완료 snapshot — Explore Objects MARK |
| 3 | `v24-instruction-part3.jpg` | Part 2 완료 snapshot — Selection MARK |
| 4 | `v24-instruction-part4.jpg` | Part 3 완료 snapshot — Visualize Objects의 두 빈 hook |
| 5 | `v24-instruction-part5.jpg` | Part 4 완료 snapshot — Replace with 3D Model의 두 빈 hook |
| 6 | `v24-instruction-part6.jpg` | Part 5 완료 snapshot — Rotate the 3D Model의 두 빈 hook |

여섯 장은 실제 Xcode 26.6 창을 1215 × 768로 촬영했다. Source 내용이나 UI를 합성하지 않았다.

## Code-linked Result Preview

결과 이미지는 해당 결과를 만드는 `@Code` 안에 `@Image`를 중첩해 DocC `runtimePreview`로 생성한다.

| Section | Resource | 실제 결과 |
| --- | --- | --- |
| 1 | `v24-part1-sample-room-loaded.png` | `Sample Room Loaded`, object pipeline 미연결 |
| 2 | `v24-part2-objects-detected.png` | `11 Objects Detected`와 category 목록 |
| 3 | `v24-part3-chair2-selected.png` | `Chair 2 Selected`, box 미렌더링 |
| 4A | `v24-part4-all-boxes.png` | `dimensions`와 `transform`을 적용해 모든 box가 처음 나타남 |
| 4B | `v24-part4-chair2-highlight.png` | Chair 2와 같은 identifier의 box만 분홍 Highlight |
| 5A | `v24-part5-replace-button.png` | 교체 가능한 Chair를 선택하면 Replace 버튼이 처음 나타남 |
| 5B | `v24-part5-chair2-replaced.png` | Chair 2 box를 project-original 3D Chair로 교체 |
| 6A | `v24-part6-rotate-button.png` | 교체된 Chair를 선택하면 Rotate 버튼이 처음 나타남 |
| 6B | `v24-part6-chair2-rotated-90.png` | 같은 RoomPlan 위치에서 replacement를 Y축 90° 회전 |

아홉 결과 이미지는 모두 전용 iPhone 17 Pro / iOS 26.5 Simulator에서 exact v2.4 product를 단계별로 설치해 1206 × 2622 PNG로 캡처했다. 각 이미지는 다음 Section의 control을 미리 보여주지 않는다.

## 검증 기준

1. 각 이미지의 MARK, 함수명, status와 control이 해당 Section snapshot과 일치하는가?
2. Result Preview가 독립 decoration이 아니라 결과를 만드는 `@Code`의 `runtimePreview`인가?
3. 다음 Section의 기능을 현재 checkpoint 이미지가 미리 보여주지 않는가?
4. Section 5에서는 Rotate 버튼이 숨겨지고 Section 6에서 replacement 후 처음 나타나는가?
5. `docc convert --analyze --warnings-as-errors`와 Xcode `docbuild`가 모든 image/code reference를 해석하는가?

Challenge는 물리 LiDAR 기기 evidence가 생기기 전까지 screenshot을 추가하지 않는다. Optional Editing도 별도 누적 snapshot이 검증되기 전에는 hands-on checkpoint로 표현하지 않는다.
