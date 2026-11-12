"""Plan releases and dispatch the tag publisher after an official master merge."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from release_notes import release_notes
from publication_policy import PACKAGE, REPOSITORY, metadata, publication_state, read_json, require_merged_commit, require_immutable_tags

API = f"https://api.github.com/repos/{REPOSITORY}"


class GitHub:
    def __init__(self, token=None):
        self.token = token

    def read(self, url, **kwargs):
        return read_json(url, token=self.token, missing_ok=kwargs.get('missing_ok', False))

    def get(self, path, *, missing_ok=False):
        return self.read(f'{API}/{path}', missing_ok=missing_ok)

    def post(self, path, body):
        if not self.token:
            raise ValueError('GITHUB_TOKEN is required for release writes')
        request = Request(f'{API}/{path}', data=json.dumps(body).encode('utf-8'), method='POST', headers={
            'Authorization': f'Bearer {self.token}', 'Accept': 'application/vnd.github+json',
            'Content-Type': 'application/json', 'User-Agent': 'jocaagura-release-dispatch',
        })
        try:
            with urlopen(request, timeout=30) as response:
                content = response.read()
                return json.loads(content) if content else None
        except HTTPError as error:
            raise ValueError(f'GitHub write returned HTTP {error.code}; do not assume success') from None


def require_cp0(evidence):
    """Require real probe evidence and maintainer-confirmed trusted publishing setup."""
    try:
        claims = evidence['observed_claims']
        run_id = claims['run_id']
        valid = (
            evidence['status'] == 'passed'
            and evidence['package'] == PACKAGE
            and evidence['repository'] == REPOSITORY
            and evidence['version'] == '5.1.0'
            and evidence['trusted_publisher_configured'] is True
            and claims['repository'] == REPOSITORY
            and claims['iss'] == 'https://token.actions.githubusercontent.com'
            and claims['aud'] == 'https://pub.dev'
            and claims['environment'] == 'pub.dev'
            and claims['mode'] == 'probe'
            and claims['result'] == 'signed_claims_verified'
            and claims['pub_dev_upload'] == 'not_executed'
            and claims['workflow_ref'] == f'{REPOSITORY}/.github/workflows/oidc_probe.yaml@{claims["ref"]}'
            and re.fullmatch(r'[1-9]\d*', run_id)
            and re.fullmatch(r'[0-9a-f]{40}', claims['sha'])
            and evidence['probe_run_url'] == f'https://github.com/{REPOSITORY}/actions/runs/{run_id}'
        )
    except (KeyError, TypeError):
        valid = False
    if not valid:
        raise ValueError('Real package-specific CP-0 probe and trusted publisher setup are required')

def require_context(env, head):
    if (env.get('GITHUB_REPOSITORY') != REPOSITORY
            or env.get('GITHUB_REF') != 'refs/heads/master'
            or env.get('GITHUB_EVENT_NAME') not in ('push', 'workflow_dispatch')
            or not re.fullmatch(r'[0-9a-f]{40}', head)
            or env.get('GITHUB_SHA') != head):
        raise ValueError('Release orchestration requires the exact master event commit')


def plan_release(spec, changelog, sha, evidence, github, package_reader=read_json):
    require_cp0(evidence)
    if github.get('git/ref/heads/master')['object']['sha'] != sha:
        raise ValueError('Master changed; evaluate its current release candidate instead')
    require_merged_commit(sha, reader=github.read)
    version = metadata(spec)
    release_notes(spec, changelog, f'v{version}')
    state = publication_state(version, package_reader(f'https://pub.dev/api/packages/{PACKAGE}', missing_ok=True))
    if state == 'manual_first_publication':
        raise ValueError('First publication must be manual')
    return {'state': state, 'version': version, 'sha': sha}


def tag_commit(ref, github):
    obj = ref['object']
    for _ in range(8):
        if not re.fullmatch(r'[0-9a-f]{40}', obj['sha']):
            raise ValueError('Malformed tag object')
        if obj['type'] == 'commit':
            return obj['sha']
        if obj['type'] != 'tag':
            break
        obj = github.get(f"git/tags/{obj['sha']}")['object']
    raise ValueError('Tag does not resolve to a commit')


def dispatch_release(plan, github, package_reader=read_json):
    version, sha = plan['version'], plan['sha']
    # A second public-state check prevents a stale CI plan from re-uploading.
    state = publication_state(version, package_reader(f'https://pub.dev/api/packages/{PACKAGE}', missing_ok=True))
    if state == 'already_published':
        return state  # Never inspect, move or recreate an existing release tag.
    if plan['state'] != 'ready_to_publish' or state != 'ready_to_publish':
        raise ValueError('Candidate is not eligible for automated publication')
    if github.get('git/ref/heads/master')['object']['sha'] != sha:
        raise ValueError('Master changed after CI; tag creation is blocked')
    require_immutable_tags(reader=github.read)
    workflow = github.get('actions/workflows/publish.yaml')
    if workflow.get('state') != 'active':
        raise ValueError('Publisher must be active on the default branch')
    tag = f'v{version}'
    ref = github.get(f'git/ref/tags/{tag}', missing_ok=True)
    if ref is None:
        github.post('git/refs', {'ref': f'refs/tags/{tag}', 'sha': sha})
        ref = github.get(f'git/ref/tags/{tag}')
    if tag_commit(ref, github) != sha:
        raise ValueError('Conflicting release tag; it must never be moved or deleted')
    github.post('actions/workflows/publish.yaml/dispatches', {'ref': tag})
    return 'publisher_dispatched'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true', help='Create the tag and dispatch after successful CI')
    args = parser.parse_args()
    try:
        head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
        require_context(os.environ, head)
        github = GitHub(os.environ.get('GH_TOKEN'))
        plan = plan_release(Path('pubspec.yaml').read_text(encoding='utf-8'),
                            Path('CHANGELOG.md').read_text(encoding='utf-8'), head,
                            json.loads(Path('.github/evidence/cp0-5.1.0.json').read_text(encoding='utf-8')), github)
        if args.execute:
            plan['state'] = dispatch_release(plan, github)
        print(json.dumps(plan))
        if os.environ.get('GITHUB_OUTPUT'):
            with Path(os.environ['GITHUB_OUTPUT']).open('a', encoding='utf-8') as output:
                output.write(f"state={plan['state']}\nversion={plan['version']}\n")
        if os.environ.get('GITHUB_STEP_SUMMARY'):
            with Path(os.environ['GITHUB_STEP_SUMMARY']).open('a', encoding='utf-8') as output:
                output.write(f"## Release orchestration\n\n{PACKAGE} {plan['version']}: **{plan['state']}**\n\nCommit: `{head}`. Dispatch success is not publication success; inspect Publish package.\n")
    except (ValueError, OSError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        parser.exit(1, f'Release orchestration failed: {error}\n')


if __name__ == '__main__':
    main()
