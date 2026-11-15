#!/usr/bin/env python3
"""Build the online lower-bound proof closure serially, then audit its axioms.

Run from a checkout with the pinned Lean toolchain and mathlib dependencies
installed. Lake still checks source/dependency hashes and reuses valid artifacts.
Serial project-module builds limit the peak memory of the rational certificate.
Use --plan to print the dependency order without building anything.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import subprocess


def project_order(root: Path, target: str) -> list[str]:
    done: set[str] = set()
    active: set[str] = set()
    order: list[str] = []

    def visit(module: str) -> None:
        if module in done:
            return
        if module in active:
            raise ValueError(f"Import cycle involving {module}")
        source = root / (module.replace(".", "/") + ".lean")
        if not source.is_file():
            raise FileNotFoundError(source)
        active.add(module)
        for dep in re.findall(r"(?m)^(?:public )?import\s+([\w.]+)", source.read_text()):
            if dep == "NeuralGeneralization" or dep.startswith("NeuralGeneralization."):
                visit(dep)
        active.remove(module)
        done.add(module)
        order.append(module)

    visit(target)
    return order


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", action="store_true")
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    modules = project_order(root, "NeuralGeneralization.OnlineLowerFullPaperCoverage")
    if args.plan:
        print("\n".join(modules))
        return
    env = os.environ.copy()
    env.setdefault("LEAN_NUM_THREADS", "2")
    logs = root / ".lake" / "online-lower-coverage"
    logs.mkdir(parents=True, exist_ok=True)
    for i, module in enumerate(modules, 1):
        log = logs / f"{module}.log"
        print(f"[{i}/{len(modules)}] {module}", flush=True)
        with log.open("w") as stream:
            result = subprocess.run(["lake", "build", module], cwd=root, env=env,
                                    stdout=stream, stderr=subprocess.STDOUT)
        if result.returncode:
            print(log.read_text())
            raise SystemExit(result.returncode)
    subprocess.run(["lake", "env", "lean", "CheckOnlineLowerCoverage.lean"],
                   cwd=root, env=env, check=True)


if __name__ == "__main__":
    main()
