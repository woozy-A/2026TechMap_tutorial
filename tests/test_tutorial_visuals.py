"""Prevent text-only learning steps and keep explanatory media honest and editable."""
from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "RoomPlanExampleApp/RoomPlanObjectExplorer.docc"
IMAGES = CATALOG / "Resources/Images"
SVG = "{http://www.w3.org/2000/svg}"
PAGES = {"01-GetCapturedRoom.tutorial": 25, "05-ScanYourOwnRoom.tutorial": 9}


class TutorialVisualTests(unittest.TestCase):
    def test_each_step_has_one_explanatory_image_or_result_capture(self):
        for page, count in PAGES.items():
            source = (CATALOG / "Tutorials" / page).read_text()
            # Controlled DocC indentation distinguishes Step closures from nested Code.
            steps = re.findall(r"^            @Step \{\n(.*?)^            \}", source, re.M | re.S)
            self.assertEqual(len(steps), count, page)
            for index, step in enumerate(steps, 1):
                with self.subTest(page=page, step=index):
                    matches = re.findall(r'@Image\(source: "([^"]+)", alt: "([^"]+)"\)', step)
                    self.assertEqual(len(matches), 1, "Every Step needs its own relevant media.")
                    file, alt = matches[0]
                    self.assertTrue((IMAGES / file).is_file(), file)
                    self.assertGreater(len(alt), 30)

    def test_guides_have_accessible_titles_and_no_external_dependencies(self):
        guides = sorted(IMAGES.glob("guide-*.svg"))
        self.assertEqual(len(guides), 14)
        pages = "\n".join((CATALOG / "Tutorials" / p).read_text() for p in PAGES)
        handoff = (ROOT / "TUTORIAL_VISUAL_GUIDE.md").read_text()
        for file in guides:
            with self.subTest(image=file.name):
                root = ET.fromstring(file.read_text())
                self.assertEqual(root.attrib["viewBox"], "0 0 1000 680")
                self.assertEqual(root.attrib["aria-labelledby"], "title desc")
                self.assertTrue(root.find(SVG + "title").text)
                self.assertIn("캡처", root.find(SVG + "desc").text)
                self.assertIn("설명용 도식 · 실제 캡처 아님", file.read_text())
                self.assertIn(file.name, pages)
                self.assertIn(file.name, handoff)
                for element in root.iter():
                    self.assertNotIn(element.tag, (SVG + "script", SVG + "image", SVG + "foreignObject"))
                    self.assertFalse(any(k.startswith("on") for k in element.attrib))
                    for key, value in element.attrib.items():
                        if key.endswith("href"):
                            self.assertTrue(value.startswith("#"), value)
        # DocC deduplicates a reused image's alt text within a tutorial page.
        for page in PAGES:
            alts_by_file = {}
            for file, alt in re.findall(r'@Image\(source: "(guide-[^"]+)", alt: "([^"]+)"\)', (CATALOG / "Tutorials" / page).read_text()):
                alts_by_file.setdefault(file, set()).add(alt)
            self.assertTrue(all(len(alts) == 1 for alts in alts_by_file.values()), page)

    def test_section_five_drawings_explain_the_existing_extension_points(self):
        mapping = (IMAGES / "guide-asset-mapping.svg").read_text()
        for label in (".chair", "MyChair", "MyChair.usdz", ".bed", "Bed.usdz", ".table", "Table.usdz"):
            self.assertIn(label, mapping)
        provider = (ROOT / "RoomPlanExampleApp/Support/FurnitureModelProvider.swift").read_text()
        self.assertIn("let uniformScale = min(", provider)
        fitting = (IMAGES / "guide-model-fitting.svg").read_text()
        for label in ("같은 배율", "box 아래쪽에 바닥 정렬", "남는 공간은 정상"):
            self.assertIn(label, fitting)
        pipeline = (IMAGES / "guide-replacement-pipeline.svg").read_text()
        for token in ("selectedObjectID", "identifier", "removeFromParent()", "objectRoot.addChild"):
            self.assertIn(token, pipeline)
        rotation = (IMAGES / "guide-rotation-cycle.svg").read_text()
        # SVG screen coordinates run downward; positive local Y viewed from above
        # is counterclockwise, represented by negative SVG rotation angles.
        for angle in (90, 180, 270):
            self.assertIn(f"rotate(-{angle})", rotation)

    def test_challenge_comparison_captures_are_not_presented_as_live_results(self):
        source = (CATALOG / "Tutorials/05-ScanYourOwnRoom.tutorial").read_text()
        captures = re.findall(r'@Image\(source: "(v6-[^"]+)", alt: "([^"]+)"\)', source)
        self.assertEqual(len(captures), 2)
        for _, alt in captures:
            self.assertIn("비교용 Sample Room", alt)
            self.assertIn("Simulator 캡처", alt)
        self.assertNotIn("이 단계에 별도 결과 Preview는 없습니다", source)
        guide = (ROOT / "CHALLENGE_CAPTURE_GUIDE.md").read_text()
        self.assertIn("기존 `@Image` 한 줄을 교체", guide)


if __name__ == "__main__":
    unittest.main()
