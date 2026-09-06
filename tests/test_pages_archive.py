"""Regression coverage for DocC's nondeterministic JSON key ordering."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/prepare_pages_archive.sh"


class PagesArchiveTests(unittest.TestCase):
    def test_zero_minutes_in_any_key_position_and_idempotent_styles(self):
        records = [
            {"estimatedTime": "0min", "title": "first"},
            {"title": "middle", "estimatedTime": "0min", "kind": "article"},
            {"title": "last", "estimatedTime": "0min"},
            {"estimatedTime": "0min"},
            {"estimatedTime": "1hr 20min", "title": "main"},
        ]
        expected = [{k: v for k, v in item.items() if not (k == "estimatedTime" and v == "0min")}
                    for item in records]
        for indent in (None, 2):
            with self.subTest(indent=indent), tempfile.TemporaryDirectory(prefix="roomplan-pages-test-") as tmp:
                root = Path(tmp)
                (root / "data").mkdir()
                data = root / "data/example.json"
                data.write_text(json.dumps(records, indent=indent, separators=(",", ":") if indent is None else None))
                index = root / "index.html"
                index.write_text('<html lang="en-US"><head><script>var baseUrl = "/"</script></head>'
                                 '<body data-color-scheme="auto"></body></html>')
                for _ in range(2):
                    subprocess.run([str(SCRIPT), str(root)], check=True, capture_output=True, text=True)
                    self.assertEqual(json.loads(data.read_text()), expected)
                    self.assertEqual(index.read_text().count('id="roomplan-tutorial-hero-brand"'), 1)
                    self.assertTrue((root / ".nojekyll").is_file())


if __name__ == "__main__":
    unittest.main()
