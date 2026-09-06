# Original Office Chair v2 — 교체하는 법

`Chair.usdz`를 Xcode의 `Resources`로 끌어 놓고 **Copy items if needed**와
**RoomPlanExampleApp target**을 선택하세요. Starter에는 의자가 미리 들어 있지 않습니다.

## 코드 수정 없이 다른 의자 넣기

새 USDZ를 **Chair.usdz**로 이름 바꿔 기존 파일 자리에 교체합니다.
같은 이름의 파일을 두 개 추가하지 마세요. Target Membership을 확인하고 앱을 다시 실행합니다.
이미 실행 중인 앱은 원본 모델을 캐시하므로 파일 교체 후 반드시 Stop → Run 합니다.

## 다른 파일명 유지하기

`MyChair.usdz`를 추가하고 `ObjectExplorerViewController.swift`의 mapping 한 줄만 변경합니다.

```swift
.chair: FurnitureAsset(resourceName: "MyChair")
```

모델이 뒤를 보고 있다면 `FurnitureAsset(resourceName: "MyChair", yawCorrectionDegrees: 180)`처럼
Y축 방향을 보정합니다. RoomPlan이 의자의 의미상 앞면을 항상 알아내는 것은 아닙니다.
임의 모델의 잘못된 up-axis, 손상된 geometry, 빠진 외부 texture까지 자동으로 고치지는 않습니다.

앱은 비율을 유지하며 RoomPlan box **안에 들어오도록** 축소/확대하고 바닥을 맞춥니다.
따라서 box를 세 축 모두 꽉 채우는 것과 다릅니다. category마다 하나의 모델을 사용하며
실행 중 Files에서 가져오기나 의자마다 다른 모델 선택은 현재 튜토리얼 범위가 아닙니다.

v2의 외형: 곡면 쿠션, 일체형 등받이 shell, 얇은 팔걸이, 평평한 금속 다리.
원본은 `scripts/generate_chair_asset.py`로 재생성합니다. 렌더는 내보낸 USDZ를 다시 불러와 만들었습니다.
CC0 라이선스와 출처·크기·해시는 동봉 문서를 참고하세요.
