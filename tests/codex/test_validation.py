"""Validate archive file types without extracting untrusted entries."""
from pathlib import Path
import stat
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
import validate_gpt6 as validation


class ArchiveValidationTests(unittest.TestCase):
    def test_zip_symlink_and_special_file_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            for mode in (stat.S_IFLNK, stat.S_IFIFO):
                with self.subTest(mode=mode):
                    path = Path(temp) / 'bad.zip'
                    with zipfile.ZipFile(path, 'w') as package:
                        entry = zipfile.ZipInfo('assets/logo.svg')
                        entry.create_system = 3
                        entry.external_attr = (mode | 0o644) << 16
                        package.writestr(entry, '../../external.svg')
                    with self.assertRaisesRegex(ValueError, 'file type'):
                        validation.read_archive(path)

    def test_regular_archive_entry_is_read(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'valid.zip'
            with zipfile.ZipFile(path, 'w') as package:
                package.writestr('assets/logo.svg', '<svg/>')
            self.assertEqual({'assets/logo.svg': b'<svg/>'}, validation.read_archive(path))

    def test_extracted_links_fail_before_reading_target(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            file = root / 'asset.svg'
            file.write_text('<svg/>', encoding='utf-8')
            # Symlink creation on Windows can require privileges. Simulate the
            # file-type result, and ensure the reader refuses before read_bytes.
            with patch.object(type(file), 'is_symlink', lambda path: path.name == 'asset.svg'):
                with patch.object(Path, 'read_bytes', side_effect=AssertionError('must not follow link')):
                    with self.assertRaisesRegex(ValueError, 'cannot contain links'):
                        validation.read_extracted(root)


if __name__ == '__main__':
    unittest.main()
