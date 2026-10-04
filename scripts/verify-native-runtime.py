#!/usr/bin/env python3
"""Bounded local native launch/geometry probe, not UI or authentication automation."""
import hashlib
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def worker(path):
    completed = 0
    published = 0.0
    while True:
        hashlib.sha256(f"still-synthetic-work-{completed}".encode()).digest()
        completed += 1
        now = time.monotonic()
        if now - published >= 0.1:
            temporary = path.with_suffix(".tmp")
            temporary.write_text(json.dumps({"completed": completed}))
            temporary.replace(path)
            published = now


def wait_for_file(path, timeout=12):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.exists():
            return
        time.sleep(0.1)
    raise RuntimeError(f"No receipt produced within {timeout}s: {path.name}")


def stop(process):
    if process is not None and process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)


def verify(app_name="Still", output_directory=None):
    output = ROOT / ("out/verification/phase01-refinement" if app_name == "Still-preview" else "out/verification/phase01")
    if output_directory is not None:
        output = ROOT / output_directory
    output = output.resolve()
    if not output.is_relative_to((ROOT / "out").resolve()):
        raise RuntimeError("Probe output must stay inside the generated out/ directory")
    executable = ROOT / f"out/{app_name}.app/Contents/MacOS/Still"
    if not executable.is_file():
        raise RuntimeError("Build out/Still.app first with scripts/build-macos.sh")
    output.mkdir(parents=True, exist_ok=True)
    receipt_path = output / "runtime.json"
    progress_path = output / "synthetic-progress.json"
    # Only this probe's generated receipt is cleared; no app/user data is deleted.
    receipt_path.unlink(missing_ok=True)
    progress_path.unlink(missing_ok=True)
    for name in ("porcelain-light.png", "porcelain-dark.png"):
        (output / name).unlink(missing_ok=True)
    workload = app = None
    try:
        workload = subprocess.Popen([sys.executable, __file__, "--worker", str(progress_path)])
        wait_for_file(progress_path)
        before = json.loads(progress_path.read_text())["completed"]
        with (output / "launch.log").open("w") as log:
            app = subprocess.Popen(
                [str(executable), "--cover", "--evidence-directory", str(output)],
                stdout=log, stderr=subprocess.STDOUT,
            )
            wait_for_file(receipt_path)
            # Wait for the two in-process native view exports to finish.
            wait_for_file(output / "porcelain-dark.png")
            time.sleep(0.75)
            during = json.loads(progress_path.read_text())["completed"]
            alive = app.poll() is None
            receipt = json.loads(receipt_path.read_text())
            stop(app)
            time.sleep(0.25)
            after = json.loads(progress_path.read_text())["completed"]
            checks = {
                "appAliveWhilePanelsReportedVisible": alive,
                "onePanelPerReportedDisplay": receipt["panelCount"] == receipt["displayCount"] > 0,
                "allPanelFramesMatchReportedScreens": all(w["matchesScreenFrame"] for w in receipt["windows"]),
                "allPanelsReportedVisible": all(w["visible"] for w in receipt["windows"]),
                "allPanelsAtExpectedCurtainLevel": all(w["level"] == receipt["expectedCurtainLevel"] for w in receipt["windows"]),
                "displayFontRegistered": receipt["displayFontRegistered"],
                "syntheticProcessMadeProgress": before < during < after,
                "ownedAppTerminated": app.poll() is not None,
            }
            result = {
                "kind": "native-structural-smoke",
                "executableSHA256": hashlib.sha256(executable.read_bytes()).hexdigest(),
                "checks": checks,
                "syntheticIterations": {"before": before, "during": during, "after": after},
                "boundary": "Not visual coverage, authentication, sleep prevention or universal workload proof.",
            }
            (output / "smoke.json").write_text(json.dumps(result, indent=2) + "\n")
            print(json.dumps(result, indent=2))
            if not all(checks.values()):
                raise RuntimeError("One or more native structural checks failed")
    finally:
        stop(app)
        stop(workload)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--worker":
        worker(Path(sys.argv[2]))
    else:
        import argparse
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("--app", choices=["Still", "Still-preview"], default="Still")
        parser.add_argument("--output", help="Local artifact directory relative to workspace root")
        arguments = parser.parse_args()
        verify(arguments.app, arguments.output)
