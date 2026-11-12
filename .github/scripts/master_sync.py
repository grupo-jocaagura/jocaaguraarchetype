"""Open a signed history-only master -> develop sync PR; never approve or merge it."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import time

import yaml

from publication_policy import (PACKAGE, REPOSITORY, metadata, publication_state,
                                read_json, require_release_pr, semver)
from release_dispatch import GitHub

PREFIX = 'automation/sync-master-'
CONTEXT = 'Master synchronization validation'


def git(*args, cwd=None, check=True):
    result = subprocess.run(['git', *args], cwd=cwd, text=True, encoding='utf-8',
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if check and result.returncode:
        # Never echo command arguments, credentials or signing-key diagnostics.
        if args[0] == 'commit' and "Couldn't load public key" in result.stderr:
            raise ValueError('SSH signing public key unavailable; generate the private-key .pub companion')
        raise ValueError(f'Git operation {args[0]} failed ({result.returncode})')
    return result.stdout.strip() if check else result.returncode


def sha(value):
    if not isinstance(value, str) or not re.fullmatch(r'[0-9a-f]{40}', value):
        raise ValueError('Expected exact commit SHA')
    return value


def ancestor(parent, child):
    result = git('merge-base', '--is-ancestor', sha(parent), sha(child), check=False)
    if result not in (0, 1):
        raise ValueError('Cannot establish ancestry')
    return result == 0


def version_at(commit):
    version = yaml.safe_load(git('show', f'{sha(commit)}:pubspec.yaml'))['version']
    semver(version)
    return version


def changelog_note(text, master):
    sha(master)
    text = re.sub(r'(?m)^<!-- master-sync: [0-9a-f]{40} -->\r?\n', '', text)
    lines = text.splitlines(keepends=True)
    if not lines or not lines[0].startswith('# '):
        raise ValueError('Changelog heading missing')
    lines.insert(1, f'<!-- master-sync: {master} -->\n')
    return ''.join(lines)


def release_head(master, github):
    commit = github.get(f'commits/{sha(master)}')
    if commit.get('commit', {}).get('verification', {}).get('verified') is not True:
        raise ValueError('Master commit must have a verified signature')
    for page in range(1, 101):
        prs = github.get(f'commits/{master}/pulls?per_page=100&page={page}')
        if not isinstance(prs, list):
            raise ValueError('Invalid release PR response')
        for pr in prs:
            try:
                require_release_pr(pr, merged_sha=master)
            except ValueError:
                continue
            return sha(pr['head']['sha'])
        if len(prs) < 100:
            break
    raise ValueError('No official merged develop -> master PR for this commit')


def verify_snapshot(master, develop, github):
    source = release_head(master, github)
    # A squash is safe to reconcile with the ours strategy ONLY after proving
    # the entire master tree already exists in a develop ancestor.
    if git('rev-parse', f'{master}^{{tree}}') != git('rev-parse', f'{source}^{{tree}}'):
        raise ValueError('Master differs from the merged release source; manual sync required')
    if not ancestor(source, develop):
        raise ValueError('Release source is not in develop; manual sync required')


def plan_sync(expected, github, reader=read_json):
    master = sha(github.get('git/ref/heads/master')['object']['sha'])
    develop = sha(github.get('git/ref/heads/develop')['object']['sha'])
    if master != sha(expected):
        return {'state': 'stale_event', 'master': master}
    if ancestor(master, develop):
        return {'state': 'already_synchronized', 'master': master, 'develop': develop}
    verify_snapshot(master, develop, github)
    spec = git('show', f'{master}:pubspec.yaml')
    version = metadata(spec)
    state = publication_state(version, reader(f'https://pub.dev/api/packages/{PACKAGE}', missing_ok=True))
    if state != 'already_published':
        return {'state': 'awaiting_publication', 'master': master, 'version': version}
    return {'state': 'ready', 'master': master, 'develop': develop,
            'version': version_at(develop), 'branch': PREFIX + master}


def validate_commit(head, master, develop, github):
    sha(head)
    verify_snapshot(master, develop, github)
    commit = github.get(f'commits/{head}')
    if commit.get('commit', {}).get('verification', {}).get('verified') is not True:
        raise ValueError('Sync commit signature is not verified')
    parents = git('show', '-s', '--format=%P', head).split()
    if len(parents) != 2 or parents[1] != master or not ancestor(parents[0], develop):
        raise ValueError('Sync must be a normal two-parent merge based on develop')
    base = parents[0]
    if version_at(head) != version_at(base) or version_at(head) != version_at(develop):
        raise ValueError('Sync must preserve the current develop version')
    if git('diff', '--name-only', base, head).splitlines() != ['CHANGELOG.md']:
        raise ValueError('Only the generated changelog marker may differ')
    before = git('show', f'{base}:CHANGELOG.md') + '\n'
    after = git('show', f'{head}:CHANGELOG.md') + '\n'
    if after != changelog_note(before, master):
        raise ValueError('Unexpected changelog edits')
    if not ancestor(master, head):
        raise ValueError('Master ancestry missing')


def sync_pr_identity(number, head, github):
    sha(head)
    if not isinstance(number, int) or number <= 0:
        raise ValueError('Invalid PR number')
    pr = github.get(f'pulls/{number}')
    branch = pr['head']['ref']
    if (pr['state'] != 'open' or pr['base']['ref'] != 'develop'
            or pr['head']['repo']['full_name'] != REPOSITORY
            or pr['base']['repo']['full_name'] != REPOSITORY
            or pr['head']['sha'] != head or not branch.startswith(PREFIX)):
        raise ValueError('Unexpected sync PR identity or head drift')
    master = sha(branch[len(PREFIX):])
    return pr, master


def validate_pr(number, head, github):
    pr, master = sync_pr_identity(number, head, github)
    if github.get('git/ref/heads/master')['object']['sha'] != master:
        raise ValueError('Sync PR is stale relative to master')
    develop = sha(github.get('git/ref/heads/develop')['object']['sha'])
    git('fetch', 'origin', head, master, develop)
    validate_commit(head, master, develop, github)
    return {'state': 'validated', 'pr': number, 'head': head}


def open_sync(plan, github):
    if plan['state'] != 'ready':
        return plan
    master, develop, branch = plan['master'], plan['develop'], plan['branch']
    existing = github.get(f'pulls?state=all&head={REPOSITORY.split("/")[0]}:{branch}&base=develop')
    if existing:
        pr = existing[0]
        if pr['state'] != 'open':
            raise ValueError('Previous sync PR closed without ancestry; manual recovery required')
        validate_pr(pr['number'], sha(pr['head']['sha']), github)
    else:
        ref = github.get(f'git/ref/heads/{branch}', missing_ok=True)
        if ref is None:
            if (github.get('git/ref/heads/master')['object']['sha'] != master
                    or github.get('git/ref/heads/develop')['object']['sha'] != develop):
                raise ValueError('Branches drifted before sync preparation; rerun')
            git('switch', '-c', branch, develop)
            git('merge', '--no-commit', '--no-ff', '--strategy=ours', master)
            # Our strategy is justified by verify_snapshot, not a generic
            # conflict override. Only the changelog annotation changes content.
            path = Path('CHANGELOG.md')
            path.write_text(changelog_note(path.read_text(encoding='utf-8'), master), encoding='utf-8')
            git('add', 'CHANGELOG.md')
            git('commit', '-S', '-m', f'chore: synchronize master history {master}')
            head = sha(git('rev-parse', 'HEAD'))
            git('push', 'origin', f'HEAD:refs/heads/{branch}')
            # Signature verification can become visible just after ingestion.
            for attempt in range(5):
                if github.get(f'commits/{head}').get('commit', {}).get('verification', {}).get('verified') is True:
                    break
                if attempt == 4:
                    raise ValueError('Pushed sync commit signature not yet verified; rerun')
                time.sleep(2)
        else:
            head = sha(ref['object']['sha'])
            git('fetch', 'origin', head)
        validate_commit(head, master, develop, github)
        # Refuse stale creation rather than force-updating an existing branch.
        if (github.get('git/ref/heads/master')['object']['sha'] != master
                or github.get('git/ref/heads/develop')['object']['sha'] != develop):
            raise ValueError('Branches drifted before PR creation; rerun')
        pr = github.post('pulls', {
            'base': 'develop', 'head': branch,
            'title': f'chore: sync master into develop ({plan["version"]} unchanged)',
            'body': f'Automatic history synchronization for master `{master}`.\n\n'
                    f'Version **{plan["version"]}** is unchanged. Only a generated changelog '
                    'marker changes content; no code, workflow or dependency changes.\n\n'
                    'Human review and a normal **merge commit** are required to retain ancestry. '
                    'Do not squash/rebase or force-push this PR.\n\n'
                    'The automation never approves, merges, changes tags or publishes a package.',
        })
    github.post(f'issues/{pr["number"]}/labels', {'labels': ['skip-version-bump', 'documentation']})
    head = sha(pr['head']['sha'])
    github.post('actions/workflows/validate_master_sync.yaml/dispatches', {
        'ref': 'master', 'inputs': {'pr': str(pr['number']), 'head': head},
    })
    return {'state': 'pr_open', 'pr': pr['number'], 'url': pr['html_url'], 'head': head}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-sha')
    parser.add_argument('--execute', action='store_true')
    parser.add_argument('--validate-pr', type=int)
    parser.add_argument('--head')
    parser.add_argument('--status', choices=['pending', 'success', 'failure'])
    args = parser.parse_args()
    try:
        if os.environ.get('GITHUB_REPOSITORY', REPOSITORY) != REPOSITORY:
            raise ValueError('Official repository required')
        github = GitHub(os.environ.get('GH_TOKEN'))
        if args.status:
            sha(args.head)
            # Never let a dispatch label an arbitrary commit as validated.
            sync_pr_identity(args.validate_pr, args.head, github)
            if args.status == 'success':
                validate_pr(args.validate_pr, args.head, github)
            github.post(f'statuses/{args.head}', {'state': args.status, 'context': CONTEXT,
                'description': 'History, verified merge signature and unchanged code/version',
                'target_url': f'https://github.com/{REPOSITORY}/actions/runs/{os.environ["GITHUB_RUN_ID"]}'})
            result = {'state': args.status, 'head': args.head}
        elif args.validate_pr:
            result = validate_pr(args.validate_pr, args.head, github)
        else:
            git('fetch', 'origin', 'master', 'develop')
            result = plan_sync(sha(args.source_sha), github)
            if args.execute:
                result = open_sync(result, github)
        print(json.dumps(result))
        if os.environ.get('GITHUB_STEP_SUMMARY'):
            with Path(os.environ['GITHUB_STEP_SUMMARY']).open('a', encoding='utf-8') as summary:
                summary.write('## Master/develop synchronization\n\n```json\n' + json.dumps(result) + '\n```\n')
    except (ValueError, KeyError, TypeError, OSError, yaml.YAMLError) as error:
        parser.exit(1, f'Master synchronization failed: {error}\n')


if __name__ == '__main__':
    main()
