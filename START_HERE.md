# RoomPlan Object Explorer — Tutorial Starter

이 프로젝트는 한 페이지로 이어지는 DocC Tutorial을 보며 Main Section 1부터 Section 5까지 코드를 직접 입력하고, 원한다면 Rotation Bonus까지 이어가는 hands-on Starter입니다.

## 대상 사용자

- Xcode에서 iOS 프로젝트를 열고 Build/Run 해본 경험이 있는 사람
- Swift 기본 문법(변수, 함수, 배열, Optional 등)을 이해하는 사람
- UIKit의 기본 개념(UIViewController, 버튼, 화면 전환 등)을 접해본 사람
- RoomPlan으로 스캔한 공간과 객체 데이터를 앱에서 활용하는 방법을 배우고 싶은 사람

RoomPlan, RealityKit, LiDAR / AR 개발, 3D 모델 제작, USDZ 구조에 대한 사전 경험은 없어도 괜찮습니다.

- 공개 Tutorial: <https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanobjectexplorer/>
- Starter ZIP: <https://github.com/woozy-A/2026TechMap_tutorial/releases/download/tutorial-docc-v6/RoomPlanTutorialStarter-v2.6.zip>
- 최신 실습 자료: Main 페이지 상단 다운로드 아이콘 **Project files** (`RoomPlanTutorialMaterials-v2.7.zip`). `Starter`와 `Assets/Chair.usdz`(의자 v2)를 함께 제공합니다.
- 위 Starter 단독 링크는 기존 v2.6 코드만 받는 호환용 링크입니다.

## 시작하기

1. 공개 Tutorial URL을 열고 **RoomPlan Object Explorer 만들기**를 선택합니다.
2. Main 페이지 상단 Project files로 실습 자료를 받고 압축을 풉니다. `Starter` 폴더가 학습 프로젝트입니다.
3. `RoomPlanExampleApp.xcodeproj`를 Xcode에서 엽니다.
4. 필요하면 Signing & Capabilities에서 자신의 Development Team과 고유 Bundle Identifier를 선택합니다.
5. Tutorial의 행동 순서대로 파일을 찾고 코드를 직접 입력합니다.
6. 실행 체크포인트마다 `Command-R`로 실행하고 결과 Preview와 실제 화면을 비교합니다. 넓은 화면에서는 코드 옆 Preview를 펼치고, 좁은 화면에서는 코드 아래로 스크롤합니다. Recap은 관련 코드만 모은 요약이므로 별도 Preview가 없습니다.

Main Tutorial은 Simulator에서 진행할 수 있고 LiDAR가 필요하지 않습니다.

## 학습 순서

```text
Section 1 — Get a CapturedRoom
Section 2 — Explore Captured Objects
Section 3 — Select an Object
Section 4 — Visualize the Selected Object in 3D
Section 5 — Add and Place a 3D Asset
Bonus — Rotate the Replacement Model
```

학습자가 수정하는 위치는 두 파일 상단의 MARK에 모여 있습니다.

- `RoomPlanExampleApp/App/OnboardingViewController.swift`
- `RoomPlanExampleApp/ObjectExplorer/ObjectExplorerViewController.swift`

Starter 상태에서 **Explore Sample Room**을 누르면 `Start Part 1` 안내가 나타나는 것이 정상입니다.

## Sample Room

`RoomPlanExampleApp/Resources/Room.json`은 모든 학습자가 같은 `CapturedRoom` 결과로 실습하기 위한 고정 snapshot입니다. JSON 내부 값을 직접 분석하거나 입력하지 않습니다.

`Room.usdz`는 포함되지 않으며 runtime에서도 사용하지 않습니다.

Starter target에는 `Chair.usdz`가 들어 있지 않습니다. Section 5에서 실습 자료의 `Assets/Chair.usdz`를 Xcode target에 직접 추가합니다. `Assets/README.md`에는 파일 교체 방법과 방향·크기 보정의 범위가 있습니다.

- 다른 의자를 `Chair.usdz`로 이름 바꿔 교체하면 mapping 코드는 그대로 사용할 수 있습니다. 교체 후 Target Membership을 확인하세요.
- `MyChair.usdz`처럼 다른 이름을 쓰면 `.chair: FurnitureAsset(resourceName: "MyChair")`로 mapping 한 곳만 바꿉니다.
- `Bed.usdz`나 `Table.usdz`는 dictionary에 해당 category mapping을 한 줄 추가하면 같은 `dimensions` / `transform` pipeline으로 연결됩니다.

이 예제는 category마다 하나의 asset을 연결합니다. object마다 서로 다른 model을 고르는 picker와 runtime Files import는 tutorial 범위에 포함하지 않습니다.

## Conditional Challenge와 Further Exploration

`Conditional Challenge — Scan Your Own Room`은 LiDAR를 지원하는 실제 iPhone 또는 iPad, 카메라 권한, 안전하게 scan할 실내 공간이 모두 있을 때만 진행합니다. 조건을 충족하지 못해도 Main Tutorial과 Bonus는 정상적으로 완료한 것입니다.

`Further Exploration — Correct or Remove an Object`는 Main Tutorial과 Rotation Bonus 이후에 읽는 Article입니다. Final Example v1.6의 설계를 설명하지만 별도 누적 hands-on snapshot으로는 아직 검증되지 않았으므로 Main 완료 조건이나 80분 예상에 포함하지 않습니다.

## Catalog 위치

`RoomPlanExampleApp/RoomPlanObjectExplorer.docc`

학습 시작점은 공개 DocC Overview입니다. ZIP 안의 이 문서는 링크와 환경을 다시 확인하기 위한 보조 안내입니다. Apple RoomPlan Sample 출처는 `README.md`에 기록되어 있습니다.
