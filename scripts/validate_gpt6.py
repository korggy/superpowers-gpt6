#!/usr/bin/env python3
"""Validate source selection or every file in an extracted/ZIP Codex package."""
import argparse
import json
from pathlib import Path
import sys
import stat
import zipfile

from codex_contract import safe_path, validate_files
from package_codex_plugin import working_files

ROOT = Path(__file__).resolve().parents[1]


def read_archive(path):
    files = {}
    with zipfile.ZipFile(path) as package:
        for entry in package.infolist():
            name = entry.filename.rstrip('/')
            safe_path(name)
            mode = stat.S_IFMT(entry.external_attr >> 16)
            if entry.is_dir():
                if mode not in (0, stat.S_IFDIR):
                    raise ValueError(f'unsupported archive file type: {name}')
                continue
            if mode not in (0, stat.S_IFREG):
                raise ValueError(f'unsupported archive file type (links are forbidden): {name}')
            if name in files:
                raise ValueError('archive contains duplicate file entries')
            files[name] = package.read(entry)
    return files


def read_extracted(root):
    root = Path(root).resolve()
    files = {}
    for path in root.rglob('*'):
        if path.is_symlink():
            raise ValueError(f'extracted package cannot contain links: {path}')
        path.resolve().relative_to(root)
        if path.is_file():
            files[path.relative_to(root).as_posix()] = path.read_bytes()
        elif not path.is_dir():
            raise ValueError(f'unsupported extracted file type: {path}')
    return files


def validate(root=ROOT, archive=None, extracted=False):
    root = Path(root)
    if archive:
        files = read_archive(archive)
    elif extracted:
        files = read_extracted(root)
    else:
        files = working_files(root)
    manifest, skills, documents = validate_files(files)
    if manifest.get('name') != 'superpowers-gpt6' or skills != 14:
        raise ValueError('expected the superpowers-gpt6 identity and 14 skills')
    if not archive and not extracted:
        marketplace = json.loads((root / '.agents/plugins/marketplace.json').read_text(encoding='utf-8-sig'))
        entries = [p for p in marketplace['plugins'] if p.get('name') == manifest['name']]
        if len(entries) != 1 or entries[0].get('source') != {'source': 'url', 'url': './'}:
            raise ValueError('marketplace must contain exactly one local fork entry')
        if manifest.get('hooks') != {}:
            raise ValueError('source manifest must suppress inherited hook discovery')
    elif 'hooks' in manifest:
        raise ValueError('portable package must omit the source-only hooks field')
    return skills, documents, len(files)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--archive', type=Path, help='Validate the actual ZIP payload')
    mode.add_argument('--extracted', type=Path, help='Validate an extracted portable package')
    args = parser.parse_args()
    try:
        skills, documents, files = validate(root=args.extracted or ROOT, archive=args.archive, extracted=bool(args.extracted))
    except (OSError, ValueError, KeyError, TypeError, zipfile.BadZipFile) as error:
        parser.exit(1, f'ERROR: {error}\n')
    print(f'Validated {skills} skills, YAML structure, resources, all {documents} packaged Markdown documents, and {files} selected files.')
