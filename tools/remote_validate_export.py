"""GitHub-hosted CI only. Never run Godot on the development laptop."""
import os
from pathlib import Path
import re
import subprocess


def main():
    # Refuse local execution before looking up or invoking an engine executable.
    if (os.environ.get("GITHUB_ACTIONS") != "true"
            or os.environ.get("RUNNER_ENVIRONMENT") != "github-hosted"):
        raise SystemExit("Refusing execution outside a GitHub-hosted runner.")
    root = Path(__file__).resolve().parents[1]
    logs = root / "ci-logs"
    logs.mkdir(exist_ok=True)
    (root / "build/web").mkdir(parents=True, exist_ok=True)
    commands = [
        ("import", ["--import"]),
        ("resources", ["--script", "res://tests/remote_resource_check.gd"]),
        ("main", ["--quit-after", "2"]),
        ("export", ["--export-release", "Web", "build/web/index.html"]),
    ]
    for label, args in commands:
        result = subprocess.run(
            ["godot", "--headless", "--path", str(root), *args],
            cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
            text=True, timeout=300, check=False,
        )
        (logs / f"{label}.log").write_text(result.stdout, encoding="utf-8")
        print(result.stdout, flush=True)
        # Some engine errors are logged without a failing process exit status.
        if result.returncode or re.search(r"(?im)^\s*(?:SCRIPT ERROR|ERROR|Parse Error):", result.stdout):
            raise SystemExit(f"Remote {label} failed; see ci-logs/{label}.log")
    for name in ("index.html", "index.js", "index.wasm", "index.pck"):
        path = root / "build/web" / name
        if not path.is_file() or path.stat().st_size == 0:
            raise SystemExit(f"Missing/empty export file: {name}")
    print("Remote validation and web export completed.")


if __name__ == "__main__":
    main()
