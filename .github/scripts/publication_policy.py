"""Read-only release eligibility and provenance checks. Never creates a tag or uploads."""

import argparse
import json
import os
from pathlib import Path
import re
from urllib.error import HTTPError
from urllib.request import Request, urlopen

import yaml

from release_notes import release_notes

REPOSITORY = "grupo-jocaagura/jocaaguraarchetype"
PACKAGE = "jocaaguraarchetype"
REPOSITORY_URL = f"https://github.com/{REPOSITORY}"
STABLE = re.compile(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")


def semver(value):
    if not isinstance(value, str) or not STABLE.fullmatch(value):
        raise ValueError("Expected stable X.Y.Z version")
    return tuple(map(int, value.split(".")))


def metadata(text):
    data = yaml.safe_load(text)
    if not isinstance(data, dict) or data.get("name") != PACKAGE:
        raise ValueError(f"Root package must be named {PACKAGE}")
    if data.get("repository") != REPOSITORY_URL:
        raise ValueError("Root repository URL must match the official repository")
    if "publish_to" in data:
        raise ValueError("Root pubspec must not declare publish_to")
    if "dependency_overrides" in data:
        raise ValueError("Published package must not declare dependency_overrides")
    dependencies = data.get("dependencies")
    if not isinstance(dependencies, dict) or dependencies.get("flutter") != {"sdk": "flutter"}:
        raise ValueError("Domain requires the Flutter SDK dependency")
    if dependencies.get("jocaagura_domain") != "^2.0.0":
        raise ValueError("Domain must consume the certified core ^2.0.0 baseline")
    for name, dependency in dependencies.items():
        if name != "flutter" and (not isinstance(dependency, str) or dependency in ("any", "")):
            raise ValueError("Release dependencies must use hosted version constraints")
    environment = data.get("environment", {})
    if environment.get("flutter") != ">=3.50.0" or environment.get("sdk") != ">=3.14.0 <4.0.0":
        raise ValueError("Release requires the homologated Flutter/Dart SDK baseline")
    version = data.get("version")
    if semver(version) == (0, 0, 0):
        raise ValueError("0.0.0 is bootstrap only")
    return version


def require_release_pr(pr, merged_sha=None):
    try:
        valid = (
            pr["base"]["ref"] == "master"
            and pr["head"]["ref"] == "develop"
            and pr["base"]["repo"]["full_name"] == REPOSITORY
            and pr["head"]["repo"]["full_name"] == REPOSITORY
        )
    except (KeyError, TypeError):
        valid = False
    if not valid:
        raise ValueError("Releases require an official develop -> master PR (no forks)")
    if merged_sha is not None and (
        not pr.get("merged_at")
        or pr.get("state") != "closed"
        or pr.get("merge_commit_sha") != merged_sha
    ):
        raise ValueError("Release commit must be the exact merged develop -> master PR commit")


def read_json(url, *, missing_ok=False, token=None):
    headers = {"Accept": "application/json", "User-Agent": "jocaagura-release-validation"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    try:
        with urlopen(Request(url, headers=headers), timeout=30) as response:
            return json.load(response)
    except HTTPError as error:
        error.close()
        if missing_ok and error.code == 404:
            return None
        raise ValueError(f"Service returned HTTP {error.code}; release eligibility is unknown") from None


def publication_state(version, package):
    target = semver(version)
    if target[2] != 0:
        raise ValueError("Development patches cannot be promoted directly; prepare a minor or major release first")
    if package is None:
        return "manual_first_publication"
    if not isinstance(package, dict) or package.get("name") != PACKAGE:
        raise ValueError("pub.dev returned an unexpected package identity")
    versions = package.get("versions")
    if not isinstance(versions, list) or not versions:
        raise ValueError("pub.dev returned an invalid version listing")
    stable = []
    for item in versions:
        if not isinstance(item, dict) or not isinstance(item.get("version"), str):
            raise ValueError("pub.dev returned malformed version data")
        value = item["version"]
        if STABLE.fullmatch(value):
            stable.append(semver(value))
        elif not re.fullmatch(r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?", value):
            raise ValueError("pub.dev returned an invalid semantic version")
    if stable and target < max(stable):
        raise ValueError("Release version regresses behind a published stable version")
    if target in stable:
        return "already_published"
    return "ready_to_publish"


def require_merged_commit(sha, *, reader=read_json):
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise ValueError("Expected an exact 40-character commit SHA")
    token = os.environ.get("GH_TOKEN")
    for page in range(1, 101):
        prs = reader(
            f"https://api.github.com/repos/{REPOSITORY}/commits/{sha}/pulls?per_page=100&page={page}",
            token=token,
        )
        if not isinstance(prs, list):
            raise ValueError("GitHub returned an invalid PR listing")
        for pr in prs:
            try:
                require_release_pr(pr, merged_sha=sha)
            except ValueError:
                continue
            return
        if len(prs) < 100:
            break
    raise ValueError("No official merged develop -> master PR authorizes this exact commit")


def require_immutable_tags(*, reader=read_json):
    """Require an effective, non-bypassable rule preventing release-tag mutation."""
    token = os.environ.get('GH_TOKEN')
    base = f'https://api.github.com/repos/{REPOSITORY}'
    rulesets = reader(base + '/rulesets?includes_parents=true', token=token)
    if not isinstance(rulesets, list):
        raise ValueError('Tag protections could not be determined')
    for item in rulesets:
        if item.get('target') != 'tag' or item.get('enforcement') != 'active':
            continue
        ruleset = reader(base + f'/rulesets/{item["id"]}', token=token)
        refs = ruleset.get('conditions', {}).get('ref_name', {})
        types = {rule.get('type') for rule in ruleset.get('rules', [])}
        if (refs.get('include') == ['refs/tags/v*'] and refs.get('exclude') == []
                and not ruleset.get('bypass_actors') and {'update', 'deletion'} <= types):
            return
    raise ValueError('Release tags must have active immutable v* rules with no bypass')


def require_tag_source(sha, tag, *, reader=read_json):
    """Recheck the live tag, exact current master and GitHub-verified signature."""
    base = f'https://api.github.com/repos/{REPOSITORY}'
    token = os.environ.get('GH_TOKEN')
    master = reader(base + '/git/ref/heads/master', token=token)
    if master.get('object', {}).get('sha') != sha:
        raise ValueError('Publisher source must be the exact current master commit')
    commit = reader(base + f'/commits/{sha}', token=token)
    if commit.get('commit', {}).get('verification', {}).get('verified') is not True:
        raise ValueError('Release commit must have a verified GitHub signature')
    ref = reader(base + f'/git/ref/tags/{tag}', token=token)['object']
    for _ in range(8):
        if ref.get('type') == 'commit':
            if ref.get('sha') != sha:
                raise ValueError('Live tag differs from the certified event SHA')
            require_immutable_tags(reader=reader)
            return
        if ref.get('type') != 'tag' or not re.fullmatch(r'[0-9a-f]{40}', ref.get('sha', '')):
            break
        ref = reader(base + f'/git/tags/{ref["sha"]}', token=token)['object']
    raise ValueError('Release tag does not resolve to the expected commit')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pr-event", type=Path)
    parser.add_argument("--tag")
    parser.add_argument("--commit")
    parser.add_argument("--metadata-only", action="store_true")
    parser.add_argument("--base-pubspec", type=Path)
    parser.add_argument("--require-new", action="store_true")
    args = parser.parse_args()
    try:
        if args.pr_event:
            event = json.loads(args.pr_event.read_text(encoding="utf-8"))
            require_release_pr(event.get("pull_request"))
        spec = Path("pubspec.yaml").read_text(encoding="utf-8")
        version = metadata(spec)
        if args.base_pubspec:
            base = yaml.safe_load(args.base_pubspec.read_text(encoding="utf-8"))
            if semver(version) <= semver(base.get("version")):
                raise ValueError("Release version must be strictly greater than master")
        if args.metadata_only:
            print(f"Verified package identity: {PACKAGE} {version}")
            return
        release_notes(spec, Path("CHANGELOG.md").read_text(encoding="utf-8"), args.tag or f"v{version}")
        if args.commit:
            require_merged_commit(args.commit)
            if not args.tag:
                raise ValueError('Publisher source validation requires the exact tag')
            require_tag_source(args.commit, args.tag)
        package = read_json(f"https://pub.dev/api/packages/{PACKAGE}", missing_ok=True)
        state = publication_state(version, package)
        if args.require_new and state != "ready_to_publish":
            raise ValueError("Release PR must contain a new eligible version")
        messages = {
            "manual_first_publication": "First publication requires a maintainer; automatic upload is blocked.",
            "already_published": "This version already exists; skip upload. Never overwrite a published version.",
            "ready_to_publish": "Eligible after CI and an official develop -> master merge.",
        }
        print(f"{state}: {PACKAGE} {version}. {messages[state]}")
        if os.environ.get("GITHUB_OUTPUT"):
            with Path(os.environ["GITHUB_OUTPUT"]).open("a", encoding="utf-8") as output:
                output.write(f"state={state}\nversion={version}\n")
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with Path(os.environ["GITHUB_STEP_SUMMARY"]).open("a", encoding="utf-8") as output:
                output.write(f"## Release eligibility\n\n`{PACKAGE} {version}`: **{state}**\n\n{messages[state]}\n")
        if args.tag and state == "manual_first_publication":
            raise ValueError("Automatic first publication is not supported")
    except (ValueError, OSError, yaml.YAMLError) as error:
        parser.exit(1, f"Release validation failed: {error}\n")


if __name__ == "__main__":
    main()
