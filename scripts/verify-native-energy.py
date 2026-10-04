#!/usr/bin/env python3
"""Verify finite IOKit requests without changing preferences or invoking forced sleep."""
import hashlib
import json
import re
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "out/verification/phase02"
EXECUTABLE = ROOT / "out/Still-preview.app/Contents/MacOS/Still"


def verify():
    if not EXECUTABLE.is_file():
        raise RuntimeError("Build Still-preview.app first")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for name in ("progress.json", "energy.json"):
        (OUTPUT / name).unlink(missing_ok=True)
    pmset = {}
    with (OUTPUT / "energy-launch.log").open("w") as log:
        process = subprocess.Popen([str(EXECUTABLE), "--energy-probe", str(OUTPUT)], stdout=log, stderr=subprocess.STDOUT)
        try:
            deadline = time.monotonic() + 20
            while process.poll() is None and time.monotonic() < deadline:
                progress = OUTPUT / "progress.json"
                if progress.exists():
                    phase = json.loads(progress.read_text())["phase"]
                    if phase in ("system-only", "system-and-display") and phase not in pmset:
                        listing = subprocess.run(["pmset", "-g", "assertions"], capture_output=True, timeout=5, check=True).stdout.decode("utf-8", errors="replace")
                        # Retain only this subprocess's own named requests; never export other app names.
                        pattern = re.compile(rf"\bpid\s+{process.pid}\(")
                        own_lines = [line for line in listing.splitlines() if pattern.search(line) and "Still " in line and "timed" in line]
                        pmset[phase] = [{"ownerPid": process.pid, "assertionType": kind}
                                        for kind in ("PreventUserIdleSystemSleep", "PreventUserIdleDisplaySleep")
                                        if any(kind in line for line in own_lines)]
                time.sleep(0.1)
            if process.poll() is None:
                raise RuntimeError("Native energy probe exceeded 20 seconds")
            process.wait(timeout=5)
            result = json.loads((OUTPUT / "energy.json").read_text())
            checks = result.get("checks", {})
            checks["pmsetShowsSystemRequest"] = any(item["assertionType"] == "PreventUserIdleSystemSleep" for item in pmset.get("system-only", []))
            checks["pmsetShowsDisplayRequest"] = any(item["assertionType"] == "PreventUserIdleDisplaySleep" for item in pmset.get("system-and-display", []))
            result["checks"] = checks
            result["pmsetOwnAssertions"] = pmset
            result["executableSHA256"] = hashlib.sha256(EXECUTABLE.read_bytes()).hexdigest()
            result["allPassed"] = result.get("allPassed", False) and all(checks.values()) and process.returncode == 0
            (OUTPUT / "energy.json").write_text(json.dumps(result, indent=2) + "\n")
            print(json.dumps({"allPassed": result["allPassed"], "checks": checks, "executableSHA256": result["executableSHA256"]}, indent=2))
            if not result["allPassed"]:
                raise RuntimeError("Native energy probe failed; inspect its local receipt")
        finally:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=5)


if __name__ == "__main__":
    verify()
