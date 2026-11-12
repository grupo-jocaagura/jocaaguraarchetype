"""Synthetic Git histories exercise reconciliation without network or signing keys."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import master_sync as sync


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        original_git = sync.git
        self.g = lambda *args, **kw: original_git(*args, cwd=self.root, **kw)
        patcher = patch.object(sync, 'git', self.g)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.g('init', '-b', 'master')
        self.g('config', 'user.name', 'Synthetic test')
        self.g('config', 'user.email', 'test@example.invalid')
        self.g('config', 'commit.gpgsign', 'false')
        self.g('config', 'core.autocrlf', 'false')
        self.spec = Path('pubspec.yaml').read_text(encoding='utf-8')
        (self.root / 'pubspec.yaml').write_text(self.spec, encoding='utf-8')
        (self.root / 'CHANGELOG.md').write_text('# Changelog\n\n## Release\n', encoding='utf-8')
        self.commit('base')
        self.g('switch', '-c', 'develop')
        (self.root / 'code.txt').write_text('released\n', encoding='utf-8')
        self.source = self.commit('release source')
        self.g('switch', 'master')
        self.g('merge', '--squash', 'develop')
        self.master = self.commit('squashed release')
        self.g('switch', 'develop')
        (self.root / 'code.txt').write_text('next development\n', encoding='utf-8')
        self.develop = self.commit('later work')
        self.verified = True
        self.release = {'base': {'ref': 'master', 'repo': {'full_name': sync.REPOSITORY}},
                        'head': {'ref': 'develop', 'sha': self.source,
                                 'repo': {'full_name': sync.REPOSITORY}},
                        'state': 'closed', 'merged_at': '2026-11-12',
                        'merge_commit_sha': self.master}
        self.writes = []
        self.github = type('FakeGitHub', (), {'get': lambda _, path, **kw: self.get(path),
                                             'post': lambda _, path, body: self.writes.append((path, body))})()

    def commit(self, message):
        self.g('add', '.')
        self.g('commit', '-m', message)
        return self.g('rev-parse', 'HEAD')

    def get(self, path):
        if path == 'git/ref/heads/master':
            return {'object': {'sha': self.master}}
        if path == 'git/ref/heads/develop':
            return {'object': {'sha': self.develop}}
        if '/pulls?' in path:
            return [self.release]
        if path.startswith('commits/'):
            return {'commit': {'verification': {'verified': self.verified}}}
        raise AssertionError(path)

    def reader(self, url, **kwargs):
        return {'name': sync.PACKAGE, 'versions': [{'version': sync.metadata(self.spec)}]}

    def merge(self):
        self.g('merge', '--no-commit', '--no-ff', '--strategy=ours', self.master)
        path = self.root / 'CHANGELOG.md'
        path.write_text(sync.changelog_note(path.read_text(encoding='utf-8'), self.master), encoding='utf-8')
        return self.commit('sync')

    def test_plan_is_read_only_and_preserves_later_work(self):
        plan = sync.plan_sync(self.master, self.github, self.reader)
        self.assertEqual(plan['state'], 'ready')
        head = self.merge()
        sync.validate_commit(head, self.master, self.develop, self.github)
        self.assertEqual(self.g('show', f'{head}:code.txt'), 'next development')
        self.assertTrue(sync.ancestor(self.master, head))
        self.assertEqual(self.writes, [])

    def test_stale_and_synchronized_events_are_noops(self):
        self.assertEqual(sync.plan_sync('f'*40, self.github)['state'], 'stale_event')
        self.develop = self.merge()
        self.assertEqual(sync.plan_sync(self.master, self.github)['state'], 'already_synchronized')
        self.assertEqual(sync.open_sync({'state': 'already_synchronized'}, self.github)['state'], 'already_synchronized')
        self.assertEqual(self.writes, [])

    def test_unpublished_release_waits(self):
        self.assertEqual(sync.plan_sync(self.master, self.github, lambda *a, **kw: None)['state'], 'awaiting_publication')
        self.assertEqual(self.writes, [])

    def test_master_content_must_match_official_release(self):
        self.release['head']['sha'] = self.develop
        with self.assertRaisesRegex(ValueError, 'differs'):
            sync.plan_sync(self.master, self.github, self.reader)

    def test_missing_provenance_and_unsigned_commit_rejected(self):
        self.release['head']['ref'] = 'other'
        with self.assertRaisesRegex(ValueError, 'No official'):
            sync.plan_sync(self.master, self.github, self.reader)
        self.verified = False
        with self.assertRaisesRegex(ValueError, 'signature'):
            sync.plan_sync(self.master, self.github, self.reader)

    def test_wrong_parents_rejected(self):
        with self.assertRaisesRegex(ValueError, 'two-parent'):
            sync.validate_commit(self.develop, self.master, self.develop, self.github)

    def test_extra_code_changes_rejected(self):
        head = self.merge()
        (self.root / 'code.txt').write_text('injected', encoding='utf-8')
        self.g('add', '.')
        self.g('commit', '--amend', '--no-edit')
        with self.assertRaisesRegex(ValueError, 'Only the generated'):
            sync.validate_commit(self.g('rev-parse', 'HEAD'), self.master, self.develop, self.github)

    def test_changelog_tampering_rejected(self):
        self.merge()
        path = self.root / 'CHANGELOG.md'
        path.write_text(path.read_text(encoding='utf-8') + 'unexpected\n', encoding='utf-8')
        self.g('add', '.')
        self.g('commit', '--amend', '--no-edit')
        with self.assertRaisesRegex(ValueError, 'Unexpected changelog'):
            sync.validate_commit(self.g('rev-parse', 'HEAD'), self.master, self.develop, self.github)

    def test_current_develop_version_can_advance(self):
        current = sync.metadata(self.spec)
        advanced = '99.0.0'
        (self.root / 'pubspec.yaml').write_text(self.spec.replace(f'version: {current}', f'version: {advanced}'), encoding='utf-8')
        self.develop = self.commit('next version already planned')
        self.assertEqual(sync.plan_sync(self.master, self.github, self.reader)['version'], advanced)
        sync.validate_commit(self.merge(), self.master, self.develop, self.github)

    def test_marker_is_idempotent_and_replaced(self):
        original = '# Changelog\n\nContent\n'
        noted = sync.changelog_note(original, self.master)
        self.assertEqual(sync.changelog_note(noted, self.master), noted)
        updated = sync.changelog_note(noted, 'a'*40)
        self.assertNotIn(self.master, updated)
        self.assertEqual(updated.count('master-sync:'), 1)

    def test_existing_pr_is_revalidated_and_reused(self):
        plan = sync.plan_sync(self.master, self.github, self.reader)
        head = self.merge()
        pr = {'number': 123, 'state': 'open', 'head': {'sha': head},
              'html_url': 'https://example.invalid/pull/123'}
        with patch.object(self.github, 'get', return_value=[pr]), \
                patch.object(sync, 'validate_pr', return_value={}) as validate:
            result = sync.open_sync(plan, self.github)
        validate.assert_called_once_with(123, head, self.github)
        self.assertEqual(result['state'], 'pr_open')
        self.assertEqual([path for path, body in self.writes], [
            'issues/123/labels', 'actions/workflows/validate_master_sync.yaml/dispatches'])
        self.assertEqual(self.writes[-1][1]['inputs']['head'], head)

    def test_closed_pr_is_never_recreated(self):
        plan = sync.plan_sync(self.master, self.github, self.reader)
        with patch.object(self.github, 'get', return_value=[{'state': 'closed'}]):
            with self.assertRaisesRegex(ValueError, 'manual recovery'):
                sync.open_sync(plan, self.github)
        self.assertEqual(self.writes, [])

    def test_status_identity_rejects_fork_and_head_drift(self):
        head = 'a'*40
        pr = {'state': 'open', 'base': {'ref': 'develop', 'repo': {'full_name': sync.REPOSITORY}},
              'head': {'sha': head, 'ref': sync.PREFIX + self.master,
                       'repo': {'full_name': sync.REPOSITORY}}}
        with patch.object(self.github, 'get', return_value=pr):
            self.assertEqual(sync.sync_pr_identity(123, head, self.github)[1], self.master)
            with self.assertRaises(ValueError):
                sync.sync_pr_identity(123, 'b'*40, self.github)
            pr['head']['repo']['full_name'] = 'fork/repository'
            with self.assertRaises(ValueError):
                sync.sync_pr_identity(123, head, self.github)

    @unittest.skipUnless(shutil.which('ssh-keygen'), 'OpenSSH required')
    def test_real_pem_ssh_signed_merge_with_public_companion(self):
        key = self.root / '.git' / 'synthetic-signing-key'
        subprocess.run(['ssh-keygen', '-q', '-t', 'rsa', '-b', '2048', '-m', 'PEM',
                        '-N', '', '-f', str(key)], check=True, capture_output=True)
        public = Path(str(key) + '.pub')
        public.unlink()
        self.g('config', 'gpg.format', 'ssh')
        self.g('config', 'user.signingkey', str(key))
        self.g('merge', '--no-commit', '--no-ff', '--strategy=ours', self.master)
        path = self.root / 'CHANGELOG.md'
        path.write_text(sync.changelog_note(path.read_text(encoding='utf-8'), self.master), encoding='utf-8')
        self.g('add', 'CHANGELOG.md')
        # Reproduce the first production failure without any repository secrets.
        with self.assertRaisesRegex(ValueError, 'public key unavailable'):
            self.g('commit', '-S', '-m', 'synthetic PEM merge')
        result = subprocess.run(['ssh-keygen', '-y', '-f', str(key)], check=True,
                                text=True, capture_output=True)
        public.write_text(result.stdout, encoding='utf-8')
        self.g('commit', '-S', '-m', 'synthetic PEM merge')
        head = self.g('rev-parse', 'HEAD')
        allowed = self.root / '.git' / 'synthetic-allowed-signers'
        allowed.write_text('test@example.invalid ' + result.stdout, encoding='utf-8')
        self.g('config', 'gpg.ssh.allowedSignersFile', str(allowed))
        self.g('verify-commit', head)
        sync.validate_commit(head, self.master, self.develop, self.github)


if __name__ == '__main__':
    unittest.main()
