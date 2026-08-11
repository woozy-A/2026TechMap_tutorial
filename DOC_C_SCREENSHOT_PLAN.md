# DocC Screenshot Plan

기준일: 2026-08-11

가짜 화면이나 임시 placeholder를 만들지 않는다. 실제 검증 과정에서 촬영한 이미지에만 DocC `@Image` reference를 둔다.

## 현재 사용 중인 이미지

| 페이지 | 목적 | DocC resource | 원본 증거 | 상태 |
| --- | --- | --- | --- | --- |
| Overview | Part 4 완성 상태 미리보기 | `overview-part4-highlight.png` | `TutorialStageEvidence/05-part4-chair2-highlight.png` | 포함·검증됨 |
| Part 1 | Sample Room Loaded | `part1-sample-room-loaded.png` | `TutorialStageEvidence/01-part1-sample-room-loaded.png` | 포함·검증됨 |
| Part 2 | 11 Objects Detected, Bed/Chair | `part2-objects-detected.png` | `TutorialStageEvidence/02-part2-objects-detected.png` | 포함·검증됨 |
| Part 2 | Storage/Table와 dimensions | `part2-storage-table.png` | `TutorialStageEvidence/02b-part2-storage-table.png` | 포함·검증됨 |
| Part 3 | Chair 2 Selected와 checkmark | `part3-chair2-selected.png` | `TutorialStageEvidence/03-part3-chair2-selected.png` | 포함·검증됨 |
| Part 4 | 모든 object box | `part4-all-boxes.png` | `TutorialStageEvidence/04-part4-all-boxes.png` | 포함·검증됨 |
| Part 4 | 선택 box Highlight | `part4-chair2-highlight.png` | `TutorialStageEvidence/05-part4-chair2-highlight.png` | 포함·검증됨 |

Catalog 내 위치:

`RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images/`

## 아직 없는 이미지

| 페이지 | 필요한 실제 화면 | 상태 | DocC reference |
| --- | --- | --- | --- |
| Challenge | `RoomCaptureView`가 실제 LiDAR 기기에서 방을 scan하는 화면 또는 scan 완료 후 자신의 Explorer | 물리 LiDAR 기기 미검증·미촬영 | 없음 |
| Optional | Category Correction 전후와 Remove 후 list/entity 동기화 | Phase 2 기능은 존재하지만 누적 Optional tutorial snapshot·전용 촬영 없음 | 없음 |

없는 이미지는 현재 `.tutorial` 파일에서 참조하지 않는다.

## 다음 촬영 기준

### Challenge

- LiDAR 지원 iPhone/iPad에서 camera permission, scan 진행, Done, 같은 Explorer 진입까지 먼저 검증한다.
- 방이나 개인 정보가 드러나지 않는 안전한 공간을 사용한다.
- 특정 object 수나 category를 정답처럼 보이게 하지 않는다.
- 촬영 후 `alt`에는 실제 보이는 상태만 기술한다.

### Optional

- 먼저 Part 4 위에 누적되는 Optional snapshot을 만들고 build/runtime checkpoint를 검증한다.
- 같은 `identifier`를 유지한 category correction 화면과, row/entity가 함께 사라진 Remove 화면을 각각 촬영한다.
- 해당 snapshot이 없으면 Phase 2 화면을 hands-on 완료 증거로 재라벨링하지 않는다.

## 이미지 교체 체크리스트

1. 실제 화면인가?
2. 해당 단계의 source commit과 일치하는가?
3. 다음 Part 기능이 미리 보이지 않는가?
4. 텍스트와 checkmark/Highlight가 판독 가능한가?
5. `@Image`의 `source`와 `alt`가 실제 파일·화면과 일치하는가?
6. DocC `--warnings-as-errors` 검증을 다시 통과하는가?
