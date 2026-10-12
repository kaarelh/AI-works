"""Synthetic Git/index tests; no real credentials or study data are read."""
from pathlib import Path
import subprocess
import tempfile
import unittest

from _check_publish import check_staged


class PublicationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(
            prefix='astra_publication_test_', dir=Path(__file__).resolve().parent)
        self.repo = Path(self.temporary.name)
        self.allowed = self.repo / 'purpose-sensitivity/astra_out'
        self.allowed.mkdir(parents=True)
        self.git('init', '-q')
        self.git('config', 'user.name', 'Synthetic Test')
        self.git('config', 'user.email', 'synthetic@example.invalid')
        self.write('purpose-sensitivity/astra_out/old.txt', 'Synthetic baseline.\n')
        self.write('outside.txt', 'Synthetic outside baseline.\n')
        self.git('add', '-A')
        self.git('commit', '-qm', 'Synthetic baseline')
        self.needles = {b'synthetic-secret-123456789'}

    def tearDown(self):
        self.temporary.cleanup()

    def git(self, *args):
        return subprocess.run(['git', *args], cwd=self.repo, check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout

    def write(self, relative, text):
        path = self.repo / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def test_in_scope_deletion_passes(self):
        self.git('rm', 'purpose-sensitivity/astra_out/old.txt')
        self.assertEqual(check_staged(self.repo, self.needles), 1)

    def test_out_of_scope_deletion_is_rejected(self):
        self.git('rm', 'outside.txt')
        with self.assertRaisesRegex(SystemExit, 'outside authorized directory'):
            check_staged(self.repo, self.needles)

    def test_outside_rename_source_is_rejected(self):
        self.git('mv', 'outside.txt', 'purpose-sensitivity/astra_out/moved.txt')
        with self.assertRaisesRegex(SystemExit, 'outside authorized directory'):
            check_staged(self.repo, self.needles)

    def test_in_scope_rename_passes_as_deletion_and_addition(self):
        self.git('mv', 'purpose-sensitivity/astra_out/old.txt', 'purpose-sensitivity/astra_out/moved.txt')
        self.assertEqual(check_staged(self.repo, self.needles), 2)

    def test_deletion_does_not_bypass_sensitive_added_blob(self):
        self.git('rm', 'purpose-sensitivity/astra_out/old.txt')
        self.write('purpose-sensitivity/astra_out/new.txt', 'synthetic-secret-123456789\n')
        self.git('add', 'purpose-sensitivity/astra_out/new.txt')
        with self.assertRaisesRegex(SystemExit, 'credential or account identifier'):
            check_staged(self.repo, self.needles)

    def test_modified_sensitive_blob_is_rejected(self):
        self.write('purpose-sensitivity/astra_out/old.txt', 'synthetic-secret-123456789\n')
        self.git('add', 'purpose-sensitivity/astra_out/old.txt')
        with self.assertRaisesRegex(SystemExit, 'credential or account identifier'):
            check_staged(self.repo, self.needles)

    def test_staged_blob_is_scanned_instead_of_clean_worktree(self):
        self.write('purpose-sensitivity/astra_out/old.txt', 'synthetic-secret-123456789\n')
        self.git('add', 'purpose-sensitivity/astra_out/old.txt')
        self.write('purpose-sensitivity/astra_out/old.txt', 'Synthetic clean worktree.\n')
        with self.assertRaisesRegex(SystemExit, 'credential or account identifier'):
            check_staged(self.repo, self.needles)

    def test_new_credential_filename_is_rejected(self):
        self.write('purpose-sensitivity/astra_out/auth.json', '{}\n')
        self.git('add', 'purpose-sensitivity/astra_out/auth.json')
        with self.assertRaisesRegex(SystemExit, 'credential-like filename'):
            check_staged(self.repo, self.needles)

    def test_removing_credential_filename_is_allowed(self):
        self.write('purpose-sensitivity/astra_out/auth.json', '{}\n')
        self.git('add', 'purpose-sensitivity/astra_out/auth.json')
        self.git('commit', '-qm', 'Synthetic credential filename fixture')
        self.git('rm', 'purpose-sensitivity/astra_out/auth.json')
        self.assertEqual(check_staged(self.repo, self.needles), 1)

    def test_empty_index_is_valid(self):
        self.assertEqual(check_staged(self.repo, self.needles), 0)


if __name__ == '__main__':
    unittest.main()
