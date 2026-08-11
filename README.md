# RoomPlan Object Explorer Tutorial

RoomPlan을 처음 사용하는 학습자가 Starter Project에 코드를 직접 추가하며 다음 흐름을 익히는 한국어 DocC hands-on tutorial입니다.

```text
CapturedRoom
→ objects
→ identifier
→ dimensions / transform
→ RealityKit Entity
→ Highlight
```

## 바로 시작하기

- [공개 DocC Tutorial](https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanobjectexplorer/)
- [Starter Project ZIP 다운로드](https://github.com/woozy-A/2026TechMap_tutorial/releases/download/v1.0.0/RoomPlanTutorialStarter.zip)
- 로컬 시작 안내: [`START_HERE.md`](START_HERE.md)

Main Tutorial은 Simulator에서 진행할 수 있고 LiDAR가 필요하지 않습니다. 실제 방을 scan하는 Challenge만 LiDAR 지원 iPhone 또는 iPad가 필요합니다.

## 구성

- Main Tutorial — 한 페이지에서 이어지는 네 Section
  - Section 1 — Get a CapturedRoom
  - Section 2 — Explore Captured Objects
  - Section 3 — Select an Object
  - Section 4 — Visualize the Selected Object in 3D
- Challenge — Scan Your Own Room
- Optional — Correct or Remove an Object

## 기반 Sample

이 프로젝트는 Apple의 RoomPlan Sample을 기반으로 scan UI와 delegate 흐름을 재사용합니다.

[Create a 3D model of an interior room by guiding the user through an AR experience](https://developer.apple.com/documentation/roomplan/create_a_3d_model_of_an_interior_room_by_guiding_the_user_through_an_ar_experience)
