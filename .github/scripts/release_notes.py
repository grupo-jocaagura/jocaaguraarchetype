"""Validate a stable package release and extract its exact changelog notes."""

import argparse
import pathlib
import re


def release_notes(pubspec: str, changelog: str, tag: str) -> str:
    versions = re.findall(r"^version:\s*([^\s#]+)", pubspec, re.MULTILINE)
    if len(versions) != 1:
        raise ValueError("Expected exactly one package version")
    version = versions[0]
    if not re.fullmatch(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", version):
        raise ValueError("Releases require a stable X.Y.Z version")
    if version == "0.0.0" or tag != f"v{version}":
        raise ValueError("Tag must match v<package version>; 0.0.0 is bootstrap only")
    headings = list(re.finditer(r"^##[^\S\n]+[^\n]+", changelog, re.MULTILINE))
    matches = [
        index for index, heading in enumerate(headings)
        if re.fullmatch(
            rf"##\s+\[{re.escape(version)}\]\s+-\s+\d{{4}}-\d{{2}}-\d{{2}}\s*",
            heading.group(),
        )
    ]
    if len(matches) != 1:
        raise ValueError("Expected exactly one dated changelog entry for this version")
    index = matches[0]
    end = headings[index + 1].start() if index + 1 < len(headings) else len(changelog)
    notes = changelog[headings[index].end():end].strip()
    if not any(line.strip() and not line.lstrip().startswith("#") for line in notes.splitlines()):
        raise ValueError("Release notes must contain material changes")
    return notes + "\n"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tag")
    parser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()
    try:
        notes = release_notes(
            pathlib.Path("pubspec.yaml").read_text(encoding="utf-8"),
            pathlib.Path("CHANGELOG.md").read_text(encoding="utf-8"),
            args.tag,
        )
    except ValueError as error:
        parser.exit(1, f"Release validation failed: {error}\n")
    args.output.write_text(notes, encoding="utf-8")
