"""Portable packaging tests. Mutations stay in temporary fixtures."""
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
SPEC = importlib.util.spec_from_file_location("package_codex", ROOT / "scripts/package_codex_plugin.py")
package = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(package)


class PackageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "source with spaces"
        self.root.mkdir()
        self.write(".codex-plugin/plugin.json", json.dumps({
            "name": "example", "version": "1.0.0", "skills": "./skills/", "hooks": {},
            "interface": {"logo": "./assets/logo.svg"}}))
        self.write("skills/example/SKILL.md", "---\nname: example\ndescription: Example fixture\n---\n# Example\n")
        self.write("skills/example/agents/openai.yaml", 'interface:\n  display_name: "Example"\n  short_description: "A useful example for package validation"\n  default_prompt: "Use $example to validate the fixture."\n')
        self.write("skills/example/scripts/helper", "#!/usr/bin/env bash\nprintf 'ok\\n'\n")
        self.write("assets/logo.svg", "<svg/>")
        self.write("README.md", "Fixture documentation\n")
        self.write("LICENSE", "Fixture license\n")
        self.write("NOTICE.md", "Fixture attribution\n")
        self.write("hooks/hooks.json", "{}")
        self.write("tests/private.txt", "not shipped")
        self.selected = [".codex-plugin/plugin.json", "skills/example/SKILL.md", "skills/example/agents/openai.yaml",
                         "skills/example/scripts/helper", "assets/logo.svg", "README.md", "LICENSE", "NOTICE.md",
                         "packaging/codex-files.json"]
        self.select()

    def select(self, resources=None):
        self.write("packaging/codex-files.json", json.dumps({"schema_version": 1, "files": self.selected,
                                                          "resource_references": resources or {}}))

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")

    def git(self, *args):
        return subprocess.run(["git", "-C", str(self.root), *args], check=True,
                              capture_output=True, text=True).stdout.strip()

    def test_self_contained_archive_excludes_source(self):
        output = Path(self.temp.name) / "plugin.zip"
        package.build(self.root, output, working_tree=True)
        with zipfile.ZipFile(output) as archive:
            self.assertIn("skills/example/agents/openai.yaml", archive.namelist())
            self.assertIn("NOTICE.md", archive.namelist())
            self.assertNotIn("hooks/hooks.json", archive.namelist())
            self.assertNotIn("tests/private.txt", archive.namelist())
            self.assertNotIn("hooks", json.loads(archive.read(".codex-plugin/plugin.json")))
            self.assertEqual(b"Fixture documentation\n", archive.read("README.md"))
            helper = archive.getinfo("skills/example/scripts/helper")
            self.assertEqual(0o755, (helper.external_attr >> 16) & 0o777)

    def test_zip_reproducibility(self):
        first, second = (Path(self.temp.name) / name for name in ("a.zip", "b.zip"))
        package.build(self.root, first, working_tree=True)
        os.utime(self.root / "README.md", (100000, 100000))
        package.build(self.root, second, working_tree=True)
        self.assertEqual(first.read_bytes(), second.read_bytes())

    def test_tar_reproducibility(self):
        first, second = (Path(self.temp.name) / name for name in ("a.tar.gz", "b.tar.gz"))
        package.build(self.root, first, working_tree=True)
        package.build(self.root, second, working_tree=True)
        self.assertEqual(first.read_bytes(), second.read_bytes())
        with tarfile.open(first) as archive:
            self.assertIn(".codex-plugin/plugin.json", archive.getnames())
            self.assertEqual(0o755, archive.getmember("skills/example/scripts/helper").mode)

    def test_missing_metadata_leaves_no_partial_archive(self):
        (self.root / "skills/example/agents/openai.yaml").unlink()
        output = Path(self.temp.name) / "missing.zip"
        with self.assertRaisesRegex(ValueError, "openai.yaml"):
            package.build(self.root, output, working_tree=True)
        self.assertFalse(output.exists())

    def test_missing_asset(self):
        (self.root / "assets/logo.svg").unlink()
        with self.assertRaisesRegex(ValueError, "asset"):
            package.build(self.root, Path(self.temp.name) / "missing.zip", working_tree=True)

    def test_unselected_instructions_never_ship(self):
        self.write("skills/example/legacy.md", "Obsolete instructions")
        output = Path(self.temp.name) / "selected.zip"
        package.build(self.root, output, working_tree=True)
        with zipfile.ZipFile(output) as archive:
            self.assertNotIn("skills/example/legacy.md", archive.namelist())

    def test_malformed_or_misnested_yaml_rejected(self):
        for content in ('not a mapping', 'interface: [broken',
                        'other:\n  display_name: Example\n',
                        'interface: {}\ninterface: {}\n'):
            with self.subTest(content=content):
                self.write("skills/example/agents/openai.yaml", content)
                with self.assertRaises(ValueError):
                    package.build(self.root, Path(self.temp.name) / "bad.zip", working_tree=True)

    def test_invalid_skill_frontmatter_rejected(self):
        self.write("skills/example/SKILL.md", "---\nname: example\ndescription: [unfinished\n---\nBody\n")
        with self.assertRaisesRegex(ValueError, "YAML"):
            package.build(self.root, Path(self.temp.name) / "bad.zip", working_tree=True)

    def test_unlinked_selected_markdown_is_validated(self):
        self.selected.append("skills/example/reference.md")
        self.write("skills/example/reference.md", "See [missing resource](missing.md).\n")
        self.select()
        with self.assertRaisesRegex(ValueError, "missing packaged reference"):
            package.build(self.root, Path(self.temp.name) / "bad.zip", working_tree=True)

    def test_missing_declared_script_resource_rejected(self):
        self.select({"skills/example/scripts/helper": ["skills/example/scripts/absent.js"]})
        with self.assertRaisesRegex(ValueError, "resource is not selected"):
            package.build(self.root, Path(self.temp.name) / "bad.zip", working_tree=True)

    def test_parent_reference_cannot_escape_package(self):
        self.write("README.md", "[outside](../outside.md)\n")
        with self.assertRaisesRegex(ValueError, "unsafe package path"):
            package.build(self.root, Path(self.temp.name) / "bad.zip", working_tree=True)

    def test_valid_yaml_scalar_styles_and_invocation_policy(self):
        self.write("skills/example/agents/openai.yaml", "interface:\n  display_name: 'Example'\n  short_description: A useful example for package validation\n  default_prompt: >-\n    Use $example to validate the fixture.\npolicy:\n  allow_implicit_invocation: false\n")
        package.build(self.root, Path(self.temp.name) / "valid.zip", working_tree=True)

    def test_unsupported_format(self):
        with self.assertRaisesRegex(ValueError, "format"):
            package.build(self.root, Path(self.temp.name) / "out.exe", working_tree=True)

    def test_output_cannot_overwrite_source(self):
        with self.assertRaisesRegex(ValueError, "outside"):
            package.build(self.root, self.root / "assets/out.zip", working_tree=True)

    def test_existing_output_preserved(self):
        output = Path(self.temp.name) / "existing.zip"
        output.write_bytes(b"preserve me")
        with self.assertRaises(FileExistsError):
            package.build(self.root, output, working_tree=True)
        self.assertEqual(b"preserve me", output.read_bytes())

    def test_ref_excludes_dirty_and_untracked_changes(self):
        self.git("init", "-q")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "-c", "commit.gpgsign=false", "commit", "-qm", "fixture")
        self.write("README.md", "dirty working copy\n")
        self.write("skills/example/private.txt", "untracked")
        output = Path(self.temp.name) / "ref.zip"
        with self.assertRaisesRegex(ValueError, "dirty"):
            package.build(self.root, output)
        package.build(self.root, output, allow_dirty=True)
        with zipfile.ZipFile(output) as archive:
            self.assertEqual(b"Fixture documentation\n", archive.read("README.md"))
            self.assertNotIn("skills/example/private.txt", archive.namelist())

    def test_archive_parent_path_rejected(self):
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode="w") as archive:
            info = tarfile.TarInfo("../outside.txt")
            info.size = 1
            archive.addfile(info, io.BytesIO(b"x"))
        with self.assertRaisesRegex(ValueError, "path"):
            package.read_git_archive(stream.getvalue())

    def test_archive_symlink_rejected(self):
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode="w") as archive:
            info = tarfile.TarInfo("skills/example/link")
            info.type = tarfile.SYMTYPE
            info.linkname = "../../outside"
            archive.addfile(info)
        with self.assertRaisesRegex(ValueError, "link"):
            package.read_git_archive(stream.getvalue())


if __name__ == "__main__":
    unittest.main()
