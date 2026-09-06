# Chair v2 / Tutorial Materials v2.7 — published checkpoint

검증일: 2026-09-06. **main push / GitHub Pages 배포 / 공개 사이트 검증 완료.**
기존 공개 URL과 v2.6 / Chair v1 release ZIP은 변경하지 않았다.
이번 배포에서는 추가 3D 모델 수정 없이 검증된 Chair v2를 그대로 반영했다.

## 바뀐 것

- 의자: 곡면 쿠션, 일체형 등받이, 얇은 팔걸이, 납작한 금속 다리.
  26,560 triangles / 901,493 bytes. 텍스처·외부 모델·브랜드 로고 없음, CC0.
- 소개 렌더: 실제 배포할 USDZ를 Blender에 다시 불러와 같은 형태·재질로 렌더.
- 앱: `Resources/Furniture/Chair.usdz`만 교체. Swift 기능·선택·fitting·회전 코드는 변경하지 않음.
- Section 5 / Bonus / 목표 화면의 4개 프리뷰를 새 모델의 실제 Simulator 캡처로 교체.
- Main의 DocC 기본 **Project files** 다운로드에 Starter 코드와 새 의자를 함께 제공.
- Challenge에 설명용 흐름도와 실제 캡처 추가 가이드 제공. 실제 LiDAR 검증으로 표시하지 않음.

## 받거나 교체할 파일

- 배포 원본: `RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Downloads/RoomPlanTutorialMaterials-v2.7.zip`
- 편의용 로컬 복사: 워크스페이스 `Current/RoomPlanTutorialMaterials-v2.7.zip`
- ZIP 안 `Starter/RoomPlanExampleApp.xcodeproj`: 기존 v2.6 Starter 앱 코드, 아직 의자 미포함.
- ZIP 안 `Assets/Chair.usdz`: Section 5에서 Xcode Resources에 넣고 target을 체크.
- ZIP 안 `Assets/README.md`: 다른 USDZ를 `Chair.usdz`로 이름 바꿔 교체하는 법.
- 실제 스캔 캡처 추가: `CHALLENGE_CAPTURE_GUIDE.md`의 파일명·삽입 위치 참고.

## 검증 결과와 경계

- Xcode 26.6 / iPhone 17 Pro iOS 26.5 Simulator build 성공.
- 확보한 기존 기기: `DF3E7CD8-3C46-47F8-92D5-4C7A78A96CEB`, 새 기기 생성 없음.
- Chair 1 선택 → 교체 → 90° → 180° → 270° → 원래 방향 복귀.
  같은 UUID의 row checkmark와 위치 유지 확인. 실기기·LiDAR·서명/Archive 검증은 아님.
- USD validation / RealityKit 직접 load 성공. Y-up, meter, bounds 0.667 × 1.162 × 0.635 m.
  모델 바닥 y는 부동소수 오차 범위 내 0(-0.000000019 m).
- DocC `--analyze --warnings-as-errors` 성공. 기본 다운로드 로컬 HTTP 수신 해시 일치.
- 자동 검사 9개 통과: ZIP 내용·manifest·재현성·Starter 무변경 입력·캐시 제외·문서 안내·배포 스크립트.
- 공개 사이트의 기존 튜토리얼 경로 4곳이 HTTP 200으로 응답했다.
- 공용 CDN의 문서 JSON 3개, Materials ZIP, 의자 렌더·프리뷰 5개, Challenge 흐름도까지
  총 10개 파일의 SHA-256이 검증된 로컬 배포본과 일치했다.
- Chrome에서 소개 화면 → Get started → Main 연결과 Project files v2.7 링크를 확인했다.
  어두운 소개 영역·구분선·80분 표시는 유지됐다.

## 배포 기록

- 콘텐츠 기준 main 커밋: `dc2c8bc66c4d08f9f598998189e136262f850eb1`
- Pages 커밋: `46a94b92ed7b3a39c8054e0e0460d6c8a49d22e5`
- [GitHub Pages 실행 34031841853 — 성공](https://github.com/woozy-A/2026TechMap_tutorial/actions/runs/34031841853)
- [기존 튜토리얼 주소](https://woozy-a.github.io/2026TechMap_tutorial/tutorials/roomplanobjectexplorer/)
- [Materials v2.7 다운로드](https://woozy-a.github.io/2026TechMap_tutorial/downloads/com.example.apple-samplecode.RoomPlanObjectExplorer/RoomPlanTutorialMaterials-v2.7.zip)
- 배포 직전 자동 검사 9/9, Xcode docbuild, DocC analyze warnings-as-errors 통과.
- 기존 gh-pages에 덮어쓰되 기존 경로 삭제나 force push 없이 배포했다.

## 재생성

기존 Blender 파일은 수정하지 않았다. 새 편집 원본·4방향 렌더·캡처는
워크스페이스 `Current/Chair-v2-Design/`에 보관한다.
Blender를 Codex sandbox 자식으로 직접 실행하지 말고 워크스페이스의 안전 실행기를 사용한다.

```sh
Tools/launch_blender_safe.sh --background --factory-startup \
  --python "$PWD/.docc-worktree/scripts/generate_chair_asset.py" \
  -- --output-dir "$PWD/Current/Chair-v2-Design"
```

`.docc-worktree`에서:

```sh
python3 scripts/package_tutorial_materials.py --starter-zip ../Current/RoomPlanTutorialStarter-v2.6.zip
swift scripts/compose_chair_previews.swift ../Current/Chair-v2-Design/RuntimeEvidence \
  RoomPlanExampleApp/RoomPlanObjectExplorer.docc/Resources/Images
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v
```

새 의자를 다시 생성했다면 앱 USDZ·소개 PNG·출처 해시를 먼저 갱신하고 위 ZIP을 다시 만든다.
프리뷰는 새 앱을 실제로 실행해 다시 캡처한다. 옛 캡처를 새 모델의 결과처럼 재사용하지 않는다.
DocC archive 생성 후 `scripts/prepare_pages_archive.sh`를 실행한다.
검증된 archive의 **downloads 폴더까지** 배포해야 Project files가 작동한다.
배포 절차와 옛 URL 유지 규칙은 `DOC_C_DEPLOYMENT.md`를 따른다.

## 고정 파일 해시 (SHA-256)

```text
Chair.usdz  6f694f1a20bf61c564bf61dc2968b102ddbf9ce605fdd3aeb6ee8c8c97944928
Materials  2c5949016ac4571790e59111fc2b7a2c91a2a4fdd88537fbd440fe12cd701ab9
chair-before.png  6b57b59dbce6caf66ec1660188b2d6f39076a81a2b053187c4176d1cc969d476
chair-replaced.png  2013e7bd2b5195a5a8f5f1ae46a0ee0cc44358abbcfae92d51ab96ec4015c53f
chair-rotated-90.png  cd55675aea6e6df934441fe243883461a0457ee3c81dec92548b5a2baeb1c777
chair-rotated-360.png  0fd1ff87b1a13a489e72d6135695d9f62aad98e9335fe18293c88743ad44ffbb
```
