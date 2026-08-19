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

### Section 1 / 3 / 4 Preview 재현 규칙

아래 네 장은 `scripts/compose_preview_images.swift`가 `TutorialStageEvidenceV25`의 실제 캡처를 crop하고 **가로·세로 비율을 유지한 채 균일하게 확대**해 만든다. 생성형 이미지, UI retouch, 글자 재작성, 비균일 stretch는 사용하지 않는다. Section 2의 정상 가로형 Preview와 마찬가지로 1440 × 900 흰 캔버스에서 `3D Overview`와 `Object List`를 나란히 보여준다.

| Target resource | 실제 source state | Source capture | SHA-256 |
| --- | --- | --- | --- |
| `v6-section1-sample-loaded.png` | `Sample Room Loaded`, object pipeline 미연결, 빈 list | `TutorialStageEvidenceV25/01-sample-room-loaded.png` | `c9f3b39913e0c8aff6620979cc4a815addc272617c2a407291ce884ef0fc25bd` |
| `v6-section3-object-selected.png` | `Chair 2 Selected`, box/Highlight 미구현 | 왼쪽은 `03-chair2-selected.png`; 오른쪽 selected row는 같은 selection UI가 선명한 `04-chair2-highlight.png`의 list 영역만 사용 | `37546116d97e98dd296e69fd01110b9e4fce5dc93f8680b6569626c6c2af0f0a` / `b74ab6272642db355aeec4921f6c6c0784977bae5df64a3e77466f9fac847e43` |
| `v6-section4-all-boxes.png` | `11 Objects Detected`, 모든 dimensions/transform box, 선택 Highlight 없음 | 왼쪽은 `04-all-boxes.png`; 변하지 않은 list는 선명한 `02-objects-detected.png`의 list 영역만 사용 | `0489d4fc6c9fdb2e31931ff5e5b51fafc99e9961ce4bdbd661fc0ab58eda6a0b` / `b5d8955c1605624c97164cd0582c5b0a1a7924602ad72032eafec53ce078fb91` |
| `v6-section4-highlight.png` | `Chair 2 Selected`, 같은 identifier의 box 하나만 분홍 Highlight | `TutorialStageEvidenceV25/04-chair2-highlight.png` | `b74ab6272642db355aeec4921f6c6c0784977bae5df64a3e77466f9fac847e43` |

Section 3 오른쪽 crop은 Stage 4 캡처의 **list 영역만** 사용한다. Stage 3의 framed 캡처는 선택된 `Chair 2` row를 화면 아래에서 잘라 버리기 때문이다. 이 crop에는 box나 Highlight, replacement button 같은 다음 단계 UI가 포함되지 않으며, Stage 3에서 이미 완성한 UUID selection/checkmark만 보인다. Section 4A의 오른쪽 crop도 Stage 2 이후 변하지 않은 category/dimensions list만 사용한다.

재생성 명령은 DocC source repository root에서 다음과 같다.

```sh
swift scripts/compose_preview_images.swift \
  ../TutorialStageEvidenceV25 \
  RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images
```

Swift module cache 쓰기가 제한된 자동화 환경에서는 `SWIFT_MODULE_CACHE_PATH`와 `CLANG_MODULE_CACHE_PATH`를 writable temporary directory로 지정한다. 스크립트는 위 네 target만 덮어쓰며, 정상인 Section 2 / 5 / Bonus 이미지는 수정하지 않는다.

직접 새 캡처로 교체할 때는 다음 두 방법 중 하나만 사용한다.

1. **Source 교체 후 재생성:** 동일 checkpoint를 찍어 위 `TutorialStageEvidenceV25` source filename으로 교체하고 스크립트를 다시 실행한다. Simulator toolbar, device frame, iOS status bar는 crop 밖에 있어야 하며 mouse cursor가 결과 영역을 가리지 않아야 한다. 캡처 크기나 화면 배치가 달라졌다면 script의 해당 `TopLeftRect`를 실제 pixel 기준으로 함께 갱신한다.
2. **완성 Preview drop-in:** 1440 × 900 PNG를 target resource와 정확히 같은 filename으로 `RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images/`에 넣는다. DocC source 수정 없이 같은 `@Code { @Image }` 연결을 유지할 수 있다.

두 방법 모두 이전 Section에 다음 기능을 미리 보여주지 않고, status 문구·선택 row·box/Highlight 상태가 표의 source state와 정확히 일치해야 한다. 출력물을 먼저 직접 열어 빈 여백, 잘못된 crop, 글자/geometry 변형이 없는지 확인한 뒤 DocC Preview를 검증한다.

## 검증 기준

1. 각 이미지의 MARK, 함수명, status와 control이 해당 Section snapshot과 일치하는가?
2. Result Preview가 독립 decoration이 아니라 결과를 만드는 `@Code`의 `runtimePreview`인가?
3. 다음 Section의 기능을 현재 checkpoint 이미지가 미리 보여주지 않는가?
4. Section 5에서는 Rotate 버튼이 숨겨지고 Section 6에서 replacement 후 처음 나타나는가?
5. `docc convert --analyze --warnings-as-errors`와 Xcode `docbuild`가 모든 image/code reference를 해석하는가?

Challenge는 물리 LiDAR 기기 evidence가 생기기 전까지 screenshot을 추가하지 않는다. Optional Editing도 별도 누적 snapshot이 검증되기 전에는 hands-on checkpoint로 표현하지 않는다.
