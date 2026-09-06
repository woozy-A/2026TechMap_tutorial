# 실제 방 스캔 캡처 넣기

현재 Challenge의 `challenge-scan-flow.svg`는 설명용 흐름도입니다.
실제 기기에서 검증한 스캔 캡처가 없으므로 이를 실제 결과처럼 표시하지 않습니다.
Main의 Preview는 고정 Sample Room의 Simulator 결과입니다.

## 무엇을 찍나요?

1. **challenge-live-scan.png** — LiDAR 실제 기기에서 Scan Your Own Room을 누르고 벽·객체를 인식한 상태. Done 버튼을 포함합니다.
2. **challenge-live-result.png** — Done 뒤 Object Explorer에서 객체 하나를 선택한 상태. 목록의 checkmark와 분홍 box가 함께 보이게 합니다.

집 주소, 얼굴, 이름, 개인 물건 등 공개하면 곤란한 정보가 없는 안전한 공간에서 촬영하세요.
기기 모델·iOS 버전·앱 commit·촬영 날짜를 함께 기록합니다. Sample Room과 객체 수가 달라도 정상입니다.

## 어디에 넣나요?

`RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images/`에 위 두 파일명으로 저장하세요.
그다음 `Tutorials/05-ScanYourOwnRoom.tutorial`의 실제 실행 Step에 다음 한 줄씩 추가합니다.

스캔 실행 Step:

```text
@Image(source: "challenge-live-scan.png", alt: "LiDAR 실제 기기에서 촬영한 RoomPlan 스캔 화면. 벽과 객체를 인식하고 Done 버튼이 보임")
```

Done 뒤 실행 체크포인트 Step:

```text
@Image(source: "challenge-live-result.png", alt: "실제 방 스캔 뒤 Object Explorer의 객체 목록과 같은 UUID의 Highlight box가 보이는 화면")
```

처음 연결한 뒤부터는 **같은 파일명으로 PNG만 교체하고 문서를 재빌드·배포**하면 됩니다.
흐름도는 그대로 두어도 됩니다. 실제 캡처가 준비되기 전에는 이 이름의 가짜 UI 이미지를 넣지 않습니다.
문서 검증 예: `xcrun docc convert RoomPlanExampleApp/RoomPlanObjectExplorer.docc --analyze --warnings-as-errors --output-path /private/tmp/roomplan-capture-check.doccarchive`.
