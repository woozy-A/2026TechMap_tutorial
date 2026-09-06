#!/usr/bin/env python3
"""Build the DocC-native materials download without mutating old releases."""
import argparse
import hashlib
from pathlib import Path, PurePosixPath
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CHAIR = ROOT / "RoomPlanExampleApp/Resources/Furniture"
CATALOG = ROOT / "RoomPlanExampleApp/RoomPlanObjectExplorer.docc"
STARTER_SHA256 = "d3852f00f6a48b15d09e7a1ca5f495b1d2748e3a858c04e84fdae11e26c5f7f6"
PACKAGE = "RoomPlanTutorialMaterials-v2.7"


def make_entries(starter_path):
    data = starter_path.read_bytes()
    if hashlib.sha256(data).hexdigest() != STARTER_SHA256:
        raise ValueError("Starter must be the verified, unchanged v2.6 release ZIP")
    entries = {}
    with zipfile.ZipFile(starter_path) as source:
        for item in source.infolist():
            if item.is_dir():
                continue
            parts = PurePosixPath(item.filename).parts
            if parts[0] != "RoomPlanTutorialStarter-v2.6" or ".." in parts:
                raise ValueError("Unexpected path in Starter ZIP")
            if any(p in {".git", "__MACOSX", "xcuserdata", "DerivedData", ".DS_Store"} for p in parts):
                continue
            relative = PurePosixPath(*parts[1:])
            entries[f"Starter/{relative}"] = source.read(item.filename)
    # The released app code stays unchanged. Only its learning guide is refreshed.
    entries["Starter/START_HERE.md"] = (ROOT / "START_HERE.md").read_bytes()
    for original, packaged in [("Chair.usdz", "Chair.usdz"),
                               ("Chair-LICENSE.md", "LICENSE.md"),
                               ("Chair-SOURCE.md", "SOURCE.md"),
                               ("Chair-README.md", "README.md")]:
        entries[f"Assets/{packaged}"] = (CHAIR / original).read_bytes()
    entries["START_HERE.md"] = (
        "# RoomPlan Tutorial Materials v2.7\n\n"
        "1. Starter/RoomPlanExampleApp.xcodeproj를 엽니다. 앱 코드는 검증된 Starter v2.6입니다.\n"
        "2. Main Section 1~4를 진행합니다. Starter에는 의자가 아직 들어 있지 않습니다.\n"
        "3. Section 5에서 Assets/Chair.usdz를 Xcode Resources에 넣고 앱 target을 체크합니다.\n"
        "4. 다른 의자는 Assets/README.md의 같은 파일명 교체 방법을 사용하세요.\n\n"
        "Assets는 Original Office Chair v2입니다. 기존 v1 ZIP은 변경하지 않았습니다.\n"
        "실제 방 스캔은 LiDAR 기기에서만 가능하고, Main은 Simulator로 진행합니다.\n"
    ).encode()
    entries["SHA256SUMS.txt"] = "".join(
        f"{hashlib.sha256(value).hexdigest()}  {key}\n" for key, value in sorted(entries.items())
    ).encode()
    return entries


def write_archive(path, entries):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(entries.items()):
            info = zipfile.ZipInfo(f"{PACKAGE}/{name}", date_time=(2026, 9, 6, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, data)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--starter-zip", type=Path, required=True)
    args = parser.parse_args()
    output = CATALOG / "Resources/Downloads" / f"{PACKAGE}.zip"
    write_archive(output, make_entries(args.starter_zip))
    print(output)
    print(f"SHA256 {hashlib.sha256(output.read_bytes()).hexdigest()}")
