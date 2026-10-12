"""Check staged paths and exact local credential values without printing them."""
import base64
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
PREFIX = 'purpose-sensitivity/astra_out/'


def strings(value):
    if isinstance(value, str):
        if len(value) >= 12 or '@' in value:
            yield value
    elif isinstance(value, dict):
        for child in value.values():
            yield from strings(child)
    elif isinstance(value, list):
        for child in value:
            yield from strings(child)


def main():
    private_home = Path('/workspace/purpose-sensitivity-private/codex-home')
    if not (private_home / 'auth.json').is_file():
        raise SystemExit('Publication blocked: private authentication file is unavailable for comparison.')
    homes = {private_home,
             Path(os.environ.get('CODEX_HOME', str(Path.home() / '.codex')))}
    sensitive = set()
    for home in homes:
        auth = home / 'auth.json'
        if not auth.exists():
            continue
        values = list(strings(json.loads(auth.read_text())))
        sensitive.update(values)
        for value in values:
            if value.count('.') == 2:
                try:
                    segment = value.split('.')[1]
                    payload = json.loads(base64.urlsafe_b64decode(segment + '=' * (-len(segment) % 4)))
                    # Personal account identifiers can appear separately from tokens.
                    for key in ('email', 'sub'):
                        if isinstance(payload.get(key), str) and payload[key]:
                            sensitive.add(payload[key])
                    identity = payload.get('https://api.openai.com/auth', {})
                    if isinstance(identity, dict):
                        for key, entry in identity.items():
                            if key.endswith(('_user_id', '_account_id')) and isinstance(entry, str) and entry:
                                sensitive.add(entry)
                except (ValueError, UnicodeDecodeError):
                    pass
    for key, value in os.environ.items():
        if any(part in key.upper() for part in ('TOKEN', 'API_KEY', 'PASSWORD', 'SECRET')) and len(value) >= 12:
            sensitive.add(value)
    needles = {v.encode() for v in sensitive}
    needles.update(json.dumps(v)[1:-1].encode() for v in sensitive)
    names = subprocess.check_output(
        ['git', 'diff', '--cached', '--name-only', '-z'], cwd=REPO).decode().split('\0')
    names = [name for name in names if name]
    if any(not name.startswith(PREFIX) for name in names):
        raise SystemExit('Publication blocked: staged path outside authorized directory.')
    for name in names:
        if Path(name).name in {'auth.json', 'config.toml'} or Path(name).suffix in {'.pem', '.key'}:
            raise SystemExit('Publication blocked: credential-like filename.')
        blob = subprocess.run(['git', 'show', ':' + name], cwd=REPO, capture_output=True)
        if blob.returncode:
            raise SystemExit('Publication blocked: cannot inspect staged file.')
        if any(needle in blob.stdout for needle in needles):
            raise SystemExit('Publication blocked: local credential or account identifier matched staged data.')
    print(f'Publication check passed: {len(names)} staged files within scope; no local credential matches.')


if __name__ == '__main__':
    main()
