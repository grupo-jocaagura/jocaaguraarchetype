"""Offline policy tests; fixtures are synthetic and are not certification evidence."""
import copy
import re
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from publication_policy import PACKAGE, REPOSITORY, metadata, publication_state, require_release_pr
from release_dispatch import require_context, require_cp0, dispatch_release
from release_notes import release_notes


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.spec = re.sub(r'^version:.*$', 'version: 5.0.0',
                           Path('pubspec.yaml').read_text(encoding='utf-8'), flags=re.M)
        self.package = {'name': PACKAGE, 'versions': [{'version': '5.0.0'}]}

    def test_official_metadata(self):
        self.assertEqual(metadata(self.spec), '5.0.0')

    def test_invalid_dependencies(self):
        for replacement in ['any', '^1.43.0', '{path: ../domain}']:
            with self.subTest(replacement=replacement), self.assertRaises(ValueError):
                metadata(self.spec.replace('jocaagura_domain: ^2.0.0', f'jocaagura_domain: {replacement}'))

    def test_identity(self):
        with self.assertRaises(ValueError):
            metadata(self.spec.replace('grupo-jocaagura/jocaaguraarchetype', 'other/repository'))

    def test_public_states(self):
        self.assertEqual(publication_state('5.1.0', self.package), 'ready_to_publish')
        self.assertEqual(publication_state('5.0.0', self.package), 'already_published')
        self.assertEqual(publication_state('5.1.0', None), 'manual_first_publication')

    def test_regression_and_development_patch(self):
        for version in ['4.0.0', '5.0.1', '5.1.0-beta', 'invalid']:
            with self.subTest(version=version), self.assertRaises(ValueError):
                publication_state(version, self.package)

    def test_unexpected_registry_identity(self):
        package = copy.deepcopy(self.package)
        package['name'] = 'another_package'
        with self.assertRaises(ValueError):
            publication_state('5.1.0', package)

    def test_exact_merged_pr(self):
        pr = {'base': {'ref': 'master', 'repo': {'full_name': REPOSITORY}},
              'head': {'ref': 'develop', 'repo': {'full_name': REPOSITORY}},
              'merged_at': '2026-11-12', 'state': 'closed', 'merge_commit_sha': 'a' * 40}
        require_release_pr(pr, 'a' * 40)
        for changed in [dict(pr, merged_at=None), dict(pr, merge_commit_sha='b'*40)]:
            with self.assertRaises(ValueError):
                require_release_pr(changed, 'a'*40)
        pr['head']['repo']['full_name'] = 'fork/package'
        with self.assertRaises(ValueError):
            require_release_pr(pr, 'a'*40)

    def test_master_context(self):
        env = {'GITHUB_REPOSITORY': REPOSITORY, 'GITHUB_REF': 'refs/heads/master',
               'GITHUB_EVENT_NAME': 'push', 'GITHUB_SHA': 'a'*40}
        require_context(env, 'a'*40)
        for field, value in [('GITHUB_REF', 'refs/heads/develop'), ('GITHUB_SHA', 'b'*40),
                             ('GITHUB_EVENT_NAME', 'pull_request')]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                require_context(dict(env, **{field: value}), 'a'*40)

    def test_pending_checkpoint_blocks_release(self):
        with self.assertRaises(ValueError):
            require_cp0({'status': 'pending'})

    def test_changelog_tag_must_match(self):
        changelog = '## [5.0.0] - 2026-11-12\n\n### Added\n\n- Widget.\n'
        self.assertIn('Widget', release_notes(self.spec, changelog, 'v5.0.0'))
        with self.assertRaises(ValueError):
            release_notes(self.spec, changelog, 'v5.1.0')

    def test_published_version_never_dispatches_or_mutates_tags(self):
        class NoWrites:
            def get(self, *args, **kwargs):
                raise AssertionError('No tag lookup needed for a published version')
            def post(self, *args, **kwargs):
                raise AssertionError('Must not write')
        self.assertEqual(dispatch_release({'version': '5.0.0', 'sha': 'a'*40,
                                          'state': 'ready_to_publish'}, NoWrites(),
                                         lambda *a, **kw: self.package), 'already_published')


if __name__ == '__main__':
    unittest.main()
