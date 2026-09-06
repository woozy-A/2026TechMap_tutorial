# RoomPlan 튜토리얼 학습 구조 검토

검토일: 2026-09-06

기준: 현재 소스와 Git 상태. 검토 시작 커밋은 `6d3409d`, 이번 Challenge 개선 커밋은 `215d1c0`입니다. 과거 배포 기록이나 대화의 평가만으로 현재 내용을 판단하지 않았습니다.

## 결론과 범위

**Main의 학습 순서를 다시 설계할 필요는 없습니다.** 데이터 읽기 → 목록 → 선택 → 3D 표시 → 모델 교체 → 선택적 회전의 연결이 자연스럽습니다. 현재 발견한 주요 약점은 기능 누락보다 **Starter가 대신 해주는 일과 방금 작성한 코드의 효과를 구별하는 설명**, 그리고 **Section 5의 난도 상승을 잇는 설명**입니다.

첫 검토에서는 Challenge를 수정하고, 그 전의 Overview·Main Sections 1~5·Bonus는 읽기 전용으로 검토했습니다. 이후 사용자의 승인으로 아래 Main 설명 개선안 1~5번을 반영했습니다. 문제 설명과 행 번호는 수정 전 검토 기록이며, 최신 반영·검증 결과는 문서 마지막에 정리합니다. 앱 실행 코드·USDZ·기존 이미지는 변경하지 않았습니다.

이는 문서·코드·제공 이미지의 정합성 검토입니다. 처음 보는 학습자의 사용성 실험이나 이번 차례의 Simulator/LiDAR 실행 검증을 대체하지 않습니다.

## 우선 보강할 지점

### 1. Section 1: “아직 비어 있다”와 실제 보이는 방 구조를 구별하기

- 위치: `Tutorials/01-GetCapturedRoom.tutorial` 37~42행.
- 확인한 사실: 체크포인트는 목록과 object box가 비어 있다고 정확히 설명합니다. 그런데 Preview 대체 텍스트는 “비어 있는 3D Overview”라고 되어 있고, 실제 이미지에는 벽·문·창문이 이미 보입니다.
- 근거: `ObjectExplorerViewController.swift`의 `viewDidLoad()`가 Starter의 `renderRoomStructure()`를 먼저 호출합니다. 그 다음이 학습자가 작성하는 객체 목록·box 함수입니다.
- 영향: 학습자가 “내가 입력하지 않은 벽은 어디서 나왔지?” 또는 “비어 있어야 하는데 잘못했나?”라고 생각할 수 있습니다. 화면 읽기 도구의 이미지 설명도 부정확합니다.
- 권장 보강: “벽·문·창문은 Starter가 미리 그려줍니다. 이번 단계에서는 가구 목록과 가구 box가 비어 있으면 정상입니다.”를 추가하고 이미지 대체 텍스트를 실제 화면에 맞춥니다.
- 우선순위: 높음. 짧은 문장과 대체 텍스트 수정만으로 해결할 수 있습니다.

### 2. Section 5: 비동기 로딩과 실제 화면 교체 사이의 설명 보충

- 위치: Main 156~172행, `Resources/Code/V26-Section5-01-Replacement.swift`.
- 확인한 사실: 앞부분의 단순 대입·반복문에서 `async throws`, `try await`, 로딩 후 선택 재확인, Entity 교체와 상태 갱신으로 한 번에 넘어갑니다. 코드는 현재 완성 앱과 일치하지만 왜 필요한지에 대한 설명은 짧습니다.
- 권장 보강은 세 덩어리로 충분합니다.

  1. 모델을 읽는 데 시간이 걸릴 수 있어 `await`로 결과를 기다린다. 실패는 Starter의 호출부가 처리한다.
  2. 기다리는 동안 선택이 바뀔 수 있으므로, 로딩 뒤에도 같은 객체인지 다시 확인한다.
  3. `removeFromParent()`와 `objectRoot.addChild(...)`가 실제 장면을 바꾸고, `displayedEntityByID`와 `replacedObjectIDs`는 이후 그 모델을 찾고 상태를 표시하게 한다.

- 현재 “`displayedEntityByID[identifier]`는 box를 model로 바꾼다”는 요약은 관련 코드 범위를 너무 압축합니다. dictionary에 새 참조를 저장하는 것만으로 장면이 바뀐다고 오해하지 않게 구분하는 편이 좋습니다.
- 우선순위: 높음. 아키텍처나 함수를 늘리지 않고 설명만 보충합니다.

### 3. 직접 넣은 USDZ가 box를 가득 채우지 않아도 정상임을 설명하기

- 위치: Main 167행 및 177~187행, `Support/FurnitureModelProvider.swift` 82~92행.
- 확인한 사실: 현재 지원 코드는 세 축 비율 중 최솟값을 사용해 **비율을 유지하며 box 안에 들어오도록 축소·확대**하고, 모델의 바닥을 맞춥니다. 세 축을 각각 늘려 찌그러뜨리는 방식이 아닙니다.
- 권장 보강: “다른 모델을 넣으면 가로·세로 비율에 따라 여백이 생길 수 있습니다. 원래 모양을 유지해 추정 box 안에 넣고 바닥을 맞추는 것이 정상입니다.”
- 파일명 교체 방식 A와 mapping 방식 B는 이미 구체적이며, category마다 하나의 asset이라는 범위도 명시되어 있습니다. 교체 구조 자체를 다시 만들 필요는 없습니다.
- 우선순위: 중간. 사용자 제공 모델의 결과를 오류로 오인하지 않게 합니다.

### 4. Section 2·3: 프리뷰에 안 보이는 부분과 아직 구현하지 않은 부분을 명시하기

- Section 2의 실제 샘플은 11개 객체입니다: Bed 2, Chair 3, Storage 4, Table 2. Preview는 목록의 윗부분만 잘라 보여줘 네 category가 한꺼번에 보이지 않습니다.
- 61~63행에 “목록을 아래로 스크롤해 네 category와 크기 표시를 확인하세요.”를 추가하면 체크포인트와 이미지가 연결됩니다.
- Section 3은 선택 UUID·checkmark·상태 문구만 만드는 단계입니다. 3D box와 분홍 Highlight는 다음 Section입니다. 현재 순서는 타당하며, “아직 3D 색이 바뀌지 않아도 정상”이라는 한 문장이 오해를 줄입니다.
- 우선순위: 중간. 프리뷰가 없다는 문제가 아니라, 프리뷰와 성공 기준을 읽는 방법의 문제입니다.

### 5. 시작 조건과 작은 문구 불일치 정리

- Overview와 Main 첫머리에서는 학습 대상·선행 지식을 바로 찾기 어렵습니다. ZIP의 `START_HERE.md`에 있는 Xcode 실행 경험·Swift 기초·UIKit 화면 개념을 짧게 안내하면 좋습니다. RoomPlan/RealityKit 사전 경험까지 요구할 필요는 없습니다.
- Section 5의 두 `previousFile` 예시는 Starter의 `Part 5` 안내 주석을 `Section 5`로 표현합니다. 실행 코드는 같지만, 처음 보는 학습자가 자기 파일과 다른 상태라고 오인할 수 있습니다. 교체 전 예시의 주석도 실제 배포 Starter와 맞추는 것이 좋습니다.
- Section 5 Recap은 기본 `Chair` mapping을 보여줍니다. 바로 앞에서 `MyChair`로 바꾼 학습자에게는 “읽기용 예시이며 자신이 바꾼 mapping을 덮어쓰지 않는다”를 덧붙이면 안전합니다.
- Bonus의 `.pi / 2`, `[0, 1, 0]`, `% 4`는 각각 90도·위쪽 축·네 번 후 원래 방향이라는 짧은 해설이면 충분합니다. quaternion 이론 강의를 추가할 필요는 없습니다.
- 우선순위: 낮음. 기본 진행을 막는 결함은 아닙니다.

## 구간별 학습 연결

| 구간 | 학습자가 연결하는 개념 | 현재 확인 가능한 결과 | 평가와 보강점 |
| --- | --- | --- | --- |
| Overview·시작 | 무엇을 만들고 어떤 자료로 시작하는가 | 완성 이미지, Project files, Starter 진입 | 목표는 명확함. 대상·선행 지식 안내는 보강 권장 |
| Section 1 | JSON → CapturedRoom → Explorer | Sample Room Loaded, 방 구조, 비어 있는 객체 목록 | 순서 적절. Starter가 그린 방 구조 설명 필요 |
| Section 2 | objects → category별 목록·dimensions | 11개 객체, 4개 category, 크기 표시 | 데이터와 화면 연결 명확. 목록 스크롤 안내 추가 권장 |
| Section 3 | identifier → 선택 상태 | Chair 2 Selected와 같은 row checkmark | 선택과 3D 표시를 나눈 설계가 좋음. 아직 Highlight가 없음을 명시하면 좋음 |
| Section 4 | dimensions·transform·identifier → box·Highlight | 모든 box → 선택한 box만 분홍색 | 두 단계 체크포인트와 합본 Recap이 잘 맞음 |
| Section 5 | category → asset → 교체 Entity | Replace 버튼 → 실제 모델, 파일 교체 실험 | 가장 큰 난도 상승. 로딩·장면 변경·상태 갱신을 나눠 설명 권장 |
| Bonus | 교체 Entity → 90도씩 회전 | Rotate 버튼, 4회 후 원래 방향 | 선택적 확장으로 적절. 짧은 각도·축 설명 정도면 충분 |

## Apple 튜토리얼과의 비교

[Apple의 Updating app data](https://developer.apple.com/tutorials/app-dev-training/updating-app-data)는 앞에서 배운 내용을 다시 사용하며, 수정 지점과 행동을 작은 단계로 나누고 확인 질문으로 이해를 점검합니다. [Build interactive tutorials using DocC](https://developer.apple.com/videos/play/wwdc2021/10235/)는 소개·Section·Step·코드·미리보기를 연결하는 작성 방식을 설명합니다.

우리 튜토리얼도 같은 핵심 패턴을 갖추고 있습니다: 완성 결과 → 작은 코드 변경 → 눈에 보이는 체크포인트 → 다음 개념. 제공 Preview와 Recap도 이 목적에 맞습니다. 모든 읽기 Step에 실행 Preview가 있어야 하는 것은 아닙니다.

차이는 프레임워크를 덜 사용해서가 아니라 설명의 연결 밀도입니다. 특히 Section 5처럼 한 단계에서 여러 새 개념이 등장하는 곳에 “왜 필요한가”를 짧게 붙이는 것이 효과적입니다. 선택적으로 마지막에 “Chair 2라는 이름 대신 identifier를 쓰는 이유는?”과 “입력이 바뀌어도 Explorer를 재사용할 수 있는 이유는?” 두 질문을 넣을 수 있지만, 새 퀴즈 기능을 만드는 것은 이번 필수 범위가 아닙니다.

## 이번 Challenge 수정

1. Sections 1~4를 완료한 프로젝트에서 이어 시작하도록 명시했습니다. 새 Starter로 돌아가면 구현한 목록·Highlight가 사라지는 혼동을 방지합니다.
2. 읽기 전용 코드임을 명시하고, Done → 세션 종료 → 결과 처리 허용 → `captureView(didPresent:error:)` → Explorer 흐름을 설명했습니다.
3. 두 줄짜리 연결 예시를 실제 함수 전체로 확장하고, 스캔 종료 예시도 추가했습니다. 두 코드 예시의 네 함수는 현재 앱과 배포 ZIP의 Starter 코드에 일치합니다.
4. “입력과 공통 처리 확인 → 실제 기기 실행 → 결과 확인”의 세 Section으로 정리했습니다.
5. 목록·box·같은 객체 Highlight를 필수 완료 기준으로, USDZ 교체·회전은 조건부 추가 실험으로 분리했습니다.
6. 실제 기기 캡처가 없다는 사실을 유지했습니다. 설명용 흐름도와 Main의 Simulator 캡처를 실제 스캔 증거로 표현하지 않았습니다.
7. `CHALLENGE_CAPTURE_GUIDE.md`에 향후 캡처 두 장을 넣을 파일명과 정확한 Step을 갱신했습니다.

RoomPlan이 처리된 방 결과를 전달하는 시점은 [Apple의 captureView(didPresent:error:) 문서](https://developer.apple.com/documentation/roomplan/roomcaptureviewdelegate/captureview%28didpresent%3Aerror%3A%29)와 현재 앱의 delegate 연결을 함께 확인했습니다.

## 첫 검토의 검증 결과와 한계

- 자동 검사: 기존 9개 + Challenge 3개 = **12/12 통과**.
- DocC: `--analyze --warnings-as-errors` 변환 및 Pages용 후처리 통과. 생성 결과의 Section·이미지 참조를 대조했습니다.
- Main 코드 연결: 배포 Starter에서 9개 전후 코드 변경을 순서대로 메모리상 적용했을 때, 관련 두 파일이 현재 완성 앱과 일치했습니다. 공백·주석을 제외한 비교입니다. 주석까지 동일한 것은 7/9이며, 나머지 2개는 위에서 언급한 Section 5 안내 주석 차이입니다.
- Recap: Section 4·5·Bonus 세 예시의 관련 코드가 현재 완성 앱과 일치합니다.
- Main 미디어: 실행 결과 Preview 9장 모두 직접 열어 단계별 기대 상태를 확인했습니다. Main은 6개 Section, 25개 Step, 12개 Code 패널(전후 비교 9 + Recap 3)입니다. Preview가 없는 Recap은 이미 본문에서 이유를 설명합니다.
- 새 Challenge: 3개 Section, 9개 Step, 2개 Code 패널. 로컬 Chrome에서 소개, 전체 콜백 코드, 완료 기준을 확인했고 콘솔 오류·경고는 관찰되지 않았습니다.
- **이전 판단 정정:** 기존 공개 Challenge의 “실제 방으로 실행하기” Section이 빠진다는 관찰은 이번 새 브라우저 세션에서 재현되지 않았습니다. 기존 두 Section과 흐름도가 실제로 표시되었습니다. 원인은 확정하지 않았고 화면 코드를 수정하지 않았습니다.
- 이번 차례에는 Xcode 빌드, 단계별 앱 재실행, LiDAR 실기기 스캔을 새로 수행하지 않았습니다. 문서 검사나 정적 코드 일치를 실기기 성공으로 보고하지 않습니다.

## Main 설명 개선 반영 결과

시작점: `8e95552`의 깨끗한 작업 트리. 승인받은 설명 보강을 하나의 기능 단위로 적용했습니다.

- Overview와 Main에 선행 지식·Simulator 진행 조건을 추가하고, Starter 제공 기능과 학습자 구현 범위를 구분했습니다.
- Section 1의 방 구조 설명과 Preview 대체 텍스트를 일치시켰습니다.
- Section 2에 category별 개수와 목록 스크롤 안내, Section 3에 아직 Highlight가 없어도 정상이라는 안내를 넣었습니다.
- Section 5 도입부에 `async`·`await`·`throws`·`try`와 로딩 뒤 선택 재확인의 이유를 설명했습니다. 실제 장면 변경과 dictionary·교체 상태 갱신을 구분하고, 모델의 비율 유지·바닥 정렬·여백을 설명했습니다.
- 사용자 지정 mapping을 Recap으로 덮어쓰지 않게 안내하고, Bonus에 90도·local Y축·네 번 후 원위치를 짧게 해설했습니다.
- Section 5 교체 전 예시 두 곳은 배포 Starter의 주석과 정확히 맞췄습니다. 실행 코드는 바꾸지 않았습니다.
- DocC의 Step은 지시 문단 하나와 선택적 캡션 문단 하나만 허용하므로, 별도 개념 설명은 Section 도입부에 배치했습니다. 최종 엄격 빌드에서 설명 누락 진단이 없는 것을 확인했습니다.

### 이번 반영의 검증

- `python3 -m unittest discover -s tests -v`: **16/16 통과**. 새 Main 검사 4개는 Starter부터 완성 코드까지의 연결, Recap, 기존 학습 구조·Preview, 새 설명과 실제 샘플 개수를 검사합니다.
- 교체 전 코드 예시는 이제 **주석까지 9/9 일치**합니다. 이를 순서대로 적용한 두 학습 파일은 공백·주석을 제외하면 현재 완성 앱과 일치합니다.
- **6 Sections · 25 Steps · 9개 실행 Preview · 3개 Recap · 80분**을 그대로 유지했습니다. URL, ZIP, asset, 스타일도 변경하지 않았습니다.
- DocC `--analyze --warnings-as-errors`와 Pages용 후처리 통과. 로컬 브라우저에서 Overview, Main 도입부, Section 1·5의 설명/코드/Preview 표시를 확인했고, Main 콘솔 오류·경고는 관찰되지 않았습니다.
- 앱 실행 코드를 변경하지 않아 이번에도 Xcode 빌드나 Simulator·LiDAR 실기기 재실행은 하지 않았습니다. 선택적 퀴즈와 신규 캡처는 추가하지 않았습니다.

## 배포 전 인계 상태 (이전 기록)

- Challenge 변경은 `215d1c0`에 로컬 커밋했습니다.
- 최초 검토 보고서는 `8e95552`에 별도 로컬 커밋했습니다. 후속 Main 설명·예시 주석·관련 검사와 이 반영 기록은 하나의 로컬 체크포인트로 묶습니다.
- 원격 push·Pages 배포는 하지 않았습니다. 공개 사이트에는 아직 이번 Challenge와 Main 설명 보강이 반영되지 않습니다.
- 변경 범위는 학습 설명과 문서 정합성입니다. 앱 로직·3D asset·웹 디자인을 다시 만들지 않았습니다.

경로 안내: 위 `Tutorials/`와 `Resources/Code/`는 `RoomPlanExampleApp/RoomPlanObjectExplorer.docc/` 기준입니다. 앱 소스는 `RoomPlanExampleApp/` 아래에 있습니다.

## 공개 배포 완료 — 2026-09-06

- 사용자 승인 후 위 세 로컬 커밋을 `origin/main`에 일반 push했습니다. 배포에 사용한 소스는 `ae14a8baaff40ca452d1283f560f117073fa54c0`입니다.
- Pages 커밋은 `e81f7f2e624fbf3062790fb02a37f018edbf0844`입니다. [GitHub Pages 실행 34033960099](https://github.com/woozy-A/2026TechMap_tutorial/actions/runs/34033960099)의 build·deploy가 모두 성공했습니다.
- 배포 직전 자동 검사 **16/16**, DocC `--analyze --warnings-as-errors`, Xcode 26.6의 generic iOS `docbuild`가 통과했습니다. 최초 샌드박스 빌드는 플랫폼 서비스 접근 문제로 실패했지만, 승인된 재실행에서 앱 컴파일·리소스 처리·문서 빌드가 성공했습니다. 코드 서명이나 앱 설치는 수행하지 않았습니다.
- 전체 Xcode DocC archive에 기존 Pages 후처리를 적용하고 기존 파일을 삭제하지 않는 방식으로 반영했습니다. 한국어·라이트 학습 화면·다크 소개 영역을 유지한 HTML은 **138개**입니다. JSON 134개의 차이는 키 직렬화 순서뿐이며, 실제 내용 변경은 Main·Challenge·Overview와 이들의 공통 탐색 참조가 있는 Further Exploration입니다.
- 사이트 루트와 기존 튜토리얼 주소 4개가 HTTP 200입니다. 이 HTML 5개와 공개 튜토리얼 JSON 4개의 SHA-256이 배포 파일과 일치합니다. 따라서 단순히 배포 작업이 끝난 상태를 넘어 새 내용이 공개 서버에 반영됐음을 확인했습니다.
- Main **6 Sections · 25 Steps · 9개 실행 Preview**, Challenge **3 Sections · 9 Steps**를 확인했습니다. 두 페이지의 이미지·실습 자료 URL **19개가 모두 HTTP 200**이며, `RoomPlanTutorialMaterials-v2.7.zip`은 기존 파일과 동일한 SHA-256 `2c5949016ac4571790e59111fc2b7a2c91a2a4fdd88537fbd440fe12cd701ab9`입니다.
- 새 브라우저 탭에서 공개 Overview → Main → Challenge를 이동했습니다. Overview의 선행 지식, Main의 Starter 역할·Section 5 설명, Challenge의 3개 Section과 완료 기준을 확인했고, Main·Challenge 콘솔 오류·경고는 관찰되지 않았습니다.
- 기존 [Overview 주소](https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanobjectexplorer/)를 계속 사용합니다. 기존 디자인·이미지·USDZ·실습 ZIP을 변경하지 않았습니다. Simulator나 LiDAR 실기기를 새로 실행한 검증은 아닙니다.
