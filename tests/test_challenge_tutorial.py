"""Keep the read-only Challenge examples aligned with the shipped Starter."""
from pathlib import Path
import re
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "RoomPlanExampleApp/RoomPlanObjectExplorer.docc"
SCAN_PATH = "RoomPlanExampleApp/RoomPlanScan/RoomCaptureViewController.swift"


def normalized(text):
    return "\n".join(line.strip() for line in text.splitlines() if line.strip())


def function_block(text, signature):
    start = text.index(signature)
    opening = text.index("{", start)
    depth = 1
    for end in range(opening + 1, len(text)):
        depth += (text[end] == "{") - (text[end] == "}")
        if depth == 0:
            return normalized(text[start:end + 1])
    raise AssertionError(f"Unclosed function: {signature}")


class ChallengeTutorialTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tutorial = (CATALOG / "Tutorials/05-ScanYourOwnRoom.tutorial").read_text()
        cls.app = (ROOT / SCAN_PATH).read_text()
        package = CATALOG / "Resources/Downloads/RoomPlanTutorialMaterials-v2.7.zip"
        with zipfile.ZipFile(package) as archive:
            cls.starter = archive.read(
                "RoomPlanTutorialMaterials-v2.7/Starter/" + SCAN_PATH
            ).decode()

    def test_read_only_examples_match_app_and_downloaded_starter(self):
        snippets = {
            "Challenge-CapturedRoomPipeline.swift": [
                "func captureView(didPresent processedResult: CapturedRoom, error: Error?)",
            ],
            "Challenge-ScanCompletion.swift": [
                "@IBAction func doneScanning(_ sender: UIBarButtonItem)",
                "private func stopSession()",
                "func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?)",
            ],
        }
        for file, signatures in snippets.items():
            snippet = (CATALOG / "Resources/Code" / file).read_text()
            self.assertIn(f'file: "{file}"', self.tutorial)
            for signature in signatures:
                with self.subTest(file=file, signature=signature):
                    actual = function_block(snippet, signature)
                    self.assertEqual(actual, function_block(self.app, signature))
                    self.assertEqual(actual, function_block(self.starter, signature))

    def test_prerequisites_and_completion_are_explicit(self):
        for phrase in (
            "Sections 1~4를 완료한 프로젝트", "새 Starter로 다시 시작하지 않습니다",
            "수정하거나 다시 붙여 넣지 않습니다", "Section 5", "Bonus",
            "LiDAR", "Simulator에서는 실제 scan을 검증할 수 없습니다",
            "목록·3D 체크포인트", "선택 체크포인트", "Challenge 완료",
            "실제 기기 캡처가 아닌", "설명용 흐름도",
        ):
            with self.subTest(phrase=phrase):
                self.assertIn(phrase, self.tutorial)

    def test_sections_and_capture_guide_stay_in_sync(self):
        titles = re.findall(r'@Section\(title: "([^"]+)"\)', self.tutorial)
        self.assertEqual(titles, [
            "같은 CapturedRoom pipeline 확인하기",
            "실제 방으로 실행하기",
            "결과를 확인하고 마무리하기",
        ])
        guide = (ROOT / "CHALLENGE_CAPTURE_GUIDE.md").read_text()
        for title in titles[1:]:
            self.assertIn(title, guide)
        for file in ("challenge-live-scan.png", "challenge-live-result.png"):
            self.assertIn(file, guide)
            # Allow the documented capture workflow without accepting broken links.
            if f'@Image(source: "{file}"' in self.tutorial:
                self.assertTrue((CATALOG / "Resources/Images" / file).is_file())


if __name__ == "__main__":
    unittest.main()
