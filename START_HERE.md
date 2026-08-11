# RoomPlan Object Explorer — Tutorial Starter

이 프로젝트는 Xcode에서 DocC 안내를 보며 Part 1부터 Part 4까지 코드를 직접 입력하는 hands-on Starter입니다.

- 공개 Tutorial: <https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanobjectexplorer/>
- Starter ZIP: <https://github.com/woozy-A/2026TechMap_tutorial/releases/download/v1.0.0/RoomPlanTutorialStarter.zip>

## 시작하기

1. `RoomPlanExampleApp.xcodeproj`를 Xcode에서 엽니다.
2. 필요하면 Signing & Capabilities에서 자신의 Development Team과 고유 Bundle Identifier를 선택합니다.
3. Project navigator에서 `RoomPlanObjectExplorer.docc`를 엽니다.
4. Overview의 Part 1부터 순서대로 진행합니다.
5. 각 Part가 끝날 때마다 Build / Run하고 화면 checkpoint를 확인합니다.

Main Tutorial은 Simulator에서 진행할 수 있고 LiDAR가 필요하지 않습니다.

## 학습 순서

```text
Part 1 — Get a CapturedRoom
Part 2 — Explore Captured Objects
Part 3 — Select an Object
Part 4 — Visualize the Selected Object in 3D
```

학습자가 수정하는 위치는 두 파일 상단의 MARK에 모여 있습니다.

- `RoomPlanExampleApp/OnboardingViewController.swift`
- `RoomPlanExampleApp/ObjectExplorerViewController.swift`

Starter 상태에서 **Explore Sample Room**을 누르면 `Start Part 1` 안내가 나타나는 것이 정상입니다.

## Sample Room

`RoomPlanExampleApp/Resources/Room.json`은 모든 학습자가 같은 `CapturedRoom` 결과로 실습하기 위한 고정 snapshot입니다. JSON 내부 값을 직접 분석하거나 입력하지 않습니다.

`Room.usdz`는 포함되지 않으며 runtime에서도 사용하지 않습니다.

## Challenge와 Optional

`Challenge — Scan Your Own Room`은 LiDAR를 지원하는 실제 iPhone 또는 iPad와 카메라 권한이 필요합니다. Starter에 Apple Sample scan과 Explorer 연결이 이미 있으므로, callback을 확인한 뒤 실제 방에서 실행합니다.

`Optional — Correct or Remove an Object`는 Main Tutorial 이후의 Further Exploration입니다. Phase 2 Final Example의 설계를 설명하지만 Part 4 위의 누적 hands-on snapshot으로 아직 검증되지 않았으므로 Main 완료 조건이나 45~55분 예상에 포함하지 않습니다.

## Catalog 위치

`RoomPlanExampleApp/RoomPlanObjectExplorer.docc`

학습 시작점은 이 파일과 DocC Overview입니다. Apple RoomPlan Sample 출처는 `README.md`에 기록되어 있습니다.
