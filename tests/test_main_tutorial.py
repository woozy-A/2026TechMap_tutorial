"""Check cumulative Main examples against the shipped Starter without an iOS run."""
from collections import Counter
from pathlib import Path
import json
import re
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "RoomPlanExampleApp/RoomPlanObjectExplorer.docc"
CODE = CATALOG / "Resources/Code"
LEARNER_FILES = {
    "OnboardingViewController.swift": "RoomPlanExampleApp/App/OnboardingViewController.swift",
    "ObjectExplorerViewController.swift": "RoomPlanExampleApp/ObjectExplorer/ObjectExplorerViewController.swift",
}


def normalized(text, *, without_comments=False):
    # Only the controlled tutorial fixtures are compared; this is not a Swift parser.
    if without_comments:
        text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return "\n".join(
        line.strip() for line in text.splitlines()
        if line.strip() and not (without_comments and line.strip().startswith("//"))
    )


class MainTutorialTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tutorial = (CATALOG / "Tutorials/01-GetCapturedRoom.tutorial").read_text()
        cls.overview = (CATALOG / "RoomPlanObjectExplorer.tutorial").read_text()
        cls.changes = re.findall(
            r'@Code\(name: "([^"]+)", file: "([^"]+)", previousFile: "([^"]+)"\)',
            cls.tutorial,
        )
        package = re.search(r'projectFiles: "([^"]+)"', cls.tutorial).group(1)
        with zipfile.ZipFile(CATALOG / "Resources/Downloads" / package) as archive:
            prefix = Path(package).stem + "/Starter/"
            cls.starter = {
                name: archive.read(prefix + path).decode()
                for name, path in LEARNER_FILES.items()
            }

    def test_all_previous_blocks_match_including_comments_and_reach_final_code(self):
        self.assertEqual(len(self.changes), 9)
        working = {name: normalized(text) for name, text in self.starter.items()}
        for name, after_file, before_file in self.changes:
            with self.subTest(step=after_file):
                before = normalized((CODE / before_file).read_text())
                after = normalized((CODE / after_file).read_text())
                self.assertEqual(working[name].count(before), 1, before_file)
                working[name] = working[name].replace(before, after, 1)

        for name, path in LEARNER_FILES.items():
            with self.subTest(completed_file=name):
                self.assertEqual(
                    normalized(working[name], without_comments=True),
                    normalized((ROOT / path).read_text(), without_comments=True),
                )

    def test_recaps_match_completed_learner_code(self):
        recaps = re.findall(r'file: "(Recap-[^"]+)"', self.tutorial)
        self.assertEqual(len(recaps), 3)
        completed = normalized(
            (ROOT / LEARNER_FILES["ObjectExplorerViewController.swift"]).read_text(),
            without_comments=True,
        )
        for file in recaps:
            with self.subTest(recap=file):
                self.assertIn(
                    normalized((CODE / file).read_text(), without_comments=True),
                    completed,
                )

    def test_original_learning_structure_and_previews_are_preserved(self):
        self.assertIn("@Tutorial(time: 80,", self.tutorial)
        self.assertEqual(self.tutorial.count("@Section(title:"), 6)
        self.assertEqual(len(re.findall(r"@Step\s*\{", self.tutorial)), 25)
        previews = re.findall(
            r'@Code\([^\n]+\)\s*\{\s*@Image\(source: "([^"]+)"', self.tutorial
        )
        self.assertEqual(len(previews), 9)
        for file in previews:
            self.assertTrue((CATALOG / "Resources/Images" / file).is_file(), file)

    def test_learning_explanations_and_sample_counts_agree(self):
        for text in (self.tutorial, self.overview):
            for concept in ("Xcode", "Swift", "UIKit", "사전 경험"):
                self.assertIn(concept, text)
        for phrase in (
            "renderRoomStructure()", "가구 목록과 가구 box가 없는 것",
            "아직 가구 box와 분홍 Highlight가 없어도 정상",
            "guard selectedObjectID == identifier", "removeFromParent()",
            "objectRoot.addChild(replacement)", "dictionary에 값을 저장하는 것만으로",
            "모델 주위에 여백이 생겨도 정상", "비율을 유지", "바닥을 box의 아래쪽",
            "덮어쓰지 마세요", ".pi / 2", "axis: [0, 1, 0]", "% 4",
        ):
            with self.subTest(explanation=phrase):
                self.assertIn(phrase, self.tutorial)
        self.assertNotIn("비어 있는 3D Overview", self.tutorial)

        room = json.loads((ROOT / "RoomPlanExampleApp/Resources/Room.json").read_text())
        counts = Counter(next(iter(obj["category"])) for obj in room["objects"])
        self.assertEqual(sum(counts.values()), 11)
        for category, count in counts.items():
            self.assertIn(f"{category.title()} ({count})", self.tutorial)


if __name__ == "__main__":
    unittest.main()
