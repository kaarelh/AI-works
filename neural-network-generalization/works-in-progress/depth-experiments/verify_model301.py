"""Regenerate model 301's exact global certificate offline in temporary files."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    model = next((ROOT / 'experiment/models').glob('301-*.npz'))
    original = json.loads((ROOT / 'certificates/global-exact-verified-301.json').read_text())
    assert sha(model) == original['model_sha256']
    with tempfile.TemporaryDirectory(prefix='depth-public-model301-') as temporary:
        dest = Path(temporary)
        cert = dest / 'certificates'
        models = dest / 'experiment/models'
        cert.mkdir()
        models.mkdir(parents=True)
        shutil.copy2(model, models / model.name)
        for name in ['verify_global_exact.py', 'exact_svd_bound.py']:
            shutil.copy2(ROOT / 'certificates' / name, cert / name)
        command = [sys.executable, 'verify_global_exact.py', '--indices', '301',
                   '--c', '1/32000', '--replay']
        result = subprocess.run(command, cwd=cert,
                                env=dict(os.environ, OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1'),
                                capture_output=True, text=True)
        if result.returncode:
            print(result.stdout)
            print(result.stderr, file=sys.stderr)
            raise SystemExit(result.returncode)
        record = json.loads((cert / 'global-exact-verified-301.json').read_text())
        assert record['model_sha256'] == sha(model)
        assert record['hidden_depth'] == 32
        assert record['width'] == 128
        assert record['exact_final_inequality_pass']
        assert record['c_exact']['numerator'] == '1'
        assert record['c_exact']['denominator'] == '32000'
        assert len(record['operator_squared_upper_bounds_exact']) == 31
        print(json.dumps({
            'all_checks_passed': True,
            'model_sha256': sha(model),
            'hidden_depth': 32,
            'width': 128,
            'c_exact': '1/32000',
            'certified_raw_output_change_approx': record['certified_raw_output_change_approx'],
            'scope': record['scope'],
            'exact_matrix_certificates_regenerated': 31,
            'external_dataset_or_network_required': False,
            'committed_records_modified': False,
            'qualification': 'Exact Python integer/rational spectral and noise-budget inequalities; not a Lean proof. Approximate SVDs propose factors, all of which are checked exactly.',
            'command': command[1:],
            'stdout_tail': result.stdout[-1200:],
        }, indent=2))


if __name__ == '__main__':
    main()
