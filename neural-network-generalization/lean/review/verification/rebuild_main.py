#!/usr/bin/env python3
"""Rebuild exact main-theorem project dependencies in a new, isolated directory.

No project .olean is copied. External packages are pinned and checked clean.
By default their cache is shared; --fresh-dependencies rebuilds them from source.
An existing destination is refused, even if empty. No network update is run.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone

MAINS = {
    "strong": ("NeuralGeneralization.StrongPriorMain", "StrongPriorGeneralization", "strongPrior"),
    "above": ("NeuralGeneralization.AboveMeanFieldMain", "AboveMeanFieldGeneralization", "aboveMeanField"),
    "meanfield": ("NeuralGeneralization.MeanFieldMain", "MeanFieldGeneralization", "meanField"),
    "subcritical": ("NeuralGeneralization.SubcriticalMain", "SubcriticalExponentialLowerBound", "subcriticalExponential"),
    "robust": ("NeuralGeneralization.RobustMain", "RobustPolynomialDepthGeneralization", "robustPolynomialDepth"),
}
CONFIGS = ("lean-toolchain", "lakefile.toml", "lake-manifest.json")


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def write_json(path: Path, value) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def checked_output(command, cwd=None) -> str:
    return subprocess.check_output(command, cwd=cwd, text=True).strip()


def erase_comments_and_strings(text: str) -> str:
    # Preserve newlines, including within nested Lean block comments.
    result, i, depth, string = [], 0, 0, False
    while i < len(text):
        pair = text[i:i+2]
        ch = text[i]
        if depth:
            if pair == "/-": depth += 1; result.extend("  "); i += 2; continue
            if pair == "-/": depth -= 1; result.extend("  "); i += 2; continue
            result.append("\n" if ch == "\n" else " "); i += 1; continue
        if string:
            if ch == "\\" and i+1 < len(text): result.extend("  "); i += 2; continue
            if ch == '"': string = False
            result.append("\n" if ch == "\n" else " "); i += 1; continue
        if pair == "/-": depth = 1; result.extend("  "); i += 2; continue
        if pair == "--":
            j = text.find("\n", i)
            if j < 0: j = len(text)
            result.extend(" " * (j-i)); i = j; continue
        if ch == '"': string = True; result.append(" "); i += 1; continue
        result.append(ch); i += 1
    if depth or string:
        raise ValueError("Unclosed Lean block comment or string")
    return "".join(result)


def imports(path: Path) -> list[str]:
    clean = erase_comments_and_strings(path.read_text())
    found = []
    for line in clean.splitlines():
        match = re.fullmatch(r"\s*(?:(?:public|private)\s+)?import\s+(.+?)\s*", line)
        if not match:
            if re.search(r"\bimport\b", line):
                raise ValueError(f"Unsupported import formatting in {path}: {line!r}")
            continue
        modules = match.group(1).split()
        if not all(re.fullmatch(r"[A-Za-z_][A-Za-z_0-9'.]*", m) for m in modules):
            raise ValueError(f"Unsupported import declaration in {path}: {line!r}")
        found.extend(modules)
    return found


def project_closure(project: Path, modules: list[str]) -> list[Path]:
    seen, visiting = set(), set()
    def visit(module):
        if module in seen: return
        if module in visiting: raise ValueError(f"Cyclic import at {module}")
        path = project.joinpath(*module.split('.')).with_suffix('.lean')
        if not path.is_file(): raise FileNotFoundError(f"Required main/project source is absent: {path}")
        visiting.add(module)
        for dependency in imports(path):
            if dependency == "NeuralGeneralization" or dependency.startswith("NeuralGeneralization."):
                visit(dependency)
        visiting.remove(module); seen.add(module)
    for module in modules: visit(module)
    return sorted(Path(*module.split('.')).with_suffix('.lean') for module in seen)


def package_state(project: Path, manifest: dict) -> dict:
    result = {}
    for package in manifest["packages"]:
        if package["type"] != "git": raise ValueError("Non-git dependency is not supported by this verifier")
        directory = project / manifest.get("packagesDir", ".lake/packages") / package["name"]
        revision = checked_output(["git", "rev-parse", "HEAD"], directory)
        if revision != package["rev"]:
            raise ValueError(f"Unpinned dependency {package['name']}: {revision} != {package['rev']}")
        dirty = checked_output(["git", "status", "--porcelain", "--untracked-files=no"], directory)
        if dirty: raise ValueError(f"Tracked dependency modifications in {directory}:\n{dirty}")
        result[package["name"]] = {"revision": revision, "tracked_source_clean": True}
    return result


def package_artifacts(packages: Path) -> dict[str, str]:
    # Record the actual reusable Lean objects, including private payloads and IR.
    # New dependencies built during verification may add entries; existing ones
    # must not change between the recorded before/after states.
    extensions = (".olean", ".olean.private", ".olean.server", ".ir", ".so")
    result = {}
    for package in sorted(packages.iterdir()):
        build = package / ".lake/build"
        if not build.exists(): continue
        for artifact in sorted(build.rglob("*")):
            if artifact.is_file() and artifact.name.endswith(extensions):
                result[str(artifact.relative_to(packages))] = digest(artifact)
    return result


def audit_source(targets) -> str:
    lines = [f"import {module}" for module, _, _ in targets]
    lines += ["import Lean.Util.CollectAxioms", "import Lean.Elab.Command", ""]
    qualified = []
    for module, statement, proof in targets:
        prefix = "Robust" if module == "NeuralGeneralization.RobustMain" else ""
        statement_name = f"NeuralGeneralization.{prefix}MainStatements.{statement}"
        proof_name = f"NeuralGeneralization.{prefix}MainProofs.{proof}"
        qualified.append((statement_name, proof_name))
        lines += [f"example : {statement_name} := {proof_name}",
                  f"#print axioms {proof_name}"]
    lines += ["", "open Lean Elab Command Meta in", "run_cmd do", "  let targets := #["]
    lines += [f"    (``{statement}, ``{proof})" +
              ("," if i+1 < len(qualified) else "]")
              for i, (statement, proof) in enumerate(qualified)]
    lines += [
        "  for (statement, proofName) in targets do",
        "    let info ← getConstInfo proofName",
        '    unless info.isTheorem do throwError "Main proof is not a theorem: {proofName}"',
        "    let exactType ← liftTermElabM <| isDefEq info.type (mkConst statement)",
        '    unless exactType do throwError "Wrong exact main type: {proofName}"',
        "    let axioms ← Lean.collectAxioms proofName",
        "    let allowed := #[``propext, ``Classical.choice, ``Quot.sound]",
        "    unless (axioms.filter fun a => !allowed.contains a).isEmpty do",
        '      throwError "Unexpected axioms for {proofName}: {axioms}"',
        '    logInfo m!"Verified exact main statement and standard-axiom closure: {proofName}"', ""]
    return "\n".join(lines)


def run_logged(command, cwd, env, log):
    with log.open('w') as stream:
        stream.write("Command: " + json.dumps(command) + "\n"); stream.flush()
        return subprocess.run(command, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT).returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--destination", type=Path, required=True)
    parser.add_argument("--main", choices=[*MAINS, "all"], default="subcritical")
    parser.add_argument("--subcritical-module", default=MAINS["subcritical"][0])
    parser.add_argument("--toolchain-bin", type=Path)
    parser.add_argument("--cpu-list", help="Optional Linux taskset CPU list, e.g. 0,1")
    parser.add_argument("--fresh-dependencies", action="store_true")
    parser.add_argument("--prepare-only", action="store_true", help="Create/check snapshot; does not certify any theorem")
    args = parser.parse_args()
    project, destination = args.project.resolve(), args.destination.resolve()
    if destination.exists(): raise ValueError(f"Refusing existing destination: {destination}")
    MAINS["subcritical"] = (args.subcritical_module, *MAINS["subcritical"][1:])
    targets = list(MAINS.values()) if args.main == "all" else [MAINS[args.main]]
    modules = [target[0] for target in targets]
    closure = project_closure(project, modules)
    paths = sorted([*closure, *(Path(name) for name in CONFIGS)])
    before = {str(path): digest(project/path) for path in paths}
    manifest = json.loads((project/"lake-manifest.json").read_text())
    deps_before = package_state(project, manifest)
    destination.mkdir(parents=True)
    evidence = destination/"verification"; evidence.mkdir()
    write_json(evidence/"source-before.json", before)
    write_json(evidence/"dependencies-before.json", deps_before)
    write_json(evidence/"project-import-closure.json", [str(path) for path in closure])
    for path in paths:
        (destination/path).parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(project/path, destination/path)
    copied = {str(path): digest(destination/path) for path in paths}
    if copied != before: raise ValueError("Sources changed while the isolated snapshot was copied")
    packages = destination/manifest.get("packagesDir", ".lake/packages")
    packages.parent.mkdir(parents=True, exist_ok=True)
    source_packages = project/manifest.get("packagesDir", ".lake/packages")
    if args.fresh_dependencies:
        packages.mkdir()
        for package in manifest["packages"]:
            shutil.copytree(source_packages/package["name"], packages/package["name"],
                            ignore=shutil.ignore_patterns(".lake"), symlinks=True)
    else:
        packages.symlink_to(source_packages, target_is_directory=True)
    audit = destination/"ExactMainAudit.lean"
    audit.write_text(audit_source(targets))
    env = dict(os.environ)
    # A user-supplied LEAN_PATH must not import the original project's objects.
    env.pop("LEAN_PATH", None)
    if args.toolchain_bin: env["PATH"] = str(args.toolchain_bin.resolve()) + os.pathsep + env.get("PATH", "")
    lake = shutil.which("lake", path=env["PATH"])
    lean = shutil.which("lean", path=env["PATH"])
    if not lake or not lean: raise ValueError("Lean and Lake must be on PATH or supplied by --toolchain-bin")
    version = subprocess.check_output([lean, "--version"], env=env, text=True).strip()
    required = (project/"lean-toolchain").read_text().strip().split(':')[-1].removeprefix('v')
    if f"version {required}," not in version and f"version {required})" not in version:
        raise ValueError(f"Toolchain version mismatch: expected {required}, got {version}")
    print("Hashing reusable external Lean artifacts", flush=True)
    artifact_before = package_artifacts(packages)
    write_json(evidence/"external-artifacts-before.json", artifact_before)
    summary = {"status": "PREPARED_ONLY", "started_utc": datetime.now(timezone.utc).isoformat(),
               "project": str(project), "snapshot": str(destination), "targets": targets,
               "project_source_count": len(closure), "lean_version": version,
               "external_dependencies": "fresh source rebuild" if args.fresh_dependencies else "shared pinned package cache",
               "project_object_cache_reused": False, "audit_sha256": digest(audit),
               "lean_executable_sha256": digest(Path(lean).resolve()),
               "lake_executable_sha256": digest(Path(lake).resolve()),
               "external_artifacts_before_count": len(artifact_before),
               "verifier_sha256": digest(Path(__file__).resolve())}
    write_json(evidence/"result.json", summary)
    print(f"Prepared {len(closure)} project modules in {destination}; external dependencies: {summary['external_dependencies']}", flush=True)
    if args.prepare_only: return
    prefix = ["taskset", "-c", args.cpu_list] if args.cpu_list else []
    print(f"Building from source; log: {evidence/'build.log'}", flush=True)
    build_code = run_logged([*prefix, lake, "--no-cache", "build", *modules], destination, env, evidence/"build.log")
    audit_code = None
    if build_code == 0:
        print(f"Checking exact types and full theorem axiom closures; log: {evidence/'audit.log'}", flush=True)
        audit_code = run_logged([*prefix, lake, "env", "lean", "-j1", str(audit)], destination, env, evidence/"audit.log")
    after = {str(path): digest(project/path) for path in paths}
    snapshot_after = {str(path): digest(destination/path) for path in paths}
    deps_after = package_state(project, manifest)
    write_json(evidence/"source-after.json", after)
    write_json(evidence/"snapshot-after.json", snapshot_after)
    write_json(evidence/"dependencies-after.json", deps_after)
    artifact_after = package_artifacts(packages)
    write_json(evidence/"external-artifacts-after.json", artifact_after)
    artifacts_stable = all(artifact_after.get(name) == sha for name, sha in artifact_before.items())
    unchanged = before == after == snapshot_after and deps_before == deps_after and artifacts_stable
    passed = build_code == 0 and audit_code == 0 and unchanged
    summary.update(status="PASS" if passed else "FAIL", build_exit_code=build_code,
                   audit_exit_code=audit_code, source_and_dependency_state_unchanged=unchanged,
                   existing_external_artifacts_unchanged=artifacts_stable,
                   external_artifacts_after_count=len(artifact_after),
                   completed_utc=datetime.now(timezone.utc).isoformat())
    write_json(evidence/"result.json", summary)
    print(f"{summary['status']}: {evidence/'result.json'}", flush=True)
    if not passed: sys.exit(1)


if __name__ == "__main__":
    try: main()
    except (ValueError, FileNotFoundError, subprocess.CalledProcessError) as error:
        print(f"VERIFICATION NOT COMPLETED: {error}", file=sys.stderr)
        sys.exit(1)
