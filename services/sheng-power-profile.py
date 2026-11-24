"""Apply the sheng prime-core frequency cap selected by Power Profiles Daemon."""
from pathlib import Path
import signal
import subprocess
import sys

policy = Path("/sys/devices/system/cpu/cpufreq/policy7")
limit = policy / "scaling_max_freq"
saver_max = 2342400
baseline = None


def apply_profile(profile):
    global baseline
    current = int(limit.read_text())
    if profile == "power-saver":
        minimum = int((policy / "scaling_min_freq").read_text())
        if baseline is None and minimum <= saver_max < current:
            limit.write_text(f"{saver_max}\n")
            baseline = current
    elif baseline is not None:
        if current == saver_max:
            limit.write_text(f"{baseline}\n")
        baseline = None


def stop(_signal, _frame):
    raise SystemExit(0)


if (policy / "scaling_driver").read_text().strip() != "qcom-cpufreq-hw":
    sys.exit("Unexpected sheng CPU frequency driver")

signal.signal(signal.SIGTERM, stop)
monitor = subprocess.Popen(
    [sys.argv[1], "monitor", "--system",
     "--dest", "org.freedesktop.UPower.PowerProfiles",
     "--object-path", "/org/freedesktop/UPower/PowerProfiles"],
    stdout=subprocess.PIPE, text=True,
)
try:
    for line in monitor.stdout:
        if "is owned by " in line or "ActiveProfile" in line:
            profile = subprocess.check_output([sys.argv[2], "get"], text=True).strip()
            apply_profile(profile)
        elif "does not have an owner" in line:
            apply_profile("balanced")
finally:
    monitor.terminate()
    monitor.wait()
    apply_profile("balanced")
