#!/usr/bin/env python3
"""Build a reproducible Codex archive from a committed ref or explicit preview.

Requires PyYAML. No installation, metadata downloads, or remote mutations.
"""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import stat
import subprocess
import tarfile
import zipfile

from codex_contract import FILES_MANIFEST, selection, validate_files

ROOT = Path(__file__).resolve().parents[1]

PAYLOAD = (".codex-plugin", "assets", "skills", "packaging", "README.md", "INSTALL.md", "LICENSE", "NOTICE.md", "CODE_OF_CONDUCT.md")
EXCLUDED = {"__pycache__", ".DS_Store", "node_modules", ".pytest_cache"}


def safe_path(name):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name or ":" in name:
        raise ValueError(f"unsafe archive path: {name}")
    return path


def read_git_archive(data):
    files = {}
    with tarfile.open(fileobj=io.BytesIO(data)) as archive:
        for entry in archive:
            safe_path(entry.name)
            if entry.issym() or entry.islnk():
                raise ValueError(f"package cannot contain links: {entry.name}")
            if entry.isfile():
                files[entry.name] = archive.extractfile(entry).read()
    return files


def working_files(root):
    root = Path(root).resolve()
    manifest_path = root / FILES_MANIFEST
    names = selection(manifest_path.read_bytes())
    files = {}
    for name in names:
        path = root / name
        if not path.is_file():
            raise ValueError(f"missing selected package file: {name}")
        if any(parent.is_symlink() for parent in (path, *path.parents) if parent != root and parent.is_relative_to(root)):
            raise ValueError(f"package cannot contain links: {name}")
        path.resolve().relative_to(root)
        files[name] = path.read_bytes()
    return files


def git(root, *args):
    result = subprocess.run(["git", "-c", "core.autocrlf=false", "-c", "core.eol=lf", "-C", str(root), *args], check=True, capture_output=True)
    return result.stdout


def validate_payload(files):
    manifest, _, _ = validate_files(files)
    # Source installs suppress inherited Claude hooks. The portable payload has
    # no hooks; omit this source-only field for the portal ingestion contract.
    if manifest.get("hooks") not in (None, {}):
        raise ValueError("unexpected hooks: portable package does not ship hooks")
    manifest.pop("hooks", None)
    files[".codex-plugin/plugin.json"] = (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
    return manifest


def file_mode(data):
    return 0o755 if data.startswith(b"#!") else 0o644


def build(root, output, *, ref="HEAD", working_tree=False, allow_dirty=False, overwrite=False, archive_format=None):
    root, output = Path(root).resolve(), Path(output).resolve()
    if output.is_relative_to(root):
        raise ValueError("package output must be outside the source checkout")
    if output.exists() and not overwrite:
        raise FileExistsError(f"output exists; use --overwrite explicitly: {output}")
    inferred = "tar.gz" if output.name.endswith((".tar.gz", ".tgz")) else "zip" if output.suffix == ".zip" else None
    archive_format = archive_format or inferred
    if archive_format not in ("zip", "tar.gz") or (inferred and inferred != archive_format):
        raise ValueError("archive format must be zip or tar.gz and match its extension")
    if working_tree:
        if ref != "HEAD" or allow_dirty:
            raise ValueError("--working-tree cannot be combined with --ref or --allow-dirty")
        files = working_files(root)
    else:
        if not allow_dirty and git(root, "status", "--porcelain", "--untracked-files=all").strip():
            raise ValueError("dirty checkout; choose --working-tree or --allow-dirty with a committed ref")
        revision = git(root, "rev-parse", "--verify", "--end-of-options", ref + "^{commit}").decode().strip()
        tracked = git(root, "ls-tree", "--name-only", "-z", revision).decode().split("\0")
        paths = [name for name in PAYLOAD if name in tracked]
        if not paths:
            raise ValueError("committed ref contains no package files")
        available = read_git_archive(git(root, "archive", "--format=tar", revision, "--", *paths))
        if FILES_MANIFEST not in available:
            raise ValueError("committed ref has no explicit package file manifest")
        names = selection(available[FILES_MANIFEST])
        missing = set(names) - set(available)
        if missing:
            raise ValueError(f"missing selected package files: {sorted(missing)}")
        files = {name: available[name] for name in names}
    files = {name: data for name, data in files.items() if not any(part in EXCLUDED for part in PurePosixPath(name).parts)}
    manifest = validate_payload(files)
    stream = io.BytesIO()
    if archive_format == "zip":
        with zipfile.ZipFile(stream, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, data in sorted(files.items()):
                info = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.external_attr = (stat.S_IFREG | file_mode(data)) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(info, data)
    else:
        with gzip.GzipFile(fileobj=stream, mode="wb", mtime=0, filename="") as compressed:
            with tarfile.open(fileobj=compressed, mode="w", format=tarfile.PAX_FORMAT) as archive:
                for name, data in sorted(files.items()):
                    info = tarfile.TarInfo(name)
                    info.size, info.mode = len(data), file_mode(data)
                    archive.addfile(info, io.BytesIO(data))
    payload = stream.getvalue()
    output.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive creation protects an existing file even if it appears while the
    # archive is being built. Explicit overwrite is the only replacing path.
    with output.open("wb" if overwrite else "xb") as destination:
        destination.write(payload)
    return {"path": str(output), "name": manifest["name"], "version": manifest["version"],
            "files": len(files), "sha256": hashlib.sha256(payload).hexdigest(),
            "source": "working-tree preview" if working_tree else ref}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--format", choices=("zip", "tar.gz"), dest="archive_format")
    source = parser.add_mutually_exclusive_group()
    source.add_argument("--ref", default=None)
    source.add_argument("--working-tree", action="store_true")
    parser.add_argument("--allow-dirty", action="store_true")
    parser.add_argument("--overwrite", action="store_true")
    args = parser.parse_args()
    try:
        result = build(ROOT, args.output, ref=args.ref or "HEAD", working_tree=args.working_tree,
                       allow_dirty=args.allow_dirty, overwrite=args.overwrite, archive_format=args.archive_format)
    except (ValueError, OSError, subprocess.CalledProcessError, tarfile.TarError) as error:
        parser.exit(1, f"ERROR: {error}\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
