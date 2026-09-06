# 실제 방 스캔 캡처 넣기

현재 Challenge의 `challenge-scan-flow.svg`와 `guide-*.svg`는 설명용 흐름도·작업 도식입니다.
실제 기기에서 검증한 스캔 캡처가 없으므로 이를 실제 결과처럼 표시하지 않습니다.
Main의 실행 Preview와 Challenge의 두 비교 이미지는 고정 Sample Room의 Simulator 결과입니다.
모든 Step에 도식 또는 비교 이미지가 연결되어 있으므로 새 캡처를 넣을 때 이미지 한 장을 추가하지 않습니다.

## 무엇을 찍나요?

1. **challenge-live-scan.png** — LiDAR 실제 기기에서 Scan Your Own Room을 누르고 벽·객체를 인식한 상태. Done 버튼을 포함합니다.
2. **challenge-live-result.png** — Done 뒤 Object Explorer에서 객체 하나를 선택한 상태. 목록의 checkmark와 분홍 box가 함께 보이게 합니다.

집 주소, 얼굴, 이름, 개인 물건 등 공개하면 곤란한 정보가 없는 안전한 공간에서 촬영하세요.
기기 모델·iOS 버전·앱 commit·촬영 날짜를 함께 기록합니다. Sample Room과 객체 수가 달라도 정상입니다.

## 어디에 넣나요?

`RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images/`에 위 두 파일명으로 저장하세요.
그다음 `Tutorials/05-ScanYourOwnRoom.tutorial`의 아래 두 Step에서 기존 `@Image` 한 줄을 교체합니다.

**「실제 방으로 실행하기」Step 2** (`Scan Your Own Room`과 카메라 권한 안내):

현재 `guide-scan-room.svg`를 가리키는 줄을 아래 줄로 교체합니다.

```text
@Image(source: "challenge-live-scan.png", alt: "LiDAR 실제 기기에서 촬영한 RoomPlan 스캔 화면. 벽과 객체를 인식하고 Done 버튼이 보임")
```

**「결과를 확인하고 마무리하기」Step 2** (row checkmark와 같은 box의 Highlight 확인):

현재 `v6-section4-highlight.png`를 가리키는 줄을 아래 줄로 교체합니다.

```text
@Image(source: "challenge-live-result.png", alt: "실제 방 스캔 뒤 Object Explorer의 객체 목록과 같은 UUID의 Highlight box가 보이는 화면")
```

처음 연결한 뒤부터는 **같은 파일명으로 PNG만 교체하고 문서를 재빌드·배포**하면 됩니다.
흐름도는 그대로 두어도 됩니다. 실제 캡처가 준비되기 전에는 이 이름의 가짜 UI 이미지를 넣지 않습니다.
문서 검증 예: `xcrun docc convert RoomPlanExampleApp/RoomPlanObjectExplorer.docc --analyze --warnings-as-errors --output-path /private/tmp/roomplan-capture-check.doccarchive`.

빌드 성공만으로 이미지 표시까지 검증한 것은 아닙니다. 로컬 또는 배포 페이지에서
세 Section이 모두 보이는지, 위 두 Step의 이미지가 열리는지 실제 브라우저에서도 확인하세요.
실제 기기 캡처를 추가한 뒤에는 본문의 「예시 이미지의 범위」와 이 안내의 검증 범위도 함께 갱신합니다.
