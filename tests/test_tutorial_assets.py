"""Offline contracts for published learning materials; no Blender required."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("materials", ROOT / "scripts/package_tutorial_materials.py")
materials = importlib.util.module_from_spec(spec)
spec.loader.exec_module(materials)
ARCHIVE = materials.CATALOG / "Resources/Downloads" / f"{materials.PACKAGE}.zip"
PREFIX = materials.PACKAGE + "/"


class TutorialMaterialsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with zipfile.ZipFile(ARCHIVE) as archive:
            cls.entries = {name.removeprefix(PREFIX): archive.read(name) for name in archive.namelist()}

    def test_native_download_matches_archive(self):
        tutorial = (materials.CATALOG / "Tutorials/01-GetCapturedRoom.tutorial").read_text()
        self.assertIn(f'projectFiles: "{ARCHIVE.name}"', tutorial)
        self.assertNotIn("RoomPlanFurnitureAsset-Chair-v1.zip", tutorial)

    def test_asset_matches_app_and_provenance(self):
        chair = (materials.CHAIR / "Chair.usdz").read_bytes()
        self.assertEqual(self.entries["Assets/Chair.usdz"], chair)
        self.assertIn(hashlib.sha256(chair).hexdigest(), self.entries["Assets/SOURCE.md"].decode())
        self.assertLess(len(chair), 1024 * 1024)

    def test_manifest_covers_every_payload(self):
        manifest = dict(line.split("  ", 1)[::-1] for line in self.entries["SHA256SUMS.txt"].decode().splitlines())
        self.assertEqual(set(manifest), set(self.entries) - {"SHA256SUMS.txt"})
        for name, digest in manifest.items():
            self.assertEqual(digest, hashlib.sha256(self.entries[name]).hexdigest(), name)

    def test_no_private_or_temporary_payload(self):
        forbidden = {".git", "__MACOSX", "xcuserdata", "DerivedData", ".DS_Store", "__pycache__", ".env"}
        for name in self.entries:
            self.assertFalse(Path(name).is_absolute())
            self.assertNotIn("..", Path(name).parts)
            self.assertFalse(forbidden.intersection(Path(name).parts), name)
            self.assertFalse(name.endswith((".pem", ".p12", ".mobileprovision", ".pyc")), name)

    def test_starter_does_not_preinstall_chair(self):
        self.assertTrue(any(name.endswith(".xcodeproj/project.pbxproj") for name in self.entries))
        self.assertFalse(any(name.startswith("Starter/") and name.endswith(".usdz") for name in self.entries))

    def test_archive_is_reproducible(self):
        with tempfile.TemporaryDirectory(prefix="roomplan-materials-test-") as tmp:
            output = Path(tmp) / "materials.zip"
            materials.write_archive(output, self.entries)
            self.assertEqual(output.read_bytes(), ARCHIVE.read_bytes())

    def test_modified_starter_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix="roomplan-materials-test-") as tmp:
            invalid = Path(tmp) / "starter.zip"
            invalid.write_bytes(b"not the verified starter")
            with self.assertRaisesRegex(ValueError, "unchanged v2.6"):
                materials.make_entries(invalid)

    def test_challenge_has_honest_preview(self):
        challenge = (materials.CATALOG / "Tutorials/05-ScanYourOwnRoom.tutorial").read_text()
        self.assertIn("challenge-scan-flow.svg", challenge)
        self.assertIn("실제 기기 캡처가 아닌", challenge)
        self.assertTrue((materials.CATALOG / "Resources/Images/challenge-scan-flow.svg").is_file())


if __name__ == "__main__":
    unittest.main()
