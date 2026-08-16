# RoomPlan Deliverables v2.4

## Current release candidates

- `RoomPlanTutorialStarter-v2.4.zip`
  - Section 1부터 시작하는 빌드 가능한 hands-on Starter.
  - RoomPlan learner hook은 비어 있고 UIKit, RealityKit, camera, table, asset-fitting boilerplate만 제공합니다.
- `RoomPlanTutorialSolution-v2.4.zip`
  - Section 1~6을 모두 누적한 완료 Solution.
  - Object list → selection → Highlight → Chair replacement → 90° rotation을 포함합니다.
- `RoomPlanFinalExample-v1.4.zip`
  - Solution 기능과 Optional Category Correction / Remove를 함께 보존한 Final Example.

각 ZIP은 root-level `BUILD_INFO.md`에 annotated source tag, peeled commit, source tree, `Room.json`, `Chair.usdz` identity를 기록합니다. Starter와 Solution은 `START_HERE.md`에서 공개 DocC Overview → Main Tutorial → Sections 1~6 진행 순서를 안내합니다.

`.git`, `Room.usdz`, reference JPG, `.blend` / `.blend1`, AppleDouble `._*`, `__MACOSX` 파일은 포함하지 않습니다. 기존 `OriginalOfficeChair-CC0-v1.zip`은 이 packaging pass에서 변경하거나 재생성하지 않았습니다.
